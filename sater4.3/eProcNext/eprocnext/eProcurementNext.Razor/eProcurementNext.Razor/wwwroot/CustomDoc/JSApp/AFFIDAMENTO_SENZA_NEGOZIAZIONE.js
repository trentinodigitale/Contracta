var flag = 0;
var OldValueTipoBando = '';
var gModAttribPunteggio = '';
var oldDivisione_lotti = '';
var oldCriterioAggiudicazioneGara = '';
var oldConformita = '';
var areAppaltoPnrrFieldsHidden = false;


$(document).ready(function () {
  OnLoadPage();
});

function OnLoadPage() 
{
  var DOCUMENT_READONLY_LOCAL = '0';
  var CriterioAggiudicazione;
  //PCP
  try {
      PCP_showOrHideFields();
	  
	  PCP_CodiceCentroDiCosto();
  } catch { }
  
  try {
    if (typeof InToPrintDocument !== 'undefined' || getObjValue('StatoFunzionale') == 'InApprove') {
      DOCUMENT_READONLY_LOCAL = '1';
    }
    else {

      DOCUMENT_READONLY_LOCAL = getObj('DOCUMENT_READONLY').value;
    }

    CriterioAggiudicazione = getObjValue('CriterioAggiudicazioneGara');

  }
  catch (e) {
  }
  
  //-- inizializzo il filtro dei cig validi
  REQUISITI_AFTER_COMMAND('');
  
  
}



function REQUISITI_AFTER_COMMAND(param) {

  var DOCUMENT_READONLY;
  try { DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value; } catch (e) { DOCUMENT_READONLY = '1' };
  try {
    if (DOCUMENT_READONLY == 0) {
      var r = 0;
      var n = getObj('REQUISITIGrid').rows.length;
      while (r < n) {

        SetProperty(getObj('RREQUISITIGrid_' + r + '_ElencoCIG'), 'filter', 'SQL_WHERE= idHEader  = \'' + getObjValue('IDDOC') + '\' ');

        r++;
      }

    }
  } catch (e) { }
}

function hasPCP() {
  return !!getObj("FLD_INTEROP");
}

function onChangeUserRUP() {

  var TipoProceduraCaratteristica = getObj('TipoProceduraCaratteristica').value
  var EnteProponente = getObjValue('EnteProponente').split('#')[0];
  var enteappaltante = getObjValue('Azienda');

  //vado ad aggiornare il campo DirezioneEspletante in funzione della struttura di appartenenza 
  //associata al rup espletante
  //sui campi gerarchici non Ã¯Â¿Â½ implemtnata la funziuone UpdateFieldVisual
  //UpdateFieldVisual(getObj('UserRUP'),'DIREZIONEESPLETANTE_FROM_RUP','STRUTTURAAPPARTENENZA_FROM_RUP','no','=','parent','filtro_StrutturaAppartenenza( \'DirezioneEspletante\' )');

  //faccio una chiamata ajax per aggiornare il campo DirezioneEpletante
  if (getObj('UserRUP').value != '') {
    var nocache = new Date().getTime();

    ajax = GetXMLHttpRequest();

    ajax.open("GET", '../../ctl_library/functions/Get_StrutturaAppartenenza_User.asp?IdPfu=' + getObj('UserRUP').value + '&nocache=' + nocache, false);
    ajax.send(null);

    if (ajax.readyState == 4) {
      //alert(ajax.status); 
      if (ajax.status == 404 || ajax.status == 500) {
        alert('Errore invocazione pagina');
        return;
      }
      //alert(ajax.responseText); 
      if (ajax.responseText != '') {

        var vet = ajax.responseText.split('@@@');

        getObj('DirezioneEspletante').value = vet[0];
        //getObj('DirezioneEspletante_edit').value = vet[1];
        //getObj('DirezioneEspletante_edit_new').value = vet[1];
        getObj('Cell_DirezioneEspletante').innerHTML = getObj('DirezioneEspletante').outerHTML;

        if (vet[1] != 'Seleziona')
          getObj('Cell_DirezioneEspletante').innerHTML = getObj('Cell_DirezioneEspletante').innerHTML + vet[1];


      }
    }
  }
  else {
    getObj('DirezioneEspletante').value = '';
    //getObj('DirezioneEspletante_edit').value = 'Seleziona';
    //getObj('DirezioneEspletante_edit_new').value ='Seleziona';
    getObj('Cell_DirezioneEspletante').innerHTML = getObj('DirezioneEspletante').outerHTML;

  }

  //aggiorno strutturaaziendale con lo stesso valore di direzioneespletante
  getObj('StrutturaAziendale').value = getObj('DirezioneEspletante').value;

  if (EnteProponente == enteappaltante) //se coincidono valorizzo RupProponente con lo stesso valore Selezionando il rup espletante puÃ¯Â¿Â½ cambiare il RUP proponente solo se vuoto, nel caso di pieno do un warning se diverso 
  {

    if (getObj('RupProponente').value == '' && getObj('RupProponente').type == 'select-one')  //vuoto ed editable
    {
      //setto il rup proponente	
      SetDomValue('RupProponente', getObj('UserRUP').value);

      //setto la struttura proponente in funzione del rup proponente
      //onChangeRUP_Prop();

      //chiamo un processo fittizio per salvare tutto
      ExecDocProcess('CAMBIO_RUP,DOCUMENT');
    }
    else {
      if (getObj('RupProponente').value != getObj('UserRUP').value) {
        //se non sono nel caso di AFFIDAMENTO DIRETTO SEMPLIFICATO COME PRIMA
        if (TipoProceduraCaratteristica != 'AffidamentoSemplificato') {
          ML_text = 'Si evidenzia che il riferimento selezionato come RUP non coincide con la selezione del RUP Proponente.';
          Title = 'Informazione';
          ICO = 1;
          page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent(ML_text) + '&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);

          ExecFunctionModale(page, null, 200, 420, null);
        }
        else {
          //riporto in RUPPROPONENTE RUP PER COERENZA
          getObj('RupProponente').value = getObj('UserRUP').value;

        }
      }

    }

  }

  SetFilterIniziative_FromRup();

}

