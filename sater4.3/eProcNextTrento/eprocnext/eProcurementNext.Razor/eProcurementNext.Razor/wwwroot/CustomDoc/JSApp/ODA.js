window.onload = Init_ODA;

//Variabile di appoggio per contenere l'idpfu dell'utente collegato e gestire l'applicazione sia se accessibile sia no
var tmp_idpfuUtenteCollegato;

function Init_ODA() 
{

	 if ( typeof idpfuUtenteCollegato == 'undefined' )
		 tmp_idpfuUtenteCollegato = getObjValue('IdpfuInCharge');
	 else
		 tmp_idpfuUtenteCollegato = idpfuUtenteCollegato;
	 
	 
	AlertEsitoControlli()
	
    //inizializzo i campi GEO
    initAziEnte();

    //inizializzo il genera pdf
    Init_Firma_ODA();

	//inizializza la sezione prodotti
	DOCUMENTAZIONE_OnLoad();

	
	ExecDocCommandInMem('PRODOTTI#RELOAD', tmp_idpfuUtenteCollegato, 'CARRELLO_ME');
	
     //se il doc non è in lavorazione non posso cancellare articoli
     if (getObj('StatoFunzionale').value != 'InLavorazione')
         ShowCol('PRODOTTI', 'FNZ_DEL', 'none');
		
		
	 //se senza TipoScadenzaOrdinativo non è a duratafissata nasconde il campo numeromesi
    // if (getObj('TipoScadenzaOrdinativo').value != 'duratafissata') 
	//{
    //    $("#cap_NumeroMesi").parents("table:first").css({"display": "none"})
    //}
	
	/*
	 if (getObj('DOCUMENT_READONLY').value == '0' && getObj('StatoFunzionale').value == 'InLavorazione') 
	 {
		 var strNotEdit = getObjValue('NotEditable');

		 //Applico il filterdom solo se il campo cig_madre è editabile
		 if ( strNotEdit.indexOf(' CIG_MADRE ') < 0 )
		 {
			 var filter =  'SQL_WHERE= idHeader = \'' + getObj( 'Id_Convenzione' ).value +  '\' ';
			 FilterDom( 'CIG_MADRE' , 'CIG_MADRE' ,  getExtraAttrib( 'val_CIG_MADRE', 'value' ) , filter ,'', '');
		 }
		
		
	 }
	*/
	
	/* -- non serve la funzione di onchange è sul modello
	if (getObj('DOCUMENT_READONLY').value == '0' )
	{
		getObj( 'CIG' ).onchange = 	onChangeCigDerivato;
	}
	*/
	
}

function AlertEsitoControlli()
{
	//var imgEsito = '<img src="../images/Domain/State_ERR.gif"/>';
	var lblesitoControlli = document.getElementById('Cell_EsitoControlli')
	var esitocontrolli = document.getElementById('EsitoControlli_V')
	if (esitocontrolli.innerHTML != "" && esitocontrolli.innerHTML != "&nbsp;"){
		// lblesitoControlli.innerHTML = imgEsito + lblesitoControlli.innerHTML
		lblesitoControlli.className = 'Evidenzia_Bordo_Cella'
	}
}


