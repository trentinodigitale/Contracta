var attributi_grid_IMPORTI = ['OrderLine_LineExtensionAmount', 'OrderLine_TotalTaxAmount', 'OrderLine_AllowanceCharge_Amount', 'OrderLine_AllowanceChargeReason'];
var attributi_grid_DATI = ['StandardItemIdentification_ID', 'OrderLine_Note', 'OrderLine_AccountingCost','RequestedDeliveryPeriod_StartDate','RequestedDeliveryPeriod_EndDate'];
var attributi_grid_RIFERIMENTO = ['DocumentReference_DocumentType', 'DocumentReference_ID', 'DocumentReference_IssueDate'];
var attributi_grid_IVA = ['OrderLine_ClassifiedTaxCategory_ID', 'OrderLine_ClassifiedTaxCategory_Percent'];
var attributi_grid_REPERTORIO = ['OrderLine_CommodityClassification_listID', 'OrderLine_CommodityClassification'];
var attributi_grid_EXTRA = ['OrderLine_AdditionalItemProperty_Name', 'OrderLine_AdditionalItemProperty_Value'];
var attributi_grid_SCONTO = ['OrderLine_Price_AllowanceChargeReason', 'OrderLine_Price_AllowanceCharge_Amount'];

window.onload = ordine_onload;

function ordine_onload()
{

	try
	{
		var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;

		//hideViewALL('none');

		if ( DOCUMENT_READONLY == '0' )
		{
			
			try
			{
				var peppolId = getObj('RACCOUNTINGCUSTOMERPARTY_MODEL_AccountingCustomerParty_EndpointID').value
				var codiceUFEIPA = getObj('RACCOUNTINGCUSTOMERPARTY_MODEL_CodiceUFEIPA').value
				if (peppolId != "")
				{
					//Ricarico il destinatario
					caricaDestinatario(peppolId);
				}
				if (codiceUFEIPA != ""){
					caricaDestinatario(codiceUFEIPA);
				}			
			}
			catch(e)
			{
			}
		
			var numeroRighe = GetProperty(getObj('INVOICELINEGrid'), 'numrow');
			var i;
			
			for (i = 0; i <= numeroRighe; i++) 
			{
				onChangeTipoIVA(getObj('RINVOICELINEGrid_' + i + '_OrderLine_ClassifiedTaxCategory_ID'), true);
			}
			
			//Evidenzio l'esito se in errore
			if ( getObj('Note_V').innerHTML != '' && getObj('Note_V').innerHTML != '&nbsp;' )
			{
				var oldClass = getObj('Note_V').getAttribute('class');
				getObj('Note_V').setAttribute('class',oldClass + ' Text_Esito_Errore');
			}
			
			INVOICELINE_AFTER_COMMAND();
			DisabilitaCampoUFE_Partecipant()
			
		}

		GestioneBollo()
	}
	catch(e){}

}

function DisabilitaCampoUFE_Partecipant(){
	var partecipantID = getObj('RACCOUNTINGCUSTOMERPARTY_MODEL_AccountingCustomerParty_EndpointID')
	var codiceUFEIPA = getObj('RACCOUNTINGCUSTOMERPARTY_MODEL_CodiceUFEIPA')
	
	if (partecipantID.value != ""){
		codiceUFEIPA.value = ""
		DisableObj('RACCOUNTINGCUSTOMERPARTY_MODEL_CodiceUFEIPA', true)		
		codiceUFEIPA.setAttribute('title','Inserire il campo UFE IPA se il destinatario è una PA italiana')		
		caricaDestinatario(partecipantID.value);
	}
	else
	{
		DisableObj('RACCOUNTINGCUSTOMERPARTY_MODEL_CodiceUFEIPA',false);
		codiceUFEIPA.setAttribute('title','')	
		partecipantID.value = ''
	}

	if (codiceUFEIPA.value != ""){
		partecipantID.value = ""
		DisableObj("RACCOUNTINGCUSTOMERPARTY_MODEL_AccountingCustomerParty_EndpointID", true)
		partecipantID.setAttribute('title','Inserire il Participant ID Peppol se il destinatario è una PA estera')			
		caricaDestinatario(codiceUFEIPA.value);	
	}
	else
	{
		DisableObj('RACCOUNTINGCUSTOMERPARTY_MODEL_AccountingCustomerParty_EndpointID',false);
		partecipantID.setAttribute('title','')
		codiceUFEIPA.value = ''
		
	}

}

function mySaveDoc()
{
	DisableObj('RACCOUNTINGCUSTOMERPARTY_MODEL_AccountingCustomerParty_EndpointID',false);
	DisableObj('RACCOUNTINGCUSTOMERPARTY_MODEL_CodiceUFEIPA',false);
	SaveDoc();

}

