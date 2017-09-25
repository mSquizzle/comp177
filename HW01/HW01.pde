TreeNode selectedNode;
ArrayList<TreeNode> leafList;
int currentMaxDepth;
color rectColor;
color cellHover;
color hoverColor;
ArrayList<Button> drawnButtons;
ArrayList<Button> cellList;
float prevWidth;
float prevHeight;
float rootBorderWidth;
void setup(){
  size(800,400);
  //pine
  rectColor = color(1, 121, 111);
  //jungle green
  cellHover = color(41, 171, 135);
  //emerald
  hoverColor = color(80, 220, 100);
  surface.setResizable(true);
  TreeParser parser = new TreeParser();   
  selectedNode = parser.parse("./hierarchy2.shf");
  reset(selectedNode);
}

void reset(TreeNode node){
  background(255);
  
    prevWidth = width;
    prevHeight = height;
  rootBorderWidth = .02 * width;
  if(width > height){
      rootBorderWidth = .02*height;  
  }
  selectedNode = node;
  currentMaxDepth = selectedNode.getMaxDepth();
  drawnButtons = new ArrayList<Button>();
  cellList = new ArrayList<Button>();
  leafList = selectedNode.getLeaves();
  squarify(selectedNode,width, height, width/2, height/2, 1, "");
}

void mouseClicked(){
  if (mouseButton == RIGHT && !selectedNode.isRoot()){
      reset(selectedNode.parent);
  }else if(mouseButton == LEFT && !selectedNode.isLeaf()){
    Button selectedButton = null;
    for(Button button : drawnButtons){
      if(button.contains(mouseX, mouseY)){
        selectedButton = button; 
      }
    } 
    if(null != selectedButton){
      for(TreeNode child : selectedNode.children){
        if(null != child.path(selectedButton.buttonText)){
          reset(child);
          break;  
        }
      }
    }
  }
}

void draw(){
  println(mouseX, mouseY);
  background(255);
  if(prevWidth == width && prevHeight == height){
    ArrayList<Button> cellMates = new ArrayList<Button>();
    for(Button cell : cellList){
      if(cell.contains(mouseX,mouseY)){
        cell.draw(cell.hover);  
      }else{
        cell.draw();  
      }
    }
    Button selectedButton = null;
    //extremely not performant but...
    for(Button button : drawnButtons){
      //iterate through the buttons to see if any of them contain the mouse
      if(button.contains(mouseX, mouseY)){
        selectedButton = button;
  
        //determine which cellParent we're in
        TreeNode cellParent = null;
        for(TreeNode child : selectedNode.children){
          if(null != child.path(button.buttonText)){
            cellParent = child;
            break;  
          }
        }
        
        //gather all of the leaves in this cell
        if(cellParent != null){
          ArrayList<TreeNode> treeNodes = cellParent.getLeaves();
          for(TreeNode leaf : treeNodes){
            for(int i = 0; i < drawnButtons.size(); i++){
              Button b = drawnButtons.get(i);
              if(b.buttonText.equals(leaf.ID)){
                cellMates.add(b);  
              }
            }
          }
        }
      }else{
        button.draw();  
      }
    }
    //draw the selected button
    if(selectedButton!=null){
      //draw the cell mate in a 'cell hover' state
      for(Button b : cellMates){
       b.draw(cellHover); 
      }  
      //draw the node in a hovered state
      selectedButton.draw(hoverColor);
    }
  }else{
    reset(selectedNode);
  }
}

int numCalled = 0;
void layoutRow(ArrayList<TreeNode> row, float scale, float canvasWidth, float canvasHeight, float centerX, float centerY, boolean widthIsShort, int depth, String parentName){
  float left = centerX - canvasWidth/2;
  float top = centerY - canvasHeight/2;
  //peak at 1/2 maxDepth (ish); 
  float pct = (currentMaxDepth - depth +1 )/ (float)currentMaxDepth;
  float hoverPct = (currentMaxDepth - depth + 2)/ (float)currentMaxDepth;
  //don't want pure black or pure white
  //color in a range of 50 to 205
  color c = color(50+pct*155);
  color hover = color(50+hoverPct*155);
  Button cell = new Button(centerX, centerY, canvasWidth, canvasHeight, c, "");
  cell.hover = hover;
  cellList.add(cell);
  cell.draw();        
  if(widthIsShort){
    //write from left to right
    float prevRight = left;
    for(TreeNode node : row){
      float area = node.getArea() * scale;
      //use canvasHeight as rectHeight
      float rectWidth = area / canvasHeight;
      float rectCenter = prevRight + rectWidth/2;
      //need centerY - given
      if(node.isLeaf()){
        Button button = new Button(rectCenter, centerY, rectWidth-rootBorderWidth, canvasHeight-rootBorderWidth, rectColor, node.ID);
        drawnButtons.add(button);
        button.draw();
      }else{
        squarify(node, rectWidth-rootBorderWidth, canvasHeight-rootBorderWidth, rectCenter, centerY, depth+1, parentName);  
      }
      prevRight = prevRight + rectWidth;
    }
  }else{
    //write from top to bottom
    float prevBottom = top;
    for(TreeNode node : row){
      float area = node.getArea() * scale;
      //use canvasHeight as rectHeight
      float rectHeight = area / canvasWidth;
      float rectCenter = prevBottom + rectHeight/2;
      //need centerY - given  
      if(node.isLeaf()){
        Button button = new Button(centerX, rectCenter, canvasWidth-rootBorderWidth, rectHeight-rootBorderWidth, rectColor, node.ID);
        drawnButtons.add(button);
        button.draw();  
      }else{
        squarify(node, canvasWidth-rootBorderWidth, rectHeight-rootBorderWidth, centerX, rectCenter, depth+1, parentName);
      }
      prevBottom = prevBottom + rectHeight;
    }
  }
}