function ChangeTotale() 
{
    var totale = 0;
	var totaleIva = 0;
	
	var docTotale = document.getElementById('TotaleEroso')
	var docTotale_V = document.getElementById('TotaleEroso_V')
	var docTotaleIva = document.getElementById('TotalIva')
	var docTotaleIva_V = document.getElementById('TotalIva_V')
	var docIva = document.getElementById('ValoreIva')
	var docIva_V = document.getElementById('ValoreIva_V')
	
	var numrow = GetProperty( getObj('PRODOTTIGrid') , 'numrow');
	 for( i = 0 ; i <= numrow ; i++ )
	 {
		 var quantita = document.getElementById('R'+ i +'_Quantita').value;
		 var importo = document.getElementById('R'+ i +'_PREZZO_OFFERTO_PER_UM').value;
		 var iva = document.getElementById('R'+ i +'_AliquotaIva').value;
		 
		 totale = totale + (importo * quantita);
		 totaleIva = totaleIva + ((importo * quantita) + ((importo * quantita) * (iva / 100) ));
		 
		 //imposto il nuovo totalòe sulla tabella
		 var tblTotale = document.getElementById('R'+ i +'_ValoreEconomico')
		 var tblTotale_V = document.getElementById('R'+ i +'_ValoreEconomico_V')
		 var tblTotaleIva = document.getElementById('R'+ i +'_VALORE_COMPLESSIVO_OFFERTA')
		 var tblTotaleIva_V = document.getElementById('R'+ i +'_VALORE_COMPLESSIVO_OFFERTA_V')
		 
		 tblTotale.value = (importo * quantita).toFixed(2);
		 tblTotale_V.innerHTML = (importo * quantita).toFixed(2);
		 tblTotaleIva.value = ((importo * quantita) + ((importo * quantita) * (iva / 100) )).toFixed(2);
		 tblTotaleIva_V.innerHTML = ((importo * quantita) + ((importo * quantita) * (iva / 100) )).toFixed(2);
	 }	 
	 
	 docTotale_V.innerHTML = totale.toFixed(2); 
	 docTotale.value = totale.toFixed(2);
	 docTotaleIva_V.innerHTML = totaleIva.toFixed(2);
	 docTotaleIva.value = totaleIva.toFixed(2);
	 docIva_V.innerHTML = (totaleIva - totale).toFixed(2);
	 docIva.value = (totaleIva - totale).toFixed(2);
}

function GeneraPDF() 
{

    //Controllo che ho inserito Titolo,Gic derivato e descrizione
    var TitoloValue = getObjValue('Titolo');

    if (TitoloValue == '') {
        getObj('Titolo').focus();
        DMessageBox('../', 'Per procedere si richiede l\'inserimento del Nome Ordine', 'Attenzione', 1, 400, 300);
        return;

    }

    var CIGValue = getObjValue('CIG');
	var ObbligoCigDerivato = getObjValue('Obbligo_Cig_Derivato');
	

	if (CIGValue == '') {
		
		if ( ObbligoCigDerivato != 'no' )
		{
			if ( getObjValue( 'RichiestaCigSimog' ) == 'si' )
			{
				DMessageBox('../', 'Attenzione, occorre procedere la richiesta del Cig sul SIMOG', 'Attenzione', 1, 400, 300);

			}
			else
			{
				getObj('CIG').focus();
				DMessageBox('../', 'Per procedere si richiede l\'inserimento del CIG', 'Attenzione', 1, 400, 300);
			}
			return;
		}
		else
		{
			if ( getObjValue( 'Motivazione_ObbligoCigDerivato' ) == '' )
			{
				getObj('Motivazione_ObbligoCigDerivato').focus();
				DMessageBox('../', 'Per Obbligo Cig = no occorre procedere con l\'inserimento della Motivazione esclusione CIG', 'Attenzione', 1, 400, 300);
				return;
			}
		}
	}

    var NoteValue = getObjValue('Note');
    if (NoteValue == '') {
        getObj('Note').focus();
        DMessageBox('../', 'Per procedere si richiede l\'inserimento della Descrizione Ordine', 'Attenzione', 1, 400, 300);
        return;

    }

    //-- verifico la presenza degli articoli
    var numeroRigheProdotti = GetProperty(getObj('PRODOTTIGrid'), 'numrow');
    if (numeroRigheProdotti == '-1') {
        DMessageBox('../', 'Per procedere si richiede l\'inserimento degli articoli', 'Attenzione', 1, 400, 300);
        return;
    }

    //-- verifico la presenza degli allegati obbligatoria
    if (VerificaAllegati() == '1') {
        DMessageBox('../', 'Per procedere si richiede l\'inserimento degli allegati', 'Attenzione', 1, 400, 300);
        return;
    }

    PrintPdfSign('TABLE_SIGN=CTL_DOC&URL=/report/prn_ODA.ASP?SIGN=YES&PDF_NAME=Ordine di acquisto&PROCESS=ODA%40%40%40CAN_GENERA_PDF:-1:CHECKOBBLIG');
	
	
}

