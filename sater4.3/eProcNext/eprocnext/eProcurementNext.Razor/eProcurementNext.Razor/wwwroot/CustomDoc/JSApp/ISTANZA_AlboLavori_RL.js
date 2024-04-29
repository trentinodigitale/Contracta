var LstAttrib = [

    'NomeRapLeg',
    'CognomeRapLeg',
    'StatoRapLeg',
    'LocalitaRapLeg',
    'ProvinciaRapLeg',
    'DataRapLeg',
    'CFRapLeg',
    'TelefonoRapLeg',
    'CellulareRapLeg',
    'ResidenzaRapLeg',
    'StatoResidenzaRapLeg',
    'ProvResidenzaRapLeg',
    'IndResidenzaRapLeg',
    'CapResidenzaRapLeg',
    // 'RuoloRapLeg',
    'RagSoc',
    'NaGi',
    'STATOLOCALITALEG',
    'INDIRIZZOLEG',
    'LOCALITALEG',
    'CAPLEG',
    'PROVINCIALEG',
    'NUMTEL',
    //'NUMFAX',
    'codicefiscale',
    //'CittaEntrate',
    //'SettoriCCNL',
    //'EmailRapLeg',
    'EMAIL',
    'GerarchicoSOA'
    //'PIVA',
];

window.onload = DISPLAY_FIRMA_OnLoad;

var NumControlli = LstAttrib.length;

function trim(str) {
    return str.replace(/^\s+|\s+$/g, "");
}

function InvioIstanza(param) {
    if (getObjValue('RichiestaFirma') == 'no') {
        var value = controlli(param);

        if (value == -1)
            return;

        ExecDocProcess('PRE_SEND,ISTANZA_AlboOperaEco');
    }

    if (getObjValue('Attach') == "" && getObjValue('RichiestaFirma') != 'no') {
        DMessageBox('../', 'Prima di Inviare il documento allegare il file firmato.', 'Attenzione', 1, 400, 300);
        return;
    }
    if (getObjValue('Attach') != "") {
        ExecDocProcess('PRE_SEND,ISTANZA_AlboOperaEco');
    }
}

function GeneraPDF() {
    var value2 = controlli('');
    if (value2 == -1)
        return;
    Stato = getObjValue('StatoDoc');

    if (Stato == '') {
        alert('Per effettuare il \"Genera PDF\" si richiede prima un salvataggio. Verra\' effettuato in automatico, successivamente effettuare nuovamente il comando di \"Genera PDF\"');
        MySaveDoc();
        return;
    }

    scroll(0, 0);

    PrintPdfSign('URL=/report/prn_' + getObj('TYPEDOC').value + '.ASP?SIGN=YES&PROCESS=ISTANZA@@@VERIFICHE_PRE_PDF');

}


function TogliFirma() {
    //DMessageBox( '../' , 'Si sta per eliminare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );
    if (confirm(CNV('../', 'Si sta per eliminare il file firmato.Vuoi procedere'))) {
        ExecDocProcess('SIGN_ERASE,FirmaDigitale');
    }


}

function SetInitField() {

    var i = 0;
    for (i = 0; i < NumControlli; i++) {
        TxtOK(LstAttrib[i]);
    }




}
function TxtErr(field) {

    if (field != 'DichiaraTipoImpresa') {
        try { getObj(field).style.backgroundColor = '#FFBE7D'; } catch (e) { }; // F80
        //try{ getObj( field  ).style.borderColor='#F00'; }catch(e){};

        try { getObj(field + '_V').style.backgroundColor = '#FFBE7D'; } catch (e) { }; //FFC
        //try{ getObj( field  + '_V' ).style.borderColor='#F00'; }catch(e){};


        try { getObj(field + '_edit').style.backgroundColor = '#FFBE7D'; } catch (e) { };
        try { getObj(field + '_edit').style.backgroundColor = '#FFBE7D'; } catch (e) { };
        //try{ getObj( field  + '_edit1' ).style.borderColor='#F00'; }catch(e){};
        try { getObj(field + '_edit_new').style.borderColor = '#FFBE7D'; } catch (e) { };
        try { getObj(field + '_edit_new').style.backgroundColor = '#FFBE7D'; } catch (e) { };

        if (getObj(field).type == 'checkbox') {
            try { getObj(field).offsetParent.style.backgroundColor = '#FFBE7D'; } catch (e) { };
            //try{ getObj( field  ).offsetParent.style.borderColor='#F00'; }catch(e){};

        }
    }
    else {
        try { getObj(field)[0].offsetParent.style.backgroundColor = '#FFBE7D'; } catch (e) { };
        try { getObj(field)[1].offsetParent.style.backgroundColor = '#FFBE7D'; } catch (e) { };
        try { getObj(field)[2].offsetParent.style.backgroundColor = '#FFBE7D'; } catch (e) { };

    }


}

function TxtOK(field) {
    if (field != 'DichiaraTipoImpresa') {

        try { getObj(field).style.backgroundColor = '#FFF'; } catch (e) { };
        //try{ getObj( field  ).style.borderColor='lightgrey'; }catch(e){};

        try { getObj(field + '_V').style.backgroundColor = '#FFF'; } catch (e) { };
        //try{ getObj( field  + '_V' ).style.borderColor='lightgrey'; }catch(e){};

        try { getObj(field + '_edit').style.backgroundColor = '#FFF'; } catch (e) { };
        //try{ getObj( field  + '_edit1' ).style.borderColor='lightgrey'; }catch(e){};
        try { getObj(field + '_edit_new').style.borderColor = '#FFF'; } catch (e) { };
        try { getObj(field + '_edit_new').style.backgroundColor = '#FFF'; } catch (e) { };

        try {
            if (getObj(field).type == 'checkbox') {
                //try{ getObj( field  ).offsetParent.style.borderColor='#FFF'; }catch(e){};
                try { getObj(field).offsetParent.style.backgroundColor = '#F4F4F4'; } catch (e) { };
            }
        } catch (e) { alert(field); }

    }
    else {
        try { getObj(field)[0].offsetParent.style.backgroundColor = '#FFF'; } catch (e) { };
        try { getObj(field)[1].offsetParent.style.backgroundColor = '#FFF'; } catch (e) { };
        try { getObj(field)[2].offsetParent.style.backgroundColor = '#FFF'; } catch (e) { };
    }
}


