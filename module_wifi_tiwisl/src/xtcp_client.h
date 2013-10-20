#ifndef _XTCP_CLIENT_H_
#define _XTCP_CLIENT_H_

#include <xccompat.h>

#ifdef __XC__
#define NULLABLE ?
#else
#define NULLABLE
#endif

#ifndef XTCP_CLIENT_BUF_SIZE
#define XTCP_CLIENT_BUF_SIZE (1460)
#endif

#ifndef XTCP_MAX_RECEIVE_SIZE
#define XTCP_MAX_RECEIVE_SIZE (XTCP_CLIENT_BUF_SIZE)
#endif

typedef unsigned int xtcp_appstate_t;

/** XTCP IP address.
 *
 *  This data type represents a single ipv4 address in the XTCP
 *  stack.
 */
typedef unsigned char xtcp_ipaddr_t[4];

/** IP configuration information structure.
 * 
 *  This structure describes IP configuration for an ip node.
 *  
 **/
typedef struct xtcp_ipconfig_t {
  xtcp_ipaddr_t ipaddr;    /**< The IP Address of the node */
  xtcp_ipaddr_t netmask;   /**< The netmask of the node. The mask used 
                                to determine which address are routed locally.*/
  xtcp_ipaddr_t gateway;   /**< The gateway of the node */
} xtcp_ipconfig_t;

/** XTCP protocol type.
 *  
 * This determines what type a connection is: either UDP or TCP.
 *
 **/
typedef enum xtcp_protocol_t {
  XTCP_PROTOCOL_TCP=6, /**< Transmission Control Protocol */
  XTCP_PROTOCOL_UDP=17  /**< User Datagram Protocol */
} xtcp_protocol_t;


/** XTCP event type.
 *
 *  The event type represents what event is occuring on a particualr connection.
 *  It is instantiated when an event is received by the client using the 
 *  xtcp_event() function.
 *
 **/
typedef enum xtcp_event_type_t {
  XTCP_NEW_CONNECTION,  /**<  This event represents a new connection has been 
                              made. In the case of a TCP server connections it
                              occurs when a remote host firsts makes contact
                              with the local host. For TCP client connections  
                              it occurs when a stream is setup with the remote
                              host.
                              For UDP connections it occurs as soon as the 
                              connection is created.        **/ 

  XTCP_RECV_DATA,       /**<  This event occurs when the connection has received
                              some data. The client **must** follow receipt of 
                              this event with a call to xtcp_recv() before
                              any other interaction with the server. **/

  XTCP_REQUEST_DATA,    /**<  This event occurs when the server is ready to send
                              data and is requesting that the client send data.
                              This event happens after a call to 
                              xtcp_init_send() from the client.
                              The client **must** follow receipt of this event 
                              with a call to xtcp_send() before any other
                              interaction with the server. */
                                                    
  XTCP_SENT_DATA,       /**<  This event occurs when the server has successfully
                              sent the previous piece of data that was given
                              to it via a call to xtcp_send(). The server
                              is now requesting more data so the client 
                              **must** follow receipt of this event 
                              with a call to xtcp_send() before any other
                              interaction with the server. */

  XTCP_RESEND_DATA,    /**<  This event occurs when the server has failed to
                              send the previous piece of data that was given
                              to it via a call to xtcp_send(). The server
                              is now requesting for the same data to be sent
                              again. The client 
                              **must** follow receipt of this event 
                              with a call to xtcp_send() before any other
                              interaction with the server. */

  XTCP_TIMED_OUT,      /**<   This event occurs when the connection has 
                              timed out with the remote host (TCP only). 
                              This event represents the closing of a connection
                              and is the last event that will occur on
                              an active connection. */

  XTCP_ABORTED,        /**<   This event occurs when the connection has 
                              been aborted by the local or remote host
                              (TCP only). 
                              This event represents the closing of a connection
                              and is the last event that will occur on
                              an active connection. */

  XTCP_CLOSED,         /**<   This event occurs when the connection has
                              been closed by the local or remote host.
                              This event represents the closing of a connection
                              and is the last event that will occur on
                              an active connection. */

  XTCP_POLL,           /**<   This event occurs at regular intervals per
                              connection. Polling can be initiated and 
                              the interval can be set with 
                              xtcp_set_poll_interval() */

  XTCP_IFUP,           /**<   This event occurs when the link goes up (with
                              valid new ip address). This event has no 
                              associated connection. */
                              
  XTCP_IFDOWN,         /**<   This event occurs when the link goes down. 
                              This event has no associated connection. */

  XTCP_ALREADY_HANDLED /**<   This event type does not get set by the server 
                              but can be set by the client to show an event
                              has been handled */
} xtcp_event_type_t;