function impostaLocalita(cod, fieldname) 
{
    ajax = GetXMLHttpRequest();

    var comuneTec;
    var provinciaTec;
    var statoTec;
    var comuneDesc;
    var provinciaDesc;
    var statoDesc;
    var provinciaText;
    var statoText;
    var comuneText;

    if (fieldname == 'consegna') {
        comuneTec = 'ReferenteLocalita2';
        comuneText = 'ReferenteLocalita_V';
        provinciaTec = 'ReferenteProvincia2';
        provinciaText = 'ReferenteProvincia_V';
        statoTec = 'ReferenteStato2';
        statoText = 'ReferenteStato_V';
        comuneDesc = 'ReferenteLocalita';
        provinciaDesc = 'ReferenteProvincia';
        statoDesc = 'ReferenteStato';
        geo = 'apriGEO';
    }

    if (fieldname == 'fatturazione') {
        comuneTec = 'FatturazioneLocalita2';
        comuneText = 'FatturazioneLocalita_V';
        provinciaTec = 'FatturazioneProvincia2';
        provinciaText = 'FatturazioneProvincia_V';
        statoTec = 'FatturazioneStato2';
        statoText = 'FatturazioneStato_V';
        comuneDesc = 'FatturazioneLocalita';
        provinciaDesc = 'FatturazioneProvincia';
        statoDesc = 'FatturazioneStato';
        geo = 'apriGEO2';
    }


    if (ajax) {
        ajax.open("GET", '../../ctl_library/functions/infoNodoGeo.asp?fldname=localita&cod=' + escape(cod), false);
        //output nella forma : COD-COMUNE#@#DESC-COMUNE#@#COD-PROVINCIA#@#DESC-PROVINCIA#@#COD-STATO#@#DESC-STATO
        ajax.send(null);

        if (ajax.readyState == 4) {
            //Se non ci sono stati errori di runtime
            if (ajax.status == 200) {
                if (ajax.responseText != '') {
                     var res = ajax.responseText;

                     //Se l'esito della chiamata è stato positivo
                    if (res.substring(0, 2) == '1#') {
                        try {
                            var vet = res.substring(4).split('#@#');

                            var codLoc;
                            var descLoc;
                            var codProv;
                            var descProv;
							var codStato;
                            var descStato;

                            codLoc = vet[0];
                            descLoc = vet[1];
                            codProv = vet[2];
                            descProv = vet[3];
                            codStato = vet[4];
                            descStato = vet[5];

                            getObj(comuneTec).value = codLoc;
                            getObj(comuneDesc).value = descLoc;
                            getObj(comuneText).innerHTML = descLoc;

                            if (codLoc == '' || codLoc.substring(codLoc.length - 3, codLoc.length) == 'XXX')
								disableGeoField(comuneDesc, false);
                            else
								disableGeoField(comuneDesc, true);

                            getObj(provinciaTec).value = codProv;
                            getObj(provinciaText).innerHTML = descProv;
                            getObj(provinciaDesc).value = descProv;

                            if (codProv == '' || codProv.substring(codProv.length - 3, codProv.length) == 'XXX')
								disableGeoField(provinciaDesc, false);
                            else
								disableGeoField(provinciaDesc, true);

                            getObj(statoTec).value = codStato;
							getObj(statoDesc).value = descStato;
							getObj(statoText).innerHTML = descStato;

                            if (codStato == '' || codStato.substring(codStato.length - 3, codStato.length) == 'XXX')
								disableGeoField(statoDesc, false);
                            else
								disableGeoField(statoDesc, true);

                        } catch (e) {
                            alert('Errore:' + e.message);

                        }
                    } else {
                        alert('errore.msg:' + res.substring(2));
                        enableDisableAziGeo(comuneDesc, provinciaDesc, statoDesc, geo, false);
                    }
                }
            } else {
                alert('errore.status:' + ajax.status);
                enableDisableAziGeo(comuneDesc, provinciaDesc, statoDesc, geo, false);

            }
        } else {
            alert('errore in impostaLocalita');
            enableDisableAziGeo(comuneDesc, provinciaDesc, statoDesc, geo, false);
        }
    }
}
	
