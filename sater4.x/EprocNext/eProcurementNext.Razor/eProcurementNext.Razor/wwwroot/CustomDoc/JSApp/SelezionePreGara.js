window.onload = OnLoadPage;

function SelezionePreGara( objGrid , Row , c )
{
	
	
	try 
	{	
		var IdDoc_PreGara = getObj('GridViewer_idRow_' + Row ).value;
		var IdDoc_Gara = getQSParam('doc_to_upd');
		
		
		//alert(IdDoc_PreGara);
		//alert(IdDoc_Gara);
		//innesco un processo sul pregara passando il parametro BUFFER che contiene id della gara
		//che verrà memorizzato nella ctl_import legato all'utente loggato
		Dash_ExecProcessID( 'SELEZIONA_PREGARA,BANDO_GARA&TABLE=CTL_DOC&key=id&field=titolo&SHOW_MSG_INFO=yes&BUFFER=' + IdDoc_Gara  , IdDoc_PreGara )
		
	} catch (e) {};
}


function RefreshContent()
{

	//alert('refreshcontent');
	//-- ricarico il documento
	ReloadDocFromDB(getQSParam('doc_to_upd'), 'BANDO_GARA' );	

	
	if ( isSingleWin() == true )
	{
	
		breadCrumbPop();
	}
	else
	{
		parent.opener.RefreshContent();
	}
}