
void setup(){
    println("hello!");
    TreeParser parser = new TreeParser();
    
   TreeNode node = parser.parse("./hierarchy1.shf");
   parser.printTree(node);
  }

class TreeParser{
  
  void printTree(TreeNode n){
    if(null == n){
     return; 
    }
    if(n.isLeaf()){
       println("Leaf : "+n.ID+" Area: "+n.area); 
    }else{
      for(int i = 0; i < n.children.size(); i++){
        println("Parent "+n.ID+" - Child: "+n.children.get(i).ID);
        printTree(n.children.get(i));
      }
    }
  }
  
  
  
  
  TreeNode parse(String fileName){
    String[] lines = loadStrings(fileName);
    printArray(lines);
    
    int numLeaves = int(lines[0]);
    
    ArrayList<TreeNode> createdNodes = new ArrayList<TreeNode>(numLeaves);
    
    for(int i = 1; i <= numLeaves + 1; i++){
      String[] line = lines[i].split(" ");
      String id = line[0];
      int area = int(line[1]);
      println("Creating Node "+id+" "+area);
      createdNodes.add(new TreeNode(id, area));
    }
  
    int numEdges = int(lines[1+numLeaves]);
    ArrayList<TreeNode> createdParents = new ArrayList<TreeNode>(numEdges);
    for(int i = numLeaves + 2; i <= numLeaves + 2 + numEdges; i++){
      String[] ids = lines[i].split(" ");
      String parentId = ids[0];
      String childId = ids[1];
      println("Making edge from "+parentId+" to "+childId);
      //check to see if we have a parent node with the parentId
      //else if we don't, create a parentNode and add it to our list
      //create parent/child relationship
      
      TreeNode parentNode = null, childNode = null;
      for(int j = 0; j < createdParents.size(); j++){
        TreeNode currentNode = createdParents.get(j);
        if(currentNode.ID.equals(parentId)){
           parentNode = currentNode; 
        }
      }
      
      for(int j = 0; j < createdNodes.size(); j++){
        TreeNode currentNode = createdNodes.get(j);
        if(currentNode.ID.equals(childId)){
           childNode = currentNode; 
        }
      }
      if(null == childNode){
        for(int j = 0; j < createdParents.size(); j++){
        TreeNode currentNode = createdParents.get(j);
          if(currentNode.ID.equals(childId)){
             childNode = currentNode; 
          }
        } 
      }
      
      if(null == parentNode){
        parentNode = new TreeNode(parentId, 0);  
      }
      
      if(null != childNode){
        parentNode.addChild(childNode);
        childNode.setParent(parentNode);  
      }
    }
    
    for(int i = 0; i < createdParents.size(); i++){
      if(createdParents.get(i).isRoot()){
         return createdParents.get(i);
      }
    }
     
    return null; 
  }
}