window.onload = setTimerReload;


function Controllo_Valori() 
{
	var pfuLogin = getObjValue( 'pfulogin' );
	var aziLog = getObjValue( 'aziLog' );
	var numeroRighe = getObj( 'NumRighe' ).value;

	
	if (pfuLogin ==  '' || aziLog == '' || numeroRighe == '' )
	{
		DMessageBox( '../ctl_library/' , 'Avvalorare tutti i campi di ricerca' , 'Attenzione' , 1 , 400 , 300 ); 
		return false;		
	}

	if ( numeroRighe > 30 )
	{
		DMessageBox( '../ctl_library/' , 'Il numero righe massimo ammesso e\' 30' , 'Attenzione' , 1 , 400 , 300 ); 
		return false;
	}
	
	return true;
}

function setTimerReload()
{
	// Ogni 3 secondi rifaccio in automatico la ricerca
	setTimeout(function(){ aggiornaLog(); }, 3000);
}

function aggiornaLog()
{
	var pfuLogin = getObjValue( 'pfulogin' );
	var aziLog = getObjValue( 'aziLog' );
	var numeroRighe = getObj( 'NumRighe' ).value;


	if (pfuLogin !=  '' && aziLog != '' && numeroRighe != '' )
	{
		var formRicerca = getObj('FormViewerFiltro');
		var actionOriginale = formRicerca.getAttribute('action');
		var newAction = actionOriginale.replace('viewer.asp','viewergriglia.asp');
		var tmpPath = '';

		if ( isSingleWin() )
		{
			tmpPath = pathRoot;
		}
		else
		{
			tmpPath = '../';
		}

		formRicerca.setAttribute('action', newAction);

		//alert(tmpPath + 'DASHBOARD/' + newAction + '&ajax=1');

		//function SEND_FORM_AJAX(  STR_URL, FORM_NAME, OBJ_OUTPUT, bAsincronous ) 
		getObj('finestra_modale').style.display = 'none';
		
		SEND_FORM_AJAX(  tmpPath + 'DASHBOARD/' + newAction + '&ajax=1', 'FormViewerFiltro', 'finestra_modale', false);
		
		//Forzo il refresh del dom
		getObj('finestra_modale').style.display = 'none';
		getObj('finestra_modale').style.display = 'block';
		
		//alert($('#finestra_modale').find('#FormViewerGriglia #div_GridViewer #GridViewer').html());

		$('#Div_ViewerGriglia').find('#FormViewerGriglia #div_GridViewer #GridViewer').html($('#finestra_modale').find('#FormViewerGriglia #div_GridViewer #GridViewer').html());
		
		getObj('finestra_modale').innerHTML = '';
		
		//Forzo il refresh del dom
		getObj('Div_ViewerGriglia').style.display = 'none';
		getObj('Div_ViewerGriglia').style.display = 'block';

		//formRicerca.submit();

		formRicerca.setAttribute('action', actionOriginale);
		
		setTimerReload();
		
	}
}