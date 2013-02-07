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
#include <string.h>
#include "tiwisl_event_handler.h"
#include "hci_helper.h"
#include "hci_defines.h"
#include <print.h>
/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define NETAPP_IPCONFIG_IP_OFFSET               (0)
#define NETAPP_IPCONFIG_SUBNET_OFFSET           (4)
#define NETAPP_IPCONFIG_GW_OFFSET               (8)

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
 event_checker
 ---------------------------------------------------------------------------*/
int event_checker(int opcode, unsigned char *rx_buf)
{
    if(opcode == 0)
    {
        //TODO: process_unsolicited_event(c_xtcp, rx_buf);
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
 tiwisl_get_ipconfig
 ---------------------------------------------------------------------------*/
void tiwisl_get_ipconfig(xtcp_ipconfig_t *ipconfig)
{
    memcpy((unsigned char *)(ipconfig), (unsigned char *)(&tiwisl_ipconfig), sizeof(xtcp_ipconfig_t));
}

/*---------------------------------------------------------------------------
 hci_process_wlan_connect
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
 hci_process_wlan_scan
 ---------------------------------------------------------------------------*/
void hci_process_wlan_scan()
{
    volatile int temp_delay = 90000000;
    while(temp_delay > 0) { temp_delay--; }
}

/*---------------------------------------------------------------------------
 hci_process_wlan_get_scan_result
 ---------------------------------------------------------------------------*/
int hci_process_wlan_get_scan_result()
{
    unsigned char *buf;
    int num_networks;
    unsigned char ssid[32];

    buf = tiwisl_rx_buf + HCI_EVENT_HEADER_SIZE + 12;
    num_networks = stream_to_int(buf, 0);

    if(num_networks > 0)
    {
        memcpy((unsigned char *)(&ssid), (unsigned char *)(buf), 32);

        for(int i = 0; i < 32; i++)
        {
            if(ssid[i] != 0) { printchar(ssid[i]); }
        }
        printstrln("");
    }
    return num_networks;
}

/*---------------------------------------------------------------------------
 hci_process_skt_create
 ---------------------------------------------------------------------------*/
int hci_process_skt_create()
{
    unsigned char *buf;
    buf = tiwisl_rx_buf + HCI_EVENT_HEADER_SIZE;
    return ( stream_to_int((char *)(buf), 0) );
}

/*---------------------------------------------------------------------------
 hci_process_skt_bind
 ---------------------------------------------------------------------------*/
int hci_process_skt_bind()
{
    unsigned char *buf;
    buf = tiwisl_rx_buf + HCI_EVENT_HEADER_SIZE;
    return ( stream_to_int((char *)(buf), 0) );
}

/*---------------------------------------------------------------------------
 hci_process_skt_listen
 ---------------------------------------------------------------------------*/
int hci_process_skt_listen()
{
    unsigned char *buf;
    buf = tiwisl_rx_buf + HCI_EVENT_HEADER_SIZE;
    return ( stream_to_int((char *)(buf), 0) );
}

/*---------------------------------------------------------------------------
 hci_process_skt_accept
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
 hci_process_skt_recv
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
 hci_process_recv_data
 ---------------------------------------------------------------------------*/
int hci_process_recv_data()
{
    unsigned char *buf;
    buf = tiwisl_rx_buf;
    return ((int)(stream_to_char((char *)(buf), HCI_PACKET_ARGSIZE_OFFSET)) + HCI_DATA_HEADER_SIZE);
}

/*==========================================================================*/
