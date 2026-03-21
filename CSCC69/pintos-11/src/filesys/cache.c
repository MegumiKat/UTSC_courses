#include "filesys/cache.h"
#include <debug.h>
#include <string.h>
#include "filesys/filesys.h"
#include "devices/timer.h"
#include "threads/malloc.h"
#include "threads/synch.h"
#include "threads/thread.h"

#define INVALID_SECTOR ((block_sector_t) - 1)

/* A cached block structure. */
struct cache_block
{
  struct lock block_lock;                 /* Protects block during access. */
  struct condition no_readers_or_writers; /* No readers or writers active. */
  struct condition no_writers;            /* No writers active. */
  int readers, read_waiters;              /* Number of readers, number waiting to read. */
  int writers, write_waiters;             /* Number of writers (max 1), number waiting to write. */

  block_sector_t sector; /* Disk sector number, INVALID_SECTOR if free. */

  bool up_to_date; /* True if data[] is current. */
  bool dirty;      /* True if data[] needs to be written back. */

  struct lock data_lock;           /* Protects access to data[]. */
  uint8_t data[BLOCK_SECTOR_SIZE]; /* Cached disk data. */
};

/* Cache settings. */
#define CACHE_CNT 64
struct cache_block cache[CACHE_CNT];

/* Cache lock for synchronization. */
struct lock cache_sync; /* Prevents race conditions during block allocation and lookup. */

/* Cache eviction pointer. */
static int hand = 0; /* Points to the next block for eviction. */

static void flushd_init(void);                        /* Initializes the flush daemon. */
static void readaheadd_init(void);                    /* Initializes the read-ahead daemon. */
static void readaheadd_submit(block_sector_t sector); /* Submits a read-ahead request. */

/* Initializes the cache. */
void cache_init(void)
{
  int i;
  lock_init(&cache_sync); /* Initialize the cache lock. */
  for (i = 0; i < CACHE_CNT; i++)
  {
    struct cache_block *b = &cache[i];
    lock_init(&b->block_lock);            /* Initialize block lock. */
    cond_init(&b->no_readers_or_writers); /* No readers or writers condition. */
    cond_init(&b->no_writers);            /* No writers condition. */
    b->readers = b->read_waiters = 0;     /* Initialize reader counts. */
    b->writers = b->write_waiters = 0;    /* Initialize writer counts. */
    b->sector = INVALID_SECTOR;           /* Mark as free. */
    lock_init(&b->data_lock);             /* Initialize data lock. */
  }
  flushd_init();     /* Start the flush daemon. */
  readaheadd_init(); /* Start the read-ahead daemon. */
}

/* Flushes the cache to disk. */
void cache_flush(void)
{
  int i;
  for (i = 0; i < CACHE_CNT; i++)
  {
    struct cache_block *b = &cache[i];
    block_sector_t sector;

    lock_acquire(&b->block_lock); /* Lock the block. */
    sector = b->sector;
    lock_release(&b->block_lock); /* Unlock after reading sector. */

    if (sector == INVALID_SECTOR) /* Skip if not allocated. */
      continue;

    b = cache_lock(sector, EXCLUSIVE); /* Get exclusive access. */
    if (b->up_to_date && b->dirty)     /* Check if data needs flushing. */
    {
      block_write(fs_device, b->sector, b->data); /* Write to disk. */
      b->dirty = false;                           /* Mark as clean. */
    }
    cache_unlock(b); /* Release block lock. */
  }
}

/* Acquires a cache block for reading or writing. */
struct cache_block *cache_lock(block_sector_t sector, enum lock_type type)
{
  int i;

try_again:
  lock_acquire(&cache_sync); /* Lock the cache for allocation/search. */

  /* Check if the block is already cached. */
  for (i = 0; i < CACHE_CNT; i++)
  {
    struct cache_block *b = &cache[i];
    lock_acquire(&b->block_lock); /* Lock the block. */
    if (b->sector != sector)      /* Skip if not the target block. */
    {
      lock_release(&b->block_lock);
      continue;
    }
    lock_release(&cache_sync); /* Release cache lock after finding. */

    /* Acquire read or write access. */
    if (type == NON_EXCLUSIVE) /* Non-exclusive (read) access. */
    {
      b->read_waiters++;
      while (b->writers || b->write_waiters)
        cond_wait(&b->no_writers, &b->block_lock);
      b->readers++;
      b->read_waiters--;
    }
    else /* Exclusive (write) access. */
    {
      b->write_waiters++;
      while (b->readers || b->read_waiters || b->writers)
        cond_wait(&b->no_readers_or_writers, &b->block_lock);
      b->writers++;
      b->write_waiters--;
    }
    lock_release(&b->block_lock); /* Release block lock. */
    ASSERT(b->sector == sector);  /* Ensure correct block. */
    return b;
  }

