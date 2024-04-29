function getObj(strId) {

  if (document.all != null) {
    return document.all(strId);
  }
  else {
    return document.getElementById(strId);
  }
}


function getObjPage(strId, docPage) {
  if (docPage == '') {
    docPage = 'self';
  }

  mydocument = eval(docPage + '.document');
  if (mydocument.all != null) {
    return mydocument.all(strId);
  }
  else {
    return mydocument.getElementById(strId);
  }
}


function getObjParent(name) {
  var obj;
  try {
    //debugger;

    obj = getObj(name);

    if (obj != null) return obj;

    var par = 'parent';
    var objPar = eval(par + '.document');
    while (objPar != null) {
      try {
        obj = getObjPage(name, par);
        if (obj != null) return obj;
      }
      catch (e) {
        par = par + '.parent';
        objPar = eval(par + '.document');
      }
    }
  } catch (e) {
  }



}

function getObjFromDoc(strId, doc) {

  mydocument = doc;
  if (mydocument.all != null) {
    return mydocument.all(strId);
  }
  else {
    return mydocument.getElementById(strId);
  }
}


function getObjGrid(strId) {

  var obj;
  var val;
  var strType;



  /*
  try {
  	
    obj = getObj( strId );
    val = getObj( strId )[0].value;
    obj = obj[0];
  	
  }catch( e ) 
  {
  	
  }
  */


  try {

    //se esite il type diverso da undefined sul primo elemento del vettore di oggetti
    //allora prendo il primo oggetto  del vettore
    //altrimenti vuol dire che non esiste il vettore di oggetti e quindi  prendo oggetto diretto

    strType = getObj(strId)[0].type;

    if (strType == undefined) {
      obj = getObj(strId);

    }
    else {
      val = getObj(strId)[0].value;
      obj = obj[0];
    }

  } catch (e) {
    obj = getObj(strId);
  }


  return obj;
}


function GetProperty(objTarget, NameProperty) {
  var attrib;

  attrib = objTarget.getAttribute(NameProperty);

  //Se l'attributo non esiste provo a recuperarlo nella
  //nuova input hidden per gli attributi estesi
  if (!attrib) {
    attrib = getExtraAttrib(objTarget.id, NameProperty.toLowerCase());
  }

  return attrib;
}

function SetProperty(objTarget, NameProperty, ValueProperty) {
  //Se esiste l'oggetto
  if (objTarget != null) {
    attrib = objTarget.getAttribute(NameProperty);

    //Se non esisteva l'attributo che si vuole settare
    if (!attrib) {
      //Provo a settarlo sulla input hidden degli attributi estesi
      setExtraAttrib(objTarget.id, NameProperty.toLowerCase(), ValueProperty);
    }
    else {
      objTarget.setAttribute(NameProperty, ValueProperty);
    }

  }
}

function getObjValue(strId) {

  var obj = getObj(strId);
  var val;
  //var l = obj.length;
  var type;
  try { type = obj[0].type; }
  catch (e) {
    //console.log(e);
    type = obj.type;
  }

  try {
    if (getObj(strId).type == 'select-one') {
      if (getObj(strId).selectedIndex == -1)
        return '';
      else
        return getObj(strId).options[getObj(strId).selectedIndex].value;
    }

  } catch (e) { }

  try {
    if (getObj(strId).type == 'textarea') {
      return getObj(strId).value;
    }

  } catch (e) { }

  try {
    //if( getObj(strId).type == 'radio' )
    if (type == 'radio') {

      //var o_radio_group = getObj(strId);
      var o_radio_group = document.getElementsByName(strId);
      for (var a = 0; a < o_radio_group.length; a++) {
        if (o_radio_group[a].checked) {
          return o_radio_group[a].value;
        }
      }
      return '';
    }
  } catch (e) { }


  // Gestiti i campi Checkbox: ritorna true o false
  try {
    if (type === 'checkbox') {
      return getObj(strId).checked;
    }
  } catch (e) { }

  try {
    val = getObj(strId).value;	//	val = GetProperty( getObj( strId ) , 'value');
  } catch (e) {
    val = undefined;
  }

  //if ( val == '' || val == undefined ) 
  if (val == undefined) {
    try {
      //val = getObj( strId )[0].value;
      val = GetProperty(getObj(strId)[0], 'value');

    } catch (e) {

      val = GetProperty(getObj(strId), 'value');
    }

  }

  return val;
}


function GetXMLHttpRequest() {
  var
    XHR = null,
    browserUtente = navigator.userAgent.toUpperCase();

  if (typeof (XMLHttpRequest) === "function" || typeof (XMLHttpRequest) === "object")
    XHR = new XMLHttpRequest();
  else if (window.ActiveXObject && browserUtente.indexOf("MSIE 4") < 0) {
    if (browserUtente.indexOf("MSIE 5") < 0)
      XHR = new ActiveXObject("Msxml2.XMLHTTP");
    else
      XHR = new ActiveXObject("Microsoft.XMLHTTP");
  }
  return XHR;
};

