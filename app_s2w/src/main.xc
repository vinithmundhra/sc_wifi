#include <platform.h>
#include <xs1.h>
#include <xscope.h>
#include <print.h>
#include "wifi_tiwisl.h"
#include "multi_uart_rxtx.h"

#include "tcp_handler.h"
#include "uart_handler.h"
#include "tcp_uart_handler.h"

#define WIFI_CORE 0
#define UART_CORE 0

#define PORT_TX on tile[UART_CORE]: XS1_PORT_8B
#define PORT_RX on tile[UART_CORE]: XS1_PORT_8A

s_multi_uart_tx_ports uart_tx_ports = { PORT_TX };
s_multi_uart_rx_ports uart_rx_ports = { PORT_RX };

on tile[UART_CORE]: clock clk_uart_tx = XS1_CLKBLK_4;
on tile[UART_CORE]: in port p_uart_ref_ext_clk = XS1_PORT_1F; /* Define 1 bit external clock */
on tile[UART_CORE]: clock clk_uart_rx = XS1_CLKBLK_5;

on tile[0]: wifi_tiwisl_ports_t p_wifi = {
  XS1_PORT_4E, // nCS - Bit0, Power enable - Bit1
  XS1_PORT_1L, // nIRQ
  {
    XS1_CLKBLK_1,
    XS1_CLKBLK_2,
    XS1_PORT_1K, // MOSI
    XS1_PORT_1J, // CLK
    XS1_PORT_1I, // MISO
  }
};

void xscope_user_init(void) {
  xscope_register(0);
  xscope_config_io(XSCOPE_IO_BASIC);
}

int main(void)
{
  interface interface_wifi_rx i_wifi_rx;
  interface interface_wifi_tx i_wifi_tx;
  interface interface_uart_rx i_uart_rx;
  interface interface_uart_tx i_uart_tx;

  streaming chan c_uart_rx, c_uart_tx;

  par
  {
    on tile[UART_CORE]: run_multi_uart_rxtx(c_uart_tx,
                                            uart_tx_ports,
                                            c_uart_rx,
                                            uart_rx_ports,
                                            clk_uart_rx,
                                            p_uart_ref_ext_clk,
                                            clk_uart_tx);

    on tile[UART_CORE]: uart_handler(c_uart_rx, c_uart_tx, i_uart_rx, i_uart_tx);
    on tile[WIFI_CORE]: tcp_handler(p_wifi, i_wifi_rx, i_wifi_tx);
    on tile[WIFI_CORE]: tcp_uart_handler(i_wifi_rx, i_wifi_tx, i_uart_rx, i_uart_tx);

  }
  return 0;
}
