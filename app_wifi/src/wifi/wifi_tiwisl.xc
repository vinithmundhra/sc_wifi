#include "wifi_tiwisl.h"
#include "wifi_spi.h"
#include "wifi_helper.h"
#include "wifi_cmd.h"
#include "wifi_offsets.h"
#include <string.h>
#include <print.h>

#define WIFI_RX_BUF_SIZE  1200
#define MAX_CLIENTS       5



static int socket_id = -1;

static int clientlist[MAX_CLIENTS] = {-1,-1,-1,-1,-1};
static unsigned char rx_buf[WIFI_RX_BUF_SIZE];
static unsigned char first_write = 1;
static wifi_ipconfig_t wifi_ipconfig;










/*===========================================================================*/
unsigned short stream_to_short(char p[], unsigned int offset)
{
  return (unsigned short) ((unsigned short)(p[offset + 1] << 8) +
                           (unsigned short)(p[offset])
                          );
}
/*===========================================================================*/
unsigned int stream_to_int(char p[], unsigned int offset)
{
  return (unsigned int) ((unsigned int)
      ((unsigned int) ((p[offset + 3])) << 24) +
      (unsigned int) ((unsigned int) ((p[offset + 2])) << 16) +
      (unsigned int) ((unsigned int) ((p[offset + 1])) << 8) +
      (unsigned int) ((p[offset])));
}
/*===========================================================================*/


#if 0
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
#endif
static int get_first_free_socket()
{
  int i;
  for(i = 0; i < MAX_CLIENTS; i++)
    if (clientlist[i] == -1) break;
  if (i >= MAX_CLIENTS) return -1;
  return i;
}

/*============================================================================*/
static int event_checker(wifi_tiwisl_ports_t &p_wifi, unsigned short opcode)
{
  int rlen;
  unsigned short rx_opcode;

  rlen = spi_read(p_wifi, rx_buf);
  if (rx_buf[0] == HCI_TYPE_EVNT)
  {
    rx_opcode = (unsigned short) ((rx_buf[2] << 8) + rx_buf[1]);
    if (rx_opcode == opcode)
    {
      return 0;
    }
    else if(rx_opcode == HCI_EVNT_WLAN_UNSOL_DISCONNECT)
    {
      return -2;
    }
    else if(rx_opcode == HCI_EVNT_CLOSE_SOCKET)
    {
      return -2;
    }
    else
    {
      return -1;
    }
  }
  return 0;
}

static void wifi_simple_link_start(wifi_tiwisl_ports_t &p_wifi)
{
  unsigned char data[10] = {0x1, 0x0, 0x5, 0x0, 0x0, 0x1, 0x0, 0x40, 0x1, 0x0};
  spi_init(p_wifi);
  spi_first_write(p_wifi, data, 10);
  while(event_checker(p_wifi, CMD_SIMPLE_LINK_START) != 0);
}

static void wifi_read_buffer(wifi_tiwisl_ports_t &p_wifi)
{
  unsigned char data[10] = {0x1, 0x0, 0x5, 0x0, 0x0, 0x1, 0xB, 0x40, 0x0, 0x0};
  spi_write(p_wifi, data, 10);
  while(event_checker(p_wifi, CMD_READ_BUFFER_SIZE) != 0);
}

static void wifi_set_event_mask(wifi_tiwisl_ports_t &p_wifi)
{
  unsigned char data[14] = {0x1,  0x0, 0x9, 0x0, 0x0, 0x1, 0x8, 0x0, 0x4, 0xC3,
                            0x82, 0x0, 0x0, 0x0};
  spi_write(p_wifi, data, 14);
  while(event_checker(p_wifi, CMD_SET_EVENT_MASK) != 0);
}

static void wifi_set_conn_policy(wifi_tiwisl_ports_t &p_wifi)
{
  unsigned char data[22] = {0x1, 0x0, 0x11, 0x0, 0x0, 0x1, 0x4, 0x0, 0xC, 0x0,
                            0x0, 0x0, 0x0,  0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
                            0x0, 0x0};
  spi_write(p_wifi, data, 22);
  while(event_checker(p_wifi, CMD_SET_CONN_POLICY) != 0);
}


/*
 * ===========================================================================
 * ===========================================================================
 */



void wifi_start(wifi_tiwisl_ports_t &p_wifi)
{
  wifi_simple_link_start(p_wifi);
  wifi_read_buffer(p_wifi);
  wifi_set_event_mask(p_wifi);
  wifi_set_conn_policy(p_wifi);
}

void wifi_stop(wifi_tiwisl_ports_t &p_wifi)
{
  spi_off(p_wifi);
}

void wifi_connect(wifi_tiwisl_ports_t &p_wifi, wifi_ap_config_t &config)
{
  int len;
  unsigned char data[102];
  len = pkg_cmd_connect(data[0], config);

  spi_write(p_wifi, data, len);
  while(event_checker(p_wifi, CMD_DHCP) != 0);

  // Get the IP configuration
  memcpy(&wifi_ipconfig, &rx_buf[HCI_EVENT_HEADER_SIZE], sizeof(wifi_ipconfig_t));

  printstr("IP Address: ");
  printint(wifi_ipconfig.ipaddr[3]);printstr(".");
  printint(wifi_ipconfig.ipaddr[2]);printstr(".");
  printint(wifi_ipconfig.ipaddr[1]);printstr(".");
  printint(wifi_ipconfig.ipaddr[0]);printstr("\n");
}

