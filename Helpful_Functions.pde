
boolean overCircle(float x, float y, float r, PApplet W) {
  float disX = x - W.mouseX;
  float disY = y - W.mouseY;
  if (sqrt(sq(disX) + sq(disY)) < r) {
    return true;
  } else {
    return false;
  }
}

float sign (float X1, float Y1, float X2, float Y2, float X3, float Y3) {
  return (X1 - X3) * (Y2 - Y3) - (X2 - X3) * (Y1 - Y3);
}

boolean overTriangle(float X1, float Y1, float X2, float Y2, float X3, float Y3, PApplet W) {
  // Checking which side of the half-plane created by the edges the point is in
  float d1, d2, d3;
  boolean neg, pos;
  
  d1 = sign(W.mouseX, W.mouseY, X1, Y1, X2, Y2);
  d2 = sign(W.mouseX, W.mouseY, X2, Y2, X3, Y3);
  d3 = sign(W.mouseX, W.mouseY, X3, Y3, X1, Y1);
  
  neg = d1 < 0 || d2 < 0 || d3 < 0;
  pos = d1 > 0 || d2 > 0 || d3 > 0;
  
  return !(neg && pos);
}

boolean overQuad(float X1, float Y1, float X2, float Y2, float X3, float Y3, float X4, float Y4, PApplet W) {
  float d1, d2, d3, d4;
  boolean neg, pos;
  
  d1 = sign(W.mouseX, W.mouseY, X1, Y1, X2, Y2);
  d2 = sign(W.mouseX, W.mouseY, X2, Y2, X3, Y3);
  d3 = sign(W.mouseX, W.mouseY, X3, Y3, X4, Y4);
  d4 = sign(W.mouseX, W.mouseY, X4, Y4, X1, Y1);
  
  neg = d1 < 0 || d2 < 0 || d3 < 0 || d4 < 0;
  pos = d1 > 0 || d2 > 0 || d3 > 0 || d4 > 0;
  
  return !(neg && pos);
}

boolean overRect(float X, float Y, float w, float h, PApplet W) {
  boolean xgood = W.mouseX > X && W.mouseX < X + w;
  boolean ygood = W.mouseY > Y && W.mouseY < Y + h;
  return xgood && ygood;
}

class Slider {
  int xmin, xmax, ymin, ymax, swidth, sheight;
  float x, y;
  float angle;
  float slideFraction;
  boolean over, press;
  boolean locked = false;
  int col = 120;
  boolean firstMousePress = false;
  PApplet w;
  
  Slider(int Xmin, int Xmax, int Ymin, int Ymax, int wid, int hei, PApplet W) {
    xmin = Xmin;
    xmax = Xmax;
    ymin = Ymin;
    ymax = Ymax;
    x = (float) xmin + ((float)(xmax - xmin))/2;
    y = (float) ymin + ((float)(ymax - ymin))/2;
    swidth = wid;
    sheight = hei;
    angle = 0;
    if (xmax - xmin != 0) {
      angle = PI/2 + atan((float)(ymax-ymin) / (float)(xmax-xmin));
    }
    w = W;
  }
  
  void update() {
    overEvent();
    pressEvent();
    if (press) {
      x = lock(mouseX, xmin, xmax);
      y = lock(mouseY, ymin, ymax);
      
    }
    slideFraction = dist(xmin, ymin, x, y) / dist(xmin, ymin, xmax, ymax);
  }
  
  void overEvent() {
    
    float s = sin(angle);
    float c = cos(angle);
    if (overQuad(x-swidth/2, y-sheight/2, x-swidth/2, y+sheight/2, x+swidth/2, y+sheight/2, x+swidth/2, y-sheight/2, w)) {
      over = true;
    } else {
      over = false;
    }
  }
  
  void pressEvent() {
    if (over && firstMousePress || locked) {
      press = true;
      locked = true;
    } else {
      press = false;
    }
  }
  
  void releaseEvent() {
    locked = false;
  }
  
  void setFirstMousePress(boolean B) {
    firstMousePress = B;
  }
  
  void move(int newmin, int newmax, int newy) {
    xmin = newmin;
    xmax = newmax;
    y = newy;
    x = xmin + (xmax - xmin)/2 - swidth/2;
  }
  
  void slide(int newx) {
    x = newx;
  }
  
