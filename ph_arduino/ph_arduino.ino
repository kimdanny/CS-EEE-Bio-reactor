#include <math.h> 
int alkaline = 9;
int acid = 10;

void setup() 
{
  Serial.begin(9600);
  pinMode(acid, OUTPUT);
  pinMode(alkaline, OUTPUT);
  
}

void loop() 
{
  int sensor = analogRead(A0);
  float voltage = sensor * (5000/1024.0);
  float vph = voltage - 2500;
  float ph = 7 - ((vph/1000)*9.6485309*pow(10,4))/(8.314510*298*log(10));
  Serial.println(ph);

  if (ph > 5.5)
  {
    digitalWrite(acid, HIGH);
    digitalWrite(alkaline, LOW);
  }
  else if (ph < 4.5)
  {
    digitalWrite(alkaline, HIGH);
    digitalWrite(acid, LOW);
  }
  else
  {
    digitalWrite(alkaline, LOW);
    digitalWrite(acid, LOW);
  }
   
  delay(500);

}
