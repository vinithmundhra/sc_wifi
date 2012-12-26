// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Info
 ----
 
 ===========================================================================*/

#ifndef _event_handler_h_
#define _event_handler_h_

/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/
#include <xccompat.h>
#include "xtcp_client.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 extern variables
 ---------------------------------------------------------------------------*/
 
/*---------------------------------------------------------------------------
 prototypes
 ---------------------------------------------------------------------------*/

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
 *  Process socket create event
 *
 *  \return int
 **/
int hci_process_skt_create();

/*==========================================================================*/
/**
 *  Process socket bind event
 *
 *  \return int
 **/
int hci_process_skt_bind();

/*==========================================================================*/
/**
 *  Process socket listen event
 *
 *  \return int
 **/
int hci_process_skt_listen();

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

#endif // _event_handler_h_
/*==========================================================================*/
