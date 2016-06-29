// Two LED Whisker Stimulation Patterns
// Hill Chang
// last edited on 6/16/16


#define CAMERA        2        

#define PIN_EXTERNAL_TRIGGER  13        
#define PIN_EXTERNAL_TRIGGER2 12        

#define PIN_TRIGGER_PULSE     11        
#define PIN_TRIGGER_PULSE2     10

#define DURATIONTRIAL    1
#define SINGLEFREQUENCY  2
#define DOUBLEFREQUENCY  3
#define TIMEDIFF         4

/*--------------------------
 variables
 --------------------------*/
char controlChar;
boolean onSignal = false;
int count = 0;
int singlePulseCount = 0;
int frequency = 2;
int frequencyDuration = 50;
int frequencyInterval = (1000/frequency)-frequencyDuration;
int signalChange;
int timeDiffCount = 0;
char buffer[] = {' ',' ',' ',' ',' ',' ',' '}; // Receive up to 7 bytes

/*-------------------------
 functions
 -------------------------*/

void setup() 
{
  
  pinMode(CAMERA, OUTPUT);
  pinMode(PIN_EXTERNAL_TRIGGER, OUTPUT);
  pinMode(PIN_EXTERNAL_TRIGGER2, OUTPUT);
  pinMode(PIN_TRIGGER_PULSE, OUTPUT);
  pinMode(PIN_TRIGGER_PULSE2, OUTPUT);

  digitalWrite(CAMERA, LOW);
  digitalWrite(PIN_EXTERNAL_TRIGGER, LOW);
  digitalWrite(PIN_EXTERNAL_TRIGGER2, LOW);
  digitalWrite(PIN_TRIGGER_PULSE, LOW);
  digitalWrite(PIN_TRIGGER_PULSE2, LOW);

  Serial.begin(9600);

  Serial.println("TWO LED WHISKER STIMULATION PATTERNS");
  Serial.println("Choose which stimulation pattern to run.");
  Serial.println("(Type 'h' to see list of available patterns.)");
  Serial.println("Type 'p' at any time to pause.");
  Serial.println("Type 'q' at amy time to quit.");

  onSignal = false;

}


