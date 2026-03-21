#include "filesys/file.h"
#include <debug.h>
#include "filesys/free-map.h"
#include "filesys/inode.h"
#include "threads/malloc.h"
/* Represents an open file.
   - inode: File's inode.
   - pos: Current position for read/write.
   - deny_write: Set if write is denied. */
struct file
{
  struct inode *inode; /* File's inode. */
  off_t pos;           /* Current position. */
  bool deny_write;     /* Write denial status. */
};

/* Creates a file at SECTOR with initial LENGTH bytes.
   Returns the file inode on success, NULL on failure. */
struct inode *
file_create(block_sector_t sector, off_t length)
{
  struct inode *inode = inode_create(sector, FILE_INODE);
  if (inode != NULL && length > 0 && inode_write_at(inode, "", 1, length - 1) != 1)
  {
    inode_remove(inode);
    inode_close(inode);
    inode = NULL;
  }
  return inode;
}

/* Opens a file given its INODE, taking ownership.
   Returns the file pointer or NULL if failed. */
struct file *
file_open(struct inode *inode)
{
  struct file *file = calloc(1, sizeof *file);
  if (inode != NULL && file != NULL && inode_get_type(inode) == FILE_INODE)
  {
    file->inode = inode;
    file->pos = 0;
    file->deny_write = false;
    return file;
  }
  inode_close(inode);
  free(file);
  return NULL;
}

/* Reopens the given file and returns a new file pointer.
   Returns NULL on failure. */
struct file *
file_reopen(struct file *file)
{
  return file_open(inode_reopen(file->inode));
}

/* Closes the given file and releases resources. */
void file_close(struct file *file)
{
  if (file != NULL)
  {
    file_allow_write(file);
    inode_close(file->inode);
    free(file);
  }
}

/* Returns the inode associated with the file. */
struct inode *
file_get_inode(struct file *file)
{
  return file->inode;
}

/* Reads SIZE bytes from FILE into BUFFER starting from current position.
   Advances position by the number of bytes read.
   Returns the number of bytes actually read. */
off_t file_read(struct file *file, void *buffer, off_t size)
{
  off_t bytes_read = inode_read_at(file->inode, buffer, size, file->pos);
  file->pos += bytes_read;
  return bytes_read;
}

/* Reads SIZE bytes from FILE into BUFFER from offset FILE_OFS.
   Does not affect the current file position.
   Returns the number of bytes actually read. */
off_t file_read_at(struct file *file, void *buffer, off_t size, off_t file_ofs)
{
  return inode_read_at(file->inode, buffer, size, file_ofs);
}

/* Writes SIZE bytes from BUFFER into FILE at current position.
   Advances position by the number of bytes written.
   Returns the number of bytes written. */
off_t file_write(struct file *file, const void *buffer, off_t size)
{
  off_t bytes_written = inode_write_at(file->inode, buffer, size, file->pos);
  file->pos += bytes_written;
  return bytes_written;
}

/* Writes SIZE bytes from BUFFER into FILE at offset FILE_OFS.
   Does not affect the current file position.
   Returns the number of bytes written. */
off_t file_write_at(struct file *file, const void *buffer, off_t size, off_t file_ofs)
{
  return inode_write_at(file->inode, buffer, size, file_ofs);
}

/* Denies write operations on the file until allowed or closed. */
void file_deny_write(struct file *file)
{
  ASSERT(file != NULL);
  if (!file->deny_write)
  {
    file->deny_write = true;
    inode_deny_write(file->inode);
  }
}
/* Re-enables write operations on FILE's inode.
   Other open files with the same inode may still deny writes. */
void file_allow_write(struct file *file)
{
  ASSERT(file != NULL);
  if (file->deny_write)
  {
    file->deny_write = false;
    inode_allow_write(file->inode);
  }
}

/* Returns the size of the file in bytes. */
off_t file_length(struct file *file)
{
  ASSERT(file != NULL);
  return inode_length(file->inode);
}

/* Sets the current read/write position in FILE to NEW_POS bytes from the start. */
void file_seek(struct file *file, off_t new_pos)
{
  ASSERT(file != NULL);
  ASSERT(new_pos >= 0);
  file->pos = new_pos;
}

/* Returns the current file position as a byte offset from the start. */
off_t file_tell(struct file *file)
{
  ASSERT(file != NULL);
  return file->pos;
}