/** Type representing a connection type.
 *
 */
typedef enum xtcp_connection_type_t {
  XTCP_CLIENT_CONNECTION,  /**< A client connection */
  XTCP_SERVER_CONNECTION   /**< A server connection */
} xtcp_connection_type_t;


/** This type represents a TCP or UDP connection.
 *
 *  This is the main type containing connection information for the client 
 *  to handle. Elements of this type are instantiated by the xtcp_event() 
 *  function which informs the client about an event and the connection
 *  the event is on.
 *
 **/
typedef struct xtcp_connection_t {
  int id;  /**< A unique identifier for the connection */
  xtcp_protocol_t protocol; /**< The protocol of the connection (TCP/UDP) */
  xtcp_connection_type_t connection_type; /**< The type of connection (client/sever) */
  xtcp_event_type_t event; /**< The last reported event on this connection. */
  xtcp_appstate_t appstate; /**< The application state associated with the connection. This is set using the xtcp_set_connection_appstate() function. */
  xtcp_ipaddr_t remote_addr; /**< The remote ip address of the connection. */
  unsigned int remote_port;  /**< The remote port of the connection. */
  unsigned int local_port;  /**< The local port of the connection. */
  unsigned int mss;  /**< The maximum size in bytes that can be send using xtcp_send() after a send event */
} xtcp_connection_t;

/** This type represents a wifi access point configuration
 *
 **/
typedef struct wifi_ap_config_t_
{
  unsigned char ssid[32]; /**< SSID of the access point. Max 32 bytes long. */
  unsigned char key[32]; /**< Security key to connect to AP. null for no security. */
  int security_type; /**< Security type: TIWISL_SEC_TYPE_UNSEC or
                                         TIWISL_SEC_TYPE_WEP or
                                         TIWISL_SEC_TYPE_WPA or
                                         TIWISL_SEC_TYPE_WPA2. */
} wifi_ap_config_t;

/** \brief Listen to a particular incoming port.
 *
 *  After this call, when a connection is established an
 *  XTCP_NEW_CONNECTION event is signalled.
 *
 * \param c_xtcp      chanend connected to the xtcp server
 * \param port_number the local port number to listen to
 * \param proto       the protocol to listen to (TCP or UDP)
 */
void xtcp_listen(chanend c_xtcp, int port_number, xtcp_protocol_t proto);

/*==========================================================================*/
/**
 *  xtcp_connect
 *
 *  \param c_xtcp     channel
 *  \param ap_config  Access point configuration set by the host application
 **/
void xtcp_connect(chanend c_xtcp,
                  REFERENCE_PARAM(wifi_ap_config_t, ap_config));

/*==========================================================================*/
/**
 *  xtcp_disconnect
 *
 *  \param c_xtcp     channel
 **/
void xtcp_disconnect(chanend c_xtcp);

/*==========================================================================*/
/**
 *  xtcp_wifi_on
 *
 *  \param c_xtcp     channel
 **/
void xtcp_wifi_on(chanend c_xtcp);

/*==========================================================================*/
/**
 *  xtcp_wifi_off
 *
 *  \param c_xtcp     channel
 **/
void xtcp_wifi_off(chanend c_xtcp);

