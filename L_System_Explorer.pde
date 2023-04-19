
import processing.pdf.*;

boolean record;

// First, defining some variables for the appearance of the main window
int BH; // The height of the productions box
int RW = 120; // The width of the right box
int RH = 80; // The height of the right box
int sep = 5; // The seperation of the boxes
int edge = 10; // The distance from the edge of the screen to the boxes
int d = 15; // diameter of the nodes

float CSize = 40; // Size of the central/mousetracking cursor

int w, h; // Variables to keep track of the width and height of the window for resizing purposes

boolean firstMousePress = false; // True if a mouse button has just been pressed while no other button was.

Triangle LGen, RGen; // The different arrow buttons for changing values
Triangle LWid, RWid, LDec, RDec;
Slider AngleSlider, OffsetSlider;
Rectangle PhotoButton;

ArrayList<Rectangle> windowButtons = new ArrayList<Rectangle>(); // The buttons that can add or remove windows/production rules
int buttonSize = 16;

PFont myFont;

int iters = 1;
float angle = 0;
float offset = 0;

// The bounds for where new nodes can be placed or dragged to
int xmin, xmax, ymin, ymax;
IntList lims;
IntList windowBounds;

String Productions; // A list of the productions that have a replacement rule
StringList Replacements; // A list of the replacement rules

ArrayList<Window> subWindows = new ArrayList<Window>(); // The windows that control the different production rules
int maxSubWindows = 4;
int initialWindows = 1;

String startVar;

//IntList wIandPN; // Initializing a short intlist that keeps track of some values for the main window's production display
int minProdNum;


ArrayList<Node> nodes = new ArrayList<Node>();


String[] L = {"A", "B", "C", "D", "E", "F"};
//ArrayList<String> M = new ArrayList<String>();
//M = {"A", "B", "C", "D", "E", "F"};

//Triangle StartTriangle;
//float startX, startY;
//int stW = 40; // The width of the start triangle
//int stH = 20; // The height of the start triangle


ArrayList<String> OGWindowProds = new ArrayList<String>(); // OG WindowProds
ArrayList<String> WindowProds = new ArrayList<String>(); // WindowProds

String LSystem;


int SliderBounds = 185;


boolean animatingA = false;
boolean animatingO = false;
float Arate = 0.3; // anywhere between -0.5 and 0.5 or so is good
float Orate = 0.2;

float initialWidth = 1;
float widthChange = 1; // fraction by which it changes (0.8 is good)


void settings() {
  size(displayWidth/2, displayHeight);
  windowButtons.add(new Rectangle(0, 0, buttonSize, buttonSize, "+", this));
  for (int i = 0; i < initialWindows; i++) {
    OGWindowProds.add(L[i]);
    windowButtons.add(new Rectangle(0, 0, buttonSize, buttonSize, "-", this));
  }
  
  
  
  WindowProds = OGWindowProds;
  
  
  registerMethod("pre", this);
  
  w = width;
  h = height;
  
  xmin = 0;
  xmax = w;
  ymin = 0;
  ymax = h - BH - edge;
  
  lims = new IntList();
  lims.append(xmin);
  lims.append(xmax);
  lims.append(ymin);
  lims.append(ymax);
  
  windowBounds = new IntList();
  windowBounds.append(0);
  windowBounds.append(w);
  windowBounds.append(0);
  windowBounds.append(h);
  
  Replacements = new StringList();
  
}

void setup() { 
  //surface.hideCursor();
  surface.setResizable(true);
  surface.setTitle("Main Window");
  surface.setLocation(0, 0);
  
  for (int i = 0; i < initialWindows; i++) {
    subWindows.add(new Window(this, L[i], i, OGWindowProds));
    subWindows.get(i).setWindowProds(WindowProds);
  }
  
}

