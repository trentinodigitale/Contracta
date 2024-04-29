window.onload = OnLoadPage; 

function OnLoadPage()
{
    var crit = '';
    var conf = '';
	var PUNTEGGI_ORIGINALI = '';
	var PunteggioECO_TipoRip = '';
	var num_criteri_eco='';
	
	
    
	try{ crit = getObjValue( 'val_CriterioAggiudicazioneGara' ); }catch(e){ crit = ''; };
    try{ conf = getObjValue( 'Conformita' ); }catch(e){ conf = ''; };
	try{ concessione = getObjValue( 'Concessione' ); }catch(e){ concessione = ''; };
	try{ num_criteri_eco = getObjValue( 'num_criteri_eco' ); }catch(e){ num_criteri_eco = ''; };
	try{ ValutazioneSoggettiva = getObjValue( 'ValutazioneSoggettiva' ); }catch(e){ ValutazioneSoggettiva = ''; };
	
	
	try{ PUNTEGGI_ORIGINALI = getObjValue( 'PUNTEGGI_ORIGINALI' ); }catch(e){ PUNTEGGI_ORIGINALI = ''; };
	try{ PunteggioECO_TipoRip = getObjValue( 'PunteggioECO_TipoRip' ); }catch(e){ PunteggioECO_TipoRip = ''; };
    
    //-- se è privista la conformita Ex-Ante oppure è economicamente più vantaggiosa oppure COSTO FISSO si devono aprire i singoli lotti
    if( conf != 'Ex-Ante' && crit != '15532' &&  crit != '25532' )
    {   
        ShowCol( 'LISTA_BUSTE' , 'bRead' , 'none' );
    }
    
    //--se è al prezzo nasconodo colonne punteggio
    //alert ( crit );
    if ( crit == '15531' )
	{
		//ShowCol( 'LISTA_BUSTE' , 'ValoreOfferta' , 'none' );
		ShowCol( 'LISTA_BUSTE' , 'PunteggioTecnico' , 'none' );
		ShowCol( 'LISTA_BUSTE' , 'PunteggioEconomico' , 'none' );
		
		
		//--se è al prezzo ed ho un solo criterio economico e non si è scelta una valutazione soggettiva nasconodo anche la colonna del punteggio e Scheda Valutazione
		if (num_criteri_eco == '1' && ValutazioneSoggettiva == '0')
		{
			ShowCol( 'LISTA_BUSTE' , 'FNZ_CONTROLLI' , 'none' );
			ShowCol( 'LISTA_BUSTE' , 'ValoreOfferta' , 'none' );
		}
		
		
    }
    
	//se è al costo fisso nascondo  le colonne scheda valutazione,punteggio tecnico,punteggio economico
	if ( crit == '25532' )
	{
		ShowCol( 'LISTA_BUSTE' , 'FNZ_CONTROLLI' , 'none' );
		ShowCol( 'LISTA_BUSTE' , 'PunteggioTecnico' , 'none' );
		ShowCol( 'LISTA_BUSTE' , 'PunteggioEconomico' , 'none' );
		ShowCol( 'LISTA_BUSTE' , 'ValoreImportoLotto' , 'none' );
		ShowCol( 'LISTA_BUSTE' , 'ValoreSconto' , 'none' );
		
		ShowCol( 'LISTA_BUSTE' , 'PunteggioEconomicoAssegnato' , 'none' );
	
	}
    
	 //-- al prezzo più alto
    if ( crit == '16291' )
	{													  
		ShowCol( 'LISTA_BUSTE' , 'PunteggioTecnico' , 'none' );
		ShowCol( 'LISTA_BUSTE' , 'PunteggioEconomico' , 'none' );
		ShowCol( 'LISTA_BUSTE' , 'ValoreImportoLotto' , 'none' );	
		
		//se un solo criterio nascondiamo il punteggio altrimenti nascondo la percentuale
		if ( num_criteri_eco == '1' && getObjValue('val_CriterioFormulazioneOfferte') == '15537' )
		{
			ShowCol( 'LISTA_BUSTE' , 'ValoreOfferta' , 'none' );
		}
		else
		{
			ShowCol( 'LISTA_BUSTE' , 'ValoreSconto' , 'none' );
		}
		
	}
	
	if ( concessione == 'si' )
	{
		ShowCol( 'LISTA_BUSTE' , 'ValoreImportoLotto' , 'none' );	
		
	}
	
	//SE PERCENTUALE MOSTRA LA COLONNA VALORESCONTO 
	if (getObjValue('val_CriterioFormulazioneOfferte') == '15537')
	{
		ShowCol( 'LISTA_BUSTE' , 'ValoreImportoLotto' , 'none' ); 	
	}
	else
	{
		ShowCol( 'LISTA_BUSTE' , 'ValoreSconto' , 'none' ); 	
	}
	
	//SE NON CI STA LA RIPAREMETRAZIONE ECONOMICA OPPURE SE LA PROPRIETA' NON RICHIEDE LA VISUALIZZAZIONE DEI PUNTEGGI ORIGINALI NASCONDO LA COLONNA
	if ( PunteggioECO_TipoRip == '' || PunteggioECO_TipoRip == 'No' )
		ShowCol( 'LISTA_BUSTE' , 'PunteggioEconomicoAssegnato' , 'none' );  
	else if  ( PUNTEGGI_ORIGINALI != 'YES' )
		ShowCol( 'LISTA_BUSTE' , 'PunteggioEconomicoAssegnato' , 'none' );  

    //cambio caption attributo CriterioAggiudicazioneGara in funzione se ACCORDOQUADRO
  	var ValTipoSceltaContraente = '';
      
    try
	{ 
      ValTipoSceltaContraente = getObjValue( 'TipoSceltaContraente' ); 
    }
	catch(e)
	{ 
		ValTipoSceltaContraente = ''; 
	}
      
    //alert(ValTipoSceltaContraente);
      
    if( ValTipoSceltaContraente == 'ACCORDOQUADRO' )
	{
      getObj('cap_CriterioAggiudicazioneGara').innerHTML =  CNV( '../../','Criterio Valutazione');
    }

	//Nel caso in cui per il lotto la valutazione è al prezzo e NON è economicamente vantaggiosa E NON COSTO FISSO si nasconde la colonna per la valutazione
	/*
	if ( getObjValue('val_CriterioAggiudicazioneGara') != '15532' && getObjValue('val_CriterioAggiudicazioneGara') != '25532' )
	{
		ShowCol( 'LISTA_BUSTE' , 'FNZ_CONTROLLI' , 'none' );
	}
	*/
	
    
	if ( getObj('TipoAggiudicazione') )
	{
		var TipoAggiudicazione = getObjValue('TipoAggiudicazione');
		
		if ( TipoAggiudicazione != 'multifornitore' )
		{
			ShowCol( 'LISTA_BUSTE' , 'PercAgg' , 'none' );
		}
		
	}

	//-- cerco di ripristinare una selezione precedente
	try{
		if ( getCookie('PDA_MICROLOTTI_IDDOC_ECO') == getObj( 'IDDOC' ).value )
		{
			var Sel = document.getElementsByName('Selezione');//getObj( 'Selezione');
			var idx = getCookie('PDA_MICROLOTTI_SELEZIONE_ECO');
			Sel[idx].checked = true;


			}
		
	}catch(e){}
	
	//-- associo la funzione di onchange per conservare la selezione del radio button
	$('input[type="radio"]').on('change',OnChangeSelezione );	
	
	var AttivaFilePending = getObj('AttivaFilePending');
	
	/* SE IL CAMPO ESISTE */
	if ( AttivaFilePending )
	{
		//Se non è richiesta la verifica pending dei file nascondiamo la colonna statoFirma
		if (AttivaFilePending.value != 'si' )
		{
			try
			{
				ShowCol('LISTA_BUSTE', 'Stato_Firma_PDA_AMM', 'none');
			}
			catch(e){}
		}
	}
	
	
}