function OnChangeBelongCCIAA(obj) {
    try {
        if (getObjValue('BelongCCIAA') == 'NO') {
            document.getElementById('BelongCCIAADIV').style.display = "none";
        }
        if (getObjValue('BelongCCIAA') == 'SI') {
            document.getElementById('BelongCCIAADIV').style.display = "";
        }
    } catch (e) {
        if (getObjValue('val_BelongCCIAA') == 'NO') {
            document.getElementById('BelongCCIAADIV').style.display = "none";
        }
        if (getObjValue('val_BelongCCIAA') == 'SI') {
            document.getElementById('BelongCCIAADIV').style.display = "";
        }
    }



}
function CheckRadio10secondo(obj) {

    if (GetProperty(getObj('CESSATIGrid'), 'numrow') == -1)
        ExecDocCommand('CESSATI#AddNew#');
}

function IsNumeric2(sText) {
    var ValidChars = '0123456789.';
    var IsNumber = true;
    var Char;

    for (i = 0; i < sText.length && IsNumber == true; i++) {
        Char = sText.charAt(i);
        if (ValidChars.indexOf(Char) == -1) {
            IsNumber = false;
        }
    }
    return IsNumber;

}


function roundTo(X, decimalpositions) {
    var i = X * Math.pow(10, decimalpositions);
    i = Math.round(i);
    return i / Math.pow(10, decimalpositions);
}

function ControllaCF(cf) {
    var validi, i, s, set1, set2, setpari, setdisp;
    if (cf == '') return '';
    cf = cf.toUpperCase();
    if (cf.length != 16)
        return "La lunghezza del codice fiscale non e'\n"
            + "corretta: il codice fiscale dovrebbe essere lungo\n"
            + "esattamente 16 caratteri.";
    validi = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    for (i = 0; i < 16; i++) {
        if (validi.indexOf(cf.charAt(i)) == -1)
            return "Il codice fiscale contiene un carattere non valido \'" +
                cf.charAt(i) +
                "\'.\nI caratteri validi sono le lettere e le cifre.";
    }
    set1 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    set2 = "ABCDEFGHIJABCDEFGHIJKLMNOPQRSTUVWXYZ";
    setpari = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    setdisp = "BAKPLCQDREVOSFTGUHMINJWZYX";
    s = 0;
    for (i = 1; i <= 13; i += 2)
        s += setpari.indexOf(set2.charAt(set1.indexOf(cf.charAt(i))));
    for (i = 0; i <= 14; i += 2)
        s += setdisp.indexOf(set2.charAt(set1.indexOf(cf.charAt(i))));
    if (s % 26 != cf.charCodeAt(15) - 'A'.charCodeAt(0))
        return "Il codice fiscale non e\' corretto:\n" +
            "il codice di controllo non corrisponde.";
    return "";
}

function ControllaPIVA(pi) {
    if (pi == '') return '';
    if (pi.length != 11)
        return "La lunghezza della partita IVA non e\'\n" +
            "corretta: la partita IVA dovrebbe essere lunga\n" +
            "esattamente 11 caratteri.";
    validi = "0123456789";
    for (i = 0; i < 11; i++) {
        if (validi.indexOf(pi.charAt(i)) == -1)
            return "La partita IVA contiene un carattere non valido \'" +
                pi.charAt(i) + "'.\nI caratteri validi sono le cifre.";
    }
    s = 0;
    for (i = 0; i <= 9; i += 2)
        s += pi.charCodeAt(i) - '0'.charCodeAt(0);
    for (i = 1; i <= 9; i += 2) {
        c = 2 * (pi.charCodeAt(i) - '0'.charCodeAt(0));
        if (c > 9) c = c - 9;
        s += c;
    }
    if ((10 - s % 10) % 10 != pi.charCodeAt(10) - '0'.charCodeAt(0))
        return "La partita IVA non e\' valida:\n" +
            "il codice di controllo non corrisponde.";
    return '';
}


function LocalPrintPdf(param) {

    Stato = getObjValue('StatoDoc');
    param = '/report/prn_' + getObj('TYPEDOC').value + '.ASP?'
    if (Stato == '') {
        //alert( 'Per effettuare la stampa si richiede prima un salvataggio. Verra\' effettuato in automatico, successivamente effettuare nuovamente il comando di stampa');
        DMessageBox('../', 'Per effettuare la stampa si richiede prima un salvataggio. Verra\' effettuato in automatico, successivamente effettuare nuovamente il comando di stampa.', 'Attenzione', 1, 400, 300);


        MySaveDoc();
        return;
    }


    PrintPdf(param);

}
function DISPLAY_FIRMA_OnLoad() {


    HideCestinodoc();
    FormatAllegato();


    Stato = '';
    Stato = getObjValue('StatoDoc');

    if (getObjValue('RichiestaFirma') == 'no') {
        document.getElementById('DIV_FIRMA').style.display = "none";
    }



    if ((getObjValue('SIGN_LOCK') == '0' || getObjValue('SIGN_LOCK') == '') && (Stato == 'Saved' || Stato == "")) {
        document.getElementById('generapdf').disabled = false;
        document.getElementById('generapdf').className = "generapdf";
    }
    else {
        document.getElementById('generapdf').disabled = true;
        document.getElementById('generapdf').className = "generapdfdisabled";
    }


    if (getObjValue('SIGN_LOCK') != '0' && (Stato == 'Saved')) {
        document.getElementById('editistanza').disabled = false;
        document.getElementById('editistanza').className = "attachpdf";
    }
    else {
        document.getElementById('editistanza').disabled = true;
        document.getElementById('editistanza').className = "attachpdfdisabled";
    }
    if (getObjValue('SIGN_ATTACH') == '' && (Stato == 'Saved') && getObjValue('SIGN_LOCK') != '0') {
        document.getElementById('attachpdf').disabled = false;
        document.getElementById('attachpdf').className = "editistanza";
    }
    else {
        document.getElementById('attachpdf').disabled = true;
        document.getElementById('attachpdf').className = "editistanzadisabled";
    }

    if (getObjValue('PresenzaDGUE') != 'si') {
        document.getElementById('DIV_DGUE').style.display = "none";
    }

    if (getObjValue('PresenzaDGUE') == 'si') {
        document.getElementById('CompilaDGUE').disabled = false;
        document.getElementById('CompilaDGUE').className = "CompilaDGUE";
    }


    if (getObj('CheckIscritta1').checked == true) {
        TextreadOnly('SedeCCIAA', false);
        TextreadOnly('ANNOCOSTITUZIONE', false);
        TextreadOnly('IscrCCIAA', false);
    }
    else {
        getObj('SedeCCIAA').value = '';
        TextreadOnly('SedeCCIAA', true);
        getObj('ANNOCOSTITUZIONE').value = '';
        TextreadOnly('ANNOCOSTITUZIONE', true);
        getObj('IscrCCIAA').value = '';
        TextreadOnly('IscrCCIAA', true);
    }


}



