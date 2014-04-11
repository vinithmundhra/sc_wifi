#include <xs1.h>
#include <platform.h>
#include "wifi_tiwisl.h"
#include <xscope.h>
#include <print.h>

#define TIWISL_POLL 10000

on tile[0]: wifi_tiwisl_ports_t p_wifi = {
  XS1_PORT_4E, // nCS - Bit0, Power enable - Bit1
  XS1_PORT_1L, // nIRQ
  {
    XS1_CLKBLK_1,
    XS1_CLKBLK_2,
    XS1_PORT_1K, // MOSI
    XS1_PORT_1J, // CLK
    XS1_PORT_1I, // MISO
  }
};

wifi_ap_config_t config = {
  "Xmos 2",
  "xmoschennai0115",
  TIWISL_SEC_TYPE_WPA2
};

static int hss;

void xscope_user_init(void) {
  xscope_register(0);
  xscope_config_io(XSCOPE_IO_BASIC);
}

static int wifi_server_init(wifi_tiwisl_ports_t &p)
{
  hss = wifi_socket_create(p, SOCK_STREAM, WIFI_PROTOCOL_TCP);

  if(hss == -1)
  {
    wifi_stop(p);
    return -1;
  }

  while(wifi_socket_bind(p, 80) != WIFI_OK) {}
  while(wifi_socket_listen(p) != WIFI_OK) {}
  return 0;
}

void myapp()
{
  int bytes_rx = 0;
  timer t;
  unsigned time;
  int cr;

  wifi_start(p_wifi);
  wifi_connect(p_wifi, config);
  wifi_server_init(p_wifi);

  t :> time;
  time += TIWISL_POLL;

  while(1)
  {
    select
    {
      case t when timerafter(time) :> time:
      {
        cr = wifi_socket_accept(p_wifi);

        if(cr == -1 || cr == -2) break;
        if(cr == -57)
        {
          wifi_socket_close(p_wifi, hss);
          wifi_server_init(p_wifi);
          break;
        }

        // do normal stuff


        time += TIWISL_POLL;
        break;
      }//case t when timerafter(time) :> void:
    }//select
  }
}

int main()
{
  par
  {
    on tile[0]: myapp();
  }
  return 0;
}