function StoreSelection()
{
	try{
		var Selezione = document.getElementsByName('Selezione');
		
		//-- recupera la riga selezionata
		//var indRow = getCheckedValueRow( Selezione ); 	
		var indRow = getIdRowChecked( Selezione ); 	
		
		//-- la memorizzo nel cooky
		setCookie2('PDA_MICROLOTTI_IDDOC_ECO', getObj( 'IDDOC' ).value  );
		setCookie2('PDA_MICROLOTTI_SELEZIONE_ECO', indRow );
		
	}catch(e){}
}

function OnChangeSelezione ( e ) 
{
	if ( e.type == 'change' && ( e.target.id == 'Selezione' || e.target.id == 'Selezione2' ) )
		StoreSelection();
	else 
		return false;	
}

function getIdRowChecked(radioObj) 
{
	if(!radioObj)
		return "";
	var radioLength = radioObj.length;
	if(radioLength == undefined)
		return -1;
	for(var i = 0; i < radioLength; i++) {
		if(radioObj[i].checked) {
			return i;
		}
	}
	return -1;
}



function OpenBustaEco( objGrid , Row , c )
{

	//-- mette la spunta sulla riga dell'offerta che si sta aprendo
    try
    {
		var Sel = document.getElementsByName('Selezione');
		Sel[Row].checked = true;
		StoreSelection();
    }catch(e){};		


    var crit = '';
    var conf = '';
    try{ crit = getObjValue( 'val_CriterioAggiudicazioneGara' ); }catch(e){ crit = ''; };
    try{ conf = getObjValue( 'Conformita' ); }catch(e){ conf = ''; };
    
    var Divisione_lotti = getObjValue( 'Divisione_lotti' );
    
    //-- se è privista la conformita Ex-Ante oppure è economicamente più vantaggiosa si devono aprire i singoli lotti
    //if( conf == 'Ex-Ante' || crit == '15532' )
    if ( Divisione_lotti != '0' )
    {
        var TipoDoc =  'OFFERTA_BUSTA_ECO'
        ShowDocumentFromAttrib( TipoDoc + ',' +  'R' + Row  + '_idHeaderLotto' );
    }    
    else
    {

        var idMsg =  getObjValue( 'R' + Row  + '_idMsg' );
        var TipoDoc =  getObjValue( 'R' + Row  + '_OPEN_DOC_NAME' );
        
        if( TipoDoc == '' )
            OpenAnyDoc( idMsg , '' , '../' );
        else 
            ShowDocumentFromAttrib( TipoDoc + ',' +  'R' + Row  + '_idMsg' );
            
    }        

}


