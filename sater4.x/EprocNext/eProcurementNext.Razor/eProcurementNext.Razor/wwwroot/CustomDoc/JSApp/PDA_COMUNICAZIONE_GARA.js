window.onload = InitComunicazione;
SetPositionRecursive(getObj('Cell_Note'), 'relative');
function OpenCollegati() {

	var Fascicolo = '';
	try { Fascicolo = getObjValue('Fascicolo') } catch (e) { };


	var URL = ''

	if (getObj('JumpCheck').value.indexOf('-BANDO_CONSULTAZIONE_GENERICA') >= 0 || getObj('JumpCheck').value.indexOf('-BANDO_CONSULTAZIONE_COMUNICAZIONE_RISPOSTA') >= 0) {
		URL = '../dashboard/mainView.asp?A=A&FOLDER_GROUP=LINKED_CONSULTAZIONE_BANDO&FilterHide= Fascicolo = \'' + Fascicolo + '\' ';

	}
	else {
		URL = '../dashboard/mainView.asp?A=A&FOLDER_GROUP=LINKED_ISCRIZIONE_ALBO&FilterHide= Fascicolo = \'' + Fascicolo + '\' ';
	}


	parent.parent.parent.DocumentiCollegati(URL);

}


function InitComunicazione() {

	//setto come caption del documento il contentuto del campo titolo
	//$(".Caption tr td:eq(1)").text( getObj('Titolo_V').innerHTML );          	            
	//-- se la comunicazione è relativa ad una comunicazione fornitore convenzione nasconde determinati campi
	try {
		if (getObj('JumpCheck').value.indexOf('COMUNICAZIONE_FORNITORE_CONVENZIONE') > 0) {
			$("#cap_DataDocumento").parents("table:first").css({ "display": "none" })
			$("#cap_CUP").parents("table:first").css({ "display": "none" })

		}

	} catch (e) { };

	try {
		if (getObj('JumpCheck').value.indexOf('SOSPENSIONE_GARA') > 0) {
			$("#cap_DataDocumento").parents("table:first").css({ "display": "none" })


		}

	} catch (e) { };

	try {
		if (getObj('JumpCheck').value.indexOf('RIPRISTINO_GARA') > 0) {
			$("#cap_DataDocumento").parents("table:first").css({ "display": "none" })


		}

	} catch (e) { };

	try {
		if (getObj('JumpCheck').value.indexOf('GARA_COMUNICAZIONE_GENERICA') > 0) {
			$("#cap_DataDocumento").parents("table:first").css({ "display": "none" })


		}

	} catch (e) { };


	//-- se la comunicazione è relativa ad una verifica registrazione nasconde determinati campi
	try {
		if (getObj('JumpCheck').value.indexOf('VERIFICA_REGISTRAZIONE_FORN') > 0 || getObj('JumpCheck').value.indexOf('GENERICA_RIDOTTA') > 0 || getObj('JumpCheck').value.indexOf('FABBISOGNI_COMUNICAZIONE_GENERICA') > 0) {

			$("#cap_CIG").parents("table:first").css({ "display": "none" })
			//try{ getObj( 'CIG' ).style.display='none'; }catch(e){}; 
			//try{ getObj( 'cap_CIG' ).style.display='none'; }catch(e){};
			//try{ getObj( 'Cell_CIG' ).style.display='none'; }catch(e){};

			$("#cap_CUP").parents("table:first").css({ "display": "none" })
			//try{ getObj( 'CUP' ).style.display='none'; }catch(e){};
			//try{ getObj( 'cap_CUP' ).style.display='none'; }catch(e){};
			//try{ getObj( 'Cell_CUP' ).style.display='none'; }catch(e){};

			$("#cap_DataScadenza").parents("table:first").css({ "display": "none" })
			// try{ getObj( 'DataScadenza' ).style.display='none'; }catch(e){};
			// try{ getObj( 'cap_DataScadenza' ).style.display='none'; }catch(e){};
			// try{ getObj( 'Cell_DataScadenza' ).style.display='none'; }catch(e){};

			$("#cap_DataDocumento").parents("table:first").css({ "display": "none" })
			// try{ getObj( 'DataDocumento' ).style.display='none'; }catch(e){};
			// try{ getObj( 'cap_DataDocumento' ).style.display='none'; }catch(e){};
			// try{ getObj( 'Cell_DataDocumento' ).style.display='none'; }catch(e){};

			$("#cap_UserDirigente").parents("table:first").css({ "display": "none" })
			// try{ getObj( 'UserDirigente' ).style.display='none'; }catch(e){};
			// try{ getObj( 'cap_UserDirigente' ).style.display='none'; }catch(e){};
			// try{ getObj( 'Cell_UserDirigente' ).style.display='none'; }catch(e){};
			// try{ getObj( 'val_UserDirigente' ).style.display='none'; }catch(e){};		

			$("#cap_IdpfuInCharge").parents("table:first").css({ "display": "none" })
			// try{ getObj( 'IdpfuInCharge' ).style.display='none'; }catch(e){};
			// try{ getObj( 'cap_IdpfuInCharge' ).style.display='none'; }catch(e){};
			// try{ getObj( 'Cell_IdpfuInCharge' ).style.display='none'; }catch(e){};

			$("#cap_CanaleNotifica").parents("table:first").css({ "display": "none" })
			// try{ getObj( 'CanaleNotifica' ).style.display='none'; }catch(e){};
			// try{ getObj( 'cap_CanaleNotifica' ).style.display='none'; }catch(e){};
			// try{ getObj( 'Cell_CanaleNotifica' ).style.display='none'; }catch(e){};		

		}
	} catch (e) { };

	//-- se la comunicazione non è per esclusione lotti nascondo la sezione dei lotti
	try {
		if (getObj('JumpCheck').value.indexOf('-LOTTI_ESCLUSIONE') == -1) {
			setVisibility(getObj('LOTTI'), 'none');
		}
	} catch (e) { };

	//se la comunicazione non ammette risposta nascondo i campi RichiestaRisposta e DataScadenza
	try {
		//if( getObj( 'JumpCheck' ).value.indexOf( '-VERIFICA_INTEGRATIVA' ) == -1 )
		if (getObj('JumpCheck').value.indexOf('1-') == -1 && getObj('JumpCheck').value.indexOf('COMUNICAZIONE_FORNITORE_CONVENZIONE') == -1) {
			$("#cap_RichiestaRisposta").parents("table:first").css({ "display": "none" });
			$("#cap_DataScadenza").parents("table:first").css({ "display": "none" });
		}
		else {

			//se documento editabile e se non è COMUNICAZIONE_FORNITORE_CONVENZIONE e nemmeno BANDO_CONSULTAZIONE_COMUNICAZIONE_RISPOSTA
			if (getObj('DOCUMENT_READONLY').value != '1' && getObj('JumpCheck').value.indexOf('COMUNICAZIONE_FORNITORE_CONVENZIONE') == -1 && getObj('JumpCheck').value.indexOf('BANDO_CONSULTAZIONE_COMUNICAZIONE_RISPOSTA') == -1) {

				//se ammette risposta vado a recuperare DataScadenza dal padre con chiamata ajax asincrona
				ajax = GetXMLHttpRequest();
				if (ajax) {

					ajax.open("GET", '../../ctl_library/functions/Get_Scadenza_Com_Capogruppo.asp?IDDOC=' + getObj('IDDOC').value, true);


					ajax.onreadystatechange = function () {

						if (ajax.readyState == 4) {

							if (ajax.status == 200) {
								if (ajax.responseText != '') {

									//alert(ajax.responseText);

									var Tech_Data = ajax.responseText;
									var Temp_Tech_Data = Tech_Data.substring(0, 10);
									var Temp_Tech_Data_Orario = Tech_Data.substring(11);

									//recupero forma visuale
									var extra_attrib = getObj('DataScadenza_extraAttrib').value;

									var ainfo = extra_attrib.split('#=#');
									var strFormat = ainfo[1];

									var vetValue = Temp_Tech_Data.split('-');

									var VisValuDataInizio = '';

									if (strFormat.substr(0, 10).toLowerCase() == 'dd/mm/yyyy') {
										VisValuDataInizio = vetValue[2] + '/' + vetValue[1] + '/' + vetValue[0];
									} else {
										VisValuDataInizio = vetValue[1] + '/' + vetValue[2] + '/' + vetValue[0];
									}

									if (strFormat.length == 13)
										VisValuDataInizio = VisValuDataInizio + ' ' + Temp_Tech_Data_Orario.substring(0, 2);
									if (strFormat.length == 16)
										VisValuDataInizio = VisValuDataInizio + ' ' + Temp_Tech_Data_Orario.substring(0, 5);
									if (strFormat.length == 19)
										VisValuDataInizio = VisValuDataInizio + ' ' + Temp_Tech_Data_Orario;

									//setto la data scadenza
									SetDataValue('DataScadenza', Tech_Data, VisValuDataInizio);
								}

							}
						}
					}

					ajax.send(null);

				}
			}
		}

	} catch (e) { };


	try {
		// gestisce il campo RichiestaRisposta se si tratta di BANDO_CONSULTAZIONE_COMUNICAZIONE_RISPOSTA
		if (getObj('JumpCheck').value.indexOf('-BANDO_CONSULTAZIONE_COMUNICAZIONE_RISPOSTA') >= 0)
			GestioneRichiestaRisposta();

	} catch (e) { };



	try {
		if (getObj('JumpCheck').value.indexOf('-BANDO_CONSULTAZIONE_GENERICA') >= 0 || getObj('JumpCheck').value.indexOf('-BANDO_CONSULTAZIONE_COMUNICAZIONE_RISPOSTA') >= 0) {
			$("#cap_CIG").parents("table:first").css({ "display": "none" });
			$("#cap_CUP").parents("table:first").css({ "display": "none" });
			$("#cap_DataDocumento").parents("table:first").css({ "display": "none" });
			$("#cap_UserDirigente").parents("table:first").css({ "display": "none" });
			$("#cap_IdpfuInCharge").parents("table:first").css({ "display": "none" });
		}
	} catch (e) { };

	//se documento editabile
	if (getObj('DOCUMENT_READONLY').value == '0') {
		try {
			//IMPOSTO UN EVENTO DI ONCHANGESULLEDATE PER LE QUALI E' RICHIESTO UN CONTROLLO CHE NON RICADONO IN UN FERMO SISTEMA
			//CONSERVANDO UNO PRECEDENTE SE LO TROVA	
			onchangepresente = GetProperty(getObj('DataScadenza_V'), 'onchange');
			if (onchangepresente == null) {
				onchangepresente = '';
			}
			if (onchangepresente != '' && onchangepresente.indexOf(";", onchangepresente.length - 1) < 0) {
				onchangepresente = onchangepresente + ';';
			}
			onchangepresente = onchangepresente + 'onChangeCheckFermoSistema(this);';
			getObj('DataScadenza_V').setAttribute('onchange', onchangepresente);
			getObj('DataScadenza_HH_V').setAttribute('onchange', 'onChangeCheckFermoSistema(this);');
			getObj('DataScadenza_MM_V').setAttribute('onchange', 'onChangeCheckFermoSistema(this);');
		} catch (e) { }
	}

	//PER LE COMUNICAZIONI DI STIPULA CONTRATTO SE IL PARAMETRO LO RICHIEDE RENDO VISIBILE AREA DI FIRMA
	if (getObj('JumpCheck').value.indexOf('-RICHIESTA_STIPULA_CONTRATTO') >= 0) {
		try {
			if (getObj('VISUALIZZA_AREA_FIRMA').value == 'YES') {
				document.getElementById('DIV_FIRMA').className = "";
				FIRMA_OnLoad();
			}
		} catch (e) { }
	}

	//PER LE COMUNICAZIONI RICHIESTA FABBISOGNI CAMBIO CAPTION AL Destinatario METTENDO ENTE
	if (getObj('JumpCheck').value.indexOf('-FABBISOGNI_COMUNICAZIONE_GENERICA') >= 0) {
		try {
			getObj('cap_Destinatario_Azi').innerHTML = CNV(pathRoot, 'ente destinatario');
		} catch (e) { }
	}


}

