window.onload = DOC_OnLoad;

function DOC_OnLoad()
{	
		  
		document.getElementById('CompilaDGUE').disabled = false; 
		document.getElementById('CompilaDGUE').className ="CompilaDGUE";
	  
	
}

function Compila_DOC_DGUE()
{
	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
    if (DOCUMENT_READONLY == "1")
	{
		MakeDocFrom('MODULO_TEMPLATE_REQUEST##'+ getObjValue('JumpCheck'));
	}
	else
	{
		ExecDocProcess( 'FITTIZIO,DOCUMENT,,NO_MSG');
	}
	
}
function afterProcess( param )
{
    if (  ( param == 'FITTIZIO' ) && ( getQSParam('PROCESS_PARAM') == 'FITTIZIO,DOCUMENT,,NO_MSG' )  )
    {
		ShowWorkInProgress();

		setTimeout(function()
		{ 
			
			ShowWorkInProgress();
			MakeDocFrom('MODULO_TEMPLATE_REQUEST##'+ getObjValue('JumpCheck'));

		}, 1 );
    }
	
	if( param == 'ANNULLA'  )
    {
		var id= getObjValue('idDoc');
		var tipodoc=getObjValue('VersioneLinkedDoc');
		
		ReloadDocFromDB(id, tipodoc );		
		
	}
	
}




function InvioRisposta (param)
{
	if ( getObjValue('Allegato') == "" )
	{
		DMessageBox( '../' , 'Per proseguire e\' necessaria la compilazione del Documento DGUE' , 'Attenzione' , 1 , 400 , 300 );
		return -1;
	}	
	
	ExecDocProcess(param);
}


