window.onload = DisplaySection;

function DisplaySection(obj) {

	FieldToSign('F2');		
	
	attachFilePending();
	ControlloFirmaBuste();
	label_controllo_firma_buste();

	//nasconde la lentine del documento ampiezza di gamma
	try
	{
		nascondiColonnaAmpiezzadiGamma()
		nascondiDettaglioAmpiezzaGamma()
	}
	catch
	{
		ShowCol( 'OFFERTA_BUSTA_TEC' , 'FNZ_OPEN' , 'none' );
	}
	
}	

function TogliFirma ()
{
	
	/*
	try
	{
		var linkedDoc = getObjValue('LinkedDoc');
		removeDocFromMem(linkedDoc,'OFFERTA');
	}
	catch(e){}
	
	DMessageBox( '../' , 'Si stanno per eliminare tutti i file firmati.' , 'Attenzione' , 1 , 400 , 300 );
	ExecDocProcess( 'SIGN_ERASE_LOTTI,SIGN_OFFERTA_BUSTA_TEC');
	*/
	ML_text = 'CONFIRM_MODIFICA_OFFERTA';
	Title = 'Informazione';					
	ICO = 1;
	page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);
		
	ExecFunctionModaleConfirm( page, Title , 200 , 420 , null , 'TogliFirma_OK' ,'');
}

function TogliFirma_OK() {
	
    
	
	try
	{
		var linkedDoc = getObjValue('LinkedDoc');
		removeDocFromMem(linkedDoc,'OFFERTA');
	}
	catch(e){}
	
	var ControlloFirmaBuste = getObj('ControlloFirmaBuste');
	var no_msg='NO';
	/* SE IL CAMPO ESISTE */
	if ( ControlloFirmaBuste )
	{
		//Se è richiesta la mancata verifica dei controlli di firma ( eccezione del hash di tra il file generato e quello allegato )
		if (ControlloFirmaBuste.value == 'no')
		{
			no_msg='YES';
		}
	}
	
	//NON MOSTRA IL MESSAGGIO IN QUANTO LO FA IL PROCESSO CHIAMATO DOPO
	if (no_msg == 'YES' )
	{
		ExecDocProcess('SIGN_ERASE_LOTTI,SIGN_OFFERTA_BUSTA_TEC,,NO_MSG');	
	}
	else
	{
		ExecDocProcess( 'SIGN_ERASE_LOTTI,SIGN_OFFERTA_BUSTA_TEC');
	}
	
	
}

function afterProcess( param )
{
	//alert(param);
	if ( param == 'SIGN_ERASE_LOTTI' )
    {
		OnChange_Allegato_TEC_ECO_SIGN_ERASE();
    }
}


function GeneraPDF_TEC()
{
    var NomePDF = 'Busta_TEC_' + getObjValue( 'NumeroLotto' );

	try
	{
		var linkedDoc = getObjValue('LinkedDoc');
		removeDocFromMem(linkedDoc,'OFFERTA');
	}
	catch(e){}

    LocalPrintPdf( '/report/OFFERTA_BUSTA_TEC.asp?&PAGEORIENTATION=landscape&TO_SIGN=YES&TABLE_SIGN=Document_Microlotto_Firme&PDF_NAME=' + NomePDF + '&IDENTITY_SIGN=idHeader&AREA_SIGN=F2' );
}

function LocalPrintPdf( param )
{
    
//    if( getObjValue('RTESTATA_PRODOTTI_MODEL_EsitoRiga') != '' )
//    {
//		DMessageBox( '../' , 'Per creare il PDF e\' necessario aver compilato la sezione prodotti senza errori di importazione' , 'Attenzione' , 1 , 400 , 300 );
//        return;
//    }

    PrintPdf( param );
}

function FIRMA_TECNICA_OnLoad()
{


    try
    {

	    if ( getObjValue('RichiestaFirma') == 'no')
	    {
		    document.getElementById('DIV_FIRMA_TEC').style.display = "none";
		    return;	
	    }
        FieldToSign( 'F2' );
    }catch( e ) {};
}


