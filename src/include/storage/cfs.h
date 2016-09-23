#ifndef __CFS_H__
#define __CFS_H__

#include "port/atomics.h"

#define CFS_VERSION "0.21"

#define CFS_GC_LOCK  0x10000000

#define CFS_LOCK_MIN_TIMEOUT 100    /* microseconds */
#define CFS_LOCK_MAX_TIMEOUT 10000  /* microseconds */
#define CFS_DISABLE_TIMEOUT  1000   /* milliseconds */
#define CFS_ESTIMATE_PROBES  10 

#define CFS_MAX_COMPRESSED_SIZE(size) ((size)*2)
#define CFS_MIN_COMPRESSED_SIZE(size) ((size)*2/3)

#define LZ_COMPRESSOR     1
#define ZLIB_COMPRESSOR   2
#define LZ4_COMPRESSOR    3
#define SNAPPY_COMPRESSOR 4
#define LCFSE_COMPRESSOR  5
#define ZSTD_COMPRESSOR   6

#ifndef CFS_COMPRESSOR 
#define CFS_COMPRESSOR ZLIB_COMPRESSOR
#endif

#define CFS_RC4_DROP_N 3072 
#define CFS_CIPHER_KEY_SIZE 256

typedef uint64 inode_t;

#define CFS_INODE_SIZE(inode) ((uint32)((inode) >> 32))
#define CFS_INODE_OFFS(inode) ((uint32)(inode))
#define CFS_INODE(size,offs)  (((inode_t)(size) << 32) | (offs))

size_t cfs_compress(void* dst, size_t dst_size, void const* src, size_t src_size);
size_t cfs_decompress(void* dst, size_t dst_size, void const* src, size_t src_size);
char const* cfs_algorithm(void);

typedef struct
{
	pg_atomic_flag gc_started;
	int            n_workers;
	int            max_iterations;
	bool           gc_enabled;
	uint8          rc4_init_state[CFS_CIPHER_KEY_SIZE];
} CfsState;

typedef struct 
{
	pg_atomic_uint32 physSize;
	pg_atomic_uint32 virtSize;
	pg_atomic_uint32 usedSize;
	pg_atomic_uint32 lock;
	pid_t            postmasterPid;
	uint64           generation;
	inode_t          inodes[RELSEG_SIZE];
} FileMap;

void     cfs_lock_file(FileMap* map, char const* path);
void     cfs_unlock_file(FileMap* map);
uint32   cfs_alloc_page(FileMap* map, uint32 oldSize, uint32 newSize);
void     cfs_extend(FileMap* map, uint32 pos);

int      cfs_msync(FileMap* map);
FileMap* cfs_mmap(int md);
int      cfs_munmap(FileMap* map);
void     cfs_initialize(void);

void     cfs_encrypt(void* block, uint32 offs, uint32 size);
void     cfs_decrypt(void* block, uint32 offs, uint32 size);

extern CfsState* cfs_state;

extern int cfs_gc_delay;
extern int cfs_gc_period;
extern int cfs_gc_workers;
extern int cfs_gc_threshold;
extern int cfs_level;
extern bool cfs_encryption;
#endif


