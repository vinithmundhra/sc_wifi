#ifndef _wifi_hci_h_
#define _wifi_hci_h_

#define SPI_HEADER_SIZE          (5)
#define HEADERS_SIZE_DATA        (SPI_HEADER_SIZE + 5)
#define HCI_CMND_SEND_ARG_LENGTH (16)
#define HCI_SEND_DATA_OFFSET     (HEADERS_SIZE_DATA + HCI_CMND_SEND_ARG_LENGTH)

#define HCI_TYPE_EVNT                    (0x4)
#define HCI_EVNT_WLAN_UNSOL_DISCONNECT   (0x8002)
#define HCI_EVNT_CLOSE_SOCKET            (0x100B)
#define HCI_EVENT_HEADER_SIZE            (5)
#define HCI_EVNT_DATA_UNSOL_FREE_BUFF    (0x4100)
#define HCI_PACKET_ARGSIZE_OFFSET       (2)
#define HCI_DATA_HEADER_SIZE    (5)

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

#endif //_wifi_hci_h_
