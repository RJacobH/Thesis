// Node class describes a modifiable point in a window
class Node {
  float x, y;
  boolean over;
  boolean press;
  boolean locked = false;
  int col = 100;
  float theta; // the current rotation of a node
  float angle; // the rotation step as chosen in the main window
  float d = 20;
  float r = d/2;
  float Len;
  
  Node before;
  ArrayList<Node> after;
  PApplet w;
  //ArrayList<Node> allNodes; // All the nodes in the window
  
  Triangle Tparent;
  Node optionParent; // arbiter? adjudicator? judge?
  ArrayList<Node> options;
  Node plus, minus;
  
  boolean firstMousePress = false;
  IntList lims; // limits for nodes etc that can move around on the screen
  
  String nodeType; // possible values are "rotation", "production", "forward", "start", and "option"
  
  float v = r + 10; // vicinity -> used to note how far away the mouse can go from the center of a node before deactivating the node
  boolean nearby;
  boolean activated;
  boolean somethingActivated;
  
  float leastX = r;
  float mostX = r;
  float leastY = r;
  float mostY = r;
  
  ArrayList<String> WindowProds;
  ArrayList<String> OGWindowProds;
  String t = " "; // The text that is in the center of the node. Only should be used for option and production nodes (and perhaps rotation nodes?)
  
  // This first constructor makes a special node without a before node. This node is tied to the StartTriangle 
  Node(float ix, float iy, float A, String Ntype, Triangle T, PApplet W, IntList limits) { // Only used once to initialize a window's tree of nodes
    w = W;
    nodeType = Ntype;
    lims = limits;
    x = ix;
    y = iy;
    theta = 0;
    before = this;
    Tparent = T;
    somethingActivated = false;
    Len = Tparent.Len;
    angle = A;
    
    OGWindowProds = Tparent.WindowProds;
    //print(" | these are OG: " + OGWindowProds);
    WindowProds = OGWindowProds;
    
    after = new ArrayList<Node>();
    options = new ArrayList<Node>(); // The option nodes that are children to either a main node or another option node
    Node plus = new Node(x + 2*r + 5, y, 0, "option", "+", this, w, lims);
    options.add(plus);
    Node rLeft = new Node(x + r + 3, y + 2*r + 3, 0, "option", ">", this, w, lims);
    options.add(rLeft);
    Node rRight = new Node(x - r - 3, y + 2*r + 3, 0, "option", "<", this, w, lims);
    options.add(rRight);
    Node forward = new Node(x, y - 2*r - 5, 0, "option", "F", this, w, lims);
    options.add(forward);
    
  }
  