var semaforoOnChange = false
function OnChangeBaseImponibileRitenuta(obj)
{
	if (semaforoOnChange == false)
	{	
		semaforoOnChange = true;
		var riga = obj.id.split('_')[1];
		var imponibileRitenuta = getObj('RINVOICELINEGrid_' + riga + '_BaseImponibileRitenuta');

		getObj('RINVOICELINEGrid_' + riga + '_BaseImponibileRitenutaInput').value = imponibileRitenuta.value;

		CalcoloRitenutaContributiCpa( obj );
		
		semaforoOnChange = false;
	}
}

function CalcoloRitenutaContributiCpa(obj)
{
	var riga = obj.id.split('_')[1];
	
	//importo = base + percentuale
	//baserit = tot + cassa

	var importoTotale = getObj('RINVOICELINEGrid_' + riga + '_OrderLine_LineExtensionAmount')

	var tipoRitenuta = getObj('RINVOICELINEGrid_' + riga + '_TipoRitenuta')
	var importoRitenuta = getObj('RINVOICELINEGrid_' + riga + '_RitenutaImporto')
	var V_importoRitenuta = getObj('RINVOICELINEGrid_' + riga + '_RitenutaImporto_V')
	var imponibileRitenutaInput = getObj('RINVOICELINEGrid_' + riga + '_BaseImponibileRitenutaInput')
	var percentualeRutenuta = getObj('RINVOICELINEGrid_' + riga + '_RitenutaPercentuale')

	var tipoContributi = getObj('RINVOICELINEGrid_' + riga + '_TipoContributo')
	var importoContributi = getObj('RINVOICELINEGrid_' + riga + '_ImportoContributo')
	var V_importoContributi = getObj('RINVOICELINEGrid_' + riga + '_ImportoContributo_V')
	var imponibileContributi = getObj('RINVOICELINEGrid_' + riga + '_ImponibileContributo')
	var V_imponibileContributi = getObj('RINVOICELINEGrid_' + riga + '_ImponibileContributo_V')
	var percentualeContributi = getObj('RINVOICELINEGrid_' + riga + '_PercentualeContributo')

	var tipoCPA = getObj('RINVOICELINEGrid_' + riga + '_CPA')
	var importoCPA = getObj('RINVOICELINEGrid_' + riga + '_CPAImporto')
	var V_importoCPA = getObj('RINVOICELINEGrid_' + riga + '_CPAImporto_V')	
	var imponibileCPA = getObj('RINVOICELINEGrid_' + riga + '_CPAImponibile')
	var V_imponibileCPA = getObj('RINVOICELINEGrid_' + riga + '_CPAImponibile_V')	
	var percentualeCPA = getObj('RINVOICELINEGrid_' + riga + '_CPAPercentuale')

	var soggettaritenuta = getObj('RINVOICELINEGrid_' + riga + '_SoggettaRitenutaDacconto')

		//calcolo importo sulla cassa
		if (tipoCPA.value != '')
		{		
			SetNumericValue('RINVOICELINEGrid_' + riga + '_CPAImporto', (Number(imponibileCPA.value) * Number(percentualeCPA.value)) / 100)
		}
		else
		{
			imponibileCPA.value = 0.00
			importoCPA.value = 0.00
			
			SetNumericValue( 'RINVOICELINEGrid_' + riga + '_CPAImponibile' , 0 );
			SetNumericValue( 'RINVOICELINEGrid_' + riga + '_CPAImporto' , 0 );
		}
		if (soggettaritenuta.value == 'si')
		{
			if (tipoRitenuta.value != '' && tipoRitenuta.value != 'NA')
			{		
				SetNumericValue( 'RINVOICELINEGrid_' + riga + '_BaseImponibileRitenuta' , Number(imponibileRitenutaInput.value) + Number(importoCPA.value) );
				SetNumericValue( 'RINVOICELINEGrid_' + riga + '_RitenutaImporto' , ((Number(imponibileRitenutaInput.value) + Number(importoCPA.value)) * Number(percentualeRutenuta.value)) / 100	);
			}
			else
			{
				SetNumericValue( 'RINVOICELINEGrid_' + riga + '_RitenutaImporto' , 0);
				SetNumericValue( 'RINVOICELINEGrid_' + riga + '_RitenutaPercentuale' , 0);
				SetNumericValue( 'RINVOICELINEGrid_' + riga + '_BaseImponibileRitenuta' , 0);
				imponibileRitenutaInput.value = 0
			}
		}
		else
		{
			if (tipoRitenuta.value != '' && tipoRitenuta.value != 'NA')
			{	
				SetNumericValue( 'RINVOICELINEGrid_' + riga + '_RitenutaImporto' , (Number(imponibileRitenutaInput.value) * Number(percentualeRutenuta.value)) / 100	);
			}
			else
			{
				SetNumericValue( 'RINVOICELINEGrid_' + riga + '_RitenutaImporto' , 0);
				SetNumericValue( 'RINVOICELINEGrid_' + riga + '_RitenutaPercentuale' , 0);
				SetNumericValue( 'RINVOICELINEGrid_' + riga + '_BaseImponibileRitenuta' , 0);
			}
		}
		
		if (tipoContributi.value != '' && tipoContributi.value != 'NA')
		{		
			SetNumericValue( 'RINVOICELINEGrid_' + riga + '_ImportoContributo' , (Number(imponibileContributi.value) * Number(percentualeContributi.value)) / 100 );	
		}
		else
		{
			SetNumericValue( 'RINVOICELINEGrid_' + riga + '_ImportoContributo' , 0);	
			SetNumericValue( 'RINVOICELINEGrid_' + riga + '_ImponibileContributo' , 0);
			SetNumericValue( 'RINVOICELINEGrid_' + riga + '_PercentualeContributo' , 0);


		}

		GestioneBollo()	
}

