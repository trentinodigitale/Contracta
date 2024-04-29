var g_techInfoParametro; // Contains the json
// var g_rowNumbers; // Contains the number of rows of the grid in the dialog ('ELENCO_VALORI')

var g_oddRow; // Contains the html as example for the odd rows
var g_evenRow; // Contains the html as example for the even rows
var g_rowToDisplay; // Contains the even or odd row tha is constructed based upon the g_evenRow or g_oddRow

var ELENCO_VALORIGrid_StartRow = 0;
var ELENCO_VALORIGrid_EndRow = 1;

// var g_dettagliGridCurrentSectionDescription; // Contains the value in the column Description for the Sezione linked to the Parametro clicked
var g_dettagliGridCurrentSectionUniqueKey; // Contains the value in the hidden column ChiaveUnivocaRiga for the Sezione linked to the Parametro clicked


$(document).ready(function () {
  OnLoadPage();
});

function OnLoadPage() {
  // Check if the document is readonly: if isDocumentReadOnly='0' then the doc is not readonly
  var isDocumentReadOnly = '0';
  if (getObj('DOCUMENT_READONLY'))
    isDocumentReadOnly = getObj('DOCUMENT_READONLY').value;

  if (isDocumentReadOnly === '0') {
    // Attivo DRAG&DROP sulla griglia DETTAGLI 
    ActiveGridDrag('DETTAGLIGrid', MoveAllDoc);

    var dettagliGridTotalrows = GetProperty(getObj('DETTAGLIGrid'), 'numrow');

    // For all the rows in the table/grid ... 
    for (rowIndex = 0; rowIndex <= dettagliGridTotalrows; rowIndex++) {
      // ... make the column "Parametro" visible only if the choice in the dropdown of the column "Tipo" is equal to 'Parametro'
      DetermineVisibilityOfParametroColumn(rowIndex);

      // ... add function OnChangeDescrizioneEstesa to DescrizioneEstesa
      getObj('RDETTAGLIGrid_' + rowIndex + '_DescrizioneEstesa').setAttribute("onchange", "OnChangeDescrizioneEstesa(" + rowIndex + ");");

      DetermineRowBackground(getObj('RDETTAGLIGrid_' + rowIndex + '_TipoRigaQuestionario').value, rowIndex);

      DetermineVisibilityOfOpenCloseSectionIcon(rowIndex, dettagliGridTotalrows);
    }
  }
  else {
    // Grid of section/sezione DETTAGLI
    AdjustGrid();
    HideColumns();
  }
}

/* // TODO: not used functions
// Add the sections to the drop down for all the rows in the grid
// function AddAllAvailableSectionsToDropDownSections(sectionsList = 0) {
//   for (var rowIndex = 0; rowIndex < GetProperty(getObj('ELENCO_VALORIGrid'), 'numrow'); rowIndex++) {
//     for (var i = 0; i < sectionsList.length; i++) {
//       getObj('RELENCO_VALORIGrid_' + rowIndex + '_SezioneCondizionale').add(new Option(sectionsList[i].description, sectionsList[i].sectionCode));
//       // To get the 'descrizione' and 'chiaveUnivocaRiga':
//       //   var sezioneCondizionale = getObj('RELENCO_VALORIGrid_' + rowIndex + '_SezioneCondizionale');
//       //   console.log(sezioneCondizionale.options[i + 1].text); // sezioneCondizionale[i + 1].text;
//       //   console.log(sezioneCondizionale[i + 1].value); // sezioneCondizionale.options[i + 1].value;
//     }
//   }
// }

// Returns only the unique values within the array
// function OnlyUnique(value, index, array) {
//   return array.indexOf(value) === index;
// }

// function AddFunctionToDescrizioneEstesa(totalRows) {
//   for (rowIndex = 0; rowIndex <= totalRows; rowIndex++) {
//     getObj('RDETTAGLIGrid_' + rowIndex + '_DescrizioneEstesa').setAttribute("onchange", "OnChangeDescrizioneEstesa(" + rowIndex + ");");
//   }
// } */

function HideColumns() {
  //nascondo drag_drop quando non editabile
  ShowCol('DETTAGLI', 'FNZ_DRAG', 'none');
  ShowCol('DETTAGLI', 'FNZ_ADD', 'none');
  // ShowCol('DETTAGLI', 'FNZ_CONTROLLI', 'none'); // Nasconde la colonna di apri/chiudi sezione
}

function AdjustGrid() {
  CalcPathNumber();

  var totalRows = GetProperty(getObj('DETTAGLIGrid'), 'numrow');
  for (rowIndex = 0; rowIndex <= totalRows; rowIndex++) {
    DetermineVisibilityOfParametroColumn(rowIndex);

    DetermineRowBackground(getObj('RDETTAGLIGrid_' + rowIndex + '_TipoRigaQuestionario').value, rowIndex);

    DetermineVisibilityOfOpenCloseSectionIcon(rowIndex);
  }
}

function DetermineVisibilityOfParametroColumn(rowIndex) {
  if (DOCUMENT_READONLY === 1){ // Quando il doc è readonly
    // Esci perchè gli id non sono giusti, esempio: invece di 'RDETTAGLIGrid_0_TipoRigaQuestionario' è 'RDETTAGLIGrid 0 TipoRigaQuestionario'
    return;
  }

  var tipoRigaQuestionarioValue = getObjValue('RDETTAGLIGrid_' + rowIndex + '_TipoRigaQuestionario');
  var tipoParametroQuestionario = getObj('RDETTAGLIGrid_' + rowIndex + '_TipoParametroQuestionario').value;

  // Hide the magnifying glass icon
  setVisibility(getObj('RDETTAGLIGrid_' + rowIndex + '_FNZ_OPEN'), 'none');

  if (tipoRigaQuestionarioValue === 'Parametro') {
    setVisibility(getObj('RDETTAGLIGrid_' + rowIndex + '_TipoParametroQuestionario'), '');
    // SelectreadOnly('RDETTAGLIGrid_' + rowIndex + '_TipoParametroQuestionario', false);

    // Show the magnifying glass only if the column "Parametro" is not empty string, null or undefined
    if (tipoParametroQuestionario !== '' && tipoParametroQuestionario)
      setVisibility(getObj('RDETTAGLIGrid_' + rowIndex + '_FNZ_OPEN'), '');
  }
  else /* if (tipoRigaQuestionarioValue === 'Sezione' || tipoRigaQuestionarioValue === 'Nota') */ {
    getObj('RDETTAGLIGrid_' + rowIndex + '_TipoParametroQuestionario').value = '';
    setVisibility(getObj('RDETTAGLIGrid_' + rowIndex + '_TipoParametroQuestionario'), 'none');
    // SelectreadOnly('RDETTAGLIGrid_' + rowIndex + '_TipoParametroQuestionario', true);
  }
}

function DETTAGLI_AFTER_COMMAND(param) {
  // Attivo DRAG&DROP sulla griglia DETTAGLI
  ActiveGridDrag('DETTAGLIGrid', MoveAllDoc);

  // Grid of section/sezione DETTAGLI
  AdjustGrid();

  if (param === "ADDNEW")
    AddUniqueKeyToRowsOfGrid();

  UpdateEsitoVerifica();
}

function AddUniqueKeyToRowsOfGrid(totalRows = GetProperty(getObj('DETTAGLIGrid'), 'numrow')) {
  totalRows = parseInt(totalRows); // Convert string to integer

  // If no rows in the grid, id est empty grid
  if (totalRows === 0) {
    getObj('RDETTAGLIGrid_' + totalRows + '_ChiaveUnivocaRiga').value = 1; // Assign the unique key to the row
    return;
  }

  // Find the greatest unique value to be assigned
  var maxUniqueValue = 0;
  for (rowIndex = 0; rowIndex <= totalRows; rowIndex++) {
    if (getObjValue('RDETTAGLIGrid_' + rowIndex + '_ChiaveUnivocaRiga') && parseInt(getObjValue('RDETTAGLIGrid_' + rowIndex + '_ChiaveUnivocaRiga')) > maxUniqueValue)
      maxUniqueValue = parseInt(getObjValue('RDETTAGLIGrid_' + rowIndex + '_ChiaveUnivocaRiga'));
  }

  if (getObj('RDETTAGLIGrid_' + totalRows + '_ChiaveUnivocaRiga') && getObjValue('RDETTAGLIGrid_' + totalRows + '_ChiaveUnivocaRiga').trim() === '')
    getObj('RDETTAGLIGrid_' + totalRows + '_ChiaveUnivocaRiga').value = (maxUniqueValue + 1).toString(); // Assign the unique key to the row
}

