#include <xs1.h>
#include <platform.h>
#include <xscope.h>
#include "wifi_tiwisl.h"
#include "webserver.h"

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
  "ssid",
  "pwd",
  TIWISL_SEC_TYPE_WPA2
};

void xscope_user_init(void) {
  xscope_register(0);
  xscope_config_io(XSCOPE_IO_BASIC);
}

int main()
{
  par
  {
    on tile[0]: webserver(p_wifi, config);
  }
  return 0;
}
