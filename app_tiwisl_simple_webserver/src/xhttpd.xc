#include "xhttpd.h"
#include "httpd.h"
#include "wifi_tiwisl_server.h"
#include <print.h>


/* SSID as advertized by your wireless router */
#define WIFI_SSID           "Xmos 2"

/* Password (if any) to connect to your wireless router */
#define WIFI_PASSWORD       "xmoschennai0115"

/*
 * Security type of your wireless router
 * If its unsecured (no password or open): TIWISL_SEC_TYPE_UNSEC
 * If its WEP: TIWISL_SEC_TYPE_WEP
 * If its WPA: TIWISL_SEC_TYPE_WPA
 * If its WPA2: TIWISL_SEC_TYPE_WPA2
 */
#define WIFI_SECURITY_TYPE  TIWISL_SEC_TYPE_WPA2


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
