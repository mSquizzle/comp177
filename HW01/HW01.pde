class TreeNode {
  TreeNode parent;
  ArrayList<TreeNode> children;
  String ID;
  int area; //double check if we need to swap up to something bigger

  
  TreeNode(String ID, int area){
    this.ID = ID;
    this.area = area;
    children = new ArrayList<TreeNode>();
  }
  
  void addChild(TreeNode child){
    children.add(child); 
  }
  
  void setParent(TreeNode parent){
   this.parent = parent; 
  }
  
  
  int numLeaves(){
    if(isLeaf()){
     return 1; 
    }else{
     int sum = 0;
     for(int i = 0; i < children.size(); i++){
        sum += children.get(i).numLeaves(); 
     }
     return sum;
    }
  }
  
  boolean isRoot(){
   return null == parent; 
  }
  
  boolean isLeaf(){
    return null == children || children.isEmpty();  
  }
  
  int getArea(){
    if(isLeaf()){
     return area; 
    }else{
       int sum = 0;
       for(int i = 0; i < children.size(); i++){
          sum += children.get(i).getArea(); 
       }
       return sum;
    }
  }
}