function controlli(param) {

    var err = 0;
    var cod = getObj("IDDOC").value;


    var strRet = CNV('../', 'ok');



    SetInitField();


    //-- effettuare tutti i controlli



    //-- controllo i dati della richiesta
    var i = 0;
    var err = 0;

    for (i = 0; i < NumControlli; i++) {

        try {



            if (getObj(LstAttrib[i]).type == 'text' || getObj(LstAttrib[i]).type == 'hidden' || getObj(LstAttrib[i]).type == 'select-one' || getObj(LstAttrib[i]).type == 'textarea') {
                if (trim(getObjValue(LstAttrib[i])) == '') {
                    err = 1;
                    //alert(LstAttrib[i] );
                    TxtErr(LstAttrib[i]);
                }
            }

            if (getObj(LstAttrib[i]).type == 'checkbox') {
                if (getObj(LstAttrib[i]).checked == false) {
                    err = 1;
                    TxtErr(LstAttrib[i]);
                }
            }


        } catch (e) {
            alert(i + ' - ' + LstAttrib[i]);
        }

    }


    /*var NRPOSIZIONI_INPSGrid = GetProperty(getObj('POSIZIONI_INPSGrid'), 'numrow');
  
  
    if (Number(NRPOSIZIONI_INPSGrid) >= 0) {
  
      for (i = 0; i <= NRPOSIZIONI_INPSGrid; i++) {
        try {
          if (getObjValue('RPOSIZIONI_INPSGrid_' + i + '_NumINPS') == '') {
            err = 1;
            TxtErr('RPOSIZIONI_INPSGrid_' + i + '_NumINPS');
          }
          else {
  
            TxtOK('RPOSIZIONI_INPSGrid_' + i + '_NumINPS');
          }
  
          if (getObjValue('RPOSIZIONI_INPSGrid_' + i + '_SedeINPS') == '') {
            err = 1;
            TxtErr('RPOSIZIONI_INPSGrid_' + i + '_SedeINPS');
          }
          else {
  
            TxtOK('RPOSIZIONI_INPSGrid_' + i + '_SedeINPS');
          }
  
  
        } catch (e) { }
      }
    }*/




    /*var NRPOSIZIONI_INAILGrid = GetProperty(getObj('POSIZIONI_INAILGrid'), 'numrow');
  
  
    if (Number(NRPOSIZIONI_INAILGrid) >= 0) {
  
      for (i = 0; i <= NRPOSIZIONI_INAILGrid; i++) {
        try {
          if (getObjValue('RPOSIZIONI_INAILGrid_' + i + '_NumINAIL') == '') {
            err = 1;
            TxtErr('RPOSIZIONI_INAILGrid_' + i + '_NumINAIL');
          }
          else {
  
            TxtOK('RPOSIZIONI_INAILGrid_' + i + '_NumINAIL');
          }
  
          if (getObjValue('RPOSIZIONI_INAILGrid_' + i + '_SedeINAIL') == '') {
            err = 1;
            TxtErr('RPOSIZIONI_INAILGrid_' + i + '_SedeINAIL');
          }
          else {
  
            TxtOK('RPOSIZIONI_INAILGrid_' + i + '_SedeINAIL');
          }
  
  
        } catch (e) { }
      }
    }*/


    /*var NRPOSIZIONI_CASSAEDILEGrid = GetProperty(getObj('POSIZIONI_CASSAEDILEGrid'), 'numrow');
  
  
    if (Number(NRPOSIZIONI_CASSAEDILEGrid) >= 0) {
  
      for (i = 0; i <= NRPOSIZIONI_CASSAEDILEGrid; i++) {
        try {
          if (getObjValue('RPOSIZIONI_CASSAEDILEGrid_' + i + '_NumEdile') == '') {
            err = 1;
            TxtErr('RPOSIZIONI_CASSAEDILEGrid_' + i + '_NumEdile');
          }
          else {
  
            TxtOK('RPOSIZIONI_CASSAEDILEGrid_' + i + '_NumEdile');
          }
  
          if (getObjValue('RPOSIZIONI_CASSAEDILEGrid_' + i + '_SedeEdile') == '') {
            err = 1;
            TxtErr('RPOSIZIONI_CASSAEDILEGrid_' + i + '_SedeEdile');
          }
          else {
  
            TxtOK('RPOSIZIONI_CASSAEDILEGrid_' + i + '_SedeEdile');
          }
  
        } catch (e) { }
      }
    }*/


    /*var NRSEDI_OPERATIVEGrid = GetProperty(getObj('SEDI_OPERATIVEGrid'), 'numrow');
  
  
    if (Number(NRSEDI_OPERATIVEGrid) >= 0) {
  
      for (i = 0; i <= NRSEDI_OPERATIVEGrid; i++) {
        try {
          if (getObjValue('RSEDI_OPERATIVEGrid_' + i + '_provincia_OPERATIVA') == '') {
            err = 1;
            TxtErr('RSEDI_OPERATIVEGrid_' + i + '_provincia_OPERATIVA');
          }
          else {
  
            TxtOK('RSEDI_OPERATIVEGrid_' + i + '_provincia_OPERATIVA');
          }
  
  
  
        } catch (e) { }
      }
    }*/

    //almeno una tra CheckNOSOA e CheckSOSPSOA deve essere selezionata

    if (getObj('CheckSOSPSOA').checked == false && getObj('CheckNOSOA').checked == false) {
        err = 1;
        TxtErr('CheckSOSPSOA');
        TxtErr('CheckNOSOA');

    }
    else {
        TxtOK('CheckSOSPSOA');
        TxtOK('CheckNOSOA');
    }


    //punto b
    if (getObj('CheckIscritta1').checked == false && getObj('CheckIscritta3').checked == false) {
        err = 1;
        TxtErr('CheckIscritta1');
        TxtErr('CheckIscritta3');

    }
    else {
        TxtOK('CheckIscritta1');
        TxtOK('CheckIscritta3');
    }

    if (getObj('CheckIscritta1').checked == true) {

        if (getObj('Registro_Camera_Provincia_Artigianato').value == '') {
            err = 1;
            TxtErr('Registro_Camera_Provincia_Artigianato');
        }
        else {
            TxtOK('Registro_Camera_Provincia_Artigianato');
        }


        if (getObj('elenco_camera_attivita_artigianato').value == '') {
            err = 1;
            TxtErr('elenco_camera_attivita_artigianato');
        }
        else {
            TxtOK('elenco_camera_attivita_artigianato');
        }

        if (getObj('numero_iscrizione').value == '') {
            err = 1;
            TxtErr('numero_iscrizione');
        }
        else {
            TxtOK('numero_iscrizione');
        }

        if (getObj('data_iscrizione_V').value == '') {
            err = 1;
            TxtErr('data_iscrizione_V');
        }
        else {
            TxtOK('data_iscrizione_V');
        }

        if (getObj('sede_iscrizione').value == '') {
            err = 1;
            TxtErr('sede_iscrizione');
        }
        else {
            TxtOK('sede_iscrizione');
        }

    }

    //PUNTO G) controllo che per i SOGGETTI CheckSoggetti1 oppure CheckSoggetti2 selezionato
    if (getObj('CheckSoggetti1').checked == false && getObj('CheckSoggetti2').checked == false) {
        err = 1;
        TxtErr('CheckSoggetti1');
        TxtErr('CheckSoggetti2');
    }
    else {
        TxtOK('CheckSoggetti1');
        TxtOK('CheckSoggetti2');
    }

    //se selezionato il primo punto controllo che ho almeno una riga di SOGGETTI compilata
    if (getObj('CheckSoggetti1').checked == true) {

        var numSogg = Number(GetProperty(getObj('SOGGETTIGrid'), 'numrow'));
        if (numSogg >= 0) {

            var t = 0;
            for (t = 0; t < numSogg + 1; t++) {

                TxtOK('RSOGGETTIGrid_' + t + '_NomeDirTec');
                TxtOK('RSOGGETTIGrid_' + t + '_CognomeDirTec');
                TxtOK('RSOGGETTIGrid_' + t + '_LocalitaDirTec');
                TxtOK('RSOGGETTIGrid_' + t + '_DataDirTec');
                TxtOK('RSOGGETTIGrid_' + t + '_ResidenzaDirTec');
                TxtOK('RSOGGETTIGrid_' + t + '_CFDirTec');
                TxtOK('RSOGGETTIGrid_' + t + '_RuoloDirTec');

                if (getObj('RSOGGETTIGrid_' + t + '_NomeDirTec').value == '') {
                    err = 1;
                    TxtErr('RSOGGETTIGrid_' + t + '_NomeDirTec');
                }

                if (getObj('RSOGGETTIGrid_' + t + '_CognomeDirTec').value == '') {
                    err = 1;
                    TxtErr('RSOGGETTIGrid_' + t + '_CognomeDirTec');
                }

                if (getObj('RSOGGETTIGrid_' + t + '_LocalitaDirTec').value == '') {
                    err = 1;
                    TxtErr('RSOGGETTIGrid_' + t + '_LocalitaDirTec');
                }

                if (getObj('RSOGGETTIGrid_' + t + '_DataDirTec').value == '') {
                    err = 1;
                    TxtErr('RSOGGETTIGrid_' + t + '_DataDirTec_V');
                }

                if (getObj('RSOGGETTIGrid_' + t + '_ResidenzaDirTec').value == '') {
                    err = 1;
                    TxtErr('RSOGGETTIGrid_' + t + '_ResidenzaDirTec');
                }

                if (getObj('RSOGGETTIGrid_' + t + '_CFDirTec').value == '') {
                    err = 1;
                    TxtErr('RSOGGETTIGrid_' + t + '_CFDirTec');
                }

                if (getObj('RSOGGETTIGrid_' + t + '_RuoloDirTec').value == '') {
                    err = 1;
                    TxtErr('RSOGGETTIGrid_' + t + '_RuoloDirTec');
                }


            }
        }

    }

    //PUNTO M controllo che almeno una selezione è fatta ed i campi sono compilati con coerenza alla selezione
    if (getObj('check_art_94_d_1').checked == false && getObj('check_art_94_d_2').checked == false && getObj('check_art_94_d_3').checked == false && getObj('check_art_94_d_4').checked == false) {
        err = 1;
        TxtErr('check_art_94_d_1');
        TxtErr('check_art_94_d_2');
        TxtErr('check_art_94_d_3');
        TxtErr('check_art_94_d_4');
    }
    else {
        TxtOK('check_art_94_d_1');
        TxtOK('check_art_94_d_2');
        TxtOK('check_art_94_d_3');
        TxtOK('check_art_94_d_4');
    }

    //PUNTO M se selezionato opzione 2 controllo i campi associati
    if (getObj('check_art_94_d_2').checked == true) {
        TxtOK('tribunale_di');
        TxtOK('Provvedimento_Numero');
        TxtOK('data_proveddimento_V');

        if (getObj('tribunale_di').value == '') {
            err = 1;
            TxtErr('tribunale_di');
        }

        if (getObj('Provvedimento_Numero').value == '') {
            err = 1;
            TxtErr('Provvedimento_Numero');
        }

        if (getObj('data_proveddimento_V').value == '') {
            err = 1;
            TxtErr('data_proveddimento_V');
        }

    }

    //PUNTO M se selezionato opzione 3 controllo i campi associati
    if (getObj('check_art_94_d_3').checked == true) {
        TxtOK('tribunale_di_1');
        TxtOK('Provvedimento_Numero_1');
        TxtOK('data_proveddimento_1_V');
        TxtOK('tribunale_di_2');
        TxtOK('Provvedimento_Numero_2');
        TxtOK('data_proveddimento_2_V');

        if (getObj('tribunale_di_1').value == '') {
            err = 1;
            TxtErr('tribunale_di_1');
        }

        if (getObj('Provvedimento_Numero_1').value == '') {
            err = 1;
            TxtErr('Provvedimento_Numero_1');
        }

        if (getObj('data_proveddimento_1_V').value == '') {
            err = 1;
            TxtErr('data_proveddimento_1_V');
        }

        if (getObj('tribunale_di_2').value == '') {
            err = 1;
            TxtErr('tribunale_di_2');
        }

        if (getObj('Provvedimento_Numero_2').value == '') {
            err = 1;
            TxtErr('Provvedimento_Numero_2');
        }

        if (getObj('data_proveddimento_2_V').value == '') {
            err = 1;
            TxtErr('data_proveddimento_2_V');
        }

    }


    //PUNTO M se selezionato opzione 4 controllo i campi associati
    if (getObj('check_art_94_d_4').checked == true) {

        TxtOK('tribunale_di_3');
        TxtOK('Provvedimento_Numero_3');
        TxtOK('data_proveddimento_3_V');
        TxtOK('tribunale_di_4');
        TxtOK('Provvedimento_Numero_4');
        TxtOK('data_proveddimento_4_V');

        if (getObj('tribunale_di_3').value == '') {
            err = 1;
            TxtErr('tribunale_di_3');
        }

        if (getObj('Provvedimento_Numero_3').value == '') {
            err = 1;
            TxtErr('Provvedimento_Numero_3');
        }

        if (getObj('data_proveddimento_3_V').value == '') {
            err = 1;
            TxtErr('data_proveddimento_3_V');
        }

        if (getObj('tribunale_di_4').value == '') {
            err = 1;
            TxtErr('tribunale_di_4');
        }

        if (getObj('Provvedimento_Numero_4').value == '') {
            err = 1;
            TxtErr('Provvedimento_Numero_4');
        }

        if (getObj('data_proveddimento_4_V').value == '') {
            err = 1;
            TxtErr('data_proveddimento_4_V');
        }

    }


    //PUNTO P OBBLIGATORIO
    if (getObj('check_art_94_6_1').checked == false && getObj('check_art_94_6_2').checked == false) {
        err = 1;
        TxtErr('check_art_94_6_1');
        TxtErr('check_art_94_6_2');

    }
    else {
        TxtOK('check_art_94_6_1');
        TxtOK('check_art_94_6_2');
    }

    //PUNTO Q OBBLIGATORIO
    if (getObj('check_art_96_1').checked == false && getObj('check_art_96_2').checked == false) {
        err = 1;
        TxtErr('check_art_96_1');
        TxtErr('check_art_96_2');

    }
    else {
        TxtOK('check_art_96_1');
        TxtOK('check_art_96_2');
    }


    //SE RICHIESTA DOCUMENTAZIONE OBBLIGATORIO LA CONTROLLO 
    var numrrowdoc = Number(GetProperty(getObj('DOCUMENTAZIONEGrid'), 'numrow'));
    if (numrrowdoc >= 0) {

        var t = 0;
        for (t = 0; t < numrrowdoc + 1; t++) {
            if (getObj('RDOCUMENTAZIONEGrid_' + t + '_Obbligatorio').value == '1') {
                if (getObj('RDOCUMENTAZIONEGrid_' + t + '_Allegato').value == '') {
                    err = 1;
                    TxtErr('RDOCUMENTAZIONEGrid_' + t + '_Allegato');
                }
                else {
                    TxtOK('RDOCUMENTAZIONEGrid_' + t + '_Allegato');
                }
            }
        }
    }


    try {
        //-- se per entrambe le classificazioni è stato selezionato nessuno non è possibile l'iscrizione
        //SOA =  getObjValue('GerarchicoSOA_edit_new');
        SOA = getObjValue('GerarchicoSOA');

        //if ( SOA == '0-Nessuna') SOA = '';
        //if ( SOA == '0 Selezionati') SOA = '';

        if (SOA != '') {

            if (SOA == '###1###') {
                alert('Per almeno una delle classificazioni occorre selezionare un valore diverso da \'0-Nessuna\' ');
                TxtErr('GerarchicoSOA');
                return -1;
            }

            //SOA =  getObjValue('GerarchicoSOA');
            if (SOA != '') {
                if (SOA != '###1###') {
                    SOA = '###' + SOA + '###'
                    if (SOA.indexOf('###1###') >= 0) {
                        alert('Per la categoria SOA non e\' possibile avere la selezione del valore  \'0-Nessuna\' insieme ad altre categorie');
                        //getObj('elemento_DICHIARAZIONE_abilitazioni_' + ClassificazioneSOA).focus();	
                        TxtErr('GerarchicoSOA');
                        return -1;
                    }
                }
            }

            TxtOK('GerarchicoSOA');
        }

    } catch (e) { }

    /*if (getObjValue('PresenzaDGUE') == 'si' && getObjValue('Allegato') == "" && err == 0) {
      DMessageBox('../', 'Per proseguire e\' necessaria la compilazione del Documento DGUE', 'Attenzione', 1, 400, 300);
      return -1;
    }*/



    if (err > 0) {

        DMessageBox('../', 'Per proseguire e\' necessaria la compilazione di tutti i campi evidenziati', 'Attenzione', 1, 400, 300);
        return -1;
    }



}


