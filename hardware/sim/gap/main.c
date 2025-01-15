#include <stdint.h>

#define MIP_MEIP (1 << 11) // External interrupt pending
#define MIP_MTIP (1 << 7)  // Timer interrupt pending
#define MIP 0x344

volatile unsigned int *WDT_addr = (int *) 0x10010000;
volatile unsigned int *dma_addr_boot = (int *) 0x10020000;




void timer_interrupt_handler(void) {
  asm("csrsi mstatus, 0x0"); // MIE of mstatus
  WDT_addr[0x40] = 0; // WDT_en
  asm("j _start");
}

void external_interrupt_handler(void) {
//	volatile unsigned int *dma_addr_boot = (int *) 0x10020000;
	asm("csrsi mstatus, 0x0"); // MIE of mstatus
//	dma_addr_boot[0x40] = 0; // disable DMA
}

void trap_handler(void) {
    uint32_t mip;
    asm volatile("csrr %0, %1" : "=r"(mip) : "i"(MIP));
	
    if ((mip & MIP_MTIP) >> 7) {
        timer_interrupt_handler();
    }

    if ((mip & MIP_MEIP) >> 11) {
        external_interrupt_handler();
    }
}


int main(void) {
  
  extern unsigned int _test_start;
  /* EPU data address */
  // input data address
  extern unsigned int __in8_start;
  extern unsigned int __in8_end;
  extern unsigned int __in8_data_in_dram_start;
  // w2 data address
  extern unsigned int __w8_start;
  extern unsigned int __w8_end;
  extern unsigned int __w8_data_in_dram_start;
  // bias data address
  extern unsigned int __bias_start;
  extern unsigned int __bias_end;
  extern unsigned int __bias_data_in_dram_start;
  // param data address 
  extern unsigned int __param_start;
  extern unsigned int __param_end;
  extern unsigned int __param_data_in_dram_start;
  // output data address 
  extern unsigned int __out8_start;
  extern unsigned int __out8_end;
  extern unsigned int __out8_data_in_dram_start;
  
  extern unsigned int __data_start;
  
  volatile unsigned int *dma_addr_boot = (int *) 0x10020000;
  //EPU control
  volatile unsigned int *EPU_start = (int *) 0x00060000;
  volatile unsigned int *EPU_done = (int *) 0x00060004;
  // Enable Local Interrupt
  /*------------------------weight ------------------------*/
  asm("li t6, 0x800");
  asm("csrw mie, t6"); // MEIE of mie 
  //DMA source addr
  dma_addr_boot[0x80] = &__w8_data_in_dram_start;
  //DMA dest addr
  dma_addr_boot[0xC0] = &__w8_start;
  //DMA len
  dma_addr_boot[0x100]= & __w8_end - &__w8_start + 1;
  // Enable DMA Controller
  dma_addr_boot[0x40] = 1; // Enable DMA
  asm("wfi");
  // disable DMA Controller
  dma_addr_boot[0x40] = 0; // disable DMA
  /*------------------------input image ------------------------*/
  asm("li t6, 0x800");
  asm("csrw mie, t6"); // MEIE of mie 
  //DMA source addr
  dma_addr_boot[0x80] = &__in8_data_in_dram_start;
  //DMA dest addr
  dma_addr_boot[0xC0] = &__in8_start;
  //DMA len
  dma_addr_boot[0x100]= & __in8_end - &__in8_start + 1;
  // Enable DMA Controller
  dma_addr_boot[0x40] = 1; // Enable DMA
  asm("wfi");
  // disable DMA Controller
  dma_addr_boot[0x40] = 0; // disable DMA

  /*------------------------input bais ------------------------*/
  asm("li t6, 0x800");
  asm("csrw mie, t6"); // MEIE of mie 
  //DMA source addr
  dma_addr_boot[0x80] = &__bias_data_in_dram_start;
  //DMA dest addr
  dma_addr_boot[0xC0] = &__bias_start;
  //DMA len
  dma_addr_boot[0x100]= & __bias_end - &__bias_start + 1;
  // Enable DMA Controller
  dma_addr_boot[0x40] = 1; // Enable DMA
  asm("wfi");
  // disable DMA Controller
  dma_addr_boot[0x40] = 0; // disable DMA
//  asm("li t6, 0x000");
//  asm("csrw mie, t6"); // MEIE of mie
  
  //EPU_finish[0] = 1;
  /*------------------------ conv0 + pooling ------------------------*/
  //weight_0
  // bias_0

  /*------------------------ conv1 + pooling ------------------------*/
  //weight_1

  // bias_1


  /*------------------------ conv2 + pooling ------------------------*/
  //weight_2

  // bias_2

  /*------------------------ conv3 + pooling ------------------------*/
  //weight_3

  // bias_3


  /*------------------------ fully connected 1 ------------------------*/
  //weight_3

  // bias_3


  /*------------------------ fully connected 2 ------------------------*/
  //weight_3

  // bias_3
  EPU_start[0] = 1;
  asm("wfi");
  EPU_start[0] = 0;


  /*------------------------ Sram to Dram ------------------------*/ 
  volatile unsigned int *__inference_result = (int *) 0x00050000;
  volatile unsigned int *__DRAM_inference_result = (int *) 0x20100000;
  //DMA src addr
  dma_addr_boot[0x80] = &__inference_result;
  //DMA dest addr
  dma_addr_boot[0xC0] = &__DRAM_inference_result;
  //DMA len
  dma_addr_boot[0x100]= 5;
  // Enable DMA Controller
  dma_addr_boot[0x40] = 1; // Enable DMA
  asm("wfi");
  dma_addr_boot[0x40] = 0; // disable DMA

  return 0;
  
}
