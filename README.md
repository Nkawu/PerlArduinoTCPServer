# PerlArduinoTCPServer

Server/Client scripts to control digital pin 10 on an Arduino connected via USB using serial. If a 5V relay is connected to pin 10 for example, a light can be turned on & off from the command line.

Start server:

    arduino_usb_server.pl --usbportname /dev/cu.usbserial-ABC123 --port=7890 (default if omitted)

Use client to control server:

    arduino_usb_client.pl --on --port=7890 (default if omitted)
    
    arduino_usb_client.pl --off
    
    arduino_usb_client.pl --shutdown (shut down server gracefully)