function GestioneBollo(){
	var totale = 0;
	var NumRow = Number(GetProperty(getObj('INVOICELINEGrid'), 'numrow')) + 1;
	
	for ( i = 0 ; i < NumRow ; i++ )
	{
		var importoTotale = getObj('RINVOICELINEGrid_' + i + '_OrderLine_LineExtensionAmount')
		var codiceIVA = getObj('RINVOICELINEGrid_' + i + '_OrderLine_ClassifiedTaxCategory_ID')

		if (codiceIVA.value == 'O_1' || codiceIVA.value == 'O_2' || codiceIVA.value == 'E'){			
			totale = totale + Number(importoTotale.value)
		}
	}

	if (totale > 77.74){
		AbilitaVisibilitàBollo()
	}else{
		DisabilitaVisibilitàBollo()
	}
}

function checkIBAN()
{
	var iban = getObj('RPAYMENTMEANS_MODEL_PayeeFinancialAccount_ID');
	var ibanMod = iban.value.replace(" ", "").toUpperCase();

	if (ibanMod != "")
	{

		//verifico se nella stringa ci sono caratteri speciali
		var caratteriSpeciali = "!@#$%^&*()+=-[]\\\';,./{}|\":<>?";
		
		var IsCaratteriSpeciali = false;

		for (var i = 0; i < ibanMod.length; i++) 
		{
			if (caratteriSpeciali.indexOf(ibanMod.charAt(i)) != -1)
			{
				IsCaratteriSpeciali = true;
			}
		}

		if (IsCaratteriSpeciali == false)
		{
			var nazioneIBAN = ibanMod.substring(0, 2);
			if (typeof nazioneIBAN === 'string' && isNaN(nazioneIBAN))
			{
				if (nazioneIBAN == 'IT')
				{
					if (ibanMod.length = 27)
					{
						//verificaCIN(ibanMod);
						iban.value = ibanMod
					}
					else
					{
						DMessageBox('../', 'Il codice iban Italiano deve contenere 27 caratteri', 'Attenzione', 1, 400, 300);
						return -1;	 
					}
				}
				else
				{
					iban.value = ibanMod
					//verificaCIN(ibanMod);
				}
			}
			else
			{
				DMessageBox('../', 'I primi 2 caratteri del codice iban devo essere lettere e devono indicare il codice paese', 'Attenzione', 1, 400, 300);
				return -1;	 	
			}
		}
		else
		{
			DMessageBox('../', 'Il codice IBAN non puo contenere caratteri speciali', 'Attenzione', 1, 400, 300);
			return -1;
		}
	}
}

function verificaCIN(input)
{
	var valori = {
		0: 0, 1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7, 8: 8, 9: 9,
        A: 10, B: 11, C: 12, D: 13, E: 14, F: 15, G: 16, H: 17, I: 18,
        J: 19, K: 20, L: 21, M: 22, N: 23, O: 24, P: 25, Q: 26, R: 27,
        S: 28, T: 29, U: 30, V: 31, W: 32, X: 33, Y: 34, Z: 35
    };

	// var countycode = input.substring(0, 4);
	// var ibanString = input.replace(countycode, "") + countycode.substring(0,2)

	// var ibanCin = "";

	// for (var i = 0; i < ibanString.length; i++)
	// {
	// 	var lettera = ibanString.substring(i, i + 1);
	// 	ibanCin = ibanCin + valori[lettera]
	// }

	// var iban = String(input).toUpperCase().replace(/[^A-Z0-9]/g, ''), // keep only alphanumeric characters
	// code = iban.match(/^([A-Z]{2})(\d{2})([A-Z\d]+)$/), // match and capture (1) the country code, (2) the check digits, and (3) the rest
	// digits;


	// // rearrange country code and check digits, and convert chars to ints
	// digits = (code[3] + code[1] + code[2]).replace(/[A-Z]/g, function (letter) {
	// 	return letter.charCodeAt(0) - 55;
	// });


	var checksum = digits.slice(0, 2), fragment;
    for (var offset = 2; offset < digits.length; offset += 7) {
        fragment = String(checksum) + digits.substring(offset, offset + 7);
        checksum = parseInt(fragment, 10) % 97;
    }
	return checksum;
}