function FieldToSign( Field )
{

    var Stato ='';
	var EsitoRiga='';
	Stato = getObjValue('StatoDoc');
	EsitoRiga = getObjValue('EsitoRiga');
	var DATA_INVIO_SUPERATA = getObj('DATA_INVIO_SUPERATA').value;
	
	//if ((getObjValue(Field + '_SIGN_LOCK') =='0' || getObjValue(Field + '_SIGN_LOCK') =='')   && (Stato=='Saved' || Stato=="") && EsitoRiga == '<img src="../images/Domain/State_OK.gif">' )
	if ( ( getObjValue(Field + '_SIGN_LOCK') =='0' || getObjValue(Field + '_SIGN_LOCK') =='' )   && ( Stato=='Saved' || Stato=="" ) && EsitoRiga.indexOf('State_ERR.gif') < 0 &&  DATA_INVIO_SUPERATA != '1'  )
    {
		document.getElementById(Field + '_generapdf').disabled = false; 
		document.getElementById(Field + '_generapdf').className ="generapdf";
	}
	else
	{
		document.getElementById(Field + '_generapdf').disabled = true; 
		document.getElementById(Field + '_generapdf').className ="generapdfdisabled";
	}
	
	
	if ( getObjValue(Field + '_SIGN_LOCK') != '0'   && (Stato=='Saved') &&  DATA_INVIO_SUPERATA != '1'  )
    {
		document.getElementById(Field + '_editistanza').disabled = false; 
		document.getElementById(Field + '_editistanza').className ="attachpdf";
	}
	else
	{
		document.getElementById(Field + '_editistanza').disabled = true; 
		document.getElementById(Field + '_editistanza').className ="attachpdfdisabled";
	}
	 
	if ( getObjValue(Field + '_SIGN_ATTACH') ==''  &&  (Stato=='Saved') && getObjValue(Field + '_SIGN_LOCK') != '0' && DATA_INVIO_SUPERATA != '1'  )
    {
		document.getElementById(Field + '_attachpdf').disabled = false; 
		document.getElementById(Field + '_attachpdf').className ="editistanza";
	}
	else
	{
		document.getElementById(Field + '_attachpdf').disabled = true; 
		document.getElementById(Field + '_attachpdf').className ="editistanzadisabled";
	}
	
}

function attachFilePending()
{
	var AttivaFilePending = getObj('AttivaFilePending');
	
	/* SE IL CAMPO ESISTE */
	if ( AttivaFilePending )
	{

		//Se richiesta la verifica pending dei file ed il documento è editabile
		if (AttivaFilePending.value == 'si' )
		{
			
			/* ITERIAMO SU TUTTI I CAMPI DI TIPO INPUT CONTENENTE IN LIKE LA PAROLA UPLOADATTACH NEL LORO ATTRIBUTO ONCLICK, VERIFICA DI TIPO CASE INSENSITIVE ( a prescindere da dove si trovano, documentazione, prodotti, giri di firma ) */

			$( "input[onclick*='uploadattach' i]" ).each( function( index, element )
			{
				
				var attachOnClick = $( this ).attr('onclick');
				
				//Se non è già presente la format a J ( jump )
				if ( attachOnClick.indexOf('&FORMAT=J') == -1 ) 
				{
					attachOnClick = attachOnClick.replace(new RegExp( '&FORMAT=', 'g'), '&FORMAT=J');
					$( this ).attr('onclick', attachOnClick); // Sostituiamo l'onlick con il nuovo
				}

			});
			
			
			
		}
	}
	
}

function ControlloFirmaBuste()
{
	var ControlloFirmaBuste = getObj('ControlloFirmaBuste');
	
	/* SE IL CAMPO ESISTE */
	if ( ControlloFirmaBuste )
	{
    
		//Se è richiesta la mancata verifica dei controlli di firma ( eccezione del hash di tra il file generato e quello allegato )
		if (ControlloFirmaBuste.value == 'no' )
		{
			
			/* ITERIAMO SU TUTTI I CAMPI MA SOLO PER IL CAMPO DOVE VIENE INSERITO LA BUSTA FIRMATA SETTIAMO LA FORMAT S per evitare il controllo se il file è firmato*/

			$( "input[onclick*='uploadattach' i]" ).each( function( index, element )
			{
				if( ($( this ).attr("id")) == 'F2_attachpdf' )
				{
					var attachOnClick = $( this ).attr('onclick');
					
					//Se non è già presente la format a J ( jump )
					if ( attachOnClick.indexOf('&FORMAT=S') == -1 ) 
					{
						attachOnClick = attachOnClick.replace(new RegExp( '&FORMAT=', 'g'), '&FORMAT=S');
						$( this ).attr('onclick', attachOnClick); // Sostituiamo l'onlick con il nuovo
					}
				}

			});
			
			
			
		}
	}
	
}