void loop() 
{
  
  while (Serial.available() > 0) // Check what user has entered 
  {
    controlChar = Serial.read();
    switch(controlChar)
    {
      case 'h':
        Serial.println("1. Duration: 5ms to 80ms in 15ms increments, x8");
        Serial.println("2. Single LED Natural Frequency");
        Serial.println("3. Double LED Natural Frequency");
        Serial.println("4. Double LED Time Difference Pattern");
        break;
      case '1':
        Serial.println("Starting Duration: 5ms to 80ms in 15ms increments, x8");
        onSignal = true;
        signalChange = 1;
        break;
      case '2':
        Serial.println("Starting Single LED Natural Frequency");
        onSignal = true;
        signalChange = 2;
        break;
      case '3':
        Serial.println("Starting Double LED Natural Frequency");
        onSignal = true;
        signalChange = 3;
        break;
      case '4':
        Serial.println("Starting Double LED Time Difference");
        onSignal = true;
        signalChange = 4;
        break;
      case 'p':
        Serial.println("Paused.");
        onSignal = false;
        break;
      case 'q':
        Serial.println("Quitting.");
        onSignal = false;
        controlChar = 0;
        count = 0;
        break;
      default:
        Serial.println("Awaiting command.");
      break;
    }

  }

  while (onSignal)
  {
    if (Serial.available() > 0) // Check if user has decided to quit or pause
    {
      controlChar = Serial.read();
      if (controlChar == 'q') {
        digitalWrite(CAMERA, LOW);
        digitalWrite(PIN_TRIGGER_PULSE, LOW);
        onSignal = false;
        Serial.println("Quitting.");
        count = 0;
        controlChar = 0;
        break;
      } 
      else if (controlChar == 'p') {
        digitalWrite(CAMERA,LOW);
        digitalWrite(PIN_TRIGGER_PULSE, LOW);
        onSignal = false;
        Serial.println("PAUSING");
        break;
      }
    } 
    else 
    {
      switch (signalChange) 
      {
        case DURATIONTRIAL:  //duration trial

          delay(500);
  
          if (count <= 8)
          {
            if (singlePulseCount < 6) 
            {
  
              if (singlePulseCount == 0)
              {
  
                Serial.print("Trial #:\t");
                Serial.println(count);
              }
  
              digitalWrite(CAMERA, HIGH);
              delay(1000);
              triggerLightOne(5+(15*singlePulseCount));
              Serial.print(5+(15*singlePulseCount));
              Serial.println("msec duration");
              delay(2000);
              digitalWrite(CAMERA, LOW);
              delay(8000);
              
              digitalWrite(CAMERA, HIGH);
              delay(1000);
              triggerLightTwo(5+(15*singlePulseCount));
              Serial.print(5+(15*singlePulseCount));
              Serial.println("msec duration");
              delay(2000);
              digitalWrite(CAMERA, LOW);
              delay(10000);
              
              
              singlePulseCount++;
            } 
            
            if (singlePulseCount == 6) 
            {
              count++;
              singlePulseCount = 0;
            }
  
            if(count == 8)
            {
              count = 0;
              onSignal = 0;
              digitalWrite(CAMERA, LOW);
              singlePulseCount = 0;
            } 
  
          }

        break;

        case SINGLEFREQUENCY: // Single LED Frequency
          delay(500); 
          if (count==0)
          {
            Serial.println("Input duration, in ms");
            while(Serial.available()==0) {}
            Serial.readBytesUntil('n', buffer, 7);
            frequencyDuration = atoi(buffer);
          }
          if (count <= 8)
          {
            digitalWrite(CAMERA, HIGH);
            delay(1000);
            Serial.print("Trial #:\t");
            Serial.println(count);
//            Serial.print("Frequency:"); 
//            Serial.println(frequency)
//            for (int i = 0; i < frequency; i++)
//            {
//              triggerLightOne(frequencyDuration);
//              delay(frequencyInterval);
//            }
            for (int i = 1; i <= floor(3000/(frequencyDuration*2)); i++)
            {
              triggerLightOne(frequencyDuration);
              delay(frequencyDuration);
            }
            delay(1000);
            Serial.print(floor(3000/(frequencyDuration*2)));
            Serial.print(" bouts of ");
            Serial.print(frequencyDuration);
            Serial.println(" ms");
            digitalWrite(CAMERA,LOW);
            digitalWrite(CAMERA, LOW);
            delay(10000);
            count++;
            if (count == 8)
            {
              count = 0;
              onSignal = 0;
              Serial.println("Single LED Frequency Pattern complete");
            }
          }
        break;

        case DOUBLEFREQUENCY: // Double LED Frequency
          delay(500);
          if (count==0)
          {
            Serial.println("Input duration, in ms");
            while(Serial.available()==0) {}
            Serial.readBytesUntil('n', buffer, 7);
            frequencyDuration = atoi(buffer);
          }
          if (count <= 8)
          {
            digitalWrite(CAMERA, HIGH);
            delay(1000);
            Serial.print("Trial #:\t");
            Serial.println(count);
//            Serial.print("Frequency:"); 
//            Serial.println(frequency)
//            for (int i = 0; i < frequency; i++)
//            {
//              triggerLightOne(frequencyDuration);
//              triggerLightTwo(frequencyInterval);
//            }
            for (int i = 1; i <= 50; i = i+1) 
            {
              triggerLightOne(frequencyDuration);
              triggerLightTwo(frequencyDuration);
            }
            delay(1000);
            Serial.print(floor(3000/(frequencyDuration*2)));
            Serial.print(" bouts of ");
            Serial.print(frequencyDuration);
            Serial.println(" ms");
            digitalWrite(CAMERA,LOW);
            delay(10000);
            
            count++;
            if (count == 8)
            {
              count = 0;
              onSignal = 0;
              Serial.println("Double LED Frequency Pattern complete");
            }
          }
        break;
        
        case TIMEDIFF:
          delay(500);
          if (count==0 && timeDiffCount == 0)
          {
            Serial.println("Input duration, in ms");
            while(Serial.available()==0) {}
            Serial.readBytesUntil('n', buffer, 7);
            frequencyDuration = atoi(buffer);
          }
          if (count <= 8)
          {
            if (timeDiffCount == 0)
            {
              Serial.print("Trial #:\t");
              Serial.println(count);
            }
            digitalWrite(CAMERA,HIGH);
            delay(1000);
            triggerLightOne(frequencyDuration);
            delay(timeDiffCount*10);
            triggerLightTwo(frequencyDuration);
            delay(1500-(2*frequencyDuration+timeDiffCount*10));
            Serial.print("Light Duration of ");
            Serial.print(frequencyDuration);
            Serial.print(" ms separated by ");
            Serial.print(timeDiffCount*10);
            Serial.println(" ms");
            digitalWrite(CAMERA,LOW);
            timeDiffCount++;
            delay(8000);
            if (timeDiffCount == 3)
            {
              timeDiffCount = 0;
              count++;
            }
            if (count == 8)
            {
              count = 0;
              onSignal = 0;
              Serial.println("Double LED Time Difference Pattern complete");
            }
          }
        break;

      }//end of case

    }//end of else

  } //end of while


}      //end of loop()

void triggerLightOne (int duration)
{ 
  // Serial.println("Activating Light One");
  digitalWrite(PIN_EXTERNAL_TRIGGER, HIGH);
  digitalWrite(PIN_TRIGGER_PULSE, HIGH);
  delay(duration);
  digitalWrite(PIN_EXTERNAL_TRIGGER, LOW);
  digitalWrite(PIN_TRIGGER_PULSE, LOW);
}
  
void triggerLightTwo (int duration)
{ 
  // Serial.println("Activating Light Two");
  digitalWrite(PIN_EXTERNAL_TRIGGER2, HIGH);
  digitalWrite(PIN_TRIGGER_PULSE2, HIGH);
  delay(duration);
  digitalWrite(PIN_EXTERNAL_TRIGGER2, LOW);
  digitalWrite(PIN_TRIGGER_PULSE2, LOW);
}


