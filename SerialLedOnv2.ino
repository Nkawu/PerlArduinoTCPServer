int led = LED_BUILTIN;
int relay = 10; // pin 10
int state = 0;

void setup()
{
   Serial.begin(19200); // baud rate
   Serial.flush();
   pinMode(led, OUTPUT); // Set pin 13 as digital out
   pinMode(relay, OUTPUT);
}

void loop()
{
  String input = "";

  while ( Serial.available() > 0 )
  {
    input += (char) Serial.read();
    delay(5);
  }
  if ( input != "" )
  {
    input.trim();
    if ( input == "on" )
    {
      if ( state != 1 )
      {
        Serial.println("ON");
        digitalWrite(led, HIGH);
        digitalWrite(relay, HIGH);
        state = 1;
      }
    }
    else if ( input == "off" )
    {
      if ( state != 0 )
      {
        Serial.println("OFF");
        digitalWrite(led, LOW);
        digitalWrite(relay, LOW);
        state = 0;
      }
    }
  }
}
