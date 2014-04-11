#include "wifi_tiwisl.h"
#include "wifi_spi.h"
#include "wifi_helper.h"
#include "wifi_cmd.h"
#include <print.h>

#define WIFI_RX_BUF_SIZE            1200
#define MAX_CLIENTS 5

static int clientlist[MAX_CLIENTS] = {-1,-1,-1,-1,-1};
static unsigned char rx_buf[WIFI_RX_BUF_SIZE];
static unsigned char skt_id;
static unsigned char first_write = 1;
static wifi_ipconfig_t wifi_ipconfig;

static int wifi_wait_for_event(wifi_tiwisl_ports_t &p_wifi,
                               unsigned short opcode,
                               unsigned char data[],
                               int len)
{
  int rlen = 0;
  int rtnval;
  int opcode_event_rxd = 0;

  if(first_write) spi_first_write(p_wifi, data, len);
  else spi_write(p_wifi, data, len);

  while(opcode_event_rxd == 0)
  {
    rlen = spi_read(p_wifi, rx_buf);
    rtnval = event_checker(rx_buf[0], opcode, opcode_event_rxd);
  }
  return rtnval;
}

static int get_first_free_socket()
{
  int i;
  for(i = 0; i < MAX_CLIENTS; i++)
    if (clientlist[i] == -1) break;
  if (i >= MAX_CLIENTS) return -1;
  return i;
}

static void wifi_simple_link_start(wifi_tiwisl_ports_t &p_wifi)
{
  unsigned char data[10] = {0x1, 0x0, 0x5, 0x0, 0x0, 0x1, 0x0, 0x40, 0x1, 0x0};
  spi_init(p_wifi);
  wifi_wait_for_event(p_wifi, CMD_SIMPLE_LINK_START, data, 10);
  first_write = 0;
}

static void wifi_read_buffer(wifi_tiwisl_ports_t &p_wifi)
{
  unsigned char data[10] = {0x1, 0x0, 0x5, 0x0, 0x0, 0x1, 0xB, 0x40, 0x0, 0x0};
  wifi_wait_for_event(p_wifi, CMD_READ_BUFFER_SIZE, data, 10);
}

static void wifi_set_event_mask(wifi_tiwisl_ports_t &p_wifi)
{
  unsigned char data[14] = {0x1,  0x0, 0x9, 0x0, 0x0, 0x1, 0x8, 0x0, 0x4, 0xC3,
                            0x82, 0x0, 0x0, 0x0};
  wifi_wait_for_event(p_wifi, CMD_SET_EVENT_MASK, data, 14);
}

static void wifi_set_conn_policy(wifi_tiwisl_ports_t &p_wifi)
{
  unsigned char data[22] = {0x1, 0x0, 0x11, 0x0, 0x0, 0x1, 0x4, 0x0, 0xC, 0x0,
                            0x0, 0x0, 0x0,  0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
                            0x0, 0x0};
  wifi_wait_for_event(p_wifi, CMD_SET_CONN_POLICY, data, 22);
}

static int wifi_tcp_no_delay(wifi_tiwisl_ports_t &p_wifi)
{
  int rtnval;
  unsigned char data[34] = {0x1, 0x0, 0x1D, 0x0, 0x0, 0x1, 0x9, 0x10, 0x18, 0x0,
                            0x0, 0x0, 0x0, 0x6,  0x0, 0x0, 0x0, 0x1,  0x0,  0x0,
                            0x0, 0x8, 0x0, 0x0,  0x0, 0x4, 0x0, 0x0,  0x0,  0x1,
                            0x0, 0x0, 0x0, 0x0};
  rtnval = wifi_wait_for_event(p_wifi, CMD_SETSOCKOPT, data, 34);
  return rtnval;
}

static int wifi_recv_nblock(wifi_tiwisl_ports_t &p_wifi, unsigned char sd)
{
  int rtnval;
  unsigned char data[34] = {0x1, 0x0, 0x1D, 0x0, 0x0, 0x1, 0x9, 0x10, 0x18, 0x1,
                            0x0, 0x0, 0x0, 0xFF, 0xFF,0x0, 0x0, 0x1,  0x0,  0x0,
                            0x0, 0x8, 0x0, 0x0,  0x0, 0x4, 0x0, 0x0,  0x0,  0x5,
                            0x0, 0x0, 0x0, 0x0};
  data[9] = sd;
  rtnval = wifi_wait_for_event(p_wifi, CMD_SETSOCKOPT, data, 34);
  return rtnval;
}





/*
 * ===========================================================================
 * ===========================================================================
 */



int wifi_start(wifi_tiwisl_ports_t &p_wifi)
{
  wifi_simple_link_start(p_wifi);
  wifi_read_buffer(p_wifi);
  wifi_set_event_mask(p_wifi);
  wifi_set_conn_policy(p_wifi);
  return 0;
}