function DisabilitaVisibilitàBollo()
{	
	var bollo = getObj('INVOICEAMOUNT_MODEL')
	var bolloValue = getObj('RINVOICEAMOUNT_MODEL_AllowanceChargeAmount_Bollo')
	bolloValue.value = "";
	setVisibility(bollo, 'none');	
}

function AbilitaVisibilitàBollo()
{
	var bollo = getObj('INVOICEAMOUNT_MODEL')
	setVisibility(bollo, '');	
}

function ORDERLINE_AFTER_COMMAND()
{
	ordine_onload();
}

function hideViewALL(display)
{
	/*
	hideViewAttribs( 'INVOICELINE', attributi_grid_IMPORTI, display );
	hideViewAttribs( 'INVOICELINE', attributi_grid_DATI, display );
	hideViewAttribs( 'INVOICELINE', attributi_grid_RIFERIMENTO, display );
	hideViewAttribs( 'INVOICELINE', attributi_grid_IVA, display );
	hideViewAttribs( 'INVOICELINE', attributi_grid_REPERTORIO, display );
	hideViewAttribs( 'INVOICELINE', attributi_grid_EXTRA, display );
	hideViewAttribs( 'INVOICELINE', attributi_grid_SCONTO, display );
	*/
}

function hideViewAttribs( section, array, display )
{
	var totElems = array.length;

	var k = 0;

	for( k = 0 ; k < totElems ; k++ )
	{
		try
		{
			ShowCol(section, array[k] , display);
		}
		catch(e)
		{
		}
	}

}

function DDT_ShowCol(section , strArray,display)
{
}

function caricaDestinatario(pid)
{

	//return;

	var ragSoc = '';
	var retAjax;

	getObj('RACCOUNTINGCUSTOMERPARTY_MODEL_PartyName').readOnly = false;
	
	if ( pid != '' )
	{
		var ajax = GetXMLHttpRequest();		
		var nocache = new Date().getTime();
		
		ajax.open('GET','../../customdoc/getDatiFromPID.asp?pid=' + encodeURIComponent(pid) + '&nocache=' + nocache , false);
		ajax.send(null);

		if(ajax.readyState == 4) 
		{
			if(ajax.status == 200)
			{
				retAjax = ajax.responseText;

				if ( retAjax != '' )
				{
					//Se abbiamo avuto una risposta positiva
					if ( retAjax.substring(0, 2) == '1#' )
					{

						ragSoc = retAjax.replace('1#','');
						
						if ( ragSoc == 'NOT_FOUND' )
						{
							ragSoc = '';
						}
						else
						{
							//Se la ragione sociale ritornata è associata ad un destinatario presente in anagrafica, rendiamo il campo ragione sociale readonly perchè non deve essere modificabile
							if ( ragSoc.indexOf('@@@') > 0 )
							{
								ragSoc = ragSoc.replace('@@@READONLY','');
								getObj('RACCOUNTINGCUSTOMERPARTY_MODEL_PartyName').value = ragSoc;							
								getObj('RACCOUNTINGCUSTOMERPARTY_MODEL_PartyName').readOnly = true;
							}
						}

					}

				}

			}

		 }
	}
	
	
}

function NotierPrint()
{
	var urn;
	
	urn = getObjValue('URN');
	
	//Se è presente l'URN dell'ordine ( quindi se l'ordine è stato inviato con successo )
	//Invoco la stampa dell'ordine direttamente tramite notier, altrimenti facciamo la nostra stampa base del documento
	if ( urn == '' )
	{
		ToPrint( '');
	}
	else
	{
		PrintPdf('/notier/dettaglio.asp&PDF_NAME=dettaglio&backoffice=yes&urn=' + encodeURI(urn) + '&pfu=' + encodeURI(idpfuUtenteCollegato));
		
		//var urlParam;
		//urlParam = '/notier/dettaglio.asp?urn=' + encodeURIComponent(urn) + '&pfu=' + encodeURIComponent(idpfuUtenteCollegato);
		//ExecFunction( pathRoot + 'ctl_library/pdf/pdf.asp?URL=' + encodeURIComponent(urlParam) + '&PDF_NAME=dettaglio&backoffice=yes');
	}
		
}

function svuotaTotale(obj) 
{
	var riga = obj.id.split('_')[1];
	getObj('RINVOICELINEGrid_' + riga + '_OrderLine_LineExtensionAmount_V').innerHTML = '';
	
	svuotaTotali();
}

function calcolaTotaleImposte(obj)
{
	var riga = obj.id.split('_')[1];
	getObj('RINVOICELINEGrid_' + riga + '_OrderLine_TotalTaxAmount_V').innerHTML = '';
	
	svuotaTotali();
}

