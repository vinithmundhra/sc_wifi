#include <string.h>
#include <print.h>
#include "xtcp_client.h"
#include "httpd.h"

#define NUM_HTTPD_CONNECTIONS 7

// ::Structure to hold HTTP state
typedef struct httpd_state_t
{
  int active;       //< Whether this state structure is being used for a connection
  int conn_id;      //< The connection id
  char *dptr;       //< Pointer to the remaining data to send
  int dlen;         //< The length of remaining data to send
  char *prev_dptr;  //< Pointer to the previously sent item of data
} httpd_state_t;
//::

// Default HTTP page with HTTP headers included
char page[] = "HTTP/1.0 200 OK\nServer: xc2/pre-1.0 (http://xmos.com)\nContent-type: text/html\n\n"
              "<!DOCTYPE html>\n"
              "<html><head><title>Hello world</title></head>\n"
              "<body>Hello World!</body></html>";

httpd_state_t connection_states[NUM_HTTPD_CONNECTIONS];

static int recv_count = 0;

/*---------------------------------------------------------------------------
 httpd_init
 ---------------------------------------------------------------------------*/
// ::httpd_init
void httpd_init(chanend tcp_svr, wifi_ap_config_t *ap_config)
{
  int i;
  xtcp_connect(tcp_svr, ap_config);
  xtcp_listen(tcp_svr, 80, XTCP_PROTOCOL_TCP);
  for(i = 0; i < NUM_HTTPD_CONNECTIONS; i++)
  {
    connection_states[i].active = 0;
    connection_states[i].dptr = NULL;
  }
}
//::

/*---------------------------------------------------------------------------
 parse_http_request
 ---------------------------------------------------------------------------*/
// ::parse_http_request
void parse_http_request(httpd_state_t *hs, char *data, int len)
{
  // Return if we have data already
  if (hs->dptr != NULL)
  {
    return;
  }

  // Test if we received a HTTP GET request
  if (strncmp(data, "GET ", 4) == 0)
  {
    // Assign the default page character array as the data to send
    hs->dptr = &page[0];
    hs->dlen = strlen(&page[0]);
  }
  else
  {
    // We did not receive a GET request, so do nothing
  }
}
//::

/*---------------------------------------------------------------------------
 httpd_recv
 ---------------------------------------------------------------------------*/
// ::httpd_recv
void httpd_recv(chanend tcp_svr, xtcp_connection_t *conn)
{
  struct httpd_state_t *hs = (struct httpd_state_t *) conn->appstate;
  char data[XTCP_CLIENT_BUF_SIZE];
  int len;

  // Receive the data from the Wi-Fi stack
  len = xtcp_recv(tcp_svr, data);

  printstr("Recv Count "); printint(recv_count); printstr(" length = "); printintln(len);
  recv_count++;

  // If we already have data to send, return
  if (hs == NULL || hs->dptr != NULL)
  {
    return;
  }

  // Otherwise we have data, so parse it
  parse_http_request(hs, &data[0], len);

  // If we are required to send data
  if (hs->dptr != NULL)
  {
    //printstrln("sending init_send");
    xtcp_init_send(tcp_svr, conn);
  }
  ////
}

/*---------------------------------------------------------------------------
 httpd_send
 ---------------------------------------------------------------------------*/
void httpd_send(chanend tcp_svr, xtcp_connection_t *conn)
{
  struct httpd_state_t *hs = (struct httpd_state_t *) conn->appstate;

  // Check if we need to resend previous data
  if (conn->event == XTCP_RESEND_DATA)
  {
    xtcp_send(tcp_svr, hs->prev_dptr, (hs->dptr - hs->prev_dptr));
    return;
  }

  // Check if we have no data to send
  if (hs->dlen == 0 || hs->dptr == NULL)
  {
    // Terminates the send process
    xtcp_complete_send(tcp_svr);
    // Close the connection
    xtcp_close(tcp_svr, conn);
  }
  // We need to send some new data
  else
  {
    int len = hs->dlen;
    if (len > conn->mss) len = conn->mss;
    xtcp_send(tcp_svr, hs->dptr, len);
    hs->prev_dptr = hs->dptr;
    hs->dptr += len;
    hs->dlen -= len;
  }
  ////
}

/*---------------------------------------------------------------------------
 httpd_init_state
 ---------------------------------------------------------------------------*/
// ::httpd_init_state
void httpd_init_state(chanend tcp_svr, xtcp_connection_t *conn)
{
  int i;

  // Try and find an empty connection slot
  for(i = 0; i < NUM_HTTPD_CONNECTIONS; i++)
  {
    if (!connection_states[i].active) break;
  }

  if (i == NUM_HTTPD_CONNECTIONS)
  {
    // If no free connection slots were found, abort the connection
    xtcp_abort(tcp_svr, conn);
  }
  else
  {
    // Otherwise, assign the connection to a slot
    connection_states[i].active = 1;
    connection_states[i].conn_id = conn->id;
    connection_states[i].dptr = NULL;
    xtcp_set_connection_appstate(tcp_svr,
                                 conn,
                                 (xtcp_appstate_t) &connection_states[i]);
  }
}

/*---------------------------------------------------------------------------
 httpd_free_state
 ---------------------------------------------------------------------------*/
// ::httpd_free_state
void httpd_free_state(xtcp_connection_t *conn)
{
  int i;

  for(i = 0; i < NUM_HTTPD_CONNECTIONS; i++)
  {
    if (connection_states[i].conn_id == conn->id)
    {
      connection_states[i].active = 0;
    }
  }
}
//::
/*---------------------------------------------------------------------------
 httpd_handle_event
 ---------------------------------------------------------------------------*/
// ::httpd_handle_event
void httpd_handle_event(chanend tcp_svr, xtcp_connection_t *conn)
{
  // Ignore events that are not directly relevant to http
  switch(conn->event)
  {
    case XTCP_IFUP:
    case XTCP_IFDOWN:
    case XTCP_ALREADY_HANDLED: return;
    default: break;
  }

  // Check if the connection is a http connection
  if (conn->local_port == 80)
  {
    switch(conn->event)
    {
      case XTCP_NEW_CONNECTION:
        printstr("New connection = "); printintln(conn->id);
        httpd_init_state(tcp_svr, conn);
        break;
      case XTCP_RECV_DATA:
        httpd_recv(tcp_svr, conn);
        break;
      case XTCP_SENT_DATA:
      case XTCP_REQUEST_DATA:
      case XTCP_RESEND_DATA:
        //printstr("Sending to = "); printintln(conn->id);
        httpd_send(tcp_svr, conn);
        break;
      case XTCP_TIMED_OUT:
      case XTCP_ABORTED:
      case XTCP_CLOSED:
        printstr("Closing = "); printintln(conn->id);
        httpd_free_state(conn);
        break;
      default: break;
    }
    conn->event = XTCP_ALREADY_HANDLED;
  }
  return;
}
//::
