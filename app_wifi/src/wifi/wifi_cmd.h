#ifndef _wifi_cmd_h_
#define _wifi_cmd_h_

#define CMD_SIMPLE_LINK_START       (0x4000)
#define CMD_READ_BUFFER_SIZE        (0x400B)
#define CMD_SET_EVENT_MASK          (0x0008)
#define CMD_SET_CONN_POLICY         (0x0004)

#define CMD_SOCKET_CREATE           (0x1001)
#define CMD_BIND                    (0x1002)
#define CMD_SCAN                    (0x0003)
#define CMD_RECV                    (0x1004)
#define CMD_ACCEPT                  (0x1005)
#define CMD_LISTEN                  (0x1006)
#define CMD_SETSOCKOPT              (0x1009)
#define CMD_CLOSE_SOCKET            (0x100B)
#define CMD_SEND                    (0x81)
#define CMD_DHCP                    (0x8010)

#endif // _wifi_cmd_h_