  Node(float ix, float iy, float A, String Ntype, String text, Node b, PApplet W, IntList limits) {
    w = W;
    nodeType = Ntype;
    lims = limits;
    x = ix;
    y = iy;
    //theta = radians(rotation) % TWO_PI;
    t = text;
    angle = A;
    //t = w.production;
    if (nodeType != "option") {
      before = b;
      OGWindowProds = before.OGWindowProds;
      WindowProds = before.WindowProds;
      theta = before.theta;
      //allNodes = b.allNodes; // Each node is responsible for adding its subsequent nodes to this growing array, but each subsequent node is responsible for removing itself if deleted
    } else {
      optionParent = b;
      OGWindowProds = optionParent.OGWindowProds;
      WindowProds = optionParent.WindowProds;
      
      //allNodes = b.allNodes;
    }
    theta = b.theta;
    
    if (nodeType == "rotation") {
      theta += radians(angle) % TWO_PI;
    }
    
    //d = b.d * 0.99;
    d = b.d;
    if (nodeType != "option") {
      after = new ArrayList<Node>();
    }
    options = new ArrayList<Node>(); // The option nodes that are children to either a main node or another option node
    
    
    //if (nodeType == "rotation") {
    //  leastX = max(r, -r*pow(2,0.5)*cos(theta+PI/2));
    //  mostX = max(r, r*pow(2,0.5)*cos(theta+PI/2));
    //  leastY = max(r, r*pow(2,0.5)*sin(theta+PI/2));
    //  mostY = max(r, -r*pow(2,0.5)*sin(theta+PI/2));
    //}
    
    if (nodeType != "option" && nodeType != "forward") {
      Node minus = new Node(x - 2*r - 5, y, 0, "option", "-", this, w, lims);
      options.add(minus);
      Node plus = new Node(x + 2*r + 5, y, 0, "option", "+", this, w, lims);
      options.add(plus);
      Node rLeft = new Node(x + r + 3, y + 2*r + 3, 0, "option", ">", this, w, lims);
      options.add(rLeft);
      Node rRight = new Node(x - r - 3, y + 2*r + 3, 0, "option", "<", this, w, lims);
      options.add(rRight);
      Node forward = new Node(x, y - 2*r - 5, 0, "option", "F", this, w, lims);
      options.add(forward);
    }
    
    if (nodeType == "forward") {
      Node minus = new Node(x - 2*r - 5, y, 0, "option", "-", this, w, lims);
      options.add(minus);
      Node plus = new Node(x + 2*r + 5, y, 0, "option", "+", this, w, lims);
      options.add(plus);
      Node rLeft = new Node(x + r + 3, y + 2*r + 3, 0, "option", ">", this, w, lims);
      options.add(rLeft);
      Node rRight = new Node(x - r - 3, y + 2*r + 3, 0, "option", "<", this, w, lims);
      options.add(rRight);
      Node forward = new Node(x, y - 2*r - 5, 0, "option", "F", this, w, lims);
      options.add(forward);
    }
    
    //print(t);
    if (nodeType == "option" && t == "+") {
      //print("something");
      for (int i = 0; i < WindowProds.size(); i++) {
        options.add(new Node(x + 2*r*(i+1) + 5, y, 0, "option", WindowProds.get(i), this, w, lims));
        //options.get(i).setText(WindowProds.get(i));
      }
      
      
      if (optionParent.nodeType == "rotation") { // two rotation nodes, one clockwise and one counterclockwise
        
      } else { // just one node for making a rotation node
        
      }
    }
  }
  
  void update() {
    if (nodeType != "option") {
      //print(angle);
    }
    fixWindowProds();
    
    overEvent();
    pressEvent();
    nearbyEvent();
    
    if (nodeType == "rotation") {
      theta = radians(angle);
      rotateSubNodes();
    }
    
    
    
    if (nodeType != "option") {
      Len = before.Len;
      angle = before.angle;
    }
    
    if (nodeType == "option" && over) {
      activated = true;
    }
    
    if (nodeType == "option" && optionParent.nodeType == "option" && optionParent.activated) {
      activated = true;
    }

    if (nodeType == "rotation") {
      leastX = max(r, -r*pow(2,0.5)*cos(theta+PI/2));
      mostX = max(r, r*pow(2,0.5)*cos(theta+PI/2));
      leastY = max(r, r*pow(2,0.5)*sin(theta+PI/2));
      mostY = max(r, -r*pow(2,0.5)*sin(theta+PI/2));
    }
    
    
    
    for (Node o : options) {
      o.update();
    }
    
    if (activated && options.size() != 0) { // A node will no longer be activated if the mouse is outside of its vicinity or the vicinity of any of its active options
      //print("active");
      boolean Near = false;
      for (Node o : options) {
        if (o.nearby) {
          Near = true;
          break;
        }
      }
      
      if (!nearby && !Near && !childNearby()) {
        activated = false;
        globalActivation(false);
      }
    }
    
    if (nodeType != "option") {
      for (Node a : after) {
        a.update();
      }
    }
    
    if (nodeType != "option" && over && !isSomethingActivated()) /*((over && !beforeActivated() && !afterActivated())*/ {
      globalActivation(true);
      activated = true;
    }
  }
  
  
  