void pre() {
  if (w != width || h != height) {
    // Sketch window has resized
    w = width;
    h = height;
    lims.clear();
    xmin = 0;
    xmax = w;
    ymin = 0;
    ymax = h - BH - edge;
    
    lims.append(xmin);
    lims.append(xmax);
    lims.append(ymin);
    lims.append(ymax);
    
    windowBounds.clear();
    windowBounds.append(0);
    windowBounds.append(w);
    windowBounds.append(0);
    windowBounds.append(h);
    
    adjustSystem(nodes, lims);
    
    LGen = new Triangle(w - edge - RW/2 - 15, h - edge - RH/2 - 5,
            w - edge - RW/2 - 15, h - edge - RH/2 + 25,
            w - edge - RW/2 - 40, h - edge - RH/2 + 10,
            this);
            
    RGen = new Triangle(w - edge - RW/2 + 15, h - edge - RH/2 - 5,
            w - edge - RW/2 + 40, h - edge - RH/2 + 10,
            w - edge - RW/2 + 15, h - edge - RH/2 + 25,
            this);
            
    AngleSlider = new Slider(w - edge - RW/4, w - edge - RW/4, 
    (int) (h - edge - 1.5*RH - 2*SliderBounds+3), (int) (h - edge - 1.5*RH+3), 25, 10, this);
    
    OffsetSlider = new Slider(w - edge - 3*RW/4, w - edge - 3*RW/4, 
    (int) (h - edge - 1.5*RH - 2*SliderBounds+3), (int) (h - edge - 1.5*RH+3), 25, 10, this);
    
    LDec = new Triangle(w - edge - 3*RW/2 - 15 - sep - 5, h - edge - RH/2 - BH - sep - 5,
            w - edge - 3*RW/2 - 15 - sep - 5, h - edge - RH/2 - BH - sep + 25,
            w - edge - 3*RW/2 - 40 - sep - 5, h - edge - RH/2 - BH - sep + 10,
            this);
            
    RDec = new Triangle(w - edge - 3*RW/2 + 15 - sep + 5, h - edge - RH/2 - BH - sep - 5,
            w - edge - 3*RW/2 + 15 - sep + 5, h - edge - RH/2 - BH - sep + 10,
            w - edge - 3*RW/2 + 40 - sep + 5, h - edge - RH/2 - BH - sep + 25,
            this);
            
    LWid = new Triangle(w - edge - 5*RW/2 - 15 - 2*sep - 8, h - edge - RH/2 - BH - sep - 5,
            w - edge - 5*RW/2 - 15 - 2*sep - 8, h - edge - RH/2 - BH - sep + 25,
            w - edge - 5*RW/2 - 40 - 2*sep - 8, h - edge - RH/2 - BH - sep + 10,
            this);
            
    RWid = new Triangle(w - edge - 5*RW/2 + 15 - 2*sep + 8, h - edge - RH/2 - BH - sep - 5,
            w - edge - 5*RW/2 + 15 - 2*sep + 8, h - edge - RH/2 - BH - sep + 10,
            w - edge - 5*RW/2 + 40 - 2*sep + 8, h - edge - RH/2 - BH - sep + 25,
            this);
  
    PhotoButton = new Rectangle(sep+ edge, 0, 100, 40, "Make PDF", this);
    
  }
}


