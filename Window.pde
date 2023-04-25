
class Window extends PApplet {
  PApplet parent;
  String name;
  int nth;
  int titleHeight = 27;
  
  int xmin, xmax, ymin, ymax;
  IntList lims;
  
  int w, h;
  
  Triangle startTriangle;
  float startX, startY;
  
  int stW = 40; // The width of the start triangle
  int stH = 20; // The height of the start triangle
  
  float vicinity = 20;
  float Len;
  float angle;
  float offset;
  
  String production = ""; // the value that is replaced
  String replacement = ""; // the value that replaces 
  ArrayList<String> OGWindowProds;
  ArrayList<String> WindowProds;
    
  @Override
    public void exitActual() {
  }
  
  Window(PApplet Parent, String P, int Nth, ArrayList<String> OGWP) {
    super();
    parent = Parent;
    production = P;
    //replacement = production;
    name = "Production rule for " + production;
    nth = Nth;
    OGWindowProds = OGWP;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
    Len = 50;
  }
  
  public void settings() {
    size(displayWidth/4, (int) (displayHeight/2 - titleHeight * 1.5));
    
    w = width;
    h = height;
    
    lims = new IntList();
    
    xmin = 0;
    xmax = w;
    ymin = 0;
    ymax = h - titleHeight;
    
    lims.append(xmin);
    lims.append(xmax);
    lims.append(ymin);
    lims.append(ymax);

    
    startX = w/2;
    startY = h/2;
    startTriangle = new Triangle(startX, startY, startX + stW/2, startY + stH, startX - stW/2, startY + stH, this);
    startTriangle.setMovable(true, lims, OGWindowProds);
  }
  
  public void setup() {
    surface.setResizable(true);
    surface.setTitle(name);
    surface.setLocation(displayWidth/2 + displayWidth/4 * (nth % 2), (int) (displayHeight/2 + titleHeight * 0.5) * (nth / 2));
    
    //textFont(myFont);
    
  }
  
  public void draw() {
    if (w != width || h != height) {
      // Sketch window has resized
      w = width;
      h = height;
      while (lims.size() > 0) {
        lims.remove(0);
      }
      xmin = 0;
      xmax = w;
      ymin = 0;
      ymax = h - titleHeight;
      
      lims.append(xmin);
      lims.append(xmax);
      lims.append(ymin);
      lims.append(ymax);
      
      //setAngle(angle);
      
      startTriangle.adjust(lims);
    }
    startTriangle.Len = Len;
    background(255);
    fill(255);
    strokeWeight(1);
    stroke(0);
    rect(0, height - titleHeight, width, titleHeight);
    textAlign(LEFT, TOP);
    textSize(15);
    fill(0);
    text(production + " : " + replacement, 10, height - titleHeight + 3);
    
    //StartTriangle.setWindowProds(WindowProds);
  
    startTriangle.update();
    startTriangle.display();
    startTriangle.setFirstMousePress(false);
    
    startX = startTriangle.x1;
    startY = startTriangle.y1;
    
    replacement = startTriangle.startNode.generateSystem(); // Need to update replacement here to reflect what's going on in the window
  }
  
  public void mousePressed() {
    startTriangle.setFirstMousePress(true);
  }

  public void mouseReleased() {
    startTriangle.releaseEvent();  
  }
  
  public void setWindowProds(ArrayList<String> WP) {
    //print(" hmm " + WP);
    WindowProds = WP;
    //print(" old start triangle prods: " + startTriangle.WindowProds);
    ////startTriangle.setWindowProds(WindowProds);
    //print(" new start triangle prods: " + startTriangle.WindowProds);
  }
  
  public void setAngle(float A) {
    startTriangle.angle = A;
  }
  
  public void setOffset(float O) {
    startTriangle.offset = O;
  }
  
  public String getProduction() {
    return production;
  }
  
  public String getProdRule() {
    return replacement;
  }
  
  
  public void close() {
    this.exitActual();
    //this.dispose();
    surface.setVisible(false);
    
  }
}