  /* Find an empty cache slot. */
  for (i = 0; i < CACHE_CNT; i++)
  {
    struct cache_block *b = &cache[i];
    lock_acquire(&b->block_lock);
    if (b->sector == INVALID_SECTOR) /* Found a free block. */
    {
      lock_release(&b->block_lock); /* Release for initialization. */
      b->sector = sector;
      b->up_to_date = false;
      ASSERT(b->readers == 0 && b->writers == 0);
      if (type == NON_EXCLUSIVE)
        b->readers = 1;
      else
        b->writers = 1;
      lock_release(&cache_sync); /* Release cache lock. */
      return b;
    }
    lock_release(&b->block_lock); /* Release block lock. */
  }

  /* Evict a cache block if no empty slots. */
  for (i = 0; i < CACHE_CNT; i++)
  {
    struct cache_block *b = &cache[hand];
    if (++hand >= CACHE_CNT) /* Circular hand increment. */
      hand = 0;

    lock_acquire(&b->block_lock);                                        /* Try to acquire block lock. */
    if (b->readers || b->writers || b->read_waiters || b->write_waiters) /* Busy block. */
    {
      lock_release(&b->block_lock);
      continue;
    }
    b->writers = 1;
    lock_release(&b->block_lock);
    lock_release(&cache_sync); /* Release cache lock for write-back. */

    /* Write back if dirty. */
    if (b->up_to_date && b->dirty)
    {
      block_write(fs_device, b->sector, b->data);
      b->dirty = false;
    }

    /* Try to free the block. */
    lock_acquire(&b->block_lock);
    b->writers = 0;
    if (!b->read_waiters && !b->write_waiters) /* No waiters, free it. */
    {
      b->sector = INVALID_SECTOR;
    }
    else /* Wake up waiting readers/writers. */
    {
      if (b->read_waiters)
        cond_broadcast(&b->no_writers, &b->block_lock);
      else
        cond_signal(&b->no_readers_or_writers, &b->block_lock);
    }
    lock_release(&b->block_lock); /* Release block lock. */
    goto try_again;               /* Retry finding a block. */
  }

  /* Wait and retry if all blocks are busy. */
  lock_release(&cache_sync);
  timer_msleep(1000); /* Delay to reduce contention. */
  goto try_again;
}

/* Reads the data from block B if not up-to-date and returns a pointer to it.
   Caller must have a lock on B (exclusive or non-exclusive). */
void *cache_read(struct cache_block *b)
{
  lock_acquire(&b->data_lock); /* Lock data for consistency. */
  if (!b->up_to_date)          /* If data is not current, read from disk. */
  {
    block_read(fs_device, b->sector, b->data); /* Read from disk. */
    b->up_to_date = true;                      /* Mark data as current. */
    b->dirty = false;                          /* Mark as clean after reading. */
  }
  lock_release(&b->data_lock); /* Release data lock. */
  return b->data;              /* Return data pointer. */
}

/* Zeros out the block B and returns a pointer to zeroed data.
   Caller must have an exclusive lock on B. */
void *cache_zero(struct cache_block *b)
{
  ASSERT(b->writers);                    /* Ensure write lock. */
  memset(b->data, 0, BLOCK_SECTOR_SIZE); /* Clear data. */
  b->up_to_date = true;                  /* Mark as current. */
  b->dirty = true;                       /* Mark as dirty. */
  return b->data;                        /* Return zeroed data. */
}

/* Marks block B as dirty, indicating it needs to be written back.
   Caller must have a lock on B and B must be up-to-date. */
void cache_dirty(struct cache_block *b)
{
  ASSERT(b->up_to_date); /* Ensure data is current. */
  b->dirty = true;       /* Mark as dirty. */
}

