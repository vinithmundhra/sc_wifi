#include <platform.h>
#include <xs1.h>
#include <print.h>
#include <xscope.h>
#include "webclient.h"
#include "ethernet_board_support.h"
#include "xtcp.h"


on ETHERNET_DEFAULT_TILE: ethernet_xtcp_ports_t xtcp_ports = {
  OTP_PORTS_INITIALIZER,
  ETHERNET_DEFAULT_SMI_INIT,
  ETHERNET_DEFAULT_MII_INIT_lite,
  ETHERNET_DEFAULT_RESET_INTERFACE_INIT
};

xtcp_ipconfig_t client_ipconfig = {
  {0, 0, 0, 0},
  {0, 0, 0, 0},
  {0, 0, 0, 0}
};

server_config_t server_config = {
  {172, 17, 0, 196},
  80,
  80
};

// Present send data length = 128 bytes
char ws_data[135] = "abcdefghijklmnopqrstuvwxyz\nABCDEFGHIJKLMNOPQRSTUVWXYZ\n0123456789!@#$%^&*()`-=~_+\n2345678901234567890...,,,...,,,...,,,...,,,####";
char ws_data_rx[135];

static int send_count = 0;

/*
 * DELAY x 10 ns
 * ------------------------------
 * 1000000 x 10 ns = 10 ms
 * 100000  x 10 ns = 1 ms
 * 10000   x 10 ns = 0.1 ms
 */
#define DELAY 1000000

void webclient_pkt_gen(chanend c_xtcp)
{
  timer tmr;
  int sys_start_time;

  // Set webserver paramters
  webclient_set_server_config(server_config);
  // Init web client
  webclient_init(c_xtcp);
  // Connect to webserver
  webclient_connect_to_server(c_xtcp);
  // Get the time
  tmr :> sys_start_time;

  printstrln("Connected to webserver. Sending data...");

  while(1)
  {
    select
    {
      case tmr when timerafter(sys_start_time) :> sys_start_time:
      {
        // Send notification to begin recording sensor data
        webclient_send_data(c_xtcp, ws_data);
        printintln(send_count);
        send_count++;
        sys_start_time += DELAY;
        break;
      } //case timer
    } //select
  } //while(1)
}

void xscope_user_init(void)
{
  xscope_register(0, 0, "", 0, "");
  xscope_config_io(XSCOPE_IO_BASIC);
}

/*---------------------------------------------------------------------------
 main
 ---------------------------------------------------------------------------*/
int main(void)
{
  chan c_xtcp[1];

  par
  {
    on ETHERNET_DEFAULT_TILE: ethernet_xtcp_server(xtcp_ports, client_ipconfig, c_xtcp, 1);
    on tile[1]: webclient_pkt_gen(c_xtcp[0]);
  }
  return 0;
}