function ClickDownDoc(grid, r, c) {
  MoveAllDoc(r, 1);
}

function ClickUpDoc(grid, r, c) {
  MoveAllDoc(r, -1);
}

// Funzione che sposta tutti campi della griglia
function MoveAllDoc(r, verso) { // r is the index of the row in the grid that the user clicked to drag&drop
  Move_Abstract('DETTAGLIGrid', 'EsitoRiga', r, verso);
  Move_Abstract('DETTAGLIGrid', 'KeyRiga', r, verso);
  Move_Abstract('DETTAGLIGrid', 'TipoRigaQuestionario', r, verso);
  Move_Abstract('DETTAGLIGrid', 'Descrizione', r, verso);
  Move_Abstract('DETTAGLIGrid', 'DescrizioneEstesa', r, verso);
  Move_Abstract('DETTAGLIGrid', 'TipoParametroQuestionario', r, verso);
  Move_Abstract('DETTAGLIGrid', 'Tech_Info_Parametro', r, verso); // Hidden column
  Move_Abstract('DETTAGLIGrid', 'EsitoRiga_Parametro', r, verso); // Hidden column
  Move_Abstract('DETTAGLIGrid', 'ChiaveUnivocaRiga', r, verso); // Hidden column
  Move_Abstract('DETTAGLIGrid', 'Valori_Di_Esclusione_Parametro', r, verso); // Hidden column
  Move_Abstract('DETTAGLIGrid', 'SezioniCondizionate', r, verso); // Hidden column
  Move_Abstract('DETTAGLIGrid', 'ElencoValori', r, verso); // Hidden column
}

// Grid of section/sezione DETTAGLI, make the column "Parametro" visible only if the choice in the dropdown of the column "Tipo" is equal to 'Parametro'
function OnChangeTipoRigaQuestionario(thisObj) {
  var rowIndex = thisObj.id.split('_')[1];
  DetermineVisibilityOfParametroColumn(rowIndex);

  CalcPathNumber();

  DetermineRowBackground(thisObj.value, rowIndex);

  UpdateEsitoRiga(rowIndex);
  UpdateEsitoVerifica();
}

// Calculate the number in column "N." (numero percorso)
function CalcPathNumber() {
  var sectionKeyRigaValue = 0; // if tipoRigaQuestionarioValue is equal to "Sezione"

  var elseKeyRigaValue = ''; // if tipoRigaQuestionarioValue is equal to "Nota" or 'Parametro'
  var fractionalPart = 0; // the fractional part of the elseKeyRigaValue variable
  var decimalAdvancement = 1; // value by which the fractionalPart variable is increased

  try {
    for (rowIndex = 0; getObj('RDETTAGLIGrid_' + rowIndex + '_KeyRiga') != undefined; rowIndex++) {
      var tipoRigaQuestionarioValue = getObjValue('RDETTAGLIGrid_' + rowIndex + '_TipoRigaQuestionario');

      if (tipoRigaQuestionarioValue === 'Sezione') {
        sectionKeyRigaValue++;
        SetTextValue('RDETTAGLIGrid_' + rowIndex + '_KeyRiga', sectionKeyRigaValue.toString());
        fractionalPart = 0;
      }
      else if (tipoRigaQuestionarioValue === 'Parametro' || tipoRigaQuestionarioValue === 'Nota' || tipoRigaQuestionarioValue === '') {
        fractionalPart += decimalAdvancement;
        elseKeyRigaValue = sectionKeyRigaValue.toString() + '.' + fractionalPart.toString();
        SetTextValue('RDETTAGLIGrid_' + rowIndex + '_KeyRiga', elseKeyRigaValue);
      }
    }
  } catch (e) { }
}

function OnChangeTipoParametroQuestionario(thisObj) {
  var rowIndex = thisObj.id.split('_')[1];
  var tipoParametroQuestionario = getObjValue('RDETTAGLIGrid_' + rowIndex + '_TipoParametroQuestionario');

  // Svuota il campo nascosto che contiene il json
  getObj('RDETTAGLIGrid_' + rowIndex + '_Tech_Info_Parametro').value = '';

  if (tipoParametroQuestionario !== '' && tipoParametroQuestionario)
    setVisibility(getObj('RDETTAGLIGrid_' + rowIndex + '_FNZ_OPEN'), '');
  else {
    setVisibility(getObj('RDETTAGLIGrid_' + rowIndex + '_FNZ_OPEN'), 'none');
  }

  UpdateEsitoRiga(rowIndex);
  UpdateEsitoVerifica();
}

function OnChangeDescrizione(thisObj) {
  UpdateEsitoRiga(thisObj.id.split('_')[1]); // Passing the rowIndex to the function UpdateEsitoRiga
  UpdateEsitoVerifica();
}

function OnChangeDescrizioneEstesa(thisObj) {
  var rowIndex;

  if (isNaN(thisObj)) // thisObj ?is Not a Number? ?
    rowIndex = thisObj.id.split('_')[1];
  else
    rowIndex = thisObj;

  UpdateEsitoRiga(rowIndex); // Passing the rowIndex to the function UpdateEsitoRiga
  UpdateEsitoVerifica();
}

