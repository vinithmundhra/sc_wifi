#include "tiwisl_event_handler.h"
#include "hci_helper.h"
#include "hci_defines.h"
#include <string.h>

#if WIFI_SCAN
#include <print.h>
#endif


#define NETAPP_IPCONFIG_IP_OFFSET       (0)
#define NETAPP_IPCONFIG_SUBNET_OFFSET   (4)
#define NETAPP_IPCONFIG_GW_OFFSET       (8)
#define HCI_EVENT_HEADER_SIZE           (5)
#define HCI_PACKET_ARGSIZE_OFFSET       (2)
#define HCI_EVENT_OPCODE_OFFSET         (1)
#define HCI_TYPE_EVNT                   (0x4)

extern unsigned char tiwisl_rx_buf[];

xtcp_ipconfig_t tiwisl_ipconfig;

/*---------------------------------------------------------------------------
 event_checker
 ---------------------------------------------------------------------------*/
int event_checker(int opcode, unsigned char *rx_buf)
{
  if (opcode == 0)
  {
    //TODO: process_unsolicited_event(c_xtcp, rx_buf);
    return 1;
  }

  else if (opcode == -1)
  {
    if (*rx_buf == HCI_TYPE_DATA)
    {
      return 1;
    }
  }

  else
  {
    if ((*rx_buf == HCI_TYPE_EVNT) && (opcode == stream_to_short((char *) rx_buf, HCI_EVENT_OPCODE_OFFSET)))
    {
      return 1;
    }
  }
  return 0;
}

/*---------------------------------------------------------------------------
 tiwisl_get_ipconfig
 ---------------------------------------------------------------------------*/
void tiwisl_get_ipconfig(xtcp_ipconfig_t *ipconfig)
{
  memcpy((unsigned char *) (ipconfig),
         (unsigned char *) (&tiwisl_ipconfig),
         sizeof(xtcp_ipconfig_t));
}

/*---------------------------------------------------------------------------
 hci_process_wlan_connect
 ---------------------------------------------------------------------------*/
void hci_process_wlan_connect(xtcp_ipconfig_t *ipconfig)
{
  unsigned char *buf;
  buf = tiwisl_rx_buf + HCI_EVENT_HEADER_SIZE;
  ipconfig->ipaddr[3] = stream_to_char((char *) (buf), NETAPP_IPCONFIG_IP_OFFSET + 0);
  ipconfig->ipaddr[2] = stream_to_char((char *) (buf), NETAPP_IPCONFIG_IP_OFFSET + 1);
  ipconfig->ipaddr[1] = stream_to_char((char *) (buf), NETAPP_IPCONFIG_IP_OFFSET + 2);
  ipconfig->ipaddr[0] = stream_to_char((char *) (buf), NETAPP_IPCONFIG_IP_OFFSET + 3);
  ipconfig->netmask[3] = stream_to_char((char *) (buf), NETAPP_IPCONFIG_SUBNET_OFFSET + 0);
  ipconfig->netmask[2] = stream_to_char((char *) (buf), NETAPP_IPCONFIG_SUBNET_OFFSET + 1);
  ipconfig->netmask[1] = stream_to_char((char *) (buf), NETAPP_IPCONFIG_SUBNET_OFFSET + 2);
  ipconfig->netmask[0] = stream_to_char((char *) (buf), NETAPP_IPCONFIG_SUBNET_OFFSET + 3);
  ipconfig->gateway[3] = stream_to_char((char *) (buf), NETAPP_IPCONFIG_GW_OFFSET + 0);
  ipconfig->gateway[2] = stream_to_char((char *) (buf), NETAPP_IPCONFIG_GW_OFFSET + 1);
  ipconfig->gateway[1] = stream_to_char((char *) (buf), NETAPP_IPCONFIG_GW_OFFSET + 2);
  ipconfig->gateway[0] = stream_to_char((char *) (buf), NETAPP_IPCONFIG_GW_OFFSET + 3);
}

/*---------------------------------------------------------------------------
 hci_process_wlan_scan
 ---------------------------------------------------------------------------*/
#if WIFI_SCAN
void hci_process_wlan_scan()
{
  volatile int temp_delay = 90000000;
  while(temp_delay > 0)
  {
    temp_delay--;
  }
}

/*---------------------------------------------------------------------------
 hci_process_wlan_get_scan_result
 ---------------------------------------------------------------------------*/
int hci_process_wlan_get_scan_result()
{
  unsigned char *buf;
  int num_networks;
  char ssid_name_length;
  unsigned char ssid[32];

  buf = tiwisl_rx_buf + HCI_EVENT_HEADER_SIZE;
  num_networks = stream_to_int((char *) buf, 0);
  ssid_name_length = (stream_to_char((char *) buf, 9) >> 2);

  if (num_networks > 0)
  {
    memcpy((unsigned char *) (&ssid),
           (unsigned char *) (buf + 12),
           ssid_name_length);

    for(int i = 0; i < ssid_name_length; i++)
    {
      if (ssid[i] != 0)
      {
        printchar(ssid[i]);
      }
    }
    printstrln("");
  }
  return num_networks;
}
#endif

/*---------------------------------------------------------------------------
 hci_process_skt_create
 ---------------------------------------------------------------------------*/
int hci_process_skt_create()
{
  unsigned char *buf;
  buf = tiwisl_rx_buf + HCI_EVENT_HEADER_SIZE;
  return (stream_to_int((char *) (buf), 0));
}

/*---------------------------------------------------------------------------
 hci_process_skt_accept
 ---------------------------------------------------------------------------*/
int hci_process_skt_accept()
{
  unsigned char *buf;
  bsd_rtn_t skt_rtn;
  buf = tiwisl_rx_buf + HCI_EVENT_HEADER_SIZE;
  memcpy((unsigned char *) (&skt_rtn),
         (unsigned char *) (buf),
         sizeof(bsd_rtn_t));
  return (int) (skt_rtn.status);
}

/*---------------------------------------------------------------------------
 hci_process_skt_recv
 ---------------------------------------------------------------------------*/
int hci_process_skt_recv()
{
  unsigned char *buf;
  bsd_read_rtn_t skt_read_rtn;
  buf = tiwisl_rx_buf + HCI_EVENT_HEADER_SIZE;
  memcpy((unsigned char *) (&skt_read_rtn),
         (unsigned char *) (buf),
         sizeof(bsd_read_rtn_t));
  return (int) (skt_read_rtn.num_bytes);
}

/*---------------------------------------------------------------------------
 hci_process_recv_data
 ---------------------------------------------------------------------------*/
int hci_process_recv_data()
{
  unsigned char *buf;
  buf = tiwisl_rx_buf;
  return ((int) (stream_to_char((char *) (buf), HCI_PACKET_ARGSIZE_OFFSET))
      + HCI_DATA_HEADER_SIZE);
}

/*---------------------------------------------------------------------------
 hci_process_setsockopt
 ---------------------------------------------------------------------------*/
int hci_process_setsockopt()
{
  unsigned char *buf;
  buf = tiwisl_rx_buf + HCI_EVENT_HEADER_SIZE;
  return (stream_to_int((char *) (buf), 0));
}
