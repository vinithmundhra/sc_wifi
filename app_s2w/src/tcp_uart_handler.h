#ifndef _tcp_uart_handler_h_
#define _tcp_uart_handler_h_

#include "tcp_handler.h"
#include "uart_handler.h"

void tcp_uart_handler(client interface interface_wifi_rx i_wifi_rx,
                      client interface interface_wifi_tx i_wifi_tx,
                      client interface interface_uart_rx i_uart_rx,
                      client interface interface_uart_tx i_uart_tx);

#endif //_tcp_uart_handler_h_
