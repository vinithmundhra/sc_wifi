#ifndef _webserver_h_
#define _webserver_h_

#include <xccompat.h>
#include "wifi_tiwisl.h"

void webserver(REFERENCE_PARAM(wifi_tiwisl_ports_t, p_wifi),
               REFERENCE_PARAM(wifi_ap_config_t, wifi_ap_config));

#endif //_webserver_h_
