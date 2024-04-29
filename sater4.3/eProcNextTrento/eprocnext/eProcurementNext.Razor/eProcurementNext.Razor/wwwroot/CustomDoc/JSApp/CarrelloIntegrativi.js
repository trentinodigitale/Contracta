
function AggiungiIntegrativo( param ){
  
  var idRow;
  var DOC_TO_UPD=getQSParam('DOC_TO_UPD');  
  
	ShowWorkInProgress(true);
	
	//-- recupera il codice delle righe selezionate
	idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	alert(idRow);
	
	if( idRow == '' )
	{
	  ShowWorkInProgress(false);
	  DMessageBox( '../' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );  
	}
	else
	{		
		var parametri =  'PRODOTTI#ADDFROM#IDROW=' + idRow + '&IDDOC='+ DOC_TO_UPD +'&NODUPLICATI=YES&TABLEFROMADD=View_Document_MicroLotti_Dettagli&DOCUMENT=ODC';
		//Viewer_Dettagli_AddSel( parametri);				
		ShowWorkInProgress(false);	
	}

}


function Integrativo_Sec_Dettagli_AddRow( objGrid , Row , c  )
{
	var cod;
	var nq;
	var strCommand;
	var testo;
  var result;
  
	
	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
	
	
	
  //recupero la qt imputata
  var QtImputata = getObjValue( 'R' + Row + '_QTDisp');
  //alert(QtImputata);
  if ( parseFloat(QtImputata) <= 0 ){
    DMessageBox( '../' , 'Quantita deve essere maggiore di 0' , 'Info' , 1 , 400 , 300 );
    return;
  }
  //recupero prezzo
  var PrezzoUnitario = getObjValue( 'R' + Row + '_PrezzoUnitario');
  //alert(PrezzoUnitario);
  if ( parseFloat(PrezzoUnitario) <= 0 ){
    DMessageBox( '../' , 'Prezzo deve essere maggiore di 0' , 'Info' , 1 , 400 , 300 );
    return;
  }
  
  //recupero valoreaccessorio
  var ValoreAccessorio = getObjValue( 'R' + Row + '_ValoreAccessorioTecnico');
  if ( parseFloat(ValoreAccessorio) < 0 ){
    DMessageBox( '../' , 'ValoreAccessorio deve essere maggiore o uguale a 0' , 'Info' , 1 , 400 , 300 );
    return;
  }
  
  //recupero not_editable
  var not_editable = getObjValue( 'R' + Row + '_Not_Editable');
  
    
  ajax = GetXMLHttpRequest(); 
  
  if(ajax){
		
    var strParam;		 
		strParam = 'OPERATION=ADDROW&ID=' + cod + '&QT=' + QtImputata + '&PrezzoUnitario=' + PrezzoUnitario + '&ValoreAccessorio=' + ValoreAccessorio + '&not_editable=' + not_editable;
		//alert(strParam);
		var nocache = new Date().getTime();
		//alert('../customDoc/OperationCarrello.asp?'+ strParam + '&nocache=' + nocache);
    ajax.open("GET", '../customDoc/OperationCarrelloIntegrativo.asp?'+ strParam + '&nocache=' + nocache , false);
	 
    ajax.send(null);
    
    if(ajax.readyState == 4) {
      //alert(ajax.status);
	    if(ajax.status == 200)
	    {
	      result =  ajax.responseText;
	      if (result == ''){
	        
	        //aggiorno il doc carrello in memoria
          ExecDocCommandInMem( 'PRODOTTI#RELOAD', IdDocIntegrativo, 'ODC');
          
          //visualizzo messaggio operazione ok
          DMessageBox( '../' , 'Articolo aggiunto allordinativo' , 'Info' , 1 , 400 , 300 );
	        
	        
	      }
		    else{
		      
		      //aggiorno il doc carrello in memoria
		      ExecDocCommandInMem( 'PRODOTTI#RELOAD', IdDocIntegrativo, 'ODC');
          
          //visualizzo messaggio operazione non consentita
          DMessageBox( '../' , result , 'Attenzione' , 2 , 400 , 300 );  
          
          
		    }
	    }
    }
  }

}
