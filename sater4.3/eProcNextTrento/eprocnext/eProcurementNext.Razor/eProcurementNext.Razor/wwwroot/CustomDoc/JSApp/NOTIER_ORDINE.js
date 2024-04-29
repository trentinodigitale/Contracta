var attributi_grid_IMPORTI = ['OrderLine_LineExtensionAmount', 'OrderLine_TotalTaxAmount', 'OrderLine_AllowanceCharge_Amount', 'OrderLine_AllowanceChargeReason'];
var attributi_grid_DATI = ['StandardItemIdentification_ID', 'OrderLine_Note', 'OrderLine_AccountingCost','RequestedDeliveryPeriod_StartDate','RequestedDeliveryPeriod_EndDate', 'LotIdentification_LotNumberID', 'ItemInstance_SerialID', 'BuyersItemIdentification'];
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
		
			var numeroRighe = GetProperty(getObj('ORDERLINEGrid'), 'numrow');
			var i;
			
			for (i = 0; i <= numeroRighe; i++) 
			{
				onChangeTipoIVA(getObj('RORDERLINEGrid_' + i + '_OrderLine_ClassifiedTaxCategory_ID'), true);
			}
			
			//Evidenzio l'esito se in errore
			if ( getObj('Note_V').innerHTML != '' && getObj('Note_V').innerHTML != '&nbsp;' )
			{
				var oldClass = getObj('Note_V').getAttribute('class');
				getObj('Note_V').setAttribute('class',oldClass + ' Text_Esito_Errore');
			}
			
			//Se l'orario del campo "data ddt" è ancora vuoto, lo valorizziamo con 00:00
			if ( getObjValue('RORDER_MODEL_Order_IssueDate_HH_V') == '' )
			{
				getObj('RORDER_MODEL_Order_IssueDate_HH_V').value = '00';
				ck_HH_VD ('RORDER_MODEL_Order_IssueDate' );
				getObj('RORDER_MODEL_Order_IssueDate_MM_V').value = '00';
				ck_MM_VD ('RORDER_MODEL_Order_IssueDate' );
			}
			
			onChangeTipoIVA_AllowanceCharge( getObj('RDELIVERY_MODEL_Sconto_ClassifiedTaxCategory_ID'), true );
			onChangeTipoIVA_AllowanceCharge( getObj('RDELIVERY_MODEL_Maggiorazione_ClassifiedTaxCategory_ID'), true );
		
		}
	}
	catch(e){}
	
	try
	{
		selezionaMittentePeppol();
	}
	catch(e)
	{
	}
	

}

function ORDERLINE_AFTER_COMMAND()
{
	ordine_onload();
}

