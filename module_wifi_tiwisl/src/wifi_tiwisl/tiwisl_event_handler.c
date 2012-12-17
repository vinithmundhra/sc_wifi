// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Info
 ----
 
 ===========================================================================*/

/*---------------------------------------------------------------------------
 include files
 ---------------------------------------------------------------------------*/
#include "tiwisl_event_handler.h"
#include "hci_helper.h"
#include "hci_defines.h"
#include <string.h>
#include <print.h>

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define FLOW_CONTROL_EVENT_HANDLE_OFFSET        (0)
#define FLOW_CONTROL_EVENT_BLOCK_MODE_OFFSET    (1)
#define FLOW_CONTROL_EVENT_FREE_BUFFS_OFFSET    (2)
#define FLOW_CONTROL_EVENT_SIZE                 (4)

#define BSD_RSP_PARAMS_SOCKET_OFFSET        (0)
#define BSD_RSP_PARAMS_STATUS_OFFSET        (4)

#define GET_HOST_BY_NAME_RETVAL_OFFSET  (0)
#define GET_HOST_BY_NAME_ADDR_OFFSET    (4)

#define ACCEPT_SD_OFFSET            (0)
#define ACCEPT_RETURN_STATUS_OFFSET (4)
#define ACCEPT_ADDRESS__OFFSET      (8)

#define SL_RECEIVE_SD_OFFSET            (0)
#define SL_RECEIVE_NUM_BYTES_OFFSET     (4)
#define SL_RECEIVE__FLAGS__OFFSET       (8)

#define SELECT_STATUS_OFFSET            (0)
#define SELECT_READFD_OFFSET            (4)
#define SELECT_WRITEFD_OFFSET           (8)
#define SELECT_EXFD_OFFSET              (12)

#define NETAPP_IPCONFIG_IP_OFFSET               (0)
#define NETAPP_IPCONFIG_SUBNET_OFFSET           (4)
#define NETAPP_IPCONFIG_GW_OFFSET               (8)
#define NETAPP_IPCONFIG_DHCP_OFFSET             (12)
#define NETAPP_IPCONFIG_DNS_OFFSET              (16)
#define NETAPP_IPCONFIG_MAC_OFFSET              (20)
#define NETAPP_IPCONFIG_SSID_OFFSET             (26)

#define NETAPP_IPCONFIG_MAC_LENGTH              (6)
#define NETAPP_IPCONFIG_SSID_LENGTH             (32)

#define NETAPP_PING_PACKETS_SENT_OFFSET         (0)
#define NETAPP_PING_PACKETS_RCVD_OFFSET         (4)
#define NETAPP_PING_MIN_RTT_OFFSET              (8)
#define NETAPP_PING_MAX_RTT_OFFSET              (12)
#define NETAPP_PING_AVG_RTT_OFFSET              (16)

#define GET_SCAN_RESULTS_TABlE_COUNT_OFFSET             (0)
#define GET_SCAN_RESULTS_SCANRESULT_STATUS_OFFSET       (4)
#define GET_SCAN_RESULTS_ISVALID_TO_SSIDLEN_OFFSET      (8)
#define GET_SCAN_RESULTS_FRAME_TIME_OFFSET              (10)
#define GET_SCAN_RESULTS_SSID_MAC_LENGTH                (38)

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/
extern unsigned char tiwisl_rx_buf[];

/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/
xtcp_ipconfig_t tiwisl_ipconfig;

/*---------------------------------------------------------------------------
 static prototypes
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
int event_checker(int opcode, unsigned char *rx_buf)
{
    if(opcode == 0)
    {
        //process_unsolicited_event(c_xtcp, rx_buf);
        return 1;
    }

    else if(opcode == -1)
    {
        if(*rx_buf == HCI_TYPE_DATA)
        {
            return 1;
        }
    }

    else
    {
        if((*rx_buf == HCI_TYPE_EVNT) && (opcode == stream_to_short((char *) rx_buf, HCI_EVENT_OPCODE_OFFSET)))
        {
            return 1;
        }
    }
    return 0;
}

/*---------------------------------------------------------------------------
 implementation2
 ---------------------------------------------------------------------------*/
void tiwisl_get_ipconfig(xtcp_ipconfig_t *ipconfig)
{
    memcpy((unsigned char *)(ipconfig), (unsigned char *)(&tiwisl_ipconfig), sizeof(xtcp_ipconfig_t));
}

/*---------------------------------------------------------------------------
 implementation2
 ---------------------------------------------------------------------------*/
