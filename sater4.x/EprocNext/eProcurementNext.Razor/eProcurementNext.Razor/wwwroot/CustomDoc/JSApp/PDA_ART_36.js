window.onload = OnloadPage;

// function ChiudiValutazione()
// {
    // var bTrovatoZero = false;
	// var valoreNonValido = false;
	// var bPunteggioNonValido = false;

    // for( Row = PDA_VALUTA_LOTTO_ECOGrid_StartRow; Row <= PDA_VALUTA_LOTTO_ECOGrid_EndRow ; Row++ )
    // {
         // if( getObjValue( 'R' + Row + '_FormulaEcoSDA' ) == 'Valutazione soggettiva' && Number(getObjValue( 'R' + Row + '_Value' )) == 0 )
         // {
             // bTrovatoZero = true;
         // }

		 // if( getObjValue( 'R' + Row + '_FormulaEcoSDA' ) == 'Valutazione soggettiva' && ( Number(getObjValue( 'R' + Row + '_Coefficiente' )) < 0 || Number(getObjValue( 'R' + Row + '_Coefficiente' )) > 1 ) )
         // {
			 // try{
				// if( getObj( 'R' +  Row + '_Coefficiente_V' ).type == 'text' )
					// valoreNonValido = true;
			 // }catch(e){}
         // }

		 // if( getObjValue( 'R' + Row + '_FormulaEcoSDA' ) == 'Valutazione soggettiva' && (   Number(getObjValue(  'R' + Row + '_Value' )) > Number(getObjValue( 'R' + Row + '_PunteggioMax' ))  ||  Number(getObjValue( 'R' + Row + '_Value' )) < 0  || getObjValue( 'R' + Row + '_Value' ) == '' ) )
		 // {
			 // try{
				// if( getObj(  'R' + Row + '_Value_V' ).type == 'text' )
					// bPunteggioNonValido = true
			 // }catch(e){}

		 // }
		 
    // }

	
	// if ( bPunteggioNonValido )
	// {

		// DMessageBox('../', 'Il valore del Punteggio inserito non è valido', 'Attenzione', 1, 400, 300);
		// return;

	// }
	
	
	// if ( valoreNonValido )
	// {

		// DMessageBox('../', 'Il valore del coefficiente deve essere compreso tra 0 ed 1', 'Attenzione', 1, 400, 300);
		// return;

	// }
	// //else
	// {
	
		// if( bTrovatoZero == true )
		// {
			// if( !confirm(  CNV( '../../' ,'Sei sicuro di chiudere la valutazione con punteggio zero?' )))
			// {
				// return;
			// }
		// }

		// ExecDocProcess( 'CHIUDI_VALUTAZIONE,PDA_VALUTA_LOTTO_ECO' );
    
    // }
	
// }

// function OnChangeCoefficiente(obj )
// {
	// //var obj = this;
	
    // var Row = obj.id.split('_')[0];
	// var valCoefficiente = getObjValue(  Row + '_Coefficiente' );
	
	// if (valCoefficiente < 0 || valCoefficiente > 1 )
	// {
		// SetNumericValue( Row + '_Value' , Number(0) );
		// DMessageBox('../', 'Il valore del coefficiente deve essere compreso tra 0 ed 1', 'Attenzione', 1, 400, 300);
		// return;
	// }
	
	
	// var totale = Number( getObjValue( Row + '_PunteggioMax' )) * Number (valCoefficiente);

	// totale = totale.toFixed(2);

	// //Setto il totale nella colonna 'value'
    // SetNumericValue( Row + '_Value' , Number(totale) );

// }

function OnloadPage()
{
    try
	{
        var i = 0;
		var DOCUMENT_READONLY = getObjValue('DOCUMENT_READONLY');
		
		// var criterio = getObjValue('ModAttribPunteggio');
		// var valutazione = getObjValue('ValutazioneEconomicaSoggettiva');
		
		// //-- si nasconde il coefficiente se ho chiesto una valutazione per punteggio
		// if ( criterio == 'punteggio' )
		// {
			// ShowCol( 'PDA_VALUTA_LOTTO_ECO' , 'Coefficiente' , 'none' );
		// }
		
		// if ( valutazione == 'no' )
		// {
			// ShowField('IdPfu',false);
			// ShowField('Protocollo',false);
			// ShowField('DataInvio',false);
			// ShowField('StatoFunzionale',false);
		// }
		
		// //sezione codice Ampiezza di gamma 
		// try
		// {
			// var PresenzaModuloAmpiezzaGamma = getObj('PresenzaModuloAmpiezzaGamma').value
			// //visualizza nella tabella prodotti la colonna ampiezza di gamma se il campo nascosto in testata "PresenzaAmpiezzaDiGamma" = si
			// if (PresenzaModuloAmpiezzaGamma == 'si')
			// {
				// nascondiColonnaAmpiezzadiGamma()
			// }
			// else
			// {
				// ShowCol( 'PDA_OFFERTA_BUSTA_ECO' , 'FNZ_OPEN' , 'none' );
			// }

		// }catch{
			// ShowCol( 'PDA_OFFERTA_BUSTA_ECO' , 'FNZ_OPEN' , 'none' );
		// }
		
	}
	catch(e){}

}