function MyMakeDocFrom() {
	if (getObj('Versione').value != '') {
		MakeDocFrom(getObj('Versione').value + '##PDA_COMUNICAZIONE_GARA');
	}
	else {
		MakeDocFrom('PDA_COMUNICAZIONE_RISP##PDA_COMUNICAZIONE_GARA');
	}


}

function MyShowDocumentFromAttrib() {
	if (getObj('Versione').value != '') {
		ShowDocumentFromAttrib(getObj('Versione').value + ',NumeroDocumento');
	}
	else {
		ShowDocumentFromAttrib('PDA_COMUNICAZIONE_RISP,NumeroDocumento');
	}


}


function GestioneRichiestaRisposta() {
	try {
		//if ( getObj( 'JumpCheck' ).value.indexOf( '-BANDO_CONSULTAZIONE_COMUNICAZIONE_RISPOSTA' ) >= 0 )
		if (getObjValue('RichiestaRisposta') == 'si')
			$("#cap_DataScadenza").parents("table:first").css({ "display": "" });
		else
			$("#cap_DataScadenza").parents("table:first").css({ "display": "none" });

	} catch (e) { };

}
function MyExecDocProcess(param) {
	//alert(param);
	var str = getObj('JumpCheck').value;

	var arr = str.split('-');
	var ammetterisposta = arr[0];
	if (ammetterisposta == '1' && getObjValue('RichiestaRisposta') == 'si') {
		try {
			if (getObjValue('DataScadenza') == '') {
				DMessageBox('../', 'Compilare il campo Rispondere Entro il', 'Attenzione', 1, 400, 300);
				return -1;
			}

			if (getObjValue('DataScadenza') != '') {
				if (CheckDataOrarioOK('DataScadenza', 'Indicare un orario per il campo "Rispondere Entro il" diverso da zero') == -1) return -1;
			}


		} catch (e) { }
	}

	ExecDocProcess(param);

}