// funzione per prendere un elemento con id univoco
function prendiElementoDaId(id_elemento) {
  var elemento;
  if (document.getElementById)
    elemento = document.getElementById(id_elemento);
  else
    elemento = document.all[id_elemento];
  return elemento;
};



function CNV(path, testo) {
  var nocache = new Date().getTime();

  ajax = GetXMLHttpRequest();

  if (isSingleWin()) {
    path = pathRoot;
  }
  if (ajax) {
    ajax.open("GET", path + 'CTL_Library/functions/CNV.asp?TXT=' + escape(testo) + '&nocache=' + nocache, false);
    ajax.send(null);

    if (ajax.readyState == 4) {
      if (ajax.status == 200) {
        return ajax.responseText;
      }
    }

  }
  return testo;
}

function CNV_AsyncInnerHTML(path, testo, Obj) {
  var nocache = new Date().getTime();
  ajax = GetXMLHttpRequest();

  if (ajax) {
    ajax.open("GET", path + 'CTL_Library/functions/CNV.asp?TXT=' + escape(testo) + '&nocache=' + nocache, true);
    ajax.onreadystatechange = function () {
      if (ajax.readyState == 4) {
        if (ajax.status == 200) {
          getObj(Obj).innerHTML = ajax.responseText;
        }
      }
    }
    ajax.send(null);
    return true;
  }
  return false;

}


function WiewLoading() {
  parent.ViewerGriglia.document.body.innerHTML = '<table class="Loading" width="100%" height="100%" ><tr><td width="100%" height="100%" align="center" valign="center" >Loading ...</td></tr></table>';
}

function CubeLoading() {
  parent.CUBEGrid.document.body.innerHTML = '<table class="Loading" width="100%" height="100%" ><tr><td width="100%" height="100%" align="center" valign="center" >Loading ...</td></tr></table>';
}


//Editable; se = no volgio il campo non editabile altrimenti editabile
//siccome prima non esisteva per default è editabile
function FilterDom(objName, FieldName, valore, filter, row, OnChange, format, strParamPath, Editable) {
  var nocache = new Date().getTime();
  var strTmpPath = '../../';

  format = format || ''; //Setto stringa vuota come default del parametro opzionale format

  ajax = GetXMLHttpRequest();

  if (ajax) {
    /* SE SIAMO NELLA VERSIONE A SINGOLA FINESTRA IL PATH E' PRESENTE NELLA VARIABILE PATHROOT */
    if (isSingleWin()) {
      strTmpPath = pathRoot;
    }
    else {
      /* PER LA VERSIONE MULTI FINESTRA, VEDI EMPULIA, IL PATH LO RECUPERIAMO DAL PARAMETRO OPZIONALE strParamPath SE PASSATO ( UTILE PER I VIEWER). ALTRIMENTI USIAMO IL DEFAULT DI PRIMA */
      if (strParamPath === undefined) {
        strTmpPath = '../../';
      }
      else {
        strTmpPath = strParamPath;
      }
    }

    if (Editable == undefined)
      Editable = 'yes';


    ajax.open("GET", strTmpPath + 'CTL_Library/GetFilteredField.asp?EDITABLE=' + Editable + '&FIELD=' + FieldName + '&VALUE=' + encodeURIComponent(valore) + '&FILTER=' + encodeURIComponent(filter) + '&ROW=' + row + '&ONCHANGE=' + encodeURIComponent(OnChange) + '&FORMAT=' + encodeURIComponent(format) + '&nocache=' + nocache, false);

    ajax.send(null);

    if (ajax.readyState == 4) {

      if (ajax.status == 200) {
        //-- funziona solo per i domini chiusi perchè sono in un div

        try {
          if (getObj(objName).type == 'select-one' || getObj(objName).type == 'hidden') {
            //alert (getObj( objName ).type);*/
            getObj('val_' + objName).parentNode.innerHTML = ajax.responseText;
            return;
          }
          else {
            getObj(objName).parentNode.innerHTML = ajax.responseText;
            return;
          }
        }
        catch (e) {
          if (getObj('val_' + objName)) {
            getObj('val_' + objName).parentNode.innerHTML = ajax.responseText;
            return;
          }
        }
      }
    }

  }

  getObj('val_' + objName).innerHTML = 'Error!!!';

  return;
}

function RetrievePath(path, TipoDoc) {

  ajax = GetXMLHttpRequest();

  if (ajax) {


    ajax.open("GET", path + 'CTL_Library/functions/RetrievePath.asp?TipoDoc=' + escape(TipoDoc), false);

    ajax.send(null);
    if (ajax.readyState == 4) {
      if (ajax.status == 200) {
        return ajax.responseText;
      }
    }

  }
  return '';
}

function RetrieveDocOrign(path, Fascicolo, SubType) {

  ajax = GetXMLHttpRequest();

  if (ajax) {


    ajax.open("GET", path + 'CTL_Library/functions/RetrieveDocOrigin.asp?Fascicolo=' + escape(Fascicolo) + '&SubType=' + SubType, false);

    ajax.send(null);
    if (ajax.readyState == 4) {
      if (ajax.status == 200) {
        return ajax.responseText;
      }
    }

  }
  return '';
}

