// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Info
 ----
 
 ===========================================================================*/

#ifndef _hci_defines_h_
#define _hci_defines_h_

/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define HCI_TYPE_CMND               (0x1)
#define HCI_TYPE_DATA               (0x2)
#define HCI_TYPE_EVNT               (0x4)

#define HCI_DATA_HEADER_SIZE        (5)
#define HCI_EVENT_HEADER_SIZE       (5)
#define HCI_PACKET_ARGSIZE_OFFSET   (2)
#define HCI_EVENT_OPCODE_OFFSET     (1)

//*****************************************************************************
// Values that can be used as HCI Commands and HCI Packet header defines
//*****************************************************************************
#define HCI_CMND_SOCKET_BASE   0x1000
#define HCI_CMND_SOCKET        0x1001
#define HCI_CMND_BIND          0x1002
#define HCI_CMND_RECV          0x1004
#define HCI_CMND_ACCEPT        0x1005
#define HCI_CMND_LISTEN        0x1006
#define HCI_CMND_CONNECT       0x1007
#define HCI_CMND_CLOSE_SOCKET  0x100B
#define HCI_CMND_RECVFROM      0x100D

#define HCI_CMND_SEND           (0x81)

#define HCI_CMND_READ_SP_VERSION  	(0x0207)
#define HCI_CMND_READ_BUFFER_SIZE   (0x400B)
#define HCI_CMND_SIMPLE_LINK_START  (0x4000)

#define HCI_CMND_WLAN_IOCTL_SET_SCANPARAM     0x0003
#define HCI_CMND_WLAN_IOCTL_GET_SCAN_RESULTS  0x0007

//*****************************************************************************
// Values that can be used as HCI Events defines
//*****************************************************************************
#define HCI_EVNT_WLAN_BASE              0x0000
#define HCI_EVNT_WLAN_CONNECT           0x0001
#define HCI_EVNT_WLAN_DISCONNECT        0x0002
#define HCI_EVNT_WLAN_IOCTL_ADD_PROFILE 0x0005
#define HCI_EVNT_SOCKET                 HCI_CMND_SOCKET
#define HCI_EVNT_BIND                   HCI_CMND_BIND
#define HCI_EVNT_RECV                   HCI_CMND_RECV
#define HCI_EVNT_ACCEPT                 HCI_CMND_ACCEPT
#define HCI_EVNT_LISTEN                 HCI_CMND_LISTEN
#define HCI_EVNT_CONNECT                HCI_CMND_CONNECT
#define HCI_EVNT_SELECT                 HCI_CMND_BSD_SELECT
#define HCI_EVNT_CLOSE_SOCKET           HCI_CMND_CLOSE_SOCKET
#define HCI_EVNT_RECVFROM               HCI_CMND_RECVFROM
#define HCI_EVNT_SETSOCKOPT             HCI_CMND_SETSOCKOPT
#define HCI_EVNT_GETSOCKOPT             HCI_CMND_GETSOCKOPT
#define HCI_EVNT_BSD_GETHOSTBYNAME      HCI_CMND_GETHOSTNAME
#define HCI_EVNT_SEND                   0x1003
#define HCI_EVNT_WRITE                  0x100E
#define HCI_EVNT_SENDTO                 0x100F
#define HCI_EVNT_PATCHES_REQ            0x1000
#define HCI_EVNT_UNSOL_BASE             0x4000

#define HCI_EVNT_WLAN_UNSOL_BASE                0x8000
#define HCI_EVNT_WLAN_UNSOL_CONNECT  	        (0x0001 + HCI_EVNT_WLAN_UNSOL_BASE)
#define HCI_EVNT_WLAN_UNSOL_DISCONNECT          (0x0002 + HCI_EVNT_WLAN_UNSOL_BASE)
#define HCI_EVNT_WLAN_UNSOL_INIT                (0x0004 + HCI_EVNT_WLAN_UNSOL_BASE)
#define HCI_EVNT_WLAN_TX_COMPLETE               (0x0008 + HCI_EVNT_WLAN_UNSOL_BASE)
#define HCI_EVNT_WLAN_UNSOL_DHCP                (0x0010 + HCI_EVNT_WLAN_UNSOL_BASE)
#define HCI_EVNT_WLAN_ASYNC_PING_REPORT         (0x0040 + HCI_EVNT_WLAN_UNSOL_BASE)
#define HCI_EVNT_WLAN_ASYNC_SIMPLE_CONFIG_DONE  (0x0080 + HCI_EVNT_WLAN_UNSOL_BASE)
#define HCI_EVNT_WLAN_KEEPALIVE			        (0x0200  + HCI_EVNT_WLAN_UNSOL_BASE)

#define HCI_EVNT_DATA_UNSOL_FREE_BUFF   0x4100
#define HCI_EVNT_NVMEM_CREATE_ENTRY     HCI_CMND_NVMEM_CREATE_ENTRY
#define HCI_EVNT_NVMEM_SWAP_ENTRY       HCI_CMND_NVMEM_SWAP_ENTRY
#define HCI_EVNT_NVMEM_READ             HCI_CMND_NVMEM_READ
#define HCI_EVNT_NVMEM_WRITE            0x0202
#define HCI_EVNT_READ_SP_VERSION        HCI_CMND_READ_SP_VERSION
#define HCI_EVNT_INPROGRESS             0xFFFF
#define HCI_DATA_RECVFROM               0x84
#define HCI_DATA_RECV                   0x85
#define HCI_DATA_NVMEM                  0x91

//--------- Address Families --------
#define AF_INET                 2

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/
typedef struct sock_addr_t_
{
    unsigned short ifamily;
    unsigned short iport;
    unsigned int   iaddr;
    char           izero[8];
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

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 extern variables
 ---------------------------------------------------------------------------*/
 
/*---------------------------------------------------------------------------
 prototypes
 ---------------------------------------------------------------------------*/

#endif // _hci_defines_h_
/*==========================================================================*/
