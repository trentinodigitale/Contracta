function RefreshContent(){
  
  /*
  
  //commentato perchè sul GD non più usato
  //aggiorno il dominio che contiene gli utenti commissione
  var result = '';
  ajax = GetXMLHttpRequest(); 
  if(ajax){
  		
	    ajax.open("GET", '../ctl_library/GetDomValueGD.asp?DZTNOME=UtenteCommissione&FIELD=NomeFieldControllo&SEZIONEAREA=SezioneArea' , false);
		 
	    ajax.send(null);
	    
	    if(ajax.readyState == 4) {
	      
		    if(ajax.status == 200)
		    {
			    result =  ajax.responseText;
	        
		    }
	    }
  }
  
  
  var strFullNameArea ='Commissione_CommissioneGara';
  var result1 =   ReplaceExtended(result,'SezioneArea',strFullNameArea ) ;
  
  //aggiorno il dominio sulla griglia  Commissione_CommissioneGara
  var NumRow = parent.opener.getObj('NumProduct_' + strFullNameArea ).value ;
  var nPosUtente=parent.opener.GetColumnPositionInGrid('UtenteCommissione',strFullNameArea);
  
  if ( NumRow > 0 ){
    
    for ( nIndRrow=1; nIndRrow <= NumRow; nIndRrow++ ){	
      
      strNomeFieldItem = strFullNameArea + '_' + nIndRrow + '_' + nPosUtente ;
      OldSelectValue = parent.opener.getObj( strFullNameArea + '_' + nIndRrow + '_' + nPosUtente ).value ;   
      parent.opener.getObj('cell_' + strFullNameArea + '_' + nIndRrow + '_' + nPosUtente ).innerHTML = ReplaceExtended(result1,'NomeFieldControllo',strNomeFieldItem ) ;
      parent.opener.getObj( strFullNameArea + '_' + nIndRrow + '_' + nPosUtente ).value = OldSelectValue;
      
    }
    
  }
  
  
  var strFullNameArea ='Commissione_Commissione2Agg';
  var result1 =   ReplaceExtended(result,'SezioneArea',strFullNameArea ) ;
  
  //aggiorno il dominio sulla griglia  Commissione_Commissione2Agg
  NumRow = -1 ;
  NumRow = parent.opener.getObj('NumProduct_' + strFullNameArea ).value ;
  nPosUtente = -1 ;
  nPosUtente = parent.opener.GetColumnPositionInGrid('UtenteCommissione',strFullNameArea);
  
  if ( NumRow > 0 ){
    
    for ( nIndRrow=1; nIndRrow <= NumRow; nIndRrow++ ){	
      
      strNomeFieldItem = strFullNameArea + '_' + nIndRrow + '_' + nPosUtente ;
      OldSelectValue = parent.opener.getObj( strFullNameArea + '_' + nIndRrow + '_' + nPosUtente ).value ;
      parent.opener.getObj('cell_' + strFullNameArea + '_' + nIndRrow + '_' + nPosUtente ).innerHTML = ReplaceExtended(result1,'NomeFieldControllo',strNomeFieldItem ) ;
      parent.opener.getObj( strFullNameArea + '_' + nIndRrow + '_' + nPosUtente ).value = OldSelectValue;
      
    }
    
  }

  
  */
  
  
  //invoco il refresh del dominio per fare in modo che risulti aggiornato
  //se vado a selezionare l'utente sui nuovi documenti
  var result = '';
  ajax = GetXMLHttpRequest(); 
  if(ajax){
  		
	    ajax.open("GET", '../ctl_library/REFRESH.ASP?COSA=DOMAIN' , false);
		 
	    ajax.send(null);
	    
	    if(ajax.readyState == 4) {
	      
		    if(ajax.status == 200)
		    {
		      
			    result =  ajax.responseText;
	        //alert(result);
		    }
	    }
  }
  
}
 
/* 
function ReplaceExtended(strExpression,strFind,strReplace){

  while (strExpression.indexOf(strFind)>=0)
  	strExpression=strExpression.replace(strFind,strReplace);
		
  return strExpression;
}
*/
	


