// If you're opening this without Arduino, comment out serialPort function in setup
//SerialEven tis set to receive temperature values, make sure to set up the scale correctly
//Function for sending the values is in draw() (writePort(blahblah)) 


import processing.serial.*;
import meter.*;

//Serial I/O
Serial serialPort;

//changed
int[] serial_arr = new int[3];
int serial_cnt = 0;

boolean inputFlag;

// Mouse flags
//Temperature
boolean tempmouseOverPlus = false;
boolean tempmouseOverMinus = false;
//Speed
boolean mouseOverPlus = false;
boolean mouseOverMinus = false;
boolean mouseOverStart = false;
//pH
boolean phmouseOverPlus = false;
boolean phmouseOverMinus = false;

//*****//
//Style//
//*****//
PFont primaryFont;
PFont secondaryFont; 


//Meter positions & properties
Meter m;
int meterPositionX = 20;
int meterPositionY = 182;
//Colors
color primaryBackground = color(255);
color secondaryBackground = #edb554;
color scaleHighlight = #edb545;


//******************************//
// Button positions & properties//
//******************************//

//Temperature
int buttonWidthPlusMinus = 30;
int buttonWidthStart = 90;
int buttonHeightPlusMinus = 30;
int buttonHeightStart = 40;
int tempminusButtonPositionX = 135, tempminusButtonPositionY = meterPositionY + 300;
int tempplusButtonPositionX = tempminusButtonPositionX + 180, tempplusButtonPositionY = tempminusButtonPositionY;
int cornerRadius = 3;
//Speed
int plusButtonPositionX = 450 + 70, plusButtonPositionY = 300;
int minusButtonPositionX = plusButtonPositionX, minusButtonPositionY = plusButtonPositionY + 40;
int startButtonPositionX = plusButtonPositionX + 90, startButtonPositionY = plusButtonPositionY - 60; 
//pH
int phplusButtonPositionX =  490 + 480 + 10, phplusButtonPositionY = 300;
int phminusButtonPositionX = phplusButtonPositionX, phminusButtonPositionY = plusButtonPositionY + 40;

//******************************************************//
//Speed and temperature monitor positions and properties//
//******************************************************//
//Temperature
int temperatureMonitorPositionX = tempminusButtonPositionX + 40;
int temperatureMonitorPositionY = tempminusButtonPositionY - 10;
int temperatureMonitorWidth = 130;
int temperatureMonitorHeight = 50;
int temperatureInput = 0;
int temperatureFeedback;

//Speed
int speedMonitorPositionX = plusButtonPositionX + 40;
int speedMonitorPositionY = plusButtonPositionY;
int speedMonitorWidth = 200;
int speedMonitorHeight = 70;
int speedInput = 17;
int speedFeedback = 2500;

//pH
int phMonitorPositionX =  phplusButtonPositionX + 40;
int phMonitorPositionY = phplusButtonPositionY;
int pHInput = 17;
int pHFeedback = 2500;
int phMonitorWidth = 150;
float phFeedback = 7.60;
float phOnDisplay;

// Colors
color plusMinusButtonBackground = primaryBackground;
color startButtonBackground = secondaryBackground;
color buttonHighlight = scaleHighlight;
color textColor = color(0);


//*******************//
//Rendering Functions//
//*******************//
void renderMainTitleBlock(String text) {
  stroke(20);
  fill(20);

  rect(0, 0, width, 100);
  fill(255);
  
  textFont(primaryFont, 40);
  text(text, width / 2 - textWidth(text) / 2, 70); 
  
  noFill();
}

void renderSecondaryTitleBlock(String text, int x , int widthBlock) {
  stroke(50);
  fill(20);

  rect(x, 100, widthBlock, 80, cornerRadius, cornerRadius, cornerRadius, cornerRadius);
  fill(255);
  
  textFont(secondaryFont, 30);
  text(text, x + widthBlock / 2 - textWidth(text) / 2, 150); 
  
  noFill();
}