function CNVDOC(path, testo) {

  ajax = GetXMLHttpRequest();

  if (ajax) {


    ajax.open("GET", path + 'CTL_Library/functions/CNVDOC.asp?TXT=' + escape(testo), false);

    ajax.send(null);
    if (ajax.readyState == 4) {
      if (ajax.status == 200) {
        return ajax.responseText;
      }
    }

  }
  return testo;
}

// makeReadOnly: nuovo parametro per fare solo i campi readonly
function DisableObj(objName, b, makeReadOnly = false) {
  if (!makeReadOnly) {
    makeReadOnly = false;
  }

  try { getObj(objName).disabled = b; } catch (e) { };
  try { getObj(objName + '_button').disabled = b; } catch (e) { };
  try { getObj(objName + '_edit').disabled = b; } catch (e) { };
  try { getObj(objName + '_edit1').disabled = b; } catch (e) { };
  try { getObj(objName + '_V').disabled = b; } catch (e) { };

  if (b == true && makeReadOnly === false) {
    if (getObj(objName).type == 'checkbox') {
      try { getObj(objName).checked = false; } catch (e) { };
    }
    else {
      try { getObj(objName).value = ''; } catch (e) { };
    }

    try { getObj(objName + '_V').value = ''; } catch (e) { };
    try { getObj(objName + '_edit').value = ''; } catch (e) { };
    try { getObj(objName + '_edit1').value = ''; } catch (e) { };
  }

  //se devo fare il readonly setto la classe di stile adeguata sui campi di input readonly main.css riga 10
  if (makeReadOnly) {
    let obj = getObj(objName);
    if (obj) {
      obj.className += ' readonly';
    }

    let objButton = getObj(objName + '_button');
    if (objButton) {
      objButton.className += ' readonly';
    }

    let objEdit = getObj(objName + '_edit');
    if (objEdit) {
      objEdit.className += ' readonly';
    }

    let objEdit1 = getObj(objName + '_edit1');
    if (objEdit1) {
      obj.className += ' readonly';
    }

    let objV = getObj(objName + '_V');
    if (objV) {
      objV.className += ' readonly';
    }
  }
}

function SUB_AJAX(URL) {

  ajax = GetXMLHttpRequest();

  if (ajax) {

    var nocache = new Date().getTime();


    ajax.open("GET", URL + '&nocache=' + nocache, false);

    ajax.send(null);
    if (ajax.readyState == 4) {
      if (ajax.status == 200) {
        return ajax.responseText;
      }
    }

  }
  return '';
}


function getQSParam(ParamName) {
  // Memorizzo tutta la QueryString in una variabile
  QS = window.location.toString();

  return getQSParamFromString(QS, ParamName, false)


  /*
  //mi faccio una copia querystring e parametro tutta MAIUSCOLA per cercare il parametro tutto maiuscolo
  QS_UPPER = QS.toUpperCase();
  ParamName = ParamName.toUpperCase();
	
  // Posizione di inizio della variabile richiesta
  var indSta=QS_UPPER.indexOf(ParamName); 
	
  // Se la variabile passata non esiste o il parametro è vuoto, restituisco null
  if (indSta==-1 || ParamName=="") return null; 
	
  // Posizione finale, determinata da una eventuale &amp; che serve per concatenare più variabili
  var indEnd=QS_UPPER.indexOf('&',indSta); 
	
  // Se non c'è una &amp;, il punto di fine è la fine della QueryString
  if (indEnd==-1) indEnd=QS.length; 
	
  // Ottengo il solore valore del parametro, ripulito dalle sequenze di escape
  var valore = unescape(QS.substring(indSta+ParamName.length+1,indEnd)); 
	
  // Restituisco il valore associato al parametro 'ParamName'
  return valore; 
  */
}



function getQSParamFromString(strQueryString, ParamName, unEncode) {
  var a;
  // Memorizzo tutta la QueryString in una variabile
  QS = strQueryString;

  //mi faccio una copia querystring e parametro tutta MAIUSCOLA per cercare il parametro tutto maiuscolo
  QS_UPPER = QS.toUpperCase();
  ParamName = ParamName.toUpperCase();


  //-- verifico se inizia per il parametro
  if (QS_UPPER.substring(0, ParamName.length + 1) == ParamName + '=')
    a = ParamName + '=';
  else
    a = '?' + ParamName + '=';

  if (QS_UPPER.indexOf(a) == -1)
    a = '&' + ParamName + '=';

  // Posizione di inizio della variabile richiesta
  var indSta = QS_UPPER.indexOf(a);

  // Se la variabile passata non esiste o il parametro è vuoto, restituisco null
  if (indSta == -1 || ParamName == "") return null;

  // Posizione finale, determinata da una eventuale &amp; che serve per concatenare più variabili
  var indEnd = QS_UPPER.indexOf('&', indSta + a.length);

  // Se non c'è una &amp;, il punto di fine è la fine della QueryString
  if (indEnd == -1) indEnd = QS.length;


  var valore = '';

  if (unEncode) {
    valore = QS.substring(indSta + a.length, indEnd);
  }
  else {
    // Ottengo il solore valore del parametro, ripulito dalle sequenze di escape
    valore = unescape(QS.substring(indSta + a.length, indEnd));
  }

  // Restituisco il valore associato al parametro 'ParamName'
  return valore;

}


