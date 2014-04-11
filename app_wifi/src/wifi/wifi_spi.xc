#include "wifi_spi.h"
#include <timer.h>

#define DELAY_FIRST_WRITE   6000 // 50us delay for first write
#define DELAY_BOOT_TIME     100000000 // 1000ms for boot time
#define READ            3
#define DEASSERT_NCS    0x03 // while power enable (bit1) is high
#define ASSERT_NCS      0x02 // while power enable (bit1) is high

unsigned char spi_read_header[] = {READ, 0, 0, 0, 0};

/*---------------------------------------------------------------------------
 spi_deassert_cs
 ---------------------------------------------------------------------------*/
static void spi_deassert_cs(wifi_tiwisl_ports_t &p_wifi)
{
  // Deassert nCS
  p_wifi.p_cs_pwr <: DEASSERT_NCS;
  // wait for IRQ to be high
  p_wifi.p_spi_irq when pinseq(1) :> void;
}

/*---------------------------------------------------------------------------
 spi_init
 ---------------------------------------------------------------------------*/
void spi_init(wifi_tiwisl_ports_t &p_wifi)
{
  unsigned irq_val;

  // Deassert nCS
  p_wifi.p_cs_pwr <: 0x01;
  // Delay 1000ms - Vcc to Pwr_en time
  delay_seconds(1);
  // Enable Wi-Fi power
  p_wifi.p_cs_pwr <: 0x03;
  // Read the interrupt pin
  p_wifi.p_spi_irq :> irq_val;
  // this will take atleast 53ms to complete - see datasheet
  if (irq_val)
  {
    // Wait for IRQ to be low
    p_wifi.p_spi_irq when pinseq(0) :> void;
  }
  else
  {
    // Wait for IRQ to be High and then low
    p_wifi.p_spi_irq when pinseq(1) :> void;
    p_wifi.p_spi_irq when pinseq(0) :> void;
  }
  // Init SPI
  spi_master_init(p_wifi.p_spi, DEFAULT_SPI_CLOCK_DIV);
}

/*---------------------------------------------------------------------------
 spi_shutdown
 ---------------------------------------------------------------------------*/
void spi_off(wifi_tiwisl_ports_t &p_wifi)
{
  // Disable Wi-Fi power
  p_wifi.p_cs_pwr <: 0;
  // Init SPI
  spi_master_shutdown(p_wifi.p_spi);
}

/*---------------------------------------------------------------------------
 spi_read
 ---------------------------------------------------------------------------*/
unsigned short spi_read(wifi_tiwisl_ports_t &p_wifi, unsigned char buffer[])
{
  unsigned short len;
  // Wait for IRQ to be low
  p_wifi.p_spi_irq when pinseq(0) :> void;
  // Assert CS
  p_wifi.p_cs_pwr <: ASSERT_NCS;
  // Issue the read command
  spi_master_out_buffer(p_wifi.p_spi, spi_read_header, SPI_READ_SIZE);
  // Read the SPI data from device
  spi_master_in_buffer(p_wifi.p_spi, buffer, 2);
  // Find the length of data that will follow
  len = (unsigned short)((unsigned short) (buffer[0] << 8) + (unsigned short) (buffer[1]));
  // Wait for IRQ to be low
  p_wifi.p_spi_irq when pinseq(0) :> void;
  // Assert CS
  p_wifi.p_cs_pwr <: ASSERT_NCS;
  // Read the SPI data from device
  spi_master_in_buffer(p_wifi.p_spi, buffer, len);
  // Deassert nCS and wait for nIRQ deassertion
  spi_deassert_cs(p_wifi);
  // return number of bytes read
  return len;
}

/*---------------------------------------------------------------------------
 spi_master_first_write
 ---------------------------------------------------------------------------*/
void spi_first_write(wifi_tiwisl_ports_t &p_wifi,
                     unsigned char buffer[],
                     unsigned short num_bytes)
{
  // wait for IRQ to be low
  p_wifi.p_spi_irq when pinseq(0) :> void;
  // Assert nCS
  p_wifi.p_cs_pwr <: ASSERT_NCS;
  // Delay 50us
  delay_microseconds(50);
  // Transmit first 4 bytes
  spi_master_out_buffer(p_wifi.p_spi, buffer, 4);
  // Delay 50us
  delay_microseconds(50);
  // Transmit rest of the bytes
  for(int i = 4; i < num_bytes; i++)
  {
    spi_master_out_byte(p_wifi.p_spi, buffer[i]);
  }
  // Deassert nCS
  p_wifi.p_cs_pwr <: DEASSERT_NCS;
  // wait for IRQ to be HI
  p_wifi.p_spi_irq when pinseq(1) :> void;
}

/*---------------------------------------------------------------------------
 spi_master_write
 ---------------------------------------------------------------------------*/
void spi_write(wifi_tiwisl_ports_t &p_wifi,
               unsigned char buffer[],
               unsigned short num_bytes)
{
  // Assert nCS
  p_wifi.p_cs_pwr <: ASSERT_NCS;
  // wait for IRQ to be low
  p_wifi.p_spi_irq when pinseq(0) :> void;
  // Transmit SPI bytes to device
  spi_master_out_buffer(p_wifi.p_spi, buffer, num_bytes);
  // Deassert nCS
  p_wifi.p_cs_pwr <: DEASSERT_NCS;
  // wait for IRQ to be high
  p_wifi.p_spi_irq when pinseq(1) :> void;
}