void hci_process_wlan_connect(xtcp_ipconfig_t *ipconfig)
{
    unsigned char *buf;
    buf = tiwisl_rx_buf + HCI_EVENT_HEADER_SIZE;

    ipconfig->ipaddr[3] = stream_to_char((char *)(buf), NETAPP_IPCONFIG_IP_OFFSET + 0);
    ipconfig->ipaddr[2] = stream_to_char((char *)(buf), NETAPP_IPCONFIG_IP_OFFSET + 1);
    ipconfig->ipaddr[1] = stream_to_char((char *)(buf), NETAPP_IPCONFIG_IP_OFFSET + 2);
    ipconfig->ipaddr[0] = stream_to_char((char *)(buf), NETAPP_IPCONFIG_IP_OFFSET + 3);

    ipconfig->netmask[3] = stream_to_char((char *)(buf), NETAPP_IPCONFIG_SUBNET_OFFSET + 0);
    ipconfig->netmask[2] = stream_to_char((char *)(buf), NETAPP_IPCONFIG_SUBNET_OFFSET + 1);
    ipconfig->netmask[1] = stream_to_char((char *)(buf), NETAPP_IPCONFIG_SUBNET_OFFSET + 2);
    ipconfig->netmask[0] = stream_to_char((char *)(buf), NETAPP_IPCONFIG_SUBNET_OFFSET + 3);

    ipconfig->gateway[3] = stream_to_char((char *)(buf), NETAPP_IPCONFIG_GW_OFFSET + 0);
    ipconfig->gateway[2] = stream_to_char((char *)(buf), NETAPP_IPCONFIG_GW_OFFSET + 1);
    ipconfig->gateway[1] = stream_to_char((char *)(buf), NETAPP_IPCONFIG_GW_OFFSET + 2);
    ipconfig->gateway[0] = stream_to_char((char *)(buf), NETAPP_IPCONFIG_GW_OFFSET + 3);

    /*
     * Could have used this but the addresses returned are in reverse order (LSB first)
     * memcpy((unsigned char *)(ipconfig), (unsigned char *)(buf), sizeof(xtcp_ipconfig_t));
     */
}

/*---------------------------------------------------------------------------
 implementation2
 ---------------------------------------------------------------------------*/
int hci_process_skt_create()
{
    unsigned char *buf;
    buf = tiwisl_rx_buf + HCI_EVENT_HEADER_SIZE;
    return ( stream_to_int((char *)(buf), 0) );
}

/*---------------------------------------------------------------------------
 implementation2
 ---------------------------------------------------------------------------*/
int hci_process_skt_bind()
{
    unsigned char *buf;
    buf = tiwisl_rx_buf + HCI_EVENT_HEADER_SIZE;
    return ( stream_to_int((char *)(buf), 0) );
}

/*---------------------------------------------------------------------------
 implementation2
 ---------------------------------------------------------------------------*/
int hci_process_skt_listen()
{
    unsigned char *buf;
    buf = tiwisl_rx_buf + HCI_EVENT_HEADER_SIZE;
    return ( stream_to_int((char *)(buf), 0) );
}

/*---------------------------------------------------------------------------
 implementation2
 ---------------------------------------------------------------------------*/
int hci_process_skt_accept()
{
    unsigned char *buf;
    bsd_rtn_t skt_rtn;
    buf = tiwisl_rx_buf + HCI_EVENT_HEADER_SIZE;
    memcpy((unsigned char *)(&skt_rtn), (unsigned char *)(buf), sizeof(bsd_rtn_t));
    return (int)(skt_rtn.status);
}

/*---------------------------------------------------------------------------
 implementation2
 ---------------------------------------------------------------------------*/
int hci_process_skt_recv()
{
    unsigned char *buf;
    bsd_read_rtn_t skt_read_rtn;
    buf = tiwisl_rx_buf + HCI_EVENT_HEADER_SIZE;
    memcpy((unsigned char *)(&skt_read_rtn), (unsigned char *)(buf), sizeof(bsd_read_rtn_t));
    return (int)(skt_read_rtn.num_bytes);
}

/*---------------------------------------------------------------------------
 implementation2
 ---------------------------------------------------------------------------*/
int hci_process_recv_data()
{
    unsigned char *buf;
    buf = tiwisl_rx_buf;
    return ((int)(stream_to_char((char *)(buf), HCI_PACKET_ARGSIZE_OFFSET)) + HCI_DATA_HEADER_SIZE);
}

/*==========================================================================*/
