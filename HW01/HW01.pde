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
        if(child.ID.equals(selectedButton.buttonText)){
        reset(child);
        return;
        }
      }
    }
    
    String containerID = "";
    for(Button cell : cellList){
      if(cell.contains(mouseX,mouseY)){
        containerID = cell.containerID;
      }
    }
    if(!"".equals(containerID)){
      for(TreeNode node : selectedNode.children){
        if(node.ID.equals(containerID)){
          reset(node);
          break;
        }
      }
    }   
  }
}

void draw(){
  background(255);
  
   //EM Added
  color gradientColor = color(80, 220, 100);
  if(drawnButtons.size() == 1){
    Button button = drawnButtons.get(0);
    if(button.contains(mouseX, mouseY)){
       gradientColor = color(80, 25, 100);
       button.draw(gradientColor, hoverColor);
       return;
    }
  }
  
  //Change button color
  for(Button button : drawnButtons){
      if(button.contains(mouseX, mouseY)){            
         for(TreeNode node : selectedNode.children){ 
            ArrayList<TreeNode> path = node.path(button.buttonText);
            if(button.buttonText.equals(node.ID) || (null != path && !path.isEmpty())){               
              int distance = path == null ? 0 : path.size();
              int newColor = 25;
              if(distance == 0){
                newColor = 0;
              }else if (distance < 2){
                newColor = 75;
              }else if (distance < 3){
                newColor = 100;
              }else if (distance < 4){
                newColor = 150;
              }else if (distance < 5){
                newColor = 200;
              }else{
                newColor = 250;           
              }
              //todo - switch to pct? 
              //newColor = 25 + distance / currentMaxDepth * 225;
              gradientColor = color(98, newColor, 150);
              break;
             }
          }
      }
  }
  //END of EM add 9/25
  
  
  if(prevWidth == width && prevHeight == height){
    ArrayList<Button> cellMates = new ArrayList<Button>();
    String containerID = "";
    
    for(int i = cellList.size() -1; i >=0; i--){
      Button cell = cellList.get(i);
      if(cell.contains(mouseX, mouseY)){
        containerID = cell.containerID;
        break;
      }
    }
    
    if(!"".equals(containerID)){
      for(Button cell : cellList){
        if(containerID.equals(cell.containerID) && cell.depth != 2){
          cell.draw(cell.hover);
        }else{
          cell.draw();  
        }
      }
      for(Button leaf : drawnButtons){
        if(leaf.containerID.equals(containerID)){
          cellMates.add(leaf);  
        }
      }
    }else{
      for(Button cell : cellList){
       
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
        if(cellParent != null && !cellMates.isEmpty()){
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
    for(Button b : cellMates){
         b.draw(cellHover); 
    }  
    //draw the selected button
    if(selectedButton!=null){
      //draw the node in a hovered state
      selectedButton.draw(gradientColor, hoverColor);
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
  float hoverPct = (currentMaxDepth - depth + 1.5)/ (float)currentMaxDepth;
  //don't want pure black or pure white
  //color in a range of 50 to 205
  color c = color(50+pct*155);
  color hover = color(50+hoverPct*155);
  Button cell = new Button(centerX, centerY, canvasWidth, canvasHeight, c, "");
  cell.depth = depth;
  if(depth!=1){
     cell.containerID = parentName;
     cell.hover = hover;
  }else{
    cell.hover = c;  
  } 
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
        if(node.parent.ID.equals(selectedNode.ID)){
          button.containerID = node.ID;  
        }else{    
          button.containerID = parentName;  
        }
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
        if(node.parent.ID.equals(selectedNode.ID)){
          button.containerID = node.ID;  
        }else{    
          button.containerID = parentName;  
        }
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
           String passedParent = parentName;
           if(!parentNode.isRoot() && parentNode.parent.ID.equals(selectedNode.ID)){
             passedParent = parentNode.ID;    
           }else if("".equals(parentName)){
             passedParent = currentRow.get(0).ID;  
           }
         //ratio is better without adding this node
         //lock down this row and draw
         if(widthIsShort){
           layoutRow(currentRow, vaRatio, shortSide, otherSide, right + shortSide/2, bottom + otherSide/2, true, depth, passedParent); 
           bottom = bottom + otherSide;
         }else{
           layoutRow(currentRow, vaRatio, otherSide, shortSide, right + otherSide/2, bottom + shortSide/2, false, depth, passedParent); 
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
    String passedParent = parentName;
    if(!parentNode.isRoot() && parentNode.parent.ID.equals(selectedNode.ID)){
       passedParent = parentNode.ID;    
     }else if("".equals(parentName)){
       passedParent = currentRow.get(0).ID;  
     }
     
     rows.add(currentRow);
     layoutRow(currentRow, vaRatio, canvasWidth, canvasHeight, right + canvasWidth/2, bottom + canvasHeight/2, widthIsShort, depth, passedParent);      
   }else{
     //this is a leaf, just draw it out
     drawnButtons = new ArrayList<Button>(1);
     drawnButtons.add(new Button(canvasWidth/2, canvasHeight/2,canvasWidth, canvasHeight, rectColor, selectedNode.ID));
   }
}