/** \brief Receive the next connect event.
 *
 *  \note This can be used in a select statement.
 *
 *  Upon receiving the event, the xtcp_connection_t structure conn
 *  is instatiated with information of the event and the connection
 *  it is on.
 *
 * \param c_xtcp      chanend connected to the xtcp server
 * \param conn        the connection relating to the current event
 */
#ifdef __XC__
transaction xtcp_event(chanend c_xtcp, xtcp_connection_t &conn);
#else
void do_xtcp_event(chanend c_xtcp,  xtcp_connection_t *conn);
#define xtcp_event(x,y) do_xtcp_event(x,y)
#endif

/** \brief Initiate sending data on a connection.
 *
 *  After making this call, the
 *  server will respond with a XTCP_REQUEST_DATA event when it is
 *  ready to accept data.
 *
 * \param c_xtcp      chanend connected to the xtcp server
 * \param conn        the connection
 */
void xtcp_init_send(chanend c_xtcp, 
                    REFERENCE_PARAM(xtcp_connection_t, conn));

/** \brief Set the connections application state data item
 *
 * After this call, subsequent events on this connection
 * will have the appstate field of the connection set
 *
 * \param c_xtcp      chanend connected to the xtcp server
 * \param conn        the connection
 * \param appstate    An unsigned integer representing the state. In C
 *                    this is usually a pointer to some connection dependent
 *                    information.
 */
void xtcp_set_connection_appstate(chanend c_xtcp, 
                                  REFERENCE_PARAM(xtcp_connection_t, conn), 
                                  xtcp_appstate_t appstate);

/** \brief Close a connection.
 *
 * \param c_xtcp      chanend connected to the xtcp server
 * \param conn        the connection
 */
void xtcp_close(chanend c_xtcp,
                REFERENCE_PARAM(xtcp_connection_t,conn));

/** \brief Abort a connection.
 *
 * \param c_xtcp      chanend connected to the xtcp server
 * \param conn        the connection
 */
void xtcp_abort(chanend c_xtcp,
                REFERENCE_PARAM(xtcp_connection_t,conn));

/**  \brief Receive data from the server
 *
 *   This can be called after an XTCP_RECV_DATA event.
 *
 * \param c_xtcp      chanend connected to the xtcp server
 * \param data        A array to place the received data into
 * \returns           The length of the received data in bytes
 */
int xtcp_recv(chanend c_xtcp, char data[]);

/** \brief Send data to the xtcp server
 *
 *  Send data to the server. This should be called after a
 *  XTCP_REQUEST_DATA, XTCP_SENT_DATA or XTCP_RESEND_DATA event 
 *  (alternatively xtcp_write_buf can be called). 
 *  To finish sending this must be called with a length  of zero or
 *  call the xtcp_complete_send() function.
 *
 * \param c_xtcp      chanend connected to the xtcp server
 * \param data        An array of data to send
 * \param len         The length of data to send. If this is 0, no data will
 *                    be sent and a XTCP_SENT_DATA event will not occur.
 */
void xtcp_send(chanend c_xtcp,
               char NULLABLE data[],
               int len);

/** \brief Complete a send transaction with the server.
 *
 *  This function can be called after a
 *  XTCP_REQUEST_DATA, XTCP_SENT_DATA or XTCP_RESEND_DATA event 
 *  to finish any sending on the connection that the event
 *  related to.
 *  
 *  \param c_xtcp   chanend connected to the tcp server
 */
void xtcp_complete_send(chanend c_xtcp);

#define xtcp_ignore_send xtcp_complete_send

/** \brief Get the IP config information into a local structure
 *
 * Get the current host IP configuration of the server.
 *
 * \param c_xtcp      chanend connected to the xtcp server
 * \param ipconfig    the structure to be filled with the IP configuration
 *                    information
 **/
void xtcp_get_ipconfig(chanend c_xtcp, 
                       REFERENCE_PARAM(xtcp_ipconfig_t, ipconfig));


#endif // _XTCP_CLIENT_H_

