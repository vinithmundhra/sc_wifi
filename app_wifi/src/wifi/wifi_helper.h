#ifndef _hci_helper_h_
#define _hci_helper_h_

#include <xccompat.h>
#include "wifi_structs.h"

#define SPI_HEADER_SIZE          (5)
#define HEADERS_SIZE_DATA        (SPI_HEADER_SIZE + 5)
#define HCI_CMND_SEND_ARG_LENGTH (16)
#define HCI_SEND_DATA_OFFSET     (HEADERS_SIZE_DATA + HCI_CMND_SEND_ARG_LENGTH)

int pkg_cmd_connect(REFERENCE_PARAM(unsigned char, data),
                    REFERENCE_PARAM(wifi_ap_config_t, config));

int hci_pkg_skt_send(REFERENCE_PARAM(unsigned char, data), int dlen, int sd);

#endif // _hci_helper_h_
