#ifndef _wifi_tiwisl_h_
#define _wifi_tiwisl_h_

#include "wifi_ports.h"
#include "wifi_structs.h"

/*==========================================================================*/
/**
 *  Start the LSR TiWi-SL module.
 *  \param[in]  p_wifi   Wi-Fi ports including IRQ, CS and SPI lines
 *  \param[out] none
 **/
void wifi_start(REFERENCE_PARAM(wifi_tiwisl_ports_t, p_wifi));

/*==========================================================================*/
/**
 *  Stop the LSR TiWi-SL module.
 *  \param[in]  p_wifi   Wi-Fi ports including IRQ, CS and SPI lines
 *  \param[out] none
 **/
void wifi_stop(REFERENCE_PARAM(wifi_tiwisl_ports_t, p_wifi));

/*==========================================================================*/
/**
 *  Connect to a wireless access point. For example: a wireless router.
 *  \param[in]  p_wifi   Wi-Fi ports including IRQ, CS and SPI lines
 *  \param[in]  config   SSID, Key and Security Type
 *  \param[out] none
 **/
void wifi_connect(REFERENCE_PARAM(wifi_tiwisl_ports_t, p_wifi),
                  REFERENCE_PARAM(wifi_ap_config_t, config));

/*==========================================================================*/
/**
 *  Create a socket.
 *  \param[in]  p_wifi   Wi-Fi ports including IRQ, CS and SPI lines
 *  \param[in]  type     Socket type
 *  \param[in]  protocol Protocol
 *  \param[out] int socket ID.
 **/
int wifi_socket(REFERENCE_PARAM(wifi_tiwisl_ports_t, p_wifi),
                wifi_sock_type_t type,
                wifi_protocol_t protocol);

/*==========================================================================*/
/**
 *  Bind.
 *  \param[in]  p_wifi   Wi-Fi ports including IRQ, CS and SPI lines
 *  \param[in]  p        Port.
 *  \param[out] int 0 -> success. -'ve -> failure.
 **/
int wifi_socket_bind(REFERENCE_PARAM(wifi_tiwisl_ports_t, p_wifi), int p);

/*==========================================================================*/
/**
 *  Listen.
 *  \param[in]  p_wifi   Wi-Fi ports including IRQ, CS and SPI lines
 *  \param[out] int 0 -> success. -'ve -> failure.
 **/
int wifi_socket_listen(REFERENCE_PARAM(wifi_tiwisl_ports_t, p_wifi));

/*==========================================================================*/
/**
 *  Accept connections on the socket ID.
 *  \param[in]  p_wifi   Wi-Fi ports including IRQ, CS and SPI lines
 *  \param[out] int client ID.
 **/
int wifi_socket_accept(REFERENCE_PARAM(wifi_tiwisl_ports_t, p_wifi));

/*==========================================================================*/
/**
 *  Close socket.
 *  \param[in]  p_wifi   Wi-Fi ports including IRQ, CS and SPI lines
 *  \param[in]  sd       socket descriptor
 *  \param[out] int 0 -> success. -'ve -> failure.
 **/
int wifi_socket_close(REFERENCE_PARAM(wifi_tiwisl_ports_t, p_wifi),
                      unsigned char sd);

/*==========================================================================*/
/**
 *  Receive data. Minimum 6 bytes of data received.
 *  \param[in]  p_wifi   Wi-Fi ports including IRQ, CS and SPI lines
 *  \param[in]  sd       Socket descriptor.
 *  \param[out] wifi_data_rx  An array containing the received data.
 *  \param[out] int number of data bytes received (Minimum 6).
 **/
int wifi_recv(REFERENCE_PARAM(wifi_tiwisl_ports_t, p_wifi),
              unsigned char sd,
              unsigned char wifi_data_rx[]);

/*==========================================================================*/
/**
 *  Send data.
 *  \param[in]  p_wifi   Wi-Fi ports including IRQ, CS and SPI lines
 *  \param[in]  sd       Socket descriptor.
 *  \param[in]  wifi_data_tx  Data to transfer
 *  \param[in]  len      Length of data to transfer
 *  \param[out] int number of bytes transmitted.
 **/
int wifi_send(REFERENCE_PARAM(wifi_tiwisl_ports_t, p_wifi),
              unsigned char sd,
              unsigned char wifi_data_tx[],
              int len);

/*==========================================================================*/
/**
 *  Connect to an IP address.
 *  \param[in]  p_wifi   Wi-Fi ports including IRQ, CS and SPI lines
 *  \param[in]  sd       Socket descriptor
 *  \param[in]  p        Port
 *  \param[in]  ipaddr   IP(v4) address to connect to.
 *  \param[out] int 0 -> success. -'ve -> failure.
 **/
int wifi_connect_to(REFERENCE_PARAM(wifi_tiwisl_ports_t, p_wifi),
                    unsigned char sd,
                    int p,
                    ipaddr_t &ipaddr);

#endif // _wifi_tiwisl_h_
