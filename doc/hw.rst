Evaluation Platforms
====================

.. _sec_hardware_platforms:

Recommended Hardware
--------------------

Slicekit
++++++++

This module may be evaluated using the Slicekit Modular Development Platform, available from digikey. Required board SKUs are:

   * XP-SKC-L2 (Slicekit L2 Core Board) plus ``Wi-Fi`` plus XA-SK-XTAG2 (Slicekit XTAG adaptor)

If using the LS Research's TiWi-SL evaluation board, make the following pin connections:

    +---------------+---------------------+----------------+
    | Lsr Board pin | Slicekit core board | Function       |
    |               |    (Core0/Type1)    |                |
    |               |      Triangle       |                |
    +===============+=====================+================+
    | J4- Pin 7     | GND                 | Ground         |
    +---------------+---------------------+----------------+
    | J4- Pin 8     | D34                 | Power Enable   |
    +---------------+---------------------+----------------+
    | J4- Pin 9     | VCC                 | 3.3V           |
    +---------------+---------------------+----------------+
    | J4- Pin 10    | D35                 | MOSI           |
    +---------------+---------------------+----------------+
    | J4- Pin 11    | D36                 | CLK            |
    +---------------+---------------------+----------------+
    | J4- Pin 12    | GND                 | Ground         |
    +---------------+---------------------+----------------+
    | J5- Pin 7     | GND                 | Ground         |
    +---------------+---------------------+----------------+
    | J5- Pin 8     | D37                 | nIRQ           |
    +---------------+---------------------+----------------+
    | J5- Pin 9     | D38                 | MISO           |
    +---------------+---------------------+----------------+
    | J5- Pin 10    | D39                 | nChip Select   |
    +---------------+---------------------+----------------+
    | J5- Pin 11    | VCC                 | 3.3V           |
    +---------------+---------------------+----------------+
    | J5- Pin 12    | GND                 | Ground         |
    +---------------+---------------------+----------------+



Demonstration Applications
--------------------------

TiWi-SL Simple Web Server Application
+++++++++++++++++++++++++++++++++++++

The TiWi-SL Simple Web Server application hosts a simple 'Hello World!' web page.

   * Package: sc_wifi
   * Application: app_tiwisl_simple_webserver
