#ifndef _wifi_ports_h_
#define _wifi_ports_h_

#include <xccompat.h>
#include "spi_master.h"

typedef struct wifi_tiwisl_ports_t {
  out port p_cs_pwr;
  in port p_spi_irq;
  spi_master_interface p_spi;
}wifi_tiwisl_ports_t;

#endif // _wifi_ports_h_
