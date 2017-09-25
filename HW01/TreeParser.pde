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
  
  TreeNode findById(ArrayList<TreeNode> nodeList, String ID){
    for(int i = 0; i < nodeList.size(); i++){
      TreeNode currentNode = nodeList.get(i);
      if(ID.equals(currentNode.ID)){
        return currentNode;  
      }
    }
    return null; 
  }
  
  TreeNode parse(String fileName){
    String[] lines = loadStrings(fileName); 
    int numLeaves = int(lines[0]);
    ArrayList<TreeNode> createdNodes = new ArrayList<TreeNode>(numLeaves);
    
    for(int i = 1; i < numLeaves + 1; i++){
      String[] line = lines[i].split(" ");
      String id = line[0];
      int area = int(line[1]);
      createdNodes.add(new TreeNode(id, area));
    }
  
    int numEdges = int(lines[1+numLeaves]);
    ArrayList<TreeNode> createdParents = new ArrayList<TreeNode>(numEdges);
    for(int i = numLeaves + 2; i < numLeaves + 2 + numEdges; i++){
      String[] ids = lines[i].split(" ");
      String parentId = ids[0];
      String childId = ids[1];
      
      TreeNode parentNode = null, childNode = null;
   
      //try to find parent in list of created parents
      for(int j = 0; j < createdParents.size(); j++){
        TreeNode currentNode = createdParents.get(j);
        if(currentNode.ID.equals(parentId)){
           parentNode = currentNode; 
        }
      }
      
      //otherwise, create a parent and add to our list
      if(null == parentNode){
        parentNode = new TreeNode(parentId, 0);  
        createdParents.add(parentNode);
      }
      
      //try to find child out of our leaves first
      for(int j = 0; j < createdNodes.size(); j++){
        TreeNode currentNode = createdNodes.get(j);
        if(currentNode.ID.equals(childId)){
           childNode = currentNode; 
        }
      }
      //otherwise try to find it our of our parent list
      if(null == childNode){
        for(int j = 0; j < createdParents.size(); j++){
        TreeNode currentNode = createdParents.get(j);
          if(currentNode.ID.equals(childId)){
             childNode = currentNode; 
          }
        } 
      }
      //otherwise, create a new child and add it to our list
      if(null == childNode){
        childNode = new TreeNode(childId, 0);  
        createdParents.add(childNode);
      }
      
      //create link between the two nodes
      parentNode.addChild(childNode);
      childNode.setParent(parentNode);
    }
    
    //the tree is complete - find and return the root
    for(int i = 0; i < createdParents.size(); i++){
      if(createdParents.get(i).isRoot()){
        createdParents.get(i).sortChildren();
        return createdParents.get(i);
      }
    }
     
    //if we don't have a root, then something's gone wrong
    return null; 
  }
}