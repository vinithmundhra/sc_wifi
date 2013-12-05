TiWi-SL Simple Webserver Demo Quickstart Guide
==============================================
This application uses the ``XA-SK-WIFI`` sliceCARD together with the xSOFTip 
``module_wifi_tiwisl`` and demonstrate:

* Connecting to a wireless access point, 
* Run a simple HTTP webserver to display a "Hello World!" webpage.
   
Host computer / Other setup
---------------------------
Required a computer:

* connected to a network
* Internet browser (Internet Explorer, Chrome, Firefox, etc...)
* Download and install the xTIMEcomposer Studio from XMOS xTIMEcomposer downloads webpage.

Access point (wireless router) setup:

* Switch on the wireless router.
* Make sure you know its advertised name (SSID), password (if any) and the security type (Unsecured, WEP, WPA or WPA2)
* Make sure the host computer is on the above network.
   
Hardware setup
--------------
Required sliceKIT units:

* XP-SKC-L16 sliceKIT L16 core board
* XA-SK-WIFI Wi-Fi sliceCARD
* xTAG-2 and XA-SK-XTAG2 adapter

Setup:

* Connect the ``XA-SK-XTAG2`` adapter to the core board.
* Connect ``XTAG2`` to ``XSYS`` side (``J1``) of the ``XA-SK-XTAG2`` adapter.
* Connect the ``XTAG2`` to your computer using a USB cable.
* Set the ``XMOS LINK`` to ON on the ``XA-SK-XTAG2`` adapter.
* Connect the ``XA-SK-WIFI`` Wi-Fi sliceCARD to the ``TRIANGLE`` slot of the sliceKIT core board. The ``TRIANGLE`` slot is indicated by a white color triangle (or) ``J3``.
* Connect the 12V power supply to the core board and switch it ON.

.. figure:: images/hardware_setup.*

   Hardware setup
      
Import and build the application
--------------------------------
Importing the TiWi-SL webserver demo application:

* Open the xTIMEcomposer Studio and ensure that it is operating in online mode. 
* Open the *Edit* perspective (Window -> Open Perspective -> XMOS Edit).
* Open the *xSOFTip* view from (Window -> Show View -> xSOFTip). An *xSOFTip* window appears on the bottom-left.
* Search for *TiWi-SL Simple Web Server Demo*.
* Click and drag it into the *Project Explorer* window. Doing this will open a *Import xTIMEcomposer Software* window. Click on *Finish* to download and complete the import.
* This will also automatically import dependencies for this application.
* The application is called as *app_tiwisl_simple_webserver* in the *Project Explorer* window.

Building the TiWi-SL webserver demo application:

* Open the file (app_tiwisl_simple_webserver\\src\\xhttpd.xc).
* Change the ``WIFI_SSID``, ``WIFI_PASSWORD`` and ``WIFI_SECURITY_TYPE`` according to your wireless router configuration.
* Currently supported security types are: TIWISL_SEC_TYPE_UNSEC, TIWISL_SEC_TYPE_WEP, TIWISL_SEC_TYPE_WPA and TIWISL_SEC_TYPE_WPA2

   For example, if your wireless router is known as 'testwifirouter' with no password, then change the configuration as::

      #define WIFI_SSID           "testwifirouter"
      #define WIFI_PASSWORD       ""
      #define WIFI_SECURITY_TYPE  TIWISL_SEC_TYPE_UNSEC
       
   Another example: If your wireless router is known as 'testwifirouter' with password as 'testpwd' and the security type as 'WEP', then change the configuration as::

      #define WIFI_SSID           "testwifirouter"
      #define WIFI_PASSWORD       "testpwd"
      #define WIFI_SECURITY_TYPE  TIWISL_SEC_TYPE_WEP
       
* Click on the *app_tiwisl_simple_webserver* item in the *Project Explorer* window.
* Click on the *Build* (indicated by a 'Hammer' picture) icon.
* Check the *Console* window to verify that the application has built successfully.

Run the application
-------------------
To run the application using xTIMEcomposer Studio:

* In the *Project Explorer* window, locate the *app_tiwisl_simple_webserver.xe* in the (app_tiwisl_simple_webserver -> Binaries).
* Right click on *app_tiwisl_simple_webserver.xe* and click on (Run As -> xCORE Application).
* A *Select Device* window appears.
* Select *XMOS XTAG-2 connected to L1* and click OK.

Demo:

* The following message appears in the *Console* window of the xTIMEcomposer Studio::
        
   **WELCOME TO THE SIMPLE WEBSERVER DEMO**
   Switching on Wi-Fi module....

* At this point, the application is trying to switch ON the TiWi-SL module. After few seconds, the *Console* window is updated as::

   **WELCOME TO THE SIMPLE WEBSERVER DEMO**
   Switching on Wi-Fi module.... ok!
   Scanning available networks....
   
* The TiWi-SL module is now scanning for available wireless networks and will list its results as::

   **WELCOME TO THE SIMPLE WEBSERVER DEMO**
   Switching on Wi-Fi module.... ok!
   Scanning available networks....
   testap1
   testap2
   testap3
   testwifirouter
   ----end----

* The TiWi-SL module is now finishing off scanning and will begin to connect to your network. Note that the IP address acquired may be different based on your network::   

   **WELCOME TO THE SIMPLE WEBSERVER DEMO**
   Switching on Wi-Fi module.... ok!
   Scanning available networks....
   testap1
   testap2
   testap3
   testwifirouter
   ----end----
   Connecting to testwifirouter
   IP Address: 192.168.1.100

* Open a web browser (Firefox, etc...) in your host computer and enter the above IP address in the address bar of the browser. It opens a web page as hosted by the simple webserver running on the XMOS device.

.. figure:: images/webpage.*

   Page hosted by webserver running on XMOS device
    
Next steps
----------

* Examine the application code in ``app_tiwisl_simple_webserver\src``.
* Look at the ``WiFi TiWi-SL Module Driver`` - the underlying component for this application that interfaces with the LS Research's TiWi-SL Wi-Fi module fitted on the ``XA-SK-WIFI`` sliceCARD.
* Try the ``sliceKIT GPIO and Wi-Fi Combo Demo`` from the *xSOFTip* window.
