#include "tcp_handler.h"
#include <print.h>
#include <string.h>

#define BUF_SIZE 500
#define MAX_CLIENTS 1
#define BIND_PORT 46

static int http_server_socket;
static unsigned char data[BUF_SIZE];
static int clients[MAX_CLIENTS];

wifi_ap_config_t wifi_ap_config = {"ssid", "key", TIWISL_SEC_TYPE_WPA2};

static int get_first_free_socket()
{
  int i;
  for(i = 0; i < MAX_CLIENTS; i++)
    if (clients[i] == -1) break;
  if (i >= MAX_CLIENTS) return -1;
  return i;
}


static int wifi_server_init(wifi_tiwisl_ports_t &p)
{
  http_server_socket = wifi_socket(p, SOCK_STREAM, WIFI_PROTOCOL_TCP);
  if(http_server_socket == -1)
  {
    wifi_stop(p);
    return -1;
  }
  wifi_socket_bind(p, BIND_PORT);
  wifi_socket_listen(p);
  return 0;
}


void tcp_handler(wifi_tiwisl_ports_t &p_wifi,
                 server interface interface_wifi_rx i_wifi_rx,
                 server interface interface_wifi_tx i_wifi_tx)
{
  unsigned char wifi_data_rx[BUF_SIZE];
  unsigned int rx_fifo_read = 0, rx_fifo_write = 0, rx_depth = 0;

  int cr, data_len;

  printstrln("Welcome to simple web server demo.");
  wifi_start(p_wifi);

  printstr("Connecting to "); printstrln(wifi_ap_config.ssid);
  wifi_connect(p_wifi, wifi_ap_config);

  wifi_server_init(p_wifi);

  for(int i = 0; i < MAX_CLIENTS; i++) clients[i] = -1;


  while(1)
  {
    cr = wifi_socket_accept(p_wifi);
    if(cr == -1 || cr == -2)
    {
    }
    else if(cr == -57)
    {
      wifi_socket_close(p_wifi, http_server_socket);
      wifi_server_init(p_wifi);
    }
    else
    {
      int free_id = get_first_free_socket();
      if (free_id == -1)
      {
      }
      else
      {
        clients[free_id] = cr;
      }
    }

    for(int i = 0; i < MAX_CLIENTS; i++)
    {
      if(clients[i] == -1) continue;
      data_len = wifi_recv(p_wifi, clients[i], data);

      if (data_len > 0)
      {
        for(int i = 0; i < data_len; i++)
        {
          wifi_data_rx[rx_fifo_write] = data[i];
          rx_fifo_write = (rx_fifo_write + 1) % BUF_SIZE;
          rx_depth++;
          i_wifi_rx.data_ready();
        }
      }
      else if(data_len == -57)
      {
        // close
        wifi_socket_close(p_wifi, clients[i]);
        clients[i] = -1;
      }

      select
      {
        /*==================================================================*/
        /* UART requesting data from TCP buffer */
        /*==================================================================*/
        case i_wifi_rx.data_get(unsigned char &data) -> unsigned int err:
        {
          if (rx_depth <= 0)
          {
            // handle buffer underflow
            err = -1;
            continue;
          }

          data = wifi_data_rx[rx_fifo_read];
          rx_fifo_read = (rx_fifo_read + 1) % BUF_SIZE;
          rx_depth--;
          if(rx_depth)
          {
            i_wifi_rx.data_ready();
            err = rx_depth;
          }
          else
          {
            err = 0;
          }
          break;
        }//case i_wifi_rx.get_data(unsigned char &data) -> unsigned int err:

        /*==================================================================*/
        /* UART transmitting data to TCP */
        /*==================================================================*/
        case i_wifi_tx.data_send(unsigned char &data) -> unsigned int err:
        {
          unsigned char data_arr[1];
          data_arr[0] = data;
          err = wifi_send(p_wifi, clients[i], data_arr, 1);
          break;
        }//case i_uart_tx.data_send(unsigned char &data) -> unsigned int err:


      }//select

    }//for
  }//while(1)
}
