#include "filesys/directory.h"
#include <stdio.h>
#include <string.h>
#include <list.h>
#include "filesys/free-map.h"
#include "filesys/filesys.h"
#include "filesys/inode.h"
#include "threads/malloc.h"
/* A directory structure.
   - inode: Pointer to the inode representing the directory.
   - pos: Current position for reading directory entries. */
struct dir
{
  struct inode *inode; /* Backing inode. */
  off_t pos;           /* Current read position. */
};

/* Represents a single directory entry.
   - inode_sector: Sector number of the file or subdirectory.
   - name: Null-terminated name of the entry.
   - in_use: True if the entry is in use, false if free. */
struct dir_entry
{
  block_sector_t inode_sector; /* Inode sector number. */
  char name[NAME_MAX + 1];     /* Null-terminated name. */
  bool in_use;                 /* Entry usage flag. */
};

/* Creates a new directory at SECTOR with PARENT_SECTOR as its parent.
   Returns the created inode on success, or NULL on failure. */
struct inode *
dir_create(block_sector_t sector, block_sector_t parent_sector)
{
  struct inode *inode = inode_create(sector, DIR_INODE);
  if (inode != NULL)
  {
    struct dir_entry entries[2];

    memset(entries, 0, sizeof entries);

    /* Add "." entry (self-reference). */
    entries[0].inode_sector = sector;
    strlcpy(entries[0].name, ".", sizeof entries[0].name);
    entries[0].in_use = true;

    /* Add ".." entry (parent directory reference). */
    entries[1].inode_sector = parent_sector;
    strlcpy(entries[1].name, "..", sizeof entries[1].name);
    entries[1].in_use = true;

    /* Write directory entries to the inode. */
    if (inode_write_at(inode, entries, sizeof entries, 0) != sizeof entries)
    {
      inode_remove(inode); /* Cleanup on failure. */
      inode_close(inode);
      inode = NULL;
    }
  }
  return inode;
}

/* Opens a directory for the given INODE and takes ownership.
   Returns the directory pointer on success, NULL on failure. */
struct dir *
dir_open(struct inode *inode)
{
  struct dir *dir = calloc(1, sizeof *dir);
  if (inode != NULL && dir != NULL && inode_get_type(inode) == DIR_INODE)
  {
    dir->inode = inode;
    dir->pos = 0;
    return dir;
  }
  else
  {
    inode_close(inode);
    free(dir);
    return NULL;
  }
}

/* Opens the root directory and returns its pointer.
   Returns NULL on failure. */
struct dir *
dir_open_root(void)
{
  return dir_open(inode_open(ROOT_DIR_SECTOR));
}

/* Reopens the given directory and returns a new instance for the same inode.
   Returns NULL on failure. */
struct dir *
dir_reopen(struct dir *dir)
{
  return dir_open(inode_reopen(dir->inode));
}

/* Closes the given directory and frees resources. */
void dir_close(struct dir *dir)
{
  if (dir != NULL)
  {
    inode_close(dir->inode);
    free(dir);
  }
}

/* Retrieves the inode associated with the directory. */
struct inode *
dir_get_inode(struct dir *dir)
{
  return dir->inode;
}

/* Searches the directory DIR for a file with NAME.
   If found, stores the entry in EP and the offset in OFSP.
   Returns true if successful, false if not found. */
static bool
lookup(const struct dir *dir, const char *name,
       struct dir_entry *ep, off_t *ofsp)
{
  struct dir_entry e;
  size_t ofs;

  ASSERT(dir != NULL);
  ASSERT(name != NULL);

  for (ofs = 0; inode_read_at(dir->inode, &e, sizeof e, ofs) == sizeof e;
       ofs += sizeof e)
    if (e.in_use && !strcmp(name, e.name))
    {
      if (ep != NULL)
        *ep = e;
      if (ofsp != NULL)
        *ofsp = ofs;
      return true;
    }
  return false;
}

/* Searches DIR for a file with NAME and returns true if found.
   Sets *INODE to the inode of the file on success, NULL on failure.
   Caller must close the returned inode. */
