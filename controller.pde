class Controller {

  
 int[] midiState;
 
 HashMap<String,Integer> mappings;
  
  
 public Controller() {
   midiState = new int[128];
   mappings = new HashMap<String, Integer>();
   setMappings();
 }
  
 
 int get(String mapping) {

   try {
     //println(mapping + ": " + midiState[mappings.get(mapping)]);
     return midiState[mappings.get(mapping)];
   }
   catch (Exception e) {
     println(mapping + ": -1");
     return -1; 
   }
   
 }
 
 
 void handleMidiEvent(int channel, int number, int val) {
   println("Handled " + channel + " " + number + " " + val);
   if (number >= 0) {
     midiState[number] = val;
   } 
   
 }


 

 void setMapping(String name, int control) {
   mappings.put(name, control);
 } 


 void setMappings() {
   mappings.put("rotationSpeed", KNOB3);
   mappings.put("drawSphere", BUTTON_M2);
   mappings.put("timeWarp", KNOB4);
   mappings.put("orbit", BUTTON_S2);
   mappings.put("minOrbit", SLIDER3);
   mappings.put("maxOrbit", SLIDER4);
 }
 
  
}