function OpenBustaTec( objGrid , Row , c )
{


    var TipoDoc =  'OFFERTA_BUSTA_TEC'
    ShowDocumentFromAttrib( TipoDoc + ',' +  'R' + Row  + '_idHeaderLotto' );
        

}





function OpenScheda( objGrid , Row , c )
{
    MakeDocFrom( 'PDA_VALUTA_LOTTO_TEC#800,800#LOTTO#' + getObjValue( 'R' + Row  + '_idRow' ) );
}

function OpenSchedaEco( objGrid , Row , c )
{
    MakeDocFrom( 'PDA_VALUTA_LOTTO_ECO#800,800#LOTTO#' + getObjValue( 'LISTA_BUSTEGrid_idRow_' + Row  ) );
}


function TESTATA_OnLoad()
{
    var val_StatoRiga = document.location.toString();
    
    if (val_StatoRiga.indexOf( 'CHIUDI_VAL_ECO_LOTTO' ) > -1  )
    {
    
        opener.ExecDocCommand( 'RIEPILOGO_FINALE#Reload' );
    }
    
}




function CreaAsta(param){

   var idRow;
   var vet;
   var altro;
   var strUrl;	
		
   //debugger;
   vet = param.split( '#' );

   var w;
   var h;
   var Left;
   var Top;
    
    if( vet.length < 3  )
    {
		w = screen.availWidth;
		h = screen.availHeight;
		Left=0;
		Top=0;
     }
     else    
    {
		var d;
		d = vet[2].split( ',' );
		w = d[0];
		h = d[1];
		Left = (screen.availWidth-w)/2;
		Top  = (screen.availHeight-h)/2;
		
		if( vet.length > 3 )
		{
			altro = vet[3];
		}
      }
  
	
   var IDDOC = getObj( 'IDDOC' ).value;
	
   //-- articoli
   strSql='select id as IDDOC,Descrizione as DescrAttach from Document_MicroLotti_Dettagli d where d.id = ' + IDDOC ;
	 
	 //recupero  ctriterioformulazione per decidere il modello ribasso/rialzo
	 //alert(getObjValue('val_CriterioFormulazioneOfferte'));
	 
	 //imposto il modello al RIALZO
   var modProdotti = '4872';
	 
	 //se criterio=prezzo allora RIBASSO
	 if (getObjValue('val_CriterioFormulazioneOfferte') == '15536')
	   modProdotti = '4561';
	   
   var ParamProdotti = '78;' + modProdotti + ';3;0;ECONOMICA;SHOW;';
   var ParamDestinatari = '78;4471;1;CompanyDes';
   
   strUrl='../../dashboard/NewGenDoc.asp?FieldForNameDoc=NumeroLotto;per Lotto n.&SQLTESTATA=exec MAKE_ASTA_FROM_LOTTO ' + IDDOC + '&SQLDESTINATARI=exec MAKE_ASTA_FROM_LOTTO_AZI_DEST ' + IDDOC + '&SQLPRODOTTI=' + strSql + '&PARAM=' + ParamProdotti + '&PARAM_DESTINATARI=' + ParamDestinatari ;
   
  
   ExecFunction(  strUrl , 'NEWGENDOC' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );

}