function Reati1() {
    if (getObj('CheckReati1').checked == true) {

        getObj('CheckReati2').checked = false;
        getObj('SentenzaReati').value = "";
        getObj('SentenzaReati').disabled = true;


    }
}
function Reati2() {
    if (getObj('CheckReati2').checked == true) {
        getObj('CheckReati1').checked = false;
        getObj('SentenzaReati').disabled = false;
    }
}
function Divieto1() {
    if (getObj('Checkdivieto1').checked == true) {

        getObj('Checkdivieto2').checked = false;

    }
}
function Divieto2() {
    if (getObj('Checkdivieto2').checked == true) {
        getObj('Checkdivieto1').checked = false;
    }
}

function Obbligo1() {
    if (getObj('Checkobbligo1').checked == true) {

        getObj('Checkobbligo2').checked = false;

    }
}
function Obbligo2() {
    if (getObj('Checkobbligo2').checked == true) {
        getObj('Checkobbligo1').checked = false;
    }
}
function Cessati1() {
    if (getObj('Checkcessati1').checked == true) {
        if (GetProperty(getObj('CESSATIGrid'), 'numrow') > -1) {
            DMessageBox('../', 'Prima di cambiare la selezione eliminare le righe dalla griglia sottostante', 'Attenzione', 1, 400, 300);
            getObj('Checkcessati1').checked = false;
            return;
        }
        getObj('Checkcessati2').checked = false;
        document.getElementById('TOOLBAR_CESSATI_ADDNEW').style.display = "none";

    }
}
function Cessati2() {
    if (getObj('Checkcessati2').checked == true) {
        getObj('Checkcessati1').checked = false;
        document.getElementById('TOOLBAR_CESSATI_ADDNEW').style.display = "";
    }
}

