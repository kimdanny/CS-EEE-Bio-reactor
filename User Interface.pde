//For testing motor speed with kit:
//1. Change speedInput allowed value intervals in mousePressed
//2. Possibly change increments(?)
//Centering of speed values has to be fixed
//Comment out serialEvent if working without Arduino


import processing.serial.*;
import java.util.*;

//Serial I/O
Serial serialPort;
String serialLine;
boolean inputFlag = false;

// Mouse flags
boolean mouseOverPlus = false;
boolean mouseOverMinus = false;
boolean mouseOverStart = false;

PFont primaryFont;
PFont secondaryFont;

// Button positions & properties
int buttonWidthPlusMinus = 30;
int buttonWidthStart = 120;
int buttonHeightPlusMinus = 30;
int buttonHeightStart = 40;
int plusButtonPositionX = 70, plusButtonPositionY = 200;
int minusButtonPositionX = plusButtonPositionX, minusButtonPositionY = plusButtonPositionY + 40;
int startButtonPositionX = 200 - buttonWidthStart/2, startButtonPositionY = plusButtonPositionY - 60; 
int cornerRadius = 3;

//Speed monitor positions and properties
int speedMonitorPositionX = plusButtonPositionX + 40;
int speedMonitorPositionY = plusButtonPositionY;
int speedMonitorWidth = 200;
int speedMonitorHeight = 70;
int speedInput = 0;
int speedFeedback;

// Colors
color plusMinusButtonBackground = color(255);
color startButtonBackground = #edb554;
color buttonHighlight = #edb545;
color textColor = color(0);

//*******************//
//Rendering functions//
//*******************//

void renderTitleBlock(String text) {
  stroke(20);
  fill(20);

  rect(0, 0, width, 100);
  fill(255);
  
  textFont(primaryFont, 40);
  text(text, width / 2 - textWidth(text) / 2, 70); 
  
  noFill();
}

void renderSpeedMonitor() {
  stroke(0);
  strokeWeight(3);
  rect(speedMonitorPositionX, speedMonitorPositionY, speedMonitorWidth, speedMonitorHeight, cornerRadius, cornerRadius, cornerRadius, cornerRadius);
  
  int speedOnDisplay;
  
  //If we're changing the value on the display, no feedback value is received from the Arduino 
  speedOnDisplay = speedFeedback;
  //println("Display:" + speedOnDisplay);
  
  String widthText = str(speedOnDisplay);

  float centerValuePositionX = (speedMonitorPositionX + speedMonitorWidth/2) - (textWidth(widthText))/2 - 3 ;
  if (speedOnDisplay > 99 && speedOnDisplay < 100) centerValuePositionX = centerValuePositionX - 20;
  else if (speedOnDisplay > 999 ) centerValuePositionX = centerValuePositionX - 20; 
  
  textFont(secondaryFont, 60);
  fill(textColor);
  text(speedFeedback, centerValuePositionX , plusButtonPositionY + 55);
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
  
  if (mouseOverPlus && text == "+") {
    stroke(buttonHighlight);
    fill(buttonHighlight);
  } else if (mouseOverMinus && text == "-") {
    stroke(buttonHighlight);
    fill(buttonHighlight);
  } else if (mouseOverStart && text == "Start") {
    stroke(100);
    fill(100);
  }
  
  rect(xButton, yButton, buttonWidth, buttonHeight, cornerRadius, cornerRadius, cornerRadius, cornerRadius);

  textFont(secondaryFont, 43);
  fill(textColor);
  if (text == "+") text(text, plusButtonPositionX + 3, yButton + buttonHeight/1.5 + 10);
  if (text == "-") text(text, plusButtonPositionX + 8, yButton + buttonHeight/1.5 + 8);
  if (text == "Start") {
    fill(255);
    textFont(secondaryFont, 33);
    text((text), xButton + 25, yButton + buttonHeight/1.5 + 5);
  }
}

//****************//
//Helper Functions//
//****************//
boolean isMouseOver(int x, int y, int windowWidth, int windowHeight) {
  return (mouseX >= x && mouseX <= x + windowWidth && mouseY >= y && mouseY <= y + windowHeight);
}

void updateButtonHoverings() {
  mouseOverPlus = isMouseOver(plusButtonPositionX, plusButtonPositionY, buttonWidthPlusMinus, buttonHeightPlusMinus);
  mouseOverMinus = isMouseOver(minusButtonPositionX, minusButtonPositionY, buttonWidthPlusMinus, buttonHeightPlusMinus);
  mouseOverStart = isMouseOver(startButtonPositionX, startButtonPositionY, buttonWidthStart, buttonHeightStart);
  
}

//************************//
//Built-In Event Functions//
//************************//

void mousePressed() {
  updateButtonHoverings();

  if ((mouseOverStart||mouseOverPlus) && speedInput == 0) {
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
  }
  println(speedInput);
}

void serialEvent(Serial serialPort) {
  if (inputFlag) return;
  
  serialLine = serialPort.readStringUntil('\n');
  // If we couldn't read a line, we return.
  if (serialLine == null) return;

  // Otherwise we remove excess whitespace from the ends of the line.
  serialLine = trim(serialLine);
  
  speedFeedback = int(serialLine);
  println("TEST: " + speedFeedback);
}

//**************//
//Core Functions//
//**************//

void setup() {
  size(400, 400);
  background(255);
  
  primaryFont = createFont("Arial Italic", 40, true);
  secondaryFont = createFont("Arial", 33, true);
  serialPort = new Serial(this, Serial.list()[0], 9600);
  serialPort.bufferUntil('\n');
 
}

void draw() {
  background(255);
  stroke(0);
  
  if (inputFlag) {
    //println(speedInput);
    serialPort.write(speedInput);
    inputFlag = false;
  }
  renderTitleBlock("Stirring Speed");
  renderSpeedMonitor();
  renderButton(plusButtonPositionX, plusButtonPositionY, buttonWidthPlusMinus, buttonHeightPlusMinus, plusMinusButtonBackground, "+");
  renderButton(minusButtonPositionX, minusButtonPositionY, buttonWidthPlusMinus, buttonHeightPlusMinus, plusMinusButtonBackground, "-");
  renderButton(startButtonPositionX, startButtonPositionY, buttonWidthStart, buttonHeightStart, startButtonBackground, "Start");
}
