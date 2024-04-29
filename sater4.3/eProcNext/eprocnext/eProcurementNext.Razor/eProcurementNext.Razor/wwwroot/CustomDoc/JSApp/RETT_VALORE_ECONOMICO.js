window.onload = OnLoadPage; 

function OnLoadPage()
{
    
    strVersione = getObj('Versione').value ;
    
    
    if ( strVersione == '' ) {
      //solo per versioni precedenti; aggiungere nascondere quantità
      
      var strDivisione_lotti = '';
      
      try{ strDivisione_lotti = getObjValue( 'Divisione_lotti' ); }catch(e){ strDivisione_lotti = ''; };
      
      //-- se è privista la conformita Ex-Ante oppure è economicamente più vantaggiosa si devono aprire i singoli lotti
      if( strDivisione_lotti != '0'  ){   
        
        ShowCol( 'VALORI_PRODOTTI' , 'NumeroRiga' , 'none' );
        
      }else{
      
        ShowCol( 'VALORI_PRODOTTI' , 'Voce' , 'none' );
        
      }
      
      //NASCONDO LE NUOVE AREE 
      getObj('VALORE_PRODOTTI_SOURCE').style.display='none';
      getObj('VALORE_PRODOTTI_DEST').style.display='none';
      
      
    }
    
    
    if ( strVersione == '2.0' ) {
    
      //NASCONDO VECCHIA AREA
      getObj('VALORI_PRODOTTI').style.display='none';
      
      //NASCONDO IL CESTINO GRIGLIA EDITABILE
      ShowCol( 'VALORE_PRODOTTI_DEST' , 'FNZ_DEL' , 'none' )
      
      
      //SULLA NUOVA GRIGLIA RENDO LE COLONNE NUMEROLOTTO,VOCE,NUMERORIGA,VARIANTE NON EDITABILI
        
      //EVIDENZA MODIFICHE NUOVA OFFERTA SE DOC READONLY
      if ( getObj('DOCUMENT_READONLY').value == '1' )
        EvidenzaCambiamenti();
      
    }
    
}

function EvidenzaCambiamenti(){
  
  var strNewValue;
  var strOldValue;
  
  //ciclo su tutte le righe 
  for( i = VALORE_PRODOTTI_DESTGrid_StartRow ; i <= VALORE_PRODOTTI_DESTGrid_EndRow ; i++ ){
    
    //ciclo su tutte le colonne
    for( j = 2 ; j <= 100 ; j++ ){
      
      try{
      
        strNewValue =  ReplaceExtended(getObj('VALORE_PRODOTTI_DESTGrid_r' + i + '_c' + j).outerHTML,'VALORE_PRODOTTI_DEST','');
        strOldValue =  ReplaceExtended(getObj('VALORE_PRODOTTI_SOURCEGrid_r' + i + '_c' + j).outerHTML,'VALORE_PRODOTTI_SOURCE','');
        
        //alert(getObj('VALORE_PRODOTTI_SOURCEGrid_r' + i + '_c' + j).innerText);
           
        //se una cella differisce la evidenzio con una classe  evidenza
        if ( strNewValue != strOldValue ){
            
            getObj('VALORE_PRODOTTI_DESTGrid_r' + i + '_c' + j).style.border='2px solid red';
            
        }
     }catch(e){}  
     
    }
  }
  
}