function CheckDataOrarioOK(FieldData, msgVuoto) {
	var ORE = 0;
	try {
		var ORARIO = getObjValue(FieldData).split('T')[1];
		var ORE = ORARIO.split(':')[0];
	}
	catch (e) { }

	if (ORE > 0) {
		return 0;
	}
	else {

		try {
			getObj(FieldData + '_V').focus();
		} catch (e) { };
		DMessageBox('../', msgVuoto, 'Attenzione', 1, 400, 300);
		return -1;
	}




}

function onChangeCheckFermoSistema(obj) {



	//INVOCAZIONE SU ONCHANGE DEL CAMPO
	try {
		if (obj.name != '' && obj.name != null) {

			var NameControlloData = obj.id;

			NameControlloData = NameControlloData.replace('_HH_V', '_V');
			NameControlloData = NameControlloData.replace('_MM_V', '_V');
			var objFieldData = getObj(NameControlloData);
			//SOLO SE DATA E ORA E MIN SONO VALORIZZATI FACCIO IL CONTROLLO DEL FERMO SISTEMA ALTRIMENTI LO FARA' IL PROCESSO DI INVIO
			//SE LO AVREI FATTO SOLO CON LA DATA RISCHIAMO DI NON CONSENTIRE AGLI UTENTI DI METTERE UN ORARIO OLTRE IL FERMO SISTEMA
			NameControlloORA = NameControlloData.replace('_V', '_HH_V');
			NameControlloMIN = NameControlloData.replace('_V', '_MM_V');
			if (getObj(NameControlloData).value != '' && getObj(NameControlloORA).value != '' && getObj(NameControlloMIN).value != '') {
				Get_CheckFermoSistema('../../', objFieldData);

			}

		}

	} catch (e) { }
}


