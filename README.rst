Wi-Fi
.....

:Latest release: 1.0.0beta0
:Maintainer: vinithmundhra
:Description: Component for driving the TI TiWi SL Wifi module. The TiWi Sl module has an integrated TCP/IP stack and interfaces to this component via an SPI interface.


Key Features
============

* Interface to use an external Wi-Fi module with embedded stack.
* Connects to wireless access points with None, WEP, WPA and WPA2 security.
* Compatible to the Webserver component API calls (for webserver applications).

To Do
=====

* Explore and provide other features of the external Wi-Fi module to the host application.

Firmware Overview
=================

The TiWi-SL component is an SPI master to the external TiWi-SL Wi-Fi module.

Known Issues
============

Support
=======

* Raise issues via GitHub or a RT Ticket.

Required software (dependencies)
================================

  * sc_spi (https://github.com/xcore/sc_spi.git)

