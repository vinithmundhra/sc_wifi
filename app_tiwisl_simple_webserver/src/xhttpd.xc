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

#include <xs1.h>
#include <print.h>
#include "httpd.h"
#include "wifi_tiwisl_server.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/
// Wireless access point config: SSID, Key, Security Type
wifi_ap_config_t ap_config = {"xms6testap0", "", TIWISL_SEC_TYPE_UNSEC};

/*---------------------------------------------------------------------------
 static prototypes
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 The main webserver thread
 ---------------------------------------------------------------------------*/
void xhttpd(chanend tcp_svr)
{
    xtcp_connection_t conn;

    printstrln("**WELCOME TO THE SIMPLE WEBSERVER DEMO**");

    // Start the Wi-Fi module
    xtcp_wifi_on(tcp_svr);

    // Initiate the HTTP state
    httpd_init(tcp_svr, ap_config);

    // Loop forever processing TCP events
    while(1)
    {
        select
        {
            case xtcp_event(tcp_svr, conn):
            {
                httpd_handle_event(tcp_svr, conn);
                break;
            } // case xtcp_event(tcp_svr, conn):
        } // select
    } // while(1)
}

/*==========================================================================*/