function getExtraAttrib(nomeCampo, nomeAttributo) {
  var campo;
  var valore;
  var attribVal;
  var splitRes;
  var i;
  var splitVal;

  try {

    //Cerco l'input hidden
    campo = document.getElementById(nomeCampo + '_extraAttrib');

    if (campo) {
      valore = campo.value;

      splitRes = valore.split("#@#");

      //Itero sugli attributi extra
      for (i = 0; i < splitRes.length; i++) {
        splitVal = splitRes[i].split("#=#");

        //Se stiamo iterando sull'attributo richiesto
        if (splitVal[0].toUpperCase() == nomeAttributo.toUpperCase()) {
          return splitVal[1];
        }
      }
    }

  }
  catch (err) {
    alert('errore:' + err.message);
  }

  //Se l'input hidden per gli attributi extra del campo richiesto non esiste
  //Oppure non è stato trovato l'attributo richiesto nella input hidden preposta
  return '';
}

function setExtraAttrib(nomeCampo, nomeAttributo, valore) {
  var attribVal;

  try {

    //Cerco l'input hidden
    campo = document.getElementById(nomeCampo + '_extraAttrib');

    if (campo) {
      attribVal = getExtraAttrib(nomeCampo, nomeAttributo);
      campo.value = campo.value.replace(nomeAttributo + '#=#' + attribVal, nomeAttributo + '#=#' + valore);
    }
  }
  catch (err) {
    alert('errore:' + err.message);
  }

}

function isSingleWin() {
  if (typeof singleWin === 'undefined') {
    //Se la variabile singleWin non esiste
    return false;
  }
  else {
    if (singleWin.toUpperCase() == 'NO')
      return false;
    else
      return true;
  }
}


function isApplicationAccessible() {
  if (typeof ApplicationAccessible === 'undefined') {
    //Se la variabile ApplicationAccessible non esiste
    return false;
  }
  else {
    if (ApplicationAccessible.toUpperCase() == 'YES')
      return true;
    else
      return false;
  }
}

//INVIA UN FORM CON AJAX
//STR_URL=url pagina
//FORM_NAME=nome form
//OBJ_OUTPUT = se diverso da null conterrà output della chiamata
//bAsincronous = false = sincrono,true = asincrono
function SEND_FORM_AJAX(STR_URL, FORM_NAME, OBJ_OUTPUT, bAsincronous) {

  var myReq = GetXMLHttpRequest();
  var res = false;

  myReq.onreadystatechange = function () {

    if (myReq.readyState == 4) {

      if (myReq.status == 200) {

        if (OBJ_OUTPUT != null) {
          //if ( isSingleWin() )
          //	$(OBJ_OUTPUT).html( myReq.responseText);
          //else
          getObj(OBJ_OUTPUT).innerHTML = myReq.responseText;
        }

        res = true;

      }
      else {
        res = false;
      }
    }

  }

  myReq.open('POST', STR_URL, bAsincronous);
  //alert('open effettuata');
  myReq.setRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
  //myReq.send(getDatiForm(FORM_NAME));

  //chiudo tutti gli oggetti RTE del form per recuperarne il valore tecnico e salvarlo
  try {
    CloseRTE();
  }
  catch (e) {

  }

  myReq.send(getquerystring(FORM_NAME));

  return res;
}



function getDatiForm(formname) {

  return getquerystring(formname);

  /* 
	
  VERSIONE OBSOLETA E CON BUG. UTILIZZARE getquerystring
	
  */

  var stringa = "";
  var form = document.forms[formname];
  var numeroElementi = form.elements.length;

  for (var i = 0; i < numeroElementi; i++) {
    if (i < numeroElementi - 1) {
      stringa += form.elements[i].name + "=" + encodeURIComponent(form.elements[i].value) + "&";
    } else {
      stringa += form.elements[i].name + "=" + encodeURIComponent(form.elements[i].value);
    }
  }

  return stringa;
}


function AF_Alert(msg) {
  //alert( msg ); 
  DMessageBox('../../ctl_library/', msg, 'Attenzione', 2, 400, 300);

}

