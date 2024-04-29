<script language="javascript">


window.onload = InitPrequalifica ;

function InitPrequalifica() {
  
  var IdDoc_Bando="";
  var IdDoc_BGLP="";
  
  try{
    IdDoc_Bando = getObj( 'IdDoc_Bando' ).value ;
  }catch(e){} 
  
  try{
    IdDoc_BGLP = getObj( 'IdDoc_BGLP' ).value ;
  }catch(e){} 
  
  if ( IdDoc_Bando == ''  ){
    //NASCONDO CREA INVITO DEL FLUSSO UNICO
    getObj('CREATE_ANSWER_5').style.display='none';
    try{
      getObj('IMG_CREATE_ANSWER_5').style.display='none';
    }catch(e){}
  }
  
  if ( IdDoc_BGLP == ''  ){
    //NASCONDO CREA INVITO DEL FLUSSO PROCEDURE RISTRETTE VECCHIO
    getObj( 'CREATE_ANSWER_6').style.display='none';
    try{
      getObj('IMG_CREATE_ANSWER_6').style.display='none';
    }catch(e){}
  }
  
  //aggiorno statofirme e presenzaAvvalimenti
  GetStatoFirmeAvvalimenti();
  
}


//recupera le info per aggiornare le colonne StatoFirme  e PresenzaAvvalimenti
function GetStatoFirmeAvvalimenti(){
  
  var colStatoFirme = GetColumnPositionInGrid('StatoFirme','Valutazione_griglia');
 
  //se esiste procedo
  if ( colStatoFirme != -1 ){
    
    ajax = GetXMLHttpRequest(); 
    if(ajax){
    		
        ajax.open("GET", './Command/Evaluate/Get_StatoFirme_Avvalimenti.asp?IDDOC_PDA=' + getObj('lIdMsgPar').value , false);
    	  ajax.send(null);
        
        if(ajax.readyState == 4) {
          
          if(ajax.status == 200)
    	    {
    		    var result1 =  ajax.responseText;
            
    		    if ( result1 != '' ){
    		     
              var aInfoResult= result1.split('@@@') ;
              var nNumOff = aInfoResult.length;
             
              var j;
              
              //aggiorno le colonne per tutte le righe
              for ( j=0; j <= nNumOff -1 ; j++ ){
                
                
                SetStatoFirmeAvvalimneti( aInfoResult[j] );
      
              }  
              
           }
          }
        }
    }   
    
  
  }

}



