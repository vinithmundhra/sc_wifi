// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Info
 ----

 ===========================================================================*/

/*---------------------------------------------------------------------------
 include files
 ---------------------------------------------------------------------------*/
#include "tiwisl_event_handler.h"
#include "wifi_tiwisl_server.h"
#include "wifi_tiwisl_spi.h"
#include "hci_defines.h"
#include "xtcp_client.h"
#include "xtcp_cmd.h"
#include "hci_pkg.h"
#include "notify.h"
#include <print.h>

#define ENABLE_XSCOPE 1

#if ENABLE_XSCOPE == 1
#include <print.h>
#include <xscope.h>
#endif

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define TIWISL_POLL 90000000

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/
unsigned char tiwisl_tx_buf[TIWISL_BUF_SIZE];
unsigned char tiwisl_rx_buf[TIWISL_BUF_SIZE];

bsd_rtn_t skt_rtn;
xtcp_connection_t conn;

int skt_id = -1;
int skt_accept_status = -1;

/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/
static int power_up = 1;
static int tiwisl_connected_to_ap = 0;
static int tiwisl_data_pending = 0;
static xtcp_ipconfig_t ipconfig;

/*---------------------------------------------------------------------------
 static prototypes
 ---------------------------------------------------------------------------*/

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
static void write_and_wait_for_event(spi_master_interface &tiwisl_spi,
                                     wifi_tiwisl_ctrl_ports_t &tiwisl_ctrl,
                                     int len,
                                     int opcode);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
static void read_and_wait_for_event(spi_master_interface &tiwisl_spi,
                                    wifi_tiwisl_ctrl_ports_t &tiwisl_ctrl,
                                    int opcode);

/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
static void create_socket(spi_master_interface &tiwisl_spi,
                          wifi_tiwisl_ctrl_ports_t &tiwisl_ctrl);


/*==========================================================================*/
/**
 *  Description
 *
 *  \param xxx    description of xxx
 *  \param yyy    description of yyy
 *  \return None
 **/
static void close_socket(int skt_d,
                         spi_master_interface &tiwisl_spi,
                         wifi_tiwisl_ctrl_ports_t &tiwisl_ctrl);







/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
static void write_and_wait_for_event(spi_master_interface &tiwisl_spi,
                                     wifi_tiwisl_ctrl_ports_t &tiwisl_ctrl,
                                     int len,
                                     int opcode)
{
    // SPI write

    /*printstr("Command = ");
    for(int i = 0; i < len; i++)
    {
        printint(tiwisl_tx_buf[i]); printstr("  ");
    }
    printstrln(" ");*/

    if(power_up)
    {
        wifi_tiwisl_spi_first_write(tiwisl_spi, tiwisl_ctrl, tiwisl_tx_buf, len);
        power_up = 0;
    }
    else
    {
        wifi_tiwisl_spi_write(tiwisl_spi, tiwisl_ctrl, tiwisl_tx_buf, len);
    }

    read_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, opcode);
}

