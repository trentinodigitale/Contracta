<script language="javascript">

 
  window.onload = InitDoc ;
  
  function InitDoc(){
  
    
    //inserisco un testo di default nel tab note
    SetDefaultComunicazione();
    
  
  }
  
  
  //inserisco un testo di default nel tab note
  function SetDefaultComunicazione(){
    
        
    //solo in caso di nuovo
    if ( getObj('Stato').value == '0' ){
      
      var strDefaultText = CNV('../../' , 'default verifica amministrativa' ) ;
      
      //rimpiazzo #NUMPARTECIPANTI#,#NUMAMMESSE#,#NUMESCLUSE#
      var nNumPartecipanti = opener.parent.getObj('NumProduct_Valutazione_griglia').value;
      strDefaultText = strDefaultText.replace( '#NUMPARTECIPANTI#', nNumPartecipanti );
      
      //recupero ammesse ed escluse
      var nRow = opener.parent.getObj('NumProduct_Valutazione_griglia').value;
      var colStatoPDA = opener.parent.GetColumnPositionInGrid('StatoPDA','Valutazione_griglia');
      
      var nNumAmmesse=0;
      var nNumEscluse=0;
      
      for ( i=1; i <= nRow; i++ ){
        
        strStatoPDARow = opener.parent.getObj('Valutazione_griglia_' + i + '_' + colStatoPDA).value;
        if ( strStatoPDARow != '1')
          nNumAmmesse = nNumAmmesse + 1 ;
        else
          nNumEscluse = nNumEscluse + 1 ;
      }
    
      
      strDefaultText = strDefaultText.replace( '#NUMAMMESSE#', nNumAmmesse );
      strDefaultText = strDefaultText.replace( '#NUMESCLUSE#', nNumEscluse );      
      
      getObj('DOCUMENTAZIONE').value = strDefaultText ; 
      
      
    }
  
  }
 
  
	
</script>


