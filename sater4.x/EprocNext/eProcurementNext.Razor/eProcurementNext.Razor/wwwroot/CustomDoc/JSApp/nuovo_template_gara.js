// window.onload = CheckCreaBando;

$(document).ready(function () {
  CheckCreaBando();
});

function CheckCreaBando() {
  //var strStatoFunzionale = getObj( 'StatoFunzionale' ).value;
  var JumpCheck = getObj('JumpCheck').value;

  //if ( strStatoFunzionale == 'InLavorazione')
  if (JumpCheck == 'OK') {
    {
      if (isSingleWin() == true) {

        LoadDocument('TEMPLATE_GARA', getObjValue('IDDOC'));
      }
      else {
        ShowDocumentPath('TEMPLATE_GARA', getObjValue('IDDOC'), '../');
        window.close();
      }
    }
  }
  else {
    //-- setta il filtro per il tipobandogara
    OnChangeProcedura(this);
  }

  //  if( getObjValue( 'Divisione_lotti' ) == '' || getObjValue( 'Divisione_lotti' ) == '0' )
  //	getObj('Complex').disabled=true;

  OnChangeLotti(this);
  OnChangeProcedura(this);

  //-- regola la visualizzazione  del campo "Concessione"
  OnChangeTipoAppalto(this);
}

function OnChangeCriterio(o) {
  if ((getObjValue('CriterioAggiudicazioneGara') == '15532') || (getObjValue('CriterioAggiudicazioneGara') == '25532')) //-- vantaggiosa or costo fisso
    FilterDom('Conformita', 'Conformita', 'No', 'SQL_WHERE=  DMV_COD = \'No\' ', '', ''); //-- solo no
  else
    FilterDom('Conformita', 'Conformita', getObjValue('Conformita'), '', '', ''); //-- tutto

  HideConformita();
}

