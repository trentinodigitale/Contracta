/*
	Prodotto 	  	  ( Descrizione, Note, Cod.Articolo Fornitore, Cod.Art.Standard, Quantità Cons )
	Rif. Gara	 	  ( Rif. di gara / tipo, id rif., data rif. )
	Merce Inevasa	  ( Quantità inevasa, ragione o motivo )
	Articolo - Lotto  ( Informazioni Articolo - ID Seriale, ID Lotto, 	Data Scadenza Articolo )
	Merce pericolosa  ( Merce Pericolosa )
	Spedizione	  	  ( Tipo Unità Logistica (UN/ECE Rec21), Scritta Sull'etichetta Dell'imballaggio, Codice Unità Di Misura (UN CL 6313), Spedizione - Peso ( KG ) )
	Conservazione	  ( Temperatura Per (Es. Trasporto, Conservazione), ............... )
*/

var attributi_grid_CONSERVAZIONE = ['Temperature_AttributeID', 'Temperature_Measure', 'Temperature_UM_Measure', 'MinimumTemperature_AttributeID', 'MinimumTemperature_Measure', 'MinimumTemperature_UM_Measure', 'MaximumTemperature_AttributeID', 'MaximumTemperature_Measure', 'MaximumTemperature_UM_Measure'];
var attributi_grid_INEVASA = ['DespatchLine_OutstandingQuantity', 'DespatchLine_OutstandingReason', 'DespatchLine_OutstandingQuantity_unitCode'];
var attributi_grid_PERICOLOSA = ['HazardousRiskIndicator'];
var attributi_grid_PERICOLOSA_2 = ['HazardousItem_ID', 'HazardousItem_TechnicalName', 'HazardousItem_CategoryName', 'HazardousItem_HazardClassID', 'HazardousItem_UNDGCode'];
//var attributi_grid_PRODOTTO = ['Item_Name','DespatchLine_Note']; //'Item_AdditionalInformation', 'SellersItemIdentification_ID', 'StandardItemIdentification_ID', 'DespatchLine_DeliveredQuantity'];
var attributi_grid_PRODOTTO = ['StandardItemIdentification_ID','DespatchLine_Note', 'BuyersItemIdentification', 'OrderLine_AdditionalItemProperty_Name', 'OrderLine_AdditionalItemProperty_Value']; //'Item_AdditionalInformation', 'SellersItemIdentification_ID', 'DespatchLine_DeliveredQuantity'];
var attributi_grid_GARA = ['DocumentReference_DocumentType','DocumentReference_ID', 'DocumentReference_IssueDate','DocumentReference_DocumentType_2','DocumentReference_ID_2', 'DocumentReference_IssueDate_2', 'AdditionalDocumentReference_CIG', 'AdditionalDocumentReference_CIG_IssueDate', 'AdditionalDocumentReference_CUP', 'AdditionalDocumentReference_CUP_IssueDate', 'AdditionalDocumentReference_CONV', 'AdditionalDocumentReference_CONV_IssueDate' ];
var attributi_grid_SPEDIZIONE = ['DespatchLine_Shipment_HandlingCode', 'TransportHandlingUnitTypeCode', 'ShippingMarks', 'MeasurementDimension_AttributeID', 'MeasurementDimension_Measure'];
var attributi_grid_LOTTO = ['ItemInstance_SerialID', 'LotIdentification_LotNumberID', 'LotIdentification_ExpiryDate'];

window.onload = ddt_onload;

function ddt_onload()
{
	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	 
	try
	{
		//hideViewALL('none');
	}
	catch(e){}
	
	if ( DOCUMENT_READONLY != '1' )
	{
		/* Se sto aprendo un DDT con un ordine agganciato blocco il campo EndpointID_Destinatario nella sezione destinatario */
		//var idOrdine = getObjValue('RDESPATCHADVICE_MODEL_OrderReference_ID');
		//var endPointDest = getObjValue('RDELIVERYCUSTOMERPARTY_MODEL_EndpointID_Destinatario');
		var ordine_associato = getObjValue('ordine_associato');
		
		if ( ordine_associato == '1' )
		{
		
			getObj('RDELIVERYCUSTOMERPARTY_MODEL_EndpointID_Destinatario_edit_new').readOnly = true;
			getObj('RDELIVERYCUSTOMERPARTY_MODEL_EndpointID_Destinatario_button').style.display = 'none';
		}
		
		//Se l'orario del campo "data ddt" è ancora vuoto, lo valorizziamo con 00:00
		if ( getObjValue('RDESPATCHADVICE_MODEL_DespatchAdvice_IssueDate_HH_V') == '' )
		{
			getObj('RDESPATCHADVICE_MODEL_DespatchAdvice_IssueDate_HH_V').value = '00';
			ck_HH_VD ('RDESPATCHADVICE_MODEL_DespatchAdvice_IssueDate' );
			getObj('RDESPATCHADVICE_MODEL_DespatchAdvice_IssueDate_MM_V').value = '00';
			ck_MM_VD ('RDESPATCHADVICE_MODEL_DespatchAdvice_IssueDate' );
		}
		
		try
		{
			selezionaMittentePeppol();
		}
		catch(e){}
		
	}
}

