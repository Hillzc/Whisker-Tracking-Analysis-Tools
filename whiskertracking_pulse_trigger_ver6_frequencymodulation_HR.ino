// Main board to control sync signal
// last edited on 2/17/2016
// Sunmee Park

#define PIN_GLOBAL_SYNC        2        // starts board 1, and sends out the signal to the board 2

#define PIN_EXTERNAL_TRIGGER  13        // for single pulse
#define PIN_EXTERNAL_TRIGGER2 12        // for single pulse

#define PIN_TRIGGER_PULSE     11        // for pulse train
#define PIN_TRIGGER_PULSE2     10

#define SINGLEPULSE            0
#define PULSETRAIN             1
#define INTENSITY              2
/*--------------------------
 variables
 --------------------------*/

char control_char;
int count = 0;

unsigned long timestamp;
unsigned long pulse_start;
boolean onSignal = false;
boolean onPulse = false;

int single_pulse_count = 0;

int pulse_count = 0;
int t_duration = 50; // longer than 10msec
//int freqArray[21] = {1,2,3,5,6,8,10,12,14,16,18,20,22,24,26,28,30,35,40,45,50} ; for mouse 1,2
int freqArray[15] = {
  1,2,3,4,5,6,7,8,9,10,12,15,20,25,30} 
;
int freq;
int dur_count = 0;
int signalChange = 0;
int freq_count=0;
int loop_count = 0;

/*-------------------------
 functions
 -------------------------*/

void setup() {

  pinMode(PIN_GLOBAL_SYNC, OUTPUT);
  pinMode(PIN_EXTERNAL_TRIGGER, OUTPUT);
  pinMode(PIN_EXTERNAL_TRIGGER2, OUTPUT);
  pinMode(PIN_TRIGGER_PULSE, OUTPUT);
  pinMode(PIN_TRIGGER_PULSE2, OUTPUT);

  digitalWrite(PIN_GLOBAL_SYNC, LOW);
  digitalWrite(PIN_EXTERNAL_TRIGGER, LOW);
  digitalWrite(PIN_EXTERNAL_TRIGGER2, LOW);
  digitalWrite(PIN_TRIGGER_PULSE, LOW);
  digitalWrite(PIN_TRIGGER_PULSE2, LOW);

  Serial.begin(9600);

  Serial.println("Enter s to start single pulse generation");
  Serial.println("Enter t to start pulse train generation");
  Serial.println("Enter i to start 20msec pulse for intensity stimulation");
  Serial.println("You can enter q(quit) during recording or p (pause)");
  Serial.println("Enter q to quit recording");

  onSignal = false;

}


