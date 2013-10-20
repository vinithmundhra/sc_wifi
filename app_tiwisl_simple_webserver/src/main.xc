#include <platform.h>
#include "wifi_tiwisl_server.h"
#include "xhttpd.h"
#include <print.h>
#include <xscope.h>

on stdcore[0]: spi_master_interface tiwisl_spi =
{
  XS1_CLKBLK_1,
  XS1_CLKBLK_2,
  XS1_PORT_1K, // MOSI
  XS1_PORT_1J, // CLK
  XS1_PORT_1I, // MISO
};

on stdcore[0]: wifi_tiwisl_ctrl_ports_t tiwisl_ctrl =
{
  XS1_PORT_4E, // nCS - Bit0, Power enable - Bit1
  XS1_PORT_1L, // nIRQ
};

void xscope_user_init(void)
{
  xscope_register(0, 0, "", 0, "");
  xscope_config_io(XSCOPE_IO_BASIC);
}

/*---------------------------------------------------------------------------
 Main entry point
 ---------------------------------------------------------------------------*/
int main(void)
{
  chan c_wifi;
    par
    {
        // The main Wi-Fi server
    on stdcore[0]: wifi_tiwisl_server(c_wifi, tiwisl_spi, tiwisl_ctrl);
        // The webserver
    on stdcore[0]: xhttpd(c_wifi);
    }
    return 0;
}