function Letteran1() {
    if (getObj('Checkletteran1').checked == true) {

        getObj('Checkletteran2').checked = false;
        getObj('Checkletteran3').checked = false;

    }
}
function Letteran2() {
    if (getObj('Checkletteran2').checked == true) {
        getObj('Checkletteran1').checked = false;
        getObj('Checkletteran3').checked = false;
    }
}

function Letteran3() {
    if (getObj('Checkletteran3').checked == true) {
        getObj('Checkletteran1').checked = false;
        getObj('Checkletteran2').checked = false;
    }
}

/*
sostituisce il nuovo controllo multivalore con il vecchio
*/
function SetCategorieSOA() {


    //se il documento è modificabile 
    try {
        var v = getObj('GerarchicoSOA').value;

        //trasformo la forma tecnica
        getObj('GerarchicoSOA').value = ReplaceExtended(v, '###', '#');
        v = getObj('GerarchicoSOA').value;


        //trasformo la forma visuale
        var v1 = getObj('GerarchicoSOA_edit').value;
        getObj('GerarchicoSOA_edit').value = ReplaceExtended(v1, ';', '#');
        v1 = getObj('GerarchicoSOA_edit').value;



        //costruisco la combo
        sCombo = '<select name="GerarchicoSOA_edit" id="GerarchicoSOA_edit">';
        if (v != '' && v != '#') {

            var ArrayIdent = v.split('#');
            var ArrayDesc = v1.split('#');

            for (iLoop = 0; iLoop < ArrayDesc.length; iLoop++) {

                sOption = '<option value="' + ArrayIdent[iLoop + 1] + '">' + ArrayDesc[iLoop] + '</option>';
                sCombo = sCombo + sOption;


            }
        } else {

            //combo vuota con elemento fittizio seleziona classe di iscrizione
            sOption = '<option value="">Seleziona Elenco Categorie SOA </option>';
            sCombo = sCombo + sOption;

        }

        //aggiungo il campo nascosto con le desc
        sCombo = sCombo + '<input type=hidden id=GerarchicoSOA_desc name=GerarchicoSOA_desc value="' + v1 + '">';

        //getObj( 'GerarchicoSOA_edit' ).outerHTML = sCombo;
        getObj('GerarchicoSOA_edit').parentNode.innerHTML = '<input type=hidden id=GerarchicoSOA name=GerarchicoSOA value="' + v + '">' + sCombo + '<input class="ButtonBar_Button" type=button id="GerarchicoSOA_button" name="GerarchicoSOA_button" value="..." onclick="javascript:CallAttributoGerarchicoSOA();">';

        //imposto chiamata sul bottone GerarchicoSOA_button
        getObj('GerarchicoSOA_button').onclick = CallAttributoGerarchicoSOA;

    }
    catch (e) {



        v1 = getObj('Cell_GerarchicoSOA').innerText;
        if (trim(v1) != '') {
            ArrayDesc = v1.split(';');
            sCombo = '<select name="GerarchicoSOA_edit" id="GerarchicoSOA_edit">';
            for (iLoop = 0; iLoop < ArrayDesc.length; iLoop++) {

                sOption = '<option value=>' + ArrayDesc[iLoop] + '</option>';
                sCombo = sCombo + sOption;
            }

            getObj('Cell_GerarchicoSOA').innerHTML = sCombo;
        }
    }

}