function OLD_onChangeTipoIVA_OLD(obj, on_load)
{
	
	var tipoiva = obj.value;
	var riga = obj.id.split('_')[1];
	
	if ( tipoiva == 'S' || tipoiva == 'AA_1' || tipoiva == 'AA_2' )
	{
		if (!on_load)
			getObj('RINVOICELINEGrid_' + riga + '_OrderLine_ClassifiedTaxCategory_Percent').value = '';
		
		//Nascondo il valore 0%
		getObj('RINVOICELINEGrid_' + riga + '_OrderLine_ClassifiedTaxCategory_Percent_0').style.display = 'none'; //funziona con chrome e firefox
		getObj('RINVOICELINEGrid_' + riga + '_OrderLine_ClassifiedTaxCategory_Percent_0').disabled='disabled';	//funziona con IE
		
		//Rendo la percentuale d'iva selezionabile
		SelectreadOnly('RINVOICELINEGrid_' + riga + '_OrderLine_ClassifiedTaxCategory_Percent', false);
	}
	else
	{
		//Visualizzo il valore 0%
		getObj('RINVOICELINEGrid_' + riga + '_OrderLine_ClassifiedTaxCategory_Percent_0').style.display = '';
		getObj('RINVOICELINEGrid_' + riga + '_OrderLine_ClassifiedTaxCategory_Percent_0').disabled='';
		
		if (!on_load)
			getObj('RINVOICELINEGrid_' + riga + '_OrderLine_ClassifiedTaxCategory_Percent').value = '0';
			
		//rendo la percentuale d'iva non selezionabile
		SelectreadOnly('RINVOICELINEGrid_' + riga + '_OrderLine_ClassifiedTaxCategory_Percent', true);
	}

	if (!on_load)
		calcolaTotaleImposte(obj);
	
}

function onChangeTipoIVA(obj, on_load)
{
	
	/*
		18/09/2019 - richieste di IC post collaudo delle fatture :
		
		CAMBIARE GESTIONE DEI 2 CAMPI IVA. Il secondo campo ( Percentuale D'iva Applicata ) diventa sempre readonly e in base alla selezione del tipo d'iva lo valorizziamo
			iva ordinaria -> 22%
			iva ridotta -> 10%
			iva minima -> 4%
			per tutte le altre iva a 0%
	*/
	
	var tipoiva = obj.value;
	var riga = obj.id.split('_')[1];
	
	var valIVA = '0';
	
	//IVA Ordinaria 
	if ( tipoiva == 'S' )
	{
		valIVA = '22';
	}
	
	//IVA Agevolata Ridotta 
	if ( tipoiva == 'AA_1' )
	{
		valIVA = '10';
	}
	
	//IVA Agevolata minima 
	if ( tipoiva == 'AA_2' )
	{
		valIVA = '4';
	}

	//rendo la percentuale d'iva non selezionabile
	SelectreadOnly('RINVOICELINEGrid_' + riga + '_OrderLine_ClassifiedTaxCategory_Percent', true);

	//Se non siamo nell'onload del documento ( e siamo quindi nell'onchange del campo tipo iva )
	if (!on_load)
	{
		getObj('RINVOICELINEGrid_' + riga + '_OrderLine_ClassifiedTaxCategory_Percent').value = valIVA;
		calcolaTotaleImposte(obj);
	}

	
	GestioneBollo()
}

function svuotaTotali()
{

	getObj('RLEGALMONETARYTOTAL_MODEL_AnticipatedMonetaryTotal_LineExtensionAmount_V').innerHTML = '';
	getObj('RLEGALMONETARYTOTAL_MODEL_AnticipatedMonetaryTotal_TaxExclusiveAmount_V').innerHTML = '';
	getObj('RLEGALMONETARYTOTAL_MODEL_AnticipatedMonetaryTotal_TaxInclusiveAmount_V').innerHTML = '';
	getObj('RLEGALMONETARYTOTAL_MODEL_AnticipatedMonetaryTotal_PayableAmount_V').innerHTML = '';
	getObj('RLEGALMONETARYTOTAL_MODEL_TaxTotal_V').innerHTML = '';	
	getObj('RINVOICE_MODEL_TaxTotal_V').innerHTML = '';
	getObj('RLEGALMONETARYTOTAL_MODEL_AnticipatedMonetaryTotal_TotaleRitenuta_V').innerHTML = '';
	getObj('RLEGALMONETARYTOTAL_MODEL_AnticipatedMonetaryTotal_TotaleContributi_V').innerHTML = '';
	getObj('RLEGALMONETARYTOTAL_MODEL_AnticipatedMonetaryTotal_TotaleCPA_V').innerHTML = '';
}

