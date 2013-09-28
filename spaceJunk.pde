import remixlab.proscene.*;
import javax.vecmath.*;
import sgp4v.*;
import java.util.Collections;
import java.util.List;
import java.util.Iterator;
import java.util.GregorianCalendar;
import codeanticode.syphon.*;

SyphonServer server;

ArrayList<Sgp4Unit> debris;
ArrayList<SatElset> debrisdesc;

double speed;
double factor = 100;
Scene scene;

boolean fast = false;
boolean drawGui = true;
boolean orbit = true;
boolean useShaders = false;
boolean sendImage = false;
boolean textTitle = false;
boolean textStats = false;

float rotAngle;
PShader glow;
PShader bloom;
PShader blur;
float orbitRadius = 500;
PFont guiFont;
PFont chineseFont;
int opacity = 0;
PGraphics3D g3;
PMatrix3D currCameraMatrix;

DebrisSwarm debSwarm;

void setup () {
  
  speed = 0.0005;
  rotAngle = 0;

  //size(displayWidth, displayHeight, P3D);
  size(800, 600, P3D);
  
  guiFont = loadFont("Futura-Medium-48.vlw");
  chineseFont = loadFont("PMingLiU-48.vlw");
 
  glow = loadShader("glow.fs.glsl", "glow.vs.glsl"); 
  bloom = loadShader("bloom.glsl");
  blur = loadShader("blur.glsl");

  server = new SyphonServer(this, "space debris");

  

  setCamera();
  
  
  debSwarm = new DebrisSwarm("1999-025.txt");
  debSwarm.start();
  
  
}


void setCamera() {
  
  g3 = (PGraphics3D)g;
  
  scene = new Scene(this);
  scene.setAxisIsDrawn(false);
  scene.setGridIsDrawn(false);
  
  scene.camera().setPosition(new PVector(-1000,0,0));
  scene.camera().lookAt(scene.camera().sceneCenter());
  
}

void updateCamera() {
  rotAngle += speed;
  
  float ar = sin(rotAngle) * (orbitRadius/2);
  float or = map(ar, -orbitRadius/2, orbitRadius/2, 110, 300);
  
  PVector rot = new PVector(
    (cos(rotAngle) * or),
    0,
    (sin(rotAngle) * or)
  );
  
  
  
  scene.camera().setPosition(rot);
  scene.camera().lookAt(scene.center());
}




void draw () {
  //frame.hide();
  if (orbit) {
    updateCamera();
  }
  
  
  background(0);
  stroke(255);
  
  // draw a sphere
  pushStyle();
  stroke(20);
  fill(0, 0, 50, 60);
  sphereDetail(10);
  sphere(90);
  popStyle();
  
  debSwarm.draw(this);
  
  if (useShaders) {
    filter(bloom);
    filter(blur);
  }
  
  if (sendImage) {
    server.sendImage(get());
  }
  if (drawGui) {
    gui();
  }
  
  
}


void drawStats() {
  pushStyle();
  fill(240, 40, 60);
  noStroke();
  textAlign(LEFT);
  textFont(guiFont, 14);
  text("Fps: " + frameRate, 10, 20);
  text("Day:   " + debSwarm.currentDay, 10, height - 40);
  text("Year:  " + debSwarm.currentYear, 10, height - 20);
  textAlign(RIGHT);
  text(debSwarm.timeWarp + "x time", width - 20, 20); 
  popStyle();
}

void drawTitle() {
  pushStyle();
  fill(255, opacity);
  stroke(33, opacity);
  textAlign(CENTER);
  textFont(chineseFont, 30);
  text("风云 卫星 碎片", width/2, height/2 - 50);
  textFont(guiFont, 40);
  text("Orbital Debris from Fengyun Satellite", width/2, height/2);
  textFont(guiFont, 16);
  textAlign(CENTER);
  text("According to NASA, the intentional destruction of FY-1C created 2,841 high-velocity debris items,", width/2, height/2 + 50);
  text("a larger amount of dangerous space junk than any other space mission in history.", width/2, height/2 + 80);
  text("This visualisation shows the live position of each item.", width/2, height/2 + 110);
  
  textAlign(RIGHT);
  textFont(guiFont, 11);
  text("Source: Nasa (http://science.nasa.gov/iSat/iSAT-text-only/)", width - 20, height - 20);
  
  popStyle();
}

void gui() {
  // Disable depth test to draw 2d on top
  hint(DISABLE_DEPTH_TEST);
  currCameraMatrix = new PMatrix3D(g3.modelview);
  // Since proscene handles the projection in a slightly different manner
  // we set the camera to Processing default values before calling camera():
  float cameraZ = ((height/2.0) / tan(PI*60.0/360.0));
  perspective(PI/3.0, scene.camera().aspectRatio(), cameraZ/10.0, cameraZ*10.0);
  camera();
  
  if (textStats) {
    drawStats();
  }
  
  if (textTitle) {
    if (opacity <= 255) opacity++; 
    drawTitle();
  } else {
    if (opacity > 0) {
      opacity--;
      drawTitle();
    }
  }
    
  
  g3.camera = currCameraMatrix;
  // Re-enble depth test
  hint(ENABLE_DEPTH_TEST);
}




void keyPressed() {
  println("keyPressed " + key); 
  if (key == 'o') {
    orbit = !orbit;
  }
  if (key == '=') {
    debSwarm.faster();
  }
  if (key == '-') {
    debSwarm.slower();
  }
  if (key == '0') {
    debSwarm.reset();
  }
  if (key == 'j') {
    textStats = !textStats;
  }
  if (key == 'k') {
    textTitle = !textTitle;
  }  
  
  
  
  if (key == 'b') {
    useShaders = !useShaders;
  }
  
  if (key == 'n') {
    sendImage = !sendImage;
  }
  
  
}