function MyExecDocProcess(param) {

    ExecDocProcess(param);
}

function MySaveDoc() {

    SaveDoc();

}




function Doc_DettagliDel(grid, r, c) {
    var v = '0';
    try {
        v = getObj('RDOCUMENTAZIONEGrid_' + r + '_Obbligatorio').value;
    } catch (e) { };

    if (v == '1') {
        //DMessageBox( '../' , 'La documentazione è obbligatoria' , 'Attenzione' , 1 , 400 , 300 );
    }
    else {
        DettagliDel(grid, r, c);
    }
}

function DOCUMENTAZIONE_AFTER_COMMAND() {
    HideCestinodoc();
    FormatAllegato();
}
function HideCestinodoc() {
    try {
        var i = 0;

        if ((getObj('StatoDoc').value == 'Saved' || getObj('StatoDoc').value == '') && (getObj('SIGN_LOCK').value == '0')) {
            for (i = 0; i < DOCUMENTAZIONEGrid_EndRow + 1; i++) {
                if (getObj('RDOCUMENTAZIONEGrid_' + i + '_Obbligatorio').value == '1') {
                    getObj('DOCUMENTAZIONEGrid_r' + i + '_c0').innerHTML = '&nbsp;';
                }
            }
        }
    } catch (e) { }

}
//funzione per inserire nella sezione documentazione i tipi allegati consentiti scelti in creazione del BANDO
function FormatAllegato() {
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
            }
            catch (e) {
                richiestaFirma = '';
            }

            tipofile = ReplaceExtended(tipofile, '###', ',');
            tipofile = 'INTVEXT:' + tipofile.substring(1, tipofile.length);
            tipofile = tipofile.substring(0, tipofile.length - 1) + '-';
            tipofile = 'FORMAT=' + tipofile;

            if (richiestaFirma == '1') {
                tipofile = tipofile + 'B'; //format per forzare la verifica di firma bloccante in caso di mancata firma o file corrotto
            }

            obj = getObj('RDOCUMENTAZIONEGrid_' + i + '_Allegato_V_BTN').parentElement;
            onclick = obj.innerHTML;
            onclick = onclick.replace(/FORMAT=INTV/g, tipofile);
            onclick = onclick.replace(/FORMAT=INT/g, tipofile);
            obj.innerHTML = onclick;

            //se per qualche motivo tolta INTV nasconde img della pennina

            try {
                if (onclick.indexOf('FORMAT=INTV') < 0) {
                    $('#RDOCUMENTAZIONEGrid_' + i + '_Allegato_V_N').siblings('.IMG_SIGNINFO').hide();
                }
            }
            catch (e) {
            }

        }
        catch (e) { }
    }

}
function RefreshContent() {
    RefreshDocument('');

}