bool dir_lookup(const struct dir *dir, const char *name,
                struct inode **inode)
{
  struct dir_entry e;
  bool ok;

  ASSERT(dir != NULL);
  ASSERT(name != NULL);

  inode_lock(dir->inode);
  ok = lookup(dir, name, &e, NULL);
  inode_unlock(dir->inode);

  *inode = ok ? inode_open(e.inode_sector) : NULL;
  return *inode != NULL;
}

/* Adds a file named NAME to DIR with the given inode sector INODE_SECTOR.
   Fails if NAME already exists or is invalid.
   Returns true if successful, false on failure. */
bool dir_add(struct dir *dir, const char *name, block_sector_t inode_sector)
{
  struct dir_entry e;
  off_t ofs;
  bool success = false;

  ASSERT(dir != NULL);
  ASSERT(name != NULL);

  /* Validate NAME. */
  if (*name == '\0' || strchr(name, '/') || strlen(name) > NAME_MAX)
    return false;

  /* Check for existing entry. */
  inode_lock(dir->inode);
  if (lookup(dir, name, NULL, NULL))
    goto done;

  /* Find a free slot or end of file. */
  for (ofs = 0; inode_read_at(dir->inode, &e, sizeof e, ofs) == sizeof e;
       ofs += sizeof e)
    if (!e.in_use)
      break;

  /* Write new entry. */
  e.in_use = true;
  strlcpy(e.name, name, sizeof e.name);
  e.inode_sector = inode_sector;
  success = inode_write_at(dir->inode, &e, sizeof e, ofs) == sizeof e;

done:
  inode_unlock(dir->inode);
  return success;
}

/* Removes any entry for NAME in DIR.
   Returns true if successful, false on failure,
   which occurs only if there is no file with the given NAME. */
bool dir_remove(struct dir *dir, const char *name)
{
  struct dir_entry e;
  struct inode *inode = NULL;
  bool success = false;
  off_t ofs;

  ASSERT(dir != NULL);
  ASSERT(name != NULL);

  /* Don't allow . or .. to be removed */
  if (strcmp(name, ".") == 0 || strcmp(name, "..") == 0)
    return false;

  /* Find directory entry. */
  inode_lock(dir->inode);
  if (!lookup(dir, name, &e, &ofs))
    goto done;

  /* Open inode. */
  inode = inode_open(e.inode_sector);
  if (inode == NULL)
    goto done;

  /* Verify that it is not an in-use or non-empty directory. */
  if (inode_get_type(inode) == DIR_INODE)
  {
    if (inode_open_cnt(inode) > 1)
      goto done;

    struct dir_entry scan_entry;
    off_t scan_offset;
    int in_use_count = 0;

    for (scan_offset = 0;
         inode_read_at(inode,
                       &scan_entry,
                       sizeof scan_entry,
                       scan_offset) == sizeof scan_entry;
         scan_offset += sizeof scan_entry)
    {
      if (scan_entry.in_use)
        in_use_count++;
    }

    if (in_use_count > 2)
      goto done;
  }

  /* Erase directory entry. */
  e.in_use = false;
  if (inode_write_at(dir->inode, &e, sizeof e, ofs) != sizeof e)
    goto done;

  /* Remove inode. */
  inode_remove(inode);
  success = true;

done:
  inode_unlock(dir->inode);
  inode_close(inode);
  return success;
}

/* Reads the next directory entry in DIR and stores the name in
   NAME.  Returns true if successful, false if the directory
   contains no more entries. */
bool dir_readdir(struct dir *dir, char name[NAME_MAX + 1])
{
  struct dir_entry e;

  inode_lock(dir->inode);
  while (inode_read_at(dir->inode, &e, sizeof e, dir->pos) == sizeof e)
  {
    dir->pos += sizeof e;
    if (e.in_use && strcmp(e.name, ".") && strcmp(e.name, ".."))
    {
      inode_unlock(dir->inode);
      strlcpy(name, e.name, NAME_MAX + 1);
      return true;
    }
  }
  inode_unlock(dir->inode);
  return false;
}