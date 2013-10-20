#ifndef _WIFI_TIWISL_SERVER_H_
#define _WIFI_TIWISL_SERVER_H_

#include "spi_master.h"
#include <xccompat.h>

#define TIWISL_SEC_TYPE_UNSEC 0  /**< Wi-Fi security type = unsecured */
#define TIWISL_SEC_TYPE_WEP   1  /**< Wi-Fi security type = WEP */
#define TIWISL_SEC_TYPE_WPA   2  /**< Wi-Fi security type = WPA */
#define TIWISL_SEC_TYPE_WPA2  3  /**< Wi-Fi security type = WPA2 */

/**
 * Control ports for the TiWi-SL module
 */
typedef struct wifi_tiwisl_ctrl_ports_t_
{
  out port p_cs_pwr;  /**< 1-bit output power enable port for TiWi-SL module */
  in port p_spi_irq;  /**< 1-bit input port for interrupts from TiWi-SL module */
} wifi_tiwisl_ctrl_ports_t;

/*==========================================================================*/
/**
 *  The Wi-Fi server
 *
 *  \param c_xtcp      channel
 *  \param tiwisl_spi  the SPI interface
 *  \param tiwisl_ctrl the TiWi-Sl control interface
 **/
void wifi_tiwisl_server(chanend c_xtcp,
                        REFERENCE_PARAM(spi_master_interface, tiwisl_spi),
                        REFERENCE_PARAM(wifi_tiwisl_ctrl_ports_t, tiwisl_ctrl));

#endif // _WIFI_TIWISL_SERVER_H_
