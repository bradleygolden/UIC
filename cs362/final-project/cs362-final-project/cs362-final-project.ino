#include <SimpleTimer.h>
#include <SoftwareSerial.h>

/*
  CS362 Final Project - Arduino Security System
  
  Author: Bradley Golden
 
 References:
 Magnet Switch:
 http://www.arduino.cc/en/Tutorial/Button
 Anode LED;
 https://learn.adafruit.com/adafruit-arduino-lesson-3-rgb-leds/breadboard-layout
 Keypad:
 http://arduino.cc/en/Tutorial/InputPullupSerial
 http://arduino.cc/en/Reference/pinMode
 SimpleTimer Library:
 http://playground.arduino.cc/Code/SimpleTimer
 */
 
 /**************Initialize Security System Variables**************/
 int warningActive = 0;
 int alarmActive = 0;
 int standbyActive = 0;
 int systemActive = 0;
 int neighborAlarmActive = 0;
 const int ON = 1;
 const int OFF = 0;
 const int WAIT = 2;
 int currColor[] = {0,0,0};
 int systemCode[] = {1,2,3};
 const int codeLength = 3;
 const int DISARM = 0;
 const int ARM = 1;
 const int DELAY = 2;
 const int delayAmount = 30; //30 seconds
 int currRGB[] = {0,0,0};
 
  /**************Initialize GSM Shield**************/
  SoftwareSerial SIM900(7, 8);
  char inchar; // Will hold the incoming character from the GSM shield
  String userPhone = "+18474213979"; //type your phone number here
  String neighborArduino = "+13129289735"; //type your neighbor's phone number here
  const int USER = 0;
  const int NEIGHBOR = 1;
  const int USER_WARNING = 2;
  
 /**************Initialize SimpleTimer Variable**************/
 SimpleTimer alarmCountdown;
 int countdownTime = 0;

/**************Initialize Magnet Door Switch**************/
const int magnetPin = 2;
int magnetState = 0;

/**************Initialize Tricolor Anode LED**************/
const int redPin = 3;
const int greenPin = 4;
const int bluePin = 5;
#define COMMON_ANODE

/**************Initialize Keypad**************/
const int keypadPin[] = {9,10,11,12};
int keypadState = 0;

/**************Initialize Stack Implementation**************/
int top = -1;
int stack[] = {0,0,0,0};


void setup() {
  setupLED();
  // initialize the Serial Monitor @ 19200
  Serial.begin(19200); 
  setupGSMShield(); 
  setupControlFromPhone();
  setupMagnet();
  setupKeypad();  
  toggleSystemFlags(ON, OFF, OFF, OFF);
  alarmCountdown.setInterval(1000, countdown);
}

void loop(){
  checkDoorOpen();
  
  readIncomingText(); //check if neighbor's alarm has been activated
  
  setCorrectLEDColors();
  
  if(doorIsOpen()){
    toggleSystemFlags(OFF, ON, OFF, WAIT);
  }
  
  if(countdownTime == 30){
    toggleAlarm(ON);
    //set text message
    sendSMS(USER);
    sendSMS(NEIGHBOR);
    toggleSystemFlags(OFF, OFF, ON, WAIT);
  }
  
  //door has been opened
  if(warningActive){
   alarmCountdown.run();
   allowKeypadEntry(DISARM);
  }
  else if(alarmActive){
    allowKeypadEntry(DISARM);
    readIncomingText();
  }
  //door is closed and the client wants to exit the building
  else{
    allowKeypadEntry(DELAY); //DELAY ARM by 30 seconds
  }
}

void sendSMS(int type)
{
  SIM900.print("AT+CMGF=1\r");//AT command to send SMS message
  delay(100);
  
  if(type == USER){
    SIM900.println("AT + CMGS = \""+ userPhone +"\""); // recipient's mobile number, in international format
    delay(100);
    SIM900.println("Bradley, you're front door has been opened!"
                   " Reply with #a0 to turn the Alarm off"); // message to send
  }
  
  else if(type == USER_WARNING){
    SIM900.println("AT + CMGS = \""+ userPhone +"\""); // recipient's mobile number, in international format
    delay(100);
    SIM900.println("Bradley, you're neighbor's front door has been opened!"
                   " Reply with #a0 to turn your system's warning off."); // message to send
  }
  
  else if(type == NEIGHBOR){
    SIM900.println("AT + CMGS = \""+ neighborArduino +"\""); // recipient's mobile number, in international format
    delay(100);
    SIM900.println("#a1"); // message to send
  }
  else {
    //do nothing
  }
  
  Serial.println("Text message sent!");
  delay(100);
  SIM900.println((char)26); // End AT command with a ^Z, ASCII code 26
  delay(100); 
  SIM900.println();
  delay(5000);  // give module time to send SMS
  SIM900power();   // turn off module
}