function TogliFirma()
 {
    DMessageBox( '../' , 'Si sta per eliminare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );	
    if (confirm(CNV('../../', 'Si sta per eliminare il file firmato.')))
		
        ExecDocProcess('ODC_SIGN_ERASE,FIRMA');
}

function MyDeleteArticolo(objGrid, Row, c) 
{
    //setto statoriga a deleted sulla riga
    // getObj('R' + Row + '_StatoRiga').value = 'deleted';
    // ExecDocProcess('ELIMINARIGA,ODA');
	DettagliDel(objGrid, Row, c)
	ChangeTotale()
}

function Init_Firma_ODA() 
{
    var JumpCheck = '';
    var StatoFunzionale = '';

    StatoFunzionale = getObjValue('StatoFunzionale');
    JumpCheck = getObj('JumpCheck').value;
	
	if ( idpfuUtenteCollegato == undefined )
		var idpfuUtenteCollegato = getObjValue('IdpfuInCharge');

   // if (getObj('RichiediFirmaOrdine').value == '1') {

         if ((getObjValue('SIGN_LOCK') == '0' || getObjValue('SIGN_LOCK') == '') && (StatoFunzionale == 'InLavorazione' || StatoFunzionale == 'InApprove') && getObj('IdpfuInCharge').value == tmp_idpfuUtenteCollegato) {
             document.getElementById('generapdf').disabled = false;
             document.getElementById('generapdf').className = "generapdf";
         } else {
             document.getElementById('generapdf').disabled = true;
             document.getElementById('generapdf').className = "generapdfdisabled";
         }

         if (getObjValue('SIGN_LOCK') != '0' && (StatoFunzionale == 'InLavorazione' || StatoFunzionale == 'InApprove') && getObj('IdpfuInCharge').value == tmp_idpfuUtenteCollegato) {
             document.getElementById('editistanza').disabled = false;
             document.getElementById('editistanza').className = "attachpdf";
         } else {
             document.getElementById('editistanza').disabled = true;
             document.getElementById('editistanza').className = "attachpdfdisabled";
         }

         if (getObjValue('SIGN_ATTACH') == '' && (StatoFunzionale == 'InLavorazione' || StatoFunzionale == 'InApprove') && getObjValue('SIGN_LOCK') != '0' && getObj('IdpfuInCharge').value == tmp_idpfuUtenteCollegato) {
             document.getElementById('attachpdf').disabled = false;
             document.getElementById('attachpdf').className = "editistanza";
         } else {
             document.getElementById('attachpdf').disabled = true;
             document.getElementById('attachpdf').className = "editistanzadisabled";
         }
     // } else {

         // getObj('DIV_FIRMA').style.display = 'none';

     // }

}

function initAziEnte() 
{
    enableDisableAziGeo('ReferenteLocalita', 'ReferenteProvincia', 'ReferenteStato', 'apriGEO', true);
    enableDisableAziGeo('FatturazioneLocalita', 'FatturazioneProvincia', 'FatturazioneStato', 'apriGEO2', true);
}


function Doc_DettagliDel(grid, r, c) 
{
     var v = '0';
     try {
         v = getObj('RDOCUMENTAZIONEGrid_' + r + '_Obbligatorio').value;
     } catch (e) {};

     if (v == '1') {
         //DMessageBox( '../' , 'La documentazione è obbligatoria' , 'Attenzione' , 1 , 400 , 300 );
     } else {
         DettagliDel(grid, r, c);
     }
 }

function DOCUMENTAZIONE_OnLoad() {
     DOCUMENTAZIONE_AFTER_COMMAND();
}

function DOCUMENTAZIONE_AFTER_COMMAND() {
    HideCestinodoc();
    FormatAllegato();
}

function HideCestinodoc() 
{
    try {
         var i = 0;

         if (getObj('DOCUMENT_READONLY').value == '0') {
             for (i = 0; i < DOCUMENTAZIONEGrid_EndRow + 1; i++) {
                 if (getObj('RDOCUMENTAZIONEGrid_' + i + '_Obbligatorio').value == '1') {
                     getObj('DOCUMENTAZIONEGrid_r' + i + '_c0').innerHTML = '&nbsp;';
                 }
             }
         }
     } catch (e) {}

}

// //funzione per inserire nella sezione documentazione i tipi allegati consentiti scelti in creazione del BANDO
function FormatAllegato() 
{

     var numDocu = GetProperty(getObj('DOCUMENTAZIONEGrid'), 'numrow');
     var tipofile;
     var richiestaFirma;
     var onclick;
     var obj;

     for (i = 0; i <= numDocu; i++) {
         try {

             tipofile = getObj('RDOCUMENTAZIONEGrid_' + i + '_TipoFile').value;

             try {
                 richiestaFirma = getObj('RDOCUMENTAZIONEGrid_' + i + '_RichiediFirma').value;
             } catch (e) {
                 richiestaFirma = '';
             }

             tipofile = ReplaceExtended(tipofile, '###', ',');
             tipofile = 'INTEXT:' + tipofile.substring(1, tipofile.length);
             tipofile = tipofile.substring(0, tipofile.length - 1) + '-';
             tipofile = 'FORMAT=' + tipofile;

             if (richiestaFirma == '1') {
                 tipofile = tipofile + 'VB'; //format per forzare la verifica di firma bloccante in caso di mancata firma o file corrotto
             }

             obj = getObj('RDOCUMENTAZIONEGrid_' + i + '_Allegato_V_BTN').parentElement;
             onclick = obj.innerHTML;
             onclick = onclick.replace('FORMAT=INT', tipofile);
             obj.innerHTML = onclick;

         } catch (e) {}
     }

}

function VerificaAllegati() {
     var err = 0;
     //controllo la prensenza di allegati nella sezione della documentazione
     var numeroRigheDOC = GetProperty(getObj('DOCUMENTAZIONEGrid'), 'numrow');

     for (i = 0; i <= numeroRigheDOC; i++) {
         try {

             if (getObjValue('RDOCUMENTAZIONEGrid_' + i + '_Allegato') == '') {
                 err = 1;
             }


         } catch (e) {}
     }
     return err;
}

function RefreshContent()
{
	if ( isSingleWin() == false )
	{
		// ExecDocProcess( 'FITTIZIO,DOCUMENT,,NO_MSG');
	}
}


function ChangePO()
{
	// ExecDocProcess( 'CHANGEPO,ODC,,NO_MSG');	
}

function onChangeRichiestaSimog()
{
	var docRichiestaCig;
	var RichiestaCigSimog;
	
	if ( getObj('docRichiestaCig') )
	{
		docRichiestaCig = getObjValue('docRichiestaCig');
		RichiestaCigSimog = getObjValue('RichiestaCigSimog');
		
		/* SE E' PRESENTE UN DOCUMENTO DI RICHIESTA CIG E SI STA PASSANDO ALLA SCELTA DI NON AVERE L'INTEGRAZIONE CON IL SIMOG */
		if ( docRichiestaCig == '1' && RichiestaCigSimog == 'no' )
		{
			//Setto preventivamente il valore al suo precedente per evitare che se l'utente clicca sulla 'X' della finestra modale 
			//riesca a cambiare la scelta senza attivare il processo di onChange
			getObj('RichiestaCigSimog').value = 'si';
			
			var ml_text = 'Cambiando questa scelta verranno annullate tutte le richieste SIMOG effettuate su ODC. Proseguire ?';
			var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ml_text ) +'&CAPTION=Informazione&ICO=1';
			
			ExecFunctionModaleConfirm( page, null , 200 , 420 , null , 'confermaCambioRichiestaSimog' );
		}
		else
		{
			if ( RichiestaCigSimog == 'no' )
			{
				ExecDocProcess('CAMBIA_RICHIESTA_SIMOG_NO,SIMOG');				
			}
			else
			{		
				var cig = document.getElementById('CIG');
				cig.value = "";		
				ExecDocProcess('CAMBIA_RICHIESTA_SIMOG_SI,SIMOG');		
				// var cig = document.getElementById('CIG');
				// cig.value = "";				
			}
		}
	}
}