void renderTemperatureSpeedMonitor() {
  stroke(0);
  strokeWeight(2);
  fill(#fffcf5);
  rect(temperatureMonitorPositionX, temperatureMonitorPositionY, temperatureMonitorWidth, temperatureMonitorHeight, cornerRadius, cornerRadius, cornerRadius, cornerRadius);
  
  int temperatureOnDisplay;
  
  //If we're changing the value on the display, no feedback value is received from the Arduino 
  if (inputFlag) {
    temperatureOnDisplay = temperatureInput;
    inputFlag = false;
  } else temperatureOnDisplay = temperatureFeedback;
  
  
  String widthText = str(temperatureOnDisplay);

  float centerValuePositionX = (temperatureMonitorPositionX + temperatureMonitorWidth/2) - (textWidth(widthText))/2 - 25 ;
  
  textFont(secondaryFont, 40);
  fill(textColor);
  text(temperatureInput + " °C", centerValuePositionX , tempplusButtonPositionY + 30);
  noFill();
}

void renderSpeedMonitor() {
  stroke(0);
  strokeWeight(3);
  fill(#fffcf5);
  rect(speedMonitorPositionX, speedMonitorPositionY, speedMonitorWidth, speedMonitorHeight, cornerRadius, cornerRadius, cornerRadius, cornerRadius);
  
  int speedOnDisplay;
  
  //If we're changing the value on the display, no feedback value is received from the Arduino 
  speedOnDisplay = speedFeedback;
  //println("Display:" + speedOnDisplay);
  
  String widthText = str(speedOnDisplay);

  float centerValuePositionX = (speedMonitorPositionX + speedMonitorWidth/2) - (textWidth(widthText))/2 - 3 ;
  if (speedOnDisplay > 99 && speedOnDisplay < 1000) centerValuePositionX = centerValuePositionX - 20;
  else if (speedOnDisplay > 999 ) centerValuePositionX = centerValuePositionX - 20; 
  
  textFont(secondaryFont, 60);
  fill(textColor);
  text(speedFeedback, centerValuePositionX - 10 , plusButtonPositionY + 55);
  textFont(secondaryFont, 50);
  fill(textColor);
  text( "RPM", (speedMonitorPositionX + speedMonitorWidth + 20), plusButtonPositionY + 55);
  textFont(secondaryFont, 80);
  
  noFill();
  
  
}

void renderPhMonitor() {
  stroke(0);
  strokeWeight(3);
  fill(#fffcf5);
  rect(phMonitorPositionX, phMonitorPositionY, phMonitorWidth, speedMonitorHeight, cornerRadius, cornerRadius, cornerRadius, cornerRadius);
  
  //If we're changing the value on the display, no feedback value is received from the Arduino 
  phOnDisplay = pHFeedback;
  //println("Display:" + speedOnDisplay);
  
  String widthText = str(phOnDisplay);

  float centerValuePositionX = (phMonitorPositionX + speedMonitorWidth/2) - (textWidth(widthText))/2 - 3 ;
  if (phOnDisplay > 99 && phOnDisplay < 1000) centerValuePositionX = centerValuePositionX - 20;
  else if (phOnDisplay > 999 ) centerValuePositionX = centerValuePositionX - 20; 
  
  textFont(secondaryFont, 60);
  fill(textColor);
  text("7.36", centerValuePositionX - 2 , phplusButtonPositionY + 55);
  textFont(secondaryFont, 50);
  fill(textColor);
  textFont(secondaryFont, 80);
  
  noFill();
  
  
}


void renderButton(int xButton, int yButton, int buttonWidth, int buttonHeight, color buttonBackground, String text) {
  updateButtonHoverings();
  
  fill(buttonBackground);
  
  stroke(255);
  strokeWeight(5);
  if (text == "Start") {
    stroke(buttonBackground);
    strokeWeight(3);
  }
  
  if (tempmouseOverPlus && text == "+" && xButton == tempplusButtonPositionX) {
    stroke(buttonHighlight);
    fill(buttonHighlight);
  } else if (tempmouseOverMinus && text == "-" && xButton == tempminusButtonPositionX) {
    stroke(buttonHighlight);
    fill(buttonHighlight);
  } else if (mouseOverPlus && text == "+" && xButton == plusButtonPositionX) {
    stroke(buttonHighlight);
    fill(buttonHighlight);
  } else if (mouseOverMinus && text == "-" && xButton == minusButtonPositionX) {
    stroke(buttonHighlight);
    fill(buttonHighlight);
  } else if (mouseOverStart && text == "Start") {
    stroke(100);
    fill(100);
  } else if (phmouseOverPlus && text == "+" && xButton == phplusButtonPositionX) {
    stroke(buttonHighlight);
    fill(buttonHighlight);
  } else if (phmouseOverMinus && text == "-" && xButton == phminusButtonPositionX) {
    stroke(buttonHighlight);
    fill(buttonHighlight);
  } else if (text == "+" || text == "-") {
    fill(200);
    stroke(200);
  }
  
  rect(xButton, yButton, buttonWidth, buttonHeight, cornerRadius, cornerRadius, cornerRadius, cornerRadius);

  textFont(secondaryFont, 43);
  fill(textColor);
  if (text == "+" && xButton == tempplusButtonPositionX) text(text, tempplusButtonPositionX + 3, yButton + buttonHeight/1.5 + 10);
  if (text == "+" && xButton == plusButtonPositionX) text(text, plusButtonPositionX + 3, yButton + buttonHeight/1.5 + 10);
  if (text == "+" && xButton == phplusButtonPositionX) text(text, phplusButtonPositionX + 3, yButton + buttonHeight/1.5 + 10);
  if (text == "-"&& xButton == tempminusButtonPositionX) text(text, tempminusButtonPositionX + 8, yButton + buttonHeight/1.5 + 8);
  if (text == "-"&& xButton == phminusButtonPositionX) text(text, phminusButtonPositionX + 8, yButton + buttonHeight/1.5 + 8);
  if (text == "-"&& xButton == minusButtonPositionX ) text(text, minusButtonPositionX + 8, yButton + buttonHeight/1.5 + 8);
  if (text == "Start") {
    fill(255);
    textFont(secondaryFont, 33);
    text(text, xButton + 10, yButton + buttonHeight/1.5 + 5);
  }  
}

//****************//
//Helper Functions//
//****************//
boolean isMouseOver(int x, int y, int windowWidth, int windowHeight) {
  return (mouseX >= x && mouseX <= x + windowWidth && mouseY >= y && mouseY <= y + windowHeight);
}

void updateButtonHoverings() {
  tempmouseOverPlus = isMouseOver(tempplusButtonPositionX, tempplusButtonPositionY, buttonWidthPlusMinus, buttonHeightPlusMinus);
  tempmouseOverMinus = isMouseOver(tempminusButtonPositionX, tempminusButtonPositionY, buttonWidthPlusMinus, buttonHeightPlusMinus);
  mouseOverPlus = isMouseOver(plusButtonPositionX, plusButtonPositionY, buttonWidthPlusMinus, buttonHeightPlusMinus);
  mouseOverMinus = isMouseOver(minusButtonPositionX, minusButtonPositionY, buttonWidthPlusMinus, buttonHeightPlusMinus);
  mouseOverStart = isMouseOver(startButtonPositionX, startButtonPositionY, buttonWidthStart, buttonHeightStart);
  phmouseOverPlus = isMouseOver(phplusButtonPositionX, phplusButtonPositionY, buttonWidthPlusMinus, buttonHeightPlusMinus);
  phmouseOverMinus = isMouseOver(phminusButtonPositionX, phminusButtonPositionY, buttonWidthPlusMinus, buttonHeightPlusMinus);
}


//***************//
//Event Functions//
//***************//
void mousePressed() {
  updateButtonHoverings();

if (tempmouseOverPlus && temperatureInput < 100) {
    inputFlag = true;
    temperatureInput += 1;
  } else if (tempmouseOverMinus && temperatureInput > 20) {
    inputFlag = true;
    temperatureInput -= 1;  
  } else if (tempmouseOverMinus && temperatureInput <= 20) {
    inputFlag = true;
    temperatureInput = 0;  
  } else if ((mouseOverStart||mouseOverPlus) && speedInput == 0) {
    inputFlag = true;
    speedInput = 10;
  } else if (mouseOverPlus && speedInput <= 90) {
    inputFlag = true;
    speedInput += 10;
  } else if (mouseOverMinus && speedInput > 10) {
    inputFlag = true;
    speedInput -= 10;  
  } else if (mouseOverMinus && speedInput <= 10) {
    inputFlag = true;
    speedInput = 0;  
  } else if (mouseOverPlus && pHInput <= 14) {
    inputFlag = true;
    pHInput += 1;
  } else if (mouseOverMinus && pHInput > 0) {
    inputFlag = true;
    pHInput -= 1;
  }
  
  println(temperatureInput);
}

void serialEvent(Serial serialPort) {
  if (inputFlag) return;
  
  String serialLine = serialPort.readStringUntil('\n');
  // If we couldn't read a line, we return.
  if (serialLine == null) return;

  // Otherwise we remove excess whitespace from the ends of the line.
  serialLine = trim(serialLine);
  
  temperatureFeedback = int(serialLine);
  temperatureFeedback = temperatureInput;
}

//**************//
//Core functions//
//**************//

void setup() {
  //changed
  String arduino = Serial.list()[1];
  serialPort = new Serial(this, arduino, 9600);
  
  size(1230, 550);
  background(255);
  
  primaryFont = createFont("Arial Italic", 40, true);
  secondaryFont = createFont("Arial", 33, true);
  
  //serialPort = new Serial(this, Serial.list()[0], 9600);
  //serialPort.bufferUntil('\n');
  
  //Meter properties
  m = new Meter(this, meterPositionX, meterPositionY);
  m.setTitleFontColor(color(255));
  m.setFrameColor(color(255));
  
  String[] scaleLabels = {"0", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100"};
  m.setScaleLabels(scaleLabels);
  m.setScaleFontSize(18);
  m.setScaleFontName("Arial");
  m.setScaleFontColor(textColor);
  
  // We can also display the value of meter
  m.setDisplayDigitalMeterValue(false);
  
  // Lets do some more modifications so our meter looks nice
  m.setArcColor(scaleHighlight);
  m.setArcThickness(15);
  
  m.setMaxScaleValue(100);
  
  m.setMinInputSignal(0);
  m.setMaxInputSignal(100);
  
  m.setNeedleThickness(3);
  m.setNeedleColor(color(0));
}

void draw() {
  background(255);
  //  <Getting multiple information from Arduino at the same time using a list>
    String val_str = serialPort.readStringUntil('\n');
    if(val_str != null){
      //getting a clean integer value
       val_str = trim(val_str);
       int val = int(val_str);
       
       serial_arr[serial_cnt] = val;
       serial_cnt++;
       //resetting serial count
       if(serial_cnt > 2){
         serial_cnt = 0;
       }
        
        int temperature = serial_arr[0];
        int ph = serial_arr[1];
        int stirring = serial_arr[2];
        
        println(temperature);
        println(ph);
        println(stirring);
    }
  
  if (inputFlag) {
    println("TEST");
    //serialPort.write(temperatureInput);
  }
  renderMainTitleBlock("Bioreactor Control System");
  renderSecondaryTitleBlock("Temperature", 0, 450);
  renderSecondaryTitleBlock("Stirring", 450, 480);
  renderSecondaryTitleBlock("pH", 450 + 480, 300);
  
  
  m.updateMeter(temperatureInput);
  renderSpeedMonitor();
  renderTemperatureSpeedMonitor();
  renderPhMonitor();
  
  renderButton(tempplusButtonPositionX, tempplusButtonPositionY, buttonWidthPlusMinus, buttonHeightPlusMinus, plusMinusButtonBackground, "+");
  renderButton(tempminusButtonPositionX, tempminusButtonPositionY, buttonWidthPlusMinus, buttonHeightPlusMinus, plusMinusButtonBackground, "-");
  renderButton(phplusButtonPositionX, phplusButtonPositionY, buttonWidthPlusMinus, buttonHeightPlusMinus, plusMinusButtonBackground, "+");
  renderButton(phminusButtonPositionX, phminusButtonPositionY, buttonWidthPlusMinus, buttonHeightPlusMinus, plusMinusButtonBackground, "-");
  renderButton(plusButtonPositionX, plusButtonPositionY, buttonWidthPlusMinus, buttonHeightPlusMinus, plusMinusButtonBackground, "+");
  renderButton(minusButtonPositionX, minusButtonPositionY, buttonWidthPlusMinus, buttonHeightPlusMinus, plusMinusButtonBackground, "-");
  renderButton(startButtonPositionX, startButtonPositionY, buttonWidthStart, buttonHeightStart, startButtonBackground, "Start");
}
