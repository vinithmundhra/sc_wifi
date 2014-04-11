#ifndef _hci_helper_h_
#define _hci_helper_h_

#include <xccompat.h>
#include "wifi_structs.h"

int pkg_cmd_connect(REFERENCE_PARAM(unsigned char, data),
                    REFERENCE_PARAM(wifi_ap_config_t, config));

int event_checker(REFERENCE_PARAM(unsigned char, data),
                  int opcode,
                  REFERENCE_PARAM(int, opc));

void get_ipconfig(REFERENCE_PARAM(wifi_ipconfig_t, config));

#endif // _hci_helper_h_