function OnChangeProcedura(o) {
  var AFFIDAMENTO_DIRETTO_DUE_FASI = getObjValue('AFFIDAMENTO_DIRETTO_DUE_FASI')

  // Se Tipo di Procedura non è "Negoziata" e se il campo/attributo Caratteristica è visibile => nascondi campo Caratteristica.
  if (getObjValue('ProceduraGara') != '15478' && getObj('TipoProceduraCaratteristica').offsetParent !== null) // 15478 == Negoziata
  {
    FilterDom('TipoAppaltoGara', 'TipoAppaltoGara', getObjValue('TipoAppaltoGara'), 'SQL_WHERE=  DMV_COD <> \'4\'', '', '');

    getObj('TipoProceduraCaratteristica').value = '';
    setVisibility(getObj('cap_TipoProceduraCaratteristica'), 'None');
    setVisibility(getObj('TipoProceduraCaratteristica'), 'None');
  }

  if (getObjValue('TipoSceltaContraente') != 'ACCORDOQUADRO') {

    if (getObjValue('ProceduraGara') == '15476' || getObjValue('ProceduraGara') == '15477' || getObjValue('ProceduraGara') == '') // Aperta o Ristretta
    {

      FilterDom('TipoBandoGara', 'TipoBandoGara', '2', 'SQL_WHERE=  dmv_cod = \'2\' ', '', ''); // solo bando

      FilterDom('Divisione_lotti', 'Divisione_lotti', getObjValue('Divisione_lotti'), '', '', 'OnChangeLotti( this );'); // come inizio

      if (getObjValue('Concessione') == 'si')
        FilterDom('CriterioAggiudicazioneGara', 'CriterioAggiudicazioneGara', getObjValue('CriterioAggiudicazioneGara'), 'SQL_WHERE=DMV_COD <> \'\' ', '', 'OnChangeCriterio(this);'); //-- RIMUOVE il filtro
      else
        FilterDom('CriterioAggiudicazioneGara', 'CriterioAggiudicazioneGara', getObjValue('CriterioAggiudicazioneGara'), 'SQL_WHERE=DMV_COD <> \'16291\' ', '', 'OnChangeCriterio(this);'); //-- filtro il prezzo pi? alto

      //getObj('TipoProceduraCaratteristica').value='';
      //setVisibility(getObj('cap_TipoProceduraCaratteristica'), 'none');
      //setVisibility(getObj('TipoProceduraCaratteristica'), 'none');
      OnChangeCriterio();
    }
    else if (getObjValue('ProceduraGara') == '15583' || getObjValue('ProceduraGara') == '15479') // Affidamento Diretto  o Richiesta Preventivo
    {
      if (AFFIDAMENTO_DIRETTO_DUE_FASI == '0' || getObjValue('ProceduraGara') == '15479') {
        // Come prima senza affidamento a due fasi
        FilterDom('TipoBandoGara', 'TipoBandoGara', '3', 'SQL_WHERE=  tdrcodice = \'3\' ', '', ''); // solo invito
        SelectreadOnly('TipoBandoGara', true);
      }
      else {
        //con affidamento diretto a tre fasi
        if (AFFIDAMENTO_DIRETTO_DUE_FASI == '1') {
          FilterDom('TipoBandoGara', 'TipoBandoGara', getObjValue('TipoBandoGara'), 'SQL_WHERE=  tdrcodice in (\'3\',\'4\',\'5\') ', '', ''); //-- solo invito
          SelectreadOnly('TipoBandoGara', false);
        }
      }

      FilterDom('CriterioAggiudicazioneGara', 'CriterioAggiudicazioneGara', '15531', 'SQL_WHERE=DMV_COD = \'15531\' ', '', 'OnChangeCriterio(this);'); // SOLO Prezzo più basso
      SelectreadOnly('CriterioAggiudicazioneGara', true);

      FilterDom('Conformita', 'Conformita', 'No', 'SQL_WHERE=  DMV_COD = \'No\' ', '', ''); //-- solo no
      SelectreadOnly('Conformita', true);

      FilterDom('Divisione_lotti', 'Divisione_lotti', getObjValue('Divisione_lotti'), 'SQL_WHERE=  DMV_COD <> \'1\' ', '', 'OnChangeLotti( this );'); // FILTRO   MULTIVOCE

    }
    else if (getObjValue('ProceduraGara') == '15478') // ProceduraGara==Negoziata
    {
      // Se il campo/attributo Caratteristica non è visibile => rendi visibile campo Caratteristica.
      if (getObj('TipoProceduraCaratteristica').offsetParent === null) {

        // Se attivo il modulo del RDO visualizzo il campo "Caratteristica"
        if (getObjValue('GROUP_Procedura_RDO') === '1') {
          setVisibility(getObj('TipoProceduraCaratteristica'), '');
          setVisibility(getObj('cap_TipoProceduraCaratteristica'), '');
        }

        // getObj('TipoBandoGara').value = '1 ' + '3'; // 1==Avviso, 3==Invito
        FilterDom('TipoBandoGara', 'TipoBandoGara', getObjValue('TipoBandoGara'), 'SQL_WHERE=  tdrcodice in (\'1\',\'3\') ', '', ''); // Avviso + Invito
        FilterDom('CriterioAggiudicazioneGara', 'CriterioAggiudicazioneGara', getObjValue('CriterioAggiudicazioneGara'), 'SQL_WHERE=DMV_COD <> \'16291\' ', '', 'OnChangeCriterio(this);'); // filtro il prezzo più alto
        FilterDom('Conformita', 'Conformita', getObjValue('Conformita'), '', '', ''); //-- tutto
      }

      if (getObjValue('TipoProceduraCaratteristica') === 'RDO') {
        FilterDom('TipoAppaltoGara', 'TipoAppaltoGara', getObjValue('TipoAppaltoGara'), 'SQL_WHERE=  DMV_COD in (\'1\', \'3\') ', '', '');
        getObj('TipoBandoGara').value = '3'; // 3==Invito
        // getObj('TipoBandoGara').disabled = true;
        SelectreadOnly('TipoBandoGara', true);
        FilterDom('Divisione_lotti', 'Divisione_lotti', getObjValue('Divisione_lotti'), 'SQL_WHERE=  DMV_Cod in (\'0\',\'2\') ', '', 'OnChangeLotti( this );'); // non "Lotti Multivoci"

        // TODO: to be tested
        getObj('Complex').value = '0';
        getObj('Complex').disabled = true;
        setVisibility(getObj('cap_Complex'), 'none');
        setVisibility(getObj('Complex'), 'none');
      }
      else {
        FilterDom('TipoAppaltoGara', 'TipoAppaltoGara', getObjValue('TipoAppaltoGara'), 'SQL_WHERE=  DMV_COD <> \'4\'', '', '');
        SelectreadOnly('TipoBandoGara', false);
        // FilterDom('Divisione_lotti', 'Divisione_lotti', getObjValue('Divisione_lotti'), 'SQL_WHERE=  DMV_Cod in (\'0\',\'2\') ', '', 'OnChangeLotti( this );'); // non "Lotti Multivoci"
        FilterDom('Divisione_lotti', 'Divisione_lotti', getObjValue('Divisione_lotti'), '', '', 'OnChangeLotti( this );'); // tutto
      }
    }
    else {
      FilterDom('TipoBandoGara', 'TipoBandoGara', getObjValue('TipoBandoGara'), 'SQL_WHERE=  tdrcodice not in (\'2\',\'4\',\'5\') ', '', '');
      FilterDom('CriterioAggiudicazioneGara', 'CriterioAggiudicazioneGara', getObjValue('CriterioAggiudicazioneGara'), 'SQL_WHERE=DMV_COD <> \'16291\' ', '', 'OnChangeCriterio(this);'); // filtro il prezzo più alto
      FilterDom('Divisione_lotti', 'Divisione_lotti', getObjValue('Divisione_lotti'), '', '', 'OnChangeLotti( this );'); // come inizio
      OnChangeCriterio();
    }
  }
}