void squarify(TreeNode parentNode, float canvasWidth, float canvasHeight, float centerX, float centerY, int depth, String parentName){   
   float canvasArea = canvasHeight * canvasWidth;
   //for the initial drawing, we want to start in the upper left corner of our cell
   float right = centerX - canvasWidth/2;
   float bottom = centerY - canvasHeight/2;
   float totalValue = parentNode.getArea();
   ArrayList<TreeNode> children = parentNode.children;
   if(!children.isEmpty()){     
     float vaRatio = canvasArea / totalValue;    
     boolean widthIsShort = true;
     float shortSide = canvasWidth;
     if(canvasWidth > canvasHeight){
       widthIsShort = false;
       shortSide = canvasHeight;
     }
     
     TreeNode maxNode = children.get(0);
     float c1 = maxNode.getArea() * vaRatio;
     float otherSide = c1 / shortSide;
     float aspectRatio = max(shortSide / otherSide, otherSide / shortSide);
     
     ArrayList<ArrayList<TreeNode>> rows = new ArrayList<ArrayList<TreeNode>>();
     ArrayList<TreeNode> currentRow = new ArrayList<TreeNode>();
     currentRow.add(maxNode);
     //loop begin here
     for(int i = 1; i < children.size(); i++){
       TreeNode nextNode = children.get(i);
       float c2 = nextNode.getArea() * vaRatio;
       float totalRow = c1 + c2;
       float newOtherSide = totalRow / shortSide;
       float nextAspectRatio = max(shortSide / newOtherSide, newOtherSide / shortSide);
       
       //better is closest to 1
       float firstDiff = Math.abs(1 - aspectRatio);
       float secondDiff = Math.abs(1 - nextAspectRatio);
       maxNode = nextNode;
       if(firstDiff < secondDiff){
         //ratio is better without adding this node
         //lock down this row and draw
         if(widthIsShort){
           layoutRow(currentRow, vaRatio, shortSide, otherSide, right + shortSide/2, bottom + otherSide/2, true, depth, parentName); 
           bottom = bottom + otherSide;
         }else{
           layoutRow(currentRow, vaRatio, otherSide, shortSide, right + otherSide/2, bottom + shortSide/2, false, depth, parentName); 
           right = right +  otherSide;
         }
         rows.add(currentRow);
         currentRow = new ArrayList<TreeNode>();
         currentRow.add(nextNode);
         //reinitialize variables for next iteration
         c1 = c2;
         if(widthIsShort){
           //canvas width does not change
           canvasHeight = canvasHeight - otherSide;        
         }else{
           //canvas height does not change
           canvasWidth = canvasWidth - otherSide;
         }
         widthIsShort = true;
         shortSide = canvasWidth;
         if(canvasWidth > canvasHeight){
           widthIsShort = false;
           shortSide = canvasHeight;
         }
         otherSide = c1/shortSide;
         aspectRatio = max(otherSide / shortSide, shortSide / otherSide); 
       }else{
         //othewise, our ratio is improved by adding this node
         //add this node to our list
         currentRow.add(nextNode);
         //update the area
         c1 = c1 + c2;
         //update the aspect ratios 
         otherSide = newOtherSide;
         aspectRatio = nextAspectRatio;
       }
     }
     rows.add(currentRow);
     layoutRow(currentRow, vaRatio, canvasWidth, canvasHeight, right + canvasWidth/2, bottom + canvasHeight/2, widthIsShort, depth, parentName);      
   }else{
     //this is a leaf, just draw it out
     drawnButtons = new ArrayList<Button>(1);
     drawnButtons.add(new Button( canvasWidth/2, canvasHeight/2,canvasWidth, canvasHeight, rectColor, selectedNode.ID));
   }
}