function DownloadFileSenzaBusta(att_hash, fileName) {
  var hash;
  var attIdObj;
  var url;
  var nomeFile;
  var ext;
  var TECHVALUE;


  hash = '';
  attIdObj = '';
  TECHVALUE = '';

  if (att_hash === undefined) {
    hash = document.getElementById('ATT_Hash').value;
  }
  else {
    hash = att_hash;
  }

  if (document.getElementById('attIdObj'))
    attIdObj = document.getElementById('attIdObj').value;

  var tmpVirtualDir;
  tmpVirtualDir = '/Application';

  if (isSingleWin())
    tmpVirtualDir = urlPortale;

  //Se stiamo nella scheda di un allegato del vecchio documento
  if (hash == '' || hash == 'NULL') {
    url = tmpVirtualDir + '/pdf.aspx?mode=ESCLUDI_BUSTA&ATT_HASH=&ATTIDOBJ=' + attIdObj;
  }
  else {
    if (fileName === undefined)
      nomeFile = document.getElementById('nomeFile_V').innerHTML;
    else
      nomeFile = fileName;

    ext = nomeFile.split('.').pop();

    var docReadOnly = '1';
    var idpfuInCharge = '';
    TECHVALUE = encodeURIComponent(nomeFile + '*' + ext + '*0*' + hash);
    try {
      //come ad esempio la versione single win Per empulia non avendo la variabile idpfuUtenteCollegato facciamo fare sempre il giro dalla pagina vb6 così da permettere la decifratura runtime del file se si è l'utente "proprietario"																																												
      if (typeof idpfuUtenteCollegato === 'undefined') {
        url = tmpVirtualDir + '/CTL_Library/functions/field/DisplayAttach.ASP?ESCLUDI_BUSTA=YES&OPERATION=DISPLAY&FIELD=&PATH=&TECHVALUE=' + TECHVALUE + '&FORMAT=INT';
      }
      else {
        docReadOnly = getObjValue('DOCUMENT_READONLY');

        try {
          idpfuInCharge = GetProperty(getObj('val_IdpfuInCharge'), 'value');
        }
        catch (e) {
          //Se manca (o va in errore) il recupero del valore di IdpfuInCharge, provo a recuperare IdPfu
          try { idpfuInCharge = getObjValue('IdPfu'); } catch (e) { }
        }

        //SE LO TROVA = 0 lo setta con idpfu
        try {
          if (idpfuInCharge == '0')
            idpfuInCharge = getObjValue('IdPfu');
        }
        catch (e) {
          if (idpfuInCharge == '0')
            idpfuInCharge = GetProperty(getObj('val_IdPfu'), 'value');
        }



        //Se l'idpfu presente sul documento e l'idpfu dell'utente collegato coincidono
        if ((idpfuInCharge == idpfuUtenteCollegato) || (ext.toLowerCase() != 'p7m' && ext.toLowerCase() != 'pdf')) {
          url = tmpVirtualDir + '/CTL_Library/functions/field/DisplayAttach.ASP?ESCLUDI_BUSTA=YES&OPERATION=DISPLAY&FIELD=&PATH=&TECHVALUE=' + TECHVALUE + '&FORMAT=INT';
        }
        else {

          //Se sono nella versione NON accessibile OPPURE se il documento è readonly OPPURE se idpfuInCharge <> idpfuUtenteCollegato
          if (isSingleWin() == false || docReadOnly == '1' || idpfuInCharge != idpfuUtenteCollegato) {
            //url = tmpVirtualDir + '/pdf.aspx?mode=ESCLUDI_BUSTA&ATT_HASH=' + hash + '&ATTIDOBJ=';

            url = tmpVirtualDir + '/CTL_Library/functions/field/sbustaRedirect.asp?ESCLUDI_BUSTA=YES&OPERATION=DISPLAY&FIELD=&PATH=&TECHVALUE=' + TECHVALUE + '&FORMAT=INT&mode=ESCLUDI_BUSTA&ATT_HASH=' + hash + '&ATTIDOBJ=';

          }
          else {
            url = tmpVirtualDir + '/CTL_Library/functions/field/DisplayAttach.ASP?ESCLUDI_BUSTA=YES&OPERATION=DISPLAY&FIELD=&PATH=&TECHVALUE=' + TECHVALUE + '&FORMAT=INT';
          }

        }
      }
    }
    catch (e) {
      url = tmpVirtualDir + '/pdf.aspx?mode=ESCLUDI_BUSTA&ATT_HASH=' + hash + '&ATTIDOBJ=';
    }

  }

  ExecFunction(url, 'DownloadAttach', ',height=200,width=500');
}

/* Funzione per per gestire il recupero di oggetti su parent o opener in versione accessibile e non */
function getObjLegacy(rifParent, strId) {

  if (isSingleWin()) {
    return getObj(strId);
  }
  else {
    if (rifParent == '') {
      rifParent = 'self';
    }

    mydocument = eval(rifParent + '.document');

    if (mydocument.all != null) {
      return mydocument.all(strId);
    }
    else {
      return mydocument.getElementById(strId);
    }
  }
}
function TxtErr(field) {
  //Se il campo esiste
  if (getObj(field)) {
    setCssClass(field, 'evidenzia_campo_obbligatorio', false);

    try { setCssClass(field + '_V', 'evidenzia_campo_obbligatorio', false); } catch (e) { }
    try { setCssClass(field + '_edit', 'evidenzia_campo_obbligatorio', false); } catch (e) { }
    try { setCssClass(field + '_edit_new', 'evidenzia_campo_obbligatorio', false); } catch (e) { }
    try { setCssClass('DIV_' + field + '_ATTACH_EMPTY', 'evidenzia_campo_obbligatorio', false); } catch (e) { }
  }
  else {
    alert('errore di configurazione.campo ' + field + ' inesistente');
  }
}