function OpenDocumentAssociatedWithParametro(gridName, rowIndex, columnNumber) {
  ShowWorkInProgress();

  // Get document's state: if isDocumentReadOnly==='0' then the doc is editable (not readonly)
  var isDocumentReadOnly = getObjValue('DOCUMENT_READONLY');

  // Get the current row values of the grid 'DETTAGLI'
  var tipoParametroQuestionario = getObj('R' + gridName + '_' + rowIndex + '_TipoParametroQuestionario').value;
  g_techInfoParametro = getObj('R' + gridName + '_' + rowIndex + '_Tech_Info_Parametro').value;
  var currentSectionNumber = getObjValue('R' + gridName + '_' + rowIndex + '_KeyRiga').split('.')[0];

  if (tipoParametroQuestionario === '' && !tipoParametroQuestionario)
    return;

  var [document, title, dialogHeight, dialogWidth] = Get_DocumentName_DialogTitleWidthAndHeight(tipoParametroQuestionario);

  // Get document using ajax
  var nocache = new Date().getTime();
  var jScript = document;
  var strURL = 'document.asp?MODE=SHOW&JScript=' + jScript + '&DOCUMENT=' + document + '&IDDOC=1&nocache=' + nocache + '&lo=none&UPD_STACK=NO';
  var ajax = GetXMLHttpRequest();
  ajax.open("GET", strURL, false);
  ajax.send(null);

  ShowWorkInProgress(false);

  if (ajax.readyState == 4) {
    if (ajax.status == 404 || ajax.status == 500) {
      alert('Errore invocazione documento');
    }

    if (ajax.responseText.includes("Sessione di lavoro scaduta")) {
      // alert('Sessione di lavoro scaduta: accedere di nuovo ');
      eval(ajax.responseText);
    }

    // Load the dialog (la modale)
    var page = '';
    if (isDocumentReadOnly === '0') { // if isDocumentReadOnly==='0' the doc is editable
      ExecFunctionModaleConfirmWithDinamicHeightAndWidth(page, title, null, 'OnOkDialog@@@@' + rowIndex + '%%%' + tipoParametroQuestionario, null, dialogHeight, dialogWidth);
    }
    else { // if (isDocumentReadOnly === '1')
      ExecFunctionModaleClose(page, title, null, dialogHeight, dialogWidth)
    }

    // Get only the form
    var parser = new DOMParser();
    var html = parser.parseFromString(ajax.responseText, 'text/html'); // Convert string to html
    var htmlForm = html.getElementById('FORMDOCUMENT'); // Get the form by Id
    if (!htmlForm) { // If htmlForm is null or undefined
      htmlForm = html.getElementsByTagName('form')[0]; // Get the form by TagName
      // html.getElementsByTagName('form')['FORMDOCUMENT'];
    }
    var formAsStr = htmlForm['outerHTML']; // Get the form as string using the 'outerHTML' property

    // Assign the ajax response into the div 'finestra_modale_confirm'
    getObj('finestra_modale_confirm').innerHTML = formAsStr;

    // Insert the values of Descrizione and DescrizioneEstesa in the 'TESTATA' section
    getObj('Descrizione').value = getObj('R' + gridName + '_' + rowIndex + '_Descrizione').value;
    getObj('DescrizioneEstesa').value = getObj('R' + gridName + '_' + rowIndex + '_DescrizioneEstesa').value;

    var sectionsInGrid = GetAllSectionsInTheGrid(currentSectionNumber);

    // Insert the values from the Tech_Info_Parametro (the json) 
    // Check if the attribute Tech_Info_Parametro contains a string not empty. If it's empty insert default values.
    if (g_techInfoParametro.trim().toLowerCase() && g_techInfoParametro.trim().toLowerCase() !== '' && g_techInfoParametro.trim().toLowerCase() !== "''") {
      g_techInfoParametro = JSON.parse(g_techInfoParametro);
      getObj('Checkobbligo1').checked = g_techInfoParametro["obbligatorio"];

      if (tipoParametroQuestionario === "SceltaSingola" || tipoParametroQuestionario === "SceltaMultipla") {
        // Save the first two rows of the grid ('ELENCO_VALORI') as example for the odd and even rows
        SaveExampleRows(html, sectionsInGrid);

        if (!g_techInfoParametro.gridObjByRows)
          BuildJson(tipoParametroQuestionario);

        // Delete the two (default) rows that comes from the ajax call
        RemoveAllRows();
        // Build/Draw the grid
        BuildGrid(sectionsInGrid);

        // Update the hidden input that contains as 'value' the number of rows
        UpdateHiddenInputForNumberOfRows(undefined, g_techInfoParametro.gridObjByRows.length);
      }
      else if (tipoParametroQuestionario === "Testo") {
        getObj('NumCaratteri').value = g_techInfoParametro.MaxNumeroCaratteri;
        getObj('NumCaratteri_V').value = g_techInfoParametro.MaxNumeroCaratteri;
      }
      // else if (tipoParametroQuestionario === "SiNo" || tipoParametroQuestionario === "Numerico" || tipoParametroQuestionario === "Data") {
      //   // // Not necessary to implement because it can contain either True or False.
      //   // getObj('Checkobbligo1').checked = g_techInfoParametro["obbligatorio"];
      // }
      else if (tipoParametroQuestionario === "Allegato" || tipoParametroQuestionario === "AllegatoFirmato") {
        //TODO
        if (g_techInfoParametro.allegati) {
          getObj('TipoFile').value = g_techInfoParametro.allegati.TipoFile_Value;
          getObj('TipoFile_edit').value = g_techInfoParametro.allegati.TipoFile_edit_Value;
          getObj('TipoFile_edit_new').value = g_techInfoParametro.allegati.TipoFile_edit_new_value;
          getObj('TipoFile_edit_new').title = g_techInfoParametro.allegati.TipoFile_edit_new_title;
        }
      }
    }
    else {
      if (tipoParametroQuestionario === "SceltaSingola" || tipoParametroQuestionario === "SceltaMultipla") {
        // Save the first two rows of the grid ('ELENCO_VALORI') as example for the odd and even rows
        SaveExampleRows(html, sectionsInGrid);

        BuildJson(tipoParametroQuestionario);
        // Delete the two (default) rows that comes from the ajax call
        RemoveAllRows();
        // Build/Draw the grid
        BuildGrid(sectionsInGrid);
        // There are 2 default rows from the ajax call
        UpdateHiddenInputForNumberOfRows(undefined, 2);
      }
      // else if (tipoParametroQuestionario === "SiNo" || tipoParametroQuestionario === "Testo" || tipoParametroQuestionario === "Numerico" || tipoParametroQuestionario === "Data") {
      //   // // Not necessary to implement because it can contain either True or False.
      //   // getObj('Checkobbligo1').checked = false;
      // }
      // else if (tipoParametroQuestionario === "Allegato" || tipoParametroQuestionario === "AllegatoFirmato") {
      //   // Nothing to do here ;
      // }
    }

    // If the doc QUESTIONARIO_AMMINISTRATIVO is read-only then the dialog should also be read-only
    if (isDocumentReadOnly === '1') {
      DisableObj('Descrizione', true, true);
      DisableObj('DescrizioneEstesa', true, true);
      DisableObj('Checkobbligo1', true, true);

      if (tipoParametroQuestionario === 'SceltaSingola' || tipoParametroQuestionario === 'SceltaMultipla') {
        // Remove/Delete the toolbar
        getObj('Parametro_SceltaSingola_ELENCO_VALORI_TOOLBAR_ADDNEW_QuestAmm_SceltaSingola').remove();

        var elencoValoriGridRows = getObj('ELENCO_VALORIGrid').rows;

        for (var index = 0; index < elencoValoriGridRows.length; index++) {
          // Remove the column "Drag and Drop" and "Elimina" for the current row
          elencoValoriGridRows[index].deleteCell(0); // Delete "Drag and Drop" cell
          elencoValoriGridRows[index].deleteCell(0); // Delete "Elimina" cell

          if (index < elencoValoriGridRows.length - 1) {
            DisableObj('RELENCO_VALORIGrid_' + index + '_DescriptionText', true, true);
            DisableObj('RELENCO_VALORIGrid_' + index + '_Esclusione', true, true);
            DisableObj('RELENCO_VALORIGrid_' + index + '_SezioneCondizionale', true, true);
          }
        }
      }
      else if (tipoParametroQuestionario === 'Allegato' || tipoParametroQuestionario === 'AllegatoFirmato') {
        DisableObj('TipoFile_edit_new', true, true);
        DisableObj('TipoFile_button', true, true);
      }
    }
  }
}

function Get_DocumentName_DialogTitleWidthAndHeight(tipoParametroQuestionario) {
  var documentName, dialogTitle, dialogHeight = 470, dialogWidth = 670;

  switch (tipoParametroQuestionario) {
    case "SceltaSingola":
      documentName = "QUESTIONARIO_PARAMETRO_SceltaSingola", dialogTitle = "PARAMETRO Scelta Singola", dialogHeight = 750, dialogWidth = 700;
      break;
    case "SiNo":
      documentName = "QUESTIONARIO_PARAMETRO_SiNo", dialogTitle = "PARAMETRO Si/No";
      break;
    case "SceltaMultipla":
      documentName = "QUESTIONARIO_PARAMETRO_SceltaMultipla", dialogTitle = "PARAMETRO Scelta Multipla", dialogHeight = 750, dialogWidth = 700;
      break;
    case "Testo":
      documentName = "QUESTIONARIO_PARAMETRO_Testo", dialogTitle = "PARAMETRO Testo", dialogHeight = 500;
      break;
    case "Numerico":
      documentName = "QUESTIONARIO_PARAMETRO_Numerico", dialogTitle = "PARAMETRO Numerico";
      break;
    case "Data":
      documentName = "QUESTIONARIO_PARAMETRO_Data", dialogTitle = "PARAMETRO Data";
      break;
    case "Allegato":
      documentName = "QUESTIONARIO_PARAMETRO_Allegato", dialogTitle = "PARAMETRO Allegato", dialogHeight = 500;
      break;
    case "AllegatoFirmato":
      documentName = "QUESTIONARIO_PARAMETRO_AllegatoFirmato", dialogTitle = "PARAMETRO Allegato Firmato", dialogHeight = 500;
      break;
    default:
      documentName = "", dialogTitle = "";
      break;
  }

  return [documentName, CNV(pathRoot, dialogTitle), dialogHeight, dialogWidth];
}