function associaProdotti(param)
{	
	var idOrdine = getObjValue('RINVOICE_MODEL_OrderReference_ID');
	var idDDT = getObjValue('RINVOICE_MODEL_DespatchDocumentReference_ID');
	
	if ( idOrdine == '' && idDDT == '' )
	{
		DMessageBox( '../' , 'E\' necessario selezionare prima una ordine o un DDT' , 'Attenzione' , 2 , 400 , 300 );
	}
	else
	{
		if ( idOrdine != '' )
			ExecDocProcess( 'SAVE_AND_GO,NOTIER_INVOICE,,NO_MSG');
		else
			ExecDocProcess( 'SAVE_AND_GO_2,NOTIER_INVOICE,,NO_MSG');
	}
}

function afterProcess(param) 
{
	var cod = getObjValue('IDDOC');
	
	if (param == 'FITTIZIO') 
	{
		ShowWorkInProgress();
		OpenViewer('../NOTIER/lista.asp?lo=base&HIDE_COL=FNZ_OPEN,FNZ_UPD,FNZ_DEL&Table=view_Document_NoTIER_ListaDocumenti&OWNER=idOwner&IDENTITY=Id&JScript=notier&TOOLBAR=&DOCUMENT=&PATHTOOLBAR=../CustomDoc/&AreaAdd=no&Height=160,100*,210&numRowForPag=25&Sort=dataricezionenotier&SortOrder=desc&ACTIVESEL=1&FILTERCOLUMNFROMMODEL=yes&AreaFiltroWin=open&CAPTION=Lista Ordini&ShowExit=0&modgriglia=Document_NoTIER_ListaDocumentiGriglia&modellofiltro=Document_NoTIER_ListaDocumentiFiltro&FilterHide=chiave_tipodocumento%3D%27ORDINE%27&doc_to_upd='+ cod);
	}
	
	if (param == 'FITTIZIO2') 
	{
		ShowWorkInProgress();
		OpenViewer('../NOTIER/lista.asp?lo=base&HIDE_COL=FNZ_OPEN,FNZ_UPD,FNZ_DEL&Table=view_Document_NoTIER_ListaDocumenti_DDT&OWNER=idOwner&IDENTITY=Id&JScript=notier&TOOLBAR=&DOCUMENT=&PATHTOOLBAR=../CustomDoc/&AreaAdd=no&Height=160,100*,210&numRowForPag=25&Sort=DataInvio&SortOrder=desc&ACTIVESEL=1&FILTERCOLUMNFROMMODEL=yes&AreaFiltroWin=open&CAPTION=Lista DDT&ShowExit=0&modgriglia=Document_NoTIER_ListaDocumentiDDTGriglia&modellofiltro=notierCreaDaDddtFiltro&FilterHide=&doc_to_upd='+ cod);
	}
	
	// Selezione prodotti da ORDINE
	if (param == 'SAVE_AND_GO') 
	{
		ShowWorkInProgress();
		OpenViewer('Viewer.asp?doc_from=NOTIER_INVOICE&owner=owner&Table=view_Document_NoTIER_Prodotti&ModelloFiltro=NOTIER_DDT_ORDINE_RIGHEFiltro&ModGriglia=NOTIER_DDT_ORDINE_RIGHE&IDENTITY=idRow&lo=base&HIDE_COL=FNZ_DEL,EsitoRiga,&DOCUMENT=NOTIER_ORDINE_ADD_PRODOTTI&PATHTOOLBAR=../CustomDoc/&JSCRIPT=NOTIER_ORDINE_ADD_PRODOTTI&AreaAdd=no&Caption=Lista Prodotti Ordine&Height=180,100*,210&numRowForPag=20&Sort=IdRow&SortOrder=asc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_NOTIER_PRODOTTI&ACTIVESEL=2&FilterHide=IdHeader='+ cod + '&doc_to_upd='+ cod);
	}
	
	// Selezione prodotti da DDT
	if (param == 'SAVE_AND_GO_2') 
	{
		ShowWorkInProgress();
		OpenViewer('Viewer.asp?doc_from=NOTIER_INVOICE&owner=owner&Table=view_Document_NoTIER_ProdottiDaDDT&ModelloFiltro=NOTIER_DDT_ORDINE_RIGHEFiltro&ModGriglia=NOTIER_DDT_ORDINE_RIGHE&IDENTITY=idRow&lo=base&HIDE_COL=FNZ_DEL,EsitoRiga,&DOCUMENT=NOTIER_ORDINE_ADD_PRODOTTI&PATHTOOLBAR=../CustomDoc/&JSCRIPT=NOTIER_ORDINE_ADD_PRODOTTI&AreaAdd=no&Caption=Lista Prodotti Ordine&Height=180,100*,210&numRowForPag=20&Sort=IdRow&SortOrder=asc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_NOTIER_PRODOTTI&ACTIVESEL=2&FilterHide=IdHeader='+ cod + '&doc_to_upd='+ cod);
	}

}

function associaOrdine()
{
	ExecDocProcess('FITTIZIO,DOCUMENT,,NO_MSG');
}

function associaDDT()
{
	ExecDocProcess('FITTIZIO2,DOCUMENT,,NO_MSG');
}