function TxtOK(field) {
  //Se il campo esiste
  if (getObj(field)) {
    setCssClass(field, 'evidenzia_campo_obbligatorio', true);

    try { setCssClass(field + '_V', 'evidenzia_campo_obbligatorio', true); } catch (e) { }
    try { setCssClass(field + '_edit', 'evidenzia_campo_obbligatorio', true); } catch (e) { }
    try { setCssClass(field + '_edit_new', 'evidenzia_campo_obbligatorio', true); } catch (e) { }
    try { setCssClass('DIV_' + field + '_ATTACH_EMPTY', 'evidenzia_campo_obbligatorio', true); } catch (e) { }

  }
  else {
    alert('errore di configurazione.campo ' + field + ' inesistente');
  }
}
//setCssClass(field,'evidenzia_campo_obbligatorio', false);
function setCssClass(field, classe, bRemove) {
  var objField = getObj(field);
  //var oldClass = objField.getAttribute('class');
  //if ( oldClass == undefined || oldClass == 'null' )
  //	oldClass='';

  if (objField.type != 'select-one' && objField.length > 1)
    objField = objField[0];


  if (objField.type == 'checkbox') {
    try { objField = getObj(field).offsetParent; } catch (e) { }
  }

  if (objField.type == 'radio') {
    try { objField = objField.offsetParent; } catch (e) { }
    try { objField = objField.offsetParent; } catch (e) { }
  }

  var oldClass = objField.getAttribute('class');
  if (oldClass == undefined || oldClass == 'null')
    oldClass = '';

  if (bRemove == false) {
    objField.setAttribute('class', oldClass + ' ' + classe + ' ');
  }
  else {
    oldClass = ReplaceExtended(oldClass, ' ' + classe + ' ', ' ');
    objField.setAttribute('class', oldClass);
  }

}

function isNumeric(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}

function generaFormValueAndSubmit(val, dest, target) {
  /*
  //Genero dinamicamente il form impostandogli il post, la pagina di destinazione e la finestra target
  var f = document.createElement('form');
  f.setAttribute('method','post');
  f.setAttribute('action',dest);
  f.setAttribute('style','display:none');
  f.setAttribute('target',target);
  //Genero dinamicamente un input hidden di nome 'value' e ci carico dentro il valore passato alla funzione
  var i = document.createElement('input');
  i.setAttribute('type','hidden');
  i.setAttribute('name','value');
  i.setAttribute('value',value);
  f.appendChild(i);
  //Aggiungo il form appena creato al DOM
  document.getElementsByTagName('body')[0].appendChild(f);
  //Eseguo il submit
  f.submit();
  //Dopo averlo generato ed effettuato la submit, lo cancello dal DOM
  document.getElementsByTagName('body')[0].removeChild(f);
  */

  var campi = { value: val };

  generaFormCollectionAndSubmit(campi, dest, target);

}



//spostata da sec_dettagli.js per le stampe
function ShowCol(Section, idCol, Show) {
  try {
    var ColName = Section + 'Grid_' + idCol;
    var objGrid = getObj(Section + 'Grid');

    var h = objGrid.rows.length;
    var w = objGrid.rows[0].cells.length;
    var x, y;

    for (x = 0; x < w; x++) {

      if (objGrid.rows[0].cells[x].id == ColName) {
        for (y = 0; y < h; y++) {
          objGrid.rows[y].cells[x].style.display = Show;
        }
        break;
      }
    }
  }
  catch (e) { };
}

// Esempio d'uso generaFormCollectionAndSubmit ( {value: 'pippo', filter: '1=1', c: 3}, 'URL_PAGINA.ASP?XXX', 'target')
function generaFormCollectionAndSubmit(campi, dest, target) {
  //Genero dinamicamente il form impostandogli il post, la pagina di destinazione e la finestra target
  var f = document.createElement('form');
  f.setAttribute('method', 'post');
  f.setAttribute('action', dest);
  f.setAttribute('style', 'display:none');
  f.setAttribute('target', target);

  var i;

  //Genero dinamicamente una serie di input hidden 1 ad 1 con la collection "campi" passata
  for (var chiave in campi) {
    i = document.createElement('input');
    i.setAttribute('type', 'hidden');
    i.setAttribute('name', chiave);
    i.setAttribute('value', campi[chiave]);

    f.appendChild(i);
  }


  //Aggiungo il form appena creato al DOM
  document.getElementsByTagName('body')[0].appendChild(f);

  //Eseguo il submit
  f.submit();

  //Dopo averlo generato ed effettuato la submit, lo cancello dal DOM
  document.getElementsByTagName('body')[0].removeChild(f);
}

//html decode 
function decodeHTMLEntities(text) {
  return $("<textarea/>")
    .html(text)
    .text();
}