function GeneraPDF() {
	//FACCIO FARE UN PROCESSO PER SALVARE IL CONTENUTO DEL TESTO COMUNICAZIONE,ALTRIMENTI FALLISCONO I CONTROLLI ESSENDO UN CAMPO RTE
	ExecDocProcess('FITTIZIO,DOCUMENT,,NO_MSG'); //FITTIZIO per salvare 	
}

function GeneraPDF_OK() {
	var value2 = controlli('');
	if (value2 == -1)
		return;

	scroll(0, 0);
	PrintPdfSign('URL=/report/prn_' + getObj('TYPEDOC').value + '.ASP?SIGN=YES&PROCESS=&VIEW_FOOTER_HEADER=PDA_COMUNICAZIONE_GARA_RICHIESTA_STIPULA_CONTRATTO_HF_Stampe');

}

function afterProcess(param) {
	if (param == 'FITTIZIO') {
		GeneraPDF_OK();
	}
}

function controlli(param) {

	//-- effettuare tutti i controlli	

	//-- controllo i dati della richiesta
	var i = 0;
	var err = 0;



	try {
		if (trim(getObjValue('Note')) == '' || trim(getObjValue('Note')) == '<br>') {
			err = 1;
			//TxtErr( LstAttrib[i] );
		}
	}
	catch (e) {
		alert(' Err Testo Comunicazione');
	}




	if (err > 0) {

		DMessageBox('../', 'Per proseguire e\' necessaria la compilazione del Testo della Comunicazione', 'Attenzione', 1, 400, 300);
		return -1;
	}

}





