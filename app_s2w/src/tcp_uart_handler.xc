#include "tcp_uart_handler.h"

void tcp_uart_handler(client interface interface_wifi_rx i_wifi_rx,
                      client interface interface_wifi_tx i_wifi_tx,
                      client interface interface_uart_rx i_uart_rx,
                      client interface interface_uart_tx i_uart_tx)
{
  while(1)
  {
    select
    {
      case i_wifi_rx.data_ready():
      {
        unsigned char data;
        int wifi_err, uart_err;
        wifi_err = i_wifi_rx.data_get(data);
        uart_err = i_uart_tx.data_send(data);
        break;
      }//case i_wifi_rx.data_ready():

      case i_uart_rx.data_ready():
      {
        unsigned char data;
        int wifi_err, uart_err;
        uart_err = i_uart_rx.data_get(data);
        wifi_err = i_wifi_tx.data_send(data);
        break;
      }//case i_uart_rx.data_ready():

    }//select
  }//while(1)
}