void loop() {

  while (Serial.available() > 0) {
    control_char = Serial.read();

    if ( control_char == 't') {

      // output for the sync pulse to control light stim/ camera
      //  delay(100);
      //  digitalWrite(PIN_GLOBAL_SYNC, HIGH);
      onSignal = true;
      Serial.println("pulse train mode");
      signalChange = 1;
      count = 0;
      //count = 1;
      // timestamp = millis();
      // delay(100);
      //  digitalWrite(PIN_GLOBAL_SYNC, LOW);

    } 
    else if (control_char == 's') {


      onSignal = true;
      Serial.println("single pulse mode");
      signalChange = 0;

    } 
    else if (control_char == 'i'){

      Serial.println("single 20msec pulse for intensity mode");
      onSignal = true;
      signalChange = 2;

    }
    else if (control_char == 'q') {
      digitalWrite(PIN_GLOBAL_SYNC, LOW);
      onSignal = false;
      count = 0;
      break;
    } 
    else {
      Serial.println("Enter either s, t, p or q");
    }

  }

  while (onSignal)
  {
    if (Serial.available() > 0) {
      control_char = Serial.read();
      if (control_char == 'q') {
        digitalWrite(PIN_GLOBAL_SYNC, LOW);
        digitalWrite(PIN_TRIGGER_PULSE, LOW);
        onSignal = false;
        Serial.println("Trigger function stopped");
        count = 0;
        break;
      } 
      else if (control_char == 'p') {
        digitalWrite(PIN_GLOBAL_SYNC, LOW);
        digitalWrite(PIN_TRIGGER_PULSE, LOW);
        onSignal = false;
        Serial.println("Trigger function paused");
        break;
      }
    } 
    else {

      switch (signalChange) {
      case SINGLEPULSE:  //for single pulse with duration change

        delay(500);

        if (single_pulse_count <= 10){
          if (count < 11) {

            if (count == 0){

              Serial.print("Trial #:\t");
              Serial.println(single_pulse_count);
            }

            digitalWrite(PIN_GLOBAL_SYNC, HIGH);
            delay(1000);
            trigger(5+(5*single_pulse_count));
            Serial.print(5+(5*single_pulse_count));
            Serial.println("msec duration");
            delay(2000);
            digitalWrite(PIN_GLOBAL_SYNC, LOW);
            delay(10000);
            count ++;
          } 
          
          if (count == 11) {
            single_pulse_count++;
            count = 0;
          }

          if(single_pulse_count == 10){
            count = 0;
            onSignal = 0;
            digitalWrite(PIN_GLOBAL_SYNC, LOW);
            single_pulse_count = 0;
          } 

        }

        break;

      case PULSETRAIN:

        if(count<15){

          if (loop_count <10){

            if (freq_count == 0){

              freq = freqArray[count];
              Serial.print("Frequency:");
              Serial.print(freq);
              Serial.println("Hz");
              Serial.print("Trial#:");
              Serial.println(loop_count+1);

              digitalWrite(PIN_GLOBAL_SYNC, HIGH);
              delay(1000);

            }

            if (freq_count <freq){

              //            Serial.println(freq_count+1);
              digitalWrite(PIN_TRIGGER_PULSE, HIGH);
              digitalWrite(PIN_TRIGGER_PULSE2, HIGH);
              delay(t_duration);
              digitalWrite(PIN_TRIGGER_PULSE, LOW);
              digitalWrite(PIN_TRIGGER_PULSE2, LOW);
              delay((1000/freq)-t_duration);

              freq_count++;

            }
            else{

              freq_count = 0;
              delay(2000);
              digitalWrite(PIN_GLOBAL_SYNC, LOW);
              loop_count++;
              delay(5000);
            }
          } 
          else{
            count++;
            loop_count = 0;
            digitalWrite(PIN_GLOBAL_SYNC, LOW);
            digitalWrite(PIN_TRIGGER_PULSE, LOW);
            digitalWrite(PIN_TRIGGER_PULSE2, LOW);
          }
        }
        else{

          // count = 0;
          digitalWrite(PIN_GLOBAL_SYNC, LOW);
          digitalWrite(PIN_TRIGGER_PULSE, LOW);
          digitalWrite(PIN_TRIGGER_PULSE2, LOW);
          onSignal = 0;

        }


        break;

      case INTENSITY:

        digitalWrite(PIN_GLOBAL_SYNC, HIGH);
        delay(1000);
        digitalWrite(PIN_TRIGGER_PULSE, HIGH);
        delay(20);
        digitalWrite(PIN_TRIGGER_PULSE, LOW);
        delay(2000);
        digitalWrite(PIN_GLOBAL_SYNC, LOW);
        digitalWrite(PIN_TRIGGER_PULSE, LOW);

        onSignal = 0;

        break;

      }//end of case

    }//end of else

  } //end of while


}      //end of loop()

void trigger (int duration){ 
  digitalWrite(PIN_EXTERNAL_TRIGGER, HIGH);
  // digitalWrite(PIN_EXTERNAL_TRIGGER2, HIGH);
  digitalWrite(PIN_TRIGGER_PULSE, HIGH);
  delay(duration);
  //  digitalWrite(PIN_EXTERNAL_TRIGGER2, LOW);
  digitalWrite(PIN_EXTERNAL_TRIGGER, LOW);
  digitalWrite(PIN_TRIGGER_PULSE, LOW);
  //delay(100);
}

void pulse(int duration){

  // digitalWrite(PIN_TRIGGER_PULSE, HIGH);

  while (millis() - pulse_start < duration) {
    digitalWrite(PIN_TRIGGER_PULSE, HIGH);
  }
  digitalWrite(PIN_TRIGGER_PULSE, LOW);
  pulse_start = millis();
}

