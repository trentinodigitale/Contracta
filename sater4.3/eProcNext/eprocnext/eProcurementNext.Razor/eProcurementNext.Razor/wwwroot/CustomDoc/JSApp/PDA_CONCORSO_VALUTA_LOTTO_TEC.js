function OpenCriterio( objGrid , Row , c )
{
    if(  getObjValue( 'val_R' + Row + '_CriterioValutazione' ) == 'quiz'  )
    {
		try 
		{
            var TipoGiudizioTecnico = getObj('TipoGiudizioTecnico').value;

            if (document.getElementById('ModAttribPunteggio')) 
			{
                var criterio = getObjValue('ModAttribPunteggio');

                if (criterio != '' && criterio != 'giudizio') 
				{
                    TipoGiudizioTecnico = 'number';
                }
            }

        }
		catch (e) 
		{
		}

        Open_Quiz( '../' , 'R' + Row + '_Formula' , 'V' , getObjValue('R' + Row + '_DescrizioneCriterio') , TipoGiudizioTecnico, 'R' + Row + '_Descrizione' );
    }
}


function OpenCambiaOfferta( objGrid , Row , c )
{

	var Statofunzionale = getObjValue( 'StatoFunzionale' );
	
	//-- verifica che la riga sia con criterio oggettivo
	if(  getObjValue( 'val_R' + Row + '_CriterioValutazione' ) != 'soggettivo' )
	{
		if ( Statofunzionale == 'InLavorazione' )
		{
			getObj( 'id_rowLottoOff' ).value = getObjValue( 'R' + Row  + '_idRow' );
			ExecDocProcess( 'CREA_CAMBIA_OFFERTA,PDA_VALUTA_LOTTO_TEC,,NO_MSG' );
		}
		else
		{
			MakeDocFrom( 'CAMBIA_OFFERTA#900,800#CRITERIO#' + getObjValue( 'R' + Row  + '_idRow' ) );
		}
	}
}

function afterProcess( param )
{

	if ( param == 'CREA_CAMBIA_OFFERTA' )
	{
		MakeDocFrom( 'CAMBIA_OFFERTA#900,800#CRITERIO#' + getObj( 'id_rowLottoOff' ).value  );
	}
	
	//per la versione non a singola finestra 
	if ( isSingleWin() == false ){
		//in caso dichiusura chaimo il refresh del padre
		if ( param == 'CHIUDI_VALUTAZIONE' ){
			
			parent.opener.RefreshContent();
			
		}	
	}
		
	
}


function ChiudiValutazione()
{
    var bTrovatoZero = false;
	var valoreNonValido = false;
	var criterio = getObjValue('ModAttribPunteggio');
	
    for( Row = PDA_VALUTA_LOTTO_TECGrid_StartRow; Row <= PDA_VALUTA_LOTTO_TECGrid_EndRow ; Row++ )
    {
        if( getObjValue( 'val_R' + Row + '_CriterioValutazione' ) == 'soggettivo' && Number(getObjValue( 'R' + Row + '_Value' )) == 0 )
        {
            bTrovatoZero = true;
        }
		
			
		if ( criterio ==  'coefficiente' )
		{
			if( getObjValue( 'val_R' + Row + '_CriterioValutazione' ) == 'soggettivo' && ( Number(getObjValue( 'R' + Row + '_GiudizioTecnico' )) < 0 || Number(getObjValue( 'R' + Row + '_GiudizioTecnico' )) > 1 ) )
			{
				valoreNonValido = true;
			}
		}		 
		 
    }

	if ( valoreNonValido )
	{

		DMessageBox('../', 'Il valore della valutazione deve essere compreso tra 0 ed 1', 'Attenzione', 1, 400, 300);
		return;

	}
	else
	{
	
		if( bTrovatoZero == true )
		{
			if( !confirm(  CNV( '../../' ,'Sei sicuro di chiudere la valutazione con punteggio zero?' )))
			{
				return;
			}
		}

		ExecDocProcess( 'CHIUDI_VALUTAZIONE:300,PDA_VALUTA_LOTTO_TEC' );
    
    }
	
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

	getObj( 'val_' + Row + '_GiudizioTecnico' ).innerHTML = FormatNumber(coef, ',','',10);	
	
	//Travaso il valore imputato nel giudizioTecnico nella controparte utilizzata per il ricarico
	getObj(Row + '_GiudizioTecnicoHidden').value = coef;

	
	
}

function OnChangeGiudizio( obj )
{
  
   
    var Row = obj.id.split('_')[0];
	var totale = Number( getObjValue( Row + '_PunteggioMax' )) * Number (getObjValue(  Row + '_GiudizioTecnico' ) );

	totale = totale.toFixed(2);

	//Setto il totale nella colonna 'value'
    SetNumericValue( Row + '_Value' , Number(totale) );

	//Travaso il valore imputato nel giudizioTecnico nella controparte utilizzata per il ricarico
	getObj(Row + '_GiudizioTecnicoHidden').value = getObjValue(  Row + '_GiudizioTecnico');

}

window.onload = OnloadPage; 