function PCP_showOrHideFields() {

  //TAB CronologiaPCP
  try
  {
	  
	  let thPCP_CRONOLOGIAGrid_StatoFunzionale = getObj("PCP_CRONOLOGIAGrid_StatoFunzionale");
	  let thPCP_CRONOLOGIAGrid_Name = getObj("PCP_CRONOLOGIAGrid_Name");
	  let thPCP_CRONOLOGIAGrid_Titolo = getObj("PCP_CRONOLOGIAGrid_Titolo");
	  let thPCP_CRONOLOGIAGrid_TipoScheda = getObj("PCP_CRONOLOGIAGrid_TipoScheda");
	  let thPCP_CRONOLOGIAGrid_TipoDoc = getObj("PCP_CRONOLOGIAGrid_TipoDoc");
	  let indexOfthPCP_CRONOLOGIAGrid_StatoFunzionale = 0;
	  let indexOfthPCP_CRONOLOGIAGrid_Name = 0;
	  let indexOfthPCP_CRONOLOGIAGrid_Titolo = 0;
	  let indexOfthPCP_CRONOLOGIAGrid_TipoScheda = 0;
	  let indexOfthPCP_CRONOLOGIAGrid_TipoDoc = 0;
	  for (let i = 0; i < thPCP_CRONOLOGIAGrid_StatoFunzionale.parentElement.childElementCount; i++) {
		if (thPCP_CRONOLOGIAGrid_StatoFunzionale.parentElement.children[i] == thPCP_CRONOLOGIAGrid_StatoFunzionale) {
		  indexOfthPCP_CRONOLOGIAGrid_StatoFunzionale = i;
		}
		if (thPCP_CRONOLOGIAGrid_StatoFunzionale.parentElement.children[i] == thPCP_CRONOLOGIAGrid_Name) {
			indexOfthPCP_CRONOLOGIAGrid_Name = i;
		  }
		if (thPCP_CRONOLOGIAGrid_StatoFunzionale.parentElement.children[i] == thPCP_CRONOLOGIAGrid_Titolo){
			indexOfthPCP_CRONOLOGIAGrid_Titolo = i;
		}
		if (thPCP_CRONOLOGIAGrid_StatoFunzionale.parentElement.children[i] == thPCP_CRONOLOGIAGrid_TipoScheda){
			indexOfthPCP_CRONOLOGIAGrid_TipoScheda = i;
		}
		if (thPCP_CRONOLOGIAGrid_StatoFunzionale.parentElement.children[i] == thPCP_CRONOLOGIAGrid_TipoDoc){
			indexOfthPCP_CRONOLOGIAGrid_TipoDoc = i;
		}
	  }
	  trCountCronologiaPCP = getObj("PCP_CRONOLOGIAGrid").firstElementChild.childElementCount - 1;
		const textToDownloadButton = (FldDomainValue, TipoScheda, Operazione, num) => {
			let file = FldDomainValue.innerText;
			if (!!file && `${file}`.trim().length > 0) {
				let extType;
				if (file.indexOf("<?") == 0) {
					extType = "xml";
				} else if (file.indexOf("{") == 0) {
					extType = "json";
				} else {
					extType = "txt";
				}
				FldDomainValue.innerText = "";
				FldDomainValue.innerHTML = ``;
				let a1 = document.createElement("a");
				let img1 = document.createElement("img");
				a1.setAttribute("href", "#");
				a1.setAttribute("class", "fldLabel_link_img");
				a1.onclick = () => {
					let filename;
					if(!!TipoScheda && TipoScheda.trim() != "" && !!Operazione){
						filename = (Operazione + "_" + TipoScheda);
					}else if(!!Operazione){
						filename = Operazione;
					}else{
						filename = file;
					}
					if(num == 1){
						filename += "_Request";
					}else if(num==2){
						filename += "_Response";
					}
					filename = filename + "." + extType;
					
					
					var element = document.createElement('a');
					element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(file));
					element.setAttribute('download', filename);

					element.style.display = 'none';
					document.body.appendChild(element);

					element.click();

					document.body.removeChild(element);
				}
				img1.setAttribute("class", "img_label_alt")
				img1.setAttribute("alt", "Download " + extType)
				img1.setAttribute("src", "../../CTL_Library/images/Domain/downloadXml.png")
				img1.setAttribute("title", "Download " + extType)
				img1.setAttribute("style", "width: 25px")
				a1.appendChild(img1);
				FldDomainValue.appendChild(a1);
			}

		}
		
		const textToDownloadButtonLink = (FldDomainValue, idRow, idRic, TipoScheda, Operazione, request, content) => 
		{
			FldDomainValue.innerText = "";
			FldDomainValue.innerHTML = ``;

			if ( content != 'NONE' )
			{

				let a1 = document.createElement("a");
				let img1 = document.createElement("img");
				a1.setAttribute("href", "#");
				a1.setAttribute("class", "fldLabel_link_img");
				
				a1.onclick = () => {
									
					var element = document.createElement('a');
					element.setAttribute('href', '../../pcp/PCP_DownloadPayload.asp?ID=' + idRow + '&IDRIC=' + idRic + '&REQ=' + request + '&SCHEDA=' + TipoScheda + '&OPERATION=' + Operazione);
					element.style.display = 'none';
					document.body.appendChild(element);

					element.click();

					document.body.removeChild(element);
				}
				
				img1.setAttribute("class", "img_label_alt")
				img1.setAttribute("alt", "Download payload")
				img1.setAttribute("src", "../../CTL_Library/images/Domain/downloadXml.png")
				img1.setAttribute("title", "Download payload")
				img1.setAttribute("style", "width: 25px")
				a1.appendChild(img1);
				FldDomainValue.appendChild(a1);
		
			}

		}
		
		
		const textTruncate = (elem) => {
			if (`${elem.innerText}`.trim().length > 50) {
				elem.innerText = elem.innerText.substr(0, 50) + "...";
			}
		}

	  for (let i = 0; i < PCP_CRONOLOGIAGrid_NumRow + 1; i++) 
	  {
		  if(getObj(`PCP_CRONOLOGIAGrid_r${i}_c${indexOfthPCP_CRONOLOGIAGrid_Name}`) == null){ continue; }
		  let TextValueName = getObj(`PCP_CRONOLOGIAGrid_r${i}_c${indexOfthPCP_CRONOLOGIAGrid_Name}`).getElementsByClassName("Text")[0];
		  let FldDomainValueStatoFunzionale = getObj(`PCP_CRONOLOGIAGrid_r${i}_c${indexOfthPCP_CRONOLOGIAGrid_StatoFunzionale}`).getElementsByClassName("FldDomainValue")[0];
		  let TextValueTitolo = getObj(`PCP_CRONOLOGIAGrid_r${i}_c${indexOfthPCP_CRONOLOGIAGrid_Titolo}`).getElementsByClassName("Text")[0];
		  let TipoScheda = getObj(`PCP_CRONOLOGIAGrid_r${i}_c${indexOfthPCP_CRONOLOGIAGrid_TipoScheda}`).getElementsByClassName("Text")[0].innerText;
		  let Operazione = getObj(`PCP_CRONOLOGIAGrid_r${i}_c${indexOfthPCP_CRONOLOGIAGrid_TipoDoc}`).getElementsByClassName("FldDomainValue")[0].innerText;

		  let idRow = getObjValue(`R${i}_idRow`);
		  let idRic = getObjValue('IDDOC');

		  //let respContent = getObjValue('val_R${i}_StatoFunzionale_extraAttrib');
		  let respContent = getExtraAttrib(`val_R${i}_StatoFunzionale`, 'value');
		  //getObjValue('val_R${i}_StatoFunzionale_extraAttrib');

		  let reqContent = getObjValue(`R${i}_Name`);

		  //textToDownloadButton(TextValueName, TipoScheda, Operazione, 1);
		  //textToDownloadButton(FldDomainValueStatoFunzionale, TipoScheda, Operazione, 2);

		  textToDownloadButtonLink(TextValueName, idRow, idRic, TipoScheda.trim(), Operazione, 1, reqContent);
		  textToDownloadButtonLink(FldDomainValueStatoFunzionale, idRow, idRic, TipoScheda.trim(), Operazione, 0, respContent);

		  textTruncate(TextValueTitolo);
		}
   }catch{}

  //End TAB CronologiaPCP

}

