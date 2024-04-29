var g_Modify_QUESTIONARIO = 0;

$(document).ready(function () {
  try {
    Init();
  } catch (error) { }
});

function Init() {
  //inizializzo l'area del genera PDF se non sono in stampa
  var InStampa;
  try {
    InStampa = InToPrintDocument;
  } catch (e) { InStampa = 0 }

  //se non sono in stampa gestisco i bottoni per il GENERA PDF
  if (InStampa == 0) {
    InitPdf();
  }
  else {
    //se sono in stampa tolgo la caption del doucmento
    //getObj('CAPTION_DOCUMENT_ID').style.display='none';
    $(".Caption").css({ "display": "none" });
  }

  //Nascondo/visualizzo le sezioni condizionate  
  ShowOrHide_SezioniCondizionate();

  // Si aggiunte la classe width_100_percent per i campi attach perchè la libreria non aggiunge la proprietà Style per questi campi
  MakeAttachFields100PercentWide();
}

function InitPdf() {
  try {
    Stato = getObj('StatoDoc').value;
    CAN_MOD = getObj('colonnatecnica').value;

    if ((getObjValue('SIGN_LOCK') == '0' || getObjValue('SIGN_LOCK') == '') && (Stato == 'Saved' || Stato == "") && CAN_MOD == 'si') {
      document.getElementById('generapdf').disabled = false;
      document.getElementById('generapdf').className = "generapdf";
    }
    else {
      document.getElementById('generapdf').disabled = true;
      document.getElementById('generapdf').className = "generapdfdisabled";
    }

    if (getObjValue('SIGN_LOCK') != '0' && (Stato == 'Saved') && CAN_MOD == 'si') {
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
  }
  catch (e) { }
}

function GeneraPDF() {
  var statoDoc = getObj('DOCUMENT_READONLY').value;
  var nomeFile = new Date().getTime();

  if (statoDoc == '1') {
    return;
  }

  if (ControlliObligatorieta()) {
    DMessageBox('../', 'Compilare il QUESTIONARIO AMMINISTRATIVO in tutti i suoi campi obbligatori, successivamente effettuare nuovamente il comando genera pdf.', 'Attenzione', 1, 400, 300);
    return;
  }

  //se ho fatto una modifca richiedo un salvataggio
  if (g_Modify_QUESTIONARIO === 1) {
    // DMessageBox('Per effettuare il \"Genera PDF\" si richiede prima un salvataggio. Verra\' effettuato in automatico, successivamente effettuare nuovamente il comando di \"Genera PDF\"', 'Attenzione', 1, 400, 300);
    DMessageBox('../', 'Per procedere si richiede prima un salvataggio, successivamente effettuare nuovamente il comando genera pdf.', 'Attenzione', 1, 400, 300);
    // SaveDoc('');
    return;
  }

  scroll(0, 0);

  ToPrintPdfSign('VIEW_FOOTER_HEADER=QUESTIONARIO_AMMINSTRATIVO_HF_Stampe&TABLE_SIGN=CTL_DOC&PDF_NAME=MODULO_QUESTIONARIO_AMMINISTRATIVO_' + nomeFile + '&lo=print&NO_SECTION_PRINT=DISPLAY_FIRMA&ML_FOOTER=&JSCRIPT_STAMPA=YES&JSCRIPT_STAMPA_NAME=MODULO_QUESTIONARIO_AMMINISTRATIVO&PROCESS=MODULO_QUESTIONARIO_AMMINISTRATIVO@@@VERIFICA_CAMPI_OBBLI');
  //ToPrintPdfSign('VIEW_FOOTER_HEADER=QUESTIONARIO_AMMINSTRATIVO_HF_Stampe&TABLE_SIGN=CTL_DOC&PDF_NAME=MODULO_QUESTIONARIO_AMMINISTRATIVO_' + nomeFile + '&lo=print&NO_SECTION_PRINT=DISPLAY_FIRMA&ML_FOOTER=ML_FOOTER_PAGING_PDF&JSCRIPT_STAMPA=YES&JSCRIPT_STAMPA_NAME=MODULO_QUESTIONARIO_AMMINISTRATIVO&' );
}

function GeneraPDF_E() {
  var nomeFile = new Date().getTime();

  ToPrintPdf('VIEW_FOOTER_HEADER=QUESTIONARIO_AMMINSTRATIVO_HF_Stampe&TABLE_SIGN=CTL_DOC&PDF_NAME=MODULO_QUESTIONARIO_AMMINISTRATIVO_' + nomeFile + '&lo=print&NO_SECTION_PRINT=DISPLAY_FIRMA&ML_FOOTER=&JSCRIPT_STAMPA=YES&JSCRIPT_STAMPA_NAME=MODULO_QUESTIONARIO_AMMINISTRATIVO&PROCESS=');
}

function TogliFirma() {
  ExecDocProcess('SIGN_ERASE,FirmaDigitale');
}

function AllegaDOCFirmato() {
  var idDoc = getObjValue('IDDOC');
  ExecFunctionCenterDoc('../functions/field/uploadattachsigned.asp?TABLE=ctl_doc&amp;IDDOC=' + idDoc + '&amp;OPERATION=INSERTSIGN&amp;IDENTITY=Id&amp;AREA=&amp;DOMAIN=FileExtention&amp;FORMAT=#AllegaFirma#600,400')
}

function OnChangeFields_QUESTIONARIO(obj) {
  g_Modify_QUESTIONARIO = 1;

  SetFieldsAsOk(obj.id);
  ShowOrHide_SezioniCondizionate();
}

function SetFieldsAsOk(parametro) {
  if (parametro.includes('DIV_')) {
    parametro = parametro.replace('DIV_', '');
  }

  if (parametro.includes('_ATTACH_EMPTY')) {
    parametro = parametro.replace('_ATTACH_EMPTY', '');
  }
  else if (parametro.includes('_Multivalore')) {
    parametro = parametro.replace('_Multivalore', '');
  }

  parametro = parametro.slice(0, 13); //Esempio => da questo "PARAMETRO_1_1_2_V" a questo "PARAMETRO_1_1"

  var paramObj = getObj(parametro);

  // Se è SceltaSingola (DropDown) o testo
  if (paramObj.type === 'select-one' || paramObj.type === 'text') {
    TxtOK(parametro);
    return;
  }

  // Se è allegato (non firmato) o allegato firmato
  if (getObj('DIV_' + parametro + '_ATTACH_EMPTY')) {
    TxtOK('DIV_' + parametro + '_ATTACH_EMPTY');
    return;
  }
  else if (getObj('DIV_' + parametro + '_Multivalore')) {
    TxtOK('DIV_' + parametro + '_Multivalore');
    return;
  }

  // Per campi data, ora, minuti, secondi, numerici
  if (getObj(parametro + '_V')) {

    // Si ha un campo numerico o data allora si chiama la TxtOK sul campo con _V
    TxtOK(parametro + '_V');
    return;
  }

  if (getObj(parametro + '_HH_V')) {
    TxtOK(parametro + '_HH_V');
    return;
  }
  if (getObj(parametro + '_MM_V')) {
    TxtOK(parametro + '_MM_V');
    return;
  }
  if (getObj(parametro + '_SS_V')) {
    TxtOK(parametro + '_SS_V');
    return;
  }

  // // Se si tratta di SceltaSingola come radio buttons
  // if (paramObj && paramObj.type === "radio") {
  //   var allNodesForSceltaSingola = document.querySelectorAll("input[type='radio']");//.filter(node => node.id === parametro);
  //   if (allNodesForSceltaSingola && allNodesForSceltaSingola !== null && allNodesForSceltaSingola.length > 0) {
  //     // Cicla tutti i nodi trovati
  //     for (var index = 0; index < allNodesForSceltaSingola.length; index++) {
  //       if (allNodesForSceltaSingola[0].id === parametro) {
  //         allNodesForSceltaSingola[index].parentElement.parentElement.className = allNodesForSceltaSingola[index].parentElement.parentElement.className.replace(" evidenzia_campo_obbligatorio", '');
  //       }
  //     }
  //   }
  //   return;
  // }

  // Se si tratta di SceltaMultipla
  {
    var firstObj = getObj(parametro + '_1_Desc'); // Should at least be one element for SceltaMultipla
    var tBody = firstObj.parentElement.parentElement.parentElement; // table's body

    // Loop through all the element of the table
    for (var index = 1; index <= tBody.childNodes.length; index++) {
      // TxtErr(parametro + '_' + index + '_Desc');
      var tmpObj = getObj(parametro + '_' + index + '_Desc');
      tmpObj.parentElement.className = tmpObj.parentElement.className.replace(" evidenzia_campo_obbligatorio", '');
    }
  }
}

function ControlliObligatorieta() {
  if (getObj('DOCUMENT_READONLY').value !== '1' && JsonCampiObbligatori && JsonCampiObbligatori !== '') {
    // Esempio => JsonCampiObbligatori = 'PARAMETRO_1_2@@@2,PARAMETRO_2_2@@@7';
    //    Devo controllare se un campo è obligatorio se la sezione di appartenenza è visualizzata

    var parametro_chaiveUnivoca_array = JsonCampiObbligatori.split(',');
    var hasErrors = false;
    var isFocusSet = false;

    // Prendo le sezioni visualizzate
    for (var z = 0; z < parametro_chaiveUnivoca_array.length; z++) {
      var infoparam = parametro_chaiveUnivoca_array[z];

      var parametro = infoparam.split('@@@')[0];
      var chiaveUnivocaRiga = infoparam.split('@@@')[1];

      var sezioneObj = getObj('SEZIONE_' + chiaveUnivocaRiga);

      // Controllo se la sezione è visualizzata
      if (sezioneObj.style.display !== 'none') {

        var paramObj = getObj(parametro);

        if ((paramObj.type === 'select-one' || paramObj.type === 'text') && paramObj.value === '') {
          // Gestisce i campi: SceltaSingola e testo  
          TxtErr(parametro);
          hasErrors = true;
          isFocusSet = SetFocusOnFirstError(hasErrors, isFocusSet, paramObj, parametro);
        }
        else if (paramObj.type === 'hidden' && paramObj.value === '') { // Gestisce i campi: numerici, data, allegati, SceltaMultipla
          var objToFocus;

          // Se è allegato (non firmato) o allegato firmato
          if (getObj('DIV_' + parametro + '_ATTACH_EMPTY')) {
            TxtErr('DIV_' + parametro + '_ATTACH_EMPTY');
            objToFocus = getObj('DIV_' + parametro + '_ATTACH_EMPTY');
          }
          else if (getObj(parametro + '_V')) {
            // Per campo data e numerico si chiama la TxtErr sul campo con _V
            TxtErr(parametro + '_V');
            objToFocus = getObj(parametro + '_V');
          }
          else {
            var firstObj = getObj(parametro + '_1_Desc'); // Should at least be one element for SceltaMultipla
            var tBody = firstObj.parentElement.parentElement.parentElement; // table's body

            // Loop through all the element of the table
            for (var index = 1; index <= tBody.childNodes.length; index++) {
              // Add class for mandatory fields if it doesn't already exists
              if (!getObj(parametro + '_' + index + '_Desc').parentElement.className.includes('evidenzia_campo_obbligatorio')) {
                getObj(parametro + '_' + index + '_Desc').parentElement.className += " evidenzia_campo_obbligatorio";
              }
              objToFocus = getObj(parametro + '_1_V');
            }
          }

          hasErrors = true;
          isFocusSet = SetFocusOnFirstError(hasErrors, isFocusSet, objToFocus, parametro);
        }

        // Verifico che ci sia il campo ora
        var hoursObj = getObj(parametro + '_HH_V');
        if (hoursObj && hoursObj.value === '') {
          TxtErr(parametro + '_HH_V');
          hasErrors = true;
          isFocusSet = SetFocusOnFirstError(hasErrors, isFocusSet, hoursObj);
        }

        // Verifico che ci sia il campo minuti
        var minutesObj = getObj(parametro + '_MM_V');
        if (minutesObj && minutesObj.value === '') {
          TxtErr(parametro + '_MM_V');
          hasErrors = true;
          isFocusSet = SetFocusOnFirstError(hasErrors, isFocusSet, minutesObj);
        }

        // Verifico che ci sia il campo secondi
        var secondsObj = getObj(parametro + '_SS_V');
        if (secondsObj && secondsObj.value === '') {
          TxtErr(parametro + '_SS_V');
          hasErrors = true;
          isFocusSet = SetFocusOnFirstError(hasErrors, isFocusSet, secondsObj);
        }
      }
    }

    return hasErrors;
  }
}

function SetFocusOnFirstError(hasErrors, isFocusSet, obj, parametro) {
  if (hasErrors && !isFocusSet) {
    if (obj.type === 'select-one' || obj.type === 'text' || obj.type === 'checkbox') {
      obj.focus();
    }
    else { // If obj is a div for an attachment or signed attachment
      getObj(parametro + '_V_BTN').focus();
    }

    return true;
  }

  return isFocusSet;
}

// Aggiunta perchè il PDF sembra non trovare il path del js getObj.js
function getObj(strId) {
  if (document.all != null) {
    return document.all(strId);
  }
  else {
    return document.getElementById(strId);
  }
}

function ShowOrHide_SezioniCondizionate() {
  // JSon_Sezionicondizionate è una variabile che si trova nel DOM, in un script javascript

  if (JSon_Sezionicondizionate && JSon_Sezionicondizionate !== '') {
    // Esempio => JSon_Sezionicondizionate = 'PARAMETRO_1_1:valore1###5@@@valore2###12,PARAMETRO_1_2:valore4###5'
    //   Ricavo le sezioni condizinate (nel esempio la 5 e 12)

    var sezioniCondizionate = JSon_Sezionicondizionate.split(','); // sezioniCondizionate = ['PARAMETRO_1_1:valore1###5@@@valore2###12', 'PARAMETRO_1_2:valore4###5']

    var chiaveUnivocaRigaList = []; // List of numbers as strings
    var parametroValoreChaiveUnivocaList = []; // List of objects

    for (var j = 0; j < sezioniCondizionate.length; j++) {
      var sezione = sezioniCondizionate[j]; // sezione = 'PARAMETRO_1_1:valore1###5@@@valore2###12'
      var separatorIndex = sezione.indexOf(':') + 1; // separatorIndex = 14
      var parametro = sezione.slice(0, separatorIndex - 1) // parametro = 'PARAMETRO_1_1'

      var sezione = sezione.slice(separatorIndex, sezione.length); // sezione = 'valore1###5@@@valore2###12'
      //sezione = sezione.substring(separatorIndex,sezione.length);

      var valore_ChaiveUnivoca_List = sezione.split('@@@'); // valore_ChaiveUnivoca_List = ['valore1###5', 'valore2###12']

      for (var index = 0; index < valore_ChaiveUnivoca_List.length; index++) {
        var chiaveUnivocaRiga = valore_ChaiveUnivoca_List[index].split('###')[1]; // chiaveUnivocaRiga = 5

        parametroValoreChaiveUnivocaList.push({
          parametro: parametro,
          valore: valore_ChaiveUnivoca_List[index].split('###')[0], // valore = 'valore1'
          chiaveUnivocaRiga: chiaveUnivocaRiga
        })//  parametroValoreChaiveUnivocaList = [
        //      {
        //        parametro: 'PARAMETRO_1_1',
        //        valore: 'valore1',
        //        chiaveUnivocaRiga: '5'
        //      },
        //      {
        //        parametro: 'PARAMETRO_1_2',
        //        valore: 'valore1',
        //        chiaveUnivocaRiga: '6'
        //      },
        //      {
        //        parametro: 'PARAMETRO_1_3',
        //        valore: 'valore1',
        //        chiaveUnivocaRiga: '5'
        //      },
        //      {
        //        parametro: 'PARAMETRO_1_1',
        //        valore: 'valore1',
        //        chiaveUnivocaRiga: '3'
        //      }
        //    ]

        chiaveUnivocaRigaList.push(chiaveUnivocaRiga); // chiaveUnivocaRigaList = [5]
      }
    }

    chiaveUnivocaRigaList = chiaveUnivocaRigaList.filter(OnlyUnique); // Rimuovo i duplicati	

    // Di default nascondo le sezioni condizionate
    // (Nel esempio la 5 e la 12)
    HideConditionedSections(chiaveUnivocaRigaList);

    // Per le sezioni condizionate (quindi nascoste), se per una sezine è soddisfatta la condizine di visualizzazione (per la sezione 5: PARAMETRO_1_1 === valore1) allora la visualizzo
    // SceltaSingola getObj(PARAMETRO_1_1)===valore1
    // Se il parametro è SceltaMutipla il valore di condizione deve essere contenuto nel valore dell'attributo (fatti cosi, ###valore1### oppure ###valore1###valore2###)
    ShowConditionedSections(parametroValoreChaiveUnivocaList);

    // Svuoto i campi delle sezioni nascoste
    EmptyFieldsForHidenSection(chiaveUnivocaRigaList, parametroValoreChaiveUnivocaList);
  }
}

function OnlyUnique(value, index, array) {
  // Returns only the unique values within the array
  return array.indexOf(value) === index;
}

function HideConditionedSections(chiaveUnivocaRigaList) {
  for (var z = 0; z < chiaveUnivocaRigaList.length; z++) {
    chiave = chiaveUnivocaRigaList[z];
    getObj('SEZIONE_' + chiave).style.display = 'none';
    //document.write ('SEZIONE_' + chiave);
  }
}

function ShowConditionedSections(parametroValoreChaiveUnivocaList) {
  for (var y = 0; y < parametroValoreChaiveUnivocaList.length; y++) {
    element = parametroValoreChaiveUnivocaList[y];

    var parametroValore = getObj(element.parametro).value; // parametroValore = "469599_1.1@giallo"

    if (parametroValore != '') {
      var valore = parametroValore.split('@')[1]; // valore = "giallo"
      var param = '###' + valore + '###'; // param = '###giallo###'

      // Con la funzione includes() controllo sia per il caso SceltaSingola che SceltaMutipla
      //if ( param.includes('###' + element.valore + '###') ) 
      if (param.indexOf('###' + element.valore + '###') !== -1) {
        getObj('SEZIONE_' + element.chiaveUnivocaRiga).style.display = '';
      }
    }
  }
}

function EmptyFieldsForHidenSection(chiaveUnivocaRigaList, parametroValoreChaiveUnivocaList) {
  for (var z = 0; z < chiaveUnivocaRigaList.length; z++) {
    chiave = chiaveUnivocaRigaList[z];

    if (getObj('SEZIONE_' + chiave).style.display.includes('none')) {
      // Svuotare i parametri per la sezione nascosta (ci sono i casi SceltaSingola e SceltaMultipla)
      // Prendo gli oggetti che hanno per 'chiaveUnivocaRiga' il valore diverso da 'chiave'
      var filteredObjects = parametroValoreChaiveUnivocaList.filter(function (obj) {
        return obj.chiaveUnivocaRiga !== chiave;
      });

      // Se si tratta di SceltaMultipla
      EmptyFieldsIfSceltaMultipla(chiave, filteredObjects);
      // Se si tratta di SceltaSingola
      EmptyFieldsIfSceltaSingola(chiave, filteredObjects);


      /* // TODO: evaluate if the commented code is to be removed
      // // Se si tratta di campi di type text (testo, data, numero)
      // var allNodesForTextType = document.getElementById("SEZIONE_" + chiave).querySelectorAll("input[type='text']");
      // if (allNodesForTextType && allNodesForTextType !== null && allNodesForTextType.length > 0) {
      //   for (var index = 0; index < allNodesForTextType.length; index++) {
      //     allNodesForTextType[index].value = '';
      //   }
      // }

      // // Se si tratta di campo Allegato (ed il file è stato inserito) ==> è da migliorare
      // const partialIdStart = "PARAMETRO_";// + chiave + "_"; // Partial string at the beginning of the ID
      // const partialIdEnd = "_V_BTN"; // Partial string at the end of the ID
      // const selector = '[id^="' + partialIdStart + '"][id$="' + partialIdEnd + '"]';
      // var allNodesAllegato = document.getElementById("SEZIONE_" + chiave).querySelectorAll(selector);
      // if (allNodesAllegato && allNodesAllegato !== null && allNodesAllegato.length > 0) {
      //   // set_clear_value();
      //   alert('Trovato allegato');
      // }

      // // Se si tratta di campi di type hidden
      // var allNodesForTextType = document.getElementById("SEZIONE_" + chiave).querySelectorAll("input[type='hidden']");
      // if (allNodesForTextType && allNodesForTextType !== null && allNodesForTextType.length > 0) {
      //   for (var index = 0; index < allNodesForTextType.length; index++) {
      //     if(allNodesForTextType[index].id.includes("_extraAttrib") === false){
      //       allNodesForTextType[index].value = '';
      //     }
      //   }
      // }*/
    }
  }
}

function EmptyFieldsIfSceltaMultipla(chiave, filteredObjects) {
  var allNodesForSceltaMultipla = document.getElementById("SEZIONE_" + chiave).querySelectorAll("input[type='checkbox']");

  if (allNodesForSceltaMultipla && allNodesForSceltaMultipla !== null && allNodesForSceltaMultipla.length > 0) {
    // Cicla tutti i nodi trovati
    for (var index = 0; index < allNodesForSceltaMultipla.length; index++) {
      // Esempio: allNodesForSceltaMultipla[index].id = "PARAMETRO_2_1_2_Desc"
      var nodeParametro = allNodesForSceltaMultipla[index].id.slice(0, 13) // nodeParametro = 'PARAMETRO_2_1'

      // Esempio: allNodesForSceltaMultipla[index].value = "469599_2.1@napoli"
      var nodeValore = allNodesForSceltaMultipla[index].value.split('@')[1]; // nodeValore = 'napoli'

      for (var i = 0; i < filteredObjects.length; i++) {
        if (filteredObjects[i].parametro === nodeParametro && filteredObjects[i].valore === nodeValore) {
          // Solo se il nodo con il corrente indice condiziona una sezione allora si svuota il nodo di tipo SceltaMultipla
          allNodesForSceltaMultipla[index].checked = false;
          getObj(nodeParametro).value = ''; // Hidden fields
          getObj('SEZIONE_' + filteredObjects[i].chiaveUnivocaRiga).style.display = 'none';
        }
      }
    }
  }
}

function EmptyFieldsIfSceltaSingola(chiave, filteredObjects) {
  /*  Caso in cui SceltaSingola sia drop-down, ossia una select
   */
  var allNodesForSceltaSingola = document.getElementById("SEZIONE_" + chiave).querySelectorAll("select");

  if (allNodesForSceltaSingola && allNodesForSceltaSingola !== null && allNodesForSceltaSingola.length > 0) {
    // Cicla tutti i nodi trovati
    for (var index = 0; index < allNodesForSceltaSingola.length; index++) {
      // Esempio: allNodesForSceltaSingola[index].id = "PARAMETRO_3_4"
      var nodeParametro = allNodesForSceltaSingola[index].id.slice(0, 13) // nodeParametro = 'PARAMETRO_3_4'

      // Esempio: allNodesForSceltaMultipla[index].value = "471367_3.4@in piedi"
      var nodeValore = allNodesForSceltaSingola[index].value.split('@')[1]; // nodeValore = 'in piedi'

      for (var i = 0; i < filteredObjects.length; i++) {
        if (filteredObjects[i].parametro === nodeParametro && filteredObjects[i].valore === nodeValore) {
          // Solo se il nodo con il corrente indice condiziona una sezione allora si svuota il nodo di tipo SceltaSingola
          allNodesForSceltaSingola[index].selectedIndex = 0;
          // getObj('val_' + nodeParametro + '_extraAttrib').value = 'value#=#';
          getObj('SEZIONE_' + filteredObjects[i].chiaveUnivocaRiga).style.display = 'none';
        }
      }
    }
  }

  /*  Caso in cui SceltaSingola sia radio button, ossia una lista di radio button
   *
  var allNodesForSceltaSingola = document.getElementById("SEZIONE_" + chiave).querySelectorAll("input[type='radio']");

  if (allNodesForSceltaSingola && allNodesForSceltaSingola !== null && allNodesForSceltaSingola.length > 0) {
    // Cicla tutti i nodi trovati
    for (var index = 0; index < allNodesForSceltaSingola.length; index++) {
      // Esempio: allNodesForSceltaSingola[index].id = "PARAMETRO_3_4"
      var nodeParametro = allNodesForSceltaSingola[index].id.slice(0, 13) // nodeParametro = 'PARAMETRO_3_4'

      // Esempio: allNodesForSceltaMultipla[index].value = "471367_3.4@in piedi"
      var nodeValore = allNodesForSceltaSingola[index].value.split('@')[1]; // nodeValore = 'in piedi'

      for (var i = 0; i < filteredObjects.length; i++) {
        if (filteredObjects[i].parametro === nodeParametro && filteredObjects[i].valore === nodeValore) {
          // Solo se il nodo con il corrente indice condiziona una sezione allora si svuota il nodo di tipo SceltaSingola
          allNodesForSceltaSingola[index].checked = false;
          allNodesForSceltaSingola[index].removeAttribute('checked') // ('refresh');
          getObj('SEZIONE_' + filteredObjects[i].chiaveUnivocaRiga).style.display = 'none';
        }
      }
    }
  }
  *
  */
}

function MakeAttachFields100PercentWide() {
  var attachContainerList = document.getElementsByClassName('ATTACH_CONTAINER');
  for (var index = 0; index < attachContainerList.length; index++) {
    attachContainerList[index].className += ' width_100_percent'
  }
}
