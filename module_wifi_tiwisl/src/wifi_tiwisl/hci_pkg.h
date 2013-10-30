#ifndef _HCI_PKG_H_
#define _HCI_PKG_H_

#include <xccompat.h>
#include "xtcp_client.h"

#define SPI_HEADER_SIZE                                 (5)
#define HEADERS_SIZE_DATA                               (SPI_HEADER_SIZE + 5)
#define HCI_CMND_SEND_ARG_LENGTH                        (16)
#define HCI_SEND_DATA_OFFSET                            (HEADERS_SIZE_DATA + HCI_CMND_SEND_ARG_LENGTH)

/*==========================================================================*/
/**
 *  hci_pkg_wifi_on
 *
 *  \param opcode  opcode to check in the response
 *  \return int    length
 **/
int hci_pkg_wifi_on(REFERENCE_PARAM(int, opcode));

/*==========================================================================*/
/**
 *  hci_pkg_read_buffer_size
 *
 *  \param opcode  opcode to check in the response
 *  \return int    length
 **/
int hci_pkg_read_buffer_size(REFERENCE_PARAM(int, opcode));

/*==========================================================================*/
/**
 *  hci_pkg_set_event_mask
 *
 *  \param mask    the event mask
 *  \param opcode  opcode to check in the response
 *  \return int    length
 **/
int hci_pkg_set_event_mask(int mask, REFERENCE_PARAM(int, opcode));

/*==========================================================================*/
/**
 *  hci_pkg_wlan_connect
 *
 *  \param ap_config  the access point configuration
 *  \param opcode     opcode to check in the response
 *  \return int       length
 **/
int hci_pkg_wlan_connect(REFERENCE_PARAM(wifi_ap_config_t, ap_config),
                         REFERENCE_PARAM(int, opcode));

/*==========================================================================*/
/**
 *  hci_pkg_wlan_set_connection_policy
 *
 *  \param should_connect_to_open_ap
 *  \param should_use_fast_connect
 *  \param use_profiles
 *  \param opcode  opcode to check in the response
 *  \return int    length
 **/
int hci_pkg_wlan_set_connection_policy(unsigned int should_connect_to_open_ap,
                                       unsigned int should_use_fast_connect,
                                       unsigned int use_profiles,
                                       REFERENCE_PARAM(int, opcode));

/*==========================================================================*/
/**
 *  hci_pkg_wlan_scan
 *
 *  \param opcode  opcode to check in the response
 *  \param enable  1 = enable scan; 0 = disable scan
 *  \return int    length
 **/
int hci_pkg_wlan_scan(REFERENCE_PARAM(int, opcode), int enable);

/*==========================================================================*/
/**
 *  hci_pkg_wlan_get_scan_result
 *
 *  \param opcode  opcode to check in the response
 *  \return int    length
 **/
int hci_pkg_wlan_get_scan_result(REFERENCE_PARAM(int, opcode));

/*==========================================================================*/
/**
 *  hci_pkg_skt_create
 *
 *  \param opcode  opcode to check in the response
 *  \return int    length
 **/
int hci_pkg_skt_create(REFERENCE_PARAM(int, opcode));

/*==========================================================================*/
/**
 *  hci_pkg_skt_bind
 *
 *  \param opcode  opcode to check in the response
 *  \return int    length
 **/
int hci_pkg_skt_bind(REFERENCE_PARAM(int, opcode));

/*==========================================================================*/
/**
 *  hci_pkg_skt_listen
 *
 *  \param opcode  opcode to check in the response
 *  \return int    length
 **/
int hci_pkg_skt_listen(REFERENCE_PARAM(int, opcode));

/*==========================================================================*/
/**
 *  hci_pkg_skt_accept
 *
 *  \param opcode  opcode to check in the response
 *  \return int    length
 **/
int hci_pkg_skt_accept(REFERENCE_PARAM(int, opcode));

/*==========================================================================*/
/**
 *  hci_pkg_skt_recv
 *
 *  \param opcode  opcode to check in the response
 *  \return int    length
 **/
int hci_pkg_skt_recv(REFERENCE_PARAM(int, opcode));

/*==========================================================================*/
/**
 *  hci_pkg_skt_send
 *
 *  \param dlen    length of data to send
 *  \param opcode  opcode to check in the response
 *  \return int    length
 **/
int hci_pkg_skt_send(int dlen, REFERENCE_PARAM(int, opcode));

/*==========================================================================*/
/**
 *  hci_pkg_skt_close
 *
 *  \param sd      socket descriptor
 *  \param opcode  opcode to check in the response
 *  \return int    length
 **/
int hci_pkg_skt_close(int sd, REFERENCE_PARAM(int, opcode));

/*==========================================================================*/
/**
 *  hci_pkg_skt_setopt_recv_nblock
 *
 *  \param opcode  opcode to check in the response
 *  \param sd      socket descriptor
 *  \return int    length
 **/
int hci_pkg_skt_setopt_recv_nblock(REFERENCE_PARAM(int, opcode), int sd);

#endif // _HCI_PKG_H_
