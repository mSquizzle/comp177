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
  selectedNode = node;
  currentMaxDepth = selectedNode.getMaxDepth();
  drawnButtons = new ArrayList<Button>();
  leafList = selectedNode.getLeaves();
  squarify(selectedNode,width, height, width/2, height/2, 1);
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
  if(prevWidth == width && prevHeight == height){
    ArrayList<Button> cellMates = new ArrayList<Button>();
    Button selectedButton = null;
    //extremely not performant but...
    for(Button button : drawnButtons){
      //iterate through the buttons to see if any of them contain the mouse
      if(button.contains(mouseX, mouseY)){
        selectedButton = button;
  
        TreeNode cellParent = null;
        for(TreeNode child : selectedNode.children){
          if(null != child.path(button.buttonText)){
            cellParent = child;
            break;  
          }
        }
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
    if(selectedButton!=null){
        for(Button b : cellMates){
         b.draw(cellHover); 
        }  
        selectedButton.draw(hoverColor);
      }
  }else{
    prevWidth = width;
    prevHeight = height;
    drawnButtons = new ArrayList<Button>();
    background(255);
    squarify(selectedNode, width, height, width/2, height/2, 1);
  }
}

int numCalled = 0;
float largeFrameAdjust = .95;
float smallFrameAdjust = .94;
void layoutRow(ArrayList<TreeNode> row, float scale, float canvasWidth, float canvasHeight, float centerX, float centerY, boolean widthIsShort, int depth){
  float left = centerX - canvasWidth/2;
  float top = centerY - canvasHeight/2;
  //peak at 1/2 maxDepth (ish); 
  float pct = (currentMaxDepth - depth +1 )/ (float)currentMaxDepth;
  //50+
  fill(50+pct*155);
  noStroke();
  rectMode(CENTER);
  rect(centerX, centerY, canvasWidth, canvasHeight);
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
        Button button = new Button(rectCenter, centerY, rectWidth*smallFrameAdjust, canvasHeight*largeFrameAdjust, rectColor, node.ID);
        drawnButtons.add(button);
        button.draw();
      }else{
        squarify(node, rectWidth*smallFrameAdjust, canvasHeight*largeFrameAdjust, rectCenter, centerY, depth+1);  
      }
      prevRight = prevRight + rectWidth;
    }
  }else{
    //write from top to bottom
    float prevBottom = top;
    float sum = 0;
    for(TreeNode node : row){
      float area = node.getArea() * scale;
      sum += node.getArea();
      //use canvasHeight as rectHeight
      float rectHeight = area / canvasWidth;
      float rectCenter = prevBottom + rectHeight/2;
      //need centerY - given  
      if(node.isLeaf()){
        Button button = new Button(centerX, rectCenter, canvasWidth*largeFrameAdjust, rectHeight*smallFrameAdjust, rectColor, node.ID);
        drawnButtons.add(button);
        button.draw();  
      }else{
        squarify(node, canvasWidth*largeFrameAdjust, rectHeight*smallFrameAdjust, centerX, rectCenter, depth+1);
      }
      prevBottom = prevBottom + rectHeight;
    }
  }
}

void squarify(TreeNode parentNode, float canvasWidth, float canvasHeight, float centerX, float centerY, int depth){   
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
           layoutRow(currentRow, vaRatio, shortSide, otherSide, right + shortSide/2, bottom + otherSide/2, true, depth); 
           bottom = bottom + otherSide;
         }else{
           layoutRow(currentRow, vaRatio, otherSide, shortSide, right + otherSide/2, bottom + shortSide/2, false, depth); 
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
     layoutRow(currentRow, vaRatio, canvasWidth, canvasHeight, right + canvasWidth/2, bottom + canvasHeight/2, widthIsShort, depth);      
   }else{
     //this is a leaf, just draw it out
     drawnButtons = new ArrayList<Button>(1);
     drawnButtons.add(new Button( canvasWidth/2, canvasHeight/2,canvasWidth, canvasHeight, rectColor, selectedNode.ID));
   }
}