void draw() {
  background(255);
  noStroke();
  
  textAlign(LEFT, TOP);
  //}
  
  stroke(255);
  
  // Productions Box
  Productions = "";
  Replacements.clear();
  for (Window w : subWindows) {
    Productions += w.getProduction();
    Replacements.append(w.getReplacement());
  }
  //StartTriangle.setWindowProds(WindowProds);
  
  
  if (subWindows.size() != 0) {
    startVar = subWindows.get(0).production;
  } else {
    startVar = "none";
  }
  
  LSystem = combineLSystem(startVar, Productions, Replacements, iters);
  
  if (record) {
    beginRecord(PDF, "frame-####.pdf");
  }
  
  drawLSystem(LSystem, this, w/2, h/2, radians(angle), radians(offset), initialWidth, widthChange); // w/2, 5*h/6
  
  if (record) {
    endRecord();
    record = false;
  }
  
  
  fill(220);
  strokeWeight(1);
  stroke(0);
  int comboProdRows = 1;
  if (LSystem.length() > 30) {
    comboProdRows = min(2 + (LSystem.length() - 50) / 70, 1);
  }
  BH = (Replacements.size() + 1 /* this +1 is for the + button */ + comboProdRows /* the other is for the combined production */) * 20;
  rect(sep + edge, height - BH - edge, width - (RW + sep * 2 + edge * 2), BH);
  minProdNum = 0;
  //wIandPN = new IntList();
  
      
  
  
  // This gets the production rules from each of the active windows and puts them into the text box in the main window
  for (int i = 0; i < Replacements.size() + 1 + comboProdRows; i++) {
    float currentW = sep + edge + 4;
    float currentH = height - BH - edge + 20*i - 3;
    fill(0);
    textAlign(LEFT,TOP);
    textSize(20);

    
    if (i == 0) {
      text("Start Variable : " + startVar, currentW, currentH);
    } else if (i < Replacements.size() + 1) {
      text(subWindows.get(i-1).production + " \u2192 " + Replacements.get(i-1), currentW, currentH);
    } else if (i == Replacements.size() + 1) {
      String more = "";
      if (LSystem.length() > 30) {
        more = "...";
      }
      text("Combo Production: " + LSystem.substring(0, min(30, LSystem.length())) + more, currentW, currentH);
    }
    //text(Productions.get(prodNum(minProdNum, maxSubWindows, subWindows)), currentW, currentH);
    if (i < Replacements.size() + 1 && !(Replacements.size() == maxSubWindows && i == 0)) {
      windowButtons.get(i).x = width - RW - sep - 18 - edge;
      windowButtons.get(i).y = currentH + comboProdRows*20 - 15; /*height - edge + step*i - buttonSize - 2 - comboProdRows * 20;*/
      
      // This places buttons that can remove (or add) production rules and their corresponding windows
      windowButtons.get(i).update();
      windowButtons.get(i).display();
    }
  }
  
  // Photo Button
  PhotoButton.y = height - BH - PhotoButton.h - 10 - sep;
  PhotoButton.update();
  PhotoButton.display();
  PhotoButton.setFirstMousePress(false);
  
  // Width Change Box
  fill(220);
  rect(width - 2*RW - edge - sep, height - RH - BH - edge - sep, RW, RH);
  
  textSize(20);
  textAlign(CENTER, CENTER);
  fill(0);
  text("Width Change", width - edge - 3*RW/2 - sep, height - edge - RH - BH - sep + 12);
  text(nf(widthChange, 0, 2), width - edge - 3*RW/2 - sep, height - edge - RH/2 - BH - sep + 6);
  
  LDec.move(LDec.x1, h - edge - RH/2 - BH - sep - 5, LDec.x2, 
  h - edge - RH/2 - BH - sep + 25, LDec.x3, h - edge - RH/2 - BH - sep + 10);
  LDec.update();
  LDec.display();
  LDec.setFirstMousePress(false);
  
  RDec.move(RDec.x1, h - edge - RH/2 - BH - sep - 5, RDec.x2, 
  h - edge - RH/2 - BH - sep + 25, RDec.x3, h - edge - RH/2 - BH - sep + 10);
  RDec.update();
  RDec.display();
  RDec.setFirstMousePress(false);
  
  // Initial Width Box
  fill(220);
  rect(width - 3*RW - edge - 2*sep, height - RH - BH - edge - sep, RW, RH);
  
  textSize(20);
  textAlign(CENTER, CENTER);
  fill(0);
  text("Initial Width", width - edge - 5*RW/2 - 2*sep, height - edge - RH - BH - sep + 12);
  text(nf(initialWidth, 0, 2), width - edge - 5*RW/2 - 2*sep, height - edge - RH/2 - BH - sep + 6);
  
  LWid.move(LWid.x1, h - edge - RH/2 - BH - sep - 5, LWid.x2, 
  h - edge - RH/2 - BH - sep + 25, LWid.x3, h - edge - RH/2 - BH - sep + 10);
  LWid.update();
  LWid.display();
  LWid.setFirstMousePress(false);
  
  RWid.move(RWid.x1, h - edge - RH/2 - BH - sep - 5, RWid.x2, 
  h - edge - RH/2 - BH - sep + 25, RWid.x3, h - edge - RH/2 - BH - sep + 10);
  RWid.update();
  RWid.display();
  RWid.setFirstMousePress(false);
  
  // Iterations Box
  fill(220);
  rect(width - RW - edge, height - RH - edge, RW, RH);
  
  textSize(20);
  textAlign(CENTER, CENTER);
  fill(0);
  text("Iterations", width - edge - RW/2, height - edge - RH + 12);
  text(str(iters), width - edge - RW/2, height - edge - RH/2 + 6);
  
  fill(200);

  LGen.update();
  LGen.display();
  LGen.setFirstMousePress(false);
  
  RGen.update();
  RGen.display();
  RGen.setFirstMousePress(false);
  
  
  // Angle Box
  
  fill(220);
  rect(width - RW/2+sep/2 - edge, height - RH - SliderBounds*2 - 1.5*edge - 70, RW/2-sep/2, SliderBounds*2 + 70);
  //(h - edge - 1.5*RH - 2*SliderBounds - 5)
  textSize(20);
  textAlign(CENTER, CENTER);
  fill(0);
  text("Angle", width - RW/4+sep/2 - edge, height - 2*SliderBounds - RW*1.5 + 25);
  
  //textSize(20);
  text(nf(angle, 0, 1), width - RW/4+sep/2 - edge, height - edge - 9 - RH - edge);
  
  fill(200);
  
  // Offset Box
  
  fill(220);
  rect(width - RW - edge, height - RH - SliderBounds*2 - 1.5*edge - 70, RW/2-sep/2, SliderBounds*2 + 70);
  
  textSize(20);
  textAlign(CENTER, CENTER);
  fill(0);
  text("Offset", width - 3*RW/4 - edge, height - 2*SliderBounds - RW*1.5 + 25);
  
  //textSize(20);
  text(nf(offset, 0, 1), width - 3*RW/4 - edge, height - edge - 9 - RH - edge);
  
  fill(200);
  
  if (AngleSlider.press) {
    angle = -round(360.0 * AngleSlider.slideFraction - 180);
  } else if (animatingA) {
    angle = (angle + Arate + 180) % 360 - 180;
    AngleSlider.setSlideFraction((angle+180.0)/360.0);
    AngleSlider.x = AngleSlider.xmin+AngleSlider.slideFraction*(AngleSlider.xmax-AngleSlider.xmin);
    AngleSlider.y = AngleSlider.ymin+AngleSlider.slideFraction*(AngleSlider.ymax-AngleSlider.ymin);
  }
  
  if (OffsetSlider.press) {
    offset = -round(360.0 * OffsetSlider.slideFraction - 180);
  } else if (animatingO) {
    offset = (offset - Orate - 180) % 360 + 180;
    OffsetSlider.setSlideFraction((offset+180.0)/360.0);
    OffsetSlider.x = OffsetSlider.xmin+OffsetSlider.slideFraction*(OffsetSlider.xmax-OffsetSlider.xmin);
    OffsetSlider.y = OffsetSlider.ymin+OffsetSlider.slideFraction*(OffsetSlider.ymax-OffsetSlider.ymin);
  }
  
  
  AngleSlider.update();
  AngleSlider.display();
  AngleSlider.setFirstMousePress(false);
  
  OffsetSlider.update();
  OffsetSlider.display();
  OffsetSlider.setFirstMousePress(false);
  
  for (Window w : subWindows) {
    w.setAngle(angle);
    w.setOffset(offset);
  }
  
}