function sganciaOrdine()
{
	var idOrdine = getObjValue('RINVOICE_MODEL_OrderReference_ID');
	var idDDT = getObjValue('RINVOICE_MODEL_DespatchDocumentReference_ID');
	
	if ( idOrdine == '' && idDDT == '' )
		DMessageBox( '../' , 'E\' necessario selezionare prima una documento di origine' , 'Attenzione' , 2 , 400 , 300 );  
	else
		ExecDocProcess( 'SGANCIA_DOCUMENTO,NOTIER_INVOICE');
}

function INVOICELINE_AFTER_COMMAND()
{
	var numeroRighe = GetProperty(getObj('INVOICELINEGrid'), 'numrow');
	var i;
	
	for (i = 0; i <= numeroRighe; i++) 
	{
		var sorgente_esterna = getObjValue('RINVOICELINEGrid_' + i + '_sorgente_esterna');
		
		//rendo la percentuale d'iva non selezionabile
		SelectreadOnly('RINVOICELINEGrid_' + i + '_OrderLine_ClassifiedTaxCategory_Percent', true);
		
		//Rendo i campi riferimento riga ordine e ddt readonly se si è scelta la selezione da sorgente esterna
		if ( sorgente_esterna == '1' )
		{
			getObj('RINVOICELINEGrid_' + i + '_OrderLine_id').readOnly = true;
			getObj('RINVOICELINEGrid_' + i + '_DespatchLine_ID').readOnly = true;
		}
		
	}
}

function validaCodiceAIC(objAIC)
{

	var msgErrorAIC = '';
	
	//SE IL CAMPO ESISTE
	if ( objAIC )
	{
		var codiceAIC = objAIC.value;
		
		if ( codiceAIC != '' )
		{
			
			var ajax = GetXMLHttpRequest();		
			var nocache = new Date().getTime();
			
			ajax.open('GET','../../customdoc/validaAIC.asp?aic=' + encodeURIComponent(codiceAIC) + '&nocache=' + nocache , false);
			ajax.send(null);

			if(ajax.readyState == 4) 
			{
				if(ajax.status == 200)
				{
					retAjax = ajax.responseText;

					if ( retAjax != '' )
					{
						//Se abbiamo avuto una risposta positiva
						if ( retAjax.substring(0, 2) == '1#' )
						{
							msgErrorAIC = retAjax.replace('1#','');
						}
					}
				}
			}
			
			if ( msgErrorAIC != '' )
			{
				objAIC.value = '';
				alert(msgErrorAIC);  
			}
			else
			{
				onChangeAIC(objAIC);
			}
			
			
		}		
		
	}

}

function isNumeric(n)
{
  return !isNaN(parseFloat(n)) && isFinite(n);
}

function divisioneIntera(y,x)
{
	return Math.floor(y/x);
}

function substring( stringa, start, length)
{
	
	//start  : The start position. The first position in string is 1
	//length : The number of characters to extract. Must be a positive number
	
	var strOut = '';
	
	strOut = stringa.substring(start-1, start+length-1);
	
	return strOut;
}

function onChangeAIC(objAIC)
{
	var numeroRiga = objAIC.id.replace('RINVOICELINEGrid_','').replace('_CodiceAIC','');
	
	var objCodForn = getObj('RINVOICELINEGrid_' + numeroRiga + '_SellersItemIdentification_ID');
	
	allineaCampiAIC(objAIC,  objCodForn);
	
}

function onCodForn(objCodForn)
{
	var numeroRiga = objCodForn.id.replace('RINVOICELINEGrid_','').replace('_SellersItemIdentification_ID','');
	
	var objAIC = getObj('RINVOICELINEGrid_' + numeroRiga + '_CodiceAIC');
	
	allineaCampiAIC(objAIC,  objCodForn);
	
}

function allineaCampiAIC(objAIC, objCodForn)
{
	/* 
	Aggiungere lato client il seguente comportamento :
	all'onChange dei 2 campi chiamare la stessa funzione che farà..
	SE valorizzato il codice AIC, terrò allineati i 2 campi codici AIC e cod. articolo fornitore. ribaltando quanto presente nell'aic sull'altro campo
	*/
	
	if ( objAIC.value != '' )
	{
		objCodForn.value = 	objAIC.value;
	}
}

function mySend(param)
{

	//var pid_dest = getObjValue('RACCOUNTINGCUSTOMERPARTY_MODEL_AccountingCustomerParty_EndpointID');
	
	//Dopo aver verificato tramite il metodo di lookup che il pid destinatario esiste, valorizziamo il flag nascosto 'FlagAssegnazione' mettendo un "1"
	//var esitoLookup = '';
	
	// if ( pid_dest == '' )
	// {
	// 	esitoLookup = 'Valorizzare il campo Partecipant ID Peppol';
	// 	getObj('RACCOUNTINGCUSTOMERPARTY_MODEL_AccountingCustomerParty_EndpointID').focus();
	// }
	// else
	// {
	// 	//esitoLookup = checkPID_lookup(pid_dest); chiama il webservice
	// }
	

	// if ( esitoLookup == '' )
	// {
	 	ExecDocProcess(param);
	// }
	// else
	// {
	// 	DMessageBox( '../ctl_library/' , esitoLookup , 'Attenzione' , 2 , 400 , 300 );
	// }
	
}