  boolean isOver() {
    
    boolean Over = (overCircle(x, y, r, w));
    if (nodeType == "rotation") {
      Over = (overQuad(x, y, x-r*sin(theta+PI/4), y-r*cos(theta+PI/4), 
        x+r*pow(2,0.5)*cos(theta+PI/2), y-r*pow(2,0.5)*sin(theta+PI/2), 
        x+r*cos(theta+PI/4), y-r*sin(theta+PI/4), w) || (overCircle(x, y, r, w)));
    } else if (nodeType == "forward") {
      float b = 6; // breadth (width of the area around the line that the program considers "over")
      float c = cos(theta);
      float s = -sin(theta);
      
      /* The four points of the forward node bounding box, in order from bottom left, clockwise:
      x+b/2*(c+s), y-b/2*(c-s)
      x+c*b/2 - Len*s, y+s*b/2+(Len+b/2)*c
      x-c*b/2 - Len*s, y-s*b/2+(Len+b/2)*c
      x-b/2*(c-s), y-b/2*(c+s)
      */
      //theta = theta + 0.03;
      //w.stroke(255,0,0);
      //w.line(x+b/2*(c+s), y-b/2*(c-s), x+c*b/2 - Len*s, y+s*b/2+(Len+b/2)*c);
      //w.line(x-c*b/2+b/2*s, y-s*b/2-b/2*c, x-c*b/2 - Len*s, y-s*b/2+(Len+b/2)*c);
      //w.line(x+b/2*(c+s), y-b/2*(c-s), x-b/2*(c-s), y-b/2*(c+s));
      //w.line(x+c*b/2 - Len*s, y+s*b/2+(Len+b/2)*c, x-c*b/2 - Len*s, y-s*b/2+(Len+b/2)*c);
      
      Over = overQuad(x+b/2*(c+s), y-b/2*(c-s), x+c*b/2 - Len*s, y+s*b/2+(Len+b/2)*c, x-c*b/2 - Len*s, y-s*b/2+(Len+b/2)*c, x-b/2*(c-s), y-b/2*(c+s), w);
      
    }
    
    return Over;
  }
  
  boolean overAfter() {
    if (nodeType != "option") {
      for (Node a : after) {
        if (a.overAfter() || a.isOver()) {
          return true;
        }
      }
    }
    return false;
  }
  
  boolean overBefore() {
    if (over) {
      return true;
    } else if (nodeType == "start") {
      return false;
    } else if (nodeType != "option") {
      return before.overBefore();
    } else {
      return optionParent.overBefore();
    }
  }
  
  boolean afterActivated() {
    if (nodeType != "option") {
      for (Node a : after) {
        if (a.activated || a.afterActivated()) {
          return true;
        }
      }
    }
    return false;
  }
  
  boolean beforeActivated() {
    if (activated) {
      return true;
    } else if (nodeType == "start") {
      return false;
    } else if (nodeType != "option") {
      return before.beforeActivated();
    } else {
      return optionParent.beforeActivated();
    }
  }
  
  void globalActivation(boolean B) {
    if (nodeType == "start") {
      somethingActivated = B;
    } else if (nodeType != "option") {
      before.globalActivation(B);
    }
    //print("how did you get here? An option is globally activating");
  }
  
  boolean isSomethingActivated() { // need to account for the case where two nodes on two different branches are both activated
    if (nodeType == "start") {
      return somethingActivated;
    } else if (nodeType != "option") {
      return before.isSomethingActivated();
    }
    print("an option node is using someActivated()");
    return false;
  }
  
  void activatedFalse() {
    activated = false;
    for (Node o : options) {
      o.activatedFalse();
    }
    if (nodeType != "option") {
      for (Node a : after) {
        a.activatedFalse();
      }
    }
  }
    
  void rotateSubNodes() {
    float oX = x;
    float oY = y;
    if (nodeType != "option") {
      if (nodeType == "forward") {
        theta = before.theta;
        x = before.x + Len*(-sin(theta));
        y = before.y + Len*(-cos(theta));
      } else {
        //move(x - oX,
      }
      for (Node a : after) {
        a.rotateSubNodes();
      }
    } else if (nodeType == "option") {
      move(x - oX, y - oY);
    }
    for (Node o : options) {
      o.rotateSubNodes();
    }
  }
  