function OnOkDialog(params) {
  var paramsArray = params.split('%%%');
  var rowIndex = paramsArray[0]; // Of the grid 'DETTAGLI' (not the one in dialog)
  var tipoParametroQuestionario = paramsArray[1]; // Holds the type of parameter select ("SiNo", "SceltaMultipla", "Allegato", ...)

  var errors = CheckAllRequiredFields(tipoParametroQuestionario, rowIndex);

  // Replace the values of Descrizione e DescrizioneEstesa
  ReplaceValuesOnTheGridDettagli(rowIndex, tipoParametroQuestionario, errors);

  // Construct and stringify the json object
  BuildJson(tipoParametroQuestionario, rowIndex);

  var jsonAsString = JSON.stringify(g_techInfoParametro);

  // Assign the json stringified
  getObj('RDETTAGLIGrid_' + rowIndex + '_Tech_Info_Parametro').value = jsonAsString;

  UpdateEsitoRiga(rowIndex);
  UpdateEsitoVerifica();
}

function ReplaceValuesOnTheGridDettagli(rowIndex, tipoParametroQuestionario, errors) {
  getObj('RDETTAGLIGrid_' + rowIndex + '_Descrizione').value = getObjValue('Descrizione');
  getObj('RDETTAGLIGrid_' + rowIndex + '_DescrizioneEstesa').value = getObjValue('DescrizioneEstesa');

  if (errors && Object.keys(errors).length > 0 && Object.getPrototypeOf(errors) === Object.prototype) {
    // Assign value to hidden column EsitoRiga_Parametro
    getObj('RDETTAGLIGrid_' + rowIndex + '_EsitoRiga_Parametro').value = JSON.stringify(errors);
  }
  else
    getObj('RDETTAGLIGrid_' + rowIndex + '_EsitoRiga_Parametro').value = "";

  if (tipoParametroQuestionario === "SceltaSingola" || tipoParametroQuestionario === "SceltaMultipla") {
    var valoriDiEsclusione = '';
    var sezioniCondizionate = '';
    var elencoValori = '###';
    var rows = GetProperty(getObj('ELENCO_VALORIGrid'), 'numrow');

    for (var i = 0; i < rows; i++) {
      var valore = getObjValue('RELENCO_VALORIGrid_' + i + '_DescriptionText');

      if (getObjValue('RELENCO_VALORIGrid_' + i + '_Esclusione') === 'S') {
        valoriDiEsclusione += '###' + valore;
      }

      var sezioneCondizionale = getObj('RELENCO_VALORIGrid_' + i + '_SezioneCondizionale');
      if (sezioneCondizionale.selectedIndex > 0 && valore.length > 0) { // Only if the pair valore-sezioneCondizionale is ok
        sezioniCondizionate += getObjValue('RELENCO_VALORIGrid_' + i + '_DescriptionText') + '###';
        sezioniCondizionate += sezioneCondizionale.options[sezioneCondizionale.selectedIndex].value;
        sezioniCondizionate += '@@@';
      }

      elencoValori += getObjValue('RELENCO_VALORIGrid_' + i + '_DescriptionText') + '###';
    }

    // Remove the last @@@ from sezioniCondizionate
    sezioniCondizionate = sezioniCondizionate.slice(0, sezioniCondizionate.length - 3);

    getObj('RDETTAGLIGrid_' + rowIndex + '_Valori_Di_Esclusione_Parametro').value = valoriDiEsclusione + '###';
    getObj('RDETTAGLIGrid_' + rowIndex + '_SezioniCondizionate').value = sezioniCondizionate;
    getObj('RDETTAGLIGrid_' + rowIndex + '_ElencoValori').value = elencoValori;
  }
}

function BuildJson(tipoParametroQuestionario, rowIndex) { // rowIndex of the grid 'DETTAGLI'
  g_techInfoParametro = JSON.parse('{}'); // Construct the json as object 

  g_techInfoParametro.obbligatorio = getObjValue('Checkobbligo1');
  g_techInfoParametro.tipoParametro = tipoParametroQuestionario;

  if (rowIndex)
    g_techInfoParametro.row = getObjValue('RDETTAGLIGrid_' + rowIndex + '_ChiaveUnivocaRiga');

  if (tipoParametroQuestionario === "SceltaSingola" || tipoParametroQuestionario === "SceltaMultipla") {

    g_techInfoParametro.gridObjByRows = [];

    for (var rowIndex = 0; rowIndex < getObj('ELENCO_VALORIGrid').rows.length - 1; rowIndex++) {
      var sezioneCondizionale = getObj('RELENCO_VALORIGrid_' + rowIndex + '_SezioneCondizionale');

      g_techInfoParametro.gridObjByRows.push({
        valore: getObjValue('RELENCO_VALORIGrid_' + rowIndex + '_DescriptionText').trim(),
        esclusione: getObjValue('RELENCO_VALORIGrid_' + rowIndex + '_Esclusione'),
        sezioneCondizionale: sezioneCondizionale.options[sezioneCondizionale.selectedIndex].value
      });
    }
  }
  else if (tipoParametroQuestionario === "Testo") {
    g_techInfoParametro.MaxNumeroCaratteri = getObjValue('NumCaratteri');
  }
  // else if (tipoParametroQuestionario === "SiNo" || tipoParametroQuestionario === "Numerico" || tipoParametroQuestionario === "Data") {
  // Nothing to do here ;
  // }
  else if (tipoParametroQuestionario === "Allegato" || tipoParametroQuestionario === "AllegatoFirmato") {
    g_techInfoParametro.allegati = {
      TipoFile_Value: getObjValue('TipoFile'),
      TipoFile_edit_Value: getObjValue('TipoFile_edit'),
      TipoFile_edit_new_value: getObj('TipoFile_edit_new').value,
      TipoFile_edit_new_title: getObj('TipoFile_edit_new').title
    };
  }
}

function CheckAllRequiredFields(tipoParametroQuestionario, rowIndex) {
  // DMessageBox('../', 'E\' necessario compilare tutti i campi obbligatori', 'Attenzione', 1, 400, 300);

  // g_techInfoParametro.errors = {};
  var errors = {};

  if (!getObjValue('Descrizione') || getObjValue('Descrizione').trim().toLowerCase() === '') {
    // g_techInfoParametro.errors.errorDescrizione = 'E\' necessario compilare la Descrizione.';
    errors.errorDescrizione = 'E\' necessario compilare la Descrizione.';
  }

  if (!getObjValue('DescrizioneEstesa') || getObjValue('DescrizioneEstesa').trim().toLowerCase() === '') {
    // g_techInfoParametro.errors.errorDescrizioneEstesa = 'E\' necessario compilare la Descrizione Estesa.';
    errors.errorDescrizioneEstesa = 'E\' necessario compilare la Descrizione Estesa.';
  }

  if (tipoParametroQuestionario === "SceltaSingola" || tipoParametroQuestionario === "SceltaMultipla") {
    if (getObj('ELENCO_VALORIGrid').rows.length <= 1) {
      // g_techInfoParametro.errors.errorGridElencoValori = 'La griglia Elenco Valori non ha righe.';
      errors.errorGridElencoValori = 'La griglia Elenco Valori non ha righe.';
    }

    var elencoValoriGridRows = getObj('ELENCO_VALORIGrid').rows;
    var errorGridColumnValore = [];

    for (var index = 0; index < elencoValoriGridRows.length - 1; index++) { // Added -1 to not consider the headers row

      if (!getObjValue('RELENCO_VALORIGrid_' + index + '_DescriptionText') || getObjValue('RELENCO_VALORIGrid_' + index + '_DescriptionText').trim().toLowerCase() === '') {
        errorGridColumnValore.push('Nella griglia Elenco Valori, la colonna Valore nella righa ' + (index + 1) + ' non e\' valorizzata.');
      }
    }

    if (errorGridColumnValore.length > 0) {
      // g_techInfoParametro.errors.errorGridColumnValore = errorGridColumnValore;
      errors.errorGridColumnValore = errorGridColumnValore;
    }
  }
  // else if (tipoParametroQuestionario === "SiNo" || tipoParametroQuestionario === "Testo" || tipoParametroQuestionario === "Numerico" || tipoParametroQuestionario === "Data") {
  //   // Not necessary to implement because it can contain either True or False.
  //   // getObj('Checkobbligo1').checked;
  // }
  // else if (tipoParametroQuestionario === "Allegato" || tipoParametroQuestionario === "AllegatoFirmato") {
  //   // Nothing to do here ;
  // }

  return errors;
}