void mousePressed() {
  for (int i = 0; i < windowButtons.size(); i++) {
    if (windowButtons.get(i).over) {
      windowButtons.get(i).over = false;
      if (windowButtons.get(i).s == "+") {
        addNewWindow();
      } else if (windowButtons.get(i).s == "-") {
        windowButtons.remove(windowButtons.get(i));
        subWindows.get(i-1).close();
        subWindows.remove(subWindows.get(i-1));
        WindowProds.remove(WindowProds.get(i-1));
      }
    }
  }
  
  if (PhotoButton.over) {
    record = true;
  }
  PhotoButton.setFirstMousePress(true);
  
  if (LDec.over) {
    widthChange = widthChange - 0.05;
    if (widthChange < 0.6) {
      widthChange = 0.6;
    }
  }
  
  if (RDec.over) {
    widthChange += 0.05;
    if (widthChange > 1.6) {
      widthChange = 1.6;
    }
  }
  
  if (LWid.over) {
    initialWidth = initialWidth - 0.5;
    if (initialWidth < 1) {
      initialWidth = 1;
    }
  }
  
  if (RWid.over) {
    initialWidth += 0.5;
    if (initialWidth > 15) {
      initialWidth = 15;
    }
  }
  
  if (LGen.over) {
    iters--;
    if (iters < 0) {
      iters = 0;
    }
  }
  if (RGen.over) {
    iters++;
  }
  LGen.setFirstMousePress(true);
  RGen.setFirstMousePress(true);
  
  AngleSlider.setFirstMousePress(true);
  OffsetSlider.setFirstMousePress(true);
  

  
  for (Window w : subWindows) {
    w.setWindowProds(WindowProds);
  }
}

void mouseReleased() {
  LGen.releaseEvent();
  RGen.releaseEvent();
  AngleSlider.releaseEvent();
  OffsetSlider.releaseEvent();
  PhotoButton.releaseEvent();
}

ArrayList<String> getWindowProds() {
  return WindowProds;
}

void addNewWindow() {
  for (int i = 0; i < maxSubWindows; i++) {
    boolean inList = false;
    for (int j = 0; j < subWindows.size(); j++) {
      if (subWindows.get(j).nth == i) {
        inList = true;
        break;
      }
    }
    if (!inList) {
      subWindows.add(i, new Window(this, L[i], i, OGWindowProds));
      subWindows.get(i).setWindowProds(WindowProds);
      windowButtons.add(new Rectangle(0, 0, buttonSize, buttonSize, "-", this));
      WindowProds.add(i, L[i]);
      break;
    }
  }
}
