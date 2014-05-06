#ifndef _wifi_spi_h_
#define _wifi_spi_h_

#include "wifi_ports.h"

#define SPI_READ_SIZE 3

/*==========================================================================*/
/**
 *  Initialize SPI ports, enable wifi power, CS, IRQ and SPI master mode
 *
 *  \param spi_if           The SPI interface: MOSI, MISO, CLK
 *  \param spi_tiwisl_ctrl  Other i/f lines: nCS, nIRQ, PWR_ENABLE
 *
 **/
void spi_init(REFERENCE_PARAM(wifi_tiwisl_ports_t, p));

/*==========================================================================*/
/**
 *  Stops SPI. Wifi power off.
 *
 *  \param spi_if           The SPI interface: MOSI, MISO, CLK
 *  \param spi_tiwisl_ctrl  Other i/f lines: nCS, nIRQ, PWR_ENABLE
 *
 **/
void spi_off(REFERENCE_PARAM(wifi_tiwisl_ports_t, p));

/*==========================================================================*/
/**
 *  Receive specified number of bytes on the SPI i/f.
 *  Most significant bit first order (Big endian byte order).
 *
 *  \param spi_if           The SPI interface: MOSI, MISO, CLK
 *  \param spi_tiwisl_ctrl  Other i/f lines: nCS, nIRQ, PWR_ENABLE
 *  \param buffer           The array the received data will be written to
 *  \param num_bytes        Number of bytes to receive
 *  \param bypass_cmd       Jump the first read to get read length
 *
 **/
unsigned short spi_read(REFERENCE_PARAM(wifi_tiwisl_ports_t, p), unsigned char buffer[]);

/*==========================================================================*/
/**
 *  SPI Write for the first time. This Write operation has 50 us time delays
 *  as specified (after asserting nCS and after the 4th byte sent).
 *
 *  \param spi_if           The SPI interface: MOSI, MISO, CLK
 *  \param spi_tiwisl_ctrl  Other i/f lines: nCS, nIRQ, PWR_ENABLE
 *  \param buffer           The array of data to transmit
 *  \param num_bytes        Number of bytes to transmit
 *
 **/
void spi_first_write(REFERENCE_PARAM(wifi_tiwisl_ports_t, p),
                     unsigned char buffer[],
                     unsigned short num_bytes);

/*==========================================================================*/
/**
 *  Normal SPI Write. Transmit specified number of bytes.
 *
 *  \param spi_if           The SPI interface: MOSI, MISO, CLK
 *  \param spi_tiwisl_ctrl  Other i/f lines: nCS, nIRQ, PWR_ENABLE
 *  \param buffer           The array of data to transmit
 *  \param num_bytes        Number of bytes to transmit
 *
 **/
void spi_write(REFERENCE_PARAM(wifi_tiwisl_ports_t, p),
               unsigned char buffer[],
               unsigned short num_bytes);

#endif // _wifi_spi_h_