//-- applica il filtro a tutta la colonna basando il presupposto che ci troviamo sulla prima riga
//strNameColNotEditable = nome colonna che contiene la lista delle colonne non editabili; riga per riga se non contiene la nostra colonna
//						  applico filterdom
function FilterDomFirstRowCol(objName, FieldName, valore, filter, row, OnChange, format, strParamPath, Editable, FieldName_NotEditable) {
  //determino il nome della cella da aggiornare (con o senza SEZ_IDGrid)
  //se row è lungo 1 allora contiene solo indice della riga
  //altrimenti 'RESPONSABILEGrid_0'
  var LocRow = '';
  if (row.length > 1) {
    LocRow = row.substring(0, row.length - 1);
    LocRow = 'R' + LocRow;

  }
  else
    LocRow = 'R' + LocRow;



  //se non passata vuol dire che non esiste
  if (FieldName_NotEditable == undefined)
    FieldName_NotEditable = '';


  var strValueNot_Editable = '';

  //ciclo sulla griglia fino a quando trovo la mia colonna editabile e faccio la filterdom per ottenere il dominio filtrato
  var bFilterDom_Made = false;

  var k = 0;
  var Row_New;
  while (!bFilterDom_Made) {

    strValueNot_Editable = '';

    if (FieldName_NotEditable != '')
      //getObjValue('R'+i+'_NotEditable') == '' || getObjValue('R'+i+'_NotEditable') == 'undefined' 
      strValueNot_Editable = getObjValue(LocRow + k + '_' + FieldName_NotEditable);


    //'RRESPONSABILEGrid_' + i + '_pfuResponsabileUtente'
    // Motivazione , StatoAnomalia 
    //se la colonna dei non editabili non esiste oppure non contiene FieldName (la nostra colonna da filtrare ) allora chiamo la filterdom
    if (strValueNot_Editable.indexOf(' ' + FieldName + ' ') == -1) {

      //determino la prossima row correttamente
      if (row.length > 1)
        Row_New = row.substring(0, row.length - 1) + k;
      else
        Row_New = k;


      FilterDom(LocRow + k + '_' + FieldName, FieldName, getObjValue(LocRow + k + '_' + FieldName), filter, Row_New, OnChange, format, strParamPath, Editable)
      bFilterDom_Made = true;

    }

    k = k + 1;

  }

  //-- per la prima riga applico il comportamento base
  //FilterDom( objName , FieldName , valore , filter , row  , OnChange, format, strParamPath, Editable)
  //var LocRow = row.substring( 0 , row.length -1);
  //var r = 1;
  var r = k;
  var Valore_R;


  var rBase = k - 1;

  //-- applico lo stesso dominio a tutta la colonna
  //var HtmlBase = getObj( 'val_' + LocRow + '0_' + FieldName ).innerHTML;
  var HtmlBase = getObj('val_' + LocRow + rBase + '_' + FieldName).innerHTML;
  var bExistField = true;
  while (bExistField) {
    try {

      //se sulla riga la colonna è editabile effettuo la sostituzione
      strValueNot_Editable = '';

      if (FieldName_NotEditable != '')
        strValueNot_Editable = getObjValue(LocRow + r + '_' + FieldName_NotEditable);

      if (strValueNot_Editable.indexOf(' ' + FieldName + ' ') == -1) {
        //-- recupero il valore
        Valore_R = getObjValue(LocRow + r + '_' + FieldName);

        //-- elimino il campo per evitare ridondanze
        getObj(LocRow + r + '_' + FieldName).outerHTML = '';

        //-- aggiusto il dominio per la riga
        HtmlBaseRiga = ReplaceExtended(HtmlBase, LocRow + rBase, LocRow + r);

        //-- lo ricreo con il dominio
        getObj('val_' + LocRow + r + '_' + FieldName).innerHTML = HtmlBaseRiga;

        //-- setto il valore precedente
        getObj(LocRow + r + '_' + FieldName).value = Valore_R;
      }
      r++;
    }
    catch (e) { bExistField = false; }
  }

}



//riportata da getobj della 19 usata nel file errorespid.asp,loginsso.asp,newtoolbaafs.asp
function applicationLogOut(goTo) {

  try {

    var nocache = new Date().getTime();

    ajax = GetXMLHttpRequest();

    if (ajax) {
      ajax.open("GET", '/application/logout.asp?nocache=' + nocache, false);
      ajax.send(null);

      if (ajax.readyState == 4) {
        if (ajax.status == 200) {
        }
      }

    }

  }
  catch (e) {
  }

  if (typeof goTo === 'undefined' || goTo == '') {
    parent.close();
  }
  else {
    window.location = goTo;





  }

  return true;

}


