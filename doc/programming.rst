Wi-Fi Programming Guide
=======================

This section provides information on how to program applications using the Wi-Fi
module.

Source code structure
---------------------
.. list-table:: Project structure
  :header-rows: 1

  * - Project
    - File
    - Description
  * - module_wifi_tiwisl
    - ``xtcp_client.h``
    - Header file containing the 'XTCP' style APIs for the Wi-Fi component
  * -
    - ``xtcp_client.xc``
    - File containing the implementation 'XTCP' style APIs of the LCD component
  * -
    - ``/wifi_tiwisl/wifi_tiwisl_server.h``
    - Header file containing the TiWi-SL server
  * -
    - ``/wifi_tiwisl/wifi_tiwisl_server.xc``
    - File containing the implementation of TiWi-SL server


Setup the ports
---------------

The component uses SPI master to communicate with the LS Research's TiWi-SL
module via the following pins:

  * MOSI - Data IN for TiWi-SL
  * MISO - Data OUT for TiWi-SL
  * nIRQ - Active low interrupt from TiWi-SL
  * nCS  - Active low chip select
  * CLK  - SPI clock (default 12.5MHz)
  * PWR_EN - Power enable to TiWi-SL

For example, these ports are setup in the demo appilcation as:
::

    on stdcore[0]: spi_master_interface tiwisl_spi =
    {
      XS1_CLKBLK_1,
      XS1_CLKBLK_2,
      XS1_PORT_1L, // MOSI
      XS1_PORT_1M, // CLK
      XS1_PORT_1O, // MISO
    };

    on stdcore[0]: wifi_tiwisl_ctrl_ports_t tiwisl_ctrl =
    {
      XS1_PORT_1P, // nCS
      XS1_PORT_1N, // nIRQ
      XS1_PORT_1K  // Wifi power enable
    };

Setup the Wireless Access Point
-------------------------------

The external wireless access point; to which the TiWi-SL will establish a
connection, needs to be configured with known parameters. The following
parameters must be known for the TiWi-SL to make a connection:

    * SSID
    * Security Key
    * Security Type

These parameters must be defined in the ``wifi_ap_config_t`` variable in the
application.

Initializing the Wi-Fi TiWi-SL module
-------------------------------------

The application needs to initialize the TiWi-SL module using two APIs as:

    #. ``xtcp_wifi_on``: This is the intial power-up sequence of TiWi-SL
       module. This may take up to 1 second to complete.
    #. ``xtcp_connect``: This API will take the wireless access point
       configuration as a parameter.

Running the TiWi-SL Server
--------------------------

The TiWi-SL server takes up one logical core. This is called using
``wifi_tiwisl_server`` API.