//aggiorna per una singola riga le colonne StatoFirme e presenzaAvvalimenti
function SetStatoFirmeAvvalimneti(paramStatoFirme){
  
  var TitleModifica = CNV('../../' , 'Allegati Offerta' );
  
 
  
  var aInfoUpgrade = paramStatoFirme.split(";");
  var lIdMsgUpdate = aInfoUpgrade[0];
  var StatoFirmeUpgrade = aInfoUpgrade[1];
  var PreAvvalimentiUpgrade = aInfoUpgrade[2];
  
  //recupero numero righe griglia valutazione
  var nRow = getObj('NumProduct_Valutazione_griglia').value;
  
  //recupero posizione colonna StatoFirme
  var colStatoFirme = GetColumnPositionInGrid('StatoFirme','Valutazione_griglia');
  
  //recupero posizione colonna StatoFirme
  var colPresAvvalimenti = GetColumnPositionInGrid('PresenzaAvvalimenti','Valutazione_griglia');
  
  var lIdMsgCurr ;
  var objCellCurr ;
  var objhiddenCurr ;
  
  
  var k;
  for ( k=1; k <= nRow; k++ ){
      
      //recupero idmsg della riga
      lIdMsgCurr = -1 ;
      lIdMsgCurr = getObj('Valutazione_griglia_' + k + '_0').value;
      
      if ( lIdMsgCurr == lIdMsgUpdate){
        
        //aggiorno colonna Avvalimenti
        objCellCurr = null;
        objCellCurr = getObj('cell_Valutazione_griglia_' + k + '_' + colPresAvvalimenti);
        
        objhiddenCurr = null;
        objhiddenCurr = getObj('Valutazione_griglia_' + k + '_' + colPresAvvalimenti);
       
        if ( PreAvvalimentiUpgrade == '0'){
          objCellCurr.innerHTML = 'No';
          objhiddenCurr.value= '0#~No';
        }else{
          objCellCurr.innerHTML = 'Si';
          objhiddenCurr.value= '1#~Si';     
        }
        
        //aggiorno colonna StatoFirme
        objCellCurr = null;
        objCellCurr = getObj('cell_Valutazione_griglia_' + k + '_' + colStatoFirme);
        
        objhiddenCurr = null;
        objhiddenCurr = getObj('Valutazione_griglia_' + k + '_' + colStatoFirme);
        
        PathImgCurr='';
        if ( StatoFirmeUpgrade == 'uguale'){
          TitleModifica = CNV('../../' , 'stesso firmatario' );
          PathImgCurr='<img border=0 src="../../CTL_LIBRARY/images/domain/uguale.png">';
          objCellCurr.innerHTML = '<a title="' + TitleModifica + '" href="#" onclick="javascript:ALLEGATI_OFFERTA('+ lIdMsgCurr + ');">' +  PathImgCurr + '</a>';
          objhiddenCurr.value= 'uguale#~uguale';
        }
        
        if ( StatoFirmeUpgrade == 'diverso'){
          TitleModifica = CNV('../../' , 'firmatario diverso' );
          PathImgCurr='<img border=0 src="../../CTL_LIBRARY/images/domain/diverso.png">';
          objCellCurr.innerHTML = '<a title="' + TitleModifica + '" href="#" onclick="javascript:ALLEGATI_OFFERTA('+ lIdMsgCurr + ');">' +  PathImgCurr + '</a>';
          objhiddenCurr.value= 'diverso#~diverso';     
        }
        
        if ( StatoFirmeUpgrade == 'nessuno'){
          TitleModifica = CNV('../../' , 'nessun firmatario' );
          PathImgCurr='<img border=0 src="../../CTL_LIBRARY/images/domain/nessuno.png">';
          objCellCurr.innerHTML = '<a title="' + TitleModifica + '" href="#" onclick="javascript:ALLEGATI_OFFERTA('+ lIdMsgCurr + ');">' +  PathImgCurr + '</a>';
          objhiddenCurr.value= 'nessuno#~nessuno';
        }
        
        break;
        
  	 }
      
  }
  
}



//apre il documento che visualizza gli allegati di una offerta
function ALLEGATI_OFFERTA( lIdMsgParam ){
  
  	if (lIdMsgParam != '-1'){
	   					
			nValid=1;
			
			try{
			
				strIdMsgValid=document.new_document.strIdMsgValid.value;
				nValid=strIdMsgValid.search(',' + lIdMsgParam + ',');
			
			}catch(e){
			}
						
			if (nValid<0){
				alert('<% =CNVMPJS(lIdmp,"operazione non possibile messaggio invalidato") %>');
				
			}else{
				
				var IdMsgPDA = getObj('lIdMsgPar').value
				
				strUrl='../../ctl_library/functions/Open_Allegati_Offerta.asp?';
				
				strUrl=strUrl+'IDDOC='+lIdMsgParam;
				strUrl=strUrl+'&TYPEDOC=DOCUMENTOGENERICO';
				strUrl=strUrl+'&IDDOC_PDA='+IdMsgPDA;
				
				const_width=690;
				const_height=500;
				sinistra=(screen.width-const_width)/2;
				alto=(screen.height-const_height)/2;
				window.open(strUrl,'ALLEGATI_OFFERTA','toolbar=no,location=no,directories=no,status=<%=CONST_STATUS%>,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
			}

   }
}

//esegue azioni dopo evento open sul documento
function Action_AFTER_OPEN( param ){
  
  if ( param != 'Cover1' )
    GetStatoFirmeAvvalimenti();
  
}

</script>

