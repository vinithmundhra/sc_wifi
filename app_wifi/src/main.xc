#include <xs1.h>
#include <platform.h>
#include "wifi_tiwisl.h"
#include <xscope.h>
#include <print.h>
#include <timer.h>

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

static wifi_state_t wifi_state;
static int hss, dummy;
static unsigned char data[1000];

void xscope_user_init(void) {
  xscope_register(0);
  xscope_config_io(XSCOPE_IO_BASIC);
}

static int wifi_server_init(wifi_tiwisl_ports_t &p)
{
  wifi_state = wifi_socket_create(p, SOCK_STREAM, WIFI_PROTOCOL_TCP, hss);
  if(hss == -1)
  {
    wifi_stop(p);
    return -1;
  }
  while(wifi_socket_bind(p, 80, dummy) != WIFI_OK) {}
  while(wifi_socket_listen(p, dummy) != WIFI_OK) {}
  return 0;
}

void myapp()
{
  int cr, data_len;

  printstrln("started...");
  wifi_start(p_wifi);
  printstrln("connecting...");
  wifi_connect(p_wifi, config);
  wifi_server_init(p_wifi);

  while(1)
  {
    wifi_state = wifi_socket_accept(p_wifi, cr);

    if(cr == -1 || cr == -2)
    {
      delay_milliseconds(500);
    }

    else if(cr == -57)
    {
      wifi_state = wifi_socket_close(p_wifi, hss, dummy);
      printstrln("socket closed...");
      wifi_server_init(p_wifi);
      delay_milliseconds(500);
    }

    else
    {
      printstr("accept... "); printintln(cr);
      wifi_state = wifi_recv(p_wifi, cr, data, data_len);
      for(int i = 0; i < data_len; i++) printchar(data[i]);
      printstrln(" ");
      wifi_state = wifi_socket_close(p_wifi, cr, dummy);
      delay_milliseconds(500);
    }
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
