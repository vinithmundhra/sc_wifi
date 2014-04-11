#ifndef _wifi_structs_h_
#define _wifi_structs_h_

typedef enum wifi_state_t {
  WIFI_ERR = -1,
  WIFI_OK = 0
}wifi_state_t;

typedef unsigned char ipaddr_t[4];

typedef struct wifi_ipconfig_t {
  ipaddr_t ipaddr;
  ipaddr_t netmask;
  ipaddr_t gateway;
}wifi_ipconfig_t;

typedef enum wifi_protocol_t {
  WIFI_PROTOCOL_TCP  = 6,   // tcp
  WIFI_PROTOCOL_UDP  = 17,  // user datagram protocol
  WIFI_PROTOCOL_RAW  = 255, // raw IP packet
}wifi_protocol_t;

typedef enum wifi_sock_type_t {
  SOCK_STREAM = 1,
  SOCK_DGRAM = 2,
  SOCK_RAW = 3,
}wifi_sock_type_t;

/*typedef struct wifi_conn_t {
  int id;
  wifi_protocol_t protocol;
  wifi_event_t event;
  ipaddr_t remote_addr;
  unsigned int remote_port;
  unsigned int local_port;
}wifi_conn_t;*/

typedef enum wifi_sec_type_t {
  TIWISL_SEC_TYPE_UNSEC,
  TIWISL_SEC_TYPE_WEP,
  TIWISL_SEC_TYPE_WPA,
  TIWISL_SEC_TYPE_WPA2,
}wifi_sec_type_t;

typedef struct wifi_ap_config_t
{
  unsigned char ssid[32];
  unsigned char key[32];
  wifi_sec_type_t security_type;
} wifi_ap_config_t;

#endif // _wifi_structs_h_