function PCP_CodiceCentroDiCosto() {

	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;

    //se doc non editabile non faccio nulla
    if (DOCUMENT_READONLY == 1) {
        return;
    }

	var CN16_CODICE_APPALTO='';
	try
	{
		CN16_CODICE_APPALTO = getObj( 'CN16_CODICE_APPALTO').value;
	}
	catch(e){}
	
	//-- il codice appalto interno viene generato esclusivamente per le nuove procedure
	if ( CN16_CODICE_APPALTO != '' )
	{	
		ajax = GetXMLHttpRequest(); 
		var nocache = new Date().getTime();
		
		if(ajax)
		{
			const urlParams = new URLSearchParams(window.location.search.toLowerCase());
			const iddoc = urlParams.get('iddoc');
			ajax.open("GET", pathRoot + "../WebApiFramework/api/ConfermaAppalto/recuperaCDC?idDoc=" + iddoc + '&nocache=' + nocache, false);
			ajax.onreadystatechange = function () 
			{

				if(ajax.readyState == 4) 
				{
					var res = ajax.responseText;
					if(ajax.status == 200)
					{
						if ( res!= '' ) 
						{
							//console.table(res)
							var objCDCs = JSON.parse(res);
							var lenCDCs = objCDCs.length;
							var objCDCsToString = "";
							for(let i=0; i < lenCDCs; i++){
								objCDCsToString += objCDCs[i].idCentroDiCosto + "@@@" + objCDCs[i].denominazioneCentroDiCosto;
								if( i != (lenCDCs - 1)){
									objCDCsToString += "#~#";
								}
							}

							let objToModify = getObj("pcp_CodiceCentroDiCosto");
							if(DOCUMENT_READONLY == 1){
								let ainfo = objCDCsToString.split('#~#');
								let found = false;
								let denominazione = "";
								for ( k = 0 ; k < ainfo.length ;  k++ )
								{
									if(ainfo[k].split('@@@')[0] == objToModify.value){
										found = true;
										denominazione = ainfo[k].split('@@@')[1];
									}
								
								}
								let tecValue = objToModify.value;
								SetTextValue("pcp_CodiceCentroDiCosto", denominazione);
								objToModify.value = tecValue;
								
							}else{
								CRITERIO_Domain(objToModify, objCDCsToString);
							}
							
						}
					}
				}
			}

			ajax.send();

		}
		
	}
	
}


