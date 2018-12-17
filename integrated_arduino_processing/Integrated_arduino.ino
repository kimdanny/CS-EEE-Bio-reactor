//For testing motor speed with kit:
// 1. Adjust range for analogWrite output
// 2. Uncomment UI communication if testing with UI 
 
//Pins//
int photointerrupter = 2;
int motor = 11;

//Speed data collection//
volatile int interruptCount = 0;
volatile int currentInterrupts;

String speedInput;
float value = 0;

//ph control
#include <math.h> 
int alkaline = 9;
int acid = 10;

// heating definition
#define THERMISTORPIN A0         
#define THERMISTORNOMINAL 10000      
#define TEMPERATURENOMINAL 24
#define NUMSAMPLES 5
#define BCOEFFICIENT 3980
#define SERIESRESISTOR 10000
#define HEATER_PIN 9  

uint16_t samples[NUMSAMPLES];
 
float setTemp = 30;


//*******************//
//Interrupt Functions//
//*******************//

void interruptCounter()  {
  interruptCount++;
}

ISR(TIMER1_COMPA_vect){//timer1 interrupt 1Hz toggles pin 13 (LED)
  currentInterrupts = interruptCount;
  interruptCount = 0;
}

//**************//
//Core Functions//
//**************//

void setup() {
  Serial.begin(9600);
   
  //Set pin modes//
  pinMode(photointerrupter, INPUT);
  pinMode(motor, OUTPUT);
  pinMode(13, OUTPUT);
  
  cli();

  //ph setup
  pinMode(acid, OUTPUT);
  pinMode(alkaline, OUTPUT);
  
 /*Set up a timer*/
  TCCR1A = 0;
  TCCR1B = 0;
  TCNT1  = 0;
  OCR1A = 15624;
  TCCR1B |= (1 << WGM12);
  TCCR1B |= (1 << CS12) | (1 << CS10);  
  TIMSK1 |= (1 << OCIE1A);

  sei();

  attachInterrupt(digitalPinToInterrupt(2), interruptCounter, RISING);

  // heating setup
  analogReference(EXTERNAL);
}

void loop(){
  int motorRPS = currentInterrupts;
  int motorRPM = motorRPS * 30;
  //Serial.print("motorRPM: ");
  //Serial.println(motorRPM);
  int printed = 3000 - value;

  //UI communication//
  if (Serial.available() > 0) {
    speedInput = Serial.read();
    //Serial.print("Received: ");
    //Serial.println(speedInput);
    value = (255.0/100.0) * speedInput.toInt();
  } 

  Serial.println(motorRPM);

  //Output for UI testing without motor 
  analogWrite(motor, value);
  delay(20);

  //ph loop
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
 
  Serial.print(steinhart);


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