function OnChangeTipoSceltaContraente(o) {
  if (getObjValue('TipoSceltaContraente') != 'ACCORDOQUADRO') {
    FilterDom('TipoAppaltoGara', 'TipoAppaltoGara', getObjValue('TipoAppaltoGara'), 'SQL_WHERE=  DMV_COD <> \'4\'', '', '');

    getObj('ProceduraGara').value = '';
    FilterDom('ProceduraGara', 'ProceduraGara', getObjValue('ProceduraGara'), 'SQL_WHERE=  tdrcodice not in ( \'15585\' )', '', 'OnChangeProcedura(this)', 'DT');
    SelectreadOnly('ProceduraGara', false);

    getObj('TipoBandoGara').value = '';
    FilterDom('TipoBandoGara', 'TipoBandoGara', getObjValue('TipoBandoGara'), '', '', ''); // tutto
    SelectreadOnly('TipoBandoGara', false);

    FilterDom('Divisione_lotti', 'Divisione_lotti', getObjValue('Divisione_lotti'), '', '', 'OnChangeLotti( this );'); // tutto
  }
  else {
    if (getObj('CriterioAggiudicazioneGara').classList.contains('readonly')) // Il campo 'CriterioAggiudicazioneGara' è readonly (cioè contiene la classe che lo rende solo lettura)?
      SelectreadOnly('CriterioAggiudicazioneGara', false); // Non è più in sola lettura.
    if (getObj('CriterioFormulazioneOfferte').classList.contains('readonly')) // Il campo 'CriterioFormulazioneOfferte' è readonly (cioè contiene la classe che lo rende solo lettura)?
      SelectreadOnly('CriterioFormulazioneOfferte', false); // Non è più in sola lettura.
    if (getObj('Conformita').classList.contains('readonly')) // Il campo 'Conformita' è readonly (cioè contiene la classe che lo rende solo lettura)?
      SelectreadOnly('Conformita', false); // Non è più in sola lettura.

    FilterDom('TipoAppaltoGara', 'TipoAppaltoGara', getObjValue('TipoAppaltoGara'), 'SQL_WHERE=  DMV_COD <> \'4\' ', '', ''); // filtra per AltraTipologia
    getObj('ProceduraGara').value = '15476'; // ProceduraGara==Aperta
    SelectreadOnly('ProceduraGara', true);

    var hasBandoAsType = false;
    for (var i = 0; i < getObj('TipoBandoGara').options.length; i++) {
      if (getObj('TipoBandoGara').options[i].value === '2') {
        hasBandoAsType = true;
        break;
      }
    }
    if (hasBandoAsType)
      getObj('TipoBandoGara').value = '2'; // TipoBandoGara==Bando
    else {
      FilterDom('TipoBandoGara', 'TipoBandoGara', getObjValue('TipoBandoGara'), '', '', ''); // tutto
      getObj('TipoBandoGara').value = '2'; // TipoBandoGara==Bando
    }
    SelectreadOnly('TipoBandoGara', true);

    getObj('TipoProceduraCaratteristica').value = '';
    setVisibility(getObj('cap_TipoProceduraCaratteristica'), 'None');
    setVisibility(getObj('TipoProceduraCaratteristica'), 'None');

    FilterDom('Divisione_lotti', 'Divisione_lotti', getObjValue('Divisione_lotti'), 'SQL_WHERE=  DMV_COD <> \'0\' ', '', 'OnChangeLotti( this );'); // filtra per AltraTipologia

    // setVisibility(getObj('cap_Complex'), '');
    // setVisibility(getObj('Complex'), '');
  }
}