void SIM900power()
// software equivalent of pressing the GSM shield "power" button
{
  digitalWrite(9, HIGH);
  delay(1000);
  digitalWrite(9, LOW);
  delay(5000);
}

void setupControlFromPhone(){
  delay(30000);
  SIM900.print("AT+CMGF=1\r");  // set SMS mode to text
  delay(100);
  SIM900.print("AT+CNMI=2,2,0,0,0\r"); 
  // blurt out contents of new SMS upon receipt to the GSM shield's serial out
  delay(100);
  Serial.println("Ready...");
}

void readIncomingText(){
  
  //If a character comes in from the cellular module...
  if(SIM900.available() >0)
  {
    inchar=SIM900.read(); 
    if (inchar=='#')
    {
      delay(10);

      inchar=SIM900.read(); 
      if (inchar=='a')
      {
        delay(10);
        inchar=SIM900.read();
        if (inchar=='0')
        {
          Serial.println("Alarm Deactivated via Text");
            toggleAlarm(OFF);
            toggleSystemFlags(ON, OFF, OFF, OFF);
        } 
        else if (inchar=='1')
        {
          Serial.println("Neighbor's alarm has been activated.");
                        toggleSystemFlags(OFF, OFF, OFF, ON);
                        sendSMS(USER_WARNING);
        }
          SIM900.println("AT+CMGD=1,4"); // delete all SMS
      }
    }
  }
}

void setupGSMShield(){
  SIM900power();
  SIM900.begin(19200);
}

void setCorrectLEDColors(){
  if(standbyActive == 1){
    setColor(0,0,255);
  }
  else if(warningActive == 1){
    setColor(255,255,0);
  }
  else if(alarmActive == 1){
    setColor(255,0,0);
  }
  else if(neighborAlarmActive == 1){
    setColor(255,192,203);
  }
}

void toggleAlarm(int status){
  if(status == ON){
    Serial.println("ALARM!");
    countdownTime = 0;
  }
  else if(status == OFF){
    Serial.print("ALARM OFF!");
    countdownTime = 0;
  }
}

void countdown(){
  countdownTime++;
  Serial.print("Countdown: ");
  Serial.println(countdownTime);
}

void setupLED(){
  // initialize the ANNODE pins as an output
  pinMode(redPin, OUTPUT);    
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);
}

void setupMagnet(){
  pinMode(magnetPin, INPUT); // initialize the magnetswtich pin as an input
}

void setupKeypad(){
  // initialize the keypad pin(s) as an input:
  for(int x=0; x<4; x++)
  {
    pinMode(keypadPin[x], INPUT_PULLUP); 
  }
}

void setColor(int red, int green, int blue)
{
  #ifdef COMMON_ANODE
    red = 255 - red;
    green = 255 - green;
    blue = 255 - blue;
  #endif
  currRGB[0] = red;
  currRGB[1] = green;
  currRGB[2] = blue;
  analogWrite(redPin, red);
  analogWrite(greenPin, green);
  analogWrite(bluePin, blue);  
}

void activateSystem(){
  standbyActive = 1;
}

void checkDoorOpen(){
  // read the state of the magnet value:
  magnetState = digitalRead(magnetPin);
}

int doorIsOpen() {
  if (magnetState == LOW) {
    Serial.println("Door is open");
    return 1;
  }
  return 0;
}

