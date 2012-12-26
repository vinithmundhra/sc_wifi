// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Info
 ----

 ===========================================================================*/

#ifndef _wifi_tiwisl_server_h_
#define _wifi_tiwisl_server_h_

/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/
#include "spi_master.h"
#include <xccompat.h>

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define      TIWISL_SEC_TYPE_UNSEC (0)
#define      TIWISL_SEC_TYPE_WEP   (1)
#define      TIWISL_SEC_TYPE_WPA   (2)
#define      TIWISL_SEC_TYPE_WPA2  (3)

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/
typedef struct wifi_tiwisl_ctrl_ports_t_
{
    out port p_spi_cs;
    in port p_spi_irq;
    out port p_pwr_en;
} wifi_tiwisl_ctrl_ports_t;

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 extern variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 prototypes
 ---------------------------------------------------------------------------*/

/*==========================================================================*/
/**
 *  wifi_tiwisl_server
 *
 *  \param c_xtcp      channel
 *  \param tiwisl_spi  the SPI interface
 *  \param tiwisl_ctrl the TiWi-Sl control interface
 **/
void wifi_tiwisl_server(chanend c_xtcp,
                        REFERENCE_PARAM(spi_master_interface, tiwisl_spi),
                        REFERENCE_PARAM(wifi_tiwisl_ctrl_ports_t, tiwisl_ctrl));

#endif // _wifi_tiwisl_server_h_
/*==========================================================================*/
