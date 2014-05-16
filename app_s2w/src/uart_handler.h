#ifndef _uart_handler_h_
#define _uart_handler_h_

#include "tcp_handler.h"

typedef interface interface_uart_rx {
  [[notification]] slave void data_ready();
  [[clears_notification]] unsigned int data_get(unsigned char &data);
}interface_uart_rx;

typedef interface interface_uart_tx {
  unsigned int data_send(unsigned char &data);
}interface_uart_tx;

void uart_handler(streaming chanend c_uart_rx,
                  streaming chanend c_uart_tx,
                  server interface interface_uart_rx i_uart_rx,
                  server interface interface_uart_tx i_uart_tx);

#endif // _uart_handler_h_
