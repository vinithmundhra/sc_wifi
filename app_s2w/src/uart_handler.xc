#include "uart_handler.h"
#include "multi_uart_rx.h"
#include "multi_uart_tx.h"

#define BUF_SIZE 500

void uart_handler(streaming chanend c_uart_rx,
                  streaming chanend c_uart_tx,
                  server interface interface_uart_rx i_uart_rx,
                  server interface interface_uart_tx i_uart_tx)
{
  unsigned char uart_data_rx[BUF_SIZE];
  unsigned int rx_fifo_read = 0, rx_fifo_write = 0, rx_depth = 0;

  while(1)
  {
    select
    {

      /*==================================================================*/
      /* Get data from UART Module*/
      /*==================================================================*/
      case c_uart_rx :> char channel_id:
      {
        if(rx_depth >= BUF_SIZE) continue; //buffer overflow

        unsigned uart_char;
        uart_char = (unsigned) uart_rx_grab_char(channel_id);
        if(uart_rx_validate_char(channel_id, uart_char) == 0)
        {
          uart_data_rx[rx_fifo_write] = uart_char;
          rx_fifo_write = (rx_fifo_write + 1) % BUF_SIZE;
          rx_depth++;
          i_uart_rx.data_ready();
        }
        break;
      }//case c_uart_rx :> char channel_id

      /*==================================================================*/
      /* TCP requesting data from UART buffer */
      /*==================================================================*/
      case i_uart_rx.data_get(unsigned char &data) -> unsigned int err:
      {
        if (rx_depth <= 0)
        {
          // handle buffer underflow
          err = -1;
          continue;
        }

        data = uart_data_rx[rx_fifo_read];
        rx_fifo_read = (rx_fifo_read + 1) % BUF_SIZE;
        rx_depth--;
        if(rx_depth)
        {
          i_uart_rx.data_ready();
          err = rx_depth;
        }
        else
        {
          err = 0;
        }
        break;
      }//case i_uart_rx.get_data(unsigned char &data) -> unsigned int err:

      /*==================================================================*/
      /* TCP transmitting data to UART */
      /*==================================================================*/
      case i_uart_tx.data_send(unsigned char &data) -> unsigned int err:
      {
        err = uart_tx_put_char(0, data);
        break;
      }//case i_uart_tx.data_send(unsigned char &data) -> unsigned int err:



    }//select
  }//while(1)
}