/*---------------------------------------------------------------------------
 implementation1
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
        spi_read_len = (unsigned short)((unsigned short)(tiwisl_rx_buf[0] << 8) + (unsigned short)(tiwisl_rx_buf[1]));

        // Read the rest of packets
        wifi_tiwisl_spi_read(tiwisl_spi, tiwisl_ctrl, tiwisl_rx_buf, spi_read_len, 1);

        /*printstr("Read = ");
        for(int i = 0; i < spi_read_len; i++)
        {
            printint(tiwisl_rx_buf[i]); printstr("  ");
        }
        printstrln(" ");*/

        // Deassert nCS and wait for nIRQ deassertion
        wifi_tiwisl_spi_deassert_cs(tiwisl_ctrl);

        // Check received data
        opcode_event_rxd = event_checker(opcode, tiwisl_rx_buf[0]);
    }
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
static void create_socket(spi_master_interface &tiwisl_spi,
                          wifi_tiwisl_ctrl_ports_t &tiwisl_ctrl)
{
    int len, opcode, rtn_val;

    // create a socket
    len = hci_pkg_skt_create(opcode);
    write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);
    skt_id = hci_process_skt_create();

    // socket bind
    len = hci_pkg_skt_bind(opcode);
    write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);
    rtn_val = hci_process_skt_bind();

    // socket listen
    len = hci_pkg_skt_listen(opcode);
    write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);
    rtn_val = hci_process_skt_listen();
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
static void close_socket(int skt_d,
                         spi_master_interface &tiwisl_spi,
                         wifi_tiwisl_ctrl_ports_t &tiwisl_ctrl)
{
    int len, opcode;
    len = hci_pkg_skt_close(skt_d, opcode);
    write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/
void wifi_tiwisl_server(chanend c_xtcp,
                        spi_master_interface &tiwisl_spi,
                        wifi_tiwisl_ctrl_ports_t &tiwisl_ctrl)
{
    xtcp_cmd_t cmd;
    timer t;
    unsigned time;
    int conn_id, opcode, len;
    int mask = (HCI_EVNT_WLAN_UNSOL_CONNECT |
                HCI_EVNT_WLAN_UNSOL_DISCONNECT |
                HCI_EVNT_WLAN_ASYNC_SIMPLE_CONFIG_DONE |
                HCI_EVNT_WLAN_ASYNC_PING_REPORT |
                HCI_EVNT_WLAN_KEEPALIVE);

    t :> time;
    time += TIWISL_POLL;

#if ENABLE_XSCOPE == 1
    xscope_register(0, 0, "", 0, "");
    xscope_config_io(XSCOPE_IO_BASIC);
#endif

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

                        // Power up sequence finished. Send dummy value.
                        c_xtcp <: power_up;

                        break;

                    } // case XTCP_CMD_WIFI_ON:

                    case XTCP_CMD_WIFI_OFF:
                    {
                        wifi_tiwisl_spi_shutdown(tiwisl_spi, tiwisl_ctrl);
                        power_up = 1;
                        tiwisl_connected_to_ap = 0;

                        break;
                    } // case XTCP_CMD_WIFI_OFF:


                    case XTCP_CMD_CONNECT:
                    {
                        wifi_ap_config_t ap_config;
                        slave
                        {
                            c_xtcp :> ap_config;
                        }

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
                        conn.protocol = p; // TODO: the TCP define is different
                        conn.mss = XTCP_MAX_RECEIVE_SIZE; // send bytes in chunks of 300
                        conn.event = XTCP_IFUP;
                        send_notification(c_xtcp, conn);

                        printstr("IP Address: "); printint(ipconfig.ipaddr[0]); printstr(".");
                        printint(ipconfig.ipaddr[1]); printstr("."); printint(ipconfig.ipaddr[2]); printstr("."); printintln(ipconfig.ipaddr[3]);

                        tiwisl_connected_to_ap = 1;

                        break;

                    } // case XTCP_CMD_LISTEN:

                    case XTCP_CMD_INIT_SEND:
                    {
                        int tx_data_len;
                        int data_offset;
                        int all_data_sent = 0;

                        // send the XTCP_REQUEST_DATA event
                        conn.event = XTCP_REQUEST_DATA;
                        send_notification(c_xtcp, conn);

                        // Get the data

                        while(all_data_sent == 0)
                        {
                            master
                            {
                                c_xtcp :> tx_data_len;

                                if(tx_data_len > 0)
                                {
                                    for(int i = 0; i < tx_data_len; i++)
                                    {
                                        c_xtcp :> tiwisl_tx_buf[i + HCI_SEND_DATA_OFFSET];
                                    }

                                    // Send data to tiwisl
                                    len = hci_pkg_skt_send(tx_data_len, opcode);
                                    write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);

                                } // if(tx_data_len > 0)
                                else
                                {
                                    all_data_sent = 1;
                                }
                            } // master

                            if(all_data_sent == 0)
                            {
                                // send the XTCP_REQUEST_DATA event again
                                conn.event = XTCP_REQUEST_DATA;
                                send_notification(c_xtcp, conn);
                            }

                        } // while(all_data_sent == 0)

                        break;

                    } // case XTCP_REQUEST_DATA:

                    case XTCP_CMD_ABORT:
                    case XTCP_CMD_CLOSE:
                    {
                        tiwisl_data_pending = 0;
                        close_socket(skt_accept_status, tiwisl_spi, tiwisl_ctrl);
                        break;
                    } // case XTCP_CMD_CLOSE:

                } // switch(cmd)

                break;

            } // case c_xtcp :> cmd;


            // =========================================
            // Handle Events from TiWiSL
            // =========================================
            case !power_up => tiwisl_ctrl.p_spi_irq when pinseq(0) :> void:
            {
                read_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, 0);

                break;
            } // case !power_up => tiwisl_ctrl.p_spi_irq when pinseq(0) :> void:



            // =========================================
            // Periodically check for new connections
            // =========================================
            case t when timerafter(time) :> void :
            {
                if(tiwisl_connected_to_ap && (tiwisl_data_pending == 0) && (skt_id != -1))
                {
                    int data_len = 0;
                    int data_offset;

                    skt_accept_status = -1;

                    // accept connections
                    len = hci_pkg_skt_accept(opcode);
                    write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);
                    skt_accept_status = hci_process_skt_accept();

                    if((skt_accept_status == -1) || (skt_accept_status == -2))
                    {}
                    else if(skt_accept_status == -57)
                    {
                        close_socket(skt_id, tiwisl_spi, tiwisl_ctrl);
                        create_socket(tiwisl_spi, tiwisl_ctrl);
                    }
                    else
                    {
                        conn.event = XTCP_NEW_CONNECTION;
                        send_notification(c_xtcp, conn);

                        // set connection appstate
                        c_xtcp :> cmd;
                        c_xtcp :> conn_id;
                        slave
                        {
                            c_xtcp :> conn.appstate;
                        }

                        len = hci_pkg_skt_recv(opcode);
                        write_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, len, opcode);
                        data_len = hci_process_skt_recv();

                        if(data_len > 0)
                        {
                            conn.event = XTCP_RECV_DATA;
                            send_notification(c_xtcp, conn);

                            read_and_wait_for_event(tiwisl_spi, tiwisl_ctrl, -1);
                            data_offset = hci_process_recv_data();
                        }

                        if(data_len >= 0)
                        {
                            master
                            {
                                c_xtcp <: data_len;
                                for(int i = 0; i < data_len; i++)
                                {
                                    c_xtcp <: tiwisl_rx_buf[data_offset + i];
                                }
                            } // master
                            tiwisl_data_pending = 1;
                        }
                    } // else - good socket accepted
                } // if(tiwisl_connected_to_ap)

                time += TIWISL_POLL;

                break;

            } // case t when timerafter(time) :> void :
        } // select
    } // while(1)
}

/*---------------------------------------------------------------------------
 implementation1
 ---------------------------------------------------------------------------*/

/*==========================================================================*/