function SaveExampleRows(html, sectionsList = 0) {
  // Add the sections to the drop down
  for (var i = 0; i < sectionsList.length; i++) {
    html.getElementById('RELENCO_VALORIGrid_0_SezioneCondizionale').add(new Option(sectionsList[i].description, sectionsList[i].sectionCode));
    html.getElementById('RELENCO_VALORIGrid_1_SezioneCondizionale').add(new Option(sectionsList[i].description, sectionsList[i].sectionCode));
  }
  // To get the 'descrizione' and 'chiaveUnivocaRiga':
  //   var sezioneCondizionale = getObj('RELENCO_VALORIGrid_' + rowIndex + '_SezioneCondizionale');
  //   console.log(sezioneCondizionale.options[i + 1].text); // sezioneCondizionale[i + 1].text;
  //   console.log(sezioneCondizionale[i + 1].value); // sezioneCondizionale.options[i + 1].value;

  g_oddRow = html.getElementById('ELENCO_VALORIGridR0');
  g_evenRow = html.getElementById('ELENCO_VALORIGridR1');
}

// Delete all the rows from the grid of the dialog
function RemoveAllRows() {
  var table = getObj('ELENCO_VALORIGrid');
  var tboby = table.children[0];
  for (var index = (tboby.children.length - 1); index > 0; index--) {
    tboby.removeChild(tboby.children[1]); // tboby.removeChild(tboby.rows[1]); // Always index 1 because when first row is removed then the next row gets index 1
  }
}

// Build/Rebuild the grid
function BuildGrid(sectionsInGrid) {
  for (var i = 0; i < g_techInfoParametro.gridObjByRows.length; i++) {
    var rowObj = g_techInfoParametro.gridObjByRows[i];

    if ((i + 1) % 2 === 0) {
      ConstructEvenRow(i);
    }
    else {
      ConstructOddRow(i);
    }

    DisplayGrid(g_rowToDisplay, i);

    if (sectionsInGrid && !sectionsInGrid.some(obj => obj.sectionCode === rowObj.sezioneCondizionale))
      rowObj.sezioneCondizionale = '';

    AddValuesToDialogGrid(rowObj.valore, rowObj.esclusione, rowObj.sezioneCondizionale, i);
  }

  // Remove unnecessary borders
  getObj('ELENCO_VALORIGrid_Caption').children[0].children[1].children[0].style.cssText += "border: none";

  // Remove the scrollbar of the entire dialog
  getObj('finestra_modale_confirm').style.cssText += "overflow: unset";

  if (!getObj('wrap_ELENCO_VALORIGrid')) {
    // Get width for the div wrap_ELENCO_VALORIGrid
    var wrappingDivWidth = getObj('ELENCO_VALORI').offsetWidth;
    // Wrap the grid in a div in order to add a scrollbar only on the  grid
    $("#ELENCO_VALORIGrid").wrap($("<div id='wrap_ELENCO_VALORIGrid' class='Scrollbar_GridElencoValori'></div>"));
    // Add the width to the div with id wrap_ELENCO_VALORIGrid
    getObj('wrap_ELENCO_VALORIGrid').style.cssText += "width: " + wrappingDivWidth + "px";
  }

  // Add the classes to the first row of the grid (which contains the column titles) to fix/lock it
  getObj('ELENCO_VALORIGrid_FNZ_DRAG').className += ' TableFirstRowSticky';
  getObj('ELENCO_VALORIGrid_FNZ_DEL').className += ' TableFirstRowSticky';
  getObj('ELENCO_VALORIGrid_DescriptionText').className += ' TableFirstRowSticky';
  getObj('ELENCO_VALORIGrid_Esclusione').className += ' TableFirstRowSticky';
  getObj('ELENCO_VALORIGrid_SezioneCondizionale').className += ' TableFirstRowSticky';

  // Enable drag and drop
  ActiveGridDrag('ELENCO_VALORIGrid', MoveAllDocInDialog);
}

function ConstructOddRow(rowIndex) {
  g_rowToDisplay = g_oddRow.cloneNode(true);

  RemoveCurrentSezioneFromTheOptions();

  if (rowIndex === 0) {
    g_rowToDisplay.children[1].children[0].setAttribute("onClick", "DettagliDelDialog('ELENCO_VALORIGrid', " + rowIndex + ", 1);");
    return;
  }

  g_rowToDisplay.id = 'ELENCO_VALORIGridR' + rowIndex; // row

  // drag and drop
  g_rowToDisplay.children[0].id = 'ELENCO_VALORIGrid_r' + rowIndex + '_c0';
  g_rowToDisplay.children[0].children[0] = 'RELENCO_VALORIGrid_' + rowIndex + '_FNZ_DRAG'; // tag table
  g_rowToDisplay.children[0].children[0].children[0].children[0].children[1].id = 'RELENCO_VALORIGrid_' + rowIndex + '_FNZ_DRAG_label'; // tag td inside the table tag

  // delete
  g_rowToDisplay.children[1].id = 'ELENCO_VALORIGrid_r' + rowIndex + '_c1';
  g_rowToDisplay.children[1].children[0].setAttribute("onClick", "DettagliDelDialog('ELENCO_VALORIGrid', " + rowIndex + ", 1);");

  g_rowToDisplay.children[1].children[0].children[0].id = 'RELENCO_VALORIGrid_' + rowIndex + '_FNZ_DEL'; // tag table
  g_rowToDisplay.children[1].children[0].children[0].children[0].children[0].children[1].id = 'RELENCO_VALORIGrid_' + rowIndex + '_FNZ_DEL_label'; // tag td inside the table tag

  // column 'Valore'
  g_rowToDisplay.children[2].id = 'ELENCO_VALORIGrid_r' + rowIndex + '_c2';
  g_rowToDisplay.children[2].children[0].name = 'RELENCO_VALORIGrid_' + rowIndex + '_DescriptionText'; // tag input
  g_rowToDisplay.children[2].children[0].id = 'RELENCO_VALORIGrid_' + rowIndex + '_DescriptionText'; // tag input

  // column 'Esclusione'
  g_rowToDisplay.children[3].id = 'ELENCO_VALORIGrid_r' + rowIndex + '_c3';
  g_rowToDisplay.children[3].children[0].id = 'val_RELENCO_VALORIGrid_' + rowIndex + '_Esclusione_extraAttrib'; // hidden input
  g_rowToDisplay.children[3].children[1].id = 'val_RELENCO_VALORIGrid_' + rowIndex + '_Esclusione'; // tag div that contains the select tag
  g_rowToDisplay.children[3].children[1].children[0].name = 'RELENCO_VALORIGrid_' + rowIndex + '_Esclusione'; // tag select
  g_rowToDisplay.children[3].children[1].children[0].id = 'RELENCO_VALORIGrid_' + rowIndex + '_Esclusione'; // tag select
  g_rowToDisplay.children[3].children[1].children[0].children[1].id = 'RELENCO_VALORIGrid_' + rowIndex + '_Esclusione_S'; // select option, value S
  g_rowToDisplay.children[3].children[1].children[0].children[2].id = 'RELENCO_VALORIGrid_' + rowIndex + '_Esclusione_N'; // select option, value N

  // column 'Sezione Condizionale'
  g_rowToDisplay.children[4].id = 'ELENCO_VALORIGrid_r' + rowIndex + '_c4';
  g_rowToDisplay.children[4].children[0].id = 'val_RELENCO_VALORIGrid_' + rowIndex + '_SezioneCondizionale_extraAttrib'; // hidden input
  g_rowToDisplay.children[4].children[1].id = 'val_RELENCO_VALORIGrid_' + rowIndex + '_SezioneCondizionale'; // tag div that contains the select tag
  g_rowToDisplay.children[4].children[1].children[0].name = 'RELENCO_VALORIGrid_' + rowIndex + '_SezioneCondizionale'; // tag select
  g_rowToDisplay.children[4].children[1].children[0].id = 'RELENCO_VALORIGrid_' + rowIndex + '_SezioneCondizionale'; // tag select
}

