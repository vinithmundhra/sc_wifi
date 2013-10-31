#include "wifi_tiwisl_server.h"
#include "tiwisl_event_handler.h"
#include "wifi_tiwisl_spi.h"
#include "hci_defines.h"
#include "xtcp_client.h"
#include "xtcp_cmd.h"
#include "hci_pkg.h"
#include <print.h>

#define TIWISL_POLL 90000
#define TIWISL_MAX_SKT 6

unsigned char tiwisl_tx_buf[XTCP_CLIENT_BUF_SIZE];
unsigned char tiwisl_rx_buf[XTCP_CLIENT_BUF_SIZE];

bsd_rtn_t skt_rtn;
xtcp_connection_t conn;

static int power_up = 1;
static int tiwisl_connected_to_ap = 0;
static xtcp_ipconfig_t ipconfig;

int skt_id = -1;
static int skt_active[TIWISL_MAX_SKT] = {-1, -1, -1, -1, -1, -1};
static int data_to_send[TIWISL_MAX_SKT] = {0,0,0,0,0,0};

/*==========================================================================*/
/**
 *  write_and_wait_for_event
 *
 *  \param tiwisl_spi    SPI interface
 *  \param tiwisl_ctrl   TiWi-Sl control interface
 *  \param len           write length
 *  \param opcode        wait for this event
 *  \return None
 **/
static void write_and_wait_for_event(spi_master_interface &tiwisl_spi,
                                     wifi_tiwisl_ctrl_ports_t &tiwisl_ctrl,
                                     int len,
                                     int opcode);

/*==========================================================================*/
/**
 *  read_and_wait_for_event
 *
 *  \param tiwisl_spi    SPI interface
 *  \param tiwisl_ctrl   TiWi-Sl control interface
 *  \param opcode        wait for this event
 *  \return None
 **/
static void read_and_wait_for_event(spi_master_interface &tiwisl_spi,
                                    wifi_tiwisl_ctrl_ports_t &tiwisl_ctrl,
                                    int opcode);

/*==========================================================================*/
/**
 *  create_socket
 *
 *  \param tiwisl_spi    SPI interface
 *  \param tiwisl_ctrl   TiWi-Sl control interface
 *  \return None
 **/
static void create_socket(spi_master_interface &tiwisl_spi,
                          wifi_tiwisl_ctrl_ports_t &tiwisl_ctrl);

/*==========================================================================*/
/**
 *  close_socket
 *
 *  \param skt_d         socket descriptor
 *  \param tiwisl_spi    SPI interface
 *  \param tiwisl_ctrl   TiWi-Sl control interface
 *  \return None
 **/
static void close_socket(int skt_d,
                         spi_master_interface &tiwisl_spi,
                         wifi_tiwisl_ctrl_ports_t &tiwisl_ctrl);

/*==========================================================================*/
/**
 *  send_notification
 *
 *  \param c      channel on which the notification to be sent
 *  \param conn   xtcp connection
 **/
static void send_notification(chanend c, xtcp_connection_t &conn);

/*---------------------------------------------------------------------------
 write_and_wait_for_event
 ---------------------------------------------------------------------------*/
static void write_and_wait_for_event(spi_master_interface &tiwisl_spi,
                                     wifi_tiwisl_ctrl_ports_t &tiwisl_ctrl,
                                     int len,
                                     int opcode)
{
  if (power_up)
  {
    // Power up has a delayed SPI write
    wifi_tiwisl_spi_first_write(tiwisl_spi, tiwisl_ctrl, tiwisl_tx_buf, len);
    power_up = 0;
  }
  else
  {
    // Normal SPI write
    wifi_tiwisl_spi_write(tiwisl_spi, tiwisl_ctrl, tiwisl_tx_buf, len);
  }
  read_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, opcode);
}

/*---------------------------------------------------------------------------
 read_and_wait_for_event
 ---------------------------------------------------------------------------*/
