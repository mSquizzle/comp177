class Button {
  
  String buttonText;
  float x , y, buttonWidth, buttonHeight;
  color c;   
  int textSize;
  String containerID;
 
  public Button(float x, float y, float buttonWidth, float buttonHeight, color c, String buttonText){
    this.x = x;
    this.y = y;
    this.buttonWidth = buttonWidth;
    this.buttonHeight = buttonHeight;
    this.c = c;
    this.buttonText = buttonText;
    textSize = 15;
    containerID = "";
  }
  
  void draw(){
    draw(c); 
  }
  
  void draw(color override){
    fill(override);
    rectMode(CENTER);
    noStroke();
    //stroke(150);
    rect(x, y, buttonWidth, buttonHeight);
    textAlign(CENTER, CENTER);
    fill(0,0,0);  
    if(textSize > buttonHeight){
      textSize = int(buttonHeight) - 1;  
    }
    textSize(textSize);
    text(buttonText, x, y, buttonWidth, buttonHeight); 
  }
  
  boolean contains(float xCord, float yCord){
   float left = x - buttonWidth/2;
   float right = x + buttonWidth/2;
   float bottom = y - buttonHeight/2;
   float top = y + buttonHeight/2;
   if(xCord >= left && xCord <= right){
     if(yCord >= bottom && yCord <= top){
       return true;
     }
    }
    return false;  
  }
  
  //setters
  
  void setColor(color c){
    this.c = c;  
  }
  
  void setButtonText(String buttonText){
    this.buttonText = buttonText;
  }
  
  void setWidth(int buttonWidth){
    this.buttonWidth = buttonWidth;
  }
  
  void setHeight(int buttonHeight){
    this.buttonHeight = buttonHeight;
  }
  
  void setX(int x){
    this.x = x;
  }
  
  void setY(int y){
    this.y = y;  
  }
  
  void setTextSize(int size){
    this.textSize = size;
  }
}