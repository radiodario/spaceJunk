class Debris {
  Sgp4Unit debrisUnit;
  Sgp4Data debrisData;

  public Debris(Sgp4Unit du) {
    this.debrisUnit = du;
  }

  // draw the debris
  void draw(PApplet p) {
    if (debrisData != null) {
      p.pushMatrix();
      p.stroke(255);

      p.translate((float)(debrisData.getX() * factor), 
      (float)(debrisData.getY() * factor), 
      (float)(debrisData.getZ() * factor));

      Vector3d vel = debrisData.getVel();

      p.stroke(239, 12, 246, 100);
      p.strokeWeight(1);
      p.line(0, 0, 0, (float)(vel.x), (float)(vel.y), (float)(vel.z));

      p.strokeWeight(3);
      p.stroke(255);
      p.point(0, 0, 0);
      p.popMatrix();
    }
  }

  // update the debris
  void update(int currentYear, double currentDay) throws ObjectDecayed {
    this.debrisData = debrisUnit.runSgp4(currentYear, currentDay);
  }
}



class DebrisSwarm extends Thread {

//  List<Debris> debris;
  ArrayList<Debris> debris;
  ArrayList<Debris> _debris;
  GregorianCalendar cal;
  int currentYear;
  double currentDay;
  long startTime;
  
  String dataSource;

  boolean loaded;
  int timeWarp;
    
  long msInDay = 24 * 3600 * 1000;

  // konstruktur
  public DebrisSwarm(String loc) {
    cal = new GregorianCalendar();
    timeWarp = 1; 
    debris = new ArrayList<Debris>();
    _debris = new ArrayList<Debris>();
    dataSource = loc;
    loaded = false;
    readDebris(dataSource);
  
    
  }
  
  void setupClock() {
    int hours = cal.get(GregorianCalendar.HOUR_OF_DAY);
    int minutes = cal.get(GregorianCalendar.MINUTE);
    int seconds = cal.get(GregorianCalendar.SECOND);
    
    startTime = hours * 60 * 60 * 1000;
    startTime += minutes * 60 * 1000;
    startTime += seconds * 1000;
    
  
  }
  
  

  
  // time warping!
  synchronized void faster() {
    
    this.timeWarp = 10 * this.timeWarp;
    println("Timewarp: " + this.timeWarp + "x");
  }
  
  synchronized void slower() {
    this.timeWarp = timeWarp / 10;
    println("Timewarp: " + this.timeWarp + "x");
  }
  
  synchronized void reset() {
    this.timeWarp = 1;
    println("Timewarp: " + this.timeWarp + "x");
  }


  // starting the engine
  void start () {       
    super.start();
  } 

  // run the update thread
  void run() {
    // TODO fix this
    int howMany = 0;
    while ( true ) {
      try {
        update();
        //sleep(100);
      } 
      catch (Exception e) {
        
      }
    }
  }


  // updates the time
  void updateDate() {
    
    
    double timeElapsed = (startTime + millis()) * timeWarp;
    
    // we need to pass the current day in double form
    // to the sgp4 equations.
    
    double portionOfDay =  ((double)timeElapsed / (double)msInDay);
    
    // update the time;
    currentYear = cal.get(GregorianCalendar.YEAR);
    currentDay  = cal.get(GregorianCalendar.DAY_OF_YEAR) + portionOfDay;
      
  }


  // updates the debris
  void update() {
    // first update the date()
    updateDate();
    // do something here

    for (Debris deb : debris) {
      try {
          deb.update(currentYear, currentDay);
      } 
      catch (ObjectDecayed od) {
        debris.remove(deb);
      }
    }

    synchronized(_debris) {
      _debris = debris;
    }
  
  }

  // draws the debris
  void draw(PApplet p) {
    if (loaded) {
      p.pushMatrix();
      p.rotateX(PI/2);
      for (Debris deb : _debris) {
        deb.draw(p);
      }
      p.popMatrix();
    }
  }


  // loads the array of debris
  void readDebris(String loc) {

    String [] debrisLines = loadStrings(loc);

    // the file has a sat/debris described on three lines
    for (int i = 0; i < debrisLines.length; i += 3) {
      String nameLine = debrisLines[i];
      String line1 = debrisLines[i+1];
      String line2 = debrisLines[i+2];

      try {
        SatElset sat = new SatElset(nameLine, line1, line2);
        Sgp4Unit deb = new Sgp4Unit(sat);
        debris.add(new Debris(deb));
      } 
      catch (Exception e) {
        println("exception!" + e);
      }
    }
    println("loaded data");
    
    loaded = true;
  }


}