function SetFilterIniziative_FromRup() {

  //solo se il doc editabile e attivo il modulo PROGRAMMAZIONE_INIZIATIVE
  if (getObj('isActive_GROUP_PROGRAMMAZIONE_INIZIATIVA') &&
    getObj('isActive_GROUP_PROGRAMMAZIONE_INIZIATIVA') !== null &&
    getObjValue('isActive_GROUP_PROGRAMMAZIONE_INIZIATIVA') == 'yes') {

    var strFilter = 'SQL_WHERE= dmv_cod in ( select ID_Iniziativa from Rup_Programmazione_Iniziative where UserRUP = \'' + getObjValue('UserRUP') + '\' )';

    SetProperty(getObj('IdentificativoIniziativa'), 'filter', strFilter);
  }
}


function CambiaTipoAppalto() {
  ExecDocProcess('ONCHANGETIPOAPPALTOGARA,BANDO_GARA');
}


function OnChangeDirezioneEspletante() {
  //allineo il valore della struttura aziendale con quello della direzione espletante
  getObj('StrutturaAziendale').value = getObj('DirezioneEspletante').value;
}

function onchangeEnteProponente() {
  filtraRupProponente();
}

//per alimnetare il campo pcp_categoria  presente sui prodotti
function OnChangepcp_Categoria() 
{
	if ( getObjValue('pcp_Categoria') != '')
	{
		ExecDocProcess('MODIFICA_PCP_CATEGORIA,BANDO_GARA,,NO_MSG');
	}
}