// function OnChangePunteggio( obj )
// {
    // var Row = obj.id.split('_')[0];
    // if(  Number(getObjValue(  Row + '_Value' )) > Number(getObjValue( Row + '_PunteggioMax' )) )
    // {
        // SetNumericValue( Row + '_Value' , Number(getObjValue( Row + '_PunteggioMax' )) );
    // }

    // if(  Number(getObjValue(  Row + '_Value' )) < 0 )
    // {
        // SetNumericValue( Row + '_Value' , 0 );
    // }

	// //-- calcolo il coefficiente
	
	// var coef = Number(getObjValue(  Row + '_Value' )) / Number(getObjValue( Row + '_PunteggioMax' ));

	// //getObj( 'val_' + Row + '_Coefficiente' ).innerHTML = FormatNumber(coef, ',','',10);	
	// SetNumericValue( Row + '_Coefficiente' , Number(coef) );
	

	
	
// }

// // function OpenAmpiezzaDiGamma(objGrid, Row, c)
// // {	
// // 	var voce = getObj('R'+ Row +'_Voce').value;
// // 	var lotto = getObj('R'+ Row +'_NumeroLotto').value;
// // 	var lotto_voce = lotto + '-' + voce
// // 	var ampiezzaGamma = getObj('R'+ Row +'_AmpiezzaGamma').value;
// // 	var IDDOC = getObj('IDDOC').value;

// // 	if (voce == '0' || ampiezzaGamma == '0')
// // 	{
// // 		LocDMessageBox('../', 'Ampiezza di gamma non prevista per la riga', 'Attenzione', 1, 400, 300);
// // 	}
// // 	else
// // 	{
// // 		param ='OFFERTA_AMPIEZZA_DI_GAMMA_ECO##VOCE#'+ IDDOC +'###' + lotto_voce + '#' ;
		
// // 		MakeDocFrom ( param ) ; 
// // 	}

	
// // }

// function nascondiDettaglioAmpiezzaGamma()
// {
	// var numrow = GetProperty( getObj('PDA_OFFERTA_BUSTA_ECOGrid') , 'numrow');

	// for( i = 0 ; i <= numrow ; i++ )
	// {
				
		// var voce = getObj('R'+ i +'_Voce').value;
		// var ampiezzaGamma = getObj('RPDA_OFFERTA_BUSTA_ECOGrid'+ i +'_AmpiezzaGamma').value;

		// if (voce == '0' || ampiezzaGamma == '0')
		// {
			// var bottone = getObj('R'+ i +'_FNZ_OPEN');
			// bottone.remove();
		// }

	// }
// }

// function nascondiColonnaAmpiezzadiGamma()
// {
	// var numrow = GetProperty( getObj('PDA_OFFERTA_BUSTA_ECOGrid') , 'numrow');

	// for( i = 0 ; i <= numrow ; i++ )
	// {
		// var presenzaampiezzaGamma = 0		
		// var ampiezzaGamma = getObj('RPDA_OFFERTA_BUSTA_ECOGrid_'+ i +'_AmpiezzaGamma').value;

		// if (ampiezzaGamma == '1')
		// {
			// presenzaampiezzaGamma = 1
		// }
	// }screenTop

	// if (presenzaampiezzaGamma == 1)
	// {
		// ShowCol( 'PDA_VALUTA_LOTTO_ECO' , 'FNZ_OPEN' , '' );
		// nascondiLenteAmpiezzaGamma()
	// }else
	// {
		// ShowCol( 'PDA_VALUTA_LOTTO_ECO' , 'FNZ_OPEN' , 'none' );
	// }
// }
	
