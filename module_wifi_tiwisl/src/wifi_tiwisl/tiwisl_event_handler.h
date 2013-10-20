#ifndef _TIWISL_EVENT_HANDLER_H_
#define _TIWISL_EVENT_HANDLER_H_

#include <xccompat.h>
#include "xtcp_client.h"
#include "hci_defines.h"

/*==========================================================================*/
/**
 *  Check if the received event matches the opcode supplied
 *
 *  \param opcode  event opcode
 *  \param rx_buf  pointer to the response buffer
 *  \return 1 on event match. 0 on event mismatch.
 **/
int event_checker(int opcode, REFERENCE_PARAM(unsigned char, rx_buf));

/*==========================================================================*/
/**
 *  Process wlan connect event
 *
 *  \param ipconfig  pointer to ipconfig
 *  \return None
 **/
void hci_process_wlan_connect(REFERENCE_PARAM(xtcp_ipconfig_t, ipconfig));

/*==========================================================================*/
/**
 *  Process scan event
 *
 *  \return int
 **/
void hci_process_wlan_scan();

/*==========================================================================*/
/**
 *  Process get scan results
 *
 *  \return int
 **/
int hci_process_wlan_get_scan_result();

/*==========================================================================*/
/**
 *  Process socket create event
 *
 *  \return int
 **/
int hci_process_skt_create();

/*==========================================================================*/
/**
 *  Process socket accept event
 *
 *  \return int
 **/
int hci_process_skt_accept();

/*==========================================================================*/
/**
 *  Process socket receive event
 *
 *  \return int
 **/
int hci_process_skt_recv();

/*==========================================================================*/
/**
 *  Process received data event
 *
 *  \return int
 **/
int hci_process_recv_data();

/*==========================================================================*/
/**
 *  Process set socket event
 *
 *  \return int
 **/
int hci_process_setsockopt();

#endif // _TIWISL_EVENT_HANDLER_H_
