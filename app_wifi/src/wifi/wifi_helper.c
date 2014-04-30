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
