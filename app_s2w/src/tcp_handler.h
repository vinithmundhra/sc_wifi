#ifndef _tcp_handler_h_
#define _tcp_handler_h_

#include "wifi_tiwisl.h"
#include "uart_handler.h"

typedef interface interface_wifi_rx {
  [[notification]] slave void data_ready();
  [[clears_notification]] unsigned int data_get(unsigned char &data);
}interface_wifi_rx;

typedef interface interface_wifi_tx {
  unsigned int data_send(unsigned char &data);
}interface_wifi_tx;

void tcp_handler(wifi_tiwisl_ports_t &p_wifi,
                 server interface interface_wifi_rx i_wifi_rx,
                 server interface interface_wifi_tx i_wifi_tx);

#endif // _tcp_handler_h_
