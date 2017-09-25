


class TreeParser{
  
  void printTree(TreeNode n){
    if(null == n){
     return; 
    }
    if(n.isLeaf()){
//       println("Leaf : "+n.ID+" Area: "+n.area); 
    }else{
      for(int i = 0; i < n.children.size(); i++){
  //      println("Parent "+n.ID+" - Child: "+n.children.get(i).ID);
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
    printArray(lines);
    
    int numLeaves = int(lines[0]);
    
    ArrayList<TreeNode> createdNodes = new ArrayList<TreeNode>(numLeaves);
    
    for(int i = 1; i < numLeaves + 1; i++){
      String[] line = lines[i].split(" ");
      String id = line[0];
      int area = int(line[1]);
      //println("Creating Node "+id+" "+area);
      createdNodes.add(new TreeNode(id, area));
    }
  
    int numEdges = int(lines[1+numLeaves]);
    ArrayList<TreeNode> createdParents = new ArrayList<TreeNode>(numEdges);
    for(int i = numLeaves + 2; i < numLeaves + 2 + numEdges; i++){
      String[] ids = lines[i].split(" ");
      String parentId = ids[0];
      String childId = ids[1];
      println("Making edge from "+parentId+" to "+childId);
      
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
      if(null == childNode){
        childNode = new TreeNode(childId, 0);  
        createdParents.add(childNode);
      }
      
      if(null == parentNode){
        parentNode = new TreeNode(parentId, 0);  
        createdParents.add(parentNode);
      }
      
      if(null != childNode){
        parentNode.addChild(childNode);
        childNode.setParent(parentNode);
        println("Edge made!");
      }else{
        println("Edge not made "); 
      }
    }
    
    for(int i = 0; i < createdParents.size(); i++){
      if(createdParents.get(i).isRoot()){
        createdParents.get(i).sortChildren();
        return createdParents.get(i);
      }
    }
     
    return null; 
  }
}