/* Unlocks block B, making it a candidate for eviction if no longer locked. */
void cache_unlock(struct cache_block *b)
{
  lock_acquire(&b->block_lock); /* Lock the block for update. */
  if (b->readers)               /* If there are readers, decrease the count. */
  {
    ASSERT(b->writers == 0); /* No writers should exist. */
    if (--b->readers == 0)   /* If no more readers, signal. */
      cond_signal(&b->no_readers_or_writers, &b->block_lock);
  }
  else if (b->writers) /* If there is a writer, decrease the count. */
  {
    ASSERT(b->readers == 0);
    ASSERT(b->writers == 1); /* Only one writer allowed. */
    b->writers--;
    if (b->read_waiters) /* Signal readers if waiting. */
      cond_broadcast(&b->no_writers, &b->block_lock);
    else /* Signal writers if no readers. */
      cond_signal(&b->no_readers_or_writers, &b->block_lock);
  }
  else
    NOT_REACHED();              /* Should never reach here. */
  lock_release(&b->block_lock); /* Release block lock. */
}

/* If SECTOR is in the cache, evicts it immediately without
   writing it back to disk (even if dirty).
   The block must be entirely unused. */
void cache_free(block_sector_t sector)
{
  int i;

  lock_acquire(&cache_sync);
  for (i = 0; i < CACHE_CNT; i++)
  {
    struct cache_block *b = &cache[i];

    lock_acquire(&b->block_lock);
    if (b->sector == sector)
    {
      lock_release(&cache_sync);

      /* Only invalidate the block if it's unused.  That
         should be the normal case, but it could be part of a
         read-ahead (in readaheadd()) or write-behind (in
         cache_flush()). */
      if (b->readers == 0 && b->read_waiters == 0 && b->writers == 0 && b->write_waiters == 0)
        b->sector = INVALID_SECTOR;

      lock_release(&b->block_lock);
      return;
    }
    lock_release(&b->block_lock);
  }
  lock_release(&cache_sync);
}

void cache_readahead(block_sector_t sector)
{
  readaheadd_submit(sector);
}

/* Flush daemon. */

static void flushd(void *aux);

/* Initializes flush daemon. */
static void
flushd_init(void)
{
  thread_create("flushd", PRI_MIN, flushd, NULL);
}

/* Flush daemon thread. */
static void
flushd(void *aux UNUSED)
{
  for (;;)
  {
    timer_msleep(30 * 1000);
    cache_flush();
  }
}

/* A block to read ahead. */
struct readahead_block
{
  struct list_elem list_elem; /* readahead_list element. */
  block_sector_t sector;      /* Sector to read. */
};

/* Protects readahead_list.
   Monitor lock for readahead_list_nonempty. */
static struct lock readahead_lock;

/* Signaled when a block is added to readahead_list. */
static struct condition readahead_list_nonempty;

/* List of blocks for read-ahead. */
static struct list readahead_list;

static void readaheadd(void *aux);

/* Initialize read-ahead daemon. */
static void
readaheadd_init(void)
{
  lock_init(&readahead_lock);
  cond_init(&readahead_list_nonempty);
  list_init(&readahead_list);
  thread_create("readaheadd", PRI_MIN, readaheadd, NULL);
}

/* Adds SECTOR to the read-ahead queue. */
static void
readaheadd_submit(block_sector_t sector)
{
  /* Allocate readahead block. */
  struct readahead_block *block = malloc(sizeof *block);
  if (block == NULL)
    return;
  block->sector = sector;

  /* Add block to list. */
  lock_acquire(&readahead_lock);
  list_push_back(&readahead_list, &block->list_elem);
  cond_signal(&readahead_list_nonempty, &readahead_lock);
  lock_release(&readahead_lock);
}

/* Read-ahead daemon. */
static void
readaheadd(void *aux UNUSED)
{
  for (;;)
  {
    struct readahead_block *ra_block;
    struct cache_block *cache_block;

    /* Get readahead block from list. */
    lock_acquire(&readahead_lock);
    while (list_empty(&readahead_list))
      cond_wait(&readahead_list_nonempty, &readahead_lock);
    ra_block = list_entry(list_pop_front(&readahead_list),
                          struct readahead_block, list_elem);
    lock_release(&readahead_lock);

    /* Read block into cache. */
    cache_block = cache_lock(ra_block->sector, NON_EXCLUSIVE);
    cache_read(cache_block);
    cache_unlock(cache_block);
    free(ra_block);
  }
}