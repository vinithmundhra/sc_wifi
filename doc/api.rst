.. _sec_api:

API
===

The component ``sc_wifi`` includes the modules ``module_wifi_tiwisl``.

module_wifi_tiwisl
------------------

.. _sec_config_defines:

Configuration Defines
+++++++++++++++++++++

The following defines can be set by adding the file
``xtcp_client.h`` into your application and setting the defines
within that file.

``XTCP_CLIENT_BUF_SIZE``
       The buffer size used for incoming packets. Default is 1200.

Data Structures/Types
+++++++++++++++++++++

.. doxygentypedef:: xtcp_ipaddr_t
.. doxygenstruct:: xtcp_ipconfig_t
.. doxygenenum:: xtcp_protocol_t
.. doxygenenum:: xtcp_event_type_t
.. doxygenenum:: xtcp_connection_type_t
.. doxygenstruct:: xtcp_connection_t
.. doxygenstruct:: wifi_ap_config_t

Server API
++++++++++

.. doxygenfunction:: wifi_tiwisl_server

Client API
++++++++++

Event Receipt
.............

.. doxygenfunction:: xtcp_event

Setting Up Connections
......................

.. doxygenfunction:: xtcp_wifi_on
.. doxygenfunction:: xtcp_wifi_off
.. doxygenfunction:: xtcp_connect
.. doxygenfunction:: xtcp_disconnect
.. doxygenfunction:: xtcp_listen
.. doxygenfunction:: xtcp_set_connection_appstate

Receiving Data
..............

.. doxygenfunction:: xtcp_recv

Sending Data
............

.. doxygenfunction:: xtcp_init_send
.. doxygenfunction:: xtcp_send
.. doxygenfunction:: xtcp_complete_send

Other Connection Management
...........................

.. doxygenfunction:: xtcp_close
.. doxygenfunction:: xtcp_abort

Other General Client Functions
..............................

.. doxygenfunction:: xtcp_get_ipconfig