function onChangePID_dest(objSelf)
{
	var pid_dest = objSelf.value;
	
	objSelf.value = objSelf.value.toUpperCase();
	objSelf.value = objSelf.value.replace(/\s/g, "");
	
	//Svuotiamo il campo hidden per indicare che all'invio dobbiamo ricontrollare se il pid è restituito dal servizio di lookup
	getObj('FlagAssegnazione').value = '';
	
	caricaDestinatario(pid_dest);
	
}

function checkPID_lookup(pid)
{
	//Se il campo Partecipant ID Peppol è del tipo "0201:" allora vuol dire che la fattura deve essere trasmessa attraverso il canale SDI e non dobbiamo invocare il servizio di Lookup
	if ( pid.substring(0, 5) == '0201:' )
		return '';
	
	var esitoLookup = -1;
	var ajax = GetXMLHttpRequest();
	var nocache = new Date().getTime();
	var retAjax;
	var msgError = '';
	
	//Se non è ancora stato fatto il controllo sul PID
	if ( getObjValue('FlagAssegnazione') == '' )
	{
		try
		{
			ShowWorkInProgress();
			ajax.open('GET','../../notier/lookup.aspx?pid=' + encodeURIComponent(pid) + '&pfu=' + encodeURIComponent(idpfuUtenteCollegato) + '&nocache=' + nocache , false);
			ajax.send(null);
			ShowWorkInProgress(false);

			if(ajax.readyState == 4) 
			{
				if(ajax.status == 200)
				{
					retAjax = ajax.responseText;
						
					if ( retAjax != '' )
					{
						//In base alla risposta alziamo il flag per indicare che abbiamo avuto una risposta dal lookup e che fino a che non cambia il valore del campo participant ID non andremo a richiamare il servizio di lookup
						
						//Se abbiamo avuto una risposta positiva
						if ( retAjax.substring(0, 2) == '1#' )
						{
							esitoLookup = 1;
							msgError = '';
							getObj('FlagAssegnazione').value = '1';
						}
						else if ( retAjax.substring(0, 2) == '0#' ) //Messaggio di ritorno dal servizio di lookup
						{
							esitoLookup = 0;
							//msgError = retAjax.replace('0#','');
							msgError = 'Participant ID destinatario non presente';
							getObj('FlagAssegnazione').value = '0';
						}
						else //Errore di runtime
						{
							esitoLookup = -1;
							msgError = retAjax.replace('2#','');
							getObj('FlagAssegnazione').value = '';
						}
					}

				}
				else
				{
					msgError = 'Errore nel servizio di verifica Participant ID destinatario. Riprovare a breve';
				}

			}
			else
			{
				msgError = 'Servizio di verifica Participant ID destinatario non disponibile';
			}

		}
		catch(e)
		{
			ShowWorkInProgress(false);
			msgError = 'Errore di runtime nel controllo dell\'esistenza del participant ID destinatario:' + e.message;
		}

	}
	
	//Se avevamo già verificato l'assenza del participant id imputato non rifacciamo la lookup e blocchiamo l'utente
	if ( msgError == '' && getObjValue('FlagAssegnazione') == '0' )
	{
		msgError = 'Participant ID destinatario non presente';
	}
	
	return msgError;

}

function elencoNotificheIMR()
{
	var cod = getObjValue('IDDOC');
	
	ShowWorkInProgress();
	OpenViewer('viewer.asp?Table=view_Document_NoTIER_ListaDocumenti&HIDE_COL=&OWNER=idOwner&IDENTITY=Id&JScript=notier&TOOLBAR=VIEWER_LISTA_IMR_TOOLBAR&DOCUMENT=&PATHTOOLBAR=../CustomDoc/&AreaAdd=no&Height=160,100*,210&numRowForPag=25&Sort=dataricezionenotier&SortOrder=desc&ACTIVESEL=1&FILTERCOLUMNFROMMODEL=yes&AreaFiltroWin=open&CAPTION=Notifiche%20IMR&ShowExit=0&modgriglia=Document_NoTIER_ListaIMR&modellofiltro=&ROWCONDITION=&lo=base&FilterHide=LinkedDoc='+ cod);
}

function CheckCFPIVA(obj, prefissoObbligatorio, codStato, ParamPath)
{
	var tipoidentificativo = getObj('RACCOUNTINGCUSTOMERPARTY_MODEL_schemeID')
	if (tipoidentificativo.value == 'IT:VAT')
	{
		CheckIVA(obj, prefissoObbligatorio, codStato, ParamPath)
	}
}