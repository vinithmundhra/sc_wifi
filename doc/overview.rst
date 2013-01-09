Overview
========

Wi-Fi TiWi-SL component
-----------------------

The Wi-Fi TiWi-SL component is a host driver to interface with the LS
Research's TiWi-SL Wi-Fi module. Please find more information about the
TiWi-SL module here: http://www.lsr.com/wireless-products/tiwi-sl

Features
++++++++

   * SPI Master interface with LS Research's TiWi-SL Wi-Fi module.
   * Supports TCP/IP protocol.
   * Can connect to wireless access points with following security types

     * Unsecured,
     * WEP,
     * WPA,
     * WPA2.

   * Dynamic IP allocation.
   * Requires a single core for the server.

     * The function ``wifi_tiwisl_server`` requires just one core.

Memory requirements
+++++++++++++++++++

+------------------+---------------+
| Resource         | Usage         |
+==================+===============+
| Stack            | xx bytes      |
+------------------+---------------+
| Program          | xx bytes      |
+------------------+---------------+

Resource requirements
+++++++++++++++++++++

+---------------+-------+
| Resource      | Usage |
+===============+=======+
| Channels      |   1   |
+---------------+-------+
| Timers        |   0   |
+---------------+-------+
| Clocks        |   1   |
+---------------+-------+
| Logical Cores |   1   |
+---------------+-------+

Performance
+++++++++++

The achievable effective bandwidth varies according to the available XCore MIPS.
The SPI interface is clocked at 12.5MHz.

