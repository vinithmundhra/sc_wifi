#include "wifi_tiwisl_spi.h"

#define DELAY_FIRST_WRITE   6000 // 50us delay for first write
#define DELAY_BOOT_TIME     100000000 // 1000ms for boot time
#define READ            3
#define DEASSERT_NCS    0x03 // while power enable (bit1) is high
#define ASSERT_NCS      0x02 // while power enable (bit1) is high
unsigned char spi_read_header[] = {READ, 0, 0, 0, 0};

static void delay(int value)
{
  timer t;
  unsigned time;
  t :> time;
  t when timerafter(time + value) :> void;
}

/*---------------------------------------------------------------------------
 spi_init
 ---------------------------------------------------------------------------*/
void wifi_tiwisl_spi_init(spi_master_interface &spi_if,
                          wifi_tiwisl_ctrl_ports_t &spi_tiwisl_ctrl)
{
  unsigned irq_val;

  // Deassert nCS
  spi_tiwisl_ctrl.p_cs_pwr <: 0x01;
  // Delay 1000ms - Vcc to Pwr_en time
  delay(DELAY_BOOT_TIME);
  // Enable Wi-Fi power
  spi_tiwisl_ctrl.p_cs_pwr <: 0x03;
  // Read the interrupt pin
  spi_tiwisl_ctrl.p_spi_irq :> irq_val;
  // this will take atleast 53ms to complete - see datasheet
  if (irq_val)
  {
    // Wait for IRQ to be low
    spi_tiwisl_ctrl.p_spi_irq when pinseq(0) :> void;
  }
  else
  {
    // Wait for IRQ to be High and then low
    spi_tiwisl_ctrl.p_spi_irq when pinseq(1) :> void;
    spi_tiwisl_ctrl.p_spi_irq when pinseq(0) :> void;
  }
  // Init SPI
  spi_master_init(spi_if, DEFAULT_SPI_CLOCK_DIV);
}

/*---------------------------------------------------------------------------
 spi_shutdown
 ---------------------------------------------------------------------------*/
void wifi_tiwisl_spi_shutdown(spi_master_interface &spi_if,
                              wifi_tiwisl_ctrl_ports_t &spi_tiwisl_ctrl)
{
  // Disable Wi-Fi power
  spi_tiwisl_ctrl.p_cs_pwr <: 0;
  // Init SPI
  spi_master_shutdown(spi_if);
}

/*---------------------------------------------------------------------------
 spi_master_read
 ---------------------------------------------------------------------------*/
void wifi_tiwisl_spi_read(spi_master_interface &spi_if,
                          wifi_tiwisl_ctrl_ports_t &spi_tiwisl_ctrl,
                          unsigned char buffer[],
                          unsigned short num_bytes,
                          int bypass_cmd)
{
  // Wait for IRQ to be low
  spi_tiwisl_ctrl.p_spi_irq when pinseq(0) :> void;
  // Assert CS
  spi_tiwisl_ctrl.p_cs_pwr <: ASSERT_NCS;
  if (!bypass_cmd)
  {
    // Issue the read command
    spi_master_out_buffer(spi_if, spi_read_header, SPI_READ_SIZE);
  }
  // Read the SPI data from device
  spi_master_in_buffer(spi_if, buffer, num_bytes);
}

/*---------------------------------------------------------------------------
 spi_deassert_cs
 ---------------------------------------------------------------------------*/
void wifi_tiwisl_spi_deassert_cs(wifi_tiwisl_ctrl_ports_t &spi_tiwisl_ctrl)
{
  // Deassert nCS
  spi_tiwisl_ctrl.p_cs_pwr <: DEASSERT_NCS;
  // wait for IRQ to be high
  spi_tiwisl_ctrl.p_spi_irq when pinseq(1) :> void;
}

/*---------------------------------------------------------------------------
 spi_master_first_write
 ---------------------------------------------------------------------------*/
void wifi_tiwisl_spi_first_write(spi_master_interface &spi_if,
                                 wifi_tiwisl_ctrl_ports_t &spi_tiwisl_ctrl,
                                 unsigned char buffer[],
                                 unsigned short num_bytes)
{
  // wait for IRQ to be low
  spi_tiwisl_ctrl.p_spi_irq when pinseq(0) :> void;
  // Assert nCS
  spi_tiwisl_ctrl.p_cs_pwr <: ASSERT_NCS;
  // Delay 50us
  delay(DELAY_FIRST_WRITE);
  // Transmit first 4 bytes
  spi_master_out_buffer(spi_if, buffer, 4);
  // Delay 50us
  delay(DELAY_FIRST_WRITE);
  // Transmit rest of the bytes
  // TODO: transmit whole buffer instead of byte-by-byte loop
  for(int i = 4; i < num_bytes; i++)
  {
    spi_master_out_byte(spi_if, buffer[i]);
  }
  // Deassert nCS
  spi_tiwisl_ctrl.p_cs_pwr <: DEASSERT_NCS;
  // wait for IRQ to be HI
  spi_tiwisl_ctrl.p_spi_irq when pinseq(1) :> void;
}

/*---------------------------------------------------------------------------
 spi_master_write
 ---------------------------------------------------------------------------*/
void wifi_tiwisl_spi_write(spi_master_interface &spi_if,
                           wifi_tiwisl_ctrl_ports_t &spi_tiwisl_ctrl,
                           unsigned char buffer[],
                           unsigned short num_bytes)
{
  // Assert nCS
  spi_tiwisl_ctrl.p_cs_pwr <: ASSERT_NCS;
  // wait for IRQ to be low
  spi_tiwisl_ctrl.p_spi_irq when pinseq(0) :> void;
  // Transmit SPI bytes to device
  spi_master_out_buffer(spi_if, buffer, num_bytes);
  // Deassert nCS
  spi_tiwisl_ctrl.p_cs_pwr <: DEASSERT_NCS;
  // wait for IRQ to be high
  spi_tiwisl_ctrl.p_spi_irq when pinseq(1) :> void;
}