// function nascondiLenteAmpiezzaGamma()
// {
	// var ismodelloEconomico = getObj('AmpGammaPresenzaModello').value

	// var numrow = GetProperty( getObj('PDA_OFFERTA_BUSTA_ECOGrid') , 'numrow');

	// for( i = 0 ; i <= numrow ; i++ )
	// {
				
		// var voce = getObj('RPDA_OFFERTA_BUSTA_ECOGrid_'+ i +'_Voce').value;
		// var ampiezzaGamma = getObj('RPDA_OFFERTA_BUSTA_ECOGrid_'+ i +'_AmpiezzaGamma').value;

		// if (voce == '0' || ampiezzaGamma == '0' || ismodelloEconomico != 'si')
		// {
			// var bottone = getObj('RPDA_OFFERTA_BUSTA_ECOGrid_'+ i +'_FNZ_OPEN');
			// bottone.remove();
		// }

	// }
// }

// function OpenAmpiezzaDiGamma(objGrid, Row, c)
// {	
	// var voce;
	// var lotto;
	// try{ 	 
		// voce = getObj('RPDA_OFFERTA_BUSTA_ECOGrid_'+ Row +'_Voce').value; 	
		// lotto = getObj('RPDA_OFFERTA_BUSTA_ECOGrid_'+ Row +'_NumeroLotto').value;
	// }
	// catch( e ) 
	// { //-- le gare senza lotti non hanno lotto voce
		// voce = getObj('RPDA_OFFERTA_BUSTA_ECOGrid_'+ Row +'_NumeroRiga').value; 	
		// lotto  ='1';
	// }

	// var lotto_voce = lotto + '-' + voce
	// var ampiezzaGamma = getObj('RPDA_OFFERTA_BUSTA_ECOGrid_'+ Row +'_AmpiezzaGamma').value;
	// var IDDOC = getObj('IDDOC').value;

	// if (voce == '0' || ampiezzaGamma == '0')
	// {
		// LocDMessageBox('../', 'Ampiezza di gamma non prevista per la riga', 'Attenzione', 1, 400, 300);
	// }
	// else
	// {
		// param ='OFFERTA_AMPIEZZA_DI_GAMMA_ECO##VOCE#'+ IDDOC +'###' + lotto_voce + '#' ;
		
		// MakeDocFrom ( param ) ; 
	// }

	
// }


function TransferAllegatoToRigh( objGrid , Row , c )
{
	//La funzione seguente è ideata per funzionare se posizionalmente è stata messa in mezzo tra le due colonne che devono subire il trasferimento
	//Va a recuperare il valore dell'allegato della cella a lei precedente e lo binda nella cella a lei successiva, 
	//mantenedo se presente nella cella di arrivo il comando Carica allegato
	
	//Nomi dei campi in oggetto (spunto futura ottimizzazione, da prendere dinamicamente)
	var campoToTransfer = "Allegato"
	var campoToRecieve = "AllegatoRisposta"
	
	// Costruisco l'id dell'elemento basato su row e cell
    var ID_elementToTransfer = "DOCUMENTIGrid_r" + Row + "_c" + (c-1);
	var ID_elementToRecive = "DOCUMENTIGrid_r" + Row + "_c" + (c+1);

    // Trova gli elementi
    var elementToTransfer = document.getElementById(ID_elementToTransfer);
    var elementToRecive = document.getElementById(ID_elementToRecive);
	
	//Partendo dall'allegato di partenza cambio i riferimenti rendendolo attinente al secondo

	//Elimina l'eventuale comando per allegare file
    // var elementToRemove = elementToTransfer.querySelector('#TD_ATTACH_BTN');

    // // Verifica se l'elemento esiste
    // if (elementToRemove) 
	// {
		// // Rimuovi l'elemento TD_ATTACH_BTN
		// elementToRemove.parentNode.removeChild(elementToRemove);
	// }
	
	// console.log(elementToRecive.innerHTML)
	
	//Inserisce il comando per allegare file presente nell'allegato di destinazione in quello di inzio per non compromettere le sue reference
    var elementToKeep = elementToRecive.querySelector("#TD_ATTACH_BTN");
	
	//TODO: rimettere questo dentro l'html nel punto giusto
	
	
	// Verifica che entrambi gli elementi siano presenti
    if (elementToTransfer && elementToRecive) {
        // Ottieni il contenuto dell'elemento di origine
        var contentToTransfer = elementToTransfer.innerHTML;

        // Effettua la sostituzione e imposta il nuovo contenuto nell'elemento di destinazione
        var newContent = contentToTransfer.replace(new RegExp('_' + campoToTransfer, "g"), '_' + campoToRecieve);
        elementToRecive.innerHTML = newContent;
    }
	
	ExecDocProcess( 'TRANSFER_FITTIZIO,PDA_ART_36' );
}