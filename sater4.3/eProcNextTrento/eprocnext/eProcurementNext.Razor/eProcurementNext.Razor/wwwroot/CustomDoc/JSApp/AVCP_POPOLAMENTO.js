window.onload=OnLoad;

var NextRow = 0;
var StatoElaborazione;


function OnLoad()
{

	StartProgressBar();
	
	var StatoFunzionale = getObjValue( 'StatoFunzionale' ) ;

	StatoElaborazione = JSON.parse( getObjValue( 'Body') );
	
	//-- fase iniziale che prepara al lavoro
	if( StatoFunzionale == 'InLavorazione' )
	{
		//-- nasconde la seconda sezione
		getObj('STEP2').style.display='none';
		getObj('STEP3').style.display='none';

		//setTimeout(function(){  NextStep();  }, 1 );
			
		
	}
	else
	//-- fase iniziale che prepara al lavoro
	if( StatoFunzionale == 'InCorso' )
	{

		//-- nasconde la prima sezione
		getObj('STEP1').style.display='none';
		getObj('STEP3').style.display='none';

		//setTimeout(function(){  NextStep();  }, 1 );
		
	}
	else
	if( StatoFunzionale == 'Completato' )
	{
		//-- nasconde la prima sezione Elaborazione terminata
		getObj('STEP1').style.display='none';
		getObj('STEP2').style.display='none';

		//StatoElaborazione = JSON.parse( getObjValue( 'Body') );
	}
	
	ShowAvanzamentoElaborazione();
	
	//se statofunzionale <> completato innesco ogni 5 secondi il refresh del documento
	
	if( StatoFunzionale != 'Completato' )
	{
			setTimeout(function(){  RefreshDocument('');  }, 5000 );
	}	
	
}

//-- deprecata l'elaborazione è stata spostata nel processo schedulato AVCP-POPOLAMENTO
function NextStep()
{
	//call RefreshDocument();
	return ;			
	var Result = SUB_AJAX( '../../AVCP/AVCP_LOAD.asp?IDDOC=' + getObjValue( 'IDDOC' ) + '&STEP=' + NextRow  );
	
	if ( Result != '' )
	{
	
		StatoElaborazione = JSON.parse( Result );
		getObj( 'Body' ).value = Result;
		
		NextRow = StatoElaborazione.NextRow;
		

		getObj('STEP1').style.display='none';
		getObj('STEP2').style.display='';

		ShowAvanzamentoElaborazione();
		
		getObj( 'val_StatoFunzionale' ).innerHTML = 'In Corso';
		
		if ( NextRow != 0 )
		{
			setTimeout(function(){  NextStep();  }, 1 );
		}
		else
		{
			
			getObj( 'val_StatoFunzionale' ).innerHTML = 'Completato';
			getObj('STEP2').style.display='none';
			getObj('STEP3').style.display='';

			
			//-- invoca l'aggiornamento del chiamante per aggiornare, avendo concluso le operazioni
			try{ 
				parent.opener.RefreshContent();
			} catch( e ) {
				try{ parent.opener.document.location = parent.opener.document.location;} catch( e ) {}; 
			};				
			
		}
	}
	else
	{
		DMessageBox( '../' , 'Errore il server non ha restituito la prossima operazione da eseguire. Provare ad eseguire nuovamente, se il problema si ripresenta contattare il supporto.' , 'Errore' , 2 , 400 , 300 );

	}
	
}



function ShowAvanzamentoElaborazione()
{
	
	SetNumericValue( 'CampoNumerico' , StatoElaborazione.TotRow );
	SetNumericValue( 'Numero_Documenti_da_elaborare' , StatoElaborazione.RowElab );


	SetNumericValue( 'CampoNumerico_1' , StatoElaborazione.NumeroGare );
	SetNumericValue( 'CampoNumerico_2' , StatoElaborazione.NumeroLotti );
	SetNumericValue( 'CampoNumerico_3' , StatoElaborazione.NumeroLottiInseriti );
	SetNumericValue( 'CampoNumerico_4' , StatoElaborazione.NumeroLottiVariati );
	SetNumericValue( 'CampoNumerico_5' , StatoElaborazione.NumeroLottiNonAggiornati );
	
	var X = parseInt( 100 - (( StatoElaborazione.RowElab / StatoElaborazione.TotRow ) * 100 ) );

	progress( X );
	
	
}


function StartProgressBar()
{
	
	progress( 0 );

}

function progress( X ) 
{
	
	getObj( 'HELP_PERFEZ_UTENTE' ).style.width = '99%';
	
	//getObj( 'HELP_PERFEZ_UTENTE' ).innerHTML = '<div class="progress"><div class="progress-bar progress-bar-success active progress-bar-striped" role="progressbar" aria-valuenow="40" aria-valuemin="0" aria-valuemax="100" style="width:' + X + '%">' + X + '% Completata </div></div>';
	
	getObj( 'HELP_PERFEZ_UTENTE' ).innerHTML = HTML_Progress_Bar (X);
}