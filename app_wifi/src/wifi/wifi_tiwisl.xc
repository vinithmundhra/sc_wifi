#include "wifi_tiwisl.h"
#include "wifi_spi.h"
#include "wifi_hci.h"
#include <string.h>
#include <print.h>

#define WIFI_BUF_SIZE  1200
#define MAX_CLIENTS       5
#define HI(value)                               (((value) & 0xFF00) >> 8)
#define LO(value)                               ((value) & 0x00FF)

static int socket_id = -1;
static unsigned char rx_buf[WIFI_BUF_SIZE];
static wifi_ipconfig_t wifi_ipconfig;

#if 0
static void debug_print_data(unsigned char msg[], unsigned char dt[], int ln)
{
  printstrln(msg);
  for(int i = 0; i < ln; i++)
  {
    printhex(dt[i]); printstr("  ");
  }
  printstrln("");
}
#endif

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
    else if(opcode == CMD_SEND)
    {
      if(rx_opcode == HCI_EVNT_DATA_UNSOL_FREE_BUFF)
      {
        return 0;
      }
    }
    else
    {
      return -1;
    }
  }
  return 0;
}

/*===========================================================================*/
static wifi_state_t wait_for_event(wifi_tiwisl_ports_t &p_wifi,
                                   unsigned short opcode,
                                   unsigned char d[],
                                   int l)
{
  int result = 0;
  spi_write(p_wifi, d, l);
  do
  {
    result = event_checker(p_wifi, opcode);
    if (result == -2)
    {
      return WIFI_ERR;
    }
  } while(result != 0);
  return WIFI_OK;
}

/*===========================================================================*/
static void wifi_simple_link_start(wifi_tiwisl_ports_t &p_wifi)
{
  unsigned char data[10] = {0x1, 0x0, 0x5, 0x0, 0x0, 0x1, 0x0, 0x40, 0x1, 0x0};
  spi_init(p_wifi);
  spi_first_write(p_wifi, data, 10);
  while(event_checker(p_wifi, CMD_SIMPLE_LINK_START) != 0);
}

/*===========================================================================*/
static void wifi_read_buffer(wifi_tiwisl_ports_t &p_wifi)
{
  unsigned char data[10] = {0x1, 0x0, 0x5, 0x0, 0x0, 0x1, 0xB, 0x40, 0x0, 0x0};
  spi_write(p_wifi, data, 10);
  while(event_checker(p_wifi, CMD_READ_BUFFER_SIZE) != 0);
}

/*===========================================================================*/
static void wifi_set_event_mask(wifi_tiwisl_ports_t &p_wifi)
{
  unsigned char data[14] = {0x1,  0x0, 0x9, 0x0, 0x0, 0x1, 0x8, 0x0, 0x4, 0xC3,
                            0x82, 0x0, 0x0, 0x0};
  spi_write(p_wifi, data, 14);
  while(event_checker(p_wifi, CMD_SET_EVENT_MASK) != 0);
}

/*===========================================================================*/
static void wifi_set_conn_policy(wifi_tiwisl_ports_t &p_wifi)
{
  unsigned char data[22] = {0x1, 0x0, 0x11, 0x0, 0x0, 0x1, 0x4, 0x0, 0xC, 0x0,
                            0x0, 0x0, 0x0,  0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
                            0x0, 0x0};
  spi_write(p_wifi, data, 22);
  while(event_checker(p_wifi, CMD_SET_CONN_POLICY) != 0);
}

/*===========================================================================*/
void wifi_start(wifi_tiwisl_ports_t &p_wifi)
{
  wifi_simple_link_start(p_wifi);
  wifi_read_buffer(p_wifi);
  wifi_set_event_mask(p_wifi);
  wifi_set_conn_policy(p_wifi);
}

/*===========================================================================*/
void wifi_stop(wifi_tiwisl_ports_t &p_wifi)
{
  spi_off(p_wifi);
}