  void overEvent() {
    if (isOver()/* && nodeType == "option"*/) {
      over = true;
    } else {
      over = false;
    }
  }
  
  void nearbyEvent() {
    if (distance(w.mouseX, w.mouseY, x, y) > v) {
      nearby = false;
    } else {
      nearby = true;
    }
  }
  
  void setFirstMousePress(boolean p) {
    firstMousePress = p;
    for (Node o : options) {
      o.setFirstMousePress(p);
    }
    if (nodeType != "option") {
      for (Node a : after) {
        a.setFirstMousePress(p);
      }
    }
  }
  
  void pressEvent() {
    press = false;
    if (options.size() == 0 && over && firstMousePress) {
      press = true;
      locked = true;
    }
  }
  
  void releaseEvent() {
    //if (locked) {
    //  activated = false;
    //}
    locked = false;
    for (Node o : options) {
      o.releaseEvent();
    }
    if (nodeType != "option") {
      for (Node a : after) {
        a.releaseEvent();
      }
    }
    //activated = false;
  }
  
  void move(float Dx, float Dy) {
    x = x + Dx;
    y = y + Dy;
    for (Node o : options) {
      o.move(Dx, Dy);
    }
    if (nodeType != "option") {
      for (Node a : after) {
        a.move(Dx, Dy);
      }
    }
  }
  
  int getPlusIndex() {
    for (int i = 0; i < options.size(); i++) {
      if (options.get(i).t == "+") {
        return i;
      }
    }
    return -1;
  }
  
  void fixWindowProds() {
    if (nodeType == "option" && t == "+") {
      if (WindowProds.size() < options.size()) { // An option node needs to be removed
        for (int i = 0; i < options.size(); i++) { // to determine which option node should be removed
          if (WindowProds.get(min(i, WindowProds.size()-1)) != options.get(i).t) {
            options.get(i).removeOption(); // remove the node that is no longer represented in the WindowProds array
            break;
          }
        }
      } else if (WindowProds.size() > options.size()) { // an option node needs to be added
        for (int i = 0; i < WindowProds.size(); i++) {
          if (options.get(min(i, options.size()-1)).t != WindowProds.get(i)) {
            String newProd = WindowProds.get(i);
            options.add(i, new Node(x + 2*r*(i+1) + 5, y, 0, "option", newProd, this, w, lims));
            break;
          }
        }
      }
    }
  }
  
  
  void setText(String T) {
    t = T;
  }
  
  void rotate(float T) {
    theta += radians(T) % (2*PI);
  }
  
  void setTheta(float T) {
    theta = radians(T) % (2*PI);
  }
  
  String generateSystem() {
    String replacement = "";
    if (nodeType == "rotation") {
      if (t == "R+") {
        replacement = "+";
      } else if (t == "R-") {
        replacement = "-";
      }
      //replacement = "±";
    } else if (nodeType == "production") {
      replacement = t;
    } else if (nodeType == "forward") {
      replacement = "F";
    } else {
      //print("GENERATOR MELTDOWN");
    }
    
    for (Node a : after) {
      if (after.indexOf(a) != after.size()-1) {
        replacement += "[";
      }
      replacement += a.generateSystem();
      if (after.indexOf(a) != after.size()-1) {
        replacement += "]";
      }
    }
    return replacement;
  }
  
  boolean childNearby() {
    if (options.size() == 0) {
      return nearby;
    }
    for (Node o : options) {
      if (o.childNearby()) {
        return true;
      }
    }
    return false;
  }
  
  void adjust(IntList newLims) {
    lims = newLims;
    if (x > lims.get(1) - r) {
      x = lims.get(1) - r;
    }
    if (y > lims.get(3) - r) {
      y = lims.get(3) - r;
    }
  }
  
  void removeOption() {
    int index = optionParent.options.indexOf(this);
    ArrayList<Node> temp = new ArrayList<Node>();
    for (int i = 0; i < optionParent.options.size(); i++) {
      if (i != index) {
        temp.add(optionParent.options.get(i));
      }
    }
    optionParent.options = temp;
  }
  