function label_controllo_firma_buste()
{
	var ControlloFirmaBuste = getObj('ControlloFirmaBuste');
	/* SE IL CAMPO ESISTE */
	if ( ControlloFirmaBuste )
	{
		//Se è richiesta la mancata verifica dei controlli di firma ( eccezione del hash di tra il file generato e quello allegato )
		if (ControlloFirmaBuste.value == 'no')
		{
			
			//SE ABBIAMO RICHIESTO DI EVITARE I CONTROLLI DI FIRMA BUSTA E NON E' FIRMATO ABGGIUNGO  la scritta "Il file allegato non è firmato" 
			if ($("#F2_SIGN_ATTACH_V tr:first-child").html().indexOf('sign_not_ok.png') > 0 ) //TEC
			{
				$("#FIRMA_TEC_il_file_allegato_non_firmato").removeAttr("style");
			}			
			
			
		}
		
	}
	
}

function OnChange_Allegato_TEC_ECO_SIGN_ERASE()
{
	var ControlloFirmaBuste = getObj('ControlloFirmaBuste');
	/* SE IL CAMPO ESISTE */
	if ( ControlloFirmaBuste )
	{
		//Se è richiesta la mancata verifica dei controlli di firma ( eccezione del hash di tra il file generato e quello allegato )
		if (ControlloFirmaBuste.value == 'no')
		{
			//chiamo un processo cappello che svuota esito_riga e poi chiama LOAD_PRODOTTI_SUB,ISTANZA_SDA_FARMACI
			ExecDocProcess('CONTROLLOFIRMABUSTE_LOTTI,OFFERTA');
		}
	}
	
}

function OnChange_Allegato_TEC_ECO()
{
	
	try
	{
		var linkedDoc = getObjValue('LinkedDoc');
		removeDocFromMem(linkedDoc,'OFFERTA');
	}
	catch(e){}
	ExecDocProcess('CONTROLLOFIRMABUSTE_LOTTI,OFFERTA,,NO_MSG');
	
}

function nascondiDettaglioAmpiezzaGamma()
{
	var numrow = GetProperty( getObj('OFFERTA_BUSTA_TECGrid') , 'numrow');

	for( i = 0 ; i <= numrow ; i++ )
	{
				
		var voce = getObj('R'+ i +'_Voce').value;
		var ampiezzaGamma = getObj('R'+ i +'_AmpiezzaGamma').value;

		if (voce == '0' || ampiezzaGamma == '0')
		{
			var bottone = getObj('R'+ i +'_FNZ_OPEN');
			bottone.remove();
		}

	}
}

function nascondiColonnaAmpiezzadiGamma()
{
	var numrow = GetProperty( getObj('OFFERTA_BUSTA_TECGrid') , 'numrow');

	for( i = 0 ; i <= numrow ; i++ )
	{
		var presenzaampiezzaGamma = 0		
		var ampiezzaGamma = getObj('R'+ i +'_AmpiezzaGamma').value;

		if (ampiezzaGamma == '1')
		{
			presenzaampiezzaGamma = 1
		}
	}screenTop

	if (presenzaampiezzaGamma == 1)
	{
		ShowCol( 'OFFERTA_BUSTA_TEC' , 'FNZ_OPEN' , '' );
	
	}else
	{
		ShowCol( 'OFFERTA_BUSTA_TEC' , 'FNZ_OPEN' , 'none' );
	}
}
	


function OpenAmpiezzaDiGamma(objGrid, Row, c)
{	
	var voce = getObj('R'+ Row +'_Voce').value;
	var lotto = getObj('R'+ Row +'_NumeroLotto').value;
	var lotto_voce = lotto + '-' + voce
	var ampiezzaGamma = getObj('R'+ Row +'_AmpiezzaGamma').value;
	var IDDOC = getObj('IDDOC').value;

	if (voce == '0' || ampiezzaGamma == '0')
	{
		LocDMessageBox('../', 'Ampiezza di gamma non prevista per la riga', 'Attenzione', 1, 400, 300);
	}
	else
	{
		param ='OFFERTA_AMPIEZZA_DI_GAMMA_TEC##VOCE#'+ IDDOC +'###' + lotto_voce + '#' ;
		
		MakeDocFrom ( param ) ; 
	}

	
}
