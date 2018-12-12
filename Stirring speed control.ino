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
}
