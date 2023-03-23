
class Window extends PApplet {
  PApplet parent;
  String name;
  int nth;
  int titleHeight = 27;
  
  int xmin, xmax, ymin, ymax;
  IntList lims;
  
  int w, h;
  
  Triangle StartTriangle;
  float startX, startY;
  
  int stW = 40; // The width of the start triangle
  int stH = 20; // The height of the start triangle
  
  float vicinity = 20;
  float Len;
  float angle;
  
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
    StartTriangle = new Triangle(startX, startY, startX + stW/2, startY + stH, startX - stW/2, startY + stH, this, lims, OGWindowProds);
    StartTriangle.setMovable(true);
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
      
      StartTriangle.adjust(lims);
    }
    StartTriangle.Len = Len;
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
  
    StartTriangle.update();
    StartTriangle.display();
    StartTriangle.setFirstMousePress(false);
    
    startX = StartTriangle.x1;
    startY = StartTriangle.y1;
    
    replacement = StartTriangle.startNode.generateSystem(); // Need to update replacement here to reflect what's going on in the window
  }
  
  public void mousePressed() {
    StartTriangle.setFirstMousePress(true);
  }

  public void mouseReleased() {
    StartTriangle.releaseEvent();  
  }
  
  public void setWindowProds(ArrayList<String> WP) {
    //print(" hmm " + WP);
    WindowProds = WP;
    //print(" old start triangle prods: " + StartTriangle.WindowProds);
    ////StartTriangle.setWindowProds(WindowProds);
    //print(" new start triangle prods: " + StartTriangle.WindowProds);
  }
  
  public void setAngle(float A) {
    StartTriangle.angle = A;
  }
  
  public String getProduction() {
    return production;
  }
  
  public String getReplacement() {
    return replacement;
  }
  
  
  public void close() {
    this.exitActual();
    //this.dispose();
    surface.setVisible(false);
    
  }
}