function DrillMotivazioni( objGrid , Row , c )
{
    
    var idRow = getObjValue( 'R' + Row +  '_IdOffertaLotto' );
    
    var w;
    var h;
    var Left;
    var Top;
    var altro;

    w = screen.availWidth * 0.5;
    h = screen.availHeight  * 0.4;
    Left= (screen.availWidth - w) / 2;
    Top= (screen.availHeight - h ) / 2;

    //alert(idRow);
    //apro la lista  delle motivazioni
    var strURL='Viewer.asp?lo=base&ModGriglia=PDA_LISTA_MOTIVAZIONE_ESITIGriglia&TOOLBAR=PDA_LISTA_MOTIVAZIONE_ESITI_TOOLBAR&Table=PDA_LISTA_AZIONI_LOTTO&JSCRIPT=&IDENTITY=Id&DOCUMENT=DECADENZA&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=Lista documenti&Height=0,100*,0&numRowForPag=20&Sort=DataInvio&SortOrder=desc&Exit=si&FilterHide=LinkedDoc=' + idRow  ;
    //ExecFunction(  strURL , 'ListaEsito'  , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
    OpenViewer( strURL );
  
}

/*function RefreshContent()
{
	opener.RefreshContent();
    RefreshDocument('');
}
*/
function RefreshContent()
{
		
	if ( singleWin != 'YES' )
	{	
		if ( opener != null )
			opener.RefreshContent();
	}	
	
	//RefreshDocument( pathRoot + 'application/ctl_library/document/');
	RefreshDocument(urlPortale + '/ctl_library/document/');
}


function Esito( stato )
{
	var crit;
    try{ crit = getObjValue( 'val_CriterioAggiudicazioneGara' ); }catch(e){ crit = ''; };

	if(( stato != 'ScioltaRiserva' && getObjValue( 'StatoRiga' ) != 'Valutato' && getObjValue( 'StatoRiga' ) != 'Completo'    ) )
	{
		
        alert(  CNV( '../../' ,  'Il cambiamento richiesto non e\' coerente con lo stato del documento' ));
        return; 
	}


    var Selezione = document.getElementsByName('Selezione');
    
    //-- recupera la riga selezionata
    var indRow = getCheckedValue( Selezione );   
    if( indRow  == '' ) 
    {
        alert(  CNV( '../../' ,  'E\' necessario selezionare prima una riga' ));
        return; 
    }
    
	
    //-- verifica se lo stato richiesto è ammissibile
    var StatoPDA = getObjValue( 'val_R' + indRow +  '_StatoRiga' );
    var idRow = getObjValue( 'R' + indRow +  '_id' );
    
    //-- se viene richiesta l'esclusione lo stato di partenza puo essere:in verifica o davalutare
    if( stato == 'escluso' && ( StatoPDA == 'Valutato' || StatoPDA == 'inVerificaEco' || StatoPDA == 'Conforme'  ) )
    {
        DOC_NewDocumentFrom( 'ESITO_ECO_LOTTO_ESCLUSA#LOTTO,' + idRow + '#800,600##&UpdateParentX=no' );
        return;
    }

    //-- se viene richiesta la verifica lo stato di partenza puo essere:daValutare
    if( stato == 'inVerifica' && ( StatoPDA == 'Valutato'   ) )
    {
        DOC_NewDocumentFrom( 'ESITO_ECO_LOTTO_VERIFICA#LOTTO,' + idRow + '#800,600##&UpdateParentX=no' );
        return;
    }
  

    //-- se viene richiesta l'annullamento lo stato di partenza non puo essere da valutare
    if( stato == 'annulla' && ( StatoPDA != 'Valutato'   ) )
    {
        DOC_NewDocumentFrom( 'ESITO_ECO_LOTTO_ANNULLA#LOTTO,' + idRow + '#800,600##&UpdateParentX=no' );
        return;
    }

     //-- se viene richiesta l'ammissione / conformità lo stato puo essere : daValutare o in verifica
    if( stato == 'VerificaSuperata' && (  StatoPDA == 'inVerificaEco' ) )
    {
    
        DOC_NewDocumentFrom( 'ESITO_ECO_LOTTO_AMMESSA#LOTTO,' + idRow + '#800,600##&UpdateParentX=no' );
        return;
    }

	if( stato == 'ScioltaRiserva' && ( StatoPDA != 'esclusoEco'   ) )
    {
		//var idHeaderLotto = getObjValue( 'R' + indRow +  '_idHeaderLotto' );
		//alert(idRow);
		MakeDocFrom( 'ESITO_LOTTO_SCIOGLI_RISERVA#800,800#LOTTO#' + idRow );
        return;
	}
 
    alert(  CNV( '../../' ,  'Il cambiamento richiesto non e\' coerente con lo stato del documento' ));
	
}