/*===========================================================================*/
void wifi_connect(wifi_tiwisl_ports_t &p_wifi, wifi_ap_config_t &config)
{
  int len, index;
  unsigned char data[102];
  unsigned char param_len;
  unsigned char ssid_len = strlen(config.ssid);
  unsigned char key_len = strlen(config.key);

  memset(data, 0, 102);
  param_len = 32 + ssid_len + key_len;
  len = param_len + 5;

  if (!(param_len & 0x0001)) len++;

  data[0] = 1;
  data[2] = param_len;
  data[5] = 1;
  data[6] = 1;
  data[7] = 0;
  data[8] = (28 + ssid_len + key_len);
  data[9] = 0x1C;
  data[13] = ssid_len;
  data[17] = config.security_type;
  data[21] = 0x10 + ssid_len;
  data[25] = key_len;
  for(int i = 0; i < ssid_len; i++)
  {
    data[37 + i] = config.ssid[i];
  }
  index = 37 + ssid_len;
  for(int i = 0; i < key_len; i++)
  {
    data[index + i] = config.key[i];
  }

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

/*===========================================================================*/
wifi_state_t wifi_socket_create(wifi_tiwisl_ports_t &p_wifi,
                                wifi_sock_type_t type,
                                wifi_protocol_t protocol,
                                int &skt_id)
{
  wifi_state_t result;
  unsigned char data[22] = {0x1, 0x0, 0x11, 0x0, 0x0, 0x1, 0x1, 0x10, 0xC, 0x2,
                            0x0, 0x0, 0x0,  0x1, 0x0, 0x0, 0x0, 0x6,  0x0, 0x0,
                            0x0, 0x0};
  data[13] = (unsigned char)(type);
  data[17] = (unsigned char)(protocol);
  result = wait_for_event(p_wifi, CMD_SOCKET_CREATE, data, 22);
  // Get the socket ID
  skt_id = stream_to_int(rx_buf, HCI_EVENT_HEADER_SIZE);
  socket_id = skt_id;

  // Set TCP NO delay
  unsigned char tcp_no_delay[34] = {0x1, 0x0, 0x1D, 0x0, 0x0, 0x1, 0x9, 0x10, 0x18, 0x0,
                                    0x0, 0x0, 0x0,  0x6, 0x0, 0x0, 0x0, 0x1,  0x0,  0x0,
                                    0x0, 0x8, 0x0,  0x0, 0x0, 0x4, 0x0, 0x0,  0x0,  0x1,
                                    0x0, 0x0, 0x0, 0x0};
  result = wait_for_event(p_wifi, CMD_SETSOCKOPT, tcp_no_delay, 34);
  return result;
}

/*===========================================================================*/
wifi_state_t wifi_socket_bind(wifi_tiwisl_ports_t &p_wifi, int p, int &rtnval)
{
  wifi_state_t result;
  unsigned char data[30] = {0x1, 0x0, 0x19, 0x0, 0x0, 0x1, 0x2, 0x10, 0x14, 0x0,
                            0x0, 0x0, 0x0,  0x8, 0x0, 0x0, 0x0, 0x8,  0x0,  0x0,
                            0x0, 0x2, 0x0,  0x0, 0x50,0x0, 0x0, 0x0,  0x0,  0x0};
  data[23] = (unsigned char)((p >> 8) & 0xFF);
  data[24] = (unsigned char)(p & 0xFF);
  result = wait_for_event(p_wifi, CMD_BIND, data, 30);
  rtnval = stream_to_int(rx_buf, HCI_EVENT_HEADER_SIZE);
  return result;
}

/*===========================================================================*/
wifi_state_t wifi_socket_listen(wifi_tiwisl_ports_t &p_wifi, int &rtnval)
{
  wifi_state_t result;
  unsigned char data[18] = {0x1, 0x0, 0xD, 0x0, 0x0, 0x1, 0x6, 0x10, 0x8, 0x0,
                            0x0, 0x0, 0x0, 0x1, 0x0, 0x0, 0x0, 0x0};
  data[9] = (unsigned char)(socket_id & 0xFF);
  result = wait_for_event(p_wifi, CMD_LISTEN, data, 18);
  rtnval = stream_to_int(rx_buf, HCI_EVENT_HEADER_SIZE);
  return result;
}

/*===========================================================================*/
wifi_state_t wifi_socket_accept(wifi_tiwisl_ports_t &p_wifi, int &rtnval)
{
  wifi_state_t result;
  unsigned char data[14] = {0x1, 0x0, 0x9, 0x0, 0x0, 0x1, 0x5, 0x10, 0x4, 0x0,
                            0x0, 0x0, 0x0, 0x0};
  result = wait_for_event(p_wifi, CMD_ACCEPT, data, 14);
  // Get the socket descriptor
  rtnval = stream_to_int(rx_buf, (HCI_EVENT_HEADER_SIZE + 4));

  if(rtnval >= 0)
  {
    unsigned char rnblock[34] = {0x1, 0x0, 0x1D, 0x0,  0x0,  0x1, 0x9, 0x10, 0x18, 0x1,
                                 0x0, 0x0, 0x0,  0xFF, 0xFF, 0x0, 0x0, 0x1,  0x0,  0x0,
                                 0x0, 0x8, 0x0,  0x0,  0x0,  0x4, 0x0, 0x0,  0x0,  0x5,
                                 0x0, 0x0, 0x0, 0x0};
    rnblock[9] = rtnval;
    result = wait_for_event(p_wifi, CMD_SETSOCKOPT, rnblock, 34);
  }
  return result;
}

/*===========================================================================*/
wifi_state_t wifi_socket_close(wifi_tiwisl_ports_t &p_wifi, unsigned char sd, int &rtnval)
{
  wifi_state_t result;
  unsigned char data[14] = {0x1, 0x0, 0x9, 0x0, 0x0, 0x1, 0xB, 0x10, 0x4, 0x1,
                            0x0, 0x0, 0x0, 0x0};
  data[9] = sd;
  result = wait_for_event(p_wifi, CMD_CLOSE_SOCKET, data, 14);
  rtnval = stream_to_int(rx_buf, HCI_EVENT_HEADER_SIZE);
  return result;
}

/*===========================================================================*/
wifi_state_t wifi_recv(wifi_tiwisl_ports_t &p_wifi,
                       unsigned char sd,
                       unsigned char wifi_data_rx[],
                       int &len)
{
  wifi_state_t result;
  int data_offset = 0;
  unsigned char data[22] = {0x1, 0x0, 0x11, 0x0, 0x0, 0x1, 0x4, 0x10, 0xC, 0x1,
                            0x0, 0x0, 0x0, 0xB0, 0x4, 0x0, 0x0, 0x0,  0x0, 0x0,
                            0x0, 0x0};
  data[9] = sd;
  result = wait_for_event(p_wifi, CMD_RECV, data, 22);
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
  return result;
}

/*===========================================================================*/
wifi_state_t wifi_send(wifi_tiwisl_ports_t &p_wifi,
                       unsigned char sd,
                       unsigned char wifi_data_tx[],
                       int len,
                       int &num_bytes_sent)
{
  wifi_state_t result;
  unsigned char tx_buf[WIFI_BUF_SIZE];
  int spi_len;

  if(len > (WIFI_BUF_SIZE - HCI_SEND_DATA_OFFSET)) return WIFI_ERR;

  memset(tx_buf, 0, WIFI_BUF_SIZE);

  spi_len = 21 + len;
  if (!(spi_len & 0x0001)) spi_len++;

  tx_buf[0] = 1;
  tx_buf[1] = HI(spi_len);
  tx_buf[2] = LO(spi_len);
  tx_buf[5] = 2;
  tx_buf[6] = CMD_SEND;
  tx_buf[7] = 16;
  tx_buf[8] = LO(16 + len);
  tx_buf[9] = HI(16 + len);
  tx_buf[10] = sd;
  tx_buf[14] = 12;
  tx_buf[18] = LO(len);
  tx_buf[19] = HI(len);
  spi_len += 5;

  memcpy(&tx_buf[26], wifi_data_tx, len);
  result = wait_for_event(p_wifi, CMD_SEND, tx_buf, spi_len);
  num_bytes_sent = len;
  return WIFI_OK;
}