function ConstructEvenRow(rowIndex) {
  g_rowToDisplay = g_evenRow.cloneNode(true);

  RemoveCurrentSezioneFromTheOptions();

  if (rowIndex === 1) {
    g_rowToDisplay.children[1].children[0].setAttribute("onClick", "DettagliDelDialog('ELENCO_VALORIGrid', " + rowIndex + ", 1);");
    return;
  }

  g_rowToDisplay.id = 'ELENCO_VALORIGridR' + rowIndex; // row, tag tr

  // drag and drop
  g_rowToDisplay.children[0].id = 'ELENCO_VALORIGrid_r' + rowIndex + '_c0'; // tag td
  g_rowToDisplay.children[0].children[0].id = 'RELENCO_VALORIGrid_' + rowIndex + '_FNZ_DRAG'; // tag table
  g_rowToDisplay.children[0].children[0].children[0].children[0].children[1].id = 'RELENCO_VALORIGrid_' + rowIndex + '_FNZ_DRAG_label'; // tag td inside the table tag

  // delete
  g_rowToDisplay.children[1].id = 'ELENCO_VALORIGrid_r' + rowIndex + '_c1'; // tag td
  g_rowToDisplay.children[1].children[0].setAttribute("onClick", "DettagliDelDialog('ELENCO_VALORIGrid', " + rowIndex + ", 1);");

  g_rowToDisplay.children[1].children[0].children[0].id = 'RELENCO_VALORIGrid_' + rowIndex + '_FNZ_DEL'; // tag table
  g_rowToDisplay.children[1].children[0].children[0].children[0].children[0].children[1].id = 'RELENCO_VALORIGrid_' + rowIndex + '_FNZ_DEL_label'; // tag td inside the table tag

  // column 'Valore'
  g_rowToDisplay.children[2].id = 'ELENCO_VALORIGrid_r' + rowIndex + '_c2'; // tag td
  g_rowToDisplay.children[2].children[0].name = 'RELENCO_VALORIGrid_' + rowIndex + '_DescriptionText'; // tag input
  g_rowToDisplay.children[2].children[0].id = 'RELENCO_VALORIGrid_' + rowIndex + '_DescriptionText'; // tag input

  // column 'Esclusione'
  g_rowToDisplay.children[3].id = 'ELENCO_VALORIGrid_r' + rowIndex + '_c3'; // tag td
  g_rowToDisplay.children[3].children[0].id = 'val_RELENCO_VALORIGrid_' + rowIndex + '_Esclusione_extraAttrib'; // hidden input
  g_rowToDisplay.children[3].children[1].id = 'val_RELENCO_VALORIGrid_' + rowIndex + '_Esclusione'; // tag div that contains the select tag
  g_rowToDisplay.children[3].children[1].children[0].name = 'RELENCO_VALORIGrid_' + rowIndex + '_Esclusione'; // tag select
  g_rowToDisplay.children[3].children[1].children[0].id = 'RELENCO_VALORIGrid_' + rowIndex + '_Esclusione'; // tag select
  g_rowToDisplay.children[3].children[1].children[0].children[1].id = 'RELENCO_VALORIGrid_' + rowIndex + '_Esclusione_S'; // select option, value S
  g_rowToDisplay.children[3].children[1].children[0].children[2].id = 'RELENCO_VALORIGrid_' + rowIndex + '_Esclusione_N'; // select option, value N

  // column 'Sezione Condizionale'
  g_rowToDisplay.children[4].id = 'ELENCO_VALORIGrid_r' + rowIndex + '_c4';
  g_rowToDisplay.children[4].children[0].id = 'val_RELENCO_VALORIGrid_' + rowIndex + '_SezioneCondizionale_extraAttrib'; // hidden input
  g_rowToDisplay.children[4].children[1].id = 'val_RELENCO_VALORIGrid_' + rowIndex + '_SezioneCondizionale'; // tag div that contains the select tag
  g_rowToDisplay.children[4].children[1].children[0].name = 'RELENCO_VALORIGrid_' + rowIndex + '_SezioneCondizionale'; // tag select
  g_rowToDisplay.children[4].children[1].children[0].id = 'RELENCO_VALORIGrid_' + rowIndex + '_SezioneCondizionale'; // tag select
}

function RemoveCurrentSezioneFromTheOptions() {
  // Get the 'select' element for the "Sezione Condizionale" => since the are 2 select element then the index 1 is used to get the second element
  var selectObject = g_rowToDisplay.getElementsByTagName('select')[1];
  for (var i = 0; i < selectObject.length; i++) {
    if (selectObject.options[i].value === g_dettagliGridCurrentSectionUniqueKey) {
      selectObject.remove(i); // remove the option
      i--;
    }
  }
}

function DisplayGrid(row, tabIndex) {
  var table = getObj('ELENCO_VALORIGrid');
  var tboby = table.children[0];
  row.tabIndex = tabIndex;
  tboby.appendChild(row);
}

function AddValuesToDialogGrid(valore, esclusione, sezioneCondizionale, rowIndex) {
  getObj('RELENCO_VALORIGrid_' + rowIndex + '_DescriptionText').value = valore;
  getObj('RELENCO_VALORIGrid_' + rowIndex + '_Esclusione').value = esclusione;

  if (sezioneCondizionale.constructor === String)
    getObj('RELENCO_VALORIGrid_' + rowIndex + '_SezioneCondizionale').value = sezioneCondizionale;
  else
    getObj('RELENCO_VALORIGrid_' + rowIndex + '_SezioneCondizionale').value = sezioneCondizionale[0].value;
}

// Update the hidden input that contains as 'value' the number of rows
function UpdateHiddenInputForNumberOfRows(grid = 'ELENCO_VALORIGrid', totalRowsInGrid, isAddRow, isRemoveRow) { // isAddRow and isRemoveRow are booleans
  var tmpArray = getObjValue(grid + '_extraAttrib').split("#=#"); // Get current rows: tmpArray[0]='numrow' ,  tmpArray[1]=2 (example)
  var endRows = ELENCO_VALORIGrid_EndRow;

  if (totalRowsInGrid) {
    getObj(grid + '_extraAttrib').value = tmpArray[0] + '#=#' + totalRowsInGrid.toString(); // Assign again with one less row
    endRows = totalRowsInGrid;
  }
  else if (isAddRow) {
    var newNumberOfRows = parseInt(tmpArray[1]) + 1; // One more row
    getObj(grid + '_extraAttrib').value = tmpArray[0] + '#=#' + newNumberOfRows.toString(); // Assign again with one less row
    endRows = newNumberOfRows;
  }
  else if (isRemoveRow) {
    var newNumberOfRows = parseInt(tmpArray[1]) - 1; // One less row
    getObj(grid + '_extraAttrib').value = tmpArray[0] + '#=#' + newNumberOfRows.toString(); // Assign again with one less row
    endRows = newNumberOfRows;
  }

  // Update the varibale that contains the index of the last row in the dialog grid 
  ELENCO_VALORIGrid_EndRow = endRows;
}

function GetAllSectionsInTheGrid(currentSectionNumber, totalRows = GetProperty(getObj('DETTAGLIGrid'), 'numrow')) {
  var sections = [];

  for (rowIndex = 0; rowIndex <= totalRows; rowIndex++) {
    var tipoRigaQuestionarioValue = getObjValue('RDETTAGLIGrid_' + rowIndex + '_TipoRigaQuestionario');

    if (tipoRigaQuestionarioValue === 'Sezione') {
      descrizione = getObjValue('RDETTAGLIGrid_' + rowIndex + '_Descrizione');

      if (currentSectionNumber === getObjValue('RDETTAGLIGrid_' + rowIndex + '_KeyRiga')) {
        // g_dettagliGridCurrentSectionDescription = descrizione;
        g_dettagliGridCurrentSectionUniqueKey = getObjValue('RDETTAGLIGrid_' + rowIndex + '_ChiaveUnivocaRiga');
      }

      if (descrizione.trim() === '')
        continue;

      chiaveUnivocaRiga = getObjValue('RDETTAGLIGrid_' + rowIndex + '_ChiaveUnivocaRiga');

      sections.push({
        sectionCode: chiaveUnivocaRiga,
        description: descrizione
      });
    }
  }

  return sections;
}

