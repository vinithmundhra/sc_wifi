#include "xhttpd.h"
#include "httpd.h"
#include "wifi_tiwisl_server.h"
#include <print.h>
#include "wifi_tiwisl_conf.h"

// Wireless access point config: SSID, Key, Security Type
wifi_ap_config_t ap_config = {WIFI_SSID, WIFI_PASSWORD, WIFI_SECURITY_TYPE};

/*---------------------------------------------------------------------------
 The main webserver thread
 ---------------------------------------------------------------------------*/
// ::webserver
void xhttpd(chanend c_wifi)
{
  xtcp_connection_t conn;
  printstrln("**WELCOME TO THE SIMPLE WEBSERVER DEMO**");
  // Start the Wi-Fi module
  xtcp_wifi_on(c_wifi);
  // Initiate the HTTP state
  httpd_init(c_wifi, ap_config);

  while(1)
  {
    select
    {
      case xtcp_event(c_wifi, conn):
      {
        httpd_handle_event(c_wifi, conn);
        break;
      } // case xtcp_event(c_wifi, conn):
    } // select
  } // while(1)
}