  void display() {
    x = (int) lock(x, xmin, xmax);
    y = (int) lock(y, ymin, ymax);
    w.fill(0);
    w.stroke(0);
    w.strokeWeight(3);
    w.line(xmin, ymin, xmax, ymax); 
    
    float fill = col;
    if (over || press) {
      fill = col + 50;
    }
    
    w.stroke(0);
    w.strokeWeight(1);
    w.fill(fill);
    float s = sin(angle);
    float c = cos(angle);
    //print("angle: " + degrees(angle));
    w.quad(x-swidth/2, y-sheight/2, x-swidth/2, y+sheight/2, x+swidth/2, y+sheight/2, x+swidth/2, y-sheight/2);
    //w.quad(x-s*swidth/2, y-c*sheight/2, x-s*swidth/2, y+c*sheight/2, x+s*swidth/2, y+c*sheight/2, x+s*swidth/2, y-c*sheight/2);
  }
}
  

class Triangle {
  float x1, y1, x2, y2, x3, y3;
  boolean over;
  boolean press;
  boolean locked = false;
  int col = 120;
  boolean firstMousePress = false;
  PApplet w;
  IntList lims;
  boolean movable = false;
  float h;
  Node startNode;
  ArrayList<String> WindowProds;
  float Len;
  float angle = 0;
  
  Triangle(float X1, float Y1, float X2, float Y2, float X3, float Y3, PApplet Window, IntList limits, ArrayList<String> WP) {

    x1 = X1;
    y1 = Y1;
    x2 = X2;
    y2 = Y2;
    x3 = X3;
    y3 = Y3;
    w = Window;
    lims = limits;
    h = max(y1, max(y2, y3)) - min(y1, min(y2, y3));
    WindowProds = WP;
  }
  
  void update() {
    overEvent();
    pressEvent();
    if (movable) {
      
      startNode.Len = Len;
      startNode.angle = angle;
      startNode.update();
      //if (over && !(startNode.activated || startNode.afterActivated())) {
      //  startNode.activatedFalse();
      //}
      
    }
    
    if (press && movable) {
      float x = lock(w.mouseX, lims.get(0) + (x1-x3), lims.get(1) + (x1-x2));
      float y = lock(w.mouseY - 7 * h / 8, lims.get(2), lims.get(3) - h);
      startNode.move(x - x1, y - y1);
      shift(x, y);
    }
  }
  
  void overEvent() {
    if (overTriangle(x1, y1, x2, y2, x3, y3, w) && (!movable || (movable && !startNode.over && !startNode.overAfter()))) {
      over = true;
    } else {
      over = false;
    }
  }
  
  void setFirstMousePress(boolean p) {
    firstMousePress = p;
    if (movable) {
      startNode.setFirstMousePress(p);
    }
  }
  
  void pressEvent() {
    if (over && firstMousePress || locked) {
      press = true;
      locked = true;
      if (movable) {
        startNode.globalActivation(true);
      }
    } else {
      if (press && movable) {
        startNode.globalActivation(false);
      }
      press = false;
    }
    
  }
  
  void releaseEvent() {
    locked = false;
    if (movable) {
      
      startNode.releaseEvent();
    }
  }
  
  void setStart(Node n) {
    startNode = n;
  }
  
  void setMovable(boolean m) {
    movable = m;
    if (movable) {
      startNode = new Node(x1, y1, 0, "start", this, w, lims);
    }
  }
  
  void setWindowProds(ArrayList<String> WP) {
    if (WP != WindowProds) {
      print("change happens");
    }
    WindowProds = WP;
  }
  
  
  void shift(float x, float y) {
    float xChange = x - x1;
    float yChange = y - y1;
    x2 += xChange;
    y2 += yChange;
    x3 += xChange;
    y3 += yChange;
    x1 = x;
    y1 = y;
  }
  
  void move(float X1, float Y1, float X2, float Y2, float X3, float Y3) {
    x1 = X1;
    y1 = Y1;
    x2 = X2;
    y2 = Y2;
    x3 = X3;
    y3 = Y3;
  }
  
  void adjust(IntList newlims) {
    lims = newlims;
    float x = lock(x1, lims.get(0) + (x1-x3), lims.get(1) + (x1-x2));
    float y = lock(y1, lims.get(2), lims.get(3) - h);
    shift(x, y);
  }
  
  void display() {
    int fill = col;
    if ((over || press) && (!movable || (movable && !(startNode.activated || startNode.afterActivated())))) { // false when the startnode or any of the following nodes are activated
      fill = col + 50;
    }
    w.stroke(0);
    w.strokeWeight(1);
    w.fill(fill);
    w.triangle(x1, y1, x2, y2, x3, y3);
    if (movable) {
      startNode.display();
    }
  }
}