function EsitoVerificaAnomalia( param )
{
	   
	var Selezione = document.getElementsByName('Selezione');
    
  //-- recupera la riga selezionata
  var indRow = getCheckedValue( Selezione );   
  if( indRow  == '' ) 
  {
      alert(  CNV( '../../' ,  'E\' necessario selezionare prima una riga' ));
      return; 
  }
  
  var StatoOfferta = getObjValue( 'val_R' + indRow +  '_StatoRiga' );
  var idRow = getObjValue( 'R' + indRow +  '_id' );
  
  if(   StatoOfferta == 'SospettoAnomalo'  )
  {
    DOC_NewDocumentFrom( 'ESITO_LOTTO_ANOMALIA_OFFERTA#PDA_RIEPILOGO_LOTTO_ROW,' + idRow + '#800,600##&UpdateParentX=no' );
    return;
  }
  
  alert(  CNV( '../../' ,  'EsitoVerificaAnomalia non e\' coerente con lo stato del documento' ));
  
}

//utilizzata in caso di ACCORDO QUADRO
function Decadenza( param )
{
	   
	var Selezione = document.getElementsByName('Selezione');
    
  //-- recupera la riga selezionata
  var indRow = getCheckedValue( Selezione );   
  if( indRow  == '' ) 
  {
      alert(  CNV( '../../' ,  'E\' necessario selezionare prima una riga' ));
      return; 
  }
  
  var StatoOfferta = getObjValue( 'val_R' + indRow +  '_Posizione' );
  var idRow = getObjValue( 'R' + indRow +  '_id' );
  
  //alert(idRow);
  
  if(   StatoOfferta == 'Idoneo provvisorio' || StatoOfferta == 'Idoneo definitivo' )
  {
    DOC_NewDocumentFrom( 'DECADENZA#PDA_RIEPILOGO_LOTTO_ROW,' + idRow + '#800,600##&UpdateParentX=no' );
    return;
  }
  
  alert(  CNV( '../../' ,  'Decadenza non e\' coerente con lo stato del documento' ));
  
}

//utilizzata in caso di ACCORDO QUADRO
function RettificaValore( param )
{
	   
	var Selezione = document.getElementsByName('Selezione');
    
  //-- recupera la riga selezionata
  var indRow = getCheckedValue( Selezione );   
  if( indRow  == '' ) 
  {
      alert(  CNV( '../../' ,  'E\' necessario selezionare prima una riga' ));
      return; 
  }
  
  var StatoOfferta = getObjValue( 'val_R' + indRow +  '_StatoRiga' );
  var idRow = getObjValue( 'R' + indRow +  '_id' );
  
  //alert(idRow);
  
  if(   StatoOfferta != 'escluso' && StatoOfferta != 'esclusoEco' ) //non deve essere ne escluso ne esclusoeco
  {
    DOC_NewDocumentFrom( 'RETT_VALORE_LOTTO_AGG#PDA_RIEPILOGO_LOTTO_ROW,' + idRow + '#800,600##&UpdateParentX=no' );
    return;
  }
  
  alert(  CNV( '../../' ,  'rettifica valore non e\' coerente con lo stato del documento' ));
  
}