//GESTIONE DEI CAMPI LOCALITA PROVINCIA E STATO

function initAziEnte() {
    enableDisableAziGeo('LocalitaRapLeg', 'ProvinciaRapLeg', 'StatoRapLeg', 'apriGEO', true);
    enableDisableAziGeo('ResidenzaRapLeg', 'ProvResidenzaRapLeg', 'StatoResidenzaRapLeg', 'apriGEO2', true);
    enableDisableAziGeo('LOCALITALEG', 'PROVINCIALEG', 'STATOLOCALITALEG', 'apriGEO3', true);
}


function impostaLocalita(cod, fieldname) {
    ajax = GetXMLHttpRequest();

    var comuneTec;
    var provinciaTec;
    var statoTec;
    var comuneDesc;
    var provinciaDesc;
    var statoDesc;

    if (fieldname == 'RapLeg') {
        comuneTec = 'LocalitaRapLeg2';
        provinciaTec = 'ProvinciaRapLeg2';
        statoTec = 'StatoRapLeg2';
        comuneDesc = 'LocalitaRapLeg';
        provinciaDesc = 'ProvinciaRapLeg';
        statoDesc = 'StatoRapLeg';
        geo = 'apriGEO'
    }
    if (fieldname == 'ResidenzaRapLeg') {
        comuneTec = 'ResidenzaRapLeg2';
        provinciaTec = 'ProvResidenzaRapLeg2';
        statoTec = 'StatoResidenzaRapLeg2';
        comuneDesc = 'ResidenzaRapLeg';
        provinciaDesc = 'ProvResidenzaRapLeg';
        statoDesc = 'StatoResidenzaRapLeg';
        geo = 'apriGEO2'
    }
    if (fieldname == 'LOCALITALEG') {
        comuneTec = 'LOCALITALEG2';
        provinciaTec = 'PROVINCIALEG2';
        statoTec = 'STATOLOCALITALEG2';
        comuneDesc = 'LOCALITALEG';
        provinciaDesc = 'PROVINCIALEG';
        statoDesc = 'STATOLOCALITALEG';
        geo = 'apriGEO3'
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

                            if (codLoc == '' || codLoc.substring(codLoc.length - 3, codLoc.length) == 'XXX')
                                disableGeoField(comuneDesc, false);
                            else
                                disableGeoField(comuneDesc, true);

                            getObj(provinciaTec).value = codProv;
                            getObj(provinciaDesc).value = descProv;

                            if (codProv == '' || codProv.substring(codProv.length - 3, codProv.length) == 'XXX')
                                disableGeoField(provinciaDesc, false);
                            else
                                disableGeoField(provinciaDesc, true);

                            getObj(statoTec).value = codStato;
                            getObj(statoDesc).value = descStato;

                            if (codStato == '' || codStato.substring(codStato.length - 3, codStato.length) == 'XXX')
                                disableGeoField(statoDesc, false);
                            else
                                disableGeoField(statoDesc, true);

                        }
                        catch (e) {
                            alert('Errore:' + e.message);

                        }
                    }
                    else {
                        alert('errore.msg:' + res.substring(2));
                        enableDisableAziGeo(comuneDesc, provinciaDesc, statoDesc, geo, false);
                    }
                }
            }
            else {
                alert('errore.status:' + ajax.status);
                enableDisableAziGeo(comuneDesc, provinciaDesc, statoDesc, geo, false);

            }
        }
        else {
            alert('errore in impostaLocalita');
            enableDisableAziGeo(comuneDesc, provinciaDesc, statoDesc, geo, false);
        }
    }
}


function Compila_DOC_DGUE() {
    var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
    if (DOCUMENT_READONLY == "1") {
        MakeDocFrom('MODULO_TEMPLATE_REQUEST##ISTANZA');
    }
    else {
        ExecDocProcess('FITTIZIO,DOCUMENT,,NO_MSG');
    }
}

function afterProcess(param) {
    if (param == 'FITTIZIO') {
        ShowWorkInProgress();

        setTimeout(function () {

            ShowWorkInProgress();
            MakeDocFrom('MODULO_TEMPLATE_REQUEST##ISTANZA');

        }, 1);
    }

}


