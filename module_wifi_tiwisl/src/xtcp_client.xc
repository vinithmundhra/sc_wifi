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
#include <xccompat.h>
#include "xtcp_client.h"
#include "xtcp_cmd.h"

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

/*---------------------------------------------------------------------------
 static prototypes
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/

/** \brief Send command over the XTCP channel
 *
 * \param c        chanend connected to the xtcp server
 * \param cmd      Command to send
 * \param conn_id  connection ID
 */
static void send_cmd(chanend c_xtcp, xtcp_cmd_t cmd, int conn_id)
{
    c_xtcp <: cmd;
    c_xtcp <: conn_id;
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void xtcp_listen(chanend c_xtcp, int port_number, xtcp_protocol_t p)
{
    send_cmd(c_xtcp, XTCP_CMD_LISTEN, 0);
    master
    {
        c_xtcp <: port_number;
        c_xtcp <: p;
    }
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void xtcp_unlisten(chanend c_xtcp, int port_number)
{
    send_cmd(c_xtcp, XTCP_CMD_UNLISTEN, 0);
    master
    {
        c_xtcp <: port_number;
    }
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void xtcp_connect(chanend c_xtcp, wifi_ap_config_t &ap_config)
{
    send_cmd(c_xtcp, XTCP_CMD_CONNECT, 0);
    master
    {
        c_xtcp <: ap_config;
    }
    c_xtcp :> int _;
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void xtcp_disconnect(chanend c_xtcp)
{
    send_cmd(c_xtcp, XTCP_CMD_DISCONNECT, 0);
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void xtcp_wifi_on(chanend c_xtcp)
{
    send_cmd(c_xtcp, XTCP_CMD_WIFI_ON, 0);
    slave
    {
        // Notified that the Wi-FI module is switched ON (as it takes some time to init).
        c_xtcp :> int _;
    }
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void xtcp_wifi_off(chanend c_xtcp)
{
    send_cmd(c_xtcp, XTCP_CMD_WIFI_OFF, 0);
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void xtcp_bind_local(chanend c_xtcp, xtcp_connection_t &conn, int port_number)
{
    send_cmd(c_xtcp, XTCP_CMD_BIND_LOCAL, conn.id);
    master
    {
        c_xtcp <: port_number;
    }
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void xtcp_bind_remote(chanend c_xtcp,
                      xtcp_connection_t &conn,
                      xtcp_ipaddr_t addr,
                      int port_number)
{
    send_cmd(c_xtcp, XTCP_CMD_BIND_REMOTE, conn.id);
    master
    {
        for (int i = 0; i < 4; i++)
            c_xtcp <: addr[i];
        c_xtcp <: port_number;
    }
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
#pragma unsafe arrays
transaction xtcp_event(chanend c_xtcp, xtcp_connection_t &conn)
{
    for (int i = 0; i < sizeof(conn) >> 2; i++)
    {
        c_xtcp :> (conn,unsigned int[])[i];
    }
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void do_xtcp_event(chanend c_xtcp, xtcp_connection_t &conn)
{
    slave
    {
        xtcp_event(c_xtcp, conn);
    }
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void xtcp_init_send(chanend c_xtcp, REFERENCE_PARAM(xtcp_connection_t, conn))
{
    send_cmd(c_xtcp, XTCP_CMD_INIT_SEND, conn.id);
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void xtcp_set_connection_appstate(chanend c_xtcp,
                                  REFERENCE_PARAM(xtcp_connection_t, conn),
                                  xtcp_appstate_t appstate)
{
    send_cmd(c_xtcp, XTCP_CMD_SET_APPSTATE, conn.id);
    master
    {
        c_xtcp <: appstate;
    }
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void xtcp_close(chanend c_xtcp, REFERENCE_PARAM(xtcp_connection_t, conn))
{
    send_cmd(c_xtcp, XTCP_CMD_CLOSE, conn.id);
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void xtcp_abort(chanend c_xtcp, REFERENCE_PARAM(xtcp_connection_t, conn))
{
    send_cmd(c_xtcp, XTCP_CMD_ABORT, conn.id);
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
int xtcp_recv(chanend c_xtcp, unsigned char data[])
{
    int len;
    slave
    {
        //c_xtcp <: 1;
        c_xtcp :> len;
        for (int i = 0; i < len; i++)
            c_xtcp :> data[i];
    }
    return len;
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void xtcp_send(chanend c_xtcp, unsigned char ?data[], int len)
{
    slave
    {
        c_xtcp <: len;
        for (int i = 0; i < len; i++)
            c_xtcp <: data[i];
    }
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void xtcp_uint_to_ipaddr(xtcp_ipaddr_t ipaddr, unsigned int i)
{
    ipaddr[0] = i & 0xff;
    i >>= 8;
    ipaddr[1] = i & 0xff;
    i >>= 8;
    ipaddr[2] = i & 0xff;
    i >>= 8;
    ipaddr[3] = i & 0xff;
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void xtcp_get_ipconfig(chanend c_xtcp, xtcp_ipconfig_t &ipconfig)
{
    send_cmd(c_xtcp, XTCP_CMD_GET_IPCONFIG, 0);
    slave
    {
        c_xtcp :> ipconfig.ipaddr[0];
        c_xtcp :> ipconfig.ipaddr[1];
        c_xtcp :> ipconfig.ipaddr[2];
        c_xtcp :> ipconfig.ipaddr[3];
        c_xtcp :> ipconfig.netmask[0];
        c_xtcp :> ipconfig.netmask[1];
        c_xtcp :> ipconfig.netmask[2];
        c_xtcp :> ipconfig.netmask[3];
        c_xtcp :> ipconfig.gateway[0];
        c_xtcp :> ipconfig.gateway[1];
        c_xtcp :> ipconfig.gateway[2];
        c_xtcp :> ipconfig.gateway[3];
    }
}

/*==========================================================================*/