//è stata riportata in getobj perchè su empulia main.js non è incluso
function ExecFunctionAttach(Url, target, param_legacy) {

  var me;
  var posML = Url.indexOf('#ML.');
  var tmpPath = '../';
  try {

    //Se trovo una chiave di multilinguismo da sostituire
    if (posML >= 0) {


      if (isSingleWin()) {
        tmpPath = pathRoot;
      }

      var chiaveML = '';
      var carattereML = '';
      for (var i = posML + 4; i < Url.length; i++) {
        carattereML = Url.charAt(i);

        if (carattereML != '#')
          chiaveML += carattereML;
        else
          break;
      }

      var chiaveCnv = CNV(tmpPath, chiaveML);

      if (chiaveCnv.indexOf('???') == -1) {
        Url = Url.replace('#ML.' + chiaveML + '#', chiaveCnv);
      }


    }
  }
  catch (e) { }

  if (target == 'self') {

    self.document.write('<table width="100%" height="100%">')
    self.document.write('<tr>')
    self.document.write('<td width="100%" height="100%" valign="middle" align="center" ><label id="_loading" name="_loading" ><font Arial size=1>Loading... </font></label>')
    self.document.write('</td>')
    self.document.write('</tr>')
    self.document.write('</table>')

    self.location = Url;
  }
  else {


    if (typeof target !== "undefined") {
      target = target.replace('<', '').replace('>', '');
    }

    var TECHVALUE = getQSParamFromString(Url, 'TECHVALUE', true);
    var FORMAT = getQSParamFromString(Url, 'FORMAT', false);
    splitRes = FORMAT.split("EXT:");
    //SOLO SE PRESENTE LA FORMAT DEI MULTIALLEGATI VALORIZZA IL FORM E TOGLIE DA URL IL TECHVALUE
    if (splitRes[0].indexOf('M') > -1) {
      //TOGLIE TECHVALUE da URL e metto TECHBUFFER=YES per capire nella nuova gestione allegati se recuperare dal DB i nuovi allegati
      splitURL = Url.split("&");
      //Itero sugli attributi extra
      newURL = '';
      for (i = 0; i < splitURL.length; i++) {
        if (splitURL[i].split("=")[0].toUpperCase() != 'TECHVALUE') {
          newURL = newURL + splitURL[i] + '&';
        }
      }
      newURL = newURL + 'TECHBUFFER=YES';
      Url = newURL;
      window.open('', target, 'toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=yes,scrollbars=yes,height=450,width=600');
      if (Url.indexOf('../../') != -1)
        generaFormValueAndSubmit(TECHVALUE, Url, target);
      else
        generaFormValueAndSubmit(TECHVALUE, tmpPath + Url, target);

    }
    else {

      //inizialmente c'erano 2 livelli di ctl_library per cui gli oggetti effettuavano la chiamata alla pagina uploadattach in due modi, con questo controllo verifico che tutti gli oggetti facciano lo stesso percorso per arrivare alla pagina asp
      if (Url.indexOf('../../') != -1)
        return window.open(Url, target, 'toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=yes,scrollbars=yes,height=450,width=600');
      else
        return window.open(tmpPath + Url, target, 'toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=yes,scrollbars=yes,height=450,width=600');
    }

  }
}


//risolve anomalia relativa alla direttiva "position:absolute;" che rovinava il layout della pagina rendendo non raggiungibili i comandi della toolbar
function SetPositionRecursive(Nodo, Val) {
  try {
    Nodo.style.position = Val; // 'relative';

    for (var i = 0; i < Nodo.childNodes.length; i++) {
      SetPositionRecursive(Nodo.childNodes[i], Val);
    }
  } catch (e) { };

}

//Editable; se = no volgio il campo non editabile altrimenti editabile
//siccome prima non esisteva per default è editabile
function Get_HTML_Attrib(FieldName, valore, filter, row, OnChange, format, strParamPath, Editable) {
  var nocache = new Date().getTime();
  var strTmpPath = '../../';
  var strTemp = '';

  format = format || ''; // Setto stringa vuota come default del parametro opzionale format

  ajax = GetXMLHttpRequest();

  if (ajax) {
    /* SE SIAMO NELLA VERSIONE A SINGOLA FINESTRA IL PATH E' PRESENTE NELLA VARIABILE PATHROOT */
    if (isSingleWin()) {
      strTmpPath = pathRoot;
    }
    else {
      /* PER LA VERSIONE MULTI FINESTRA, VEDI EMPULIA, IL PATH LO RECUPERIAMO DAL PARAMETRO OPZIONALE strParamPath SE PASSATO (UTILE PER I VIEWER). ALTRIMENTI USIAMO IL DEFAULT DI PRIMA */
      if (strParamPath === undefined) {
        strTmpPath = '../../';
      }
      else {
        strTmpPath = strParamPath;
      }
    }

    if (Editable == undefined)
      Editable = 'yes';

    ajax.open("GET", strTmpPath + 'CTL_Library/GetFilteredField.asp?EDITABLE=' + Editable + '&FIELD=' + FieldName + '&VALUE=' + encodeURIComponent(valore) + '&FILTER=' + encodeURIComponent(filter) + '&ROW=' + row + '&ONCHANGE=' + encodeURIComponent(OnChange) + '&FORMAT=' + encodeURIComponent(format) + '&nocache=' + nocache, false);

    ajax.send(null);

    if (ajax.readyState == 4) {

      if (ajax.status == 200) {
        //-- funziona solo per i domini chiusi perchè sono in un div
        strTemp = ajax.responseText;
      }
    }
  }

  return strTemp;
}


//setta il campo readonly 
function ReadOnlyObj(objName, b) 
{
	//è da verificare se funziona con tutti i tipi di controlli
	try { getObj(objName).readOnly = b; } catch (e) { };
	
	
}
	