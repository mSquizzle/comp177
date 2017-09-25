TreeNode selectedNode;
int currentMaxDepth;
color rectColor;
color hoverColor;
ArrayList<Button> drawnButtons;
float prevWidth;
float prevHeight;

void setup(){
  size(800,400);
  rectColor = color(55, 150, 80);
  hoverColor = color(100, 300, 150);
  surface.setResizable(true);
  TreeParser parser = new TreeParser();   
  selectedNode = parser.parse("./hierarchy2.shf");
  parser.printTree(selectedNode);
  reset(selectedNode);
}

void reset(TreeNode node){
  selectedNode = node;
  currentMaxDepth = selectedNode.getMaxDepth();
  drawnButtons = new ArrayList<Button>();
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
  background(255);
  if(prevWidth == width && prevHeight == height){
    for(Button button : drawnButtons){
      if(button.contains(mouseX, mouseY)){
        button.draw(hoverColor);  
      }else{
        button.draw();  
      }
    }
  }else{
    prevWidth = width;
    prevHeight = height;
    drawnButtons = new ArrayList<Button>();
    squarify(selectedNode, width, height, width/2, height/2, 1);
  }
}

int numCalled = 0;
float frameAdjust = .99;
void layoutRow(ArrayList<TreeNode> row, float scale, float canvasWidth, float canvasHeight, float centerX, float centerY, boolean widthIsShort, int depth){
  float left = centerX - canvasWidth/2;
  float top = centerY - canvasHeight/2;
  
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
        Button button = new Button(rectCenter, centerY, rectWidth, canvasHeight, rectColor, node.ID);
        drawnButtons.add(button);
      button.draw();
      }else{
        squarify(node, rectWidth*frameAdjust, canvasHeight*frameAdjust, rectCenter, centerY, depth+1);  
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
        Button button = new Button(centerX, rectCenter, canvasWidth, rectHeight, rectColor, node.ID);
        drawnButtons.add(button);
        button.draw();  
      }else{
        squarify(node, canvasWidth*frameAdjust, rectHeight*frameAdjust, centerX, rectCenter, depth+1);
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
   //todo - use better sorting algorithm
   ArrayList<TreeNode> children = parentNode.children;
   ArrayList<TreeNode> sortedChildren = new ArrayList<TreeNode>(children.size());
   if(!children.isEmpty()){
     for(TreeNode node : parentNode.children){
        println("Node "+node.ID+" - Area "+node.getArea()); 
     }
     
     float vaRatio = canvasArea / totalValue;    
     boolean widthIsShort = true;
     float shortSide = canvasWidth;
     if(canvasWidth > canvasHeight){
       widthIsShort = false;
       shortSide = canvasHeight;
     }
     
     sortedChildren = children;
     TreeNode maxNode = sortedChildren.get(0);
     float c1 = maxNode.getArea() * vaRatio;
     float otherSide = c1 / shortSide;
     float aspectRatio = min(shortSide / otherSide, otherSide / shortSide);
     
     ArrayList<ArrayList<TreeNode>> rows = new ArrayList<ArrayList<TreeNode>>();
     ArrayList<TreeNode> currentRow = new ArrayList<TreeNode>();
     currentRow.add(maxNode);
     //loop begin here
     for(int i = 1; i < sortedChildren.size(); i++){
       TreeNode nextNode = sortedChildren.get(i);
       float c2 = nextNode.getArea() * vaRatio;
       float totalRow = c1 + c2;
       float newOtherSide = totalRow / shortSide;
       float nextAspectRatio = min(shortSide / newOtherSide, newOtherSide / shortSide);
       
       //better is closest to 1
       float firstDiff = Math.abs(1 - aspectRatio);
       float secondDiff = Math.abs(1 - nextAspectRatio);
       maxNode = nextNode;
       if(firstDiff < secondDiff){
         //lock down this row and redraw  
         if(widthIsShort){
           //layoutRow(ArrayList<TreeNode> row, float scale, float canvasWidth, float canvasHeight, float centerX, float centerY, boolean widthIsShort)
           //println("shortside "+shortSide);
           //println("c1 - "+c1);
           //shortSide = height
           //println("Otherside "+otherSide);
           //println("Right "+right);
           //println("Bottom "+bottom);
           layoutRow(currentRow, vaRatio, shortSide, otherSide, right + shortSide/2, bottom + otherSide/2, true, depth+1); 
           bottom = bottom + otherSide;
         }else{
           //layoutRow(ArrayList<TreeNode> row, float scale, float canvasWidth, float canvasHeight, float centerX, float centerY, boolean widthIsShort)
           layoutRow(currentRow, vaRatio, otherSide, shortSide, right + otherSide/2, bottom + shortSide/2, false, depth+1); 
           right = right +  otherSide;
         }
         rows.add(currentRow);
         currentRow = new ArrayList<TreeNode>();
         currentRow.add(nextNode);
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
         aspectRatio = min(otherSide / shortSide, shortSide / otherSide); 
         
         
       }else{
         //add this to our row and try to add the next node 
         println("adding node "+nextNode.ID+" to our list");
         currentRow.add(nextNode);
         //update the area
         c1 = c1 + c2;
         //update the aspect ratios 
         otherSide = newOtherSide;
         aspectRatio = nextAspectRatio;
       }
     }
     rows.add(currentRow);
 //    println("Right "+right);
  //   println("Bottom "+bottom);
     layoutRow(currentRow, vaRatio, canvasWidth, canvasHeight, right + canvasWidth/2, bottom + canvasHeight/2, widthIsShort, depth+1);      
   }else{
     drawnButtons = new ArrayList<Button>(1);
     drawnButtons.add(new Button( canvasWidth/2, canvasHeight/2,canvasWidth, canvasHeight, rectColor, selectedNode.ID));
   }
}