  void removeNode() {
    globalActivation(false);
    int index = before.after.indexOf(this);
    ArrayList<Node> temp = new ArrayList<Node>();
    for (int i = 0; i < before.after.size(); i++) {
      if (i != index) {
        temp.add(before.after.get(i));
      }
    }
    before.after = temp;
  }
  
  void createNode(String t) {
    //print(OGWindowProds);
    if (WindowProds.indexOf(t) != -1) { 
      //print(t + " is in the list. ");
      optionParent.after.add(new Node(optionParent.x, optionParent.y, 0, "production", t, optionParent, w, lims));
    } else if (t == "F") {
      after.add(new Node(x + Len*(-sin(theta)), y + Len*(-cos(theta)), 0, "forward", "", this, w, lims));
    } else if (t == ">") {
      after.add(new Node(x, y, -PI/2, "rotation", "R-", this, w, lims));
    } else if (t == "<") {
      after.add(new Node(x, y, PI/2, "rotation", "R+", this, w, lims));
    }
    //print("this is t: " + t);
  }
  
  void drawNode(int fill) {
    // This part draws & fills in the shape of the node
    if (nodeType != "forward") {
      w.fill(fill);
      w.stroke(0);
      w.strokeWeight(1);
      w.circle(x, y, d);
      //w.fill(0);
      //w.arc(x, y, 2*r, 2*r, theta+PI/4 + PI/2, theta+PI/4 - PI/2);
    } else {
      w.stroke(0, 0, 255);
      w.strokeWeight(4);
      w.line(x, y, x - Len*(-sin(theta)), y - Len*(-cos(theta)));
      //w.line(optionParent.x, optionParent.y, optionParent.x+100, optionParent.y-100);
    }
    
    if (nodeType == "rotation") {
      w.noStroke();
      w.quad(x, y, x-r*sin(theta+PI/4), y-r*cos(theta+PI/4), 
      x+r*pow(2,0.5)*cos(theta+PI/2), y-r*pow(2,0.5)*sin(theta+PI/2), 
      x+r*cos(theta+PI/4), y-r*sin(theta+PI/4));
      w.stroke(0);
      w.strokeWeight(1);
      w.line(x-r*sin(theta+PI/4), y-r*cos(theta+PI/4), 
      x+r*pow(2,0.5)*cos(theta+PI/2), y-r*pow(2,0.5)*sin(theta+PI/2));
      w.line(x+r*pow(2,0.5)*cos(theta+PI/2), y-r*pow(2,0.5)*sin(theta+PI/2), 
      x+r*cos(theta+PI/4), y-r*sin(theta+PI/4));
      
      //w.line(x,y, x + Len*(-sin(theta)),y + Len*(-cos(theta)));
      //print(theta);
    }
    
    
    // This part adds the text in the middle of the node (if there is any)
    w.fill(0, 255, 0);
    w.textAlign(CENTER, CENTER);
    w.textSize(d-3);
    w.text(t, x, y-3);
  }
  
  void display() {
    
    // This section manages the coloring of each node
    int fill = col;
    if ((options.size() == 0 && over) || (options.size() > 0 && (activated /*|| over*/))) { // 
      fill = col + 50;
    }
    if (firstMousePress && over && options.size() == 0) {
      fill = 255;
      if (t == "-") {
        optionParent.removeNode();
      } else {
        optionParent.createNode(t);
      }
      
    }
    //if (locked) {
    //  fill = 255;
    //} 
    
    drawNode(fill);
    boolean forwardChild = false;
    
    if (nodeType != "option") {
      for (Node a : after) {
        a.display();
        if (a.nodeType == "forward") {
          drawNode(fill);
          forwardChild = true;
        }
      }
      if (forwardChild) {
        //drawNode(fill);
      }
    }
    
    if (activated) {
      if (nodeType != "option") {
      }
      drawNode(fill);
      for (Node o : options) {
        //o.update();
        o.display();
      }
    }
  }
}