function DESPATCHLINE_AFTER_COMMAND()
{
	ddt_onload();
}

function hideViewALL(display)
{
	hideViewAttribs( 'DESPATCHLINE', attributi_grid_CONSERVAZIONE, display );
	hideViewAttribs( 'DESPATCHLINE', attributi_grid_INEVASA, display );
	hideViewAttribs( 'DESPATCHLINE', attributi_grid_PERICOLOSA, display );
	hideViewAttribs( 'DESPATCHLINE', attributi_grid_PERICOLOSA_2, display );
	hideViewAttribs( 'DESPATCHLINE', attributi_grid_PRODOTTO, display );
	hideViewAttribs( 'DESPATCHLINE', attributi_grid_GARA, display );
	hideViewAttribs( 'DESPATCHLINE', attributi_grid_SPEDIZIONE, display );
	hideViewAttribs( 'DESPATCHLINE', attributi_grid_LOTTO, display );
}

function attivaMercePericolosa(obj)
{
	var val = '';
	var k = 0;
	var numeroRighe = -1;
	
	try
	{
		val = obj.value;

		if ( val == undefined )
			val = 'si';

	}
	catch(e)
	{
		val = 'si';
	}

	hideViewAttribs( 'DESPATCHLINE', attributi_grid_PERICOLOSA, '' );

	numeroRighe = GetProperty( getObj('DESPATCHLINEGrid'),'numrow');
	
	for( k = 0 ; k <= numeroRighe ; k++ )
	{
		val  = getObjValue('RDESPATCHLINEGrid_' + k + '_HazardousRiskIndicator');
	
		if ( val == 'si' )
		{
			hideViewAttribs( 'DESPATCHLINE', attributi_grid_PERICOLOSA_2, '' );
			break;
		}
		else
		{
			hideViewAttribs( 'DESPATCHLINE', attributi_grid_PERICOLOSA_2, 'none' );
		}
	}
	
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

function associaOrdine()
{
	ExecDocProcess('FITTIZIO,DOCUMENT,,NO_MSG');
}

function afterProcess(param) 
{
	if (param == 'FITTIZIO') 
	{
		ShowWorkInProgress();
		var cod = getObjValue('IDDOC');
		OpenViewer('../NOTIER/lista.asp?lo=base&HIDE_COL=FNZ_OPEN,FNZ_UPD,FNZ_DEL&Table=view_Document_NoTIER_ListaDocumenti&OWNER=idOwner&IDENTITY=Id&JScript=notier&TOOLBAR=&DOCUMENT=&PATHTOOLBAR=../CustomDoc/&AreaAdd=no&Height=160,100*,210&numRowForPag=25&Sort=dataricezionenotier&SortOrder=desc&ACTIVESEL=1&FILTERCOLUMNFROMMODEL=yes&AreaFiltroWin=open&CAPTION=Lista Ordini&ShowExit=0&modgriglia=Document_NoTIER_ListaDocumentiGriglia&modellofiltro=Document_NoTIER_ListaDocumentiFiltro&FilterHide=chiave_tipodocumento%3D%27ORDINE%27&doc_to_upd='+ cod);
	}
	
	if (param == 'SAVE_AND_GO') 
	{
		ShowWorkInProgress();
		var cod = getObjValue('IDDOC');
		OpenViewer('Viewer.asp?owner=owner&Table=view_Document_NoTIER_Prodotti&ModelloFiltro=NOTIER_DDT_ORDINE_RIGHEFiltro&ModGriglia=NOTIER_DDT_ORDINE_RIGHE&IDENTITY=idRow&lo=base&HIDE_COL=FNZ_DEL,EsitoRiga,&DOCUMENT=NOTIER_ORDINE_ADD_PRODOTTI&PATHTOOLBAR=../CustomDoc/&JSCRIPT=NOTIER_ORDINE_ADD_PRODOTTI&AreaAdd=no&Caption=Lista Prodotti Ordine&Height=180,100*,210&numRowForPag=20&Sort=IdRow&SortOrder=asc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_NOTIER_PRODOTTI&ACTIVESEL=2&FilterHide=IdHeader='+ cod + '&doc_to_upd='+ cod);
	}

}

function associaProdotti(param)
{	
	var idOrdine = getObjValue('RDESPATCHADVICE_MODEL_OrderReference_ID');
	
	if ( idOrdine == '' )
		DMessageBox( '../' , 'E\' necessario selezionare prima una ordine' , 'Attenzione' , 2 , 400 , 300 );  
	else
		ExecDocProcess( 'SAVE_AND_GO,NOTIER_DDT,,NO_MSG');
}

function sganciaOrdine()
{
	var idOrdine = getObjValue('RDESPATCHADVICE_MODEL_OrderReference_ID');
	
	if ( idOrdine == '' )
		DMessageBox( '../' , 'E\' necessario selezionare prima una ordine' , 'Attenzione' , 2 , 400 , 300 );  
	else
		ExecDocProcess( 'SGANCIA_ORDINE,NOTIER_DDT');
}

function DDT_ShowCol(section , strArray,display)
{
}

function checkTipoAltroRif()
{
	/* IMPEDIAMO L'IMPUTAZIONE DI UNO DEI TIPI GIA PREVISTI NEI CAMPI FISSI cig cup e convenzione */
	
	var val = getObjValue('RDESPATCHADVICE_MODEL_AdditionalDocumentReference_DocType').toUpperCase();
	
	if ( val == 'CIG' || val == 'CUP' || val == 'CONVENZIONE' )
	{
		getObj('RDESPATCHADVICE_MODEL_AdditionalDocumentReference_DocType').value = '';
		getObj('RDESPATCHADVICE_MODEL_AdditionalDocumentReference_ID').value = '';
		DMessageBox( '../' , 'Valore non ammesso. Inserire il riferimento nei campi preposti' , 'Attenzione' , 2 , 400 , 300 );
	}
	
	
}

function selezionaMittentePeppol(  )
{
	
	//Entriamo in questa funzione solo se il campo participant id mittente è editabile, altrimenti vuol dire che è stato preavvalorato e readonly
	if ( getObj('RDESPATCHSUPPLIERPARTY_MODEL_PARTICIPANTID').type != 'text'  && getObj('RDESPATCHSUPPLIERPARTY_MODEL_PARTICIPANTID').tagName != 'SELECT' )
		return;
	
	var identificativo = getObjValue('RDESPATCHSUPPLIERPARTY_MODEL_PartyIdentification_ID');
	var tipoIdentificativo = getObjValue('RDESPATCHSUPPLIERPARTY_MODEL_schemeID');
	
	getObj('RDESPATCHSUPPLIERPARTY_MODEL_PARTICIPANTID').readOnly = false;
	

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
		
			var oldPID = getObjValue('RDESPATCHSUPPLIERPARTY_MODEL_PARTICIPANTID');
		
			if ( retAjax != '' )
			{
				vet = retAjax.split('###');
				
				var parentObj = getObj('RDESPATCHSUPPLIERPARTY_MODEL_PARTICIPANTID').parentNode;
				
				if ( vet.length == 1 )
				{
					var strHTML = '<input type="text" name="RDESPATCHSUPPLIERPARTY_MODEL_PARTICIPANTID" id="RDESPATCHSUPPLIERPARTY_MODEL_PARTICIPANTID" class="Text" maxlength="20" size="20" value="' + vet[0] + '" readonly>';
					parentObj.innerHTML = strHTML;
				}
				else
				{
					
					//Cancello la text box
					parentObj.innerHTML = '';
					
					var strListPID = '<select id="RDESPATCHSUPPLIERPARTY_MODEL_PARTICIPANTID" name="RDESPATCHSUPPLIERPARTY_MODEL_PARTICIPANTID" class="FldDomainValue">';
					
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
