#ifndef _wifi_tiwisl_h_
#define _wifi_tiwisl_h_

#include "wifi_ports.h"
#include "wifi_structs.h"

void wifi_start(REFERENCE_PARAM(wifi_tiwisl_ports_t, p_wifi));

void wifi_stop(REFERENCE_PARAM(wifi_tiwisl_ports_t, p_wifi));

int wifi_scan(REFERENCE_PARAM(wifi_tiwisl_ports_t, p_wifi));

void wifi_connect(REFERENCE_PARAM(wifi_tiwisl_ports_t, p_wifi), REFERENCE_PARAM(wifi_ap_config_t, config));

wifi_state_t wifi_socket_create(REFERENCE_PARAM(wifi_tiwisl_ports_t, p_wifi),
                                wifi_sock_type_t type,
                                wifi_protocol_t protocol,
                                REFERENCE_PARAM(int, skt_id));

wifi_state_t wifi_socket_bind(REFERENCE_PARAM(wifi_tiwisl_ports_t, p_wifi),
                              int p,
                              REFERENCE_PARAM(int, rtnval));

wifi_state_t wifi_socket_listen(REFERENCE_PARAM(wifi_tiwisl_ports_t, p_wifi),
                                REFERENCE_PARAM(int, rtnval));

wifi_state_t wifi_socket_accept(REFERENCE_PARAM(wifi_tiwisl_ports_t, p_wifi),
                                REFERENCE_PARAM(int, rtnval));

wifi_state_t wifi_socket_close(REFERENCE_PARAM(wifi_tiwisl_ports_t, p_wifi),
                               unsigned char sd,
                               REFERENCE_PARAM(int, rtnval));

wifi_state_t wifi_recv(REFERENCE_PARAM(wifi_tiwisl_ports_t, p_wifi),
                       unsigned char sd,
                       unsigned char wifi_data_rx[],
                       REFERENCE_PARAM(int, len));

int wifi_send(REFERENCE_PARAM(wifi_tiwisl_ports_t, p_wifi),
              unsigned char tx_buf[],
              int len,
              int skt);

#endif // _wifi_tiwisl_h_
