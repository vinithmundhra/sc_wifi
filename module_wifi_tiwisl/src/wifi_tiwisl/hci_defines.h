#ifndef _HCI_DEFINES_H_
#define _HCI_DEFINES_H_


//============================================================================
#ifdef __wifi_tiwisl_conf_h_exists__
#include "wifi_tiwisl_conf.h"
#endif

#ifndef WIFI_TCP_NODELAY
#define WIFI_TCP_NODELAY 0
#endif

#ifndef WIFI_SCAN
#define WIFI_SCAN 0
#endif
//============================================================================


#define HCI_TYPE_DATA                           (0x2)
#define HCI_DATA_HEADER_SIZE                    (5)
#define HCI_EVNT_WLAN_UNSOL_BASE                (0x8000)
#define HCI_EVNT_WLAN_UNSOL_CONNECT  	          (0x0001 + HCI_EVNT_WLAN_UNSOL_BASE)
#define HCI_EVNT_WLAN_UNSOL_DISCONNECT          (0x0002 + HCI_EVNT_WLAN_UNSOL_BASE)
#define HCI_EVNT_WLAN_UNSOL_DHCP                (0x0010 + HCI_EVNT_WLAN_UNSOL_BASE)
#define HCI_EVNT_WLAN_ASYNC_PING_REPORT         (0x0040 + HCI_EVNT_WLAN_UNSOL_BASE)
#define HCI_EVNT_WLAN_ASYNC_SIMPLE_CONFIG_DONE  (0x0080 + HCI_EVNT_WLAN_UNSOL_BASE)
#define HCI_EVNT_WLAN_KEEPALIVE			            (0x0200  + HCI_EVNT_WLAN_UNSOL_BASE)
#define AF_INET                                 (2)

typedef struct sock_addr_t_
{
  unsigned short ifamily;
  unsigned short iport;
  unsigned int iaddr;
  char izero[8];
}sock_addr_t;

typedef struct bsd_rtn_t_
{
  int sd;
  int status;
  sock_addr_t sock_addr;
}bsd_rtn_t;

typedef struct bsd_read_rtn_t_
{
  int sd;
  int num_bytes;
  int flags;
}bsd_read_rtn_t;

#endif // _HCI_DEFINES_H_
