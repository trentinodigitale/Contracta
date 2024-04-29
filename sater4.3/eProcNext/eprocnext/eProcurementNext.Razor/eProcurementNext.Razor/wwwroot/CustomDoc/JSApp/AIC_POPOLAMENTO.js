window.onload=OnLoad;

var NextRow = -1;
var StatoElaborazione;
var IdDoc_Off;
var NumAIC = 0;
var TotRow = 0;

function OnLoad()
{

	StartProgressBar();
	
	var StatoFunzionale = getObjValue( 'StatoFunzionale' ) ;
	
	
	//-- fase iniziale che prepara al lavoro
	if( StatoFunzionale == 'InLavorazione' )
	{
		//-- nasconde la seconda sezione
		getObj('STEP2').style.display='none';
		getObj('STEP3').style.display='none';

		setTimeout(function(){  NextStep();  }, 1 );
			
		
	}
	else
	//-- fase iniziale che prepara al lavoro
	if( StatoFunzionale == 'InCorso' )
	{

		//-- nasconde la prima sezione
		getObj('STEP1').style.display='none';
		getObj('STEP3').style.display='none';

		setTimeout(function(){  NextStep();  }, 1 );
		
	}
	else
	if( StatoFunzionale == 'Completato' )
	{
		//-- nasconde la prima sezione Elaborazione terminata
		getObj('STEP1').style.display='none';
		getObj('STEP2').style.display='none';

		StatoElaborazione = JSON.parse( getObjValue( 'Body') );
	}

	ShowAvanzamentoElaborazione();
}


function NextStep()
{
				
	IdDoc_Off = getObjValue( 'LinkedDoc' ) ;
	
	//alert(IdDoc_Off);
	TYPEDOC = getObjValue( 'JumpCheck' ) ;
	

	
	var Result = SUB_AJAX( '../../CustomDoc/AIC_LOAD.asp?IDDOC=' + IdDoc_Off + '&TYPEDOC=' + TYPEDOC + '&ID_DOC_POPOLAMENTO=' + getObjValue( 'IDDOC' ) + '&STEP=' + NextRow + '&NumAIC=' + NumAIC + '&TotRow=' + TotRow );
	//getObj('STEP2').style.display='';
	//StatoElaborazione = JSON.parse( Result );
	
	
	
	//SetTextValue( 'CampoTesto_1' , Result);		
	//SetTextValue( 'CampoTesto_1' , Result + ' - ' + TotRow + ' - ' + NumAIC + ' - ' + NextRow );
	
	
	
	if ( Result != '' )
	{
	
		StatoElaborazione = JSON.parse( Result );
		getObj( 'Body' ).value = Result;
		
		NumAIC = StatoElaborazione.NumAIC;
		TotRow = StatoElaborazione.TotRow;
		NextRow = StatoElaborazione.Step;
		

		getObj('STEP1').style.display='none';
		getObj('STEP2').style.display='';

		ShowAvanzamentoElaborazione();
		
		getObj( 'val_StatoFunzionale' ).innerHTML = 'In Corso';
		
		//if ( NextRow != -1 )
		if ( parseInt(NextRow) < parseInt(TotRow) )
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
				
				//removeDocFromMem(IdDoc_Off, 'OFFERTA');	
				removeDocFromMem(IdDoc_Off, TYPEDOC);	
	
				
			} catch( e ) {
				//try{ parent.opener.document.location = parent.opener.document.location;} catch( e ) {}; 
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
	
	//SetNumericValue( 'CampoNumerico' , StatoElaborazione.NumAIC );
	SetTextValue( 'CampoNumerico' , parseInt(StatoElaborazione.NumAIC) );
	//SetNumericValue( 'Numero_Documenti_da_elaborare' , StatoElaborazione.RowElab );
	
	NumAIC = StatoElaborazione.NumAIC;
	TotRow = StatoElaborazione.TotRow;
	NextRow = StatoElaborazione.Step;
	
	
	//SetTextValue( 'CampoTesto_1' , StatoElaborazione.urlToInvoke);
	//SetTextValue( 'CampoTesto_1' , StatoElaborazione.invokeWS);

	//SetNumericValue( 'CampoNumerico_1' , StatoElaborazione.TotRow );
	SetTextValue( 'CampoTesto_2' , parseInt(TotRow) );
	//SetNumericValue( 'CampoNumerico_2' , StatoElaborazione.NumAIC );
	//SetNumericValue( 'CampoNumerico_3' , StatoElaborazione.NumAIC );
	SetTextValue( 'CampoTesto_3' , parseInt(NumAIC) );
	SetTextValue( 'CampoTesto_4' , parseInt(NumAIC) );
	
	//SetNumericValue( 'CampoNumerico_4' , StatoElaborazione.NumeroLottiVariati );
	//SetNumericValue( 'CampoNumerico_5' , StatoElaborazione.NumeroLottiNonAggiornati );
	
	//var Z =  100 - (  ( (NextRow + 1) / TotRow ) * 100 ) ;
	//var Z =  100 - (  ( ( parseInt(NextRow) + 1) / parseInt(TotRow) ) * 100 ) ;
	var Z =    ( ( parseInt(NextRow) + 1) / parseInt(TotRow) ) * 100  ;
	//var X = parseInt( 100 - (( (StatoElaborazione.Step + 1) / StatoElaborazione.TotRow ) * 100 ) );
	var X = parseInt( Z );

	progress( X );
	
	
}


function StartProgressBar()
{
	
	progress( 0 );

}

function progress( X ) 
{
	
	getObj( 'HELP_PERFEZ_UTENTE' ).style.width = '99%';
	getObj( 'HELP_PERFEZ_UTENTE' ).innerHTML = '<div class="progress"><div class="progress-bar progress-bar-success active progress-bar-striped" role="progressbar" aria-valuenow="40" aria-valuemin="0" aria-valuemax="100" style="width:' + X + '%">' + X + '% Completata </div></div>';
	 
}