class Rectangle {
  float x, y, w, h;
  boolean over;
  boolean press;
  boolean locked = false;
  int col = 120;
  boolean firstMousePress = false;
  PApplet W;
  boolean movable = false;
  String s;
  
  Rectangle(float X, float Y, float Width, float Height, String string, PApplet Window) {
    x = X;
    y = Y;
    w = Width;
    h = Height;
    s = string;
    W = Window;
  }
  
  void update() {
    overEvent();
    pressEvent();
  }
  
  void overEvent() {
    if (overRect(x, y, w, h, W)) {
      over = true;
    } else {
      over = false;
    }
  }
  
  void setFirstMousePress(boolean p) {
    firstMousePress = p;
  }
  
  void pressEvent() {
    if (over && firstMousePress || locked) {
      press = true;
      locked = true;
    } else {
      press = false;
    }
  }
  
  void releaseEvent() {
    locked = false;
  }
  
  void setMovable(boolean m) {
    movable = m;
  }
  
  void display() {
    int fill = col;
    W.strokeWeight(1);
    W.stroke(0);
    if (over || press) {
      fill = col + 50;
    }
    W.fill(fill);
    W.rect(x, y, w, h, 5);
    
    W.textAlign(CENTER, CENTER);
    W.fill(0);
    int yChange = 3;
    if (s == "+") {
      yChange = 5;
    }
    W.text(s, x + w/2 + 1, y + yChange);
  }
}


float lock(float val, float minv, float maxv) {
  return min(max(val, minv), maxv);
}

void drawSystem(ArrayList<Node> nodes) {
  for (Node n : nodes) {
    n.update();
    n.display();
  }
}

void adjustSystem(ArrayList<Node> nodes, IntList lims) {
  for (Node n : nodes) {
    n.adjust(lims);
    n.display();
  }
}

float distance(float x1, float y1, float x2, float y2) {
  return sqrt(pow((x1 - x2), 2) + pow((y1 - y2), 2));
}


class State {
  float X;
  float Y;
  float theta;
  
  State(float x, float y, float t) {
    X = x;
    Y = y;
    theta = t;
  }
  
  void changeData(float x, float y, float t) {
    X = x;
    Y = y;
    theta = t;
  }
  
  float getX() {
    return X;
  }
  
  float getY() {
    return Y;
  }
  
  float getTheta() {
    return theta;
  }
}

String generateSystem(Node n) {
  String s = "";
  for (Node nn : n.after) {
    if (nn.after.size() == 0) {
      s += generateSystem(nn);
    } else {
      
    }
  }
  return s;
}

String combineLSystem(String Start, String Productions, StringList Replacements, int iters) {
  String phrase = Start;
  String tempPhrase;
  char C;
  for (int i = 0; i < iters; i++) {
    tempPhrase = "";
    for (int j = 0; j < phrase.length(); j++) {
      C = phrase.charAt(j);
      if (Productions.indexOf(str(C)) != -1) {
        tempPhrase += Replacements.get(Productions.indexOf(C));
      } else {
        tempPhrase += C;
      }
    }
    phrase = tempPhrase;
  }
  return phrase;
}

void drawLSystem(String LSystem, PApplet Window, float startX, float startY, float angle) {
  float currentX = startX;
  float currentY = startY;
  float theta = 0;
  float Dtheta = angle;
  char C;
  ArrayList<State> Stack = new ArrayList<State>();
  
  Window.fill(0);
  Window.strokeWeight(1);
  Window.stroke(0);
  for (int i = 0; i < LSystem.length(); i++) {
    C = LSystem.charAt(i);
    State tempState = new State(currentX, currentY, theta);
    if (C == 'F') {
      float newX = (currentX + 20 * -sin(theta)); // was cos
      float newY = (currentY + 20 * -cos(theta)); // was -sin
      Window.strokeWeight(1);
      //float
      //Window.stroke(255* (currentX-newX)/, random(255), random(255));
      Window.line(currentX, currentY, newX, newY);
      currentX = newX;
      currentY = newY;
    } else if (C == '+') {
      theta = (theta + Dtheta) % TWO_PI;
    } else if (C == '-') {
      theta = (theta - Dtheta) % TWO_PI;
    } else if (C == '[') {
      tempState.changeData(currentX, currentY, theta);
      Stack.add(tempState);
    } else if (C == ']') {
      tempState = Stack.get(Stack.size()-1);
      Stack.remove(Stack.size()-1);
      currentX = tempState.getX();
      currentY = tempState.getY();
      theta = tempState.getTheta();
    }
    //print(Stack.size());
  }
}