function confermaCambioRichiestaSimog()
{
	//Ripristino la scelta dell'utente
	getObj('RichiestaCigSimog').value = 'no';
	
	ExecDocProcess('CAMBIA_RICHIESTA_SIMOG_NO,SIMOG');
	
}

function onChangeUserRUP(obj)
{
	//Salvataggio del documento
	//ExecDocProcess('CAMBIO_RUP,DOCUMENT');
	
	var RichiestaCigSimog = getObjValue('RichiestaCigSimog');
	var StrValueRup = getObj('idpfuRup').value;
	var ObjCigDerivato = getObj('CIG');
	
	//se valorizzato anche idpfurup (RUP) e richiesta cig simog = no allora innesco un processo che effettua 
	// verifica sincrona del CIG - RUP e se positiva conserva nella ctl_doc_value
    // CIG_VALIDO_SUL_SIMOG , CIG_CONTROLLATO, RUP_CONTROLLATO
	if ( RichiestaCigSimog == 'no' && StrValueRup != '' && ObjCigDerivato.value != '' && IsSmartCIg( ObjCigDerivato.value ) == 0 )
		ExecDocProcess('VERIFICA_CIG_DERIVATO_SIMOG,ODC,,NO_MSG');
	else
		ExecDocProcess('CAMBIO_RUP,DOCUMENT,,NO_MSG');
	
}
/*

function VerificaObbligoCigDerivato()
{
	
	var  bRet = true;
	
	var strKey_ML = '';
	
	//se il campo "Obbligo Cig Derivato" = si "Cig Derivato" obbligatorio
	if ( getObj('CIG').value == '' )
	{	

		if ( getObjValue( 'RichiestaCigSimog' ) == 'si' )
		{
			strKey_ML = 'Attenzione, occorre procedere con la richiesta del Cig sul SIMOG', 'Attenzione';
		
		}
		else
		{

			strKey_ML = 'Attenzione, valorizzare il campo Cig Derviato';
			getObj('CIG').focus();
		}
		bRet = false ;
	}
	
	
	
	if ( ! bRet )
	{	
		DMessageBox('../', strKey_ML , 'Errore', 2, 400, 300);
	}	
	
	return bRet;
	
	
	
}	

*/

