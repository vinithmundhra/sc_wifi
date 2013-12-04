#include "xtcp_client.h"
#include <xs1.h>
#include <xccompat.h>
#include "xtcp_cmd.h"

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

//=============================================================================
void xtcp_listen(chanend c_xtcp, int port_number, xtcp_protocol_t p)
{
  send_cmd(c_xtcp, XTCP_CMD_LISTEN, 0);
  master
  {
    c_xtcp <: port_number;
    c_xtcp <: p;
  }
}

//=============================================================================
void xtcp_connect(chanend c_xtcp, wifi_ap_config_t &ap_config)
{
  send_cmd(c_xtcp, XTCP_CMD_CONNECT, 0);
  master
  {
    c_xtcp <: ap_config;
  }
  c_xtcp :> int _;
}

//=============================================================================
void xtcp_disconnect(chanend c_xtcp)
{
  send_cmd(c_xtcp, XTCP_CMD_DISCONNECT, 0);
}

//=============================================================================
void xtcp_wifi_on(chanend c_xtcp)
{
  send_cmd(c_xtcp, XTCP_CMD_WIFI_ON, 0);
  slave
  {
    // Notified that the Wi-FI module is switched ON.
    c_xtcp :> int _;
  }
}

//=============================================================================
void xtcp_wifi_off(chanend c_xtcp)
{
  send_cmd(c_xtcp, XTCP_CMD_WIFI_OFF, 0);
}

//=============================================================================
#pragma unsafe arrays
transaction xtcp_event(chanend c_xtcp, xtcp_connection_t &conn)
{
  for(int i = 0; i < sizeof(conn) >> 2; i++)
  {
    c_xtcp :> (conn,unsigned int[])[i];
  }
}

//=============================================================================
void do_xtcp_event(chanend c_xtcp, xtcp_connection_t &conn)
{
  slave
  {
    xtcp_event(c_xtcp, conn);
  }
}

//=============================================================================
void xtcp_init_send(chanend c_xtcp, REFERENCE_PARAM(xtcp_connection_t, conn))
{
  send_cmd(c_xtcp, XTCP_CMD_INIT_SEND, conn.id);
}

//=============================================================================
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

//=============================================================================
void xtcp_close(chanend c_xtcp, REFERENCE_PARAM(xtcp_connection_t, conn))
{
  send_cmd(c_xtcp, XTCP_CMD_CLOSE, conn.id);
}

//=============================================================================
void xtcp_abort(chanend c_xtcp, REFERENCE_PARAM(xtcp_connection_t, conn))
{
  send_cmd(c_xtcp, XTCP_CMD_ABORT, conn.id);
}

//=============================================================================
int xtcp_recv(chanend c_xtcp, unsigned char data[])
{
  int len;
  slave
  {
    c_xtcp :> len;
    for(int i = 0; i < len; i++) c_xtcp :> data[i];
  }
  return len;
}

//=============================================================================
void xtcp_send(chanend c_xtcp, unsigned char data[], int len)
{
  slave
  {
    c_xtcp <: len;
    for(int i = 0; i < len; i++) c_xtcp <: data[i];
  }
}

//=============================================================================
void xtcp_complete_send(chanend c_xtcp)
{
  char dummy_data[1];
  xtcp_send(c_xtcp, dummy_data, 0);
}

//=============================================================================
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
