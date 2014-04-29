#include "wifi_helper.h"
#include "wifi_cmd.h"
#include "wifi_structs.h"
#include "wifi_util.h"
#include <string.h>
#include <print.h>

#define HCI_TYPE_CMND                           (0x1)
#define HCI_TYPE_DATA                           (0x2)
#define HCI_TYPE_EVNT                           (0x4)
#define SIMPLE_LINK_HCI_DATA_HEADER_SIZE        (5)
#define SIMPLE_LINK_HCI_CMND_HEADER_SIZE        (4)
#define HEADERS_SIZE_CMD                        (SPI_HEADER_SIZE + SIMPLE_LINK_HCI_CMND_HEADER_SIZE)
#define HCI_CMND_WLAN_CONNECT                   (0x0001)
#define HCI_CMND_SEND                           (0x81)
#define WLAN_CONNECT_PARAM_LEN                  (29)
#define ETH_ALEN                                (6)
#define SPI_HEADER_SIZE                         (5)
#define WRITE                                   (1)
#define HI(value)                               (((value) & 0xFF00) >> 8)
#define LO(value)                               ((value) & 0x00FF)

#define HCI_EVENT_HEADER_SIZE           (5)
#define NETAPP_IPCONFIG_IP_OFFSET       (0)
#define NETAPP_IPCONFIG_SUBNET_OFFSET   (4)
#define NETAPP_IPCONFIG_GW_OFFSET       (8)
#define HCI_EVENT_HEADER_SIZE           (5)
#define HCI_PACKET_ARGSIZE_OFFSET       (2)

/*---------------------------------------------------------------------------
 ---------------------------------------------------------------------------*/
static int hci_pkg_spi_header(unsigned char *buf, unsigned short len)
{
  unsigned char *stream;
  int pad = 0;

  if (!(len & 0x0001))
  {
    pad++;
    stream = char_to_stream((buf + SPI_HEADER_SIZE + len), 0);
  }
  stream = char_to_stream(buf, WRITE);
  stream = char_to_stream(stream, HI(len + pad));
  stream = char_to_stream(stream, LO(len + pad));
  stream = char_to_stream(stream, 0);
  stream = char_to_stream(stream, 0);
  return (SPI_HEADER_SIZE + len + pad);
}

/*---------------------------------------------------------------------------
 ---------------------------------------------------------------------------*/
static unsigned int hci_pkg_cmd(unsigned short opcode,
                                unsigned char *buf,
                                unsigned char args_len)
{
  unsigned char *stream;
  unsigned int len;
  len = hci_pkg_spi_header(buf, (args_len + SIMPLE_LINK_HCI_CMND_HEADER_SIZE));
  stream = (unsigned char *) (buf + SPI_HEADER_SIZE);
  stream = char_to_stream(stream, HCI_TYPE_CMND);
  stream = short_to_stream(stream, opcode);
  stream = char_to_stream(stream, args_len);
  return len;
}

/*---------------------------------------------------------------------------
 ---------------------------------------------------------------------------*/
static unsigned int hci_pkg_data(unsigned char opcode,
                                 unsigned char *buf,
                                 unsigned short args_len,
                                 unsigned short data_len)
{
  unsigned char *stream;
  unsigned int len;
  len = hci_pkg_spi_header(buf, (SIMPLE_LINK_HCI_DATA_HEADER_SIZE + args_len + data_len));
  stream = buf + SPI_HEADER_SIZE;
  stream = char_to_stream(stream, HCI_TYPE_DATA);
  stream = char_to_stream(stream, opcode);
  stream = char_to_stream(stream, args_len);
  stream = short_to_stream(stream, (args_len + data_len));
  return len;
}

/*---------------------------------------------------------------------------
 Package the connect command
 ---------------------------------------------------------------------------*/
int pkg_cmd_connect(unsigned char *data, wifi_ap_config_t *config)
{
  unsigned char *args;
  unsigned char bssid_zero[] = {0, 0, 0, 0, 0, 0};
  int len, ssid_len, key_len;

  ssid_len = strlen((char *) (config->ssid));
  key_len = strlen((char *) (config->key));

  args = (data + HEADERS_SIZE_CMD);
  args = int_to_stream(args, 0x0000001c);
  args = int_to_stream(args, ssid_len);
  args = int_to_stream(args, config->security_type);
  args = int_to_stream(args, 0x00000010 + ssid_len);
  args = int_to_stream(args, key_len);
  args = short_to_stream(args, 0);
  args = array_to_stream(args, bssid_zero, ETH_ALEN);
  args = array_to_stream(args, config->ssid, ssid_len);
  if (key_len)
  {
    args = array_to_stream(args, config->key, key_len);
  }
  len = hci_pkg_cmd(HCI_CMND_WLAN_CONNECT,
                    data,
                    (WLAN_CONNECT_PARAM_LEN + ssid_len + key_len - 1));
  return len;
}

/*---------------------------------------------------------------------------
 Package the send command
 ---------------------------------------------------------------------------*/
int hci_pkg_skt_send(unsigned char *data, int dlen, int sd)
{
  unsigned char *args;
  int len;

  args = data + HEADERS_SIZE_DATA;
  args = int_to_stream(args, sd);
  args = int_to_stream(args, HCI_CMND_SEND_ARG_LENGTH - sizeof(sd));
  args = int_to_stream(args, dlen);
  args = int_to_stream(args, 0);
  len = hci_pkg_data(HCI_CMND_SEND, data, HCI_CMND_SEND_ARG_LENGTH, dlen);
  return len;
}
