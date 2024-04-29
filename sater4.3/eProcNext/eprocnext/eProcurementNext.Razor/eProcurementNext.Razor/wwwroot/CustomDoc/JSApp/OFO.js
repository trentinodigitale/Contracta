//window.onload = DownloadListaAllegati;

function DownloadListaAllegati() 
{

    /*
        
    
	var MODE=getQSParam('MODE');
	var COMMAND=getQSParam('COMMAND');
	
	if (MODE=='SHOW' && ( COMMAND=='' || COMMAND == undefined) )
		ExecDocProcess ('DOWNLOADLISTAALLEGATI,OFO,,NO_MSG');
		
	*/
}

function afterProcess(param) 
{

	//if ( param == 'DOWNLOADLISTAALLEGATI' )
	//{
		//alert ('ciao');
	//}	
	
	
}

function ScaricaAllegatoOFO(grid, row, col)
{

	//if ( param == 'DOWNLOADLISTAALLEGATI' )
	//{
		//alert ('ciao');
	//}	
	//alert(getObj(	'R' + row + '_idRow').value);
	window.location='../../ts_aec/GetAttach.asp?IDROW=' + getObj(	'R' + row + '_idRow').value;
	
	
}





function OpenDocumentOFO( objGrid , Row , c )
{
	var cod;
	var nq;

	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
  
	var strDoc;
	strDoc = getObj('DOCUMENT').value;
	
	// chiama la pagina per scaricare gli allegati
	//window.location='../ts_aec/GetAttach.asp?IDDOC=' + cod;
	
	var nocache = new Date().getTime();
	var url;
		
	url = '../ts_aec/GetAttach.asp?IDDOC=' + cod;
	
	ajax = GetXMLHttpRequest();		
	
	ajax.open("GET",url + '&nocache=' + nocache , false);
	ajax.send(null);
	//alert(ajax.readyState);
	
	if(ajax.readyState == 4) 
	{
	  //alert(ajax.status); 
		if(ajax.status == 404 || ajax.status == 500)
		{
		  alert('Errore invocazione pagina di scarico allegati');				  
		}
	  //alert(ajax.responseText); 
	  /*
		if ( ajax.responseText == 'OK' ) 
		{
			//ritorno al documento di codifica prodotti se tutto ok
			breadCrumbPop('');
		}
		
		if ( ajax.responseText == 'ERRORE_DOCUMENTO_DA_AGGIORNARE' ) 
		{
		 alert('Errore: Stato del documento da aggiornare diverso da in lavorazione');				  
		}
		*/
	 }
	
	
	ShowDocument( strDoc , cod );
}