function OnloadPage()
{
	var criterio;
    try
	{
        var i = 0;
		var DOCUMENT_READONLY = getObjValue('DOCUMENT_READONLY');
	
		for( i=0; i < PDA_VALUTA_LOTTO_TECGrid_EndRow+1 ; i++ )
		{
			if( getObjValue( 'val_R' + i + '_CriterioValutazione' ) == 'soggettivo' || getObjValue( 'val_R' + i + '_CriterioValutazione' ) == 'ereditato' )
			{
			
				getObj( 'PDA_VALUTA_LOTTO_TECGrid_r' + i + '_c6' ).innerHTML = '&nbsp;';
				getObj( 'PDA_VALUTA_LOTTO_TECGrid_r' + i + '_c6' ).className = "";

				try{getObj( 'PDA_VALUTA_LOTTO_TECGrid_r' + i + '_c15' ).innerHTML = '&nbsp;';}catch(e){}
				try{getObj( 'PDA_VALUTA_LOTTO_TECGrid_r' + i + '_c15' ).className = "";}catch(e){}

			}
			
			try
			{

				if (document.getElementById('ModAttribPunteggio')) 
				{
					criterio = getObjValue('ModAttribPunteggio');
				
					if (criterio != '' && ( criterio == 'coefficiente' || criterio == 'punteggio' )) 
					{
						var oldValueDom='';
						var oldValue=''; 


						try
						{
							oldValueDom = getObjValue('R' + i + '_GiudizioTecnico');						
						}
						catch(e)
						{
							oldValueDom = getObjValue('val_R' + i + '_GiudizioTecnico');
						}
						
						oldValue = getObjValue('R' + i + '_GiudizioTecnicoHidden');
						
						
						if ( oldValue == '' && oldValueDom != '' )
							oldValue = oldValueDom;

						//Se il documento è editabile
						if ( DOCUMENT_READONLY == '0' && criterio == 'coefficiente' && getObjValue( 'val_R' + i + '_CriterioValutazione' ) == 'soggettivo' )
						{
							var newHtmlNumber = '<input type="hidden" name="R' + i + '_GiudizioTecnico" id="R' + i + '_GiudizioTecnico" class="display_none" value="' + oldValue + '"/>';
							newHtmlNumber = newHtmlNumber + '<input type="hidden" id="R' + i + '_GiudizioTecnico_extraAttrib" value="nd#=#10#@#ds#=#,#@#format#=###0.00000#####"/>';
							newHtmlNumber = newHtmlNumber + '<input type="text" name="R' + i + '_GiudizioTecnico_V" id="R' + i + '_GiudizioTecnico_V" class="Fld_Number" onblur="ck_VN( this ,\',\',10 );" onfocus="of_VN( this ,\',\',10 );" onchange="try{oc_VN( this ,\',\', 10 );}catch(e){}; OnChangeGiudizio( this );" size="15" value="' + FormatNumber(oldValue, ',','',10) + '" style="text-align: right;"/>';
							getObj( 'PDA_VALUTA_LOTTO_TECGrid_r' + i + '_c8' ).innerHTML = newHtmlNumber;
						}
						else
						{
							getObj( 'val_R' + i + '_GiudizioTecnico' ).innerHTML = FormatNumber(oldValue, ',','',10);
						}
						
						//-- si nasconde il coefficiente se ho chiesto una valutazione per punteggio
						if ( criterio == 'punteggio' )
						{
							ShowCol( 'PDA_VALUTA_LOTTO_TEC' , 'GiudizioTecnico' , 'none' );
							ShowCol( 'PDA_VALUTA_LOTTO_TEC' , 'GiudizioRiparametrato' , 'none' );
						}
						
					}
					
				}

			}
			catch(e)
			{
			}

		}

	}
	catch(e){}

	//-- nascondo le colonne dei punteggi riparametrati in coerenza con il criterio scelto
	var PunteggioTEC_TipoRip = getObjValue( 'PunteggioTEC_TipoRip' );
	var PunteggioTEC_100 = getObjValue( 'PunteggioTEC_100' );
    
    if( PunteggioTEC_100 == '0'  || PunteggioTEC_TipoRip == '1' ) //-- se non riparametro oppure riparametro solo il lotto 
    {
        ShowCol( 'PDA_VALUTA_LOTTO_TEC' , 'GiudizioRiparametrato' , 'none' );
        ShowCol( 'PDA_VALUTA_LOTTO_TEC' , 'PunteggioRiparametrato' , 'none' );
    }
	else
    {
		if( PunteggioTEC_100 != '1' ) //-- SE HO CHIESTO LA RIPARAMETRAZIONE DOPO LA SOGLIA DI SBARRAMENTO HO BISOGNO DEL PUNTEGGIO NON RIPARAMETRATO PER COMPRENDERE CHE VALORI HO OTTENUTO SENZA la riparametrazione
        {
			//-- ma se ho chiesto di valutare per punteggio npn posso nascondere la colonna
			if ( criterio != 'punteggio' )
			{
				ShowCol( 'PDA_VALUTA_LOTTO_TEC' , 'Value' , 'none' );
			}
        }
	}

}