void flashLED(int red, int green, int blue, int time){
    setColor(red, green, blue);
    delay(time);
}
 
 void allowKeypadEntry(int command){
   int pin[] = {9, 10, 11, 12};
   
   for(int x=0; x<4; x++){
    //signifying the state of which the button is in by reading the appropriate pin #
    keypadState = digitalRead(keypadPin[x]);
    
  // check if the pushbutton on the keypad is pressed.
  // if it is, the keypadState is LOW:
  //button 3
    if (keypadState == LOW && keypadPin[x] == 10) {
      Serial.println("BTN 3");
      int currKey = 3;
      inputKey(currKey); //push current inputted key onto the stack
      flashLED(0,255,0,150); //flash green to indicate key is pressed
      printStk(); //print the stack
    }
    
    //button 4 DISABLED DUE TO BUGGY BEHAVIOR
    //if (keypadState == LOW && keypadPin[x] == 9) {      
      //Serial.println("BTN 4");
      //int currKey = y + 1;
      //inputKey(currKey); //push current inputted key onto the stack
      //flashLED(0,255,0,150); //flash green to indicate key is pressed
      //printStk(); //print the stack
    //}
    
    //button 1
    if (keypadState == LOW && keypadPin[x] == 12) {    
      Serial.println("BTN 1");
      int currKey = 1;
      inputKey(currKey); //push current inputted key onto the stack
      flashLED(0,255,0,150); //flash green to indicate key is pressed
      printStk(); //print the stack
    }
	
	//button 2
    if (keypadState == LOW && keypadPin[x] == 11) {     
      Serial.println("BTN 2");
      int currKey = 2;
      inputKey(currKey); //push current inputted key onto the stack
      flashLED(0,255,0,150); //flash green to indicate key is pressed
      printStk(); //print the stack
    }
  }
  delay(250);

  if(codeEnteredCorrectly() && command == DISARM){
      disarm(); //disarm the warning
      resetKeyInput();
      countdownTime = 0; //reset countdown to 0 seconds
      toggleSystemFlags(ON, OFF, OFF, WAIT);
  }
  else if(codeEnteredCorrectly() && command == DELAY){
    delayArm();
    resetKeyInput();
    countdownTime = 0; //reset countdown to 0 seconds
    toggleSystemFlags(ON, OFF, OFF, WAIT);
   }
   else if(fourDigitsEntered() && !codeEnteredCorrectly()){
    //flash long red to indicate unsuccessfull password input
    flashLED(255,0,0,500);
    resetKeyInput();
    toggleSystemFlags(WAIT,WAIT,WAIT,WAIT);
   }
 }
 
 void toggleSystemFlags(int standby, int warning, int alarm, int neighbor){
   
   //system standby flag
   if(standby == ON){
     standbyActive = ON;
   }
   else if(standby == WAIT){
     //do nothing
   }
   else {
     standbyActive = OFF;
   }
   
   //system warning flag
   if(warning == ON){
     warningActive = ON;
   }
   else if(warning == WAIT){
     //do nothing
   }
   else {
     warningActive = OFF;
   }
   
   //system alarm flag
   if(alarm == ON){
     alarmActive = ON;
   }
   else if(alarm == WAIT){
     //do nothing
   }
   else {
     alarmActive = OFF;
   }
   
   //neighbor's alarm flag
   if(neighbor == ON){
     neighborAlarmActive = ON;
   }
   else if(neighbor == WAIT){
     //do nothing
   }
   else {
     neighborAlarmActive = OFF;
   }
   
 }
 
 //delay for specified time
 //allows use to leave their house without setting off the alarm
 void delayArm(){
   int i = 0;
      while(i < delayAmount){
        delay(500); //delay .5 seconds
        setColor(255,0,0); //change color to red
        delay(500); //delay .5 seconds
        setColor(0,0,255); //change color to blue
        i++;
        Serial.print("Delay Arm: ");
        Serial.println(i);
      }
 }
 
 void disarm(){
    //flash long green to indicate successfull password input to client
    flashLED(0,255,0,500);
    toggleSystemFlags(ON, OFF, OFF, OFF);
    resetKeyInput();
 }
 
 void resetKeyInput(){
   resetStk();
 }
 
 int codeEnteredCorrectly(){
   return stkMatchesSystemCode();
 }
 
 int fourDigitsEntered(){
   if(stkIsFull()){
     return 1;
   }
   return 0;
 }
 
 int stkMatchesSystemCode(){
   int correct = 0;
   
   for(int i=0; i<codeLength; i++){
     if(stack[i] == systemCode[i]){ //check that contents in stack are the same as the system code
       correct++;
     }
   }
   if(correct == codeLength){
     return 1;
   }
   else{
     return 0;
   }
 }
 
 void inputKey(int key){
     push(key);
 }
 
 void printStk(){
   int i;
   for(i=0; i<codeLength; i++){
     Serial.print("[");
     Serial.print(stack[i]);
     Serial.print("]");
   }
   Serial.println("");
 }
 
 void push(int val){
   if(stkIsFull()){
     resetStk();
   }
   top++;
   stack[top] = val;
 }
 
 int stkIsFull(){
   if(top >= codeLength-1){
     return 1;
   }
   return 0;
 }
 
 void resetStk(){
   int i;
   for(i=0; i<codeLength; i++){
     stack[i] = 0;
   }
   top = -1;
 }
 
 int pop(){
   int val = stack[top];
   top--;
   return val;
 }