static void read_and_wait_for_event(spi_master_interface &tiwisl_spi,
                                    wifi_tiwisl_ctrl_ports_t &tiwisl_ctrl,
                                    int opcode)
{
  int opcode_event_rxd = 0;
  int spi_read_len = 0;

  // Read while the request opcode event is received
  while(opcode_event_rxd == 0)
  {
    // SPI Read
    // Read the length of SPI packet to read
    wifi_tiwisl_spi_read(tiwisl_spi, tiwisl_ctrl, tiwisl_rx_buf, 2, 0);
    spi_read_len = (unsigned short) ((unsigned short) (tiwisl_rx_buf[0] << 8)
        + (unsigned short) (tiwisl_rx_buf[1]));

    // Read the rest of packets
    wifi_tiwisl_spi_read(tiwisl_spi,
                         tiwisl_ctrl,
                         tiwisl_rx_buf,
                         spi_read_len,
                         1);
    // Deassert nCS and wait for nIRQ deassertion
    wifi_tiwisl_spi_deassert_cs(tiwisl_ctrl);
    // Check received data
    opcode_event_rxd = event_checker(opcode, tiwisl_rx_buf[0]);
  } // while(opcode_event_rxd == 0)
}

/*---------------------------------------------------------------------------
 create_socket
 ---------------------------------------------------------------------------*/
static void create_socket(spi_master_interface &tiwisl_spi,
                          wifi_tiwisl_ctrl_ports_t &tiwisl_ctrl)
{
  int len, opcode;

  // create a socket
  len = hci_pkg_skt_create(opcode);
  write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);
  skt_id = hci_process_skt_create();
  // socket bind
  len = hci_pkg_skt_bind(opcode);
  write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);
  // socket listen
  len = hci_pkg_skt_listen(opcode);
  write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);
}

/*---------------------------------------------------------------------------
 close_socket
 ---------------------------------------------------------------------------*/
static void close_socket(int skt_d,
                         spi_master_interface &tiwisl_spi,
                         wifi_tiwisl_ctrl_ports_t &tiwisl_ctrl)
{
  int len, opcode;
  len = hci_pkg_skt_close(skt_active[skt_d], opcode);
  write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);
  skt_active[skt_d] = -1;
  data_to_send[skt_d] = 0;
  conn.appstate = 0;
  conn.id = skt_d;
  conn.event = XTCP_CLOSED;
}

/*---------------------------------------------------------------------------
 send_notification
 ---------------------------------------------------------------------------*/
static void send_notification(chanend c, xtcp_connection_t &conn)
{
  master
  {
    for(int i = 0; i < sizeof(conn) >> 2; i++)
    {
      c <: (conn,unsigned int[])[i];
    }
  }
}

/*---------------------------------------------------------------------------
 get_first_free_socket
 ---------------------------------------------------------------------------*/
static int get_first_free_socket()
{
  int i;
  for(i = 0; i < TIWISL_MAX_SKT; i++)
    if (skt_active[i] == -1) break;
  if (i >= TIWISL_MAX_SKT) return -1;
  return i;
}

/*---------------------------------------------------------------------------
 wifi_tiwisl_server
 ---------------------------------------------------------------------------*/