function hideViewALL(display)
{
	hideViewAttribs( 'ORDERLINE', attributi_grid_IMPORTI, display );
	hideViewAttribs( 'ORDERLINE', attributi_grid_DATI, display );
	hideViewAttribs( 'ORDERLINE', attributi_grid_RIFERIMENTO, display );
	hideViewAttribs( 'ORDERLINE', attributi_grid_IVA, display );
	hideViewAttribs( 'ORDERLINE', attributi_grid_REPERTORIO, display );
	hideViewAttribs( 'ORDERLINE', attributi_grid_EXTRA, display );
	hideViewAttribs( 'ORDERLINE', attributi_grid_SCONTO, display );
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

function caricaParticipantID()
{
	
	var tipoIdentificativo;
	var identificativo;
	var participantIDdest;
	var vet;
	var ragSoc;
	var objRagSoc;
	var retAjax;
	
	tipoIdentificativo = getObjValue('RSELLERSUPPLIERPARTY_MODEL_schemeID');
	identificativo  = getObjValue('RSELLERSUPPLIERPARTY_MODEL_PartyIdentification_ID');
	participantIDdest = getObj('RSELLERSUPPLIERPARTY_MODEL_SellerSupplierParty_EndpointID');
	objRagSoc = getObj('RSELLERSUPPLIERPARTY_MODEL_PartyName');
	
	//RSELLERSUPPLIERPARTY_MODEL_PartyName
	
	if ( tipoIdentificativo != '' && identificativo != '' )
	{
		var ajax = GetXMLHttpRequest();		
		var nocache = new Date().getTime();
		var pid;
		
		ajax.open('GET','../../customdoc/getParticipantID.asp?tipo=' + encodeURIComponent(tipoIdentificativo) + '&cod=' + encodeURIComponent(identificativo) + '&nocache=' + nocache , false);
		ajax.send(null);

		if(ajax.readyState == 4) 
		{

			if(ajax.status == 200)
			{
				retAjax = ajax.responseText;
					
				if ( retAjax != '' )
				{
					vet = retAjax.split('###');
					
					pid = vet[0];
					ragSoc = vet[1];

					if ( pid != '' )
						participantIDdest.value = pid;
					
					objRagSoc.value = ragSoc;
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
	getObj('RORDERLINEGrid_' + riga + '_OrderLine_LineExtensionAmount_V').innerHTML = '';
	
	svuotaTotali();
}

function calcolaTotaleImposte(obj)
{
	var riga = obj.id.split('_')[1];
	
	try
	{
		getObj('RORDERLINEGrid_' + riga + '_OrderLine_TotalTaxAmount_V').innerHTML = '';
	}
	catch(e){}
	
	svuotaTotali();
}

function onChangeTipoIVA(obj, on_load)
{
	var tipoiva = obj.value;
	var riga = obj.id.split('_')[1];
	
	if ( tipoiva == 'S' || tipoiva == 'AA_1' || tipoiva == 'AA_2' )
	{
		if (!on_load)
			getObj('RORDERLINEGrid_' + riga + '_OrderLine_ClassifiedTaxCategory_Percent').value = '';
		
		//Nascondo il valore 0%
		getObj('RORDERLINEGrid_' + riga + '_OrderLine_ClassifiedTaxCategory_Percent_0').style.display = 'none'; //funziona con chrome e firefox
		getObj('RORDERLINEGrid_' + riga + '_OrderLine_ClassifiedTaxCategory_Percent_0').disabled='disabled';	//funziona con IE
		
		//Rendo la percentuale d'iva selezionabile
		SelectreadOnly('RORDERLINEGrid_' + riga + '_OrderLine_ClassifiedTaxCategory_Percent', false);
	}
	else
	{
		//Visualizzo il valore 0%
		getObj('RORDERLINEGrid_' + riga + '_OrderLine_ClassifiedTaxCategory_Percent_0').style.display = '';
		getObj('RORDERLINEGrid_' + riga + '_OrderLine_ClassifiedTaxCategory_Percent_0').disabled='';
		
		if (!on_load)
			getObj('RORDERLINEGrid_' + riga + '_OrderLine_ClassifiedTaxCategory_Percent').value = '0';
			
		//rendo la percentuale d'iva non selezionabile
		SelectreadOnly('RORDERLINEGrid_' + riga + '_OrderLine_ClassifiedTaxCategory_Percent', true);
	}

	if (!on_load)
		calcolaTotaleImposte(obj);
	
}

function onChangeTipoIVA_AllowanceCharge(obj, on_load)
{
	var tipoiva = obj.value;
	var id_tipoiva = obj.id;
	var targetObj = '';
	
	if ( id_tipoiva == 'RDELIVERY_MODEL_Sconto_ClassifiedTaxCategory_ID' )
		targetObj = 'RDELIVERY_MODEL_Sconto_ClassifiedTaxCategory_Percent';
	else
		targetObj = 'RDELIVERY_MODEL_Maggiorazione_ClassifiedTaxCategory_Percent';
	
	if ( tipoiva == 'S' || tipoiva == 'AA_1' || tipoiva == 'AA_2' )
	{
		if (!on_load)
			getObj(targetObj).value = '';
		
		//Nascondo il valore 0%
		getObj(targetObj + '_0').style.display = 'none'; //funziona con chrome e firefox
		getObj(targetObj + '_0').disabled='disabled';	//funziona con IE
		
		//Rendo la percentuale d'iva selezionabile
		SelectreadOnly(targetObj, false);
	}
	else
	{
		//Visualizzo il valore 0%
		getObj(targetObj + '_0').style.display = '';
		getObj(targetObj + '_0').disabled='';
		
		if (!on_load)
			getObj(targetObj).value = '0';
			
		//rendo la percentuale d'iva non selezionabile
		SelectreadOnly(targetObj, true);
	}

	if (!on_load)
		svuotaTotali();
	
}

function svuotaTotali()
{
	getObj('RANTICIPATEDMONETARYTOTAL_MODEL_AnticipatedMonetaryTotal_LineExtensionAmount_V').innerHTML = '';
	getObj('RANTICIPATEDMONETARYTOTAL_MODEL_AnticipatedMonetaryTotal_TaxExclusiveAmount_V').innerHTML = '';
	getObj('RANTICIPATEDMONETARYTOTAL_MODEL_AnticipatedMonetaryTotal_TaxInclusiveAmount_V').innerHTML = '';
	getObj('RANTICIPATEDMONETARYTOTAL_MODEL_AnticipatedMonetaryTotal_PayableAmount_V').innerHTML = '';
	getObj('RANTICIPATEDMONETARYTOTAL_MODEL_TaxTotal_V').innerHTML = '';	

	try
	{
		getObj('RORDER_MODEL_TaxTotal').value = '';
	}
	catch(e)
	{}
	
	try
	{
		getObj('RORDER_MODEL_TaxTotal_V').innerHTML = '';
	}
	catch(e)
	{}
}

function selezionaMittentePeppol(  )
{

	//Entriamo in questa funzione solo se il campo participant id mittente è editabile, altrimenti vuol dire che è stato preavvalorato e readonly
	if ( getObj('RBUYERCUSTOMERPARTY_MODEL_PARTICIPANTID_MITTENTE').type != 'text' && getObj('RBUYERCUSTOMERPARTY_MODEL_PARTICIPANTID_MITTENTE').tagName != 'SELECT' )
		return;
	
	var identificativo = getObjValue('RBUYERCUSTOMERPARTY_MODEL_PartyIdentification_ID');
	var tipoIdentificativo = getObjValue('RBUYERCUSTOMERPARTY_MODEL_schemeID');
	
	getObj('RBUYERCUSTOMERPARTY_MODEL_PARTICIPANTID_MITTENTE').readOnly = false;
	

	var ajax = GetXMLHttpRequest();		
	var nocache = new Date().getTime();
	var pid;
	
	ajax.open('GET','../../customdoc/getParticipantID.asp?ente_ext=1&tipo=' + encodeURIComponent(tipoIdentificativo) + '&cod=' + encodeURIComponent(identificativo) + '&nocache=' + nocache , false);
	ajax.send(null);

	if(ajax.readyState == 4) 
	{

		if(ajax.status == 200)
		{
			retAjax = ajax.responseText;
		
			var oldPID = getObjValue('RBUYERCUSTOMERPARTY_MODEL_PARTICIPANTID_MITTENTE');
		
			if ( retAjax != '' )
			{
				vet = retAjax.split('###');
				
				var parentObj = getObj('RBUYERCUSTOMERPARTY_MODEL_PARTICIPANTID_MITTENTE').parentNode;
				
				if ( vet.length == 1 )
				{
					//getObj('RBUYERCUSTOMERPARTY_MODEL_PARTICIPANTID_MITTENTE').value = vet[0];
					//getObj('RBUYERCUSTOMERPARTY_MODEL_PARTICIPANTID_MITTENTE').readOnly = true;
					var strHTML = '<input type="text" name="RBUYERCUSTOMERPARTY_MODEL_PARTICIPANTID_MITTENTE" id="RBUYERCUSTOMERPARTY_MODEL_PARTICIPANTID_MITTENTE" class="Text" maxlength="20" size="20" value="' + vet[0] + '" readonly>';
					parentObj.innerHTML = strHTML;
				}
				else
				{
					
					//Cancello la text box
					parentObj.innerHTML = '';
					
					var strListPID = '<select id="RBUYERCUSTOMERPARTY_MODEL_PARTICIPANTID_MITTENTE" name="RBUYERCUSTOMERPARTY_MODEL_PARTICIPANTID_MITTENTE" class="FldDomainValue">';
					
					for (var index = 0; index < vet.length; ++index) 
					{
						pid = vet[index];
					
						if ( pid != '' )
						{
							strListPID = strListPID + '<option value="' + pid + '"';
							
							if ( pid == oldPID )
								strListPID = strListPID + ' selected="selected"';
							
							strListPID = strListPID + '>' + pid + '</option>';
						}
					}
					
					strListPID = strListPID + '</select>';
					
					parentObj.innerHTML = strListPID;
					
				}
				
				

			}

		}

	 }

	
}

function loadRagSocFromPID()
{
	var pidDest = getObjValue('RSELLERSUPPLIERPARTY_MODEL_SellerSupplierParty_EndpointID');
	
	if ( pidDest != '' )
	{
		var ajax = GetXMLHttpRequest();		
		var nocache = new Date().getTime();
		var pid;
		
		ajax.open('GET','../../customdoc/getParticipantID.asp?rag_soc=1&cod=' + encodeURIComponent(pidDest) + '&nocache=' + nocache , false);
		ajax.send(null);

		if(ajax.readyState == 4) 
		{

			if(ajax.status == 200)
			{
				retAjax = ajax.responseText;
					
				if ( retAjax != '' )
				{
					var objRagSoc = getObj('RSELLERSUPPLIERPARTY_MODEL_PartyName');
					objRagSoc.value = retAjax;
				}

			}

		 }
	}
}

