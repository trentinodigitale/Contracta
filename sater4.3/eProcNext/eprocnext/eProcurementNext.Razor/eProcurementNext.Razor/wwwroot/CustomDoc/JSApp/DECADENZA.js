function SetDecadenzaTuttiLotti(){
  
 
  
  if ( getObj( 'InterrompiProcedura' ).checked ){
    
    getObj( 'DecadenzaTuttiLotti' ).checked = false ;
    getObj('cap_DecadenzaTuttiLotti').style.display='none';
    getObj('DecadenzaTuttiLotti').style.display='none';
    
  }else{
    
    getObj('cap_DecadenzaTuttiLotti').style.display='';
    getObj('DecadenzaTuttiLotti').style.display='';
    
  }
  
  
}