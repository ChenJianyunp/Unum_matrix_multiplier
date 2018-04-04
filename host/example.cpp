#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <time.h>;
#include <sys/time.h>
using namespace std;

// libcxl
extern "C" {
  #include "libcxl.h"
}

#define APP_NAME              "example"

#define CACHELINE_BYTES       128                   // 0x80
#define MMIO_ADDR             0x3fffff8             // 0x3fffff8 >> 2 = 0xfffffe

//#ifdef  SIM
  #define DEVICE              "/dev/cxl/afu0.0d"
//#else
//  #define DEVICE              "/dev/cxl/afu1.0d"
//#endif

struct wed {
  __u8   volatile status;      // 7    downto 0
  __u8   wed00_a;              // 15   downto 8
  __u16  wed00_b;              // 31   downto 16
  __u32  size;                 // 63   downto 32
  __u64  *source;              // 127  downto 64
  __u64  *destination;         // 191  downto 128
  __u64  wed03;                // 255  downto 192
  __u64  wed04;                // 319  downto 256
  __u64  wed05;                // 383  downto 320
  __u64  wed06;                // 447  downto 384
  __u64  wed07;                // 511  downto 448
  __u64  wed08;                // 575  downto 512
  __u64  wed09;                // 639  downto 576
  __u64  wed10;                // 703  downto 640
  __u64  wed11;                // 767  downto 704
  __u64  wed12;                // 831  downto 768
  __u64  wed13;                // 895  downto 832
  __u64  wed14;                // 959  downto 896
  __u64  wed15;                // 1023 downto 960
};