wifi_state_t wifi_socket_create(wifi_tiwisl_ports_t &p_wifi,
                                wifi_sock_type_t type,
                                wifi_protocol_t protocol,
                                int &skt_id)
{
  int result = 0;
  unsigned char data[22] = {0x1, 0x0, 0x11, 0x0, 0x0, 0x1, 0x1, 0x10, 0xC, 0x2,
                            0x0, 0x0, 0x0,  0x1, 0x0, 0x0, 0x0, 0x6,  0x0, 0x0,
                            0x0, 0x0};
  data[13] = (unsigned char)(type);
  data[17] = (unsigned char)(protocol);

  spi_write(p_wifi, data, 22);

  do
  {
    result = event_checker(p_wifi, CMD_SOCKET_CREATE);
    if(result == -2)
    {
      return WIFI_ERR;
    }
  }while(result != 0);

  // Get the socket ID
  skt_id = stream_to_int(rx_buf, HCI_EVENT_HEADER_SIZE);
  socket_id = skt_id;
  return WIFI_OK;
}

wifi_state_t wifi_socket_bind(wifi_tiwisl_ports_t &p_wifi, int p, int &rtnval)
{
  int result = 0;
  unsigned char data[30] = {0x1, 0x0, 0x19, 0x0, 0x0, 0x1, 0x2, 0x10, 0x14, 0x0,
                            0x0, 0x0, 0x0,  0x8, 0x0, 0x0, 0x0, 0x8,  0x0,  0x0,
                            0x0, 0x2, 0x0,  0x0, 0x50,0x0, 0x0, 0x0,  0x0,  0x0};
  data[23] = (unsigned char)((p >> 8) & 0xFF);
  data[24] = (unsigned char)(p & 0xFF);

  spi_write(p_wifi, data, 30);

  do
  {
    result = event_checker(p_wifi, CMD_BIND);
    if(result == -2)
    {
      return WIFI_ERR;
    }
  }while(result != 0);

  // Get the socket ID
  rtnval = stream_to_int(rx_buf, HCI_EVENT_HEADER_SIZE);
  return WIFI_OK;
}

wifi_state_t wifi_socket_listen(wifi_tiwisl_ports_t &p_wifi, int &rtnval)
{
  int result = 0;
  unsigned char data[18] = {0x1, 0x0, 0xD, 0x0, 0x0, 0x1, 0x6, 0x10, 0x8, 0x0,
                            0x0, 0x0, 0x0, 0x1, 0x0, 0x0, 0x0, 0x0};

  data[9] = (unsigned char)(socket_id & 0xFF);


  spi_write(p_wifi, data, 18);

  do
  {
    result = event_checker(p_wifi, CMD_LISTEN);
    if(result == -2)
    {
      return WIFI_ERR;
    }
  }while(result != 0);

  // Get the socket ID
  rtnval = stream_to_int(rx_buf, HCI_EVENT_HEADER_SIZE);
  return WIFI_OK;
}

wifi_state_t wifi_socket_accept(wifi_tiwisl_ports_t &p_wifi, int &rtnval)
{
  int result = 0;
  unsigned char data[14] = {0x1, 0x0, 0x9, 0x0, 0x0, 0x1, 0x5, 0x10, 0x4, 0x0,
                            0x0, 0x0, 0x0, 0x0};



  spi_write(p_wifi, data, 14);

  do
  {
    result = event_checker(p_wifi, CMD_ACCEPT);
    if(result == -2)
    {
      return WIFI_ERR;
    }
  }while(result != 0);

  // Get the socket descriptor
  rtnval = stream_to_int(rx_buf, (HCI_EVENT_HEADER_SIZE + 4));
  return WIFI_OK;
}

wifi_state_t wifi_socket_close(wifi_tiwisl_ports_t &p_wifi, unsigned char sd, int &rtnval)
{
  int result = 0;
  unsigned char data[14] = {0x1, 0x0, 0x9, 0x0, 0x0, 0x1, 0xB, 0x10, 0x4, 0x1,
                            0x0, 0x0, 0x0, 0x0};
  data[9] = sd;

  spi_write(p_wifi, data, 14);

  do
  {
    result = event_checker(p_wifi, CMD_CLOSE_SOCKET);
    if(result == -2)
    {
      return WIFI_ERR;
    }
  }while(result != 0);

  // Get the socket descriptor
  rtnval = stream_to_int(rx_buf, HCI_EVENT_HEADER_SIZE);
  return WIFI_OK;
}

wifi_state_t wifi_recv(wifi_tiwisl_ports_t &p_wifi,
                       unsigned char sd,
                       unsigned char wifi_data_rx[],
                       int &len)
{
  int result = 0;
  int data_offset = 0;
  unsigned char data[22] = {0x1, 0x0, 0x11, 0x0, 0x0, 0x1, 0x4, 0x10, 0xC, 0x1,
                            0x0, 0x0, 0x0, 0xB0, 0x4, 0x0, 0x0, 0x0,  0x0, 0x0,
                            0x0, 0x0};
  data[9] = sd;

  spi_write(p_wifi, data, 22);

  do
  {
    result = event_checker(p_wifi, CMD_RECV);
    if(result == -2)
    {
      return WIFI_ERR;
    }
  }while(result != 0);

  len = stream_to_int(rx_buf, (HCI_EVENT_HEADER_SIZE+4));

  if(len > 0)
  {
    result = event_checker(p_wifi, -1);
    if(result == -2)
    {
      return WIFI_ERR;
    }
    else
    {
      data_offset = rx_buf[HCI_PACKET_ARGSIZE_OFFSET] + HCI_DATA_HEADER_SIZE;
      memcpy(wifi_data_rx, &rx_buf[data_offset], len);
    }
  }

  return WIFI_OK;
}


wifi_state_t wifi_send(wifi_tiwisl_ports_t &p_wifi,
                       unsigned char sd,
                       unsigned char wifi_data_tx[],
                       int len,
                       int &num_bytes_sent)
{

}
