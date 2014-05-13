#include "webserver.h"
#include <print.h>
#include <string.h>
#include <stdio.h>

#define BUF_SIZE 1000
#define MAX_CLIENTS 5
#define BIND_PORT 80

static int http_server_socket;
static unsigned char data[BUF_SIZE];
static int clients[MAX_CLIENTS];

// Default HTTP page with HTTP headers included
char page[] = 	"HTTP/1.0 200 OK\nServer: xc2/pre-1.0 (http://xmos.com)\nContent-type: text/html\n\n"
				        "<!DOCTYPE html>\n"
				        "<html><head><title>Hello world</title></head>\n"
				        "<body>Hello World!</body></html>";

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

void webserver(wifi_tiwisl_ports_t &p_wifi)
{
  int cr, data_len, num_bytes_sent;
  wifi_ap_config_t wifi_ap_config;

  printstrln("Welcome to simple web server demo.");
  
  printstr("Enter SSID: ");
  gets(wifi_ap_config.ssid);
  
  printstr("Enter Key: ");
  gets(wifi_ap_config.key);
  wifi_ap_config.security_type = TIWISL_SEC_TYPE_WPA2;
  wifi_start(p_wifi);
  
  printstr("Connecting to "); printstrln(wifi_ap_config.ssid);
  wifi_connect(p_wifi, wifi_ap_config);
  
  wifi_server_init(p_wifi);

  for(int i = 0; i < MAX_CLIENTS; i++) clients[i] = -1;

  while(1)
  {
    while(1)
    {
      cr = wifi_socket_accept(p_wifi);

      if(cr == -1 || cr == -2)
      {
        delay_milliseconds(100);
        break;
      }

      else if(cr == -57)
      {
        wifi_socket_close(p_wifi, http_server_socket);
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

      data_len = wifi_recv(p_wifi, clients[i], data);

      if (data_len > 0)
      {
        if (strncmp(data, "GET ", 4) == 0)
        {
          num_bytes_sent = wifi_send(p_wifi, clients[i], page, strlen(page));
        }
        wifi_socket_close(p_wifi, clients[i]);
        clients[i] = -1;
      }
      else if(data_len == -57)
      {
        // close
        wifi_socket_close(p_wifi, clients[i]);
        clients[i] = -1;
      }
    }
  }
}