int wifi_stop(wifi_tiwisl_ports_t &p_wifi)
{
  spi_off(p_wifi);
  return 0;
}

int wifi_connect(wifi_tiwisl_ports_t &p_wifi, wifi_ap_config_t &config)
{
  int len, intconf;
  unsigned char data[102];
  len = pkg_cmd_connect(data[0], config);
  intconf = wifi_wait_for_event(p_wifi, CMD_DHCP, data, len);
  get_ipconfig(wifi_ipconfig);
  printstr("IP Address: ");
  printint(wifi_ipconfig.ipaddr[0]);printstr(".");
  printint(wifi_ipconfig.ipaddr[1]);printstr(".");
  printint(wifi_ipconfig.ipaddr[2]);printstr(".");
  printint(wifi_ipconfig.ipaddr[3]);printstr("\n");
  return 0;
}

int wifi_socket_create(wifi_tiwisl_ports_t &p_wifi,
                       wifi_sock_type_t type,
                       wifi_protocol_t protocol)
{
  unsigned char data[22] = {0x1, 0x0, 0x11, 0x0, 0x0, 0x1, 0x1, 0x10, 0xC, 0x2,
                            0x0, 0x0, 0x0,  0x1, 0x0, 0x0, 0x0, 0x6,  0x0, 0x0,
                            0x0, 0x0};
  data[13] = (unsigned char)(type);
  data[17] = (unsigned char)(protocol);
  skt_id = wifi_wait_for_event(p_wifi, CMD_SOCKET_CREATE, data, 22);
  wifi_tcp_no_delay(p_wifi);
  return skt_id;
}

int wifi_socket_bind(wifi_tiwisl_ports_t &p_wifi, int p)
{
  int rtnval;
  unsigned char data[30] = {0x1, 0x0, 0x19, 0x0, 0x0, 0x1, 0x2, 0x10, 0x14, 0x0,
                            0x0, 0x0, 0x0,  0x8, 0x0, 0x0, 0x0, 0x8,  0x0,  0x0,
                            0x0, 0x2, 0x0,  0x0, 0x50,0x0, 0x0, 0x0,  0x0,  0x0};
  data[24] = (unsigned char)(p & 0xFF);
  data[25] = (unsigned char)((p >> 8) & 0xFF);
  rtnval = wifi_wait_for_event(p_wifi, CMD_BIND, data, 30);
  return rtnval;
}

int wifi_socket_listen(wifi_tiwisl_ports_t &p_wifi)
{
  int rtnval;
  unsigned char data[18] = {0x1, 0x0, 0xD, 0x0, 0x0, 0x1, 0x6, 0x10, 0x8, 0x0,
                            0x0, 0x0, 0x0, 0x1, 0x0, 0x0, 0x0, 0x0};
  data[9] = (unsigned char)(skt_id & 0xFF); //xxx
  rtnval = wifi_wait_for_event(p_wifi, CMD_LISTEN, data, 18);
  return rtnval;
}

int wifi_socket_accept(wifi_tiwisl_ports_t &p_wifi)
{
  int rtnval;
  unsigned char data[14] = {0x1, 0x0, 0x9, 0x0, 0x0, 0x1, 0x5, 0x10, 0x4, 0x0,
                            0x0, 0x0, 0x0, 0x0};
  rtnval = wifi_wait_for_event(p_wifi, CMD_ACCEPT, data, 14);
  wifi_recv_nblock(p_wifi, rtnval);

  int new_conn_id = get_first_free_socket();
  if(new_conn_id == -1)
  { // no free sockets available
    return -1;
  }
  else
  {
    clientlist[new_conn_id] = rtnval;
  }

  return rtnval;
}

int wifi_socket_close(wifi_tiwisl_ports_t &p_wifi, unsigned char sd)
{
  int rtnval;
  unsigned char data[14] = {0x1, 0x0, 0x9, 0x0, 0x0, 0x1, 0xB, 0x10, 0x4, 0x1,
                            0x0, 0x0, 0x0, 0x0};
  data[9] = sd;
  rtnval = wifi_wait_for_event(p_wifi, CMD_CLOSE_SOCKET, data, 14);
  return rtnval;
}

int wifi_recv(wifi_tiwisl_ports_t &p_wifi,
              unsigned char sd,
              unsigned char rx_data[])
{
  int rtnval;
  unsigned char data[22] = {0x1, 0x0, 0x11, 0x0, 0x0, 0x1, 0x4, 0x10, 0xC, 0x1,
                            0x0, 0x0, 0x0, 0xB0, 0x4, 0x0, 0x0, 0x0,  0x0, 0x0,
                            0x0, 0x0};
  data[9] = sd;
  rtnval = wifi_wait_for_event(p_wifi, CMD_RECV, data, 22);

  if(rtnval > 0)
  {

  }

  return rtnval;
}