function openGEO_simog() {
  codApertura = 'M-1-11-ITA';

  var tmp = getObjValue('COD_LUOGO_ISTAT');

  if (tmp !== '') {
    codApertura = tmp;
  }

  //aggiunto il parametro cod_to_exclude per non visualizzare i codici che finiscono con XXX, quindi gli elementi 'altro' del dominio
  ExecFunction('../../Ctl_Library/gerarchici.asp?lo=content&portale=no&cod_to_exclude=%25XXX&fieldname=localita&path_filtra=GEO&caption=Dominio GEO&help=help_geo_ente&path_start=GEO&lvl_sel=,7,&lvl_max=7&sel_all=1&cod=' + codApertura + '&js=impostaLuogoIstat', 'DOMINIO_GEO', ',width=700,height=750');
}


function impostaLuogoIstat(cod, fieldName) {

  ajax = GetXMLHttpRequest();

  if (ajax) {
    ajax.open("GET", '../../ctl_library/functions/infoNodoGeo.asp?fldname=stato&cod=' + escape(cod), false);

    ajax.send(null);

    if (ajax.readyState == 4) {
      //Se non ci sono stati errori di runtime
      if (ajax.status == 200) {
        if (ajax.responseText != '') {
          var res = ajax.responseText;

          //Se l'esito della chiamata Ã¯Â¿Â½ stato positivo
          if (res.substring(0, 2) == '1#') {
            try {
              var vet = res.split('###');

              var desc;

              desc = vet[1];

              getObj('DESC_LUOGO_ISTAT').value = desc;
              getObj('DESC_LUOGO_ISTAT_V').innerHTML = desc;
              getObj('COD_LUOGO_ISTAT').value = cod;

            }
            catch (e) {
              alert('Errore:' + e.message);
            }
          }
        }
      }

    }

  }
}


function onChangeCPV() {
  var valCodiceCPV = getObjValue('CODICE_CPV');

  if (valCodiceCPV != '') {

    var ultimi6 = valCodiceCPV.substr(valCodiceCPV.length - 6);
    var ultimi5 = valCodiceCPV.substr(valCodiceCPV.length - 5);

    // Consentiamo la selezione solo dei livelli maggiori o uguale al 3
    if (ultimi6 == '000000' || ultimi5 == '00000') {

      //per i livelli inferiore al terzo consento la selezione solo dei nodi foglie
      //effettuo il controllo con chiamata ajax
      var nocache = new Date().getTime();

      ajax = GetXMLHttpRequest();

      ajax.open("GET", '../../ctl_library/functions/FIELD/CK_FldHierarchy_ChildNode.asp?DOMAIN=CODICE_CPV&CODICE=' + valCodiceCPV + '&nocache=' + nocache, false);
      ajax.send(null);

      if (ajax.readyState == 4) {
        //alert(ajax.status); 
        if (ajax.status == 404 || ajax.status == 500) {
          alert('Errore invocazione pagina');
          return;
        }
        //alert(ajax.responseText); 
        if (ajax.responseText != 'YES') {
          getObj('CODICE_CPV').value = '';
          getObj('CODICE_CPV_edit_new').value = '';

          //DMessageBox( '../' , 'Selezione non valida. Selezionare un voce con un livello di profondita\' maggiore o uguale al terzo' , 'Attenzione' , 1 , 400 , 300 );
          DMessageBox('../', 'Selezione non valida. Selezionare un nodo con un livello maggiore o uguale al terzo oppure un nodo foglia di livello minore al terzo', 'Attenzione', 1, 400, 300);
        }
      }
    }

  }

}

function onChangeCodiceFiscale()
{
	ExecDocProcess('RECUPERA_ANAGRAFICA,AFFIDAMENTO_SENZA_NEGOZIAZIONE,,NO_MSG');
}

function ValidateURL() {
  //Controllo formale sull'url per il campo 'Indirizzo dei documenti di gara (BT-15)'

  // definizione dell'espressione regolare per verificare se la stringa ÃÂ¨ un URL HTTP o HTTPS valido
  var urlPattern = /^(https?):\/\/[^\s/$.?#].[^\s]*$/;

  var objUrlExtRef = getObj('cn16_CallForTendersDocumentReference_ExternalRef');
  var urlExtRef = objUrlExtRef.value;

  // Se l'url ÃÂ¨ diverso da vuoto si va a testare rispetto all'espressione regolare
  if (urlExtRef != '' && !urlPattern.test(urlExtRef)) {
    objUrlExtRef.value = ''; //svuoto il campo considerato non valido
    DMessageBox('../', 'URL non valido. Non rispetta il formato richiesto', 'Attenzione', 1, 400, 300);
  }

}