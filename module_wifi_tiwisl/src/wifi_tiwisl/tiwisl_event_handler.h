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
 *  Event Handler
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
int event_checker(int opcode, REFERENCE_PARAM(unsigned char, rx_buf));

/*==========================================================================*/
/**
 *  Event Handler
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
void hci_process_wlan_connect(REFERENCE_PARAM(xtcp_ipconfig_t, ipconfig));

/*==========================================================================*/
/**
 *  Event Handler
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
int hci_process_skt_create();

/*==========================================================================*/
/**
 *  Event Handler
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
int hci_process_skt_bind();

/*==========================================================================*/
/**
 *  Event Handler
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
int hci_process_skt_listen();

/*==========================================================================*/
/**
 *  Event Handler
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
int hci_process_skt_accept();

/*==========================================================================*/
/**
 *  Event Handler
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
int hci_process_skt_recv();

/*==========================================================================*/
/**
 *  Event Handler
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
int hci_process_recv_data();

/*==========================================================================*/
/**
 *  Event Handler
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/

/*==========================================================================*/
/**
 *  Event Handler
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/


#endif // _event_handler_h_
/*==========================================================================*/
