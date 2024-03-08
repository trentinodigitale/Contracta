function ricerca()
{
	var value ='';

	if ( getObj('StatoFunzionale').value != 'InLavorazione')
    {
		value='NO';
	}	
	
	if ( value == '' )
	{ 
		ExecDocProcess( 'RICERCA,RICERCA_ENTI' );
	}
	else
		return false; 

}

function RefreshContent()
{ 	
	RefreshDocument('');      
}


function VisualizzaAzienda( grid , r , c )
{
	//-- recupero il codice della riga passata
	
	var nIdAzienda;
	try{
		nIdAzienda = getObj( 'RESITIGrid_' + r + '_IdAzi' )[0].value
	}catch( e ) {
		nIdAzienda = getObj( 'RESITIGrid_' + r + '_IdAzi' ).value
	}

	
	//variabili che mi indicano in che posizione devo aprire le form dei documenti
	const_width=780;
	const_height=500;
	sinistra=(screen.width-const_width)/2;
	alto=(screen.height-const_height)/2;
	

	
	
	//Se versione accessibile
	if ( isSingleWin() )
	{
		var url;
		url = encodeURIComponent('ctl_library/document/document.asp?MODE=SHOW&lo=base&JScript=SCHEDA_ANAGRAFICA&DOCUMENT=SCHEDA_ANAGRAFICA&IDDOC=' + nIdAzienda );
		ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
	}
	else
	{
	
		//non apro più la vecchia anagrafica se è versione accessibile
		window.open('../../customdoc/VisualizzaAzienda.asp?IdPfu=&strFlag=OK&idAzi=' + nIdAzienda + '&IDMP=&intTab=0&strNomeCampo=-1&Read_Only=YES&Provenienza=1','Run_Dati_AziendaLinked','toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
	
	}
}
window.onload=controlli;

function controlli()
{
	//se il doc è readonly nasconde il ricerca
	if ( getObj('StatoFunzionale').value != 'InLavorazione')
    {
		document.getElementById('bottone_ricerca').style.visibility = 'hidden';
	}
	
	//dopo il conferma chiudo il documento
	var Command=getQSParam('COMMAND'); 
	var Process_Param=getQSParam('PROCESS_PARAM'); 

	if (Command == 'PROCESS' && Process_Param == 'SEND,RICERCA_ENTI')
	{
		if ( isSingleWin() == false)
			RemoveMessageFromMem();
		else
		{
			//Ricarico dal db la sezione dei destinatari del documento chiamante
			var linkedDoc = getObjValue('LinkedDoc');
			var tipoDocChiamante = getObjValue('VersioneLinkedDoc');
			
			if (linkedDoc != '' && tipoDocChiamante != '') 
			{			
				ShowWorkInProgress(true);
				ExecDocCommandInMem( 'DESTINATARI#RELOAD', linkedDoc, tipoDocChiamante);				
				ShowWorkInProgress(false);
				
				//Ritorno sull'ultimo livello delle molliche di pane
				breadCrumbPop();
				
			}
		}
	}
	
  

	
}

function CRITERI_AFTER_COMMAND( cmd )
{ 
    
}
function SP_Refresh_SP_CRITERI( )
{
	
}



function myaddRow ()
 {
	var cod;
	var nq;
	var strCommand;
	var testo;	
	//-- recupero il codice della riga passata
	cod = -1;
	
	

	
	//-- compone il comando per aggiungere la riga
	strCommand = 'CRITERI#ADDFROM#' + 'IDROW=' + cod + '&TABLEFROMADD=CRITERI_RICERCA_OE_FROM_TOOLBAR';
	
	//alert( strCommand );
	
	ExecDocCommand( strCommand );

	try{ 
		//var sec = parent.opener.getObj( 'SECTION_DETTAGLI_NAME' ).value;
		parent.opener.ShowLoading( 'CRITERI' ); 
	}catch( e ){};
	
	

}


function ChangedField( obj )
{
		//-- cancella il risultato precedente se c'era almeno una riga
		var NumRighe = getObjValue( 'NumRighe');
		
		if ( NumRighe > 0 )
		{
			//ExecDocCommand( 'ESITI#DELETE_ALL' );
			ExecDocProcess( 'DELETE_ALL,RICERCA_OE' );
			
		}
		

}

function afterProcess( param )
{
    if ( param == 'DELETE_ALL' )
    {
		DMessageBox( '../' , 'Gli esiti della ricerca sono stati svuotati in seguito ad un cambiamento dei "Criteri di ricerca". Rieseguire la "Ricerca"' , 'Attenzione' , 1 , 400 , 300 );
		return;
    }
}