function VerificaObbligoCigDerivato()
{
	
	var  bRet = true;
	
	var strKey_ML = '';
	
	//se il campo "Obbligo Cig Derivato" = si "Cig Derivato" obbligatorio
	if ( getObj('Obbligo_Cig_Derivato').value == 'si' && getObj('CIG').value == '' )
	{	

		if ( getObjValue( 'RichiestaCigSimog' ) == 'si' )
		{
			strKey_ML = 'Attenzione, occorre procedere con la richiesta del Cig sul SIMOG';
		
		}
		else
		{

			strKey_ML = 'Attenzione, Se Obbligo Cig = si valorizzare il campo Cig';
			getObj('CIG').focus();
		}
		bRet = false ;
	}
	
	
	//se il campo "Obbligo Cig Derivato" = no "Motivazione" obbligatorio
	if ( getObj('Obbligo_Cig_Derivato').value == 'no' && getObj('Motivazione_ObbligoCigDerivato').value == '' )
	{	
		strKey_ML = 'Attenzione, Se Obbligo Cig = no valorizzare il campo Motivazione';
		getObj('Motivazione_ObbligoCigDerivato').focus();
		bRet = false ;
	}
	
	
	if ( ! bRet )
	{	
		DMessageBox('../', strKey_ML , 'Errore', 2, 400, 300);
	}	
	
	return bRet;
	
	
}

