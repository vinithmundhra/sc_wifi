#include "webserver.h"
#include <print.h>
#include <string.h>

#define BUF_SIZE 1000
#define MAX_CLIENTS 5
#define BIND_PORT 80

static wifi_state_t wifi_state;
static int http_server_socket, dummy;
static unsigned char data[BUF_SIZE];
static int clients[MAX_CLIENTS];


#if 0
static void debug_print(unsigned char msg[], int val)
{
  printstr(msg); printintln(val);
}
#endif

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
  while(wifi_socket_create(p, SOCK_STREAM, WIFI_PROTOCOL_TCP, http_server_socket) != WIFI_OK) {}
  if(http_server_socket == -1)
  {
    wifi_stop(p);
    return -1;
  }
  while(wifi_socket_bind(p, BIND_PORT, dummy) != WIFI_OK) {}
  while(wifi_socket_listen(p, dummy) != WIFI_OK) {}
  return 0;
}

void webserver(wifi_tiwisl_ports_t &p_wifi, wifi_ap_config_t &wifi_ap_config)
{
  int cr, data_len, num_bytes_sent;

  printstrln("Welcome to simple web server demo.");

  wifi_start(p_wifi);

  printstr("connecting to "); printstrln(wifi_ap_config.ssid);

  wifi_connect(p_wifi, wifi_ap_config);

  wifi_server_init(p_wifi);

  for(int i = 0; i < MAX_CLIENTS; i++) clients[i] = -1;

  while(1)
  {
    while(1)
    {
      wifi_state = wifi_socket_accept(p_wifi, cr);

      //debug_print("accept = ", cr);

      if(cr == -1 || cr == -2)
      {
        delay_milliseconds(100);
        break;
      }

      else if(cr == -57)
      {
        wifi_state = wifi_socket_close(p_wifi, http_server_socket, dummy);
        printstrln("socket closed...");
        wifi_server_init(p_wifi);
        break;
      }

      else
      {
        int free_id = get_first_free_socket();

        if (free_id == -1)
        {
          break; // no free sockets available
        }
        else
        {
          clients[free_id] = cr;
        }
      }
    }


    for(int i = 0; i < MAX_CLIENTS; i++)
    {
      if(clients[i] == -1) continue;

      wifi_state = wifi_recv(p_wifi, clients[i], data, data_len);

      if (data_len > 0)
      {
        for(int i = 0; i < data_len; i++) printchar(data[i]);
        printstrln(" ");

        printstrln("sending...");
        wifi_state = wifi_send(p_wifi,
                               clients[i],
                               data,
                               strlen(data),
                               num_bytes_sent);

        // close
        //wifi_state = wifi_socket_close(p_wifi, clients[i], dummy);
        //clients[i] = -1;
      }
      else if(data_len == -57)
      {
        // close
        wifi_state = wifi_socket_close(p_wifi, clients[i], dummy);
        clients[i] = -1;
      }
    }
  }
}
