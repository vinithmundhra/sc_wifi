#ifndef _HTTPD_H_
#define _HTTPD_H_

#include "xtcp_client.h"

/*==========================================================================*/
/**
 *  Connect to an access point defined in ``wifi_tiwisl_conf.h`` as WIFI_SSID
 *  with password as WIFI_PASSWORD and start listening on port 80.
 *
 *  \param tcp_svr    channel
 *  \param ap_config  wireless access point ssid/key/security type
 *  \return None
 **/
void httpd_init(chanend tcp_svr,
                REFERENCE_PARAM(wifi_ap_config_t, ap_config));

/*==========================================================================*/
/**
 *  Handle events from the Wi-Fi component
 *
 *  \param tcp_svr    channel to Wi-Fi TiWi-SL component
 *  \param conn       associated connection
 *  \return None
 **/
void httpd_handle_event(chanend tcp_svr,
                        REFERENCE_PARAM(xtcp_connection_t, conn));

#endif // _HTTPD_H_
