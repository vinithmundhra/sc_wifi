#ifndef _WIFI_TIWISL_SPI_H_
#define _WIFI_TIWISL_SPI_H_

#include "wifi_tiwisl_server.h"

#define SPI_READ_SIZE 3

/*==========================================================================*/
/**
 *  Initialize SPI ports, enable wifi power, CS, IRQ and SPI master mode
 *
 *  \param spi_if           The SPI interface: MOSI, MISO, CLK
 *  \param spi_tiwisl_ctrl  Other i/f lines: nCS, nIRQ, PWR_ENABLE
 *
 **/
void wifi_tiwisl_spi_init(spi_master_interface &spi_if,
                          wifi_tiwisl_ctrl_ports_t &spi_tiwisl_ctrl);

/*==========================================================================*/
/**
 *  Stops SPI. Wifi power off.
 *
 *  \param spi_if           The SPI interface: MOSI, MISO, CLK
 *  \param spi_tiwisl_ctrl  Other i/f lines: nCS, nIRQ, PWR_ENABLE
 *
 **/
void wifi_tiwisl_spi_shutdown(spi_master_interface &spi_if,
                              wifi_tiwisl_ctrl_ports_t &spi_tiwisl_ctrl);

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
void wifi_tiwisl_spi_read(spi_master_interface &spi_if,
                          wifi_tiwisl_ctrl_ports_t &spi_tiwisl_ctrl,
                          unsigned char buffer[],
                          unsigned short num_bytes,
                          int bypass_cmd);

/*==========================================================================*/
/**
 *  Deassert nCS and wait for nIRQ deassert
 *
 *  \param spi_tiwisl_ctrl  Other i/f lines: nCS, nIRQ, PWR_ENABLE
 *
 **/
void wifi_tiwisl_spi_deassert_cs(wifi_tiwisl_ctrl_ports_t &spi_tiwisl_ctrl);

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
void wifi_tiwisl_spi_first_write(spi_master_interface &spi_if,
                                 wifi_tiwisl_ctrl_ports_t &spi_tiwisl_ctrl,
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
void wifi_tiwisl_spi_write(spi_master_interface &spi_if,
                           wifi_tiwisl_ctrl_ports_t &spi_tiwisl_ctrl,
                           unsigned char buffer[],
                           unsigned short num_bytes);

#endif // _WIFI_TIWISL_SPI_H_