void wifi_tiwisl_server(chanend c_xtcp,
                        spi_master_interface &tiwisl_spi,
                        wifi_tiwisl_ctrl_ports_t &tiwisl_ctrl)
{
  xtcp_cmd_t cmd;
  timer t;
  unsigned time;
  int conn_id, opcode, len;

  // Mask out any event that we are not interested in
  int mask = (HCI_EVNT_WLAN_UNSOL_CONNECT |
              HCI_EVNT_WLAN_UNSOL_DISCONNECT |
              HCI_EVNT_WLAN_ASYNC_SIMPLE_CONFIG_DONE |
              HCI_EVNT_WLAN_ASYNC_PING_REPORT |
              HCI_EVNT_WLAN_KEEPALIVE);

  skt_rtn.sock_addr.ifamily = AF_INET;
  skt_rtn.sock_addr.iport = 0;
  skt_rtn.sock_addr.iaddr = 0;
  skt_rtn.sock_addr.izero[0] = 0;
  skt_rtn.sock_addr.izero[1] = 0;
  skt_rtn.sock_addr.izero[2] = 0;
  skt_rtn.sock_addr.izero[3] = 0;
  skt_rtn.sock_addr.izero[4] = 0;
  skt_rtn.sock_addr.izero[5] = 0;
  skt_rtn.sock_addr.izero[6] = 0;
  skt_rtn.sock_addr.izero[7] = 0;

  t :> time;
  time += TIWISL_POLL;

  while(1)
  {
    select
    {
      // =========================================
      // Handle commands from user
      // =========================================
      case c_xtcp :> cmd:
      {
        c_xtcp :> conn_id;

        switch(cmd)
        {
          case XTCP_CMD_WIFI_ON:
          {
            int num_networks = 0;

            printstr("Switching on Wi-Fi module.... ");
            // Initialize the TiWi-SL and SPI
            wifi_tiwisl_spi_init(tiwisl_spi, tiwisl_ctrl);

            // Send simple link start command
            len = hci_pkg_wifi_on(opcode);
            write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);
            // nothing to check

            // Send read buffer command
            len = hci_pkg_read_buffer_size(opcode);
            write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);
            // nothing to check

            // Set event mask
            len = hci_pkg_set_event_mask(mask, opcode);
            write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);
            // nothing to check

            // Send set connection policy command
            len = hci_pkg_wlan_set_connection_policy(0, 0, 0, opcode);
            write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);
            // nothing to check

            printstrln("ok!");

            // Scan and list available networks
            printstrln("Scanning available networks.... ");

            // Start scanning available networks
            len = hci_pkg_wlan_scan(opcode, 1);
            write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);
            hci_process_wlan_scan();

            while(num_networks == 0)
            {
              // Keep getting result until we have a network found
              len = hci_pkg_wlan_get_scan_result(opcode);
              write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);
              num_networks = hci_process_wlan_get_scan_result();
            }

            /* num_networks > 0 : found networks. Now, keep getting results
             * until num_networks = 0
             */

            while(num_networks > 0)
            {
              // Keep getting result until we have a network found
              len = hci_pkg_wlan_get_scan_result(opcode);
              write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);
              num_networks = hci_process_wlan_get_scan_result();
            }

            // Stop scanning
            len = hci_pkg_wlan_scan(opcode, 0);
            write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);
            hci_process_wlan_scan();

            printstrln("----end----");

            // Power up sequence finished. Send dummy value.
            c_xtcp <: power_up;

            break;

          } // case XTCP_CMD_WIFI_ON:

          case XTCP_CMD_WIFI_OFF:
          {
            printstr("Switching off Wi-Fi module.... ");
            wifi_tiwisl_spi_shutdown(tiwisl_spi, tiwisl_ctrl);
            power_up = 1;
            tiwisl_connected_to_ap = 0;
            printstrln("ok!");
            break;
          } // case XTCP_CMD_WIFI_OFF:


          case XTCP_CMD_CONNECT:
          {
            wifi_ap_config_t ap_config;
            slave
            {
              c_xtcp :> ap_config;
            }

            printstr("Connecting to "); printstrln(ap_config.ssid);

            // Send wlan connect command
            len = hci_pkg_wlan_connect(ap_config, opcode);
            write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);
            hci_process_wlan_connect(ipconfig);

            // send dummy to indicate connection to ap
            c_xtcp <: power_up;

            break;
          } // case XTCP_CMD_CONNECT

          case XTCP_CMD_LISTEN:
          {
            int port_number;
            xtcp_protocol_t p;

            slave
            {
              c_xtcp :> port_number;
              c_xtcp :> p;
            }

            skt_rtn.sock_addr.iport = (unsigned short)(port_number);
            create_socket(tiwisl_spi, tiwisl_ctrl);

            conn.local_port = port_number;
            conn.protocol = p;
            conn.mss = XTCP_MAX_RECEIVE_SIZE; // send in chunks
            conn.event = XTCP_IFUP;
            send_notification(c_xtcp, conn);

            // Print out the assigned IP address by the access point
            printstr("IP Address: ");
            printint(ipconfig.ipaddr[0]); printstr(".");
            printint(ipconfig.ipaddr[1]); printstr(".");
            printint(ipconfig.ipaddr[2]); printstr(".");
            printintln(ipconfig.ipaddr[3]);

            tiwisl_connected_to_ap = 1;

            break;

          } // case XTCP_CMD_LISTEN:

          case XTCP_CMD_INIT_SEND:
          {
            data_to_send[conn_id] = 1;
            break;
          } // case XTCP_CMD_INIT_SEND:

          case XTCP_CMD_ABORT:
          case XTCP_CMD_CLOSE:
          {
            close_socket(conn_id, tiwisl_spi, tiwisl_ctrl);
            send_notification(c_xtcp, conn);
            break;
          } // case XTCP_CMD_CLOSE:

        } // switch(cmd)
        break;
      } // case c_xtcp :> cmd;


      // =========================================
      // Handle Unsolicited Events from TiWi-SL
      // =========================================
      case !power_up => tiwisl_ctrl.p_spi_irq when pinseq(0) :> void:
      {
        read_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, 0);
        break;
      } // case !power_up => tiwisl_ctrl.p_spi_irq when pinseq(0) :> void:

      // =======================================================================
      // Periodically check for new connections, data to send and incoming data
      // =======================================================================
      case t when timerafter(time) :> void:
      {
        if(tiwisl_connected_to_ap)
        {
          int skt_status;

          // accept connections
          len = hci_pkg_skt_accept(opcode);
          write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);
          skt_status = hci_process_skt_accept();

          if(skt_status >= 0)
          {
            len = hci_pkg_skt_setopt_recv_nblock(opcode, skt_status);
            write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);

            int new_conn_id = get_first_free_socket();

            if(new_conn_id == -1)
            {
              // no free sockets available
              break;
            }
            else
            {
              skt_active[new_conn_id] = skt_status;
              conn.id = new_conn_id;
              conn.event = XTCP_NEW_CONNECTION;
              send_notification(c_xtcp, conn);

              c_xtcp :> int _;
              c_xtcp :> int _;
              slave { c_xtcp :> conn.appstate; }
            } // else
          } // if(skt_status >= 0)

          for(int i = 0; i < TIWISL_MAX_SKT; i++)
          {
            int data_offset;
            int data_length = 0;

            if(skt_active[i] == -1) continue;

            /*
             * SEND DATA
             */
            if(data_to_send[i])
            {
              int tx_data_len = 1;
              int data_offset;

              do
              {
                // send the XTCP_REQUEST_DATA event
                conn.event = XTCP_REQUEST_DATA;
                send_notification(c_xtcp, conn);

                master
                {
                  c_xtcp :> tx_data_len;
                  for(int i = 0; i < tx_data_len; i++)
                  {
                    c_xtcp :> tiwisl_tx_buf[i + HCI_SEND_DATA_OFFSET];
                  }
                }

                if(tx_data_len > 0)
                {
                  // Send data to tiwisl
                  if(skt_active[conn_id] != -1)
                  {
                    len = hci_pkg_skt_send(tx_data_len, opcode, skt_active[conn_id]);
                    write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);
                  } // if(skt_active[conn_id] != -1)
                } // if(tx_data_len > 0)
              }while(tx_data_len > 0);

              data_to_send[i] = 0;
            } // if(data_to_send[i])


            /*
             * CHECK FOR INCOMING DATA
             */
            len = hci_pkg_skt_recv(opcode, skt_active[i]);
            write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);
            data_length = hci_process_skt_recv();

            if(data_length > 0)
            {
              conn.id = i;
              conn.event = XTCP_RECV_DATA;
              send_notification(c_xtcp, conn);

              read_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, -1);
              data_offset = hci_process_recv_data();

              master
              {
                c_xtcp <: data_length;
                for(int i = 0; i < data_length; i++)
                {
                  c_xtcp <: tiwisl_rx_buf[data_offset + i];
                }
              }
            }
            else if(data_length < 0)
            {
              // data length negative, connection broken
              close_socket(i, tiwisl_spi, tiwisl_ctrl);
              send_notification(c_xtcp, conn);
            }
            else
            {}
          } // for(int i = 0; i < 7; i++)


        } // if(tiwisl_connected_to_ap)
        t :> time;
        time += TIWISL_POLL;
        break;
      } // case t when timerafter(time) :> void :


    } // select
  } // while(1)
}