function FIRMA_OnLoad() {

	var Stato = '';
	Stato = getObjValue('StatoFunzionale');


	try {
		if ((getObjValue('SIGN_LOCK') == '0' || getObjValue('SIGN_LOCK') == '') && (Stato != 'Inviato' && Stato != 'InProtocollazione')) {
			document.getElementById('generapdf').disabled = false;
			document.getElementById('generapdf').className = "generapdf";
		}
		else {
			document.getElementById('generapdf').disabled = true;
			document.getElementById('generapdf').className = "generapdfdisabled";
		}

		if (getObjValue('SIGN_LOCK') != '0' && (Stato != 'Inviato' && Stato != 'InProtocollazione')) {
			document.getElementById('editistanza').disabled = false;
			document.getElementById('editistanza').className = "attachpdf";
		}
		else {
			document.getElementById('editistanza').disabled = true;
			document.getElementById('editistanza').className = "attachpdfdisabled";
		}


		if (getObjValue('SIGN_ATTACH') == '' && (Stato != 'Inviato' && Stato != 'InProtocollazione') && getObjValue('SIGN_LOCK') != '0') {
			document.getElementById('attachpdf').disabled = false;
			document.getElementById('attachpdf').className = "editistanza";
		}
		else {
			document.getElementById('attachpdf').disabled = true;
			document.getElementById('attachpdf').className = "editistanzadisabled";
		}


	} catch (e) { }



}

function trim(str) {
	return str.replace(/^\s+|\s+$/g, "");
}

function TogliFirma() {
	DMessageBox('../', 'Si sta per eliminare il file firmato.', 'Attenzione', 1, 400, 300);
	ExecDocProcess('SIGN_ERASE,FirmaDigitale');
}