#define THERMISTORPIN A0         
#define THERMISTORNOMINAL 10000      
#define TEMPERATURENOMINAL 24
#define NUMSAMPLES 5
#define BCOEFFICIENT 3980
#define SERIESRESISTOR 10000
#define HEATER_PIN 9  

uint16_t samples[NUMSAMPLES];
 
float setTemp = 30;

void setup(void) {
  Serial.begin(9600);
  analogReference(EXTERNAL);
}
 
void loop(void) {
  
  // Temperature Reaing
  uint8_t i;
  float average;
 
  for (i=0; i< NUMSAMPLES; i++) {
   samples[i] = analogRead(THERMISTORPIN);
   delay(10);
  }
 
  average = 0;
  for (i=0; i< NUMSAMPLES; i++) {
     average += samples[i];
  }
  average /= NUMSAMPLES;
 
//  Serial.print("Average analog reading "); 
//  Serial.println(average);

  average = 1023 / average - 1;
  average = SERIESRESISTOR / average;
  //Serial.print("Thermistor resistance "); 
  //Serial.println(average);
 
  float steinhart;
  steinhart = average / THERMISTORNOMINAL;    
  steinhart = log(steinhart);     
  steinhart /= BCOEFFICIENT;
  steinhart += 1.0 / (TEMPERATURENOMINAL + 273.15);
  steinhart = 1.0 / steinhart;           
  steinhart -= 273.15;               
 
  //Serial.print("Temperature "); 
  Serial.print(steinhart);
  //Serial.println(" *C");

 
 
 
 
 //Temperature Regulation
  if (steinhart > setTemp){
    digitalWrite(HEATER_PIN, LOW);
    //Serial.println("----- Heater is off -----");
  }else{
    digitalWrite(HEATER_PIN, HIGH);
    //Serial.println("----- Heater is on -----");
  }
  delay(500);
}