//utilizzata in caso di ACCORDO QUADRO
function RettificaValoreEconomico( param )
{
	   
	var Selezione = document.getElementsByName('Selezione');
    
  //-- recupera la riga selezionata
  var indRow = getCheckedValue( Selezione );   
  if( indRow  == '' ) 
  {
      alert(  CNV( '../../' ,  'E\' necessario selezionare prima una riga' ));
      return; 
  }
  
  //controllo che la busta economica è stata aperta
  //val_R0_bReadEconomica_extraAttrib
  var BustaEcoLetta = getObjValue( 'val_R' + indRow +  '_bReadEconomica' );
  
  if ( BustaEcoLetta == '1'){
    alert(  CNV( '../../' ,  'busta economica non ancora letta' ));
    return;
  }
  
  var StatoOfferta = getObjValue( 'val_R' + indRow +  '_StatoRiga' );
  var idRow = getObjValue( 'R' + indRow +  '_id' );
  
  //alert(idRow);
  
  if(   StatoOfferta != 'escluso' && StatoOfferta != 'esclusoEco' ) //non deve essere ne escluso ne esclusoeco
  {
    //DOC_NewDocumentFrom( 'RETT_VALORE_LOTTO_AGG#PDA_RIEPILOGO_LOTTO_ROW,' + idRow + '#800,600##&UpdateParentX=no' );
    MakeDocFrom( 'RETT_VALORE_ECONOMICO#800,800#PDA_RIEPILOGO_LOTTO_ROW#' + idRow );
    return;
  }
  
  alert(  CNV( '../../' ,  'rettifica valore non e\' coerente con lo stato del documento' ));
  
}

function getCheckedValue(radioObj) {
	if(!radioObj)
		return "";
	var radioLength = radioObj.length;
	if(radioLength == undefined)
		if(radioObj.checked)
			return radioObj.value;
		else
			return "";
	for(var i = 0; i < radioLength; i++) {
		if(radioObj[i].checked) {
			return radioObj[i].value;
		}
	}
	return "";
}

function OpenOfferta( idOfferta )
{
    
	ExecDocCommand( 'LISTA_BUSTE#Reload' );

	
    
}

 function LISTA_BUSTE_AFTER_COMMAND( param )
{
   OnLoadPage();
}



function My_Dash_ExecProcessDoc( param , ID_Griglia)
{
		
	var w;
	var h;
	var Left;
	var Top;
	var parametri;

	w = 800;
	h = 600;	
	Left = (screen.availWidth-w)/2;
	Top  = (screen.availHeight-h)/2;	
		
	
	parametri='CONTESTO=' + getObj( 'TYPEDOC' ).value  + '&IDDOC=' + getObj('IDDOC').value + '&PROCESS_PARAM=' + encodeURIComponent(param);
	
	ExecFunction(  pathRoot + 'customDoc/Apri_Buste_Offerte.asp?' + parametri,  '_blank',  ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h );
	
	
}

/*

function My_Dash_ExecProcessDoc( param , ID_Griglia){
	
	//Dash_ExecProcessDoc( param , 'OFFERTE');
	//-- determino che riga selezionare
	//ID_Griglia = 'OFFERTEGrid';
	ID_Griglia = ID_Griglia + 'Grid';
	
	var i;
	var result = '';
	var NumRow = eval( ID_Griglia + '_EndRow;' );
	var nStartRow=eval( ID_Griglia + '_StartRow;' );
	var strDoc = '';
	var StatoPDA;
	
    for( i = nStartRow ; i <= NumRow ; i++ )
    {
		
		//busta Riepilogo Finale Lotto
		if (ID_Griglia == 'LISTA_BUSTEGrid' ) 
		{	
			
			
			try{ StatoLOTTO = getObjValue( 'val_R' + ( i ) + '_StatoRiga' ); } catch(e){ break;}
			bReadEconomica = '';
			bReadEconomica = getObjValue( 'val_R' + ( i ) + '_bReadEconomica' );
			//alert(bReadDocumentazione);
			if (  ( StatoLOTTO == 'Valutato' ||  StatoLOTTO == 'Completo'  )  && bReadEconomica == '1' )
			{
			
				strDoc = getObj( ID_Griglia + '_idRow_' + i ).value; //OFFERTEGrid_idRow_0	
			
				if ( result != '' ) 
					result = result +  '~~~';

				result = result + strDoc;
				
			}
		}
		
		
			
    }
	//alert(result);
	if (result == '')
	{
		alert( CNV( '../../' , 'Non ci sono buste da aprire' ));
		return;
	}	
			
	
	parent.ExcelDocument.location =  '../../dashboard/ViewerCommand.asp?IDLISTA=' + result +'&PROCESS_PARAM=' + param ;
	
	
}*/


