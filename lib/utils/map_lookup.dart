dynamic lookup(dynamic root, List<dynamic> path) {
  if(root == null || path == null) return null;
  var obj = root;
  for(var i in path){
    if(obj[i] != null){
      obj = obj[i];
    }else{
      return null;
    }
  }
  return obj;
}