function OnChangeCheck(obj) {
    var name = obj.name;
    var valore = obj.value;



    if (name.substring(0, name.length - 1) == 'CheckIscritta' && valore == '1') {

        getObj('CheckIscritta1').checked = false;
        getObj('CheckIscritta3').checked = false;

        getObj(name).checked = true;

        if (name == 'CheckIscritta1') {

            TextreadOnly('Registro_Camera_Provincia_Artigianato', false);
            TextreadOnly('elenco_camera_attivita_artigianato', false);
            TextreadOnly('numero_iscrizione', false);
            document.getElementById('data_iscrizione_button').style.display = "";
            TextreadOnly('data_iscrizione_V', false);
            TextreadOnly('sede_iscrizione', false);

        }
        else {

            getObj('Registro_Camera_Provincia_Artigianato').value = ''
            TextreadOnly('Registro_Camera_Provincia_Artigianato', true);

            getObj('elenco_camera_attivita_artigianato').value = ''
            TextreadOnly('elenco_camera_attivita_artigianato', true);

            getObj('numero_iscrizione').value = ''

            TextreadOnly('numero_iscrizione', true);

            getObj('data_iscrizione').value = '';
            getObj('data_iscrizione_V').value = '';
            document.getElementById('data_iscrizione_button').style.display = "none";
            TextreadOnly('data_iscrizione_V', true);

            getObj('sede_iscrizione').value = ''
            TextreadOnly('sede_iscrizione', true);
        }

        return;
    }


    if (name.substring(0, name.length - 1) == 'CheckSoggetti' && valore == '1') {
        getObj('CheckSoggetti1').checked = false;
        getObj('CheckSoggetti2').checked = false;

        getObj(name).checked = true;

        //se ho la seconda opzione svuoto la griglia dei soggetti
        //collegata all aprima scelta altrimenti se la griglia è vuota aggiungo una riga
        if (name == 'CheckSoggetti2') {
            ExecDocCommand('SOGGETTI#DELETE_ALL#');
        }
        else {

            var numSogg = GetProperty(getObj('SOGGETTIGrid'), 'numrow');

            if (numSogg == -1)
                ExecDocCommand('SOGGETTI#ADDNEW#');
        }
    }


    if (name.substring(0, name.length - 2) == 'check_art_94' && valore == '1') {
        getObj('check_art_94_1').checked = false;
        getObj('check_art_94_2').checked = false;

        getObj(name).checked = true;


    }


    if (name.substring(0, name.length - 2) == 'check_art_94_d' && valore == '1') {
        getObj('check_art_94_d_1').checked = false;
        getObj('check_art_94_d_2').checked = false;
        getObj('check_art_94_d_3').checked = false;
        getObj('check_art_94_d_4').checked = false;

        getObj(name).checked = true;


        if (name == 'check_art_94_d_1') {
            //svuoto i campi relativi alle altre scelte per coerenza

            Handle_Field_2_PuntoM(1);

            Handle_Field_3_PuntoM(1);

            Handle_Field_4_PuntoM(1);

        }

        if (name == 'check_art_94_d_2') {
            //svuoto i campi relativi alle altre scelte per coerenza

            Handle_Field_2_PuntoM(0);

            Handle_Field_3_PuntoM(1);

            Handle_Field_4_PuntoM(1);

        }

        if (name == 'check_art_94_d_3') {
            //svuoto i campi relativi alle altre scelte per coerenza

            Handle_Field_2_PuntoM(1);

            Handle_Field_3_PuntoM(0);

            Handle_Field_4_PuntoM(1);

        }

        if (name == 'check_art_94_d_4') {
            //svuoto i campi relativi alle altre scelte per coerenza

            Handle_Field_2_PuntoM(1);

            Handle_Field_3_PuntoM(1);

            Handle_Field_4_PuntoM(0);

        }


    }


    if (name.substring(0, name.length - 2) == 'check_art_94_6' && valore == '1') {
        getObj('check_art_94_6_1').checked = false;
        getObj('check_art_94_6_2').checked = false;

        getObj(name).checked = true;


    }


    if (name.substring(0, name.length - 2) == 'check_art_96' && valore == '1') {
        getObj('check_art_96_1').checked = false;
        getObj('check_art_96_2').checked = false;

        getObj(name).checked = true;


    }





    /*if ((name == 'CheckNOSOA' || name == 'CheckSOSPSOA') && valore == '1') {
      getObj('CheckNOSOA').checked = false;
      getObj('CheckSOSPSOA').checked = false;
      getObj(name).checked = true;
      return;
    }*/


    /*if ( name.substring(0,name.length - 2) == 'check_blacklist' && valore == '1' )
    {
       getObj('check_blacklist_2').checked = false;	
       getObj('check_blacklist_1').checked = false;
       getObj(name).checked = true;
       return;
    }	
    */
}




function Handle_Field_2_PuntoM(nLock) {
    TextreadOnly('tribunale_di', false);
    TextreadOnly('Provvedimento_Numero', false);
    TextreadOnly('data_proveddimento_V', false);
    document.getElementById('data_proveddimento_button').style.display = "";

    if (nLock == 1) {
        getObj('tribunale_di').value = ''
        TextreadOnly('tribunale_di', true);

        getObj('Provvedimento_Numero').value = ''
        TextreadOnly('Provvedimento_Numero', true);

        getObj('data_proveddimento_V').value = ''
        getObj('data_proveddimento').value = ''
        TextreadOnly('data_proveddimento_V', true);

        document.getElementById('data_proveddimento_button').style.display = "none";

    }
}

function Handle_Field_3_PuntoM(nLock) {

    TextreadOnly('tribunale_di_1', false);
    TextreadOnly('Provvedimento_Numero_1', false);
    TextreadOnly('data_proveddimento_1_V', false);
    document.getElementById('data_proveddimento_1_button').style.display = "";
    TextreadOnly('tribunale_di_2', false);
    TextreadOnly('Provvedimento_Numero_2', false);
    TextreadOnly('data_proveddimento_2_V', false);
    document.getElementById('data_proveddimento_2_button').style.display = "";


    if (nLock == 1) {
        getObj('tribunale_di_1').value = ''
        TextreadOnly('tribunale_di_1', true);

        getObj('Provvedimento_Numero_1').value = ''
        TextreadOnly('Provvedimento_Numero_1', true);

        getObj('data_proveddimento_1_V').value = ''
        getObj('data_proveddimento_1').value = ''
        TextreadOnly('data_proveddimento_1_V', true);

        document.getElementById('data_proveddimento_1_button').style.display = "none";

        getObj('tribunale_di_2').value = ''
        TextreadOnly('tribunale_di_2', true);

        getObj('Provvedimento_Numero_2').value = ''
        TextreadOnly('Provvedimento_Numero_2', true);

        getObj('data_proveddimento_2_V').value = ''
        getObj('data_proveddimento_2').value = ''
        TextreadOnly('data_proveddimento_2_V', true);

        document.getElementById('data_proveddimento_2_button').style.display = "none";

    }
}


function Handle_Field_4_PuntoM(nLock) {


    TextreadOnly('tribunale_di_3', false);
    TextreadOnly('Provvedimento_Numero_3', false);
    TextreadOnly('data_proveddimento_3_V', false);
    document.getElementById('data_proveddimento_3_button').style.display = "";
    TextreadOnly('tribunale_di_4', false);
    TextreadOnly('Provvedimento_Numero_4', false);
    TextreadOnly('data_proveddimento_4_V', false);
    document.getElementById('data_proveddimento_4_button').style.display = "";


    if (nLock == 1) {
        getObj('tribunale_di_3').value = ''
        TextreadOnly('tribunale_di_3', true);

        getObj('Provvedimento_Numero_3').value = ''
        TextreadOnly('Provvedimento_Numero_3', true);

        getObj('data_proveddimento_3_V').value = ''
        getObj('data_proveddimento_3').value = ''
        TextreadOnly('data_proveddimento_3_V', true);

        document.getElementById('data_proveddimento_3_button').style.display = "none";

        getObj('tribunale_di_4').value = ''
        TextreadOnly('tribunale_di_4', true);

        getObj('Provvedimento_Numero_4').value = ''
        TextreadOnly('Provvedimento_Numero_4', true);

        getObj('data_proveddimento_4_V').value = ''
        getObj('data_proveddimento_4').value = ''
        TextreadOnly('data_proveddimento_4_V', true);

        document.getElementById('data_proveddimento_4_button').style.display = "none";

    }
}