function EsportaRiepilogo(param)
{
	
	
	var strHideCol='';
	var CriterioAggiudicazioneGara; 
	var num_criteri_eco='';	
	
	try{ num_criteri_eco = getObjValue( 'num_criteri_eco' ); }catch(e){ num_criteri_eco = ''; };
	
	try{ CriterioAggiudicazioneGara = getObjValue( 'val_CriterioAggiudicazioneGara' ); }catch(e){ crit = ''; };
	
	try{ ValutazioneSoggettiva = getObjValue( 'ValutazioneSoggettiva' ); }catch(e){ ValutazioneSoggettiva = ''; };
	 

    //se è al costo fisso nascondo  le colonne scheda valutazione,punteggio tecnico,punteggio economico
	if ( CriterioAggiudicazioneGara == '25532' )
	{
		//ShowCol( 'OFFERTE_ECO' , 'ValoreImportoLotto' , 'none' );
		//ShowCol( 'OFFERTE_ECO' , 'PunteggioEconomicoAssegnato' , 'none' );        
		strHideCol =  'ValoreSconto,ValoreImportoLotto,PunteggioEconomicoAssegnato'

	}
	
    //-- al prezzo più alto
    if ( CriterioAggiudicazioneGara == '16291' )
	{
		strHideCol =  'ValoreImportoLotto,PercentualeRibasso,Ribasso'
		
		//se un solo criterio nascondiamo il punteggio altrimenti nascondo la percentuale
		if ( num_criteri_eco == '1' && getObjValue('val_CriterioFormulazioneOfferte') == '15537' )
		{
			
			strHideCol =  'ValoreOfferta,ValoreImportoLotto,PercentualeRibasso,Ribasso'
		}
		else
		{
			
			strHideCol =  'ValoreSconto,ValoreImportoLotto,PercentualeRibasso,Ribasso'
		}
		
	}
	if ( CriterioAggiudicazioneGara == '15531' )
    {		
	  
	  //--se è al prezzo ed ho un solo criterio economico e non si è scelta una valutazione soggettiva nasconodo anche la colonna del punteggio e Scheda Valutazione
		if (num_criteri_eco == '1' && ValutazioneSoggettiva == '0')
		{
			strHideCol =  'ValoreOfferta'
		}
		
		//-- al prezzo più basso nasconde la colonna  Ribasso %    
		if (strHideCol != '')
			strHideCol = strHideCol + ',PercentualeRibasso'		
	}
	
	
	try{ var concessione = getObjValue( 'Concessione' ); }catch(e){ concessione = ''; };
	
	if ( concessione == 'si' )
	{
		if (strHideCol != '')
			strHideCol = strHideCol + ','
		
		strHideCol = strHideCol + 'ValoreImportoLotto';
		
	}
	
	//SE PERCENTUALE MOSTRA LA COLONNA VALORESCONTO 
	if (getObjValue('val_CriterioFormulazioneOfferte') == '15537')
	{
		if (strHideCol != '')
			strHideCol = strHideCol + ','
		
		strHideCol = strHideCol + 'ValoreImportoLotto';
	}
	else
	{
		if (strHideCol != '')
			strHideCol = strHideCol + ','
		
		strHideCol = strHideCol + 'ValoreSconto';
	}

	
	
	param = param + '&HIDECOL=' + strHideCol ;
	
	//alert(param);
	
	ExecDownloadSelf(param);
}