int main (int argc, char *argv[]) {

  __u32 copy_size;
  unsigned int row,row2,column,num_result;
  struct timeval tv1,tv2,tv3,tv4,tv5;
	struct timezone tz;
  row=128;
  column=128;
  row2=128;
  num_result=row*row2*4;
  
  // parse input arguments
//  if (argc != 2) {
//    cout << "Usage: " << APP_NAME << " <number_of_cachelines>\n";
//    return -1;
//  } else {
//    copy_size = strtoul(argv[1], NULL, 0);
//  }

  copy_size=(__u32)(row*column/32+row2*column/32);
  cout<<"copy_size="<<copy_size<<endl;

  __u64 *source = NULL;
  __u64 *source2 = NULL;
  __u64 *destination = NULL;
  __u64 *destination2 = NULL;

  // allocate memory
  if (posix_memalign ((void **) &(source), CACHELINE_BYTES, CACHELINE_BYTES * copy_size)) {
    perror ("posix_memalign");
    return -1;
  }
  if (posix_memalign ((void **) &(source2), CACHELINE_BYTES, CACHELINE_BYTES * copy_size)) {
    perror ("posix_memalign");
    return -1;
  }
  if (posix_memalign ((void **) &(destination), CACHELINE_BYTES,num_result )) {
    perror ("posix_memalign");
    return -1;
  }
  if (posix_memalign ((void **) &(destination2), CACHELINE_BYTES,num_result )) {
    perror ("posix_memalign");
    return -1;
  }

  __u64 a[128]={0x4000000040000000,0x4800000048000000,0x4c0000004c000000,0x5000000050000000, //1 2 3 4 
			   0x5200000052000000,0x5400000054000000,0x5600000056000000,0x5800000058000000, //5 6 7 8 
			   0x4000000040000000,0x4800000048000000,0x4c0000004c000000,0x5000000050000000,
			   0x5200000052000000,0x5400000054000000,0x5600000056000000,0x5800000058000000,
			   0x4000000040000000,0x4800000048000000,0x4c0000004c000000,0x5000000050000000,
			   0x5200000052000000,0x5400000054000000,0x5600000056000000,0x5800000058000000,
			   0x4000000040000000,0x4800000048000000,0x4c0000004c000000,0x5000000050000000,
			   0x5200000052000000,0x5400000054000000,0x5600000056000000,0x5800000058000000,
			   0x4000000040000000,0x4800000048000000,0x4c0000004c000000,0x5000000050000000,
			   0x5200000052000000,0x5400000054000000,0x5600000056000000,0x5800000058000000,
			   0x4000000040000000,0x4800000048000000,0x4c0000004c000000,0x5000000050000000,
			   0x5200000052000000,0x5400000054000000,0x5600000056000000,0x5800000058000000,
			   0x4000000040000000,0x4800000048000000,0x4c0000004c000000,0x5000000050000000,
			   0x5200000052000000,0x5400000054000000,0x5600000056000000,0x5800000058000000,
			   0x4000000040000000,0x4800000048000000,0x4c0000004c000000,0x5000000050000000,
			   0x5200000052000000,0x5400000054000000,0x5600000056000000,0x5800000058000000,
         0x4000000040000000,0x4800000048000000,0x4c0000004c000000,0x5000000050000000, //1 2 3 4 
			   0x5200000052000000,0x5400000054000000,0x5600000056000000,0x5800000058000000, //5 6 7 8 
			   0x4000000040000000,0x4800000048000000,0x4c0000004c000000,0x5000000050000000,
			   0x5200000052000000,0x5400000054000000,0x5600000056000000,0x5800000058000000,
			   0x4000000040000000,0x4800000048000000,0x4c0000004c000000,0x5000000050000000,
			   0x5200000052000000,0x5400000054000000,0x5600000056000000,0x5800000058000000,
			   0x4000000040000000,0x4800000048000000,0x4c0000004c000000,0x5000000050000000,
			   0x5200000052000000,0x5400000054000000,0x5600000056000000,0x5800000058000000,
			   0x4000000040000000,0x4800000048000000,0x4c0000004c000000,0x5000000050000000,
			   0x5200000052000000,0x5400000054000000,0x5600000056000000,0x5800000058000000,
			   0x4000000040000000,0x4800000048000000,0x4c0000004c000000,0x5000000050000000,
			   0x5200000052000000,0x5400000054000000,0x5600000056000000,0x5800000058000000,
			   0x4000000040000000,0x4800000048000000,0x4c0000004c000000,0x5000000050000000,
			   0x5200000052000000,0x5400000054000000,0x5600000056000000,0x5800000058000000,
			   0x4000000040000000,0x4800000048000000,0x4c0000004c000000,0x5000000050000000,
			   0x5200000052000000,0x5400000054000000,0x5600000056000000,0x5800000058000000		
  }; 

//    cout <<"content is: ";
  // initialize
  //input matrix1
  for(unsigned i=row2; i <(row+row2); i++) {
    for(unsigned j=0; j < column/2; j++){
    *(source+j+i*column/2) =  (__u64)0x4000000040000000;
//	*(source+j+i*column/2) =  (__u64) a[i-row2];
//    *(source+j+i*column/2) =   (__u64)0x0000000000000000;  ///0
   *(source+j+i*column/2) = (__u64) a[i-row2];
   *(source2+j+i*column/2) = (__u64) a[i-row2];
    }
  }
//  *(source+row2*column/2)=(__u64)0x8000000040000000;
//    *(source+row2*column/2)=(__u64)0x7fef46a540000000;
//    *(source+row2*column/2+1)=(__u64)0x8010b95b40000000;

for(unsigned i=0; i <row2; i++) {
   for(unsigned j=0; j < column/2; j++){
        *(source+j+i*column/2) =   (__u64)0x4000000040000000;
//        *(source+j+i*column/2) =   (__u64)0x3199999a3199999a;  ///0.3
//        *(source+j+i*column/2) =   (__u64)0x0000000000000000;  ///0
//          *(source+j+i*column/2) =   (__u64)0x4266666642666666;  ///1.3
 //       *(source+j+i*column/2) =   (__u64)a[i];
        *(source2+j+i*column/2) =  (__u64)0x4000000040000000;
   }
}   


  // setup wed
  struct wed *wed0 = NULL;
  if (posix_memalign ((void **) &(wed0), CACHELINE_BYTES, sizeof(struct wed))) {
    perror ("posix_memalign");
    return -1;
  }

  wed0->status = 0;
 // wed0->size = copy_size; 
  //wed0->size =0x00000080;
  wed0->size =(__u64)row*row2/32;  ///each cacheline contains 32 numbers
//  wed0->size=(__u64)1;
  wed0->source = source;
  wed0->destination = destination;
  wed0->wed03=((__u64)column<<32)|((__u64)row);
  wed0->wed04=(__u64)(row*column+row2*column)/32;  
  wed0->wed05=(__u64)row2;
  wed0->wed06=0x0000000000000001;
  wed0->wed07=(__u64)source2;
  wed0->wed08=(__u64)destination2;
// open afu device
  struct cxl_afu_h *afu = cxl_afu_open_dev ((char*) (DEVICE));
  if (!afu) {
    perror ("cxl_afu_open_dev");
    return -1;
  }

  // attach afu and pass wed address
  if (cxl_afu_attach (afu, (__u64) wed0) < 0) {
    perror ("cxl_afu_attach");
    return -1;
  }

  printf("AFU has started.\n");
 gettimeofday(&tv1,&tz);
  // map mmio
  if ((cxl_mmio_map (afu, CXL_MMIO_BIG_ENDIAN)) < 0) {
    perror("cxl_mmio_map");
    return -1;
  }

  uint64_t rc;

  // wait for afu
  // while(rc<96){ 
  while (!wed0->status) {
//  for (int i=0;i<1;i++){
    cxl_mmio_read64(afu, MMIO_ADDR, &rc);
    printf("Response counter: %lu\n", rc);
//  }
  }

  gettimeofday(&tv2,&tz);
  printf("T2-1:%ld\n",(tv2.tv_sec-tv1.tv_sec)*1000000L+(tv2.tv_usec-tv1.tv_usec));
  printf("AFU is done.\n");

  printf("\nmatrix2 is:\n");
  for(unsigned i=0; i < 16*copy_size; i++) {
    if(i==row2*column/2){
		printf("\nmatrix1 is:\n");
	}
	cout <<hex<<(__u64)(*(source+i))<<" ";
  }  

  printf("\nthe result matrix is:\n");
  for(unsigned i=0;i<row;i++){
    for(unsigned j=0;j<row2/2;j++){
      printf("%08llx ",*(destination+(i*row/2)+j));
    }
    printf("\n");
  }

  printf("\nthe result matrix2 is:\n");
  for(unsigned i=0;i<row;i++){
    for(unsigned j=0;j<row2/2;j++){
      printf("%08llx ",*(destination2+(i*row/2)+j));
    }
    printf("\n");
  }



  cxl_mmio_unmap (afu);
  cxl_afu_free (afu);

  return 0;

}
