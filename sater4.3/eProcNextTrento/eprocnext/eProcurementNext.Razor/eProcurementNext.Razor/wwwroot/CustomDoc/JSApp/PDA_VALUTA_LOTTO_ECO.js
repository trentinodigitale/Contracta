window.onload = OnloadPage;

function ChiudiValutazione()
{
    var bTrovatoZero = false;
	var valoreNonValido = false;
	var bPunteggioNonValido = false;

    for( Row = PDA_VALUTA_LOTTO_ECOGrid_StartRow; Row <= PDA_VALUTA_LOTTO_ECOGrid_EndRow ; Row++ )
    {
         if( getObjValue( 'R' + Row + '_FormulaEcoSDA' ) == 'Valutazione soggettiva' && Number(getObjValue( 'R' + Row + '_Value' )) == 0 )
         {
             bTrovatoZero = true;
         }

		 if( getObjValue( 'R' + Row + '_FormulaEcoSDA' ) == 'Valutazione soggettiva' && ( Number(getObjValue( 'R' + Row + '_Coefficiente' )) < 0 || Number(getObjValue( 'R' + Row + '_Coefficiente' )) > 1 ) )
         {
			 try{
				if( getObj( 'R' +  Row + '_Coefficiente_V' ).type == 'text' )
					valoreNonValido = true;
			 }catch(e){}
         }

		 if( getObjValue( 'R' + Row + '_FormulaEcoSDA' ) == 'Valutazione soggettiva' && (   Number(getObjValue(  'R' + Row + '_Value' )) > Number(getObjValue( 'R' + Row + '_PunteggioMax' ))  ||  Number(getObjValue( 'R' + Row + '_Value' )) < 0  || getObjValue( 'R' + Row + '_Value' ) == '' ) )
		 {
			 try{
				if( getObj(  'R' + Row + '_Value_V' ).type == 'text' )
					bPunteggioNonValido = true
			 }catch(e){}

		 }
		 
    }

	
	if ( bPunteggioNonValido )
	{

		DMessageBox('../', 'Il valore del Punteggio inserito non è valido', 'Attenzione', 1, 400, 300);
		return;

	}
	
	
	if ( valoreNonValido )
	{

		DMessageBox('../', 'Il valore del coefficiente deve essere compreso tra 0 ed 1', 'Attenzione', 1, 400, 300);
		return;

	}
	//else
	{
	
		if( bTrovatoZero == true )
		{
			if( !confirm(  CNV( '../../' ,'Sei sicuro di chiudere la valutazione con punteggio zero?' )))
			{
				return;
			}
		}

		ExecDocProcess( 'CHIUDI_VALUTAZIONE,PDA_VALUTA_LOTTO_ECO' );
    
    }
	
}

function OnChangeCoefficiente(obj )
{
	//var obj = this;
	
    var Row = obj.id.split('_')[0];
	var valCoefficiente = getObjValue(  Row + '_Coefficiente' );
	
	if (valCoefficiente < 0 || valCoefficiente > 1 )
	{
		SetNumericValue( Row + '_Value' , Number(0) );
		DMessageBox('../', 'Il valore del coefficiente deve essere compreso tra 0 ed 1', 'Attenzione', 1, 400, 300);
		return;
	}
	
	
	var totale = Number( getObjValue( Row + '_PunteggioMax' )) * Number (valCoefficiente);

	totale = totale.toFixed(2);

	//Setto il totale nella colonna 'value'
    SetNumericValue( Row + '_Value' , Number(totale) );

}

function OnloadPage()
{
    try
	{
        var i = 0;
		var DOCUMENT_READONLY = getObjValue('DOCUMENT_READONLY');
		
		var criterio = getObjValue('ModAttribPunteggio');
		var valutazione = getObjValue('ValutazioneEconomicaSoggettiva');
		
		//-- si nasconde il coefficiente se ho chiesto una valutazione per punteggio
		if ( criterio == 'punteggio' )
		{
			ShowCol( 'PDA_VALUTA_LOTTO_ECO' , 'Coefficiente' , 'none' );
		}
		
		if ( valutazione == 'no' )
		{
			ShowField('IdPfu',false);
			ShowField('Protocollo',false);
			ShowField('DataInvio',false);
			ShowField('StatoFunzionale',false);
		}
		
		
	}
	catch(e){}

}


function OnChangePunteggio( obj )
{
    var Row = obj.id.split('_')[0];
    if(  Number(getObjValue(  Row + '_Value' )) > Number(getObjValue( Row + '_PunteggioMax' )) )
    {
        SetNumericValue( Row + '_Value' , Number(getObjValue( Row + '_PunteggioMax' )) );
    }

    if(  Number(getObjValue(  Row + '_Value' )) < 0 )
    {
        SetNumericValue( Row + '_Value' , 0 );
    }

	//-- calcolo il coefficiente
	
	var coef = Number(getObjValue(  Row + '_Value' )) / Number(getObjValue( Row + '_PunteggioMax' ));

	//getObj( 'val_' + Row + '_Coefficiente' ).innerHTML = FormatNumber(coef, ',','',10);	
	SetNumericValue( Row + '_Coefficiente' , Number(coef) );
	

	
	
}
