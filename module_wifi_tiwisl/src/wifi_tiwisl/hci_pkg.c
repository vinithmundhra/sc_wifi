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
#include "hci_pkg.h"
#include "hci_helper.h"
#include "hci_defines.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define WRITE               1
#define HI(value)           (((value) & 0xFF00) >> 8)
#define LO(value)           ((value) & 0x00FF)

#define ETH_ALEN                                (6)
#define SL_PATCHES_REQUEST_DEFAULT              (0)

#define WLAN_SL_INIT_START_PARAMS_LEN           (1)
#define WLAN_SET_CONNECTION_POLICY_PARAMS_LEN   (12)
#define WLAN_SET_MASK_PARAMS_LEN                (4)
#define WLAN_CONNECT_PARAM_LEN                  (29)
#define ASIC_ADDR_LEN                           (8)
#define SOCKET_OPEN_PARAMS_LEN                  (12)
#define SOCKET_CLOSE_PARAMS_LEN                 (4)
#define SOCKET_ACCEPT_PARAMS_LEN                (4)
#define SOCKET_BIND_PARAMS_LEN                  (20)
#define SOCKET_LISTEN_PARAMS_LEN                (8)
#define SOCKET_RECV_FROM_PARAMS_LEN             (12)

#define SIMPLE_LINK_HCI_CMND_HEADER_SIZE                (4)
#define HEADERS_SIZE_CMD                                (SPI_HEADER_SIZE + SIMPLE_LINK_HCI_CMND_HEADER_SIZE)
#define SIMPLE_LINK_HCI_DATA_HEADER_SIZE                (5)

#define HCI_CMND_WLAN_CONNECT                           (0x0001)
#define HCI_CMND_WLAN_IOCTL_SET_CONNECTION_POLICY       (0x0004)
#define HCI_CMND_EVENT_MASK                             (0x0008)

//------------ Socket Types ------------
#define SOCK_STREAM             1
#define IPPROTO_TCP             6

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/
extern unsigned char tiwisl_tx_buf[];
extern bsd_rtn_t skt_rtn;
extern int skt_id;
extern int skt_accept_status;

/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 static prototypes
 ---------------------------------------------------------------------------*/

/*==========================================================================*/
/**
 *  hci_pkg_spi_header: package the SPI header
 *
 *  \param buf   buffer pointing to tx
 *  \param len   length of data other than SPI header
 *  \return int  overall length
 **/
static int hci_pkg_spi_header(unsigned char *buf, unsigned short len);

/*==========================================================================*/
/**
 *  hci_pkg_cmd: package command
 *
 *  \param opcode    opcode to check in the response
 *  \param buf       buffer pointing to tx
 *  \param args_len  length of command arguments
 *  \return int      overall length
 **/
static unsigned int hci_pkg_cmd(unsigned short opcode,
                                unsigned char *buf,
                                unsigned char args_len);

/*==========================================================================*/
/**
 *  hci_pkg_data: package data
 *
 *  \param opcode    opcode to check in the response
 *  \param buf       buffer pointing to tx
 *  \param args_len  length of command arguments
 *  \param data_len  length of data
 *  \return int      overall length
 **/
static unsigned int hci_pkg_data(unsigned char opcode,
                                 unsigned char *buf,
                                 unsigned short args_len,
                                 unsigned short data_len);

/*---------------------------------------------------------------------------
 hci_pkg_cmd
 ---------------------------------------------------------------------------*/
static unsigned int hci_pkg_cmd(unsigned short opcode,
                                unsigned char *buf,
                                unsigned char args_len)
{ 
	unsigned char *stream;
    unsigned int len;

    len = hci_pkg_spi_header(buf, (args_len + SIMPLE_LINK_HCI_CMND_HEADER_SIZE));
    
	stream = (unsigned char *)(buf + SPI_HEADER_SIZE);	
	stream = char_to_stream(stream, HCI_TYPE_CMND);
	stream = short_to_stream(stream, opcode);
	stream = char_to_stream(stream, args_len);

    return len;
}

/*---------------------------------------------------------------------------
 hci_pkg_data
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
 hci_pkg_spi_header
 ---------------------------------------------------------------------------*/