function onChangeObbligoCigDerivato()
{
	var docRichiestaCig;
	var RichiestaCigSimog;
	var ObbligoCigDerivato ;
	
	docRichiestaCig = getObjValue('docRichiestaCig');
	
	ObbligoCigDerivato = getObj('Obbligo_Cig_Derivato').value;
	
	RichiestaCigSimog = getObjValue('RichiestaCigSimog');
	
	
	//alert(docRichiestaCig);
	/* SE STO SETTANDO Obbligo_Cig_Derivato A NO e RichiestaCigSimog vale SI 
	   SE E' PRESENTE UN DOCUMENTO DI RICHIESTA CIG ALLORA CHIEDO CONFERMA PRIMA DI PROCEDERE
	   SE L'UTENTE CONFERMA VADO AD ANNULLARE EVENTUALI RICHIESTE CIG INVIATE 	
	*/
	if ( ObbligoCigDerivato == 'no' && docRichiestaCig == '1' && RichiestaCigSimog == 'si' )
	{
		
		getObj('Obbligo_Cig_Derivato').value = 'si';
		
		var ml_text = 'Cambiando questa scelta verranno annullate tutte le richieste SIMOG effettuate su ODC. Proseguire ?';
		var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ml_text ) +'&CAPTION=Informazione&ICO=1';
		
		ExecFunctionModaleConfirm( page, null , 200 , 420 , null , 'confermaCambioObbligoCigDerivato' );
	}
	else
	{
		ExecDocProcess('CHANGE_OBBLIGO_CIG_DERIVATO,ODC,,NO_MSG' );
	}
		
	
	
	
}



function confermaCambioObbligoCigDerivato()
{
	
	getObj('Obbligo_Cig_Derivato').value = 'no';
	
	ExecDocProcess('CHANGE_OBBLIGO_CIG_DERIVATO,ODC');
	
}




function onChangeCigDerivato()
{
	var RichiestaCigSimog = getObjValue('RichiestaCigSimog');
	var ObjCigDerivato = getObj('CIG');
	var StrValueRup = getObj('idpfuRup').value;
	
	
	if ( validateExtCig( ObjCigDerivato , false ) ) 
	{
	  //se non si tratta di uno SMART CIG
	  if ( IsSmartCIg( ObjCigDerivato.value ) == 0 )
	  {
		  //se valorizzato anche idpfurup (RUP) e richiesta cig simog = no allora innesco un processo che effettua 
		  // verifica sincrona del CIG - RUP e se positiva conserva nella ctl_doc_value
		  // CIG_VALIDO_SUL_SIMOG , CIG_CONTROLLATO, RUP_CONTROLLATO
		  if ( RichiestaCigSimog == 'no' && StrValueRup != ''  )
			  ExecDocProcess('VERIFICA_CIG_DERIVATO_SIMOG,ODC,,NO_MSG');
	  
	 }
	}
	else
	{
		DMessageBox( '../ctl_library/' , 'Valore CIG non ammesso' , 'Attenzione' , 2 , 400 , 300 );
	}

}


function afterProcess(param)
{
	//se stato eseguito iol processo VERIFICA_CIG_DERIVATO_SIMOG vado ad eseguire quello per completarlo
	if ( param == 'VERIFICA_CIG_DERIVATO_SIMOG')
		ExecDocProcess('AFTER_VERIFICA_CIG_DERIVATO_SIMOG,ODC,,NO_MSG');
}



function MySend(param) {
	try 
	{
		
		if ( VerificaObbligoCigDerivato() )
		{	
		
			try {
				if (verifyCap('ReferenteLocalita2', getObj('ReferenteCap')) && verifyCap('FatturazioneLocalita2', getObj('FatturazioneCap'))) {
					ExecDocProcess(param);
				}
			} catch (e) 
			{
				ExecDocProcess(param);
			}
		
		}
	} catch (e) 
	{
		ExecDocProcess(param);
	}
}