function AddRowToGrid() {
  var rowIndex = getObj('ELENCO_VALORIGrid').rows.length - 1;

  if (rowIndex % 2 === 0) {
    ConstructOddRow(rowIndex);
  }
  else {
    ConstructEvenRow(rowIndex);
  }

  DisplayGrid(g_rowToDisplay, rowIndex);
  AddGridRowToJson(rowIndex);

  // Enable drag and drop
  ActiveGridDrag('ELENCO_VALORIGrid', MoveAllDocInDialog);

  // Set focus in the row added, on the "Valore" column
  getObj('RELENCO_VALORIGrid_' + rowIndex + '_DescriptionText').focus();

  // Increase the value of number of rows (input with id=ELENCO_VALORIGrid_extraAttrib)
  UpdateHiddenInputForNumberOfRows('ELENCO_VALORIGrid', undefined, 1);
}

function AddGridRowToJson(rowIndex) {
  g_techInfoParametro.gridObjByRows.push({
    valore: getObjValue('RELENCO_VALORIGrid_' + rowIndex + '_DescriptionText'),
    esclusione: getObjValue('RELENCO_VALORIGrid_' + rowIndex + '_Esclusione'),
    sezioneCondizionale: getObj('RELENCO_VALORIGrid_' + rowIndex + '_SezioneCondizionale')
  });
}

// Override of the same function in "sec_Dettagli.js" file. Used to remove a row from the grid
function DettagliDelDialog(grid, row, column) { // example: grid==='ELENCO_VALORIGrid', row===1, column===1
  // Remove the element
  g_techInfoParametro.gridObjByRows.splice(row, 1);

  // Delete all the rows from the grid of the dialog
  RemoveAllRows();

  // Rebuild/Redraw the grid
  BuildGrid();

  BuildJson(g_techInfoParametro.tipoParametro);

  var gridRowsLength = getObj(grid).rows.length - 1;
  // Set focus
  if (gridRowsLength > 0) {
    // TODO: Check which of the following was is more appropriate to use (the .focus() or .scrollIntoView())
    if (row < gridRowsLength) { // First row deleted (row === 0) or the row deleted was in the middle
      // getObj('R' + grid + '_' + row + '_DescriptionText').focus(); // Esempio: RELENCO_VALORIGrid_4_DescriptionText = R + ELENCO_VALORIGrid + _ + 4 + _DescriptionText
      // getObj(grid + 'R' + row).scrollIntoView({ behavior: 'smooth' });
      getObj(grid + 'R' + row).focus(); // This works because tabindex was added to the element (in the DOM)
    }
    else if (row === gridRowsLength) { // Last row deleted
      // getObj('R' + grid + '_' + (row - 1) + '_DescriptionText').focus();
      // getObj(grid + 'R' + (row - 1)).scrollIntoView({ behavior: 'smooth' });
      getObj(grid + 'R' + (row - 1)).focus(); // This works because tabindex was added to the element (in the DOM)
    }
  }

  // Removed one row
  UpdateHiddenInputForNumberOfRows(grid, null, null, 1);
}

// Function for the drag and drop of rows in the dialog
function MoveAllDocInDialog(r, verso) {
  Move_Abstract('ELENCO_VALORIGrid', 'DescriptionText', r, verso);
  Move_Abstract('ELENCO_VALORIGrid', 'Esclusione', r, verso);
  Move_Abstract('ELENCO_VALORIGrid', 'SezioneCondizionale', r, verso);

  BuildJson(g_techInfoParametro.tipoParametro);
}

function OnValoreChange(thisObj) {
  var rowIndex = thisObj.id.split('_')[2];
  var valore = getObjValue('RELENCO_VALORIGrid_' + rowIndex + '_DescriptionText');
  g_techInfoParametro.gridObjByRows[rowIndex].valore = valore;
}

function OnEsclusioneChange(thisObj) {
  var rowIndex = thisObj.id.split('_')[2];
  var esclusione = getObjValue('RELENCO_VALORIGrid_' + rowIndex + '_Esclusione');
  g_techInfoParametro.gridObjByRows[rowIndex].esclusione = esclusione;
}

function OnChangeSezioneCondizionale(thisObj) {
  var rowIndex = thisObj.id.split('_')[2];
  var sezioneCondizionale = getObjValue('RELENCO_VALORIGrid_' + rowIndex + '_SezioneCondizionale');
  g_techInfoParametro.gridObjByRows[rowIndex].sezioneCondizionale = sezioneCondizionale;
}

function UpdateEsitoVerifica() {
  SetTextValue('Note', '<img src="../images/Domain/State_ERR.png"><br>' + CNV('../../', 'La lista sezioni/note/parametri e\' stata modificata, e\' necessario eseguire il comando Verifica Informazioni'));
}

function UpdateEsitoRiga(rowIndex) {
  var mlText = CNV('../../', 'La lista sezioni/note/parametri e\' stata modificata, e\' necessario eseguire il comando Verifica Informazioni');
  var message = `<img src="../images/Domain/State_ERR.png" title="${mlText}"><br>`;
  SetTextValue('RDETTAGLIGrid_' + rowIndex + '_EsitoRiga', message);
}

function MyMakeDocFrom(params) {
  if (getObjValue('Note') !== '<img src="../images/Domain/state_ok22x23.png">') {
    DMessageBox('../', 'Per visualizzare esempio questionario necessario correggere gli errori di compilazione', 'Attenzione', 2, 400, 300);
    return;
  }

  var idDoc = getObjValue('IDDOC');
  var model = 'MODULO_QUESTIONARIO_AMMINISTRATIVO_' + idDoc;
  var nocache = new Date().getTime();

  var ajax = GetXMLHttpRequest();
  ajax.open("GET", '../../ctl_library/REFRESH.ASP?PROCESS=YES&OBJ=MODEL&CHI=' + model + '&nocache=' + nocache, false);
  ajax.send(null);

  if (ajax.readyState == 4) {
    if (ajax.status == 404 || ajax.status == 500) {
      alert('Errore invocazione pagina');
    }

    MakeDocFrom(params);
  }
}

function DetermineRowBackground(objValue, rowIndex) {
  if ((objValue === '' || objValue) && (rowIndex || rowIndex === 0)) {
    var row = getObj('DETTAGLIGridR' + rowIndex);

    row.className = row.className.replace('GR_Q_S', '');
    // row.className = row.className.replace('GR_Q_P', '');
    // row.className = row.className.replace('GR_Q_N', '');

    if (objValue === "Sezione") {
      row.className += ' GR_Q_S';
    }
    // else if (objValue === "Parametro") {
    //   row.className += ' GR_Q_P';
    // }
    // else if (objValue === "Nota") {
    //   row.className += ' GR_Q_N';
    // }
  }
}

function DetermineVisibilityOfOpenCloseSectionIcon(rowIndex) {
  if (getObj('RDETTAGLIGrid_' + rowIndex + '_TipoRigaQuestionario').value !== 'Sezione') {
    setVisibility(getObj('RDETTAGLIGrid_' + rowIndex + '_FNZ_CONTROLLI'), 'none');
  }
  else { //if (getObj('RDETTAGLIGrid_' + rowIndex + '_TipoRigaQuestionario').value === 'Sezione')
    setVisibility(getObj('RDETTAGLIGrid_' + rowIndex + '_FNZ_CONTROLLI'), '');
  }
}

function OpenCloseSection(grid, row, column) {
  var gridRowsNumber = getObj('DETTAGLIGrid').rows.length - 1;

  for (var rowIndex = (row + 1); rowIndex < gridRowsNumber; rowIndex++) {
    if (getObj('RDETTAGLIGrid_' + rowIndex + '_TipoRigaQuestionario').value === 'Sezione') {
      break;
    }

    var gridRow = getObj('DETTAGLIGridR' + rowIndex);

    if (gridRow.className.includes('display_none_soft')) {
      gridRow.className = gridRow.className.replace(' display_none_soft', '');
      var imgElement = getObj('RDETTAGLIGrid_' + row + '_FNZ_CONTROLLI').getElementsByTagName('img')[0];
      imgElement.parentElement.innerHTML = `<img class="img_label_alt" alt="${CNV('../../', 'meno.png')}" src="../images/toolbar/collapse25x25.png" title="${CNV('../../', 'meno.png')}" />`;
      // $('#RDETTAGLIGrid_' + row + '_FNZ_CONTROLLI').find('img')[0].parentElement.innerHTML = '<img class="img_label_alt" alt="???meno.png???" src="../images/toolbar/meno.png" title="???meno.png???" />';
    }
    else {
      gridRow.className += ' display_none_soft';
      var imgElement = getObj('RDETTAGLIGrid_' + row + '_FNZ_CONTROLLI').getElementsByTagName('img')[0];
      imgElement.parentElement.innerHTML = `<img class="img_label_alt" alt="${CNV('../../', 'add.png')}" src="../images/toolbar/extend25x25.png" title="${CNV('../../', 'add.png')}" />`;
      // $('#RDETTAGLIGrid_' + row + '_FNZ_CONTROLLI').find('img')[0].parentElement.innerHTML = '<img class="img_label_alt" alt="???add.png???" src="../images/toolbar/add.png" title="???add.png???" />';
    }
  }
}

