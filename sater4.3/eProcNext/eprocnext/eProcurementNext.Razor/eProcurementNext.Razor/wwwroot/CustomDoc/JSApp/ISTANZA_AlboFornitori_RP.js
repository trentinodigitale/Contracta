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
  'NUMFAX',
  'codicefiscale',
  'CittaEntrate',
  'SettoriCCNL',
  //'EmailRapLeg',
  'EMAIL',
  'ClasseIscriz',
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


function GeneraPDF ()
{
	var value2=controlli('');
	if (value2 == -1)
	return;
    Stato = getObjValue('StatoDoc');
    
    if( Stato == '' ) 
    {
        alert( 'Per effettuare il \"Genera PDF\" si richiede prima un salvataggio. Verra\' effettuato in automatico, successivamente effettuare nuovamente il comando di \"Genera PDF\"');
        MySaveDoc();
        return;
	}
	
    scroll(0,0);   
    
	PrintPdfSign('URL=/report/prn_' + getObj('TYPEDOC').value + '.ASP?SIGN=YES&PROCESS=ISTANZA@@@VERIFICHE_PRE_PDF');
	 
}

function TogliFirma() {
  //DMessageBox( '../' , 'Si sta per eliminare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );
  if (confirm(CNV('../', 'Si sta per eliminare il file firmato. Vuoi procedere?'))) {
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
  Filtro_Classe_Iscrizione();
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

  var NRPOSIZIONI_INPSGrid = GetProperty(getObj('POSIZIONI_INPSGrid'), 'numrow');

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
  }

  var NRPOSIZIONI_INAILGrid = GetProperty(getObj('POSIZIONI_INAILGrid'), 'numrow');

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
  }

  var NRPOSIZIONI_CASSAEDILEGrid = GetProperty(getObj('POSIZIONI_CASSAEDILEGrid'), 'numrow');

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
  }

  var NRSEDI_OPERATIVEGrid = GetProperty(getObj('SEDI_OPERATIVEGrid'), 'numrow');

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
  }

  //punto b
  if (getObj('CheckIscritta1').checked == false && getObj('CheckIscritta2').checked == false && getObj('CheckIscritta3').checked == false) {
    err = 1;
    TxtErr('CheckIscritta1');
    TxtErr('CheckIscritta2');
    TxtErr('CheckIscritta3');
  }
  else {
    TxtOK('CheckIscritta1');
    TxtOK('CheckIscritta2');
    TxtOK('CheckIscritta3');
  }

  if (getObj('CheckIscritta1').checked == true) {
    if (getObj('IscrCCIAA').value == '') {
      err = 1;
      TxtErr('IscrCCIAA');
    }
    else {
      TxtOK('IscrCCIAA');
    }

    if (getObj('SedeCCIAA').value == '') {
      err = 1;
      TxtErr('SedeCCIAA');
    }
    else {
      TxtOK('SedeCCIAA');
    }

    if (getObj('ANNOCOSTITUZIONE').value == '') {
      err = 1;
      TxtErr('ANNOCOSTITUZIONE');
    }
    else {
      TxtOK('ANNOCOSTITUZIONE');
    }
  }


  //punto e
  /*if ( getObj( 'check_blacklist_1' ).checked == false &&  getObj( 'check_blacklist_2' ).checked == false )
  {
    err = 1;
    TxtErr( 'check_blacklist_1' );
    TxtErr( 'check_blacklist_2' );
 
  }
  else
  {
    TxtOK( 'check_blacklist_1' );
    TxtOK( 'check_blacklist_2' );
  } */

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
    //Merc = getObjValue('ClasseIscriz_edit_new');
    Merc = getObjValue('ClasseIscriz');

    //if ( Merc == '0-Nessuna') Merc = '';
    //if ( Merc == '0 Selezionati') Merc = '';

    if (Merc != '') {
      if (Merc == '###1232###') {
        alert('Per almeno una delle classificazioni occorre selezionare un valore diverso da \'0-Nessuna\' ');
        TxtErr('ClasseIscriz');
        return -1;
      }

      //Merc = getObjValue('ClasseIscriz');
      if (Merc != '') {
        if (Merc != '###1232###') {
          Merc = '###' + Merc + '###'
          if (Merc.indexOf('###1232###') >= 0) {
            alert('Per la categoria Merceologica non e\' possibile avere la selezione del valore  \'0-Nessuna\' insieme ad altre categorie');
            //getObj('elemento_DICHIARAZIONE_abilitazioni_' + strClasseIscriz).focus();	
            TxtErr('ClasseIscriz');
            return -1;
          }
        }
      }

      //controllo che nella Categorie Merceologiche non ci siano le voci "Generiche" e "Spese Sanitarie"
      Merc = getObjValue('ClasseIscriz');
      Merc = '###' + Merc + '###';
      if (Merc.indexOf('###0###') >= 0 || Merc.indexOf('###1###') >= 0 || Merc.indexOf('###2###') >= 0) {
        alert('Per le Categorie Merceologiche non e\' possibile selezionare i valori  \'Generiche\', \'Spese Sanitarie\', \'Categorie Merceologiche\'.');
        TxtErr('ClasseIscriz');
        return -1;
      }

      TxtOK('ClasseIscriz');
    }

  } catch (e) { }

  if (getObjValue('PresenzaDGUE') == 'si' && getObjValue('Allegato') == "" && err == 0) {
    DMessageBox('../', 'Per proseguire e\' necessaria la compilazione del Documento DGUE', 'Attenzione', 1, 400, 300);
    return -1;
  }

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
function SetClasseIscriz() {
  //se il documento è modificabile 
  try {
    var v = getObj('ClasseIscriz').value;

    //trasformo la forma tecnica
    getObj('ClasseIscriz').value = ReplaceExtended(v, '###', '#');
    v = getObj('ClasseIscriz').value;

    //trasformo la forma visuale
    var v1 = getObj('ClasseIscriz_edit').value;
    getObj('ClasseIscriz_edit').value = ReplaceExtended(v1, ';', '#');
    v1 = getObj('ClasseIscriz_edit').value;

    //costruisco la combo
    sCombo = '<select name="ClasseIscriz_edit" id="ClasseIscriz_edit">';    
    if (v != '' && v != '#') {
      var ArrayIdent = v.split('#');
      var ArrayDesc = v1.split('#');

      for (iLoop = 0; iLoop < ArrayDesc.length; iLoop++) {
        sOption = '<option value="' + ArrayIdent[iLoop + 1] + '">' + ArrayDesc[iLoop] + '</option>';
        sCombo = sCombo + sOption;
      }
    } else {

      //combo vuota con elemento fittizio seleziona classe di iscrizione
      sOption = '<option value="">Seleziona Elenco Classi di Iscrizione</option>';
      sCombo = sCombo + sOption;
    }

    //aggiungo il campo nascosto con le desc
    sCombo = sCombo + '<input type=hidden id=ClasseIscriz_desc name=ClasseIscriz_desc value="' + v1 + '">';

    //getObj( 'ClasseIscriz_edit' ).outerHTML = sCombo;
    getObj('ClasseIscriz_edit').parentNode.innerHTML = '<input type=hidden id=ClasseIscriz name=ClasseIscriz value="' + v + '">' + sCombo + '<input class="ButtonBar_Button" type=button id="ClasseIscriz_button" name="ClasseIscriz_button" value="..." onclick="javascript:CallAttributoClasseIscriz();">';

    //imposto chiamata sul bottone ClasseIscriz_button
    getObj('ClasseIscriz_button').onclick = CallAttributoClasseIscriz;

  }
  catch (e) {
    v1 = getObj('Cell_ClasseIscriz').innerText;
    if (trim(v1) != '') {
      ArrayDesc = v1.split(';');
      sCombo = '<select name="ClasseIscriz_edit" id="ClasseIscriz_edit">';
      for (iLoop = 0; iLoop < ArrayDesc.length; iLoop++) {

        sOption = '<option value=>' + ArrayDesc[iLoop] + '</option>';
        sCombo = sCombo + sOption;
      }

      getObj('Cell_ClasseIscriz').innerHTML = sCombo;
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
    getObj('CheckIscritta2').checked = false;
    getObj('CheckIscritta3').checked = false;

    getObj(name).checked = true;

    if (name == 'CheckIscritta1') {
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

    return;
  }

  /*if ( name.substring(0,name.length - 2) == 'check_blacklist' && valore == '1' )
  {
     getObj('check_blacklist_2').checked = false;	
     getObj('check_blacklist_1').checked = false;
     getObj(name).checked = true;
     return;
  }	
  */
}


function Filtro_Classe_Iscrizione()
{
	
	if(  getObjValue( 'StatoFunzionale' ) == 'InLavorazione'  )
	{
		//alert('Ok');
		var class_bando = getObj('ClasseIscriz_Bando').value;
		//alert(class_bando);
		
		if ( class_bando != '' )
		{	
			var filter = '';
			
			filter =  GetProperty ( getObj('ClasseIscriz'),'filter') ;				
				
			if ( filter == '' || filter == undefined || filter == null )
			{					
				SetProperty( getObj('ClasseIscriz'),'filter','SQL_WHERE= dmv_cod in (  select top 1000000  B.dmv_cod  from ClasseIscriz a  INNER JOIN ClasseIscriz B ON a.dmv_father = left( b.dmv_father , len ( a.dmv_father ) )  or  b.dmv_father = \'000.\'  or b.dmv_father = left( a.dmv_father , len ( b.dmv_father ) )     where  \'' + class_bando + '\' like \'%###\' + A.DMV_COD + \'###%\'    )');
			}			
		}
	}	
}