function OnChangeTipoBando(obj) { }

function OnChangeLotti(o) {
  // If Divisione_lotti === 'Lotti Multivoci'
  if (getObjValue('Divisione_lotti') != '' && getObjValue('Divisione_lotti') != '0' && getObjValue('Divisione_lotti') != '2') {
    //sul modello della RDO Complex non presente
    try {
      getObj('Complex').disabled = false;
      setVisibility(getObj('cap_Complex'), '');
      setVisibility(getObj('Complex'), '');
    } catch (e) { }

    //cambio caption attributo "Criterio Aggiudicazione Gara" se divisione lotti<>no
    if (getObjValue('TipoSceltaContraente') == 'ACCORDOQUADRO')
      getObj('cap_CriterioAggiudicazioneGara').innerHTML = CNV('../../', 'Criterio Valutazione Prevalente');
    else
      getObj('cap_CriterioAggiudicazioneGara').innerHTML = CNV('../../', 'CriterioAggiudicazioneGara Prevalente');
  }
  else { // If Divisione_lotti !== 'Lotti Multivoci'
    //sul modello della RDO Complex non presente
    try {
      getObj('Complex').value = '0';
      getObj('Complex').disabled = true;
      setVisibility(getObj('cap_Complex'), 'none');
      setVisibility(getObj('Complex'), 'none');
    } catch (e) { }

    if (getObjValue('TipoSceltaContraente') == 'ACCORDOQUADRO')
      getObj('cap_CriterioAggiudicazioneGara').innerHTML = CNV('../../', 'Criterio Valutazione');
    else
      getObj('cap_CriterioAggiudicazioneGara').innerHTML = CNV('../../', 'CriterioAggiudicazioneGara');
  }

  HideConformita();
}

function OnChangeFormulazione(o) { }

function HideConformita() {
  //  if( getObjValue( 'CriterioAggiudicazioneGara' ) == '15531' && getObjValue( 'Divisione_lotti' ) == '0'  ) //-- prezzo e no lotti
  //  {
  //    getObj('Conformita').value='No';
  //    setVisibility(getObj('cap_Conformita'), 'none');
  //    setVisibility(getObj('Conformita'), 'none');
  //  }
  //  else
  //  {
  //    setVisibility(getObj('cap_Conformita'), '');
  //    setVisibility(getObj('Conformita'), '');
  //  }
}

function ChangeImpAppalto(obj) {
  var Oneri = Number(getObj('Oneri').value);
  var importoBaseAsta2 = Number(getObj('importoBaseAsta2').value);
  var Opzioni = Number(getObj('Opzioni').value);
  SetNumericValue('importoBaseAsta', Oneri + importoBaseAsta2 + Opzioni);
}

