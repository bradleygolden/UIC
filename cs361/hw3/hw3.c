#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>

#include <limits.h>
#include <sys/types.h>

struct memory_region{
  size_t * start;
  size_t * end;
};

struct memory_region global_mem;
struct memory_region heap_mem;
struct memory_region stack_mem;

int marked = 0;
int unmarked = 0;
int freed = 0;
int allocated = 0;

//grabbing the address and size of the global memory region from proc 
void init_global_range(){
  char file[100];
  char * line=NULL;
  size_t n=0;
  size_t read_bytes=0;
  size_t start, end;

  sprintf(file, "/proc/%d/maps", getpid());
  FILE * mapfile  = fopen(file, "r");
  if (mapfile==NULL){
    perror("opening maps file failed\n");
    exit(-1);
  }

  int counter=0;
  while ((read_bytes = getline(&line, &n, mapfile)) != -1) {
    if (strstr(line, "hw3")!=NULL){
      ++counter;
      if (counter==3){
        sscanf(line, "%lx-%lx", &start, &end);
        global_mem.start=(size_t*)start;
        global_mem.end=(size_t*)end;
      }
    }
    else if (read_bytes > 0 && counter==3){
      //if the globals are larger than a page, it seems to create a separate mapping
      sscanf(line, "%lx-%lx", &start, &end);
      if ((void*)start==global_mem.end){
        global_mem.end=(size_t*)end;
      }
      break;
    }
  }
  fclose(mapfile);
}

size_t block_size(void *b){
  return (size_t)(*((size_t*)b+1) & ~0x7);
} // end block_size

size_t * next_block(size_t *b){
  return (void*)b + block_size(b);
}// end next_block

int block_marked(size_t *b){
  size_t *temp = (size_t*)b+1;
  if (((size_t)*temp & 0x4) == 4){
    return 1;
  }
  return 0;
}// end block_marked

void mark_block(size_t *b){
  size_t *temp = (size_t*)b+1;
  *temp = *temp | 4; // mark second bit as 1
  marked++;
} // end mark_block

int block_allocated(size_t *curr_block){
  size_t *nxt_block = next_block(curr_block); 

  if (nxt_block >= heap_mem.end){ 
    return 0;
  }

  int is_allocated = *((size_t*)nxt_block+1) & 0x1;

  if (is_allocated)
    allocated++;

  return is_allocated;

} // end is_allocated

void unmark_block(size_t *b){
  size_t *temp = (size_t*)b+1;
  *temp = *temp & ~0x4;
  unmarked++;
} // end unmark_block

int length(size_t * b){
  int size, len;

  size = block_size(b);
//  len = size / __WORDSIZE + 37; // size / wordsize = # words
    len = size / __WORDSIZE;



  return len;
}// end length

size_t * is_ptr(size_t *p){
  size_t *curr_block;
  size_t *nxt_block;
  size_t *heap_start = heap_mem.start;
  size_t *heap_end = heap_mem.end;

  if (p < heap_mem.start || p > heap_end) {
    return 0;
  }

  curr_block = heap_start-2;
  nxt_block = (void*)curr_block + block_size(curr_block);

  while(nxt_block < heap_end){
    if(p >= curr_block && p < nxt_block){
      return curr_block; // success!
    }
    else {
      curr_block = nxt_block;
      nxt_block = next_block(curr_block);
    }
  }

  return 0; // failed
} // end is_ptr

void mark(size_t * p){
  int i, len;
  size_t *b;

  if ((b = is_ptr(p)) == 0) return; 
  if (block_marked(b)) return;
  mark_block(b);

  len = length(b);

  for (i=0; i<len; i++) {
    mark((void*)b[i]);
    b++;
  }
}// mark 

void mark_phase(size_t *start, size_t *end){
  size_t *curr = start;

  while (curr < end){
    mark((void*)*curr);
    curr++;
  }

}// mark_phase

void traverse(size_t *start, size_t *end){
  for (size_t *ptr = start; ptr < end; ptr++){
    size_t *block = is_ptr((size_t *)*ptr);
    if (block && (block_marked(block) == 0)){
      mark_block(block);
      traverse(block, (void*)block + block_size(block));
    }
  }
}

void sweep_phase(){

  size_t *curr = heap_mem.start-2;
  size_t *end = heap_mem.end;
  size_t *next = curr;

  freed = 0;

  while ((void*)curr < sbrk(0)) {
    next = next_block(curr);
    if (block_marked(curr)){
      unmark_block(curr);
    }
    else if (block_allocated(curr)){
      free(curr+2);
      freed++;
    }
    curr = next;
  }

  return;
}

void init_gc() {
  char *a = "a";
  stack_mem.end = (size_t*)&a;
  init_global_range();
  heap_mem.start=malloc(512);
  printf("\n\nThe program may lag for a few seconds, I didn't optimize using the heap index.\n\n");
}

void gc() {
  char *a = "a";
  stack_mem.start = (size_t*)&a;
  heap_mem.end=sbrk(0);

  size_t *curr;
  size_t *start;
  size_t *end;

  /************************
   * MARK PHASE
   ************************/
  // traverse global
  start = global_mem.start;
  end = global_mem.end;
  //mark_phase(start, end);
  traverse(start, end);
  //  printf("Marked after global: %i\n", marked);
  marked = 0;

  // traverse stack
  start = stack_mem.start;
  end = stack_mem.end;
  //mark_phase(start, end);
  traverse(start, end);
  //printf("Marked after stack: %i\n", marked);
  marked = 0;

  /************************
   * SWEEP PHASE
   ************************/
  sweep_phase();
  //printf("Unmarked during sweep: %i\n", unmarked);
  //printf("Allocated blocks: %i\n", allocated);
  //printf("Blocks freed after sweep: %i\n", freed);
  unmarked = 0;
  allocated = 0;
}