function OpenAllSections(gridRowsNumber) {
  var chiaveUnivocaOfClosedRows = []; // Contiene i valori delle ChiaveUnivocaRiga delle Sezioni chiuse 

  for (var rowIndex = 0; rowIndex <= gridRowsNumber; rowIndex++) {
    var gridRow = getObj('DETTAGLIGridR' + rowIndex);

    if (gridRow.className.includes(' display_none_soft')) {
      chiaveUnivocaOfClosedRows.push(getObjValue('RDETTAGLIGrid_' + rowIndex + '_ChiaveUnivocaRiga'));
    }

    gridRow.className = gridRow.className.replace(' display_none_soft', '');

    var imgElement = getObj('RDETTAGLIGrid_' + rowIndex + '_FNZ_CONTROLLI').getElementsByTagName('img')[0];
    imgElement.parentElement.innerHTML = `<img class="img_label_alt" alt="${CNV('../../', 'meno.png')}" src="../images/toolbar/collapse25x25.png" title="${CNV('../../', 'meno.png')}" />`;
  }

  return chiaveUnivocaOfClosedRows;
}

// L'override della funzione che sposta le righe per il drag and drop
// Questa è l'override della funzione che si trova in //afsvm046/Application/CTL_Library/jscript/Grid/Grid.js
function GridMoveRow(gridName, onMoveRow, startingIndex, endingIndex) {
  // Tolgo 2 righe per la caption e perché la numerazione è a base 1 (1 based)
  // La patch non considera la paginazione della griglia
  var gridRowsNumber = getObj(gridName).rows.length - 2;

  while (endingIndex < gridRowsNumber && startingIndex < endingIndex) {
    var tmp = endingIndex; // Variabile per uscire dal ciclo se la prossima riga non è una sezione o se non è nascosta

    // Cerca se dopo la riga con indice endingIndex ci sono altre righe nascoste (con "display: none;")
    if (getObj('RDETTAGLIGrid_' + (endingIndex + 1) + '_TipoRigaQuestionario').value === 'Sezione') {
      break;
    }

    var nextGridRow = getObj('DETTAGLIGridR' + (endingIndex + 1));
    if (nextGridRow.className.includes('display_none_soft')) {
      endingIndex++;
    }

    if (tmp === endingIndex) {
      break;
    }
  }

  var chiaveUnivocaOfClosedRows = OpenAllSections(gridRowsNumber);

  var verso = 1;

  if (endingIndex < eval(gridName + '_StartRow')) {
    endingIndex = eval(gridName + '_StartRow');
  }

  if (endingIndex > eval(gridName + '_EndRow')) {
    endingIndex = eval(gridName + '_EndRow');
  }

  if (endingIndex < startingIndex) {
    verso = -1;
  }

  if (getObj('RDETTAGLIGrid_' + startingIndex + '_TipoRigaQuestionario').value === 'Sezione') {
    if (verso === 1) {
      if (getObj('RDETTAGLIGrid_' + (endingIndex + 1) + '_TipoRigaQuestionario') === null || getObjValue('RDETTAGLIGrid_' + (endingIndex + 1) + '_TipoRigaQuestionario') === 'Sezione') {
        GridMoveSectionRowsDown(gridRowsNumber, onMoveRow, startingIndex, endingIndex, verso);
      }
    }
    else {
      if (getObjValue('RDETTAGLIGrid_' + (endingIndex) + '_TipoRigaQuestionario') === 'Sezione') {
        GridMoveSectionRowsUp(gridRowsNumber, onMoveRow, startingIndex, endingIndex, verso);
      }
    }
  }
  else {
    GridMoveOneRowDown(gridRowsNumber, onMoveRow, startingIndex, endingIndex, verso);
  }

  RestoreClosedSections(gridRowsNumber, chiaveUnivocaOfClosedRows);

  AdjustGrid();
  UpdateEsitoVerifica();

  UpdateImageOfClosedSections(gridRowsNumber);
}

function GridMoveSectionRowsDown(gridRowsNumber, onMoveRow, startingIndex, endingIndex, verso) {
  var rowsToMove = GetRowsToShift(gridRowsNumber, startingIndex);

  for (var rowIndex = 0; rowIndex < rowsToMove.length; rowIndex++) {
    var movingRowIndex = rowsToMove[0];
    while (movingRowIndex < endingIndex) {
      onMoveRow(movingRowIndex, verso);
      movingRowIndex++;
    }
  }
}

function GridMoveSectionRowsUp(gridRowsNumber, onMoveRow, startingIndex, endingIndex, verso) {
  var rowsToMove = GetRowsToShift(gridRowsNumber, startingIndex);

  for (var rowIndex = 0; rowIndex < rowsToMove.length; rowIndex++) {
    var movingRowIndex = rowsToMove[rowsToMove.length - 1];
    while (movingRowIndex > endingIndex) {
      onMoveRow(movingRowIndex, verso);
      movingRowIndex--;
    }
  }
}

function GetRowsToShift(gridRowsNumber, startingIndex) {
  var rowsToMove = [startingIndex]; // Vettore di numeri, ossia gli indici delle righe da spostare

  // Get rows to be moved
  for (var rowIndex = (startingIndex + 1); rowIndex <= gridRowsNumber; rowIndex++) {
    if (getObj('RDETTAGLIGrid_' + rowIndex + '_TipoRigaQuestionario').value === 'Sezione') {
      break;
    }
    else {
      rowsToMove.push(rowIndex);
    }
  }

  return rowsToMove;
}

function GridMoveOneRowDown(gridRowsNumber, onMoveRow, startingIndex, endingIndex, verso) {
  var countingIndex = startingIndex;

  if (endingIndex > gridRowsNumber) {
    endingIndex = gridRowsNumber;
  }

  while (countingIndex !== endingIndex) {
    onMoveRow(countingIndex, verso);
    countingIndex = countingIndex + verso;
  }
}

function RestoreClosedSections(gridRowsNumber, chiaveUnivocaOfClosedRows) {
  for (var rowIndex = 0; rowIndex <= gridRowsNumber; rowIndex++) {
    var currentChiaveUnivoca = getObjValue('RDETTAGLIGrid_' + rowIndex + '_ChiaveUnivocaRiga')

    if (chiaveUnivocaOfClosedRows.includes(currentChiaveUnivoca)) {
      var gridRow = getObj('DETTAGLIGridR' + rowIndex);
      gridRow.className += ' display_none_soft';
    }
  }
}

function UpdateImageOfClosedSections(gridRowsNumber) {
  for (var rowIndex = 0; rowIndex <= gridRowsNumber; rowIndex++) {
    if (getObj('RDETTAGLIGrid_' + rowIndex + '_TipoRigaQuestionario').value === 'Sezione') {
      var nextGridRow = getObj('DETTAGLIGridR' + (rowIndex + 1))

      if (nextGridRow.className.includes(' display_none_soft')) {
        var imgElement = getObj('RDETTAGLIGrid_' + rowIndex + '_FNZ_CONTROLLI').getElementsByTagName('img')[0];
        imgElement.parentElement.innerHTML = `<img class="img_label_alt" alt="${CNV('../../', 'add.png')}" src="../images/toolbar/extend25x25.png" title="${CNV('../../', 'add.png')}" />`;
      }
    }
  }
}