function OnChangeModalita(o) {
  if (getObjValue('ModalitadiPartecipazione') == '16308') //-- Telematica
  {
    //FilterDom( 'Divisione_lotti' ,  'Divisione_lotti' , getObjValue( 'Divisione_lotti' ) , 'SQL_WHERE=  DMV_COD <> \'1\' ' , '' , ''); //-- tutto
    FilterDom('Divisione_lotti', 'Divisione_lotti', getObjValue('Divisione_lotti'), '', '', 'OnChangeLotti( this );'); //-- tutto
  }
  else {
    FilterDom('Divisione_lotti', 'Divisione_lotti', '0', 'SQL_WHERE=  DMV_COD = \'0\' ', '', 'OnChangeLotti( this );'); //-- niente lotti
  }

  OnChangeLotti(o);
}

function LocSaveDoc() {
  
  
  if (getObjValue('TipoProceduraCaratteristica') == 'RDO') {
    //controllo su importo supera le soglie impostate
    if (getObjValue('TipoAppaltoGara') == '1') //forniture
    {
	  
      if (Number(getObjValue('importoBaseAsta')) > Number(getObjValue('Importo_forniture'))) {
        DMessageBox('../', 'Attenzione Importo Appalto maggiore della soglia stabilita.', 'Attenzione', 1, 400, 300);
        return -1;
      }

      if (Number(getObjValue('importoBaseAsta')) > Number(getObjValue('Importo_Warning_forniture'))) {
        if (confirm(CNV('../../', 'Attenzione Importo Appalto maggiore della soglia di Warning stabilita. Sei sicuro?')) == false) {
          return -1;
        }
      }

    }

    //controllo su importo supera le soglie impostate
    if (getObjValue('TipoAppaltoGara') == '3') //servizi
    {
      if (Number(getObjValue('importoBaseAsta')) > Number(getObjValue('Importo_servizi'))) {
        DMessageBox('../', 'Attenzione Importo Appalto maggiore della soglia stabilita.', 'Attenzione', 1, 400, 300);
        return -1;
      }

      if (Number(getObjValue('importoBaseAsta')) > Number(getObjValue('Importo_Warning_servizi'))) {
        if (confirm(CNV('../../', 'Attenzione Importo Appalto maggiore della soglia di Warning stabilita. Sei sicuro?')) == false) {
          return -1;
        }
      }
    }
  }
  

  ExecDocProcess('SAVE,NUOVO_TEMPLATE_GARA');
}

function OnChangeTipoAppalto(obj) {
  var TipoAppaltoGara = getObjValue('TipoAppaltoGara');
  if (
    (getObjValue('TipoSceltaContraente') != 'ACCORDOQUADRO' && getObjValue('TipoSceltaContraente') != 'ACCORDOQUADRO_RUPAR' && getObjValue('TipoSceltaContraente') != 'AQ_STRU_INFORMATICA')
    &&
    (TipoAppaltoGara == '2' || TipoAppaltoGara == '3') //-- mostriamola scelta per indicare se la gara ? di tipo concessione per Lavori e Servizi
  ) {
    //-- mostra
    setVisibility(getObj('cap_Concessione'), '');
    setVisibility(getObj('Concessione'), '');
  }
  else {
    //-- nascondi
    getObj('Concessione').value = 'no';
    OnChangeConcessione(obj);
    setVisibility(getObj('cap_Concessione'), 'none');
    setVisibility(getObj('Concessione'), 'none');
  }
}

function OnChangeConcessione(obj) {
  var PG = getObjValue('ProceduraGara');

  //-- l'attivazione delle concessioni limita il Tipo procedurea ad Aperta e Ristretta
  var ColNotEditable = getObjValue('NotEditable');

  //se la colonna ProceduraGara è editabile allora faccio il filtro
  if (ColNotEditable.indexOf(' ProceduraGara ') < 0) {
    if (getObjValue('Concessione') == 'si') {
      FilterDom('ProceduraGara', 'ProceduraGara', PG, 'SQL_WHERE=  tdrcodice not in ( \'15585\' )', '', 'OnChangeProcedura(this)', 'DT');
    }
    else {
      FilterDom('ProceduraGara', 'ProceduraGara', PG, 'SQL_WHERE=  tdrcodice not in ( \'15585\' )', '', 'OnChangeProcedura(this)', 'DT');
    }

    if (PG != '')
      OnChangeProcedura(obj);
  }
}