static int hci_pkg_spi_header(unsigned char *buf, unsigned short len)
{
    unsigned char *stream;
    int pad = 0;

    if(!(len & 0x0001))
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
 hci_pkg_wifi_on
 ---------------------------------------------------------------------------*/
int hci_pkg_wifi_on(int *opcode)
{
    unsigned char *args;
    unsigned char *buf;
    int len;

    buf = tiwisl_tx_buf;
    args = (unsigned char *)(buf + HEADERS_SIZE_CMD);
    args = char_to_stream(args, SL_PATCHES_REQUEST_DEFAULT);
    len = hci_pkg_cmd(HCI_CMND_SIMPLE_LINK_START, buf, WLAN_SL_INIT_START_PARAMS_LEN);

    *opcode = HCI_CMND_SIMPLE_LINK_START;
    return len;
}

/*---------------------------------------------------------------------------
 hci_pkg_read_buffer_size
 ---------------------------------------------------------------------------*/
int hci_pkg_read_buffer_size(int *opcode)
{
    unsigned char *buf;
    buf = tiwisl_tx_buf;
    *opcode = HCI_CMND_READ_BUFFER_SIZE;
    return hci_pkg_cmd(HCI_CMND_READ_BUFFER_SIZE, buf, 0);
}

/*---------------------------------------------------------------------------
 hci_pkg_set_event_mask
 ---------------------------------------------------------------------------*/
int hci_pkg_set_event_mask(int mask, int *opcode)
{
    unsigned char *buf, *args;
    buf = tiwisl_tx_buf;

    args = (buf + HEADERS_SIZE_CMD);
    args = int_to_stream(args, mask);

    *opcode = HCI_CMND_EVENT_MASK;
    return hci_pkg_cmd(HCI_CMND_EVENT_MASK, buf, WLAN_SET_MASK_PARAMS_LEN);
}

/*---------------------------------------------------------------------------
 hci_pkg_wlan_connect
 ---------------------------------------------------------------------------*/
int hci_pkg_wlan_connect(wifi_ap_config_t *ap_config, int *opcode)
{
    unsigned char *args;
    unsigned char *buf;
    unsigned char bssid_zero[] = {0, 0, 0, 0, 0, 0}; 
    int len, ssid_len, key_len;
    
    ssid_len = strlen((char *)(ap_config->ssid));
    key_len = strlen((char *)(ap_config->key));
    
    buf = tiwisl_tx_buf;
    args = (buf + HEADERS_SIZE_CMD);
    args = int_to_stream(args, 0x0000001c);
	args = int_to_stream(args, ssid_len);
	args = int_to_stream(args, ap_config->security_type);
	args = int_to_stream(args, 0x00000010 + ssid_len);
	args = int_to_stream(args, key_len);
	args = short_to_stream(args, 0);
    args = array_to_stream(args, bssid_zero, ETH_ALEN);
    args = array_to_stream(args, ap_config->ssid, ssid_len);
    
    if(key_len)
    {
        args = array_to_stream(args, ap_config->key, key_len);
    }
    
    len = hci_pkg_cmd(HCI_CMND_WLAN_CONNECT, buf, (WLAN_CONNECT_PARAM_LEN + ssid_len + key_len - 1));

    *opcode = HCI_EVNT_WLAN_UNSOL_DHCP;
    return len;
}

/*---------------------------------------------------------------------------
 hci_pkg_wlan_set_connection_policy
 ---------------------------------------------------------------------------*/
int hci_pkg_wlan_set_connection_policy(unsigned int should_connect_to_open_ap,
                                       unsigned int should_use_fast_connect,
                                       unsigned int use_profiles,
                                       int *opcode)
{
    int len;
    unsigned char *buf;
    unsigned char *args;

    buf = tiwisl_tx_buf;
    args = (unsigned char *)(buf + HEADERS_SIZE_CMD);
    args = int_to_stream(args, should_connect_to_open_ap);
    args = int_to_stream(args, should_use_fast_connect);
    args = int_to_stream(args, use_profiles);

    len = hci_pkg_cmd(HCI_CMND_WLAN_IOCTL_SET_CONNECTION_POLICY, buf, WLAN_SET_CONNECTION_POLICY_PARAMS_LEN);
    *opcode = HCI_CMND_WLAN_IOCTL_SET_CONNECTION_POLICY;
    return len;
}

/*---------------------------------------------------------------------------
 hci_pkg_skt_create
 ---------------------------------------------------------------------------*/
int hci_pkg_skt_create(int *opcode)
{
    unsigned char *buf, *args;
    int len;

    buf = tiwisl_tx_buf;
    args = (unsigned char *)(buf + HEADERS_SIZE_CMD);
    args = int_to_stream(args, AF_INET);
    args = int_to_stream(args, SOCK_STREAM);
    args = int_to_stream(args, IPPROTO_TCP);

    len = hci_pkg_cmd(HCI_CMND_SOCKET, buf, SOCKET_OPEN_PARAMS_LEN);
    *opcode = HCI_CMND_SOCKET;
    return len;
}

/*---------------------------------------------------------------------------
 hci_pkg_skt_bind
 ---------------------------------------------------------------------------*/
int hci_pkg_skt_bind(int *opcode)
{
    unsigned char *buf, *args;
    int len;

    buf = tiwisl_tx_buf;
    args = (unsigned char *)(buf + HEADERS_SIZE_CMD);
    args = int_to_stream(args, skt_id);
    args = int_to_stream(args, 0x00000008);
    args = int_to_stream(args, ASIC_ADDR_LEN);
    args = short_to_stream(args, AF_INET);
    args = char_to_stream(args, HI((unsigned short)(skt_rtn.sock_addr.iport)));
    args = char_to_stream(args, LO((unsigned short)(skt_rtn.sock_addr.iport)));
    args = int_to_stream(args, 0);

    len = hci_pkg_cmd(HCI_CMND_BIND, buf, SOCKET_BIND_PARAMS_LEN);
    *opcode = HCI_CMND_BIND;
    return len;
}

/*---------------------------------------------------------------------------
 hci_pkg_skt_listen
 ---------------------------------------------------------------------------*/
int hci_pkg_skt_listen(int *opcode)
{
    unsigned char *buf, *args;
    int len;

    buf = tiwisl_tx_buf;
    args = (unsigned char *)(buf + HEADERS_SIZE_CMD);
    args = int_to_stream(args, skt_id);
    args = int_to_stream(args, 1);

    len = hci_pkg_cmd(HCI_CMND_LISTEN, buf, SOCKET_LISTEN_PARAMS_LEN);
    *opcode = HCI_CMND_LISTEN;
    return len;
}

/*---------------------------------------------------------------------------
 hci_pkg_skt_accept
 ---------------------------------------------------------------------------*/
int hci_pkg_skt_accept(int *opcode)
{
    unsigned char *buf, *args;
    int len;

    buf = tiwisl_tx_buf;
    args = (unsigned char *)(buf + HEADERS_SIZE_CMD);
    args = int_to_stream(args, skt_id);

    len = hci_pkg_cmd(HCI_CMND_ACCEPT, buf, SOCKET_ACCEPT_PARAMS_LEN);
    *opcode = HCI_CMND_ACCEPT;
    return len;
}

/*---------------------------------------------------------------------------
 hci_pkg_skt_recv
 ---------------------------------------------------------------------------*/
int hci_pkg_skt_recv(int *opcode)
{
    unsigned char *buf, *args;
    int len;

    buf = tiwisl_tx_buf;
    args = (unsigned char *)(buf + HEADERS_SIZE_CMD);
    args = int_to_stream(args, skt_accept_status);
    args = int_to_stream(args, 1200);
    args = int_to_stream(args, 0);

    len = hci_pkg_cmd(HCI_CMND_RECV, buf, SOCKET_RECV_FROM_PARAMS_LEN);
    *opcode = HCI_CMND_RECV;
    return len;
}

/*---------------------------------------------------------------------------
 hci_pkg_skt_send
 ---------------------------------------------------------------------------*/
int hci_pkg_skt_send(int dlen, int *opcode)
{
    unsigned char *buf, *args;
    int len;

    buf = tiwisl_tx_buf;
    args = (unsigned char *)(buf + HEADERS_SIZE_DATA);
    args = int_to_stream(args, skt_accept_status);
    args = int_to_stream(args, HCI_CMND_SEND_ARG_LENGTH - sizeof(skt_accept_status));
    args = int_to_stream(args, dlen);
    args = int_to_stream(args, 0);

    len = hci_pkg_data(HCI_CMND_SEND, buf, HCI_CMND_SEND_ARG_LENGTH, dlen);
    *opcode = 0;
    return len;
}

/*---------------------------------------------------------------------------
 hci_pkg_skt_close
 ---------------------------------------------------------------------------*/
int hci_pkg_skt_close(int sd, int *opcode)
{
    unsigned char *buf, *args;
    int len;

    buf = tiwisl_tx_buf;
    args = (unsigned char *)(buf + HEADERS_SIZE_CMD);
    args = int_to_stream(args, sd);
    len = hci_pkg_cmd(HCI_CMND_CLOSE_SOCKET, buf, SOCKET_CLOSE_PARAMS_LEN);
    *opcode = HCI_CMND_CLOSE_SOCKET;
    return len;
}

/*==========================================================================*/
