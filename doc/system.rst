TiWi-SL interface Description
=============================

The server runs on a single logical core and connects to the LS Research's
TiWi-SL module using SPI master component. Where, the TiWi-SL module is slave
and the module_wifi_tiwisl is SPI master.

The default SPI clock frequency for this interface is set as 12.5MHz, operating
in SPI mode 1 (CPHA 1; CPOL 0).

The server gets is IP address dynamically assigned (default option, for now)
from the wireless access point.

Events and Connections
----------------------

The Wi-Fi interface is a low-level event based interface. This is to allow
applications to manage buffering and connection management in the most efficient
way possible for the application.

.. only:: html

  .. figure:: images/events-crop.png
     :align: center

     Example event sequence

Each client will receive *events* from the server. These events
usually have an associated *connection*. In addition to receiving
these events the client can send *commands* to the server to initiate
new connections and so on.

The above Figure shows an example event/command sequence of a
client making a connection, sending some data, receiving some data and
then closing the connection. Note that sending and receiving may be
split into several events/commands since the server itself performs no
buffering.

New Connections
---------------

New connections are made by constantly polling the TiWi-SL module after
successfully connecting to a wireless access point. If a new
connection is requested, the TiWi-SL responds with appropriate event and the
module_wifi_tiwisl then triggers a :c:member:`XTCP_NEW_CONNECTION` event.

The API function :c:func:`xtcp_close` should be called after the connection is
no longer needed.

Receiving Data
--------------

Once a new connection is requested, the component then polls for data from the
TiWi-SL module as the module does not generate an event by itself. When data is
received by a connection, the :c:member:`XTCP_RECV_DATA` event is triggered and
communicated to the client. At this point the client **must** call the
:c:func:`xtcp_recv` function to receive the data.

Data is sent from host to client as the TCP packets come in. There is no
buffering in the server so it will wait for the client to handle the event
before processing new incoming packets.

Sending Data
------------

When sending data, the client is responsible for dividing the data
into chunks for the server and re-transmitting the previous chunk if a
transmission error occurs.

The client can initiate a send transaction with the
:c:func:`xtcp_init_send` function. At this point no sending has been
done but the server is notified of a wish to send. The client must
then wait for a :c:member:`XTCP_REQUEST_DATA` event at which point it
must respond with a call to :c:func:`xtcp_send`.

After this data is sent to the server, two things can happen: Either
the server will respond with an :c:member:`XTCP_SENT_DATA` event, in
which case the next chunk of data can be sent or with an
:c:member:`XTCP_RESEND_DATA` event in which case the client must
re-transmit the previous chunk of data.

The command/event exchange continues until the client calls the
:c:func:`xtcp_complete_send` function to finish the send
transaction. After this the server will not trigger any more
:c:member:`XTCP_SENT_DATA` events.

Configuration
-------------

The server is configured via arguments passed to the
:c:func:`wifi_tiwisl_server` function and the defines described in Section
:ref:`sec_config_defines`.

Client connections are configured via the client API described in
Section :ref:`sec_config_defines`.
