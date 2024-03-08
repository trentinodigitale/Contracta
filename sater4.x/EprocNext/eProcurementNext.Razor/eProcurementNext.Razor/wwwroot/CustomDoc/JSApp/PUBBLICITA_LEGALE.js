window.onload = ON_LOAD_DOCUMENT;

var DOCUMENT_READONLY='';

function ON_LOAD_DOCUMENT()
{
	
	DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	filtraRup();
/*
	CheckCreaBando();
	
	//-- Caption del campo allegato in funzione della fase
	SetCaptionAllegato();
	

	HideDocumentazione();*/
	if( ( getObjValue( 'JumpCheck' ) == 'GURI' ) )
	{
		ShowField('NumQuotNaz',false);
		ShowField('NumQuotReg',false);
		
	}
	
	
	if( ( getObjValue( 'JumpCheck' ) == 'QUOTIDIANI' ) )
	{
		ShowField('MandatoPagDett',false);	
	}
	filtraCodici();
	hide_lente_operazioni_effettuate();
	Change_Allega_file();
}

function HideDocumentazione()
{
	if( getObj( 'DOCUMENTAZIONEGrid_Descrizione' ).classList.contains('display_none') )
	{
		
		try{$("#DOCUMENTAZIONE").css({"display": "none"});}catch(e){}
		
	}
}


function CheckCreaBando()
{

	DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
    
	//SE LA SEZIONE NON E' EDITABLE NON CHIAMO LA FUNZIONE
	if (DOCUMENT_READONLY == '0' && (  getObjValue('StatoFunzionale') == 'InLavorazione' || getObjValue('StatoFunzionale') == 'AnalisiStrategiaNonApp' ) ) 
	{		
		//-- setta il filtro per il tipobandogara
		OnChangeProcedura(this);
	}
	
	OnChangeLotti(this);
	
	

	//-- regola la visualizzazione  del campo "Concessione"	
	try{OnChangeTipoAppalto( this );} catch (e) {}     
	
	mostra_punteggio();
	
	
	filtraRup();
	filtraRupEspletante();
	
	if ( DOCUMENT_READONLY == '0' )
	{
		hide_cestino_atti();
		hide_cestino_determina();
	}
	
	Change_Allega_file_ATTI();
	Change_Allega_file_DETERMINA();
	
	hide_lente_operazioni_effettuate();
    
}










function filtraCodici()
{
	if (DOCUMENT_READONLY == '0' )
	{
		var filter=''
		var editable='no';
		var DomCodiceIPA=getObjValue('DomCodiceIPA');	
	
		if( getObj('DomCodiceIPA').type == 'select-one' )
		{
			
			filter =  'SQL_WHERE = DMV_Cod in (Select DMV_Father from DOMAIN_CODICI_IPA  where   DMV_Father =' + EnteProponente + ' )';

			FilterDom( 'DomCodiceIPA' , 'DomCodiceIPA' , getExtraAttrib('val_DomCodiceIPA' , 'value' ) , filter ,'', '','TCD','','yes');
			
		}
	}
	
}






function onchangeEnteProponente ()
{
	filtraRup();
}




function filtraRup()
{
	if (DOCUMENT_READONLY == '0' )
	{
		var filter=''
		var editable='no';
		var EnteProponente=getObjValue('EnteProponente').split('#')[0];	
		/*
		if (  getObjValue('StatoFunzionale') == 'InLavorazione' || getObjValue('StatoFunzionale') == 'AnalisiStrategiaNonApp' || getObjValue('StatoFunzionale') == 'AnalisiStrategia' ) 
		{
			editable='yes';
		}
		
		
		if ( EnteProponente == '' ) 
		{
			SelectreadOnly( 'RupProponente' , true );
		}
		else
			*/
		//-- se il campo per selezionare è editabile lo filtriamo con gli utenti dell'ente
		if( getObj('RupProponente').type == 'select-one' )
		{
			
			filter =  'SQL_WHERE= dmv_cod in (Select DMV_COD from ELENCO_RESPONSABILI_AZI  where RUOLO in (\'RUP\',\'RUP_PDG\') and idpfu = (select top 1 idpfu from ProfiliUtente where pfuIdAzi=' + EnteProponente + ') )';

			FilterDom( 'RupProponente' , 'RupProponente' , getExtraAttrib('val_RupProponente' , 'value' ) , filter ,'', 'onChangeRUPProp()','','','yes');
			
		}
	}
	
}

function filtraRupEspletante()
{
	if (DOCUMENT_READONLY == '0' )
	{
		//-- se il campo per selezionare è editabile lo filtriamo con gli utenti dell'ente
		if( getObj('UserRUP').type == 'select-one' )
		{
			
			filter =  'SQL_WHERE= dmv_cod in (Select DMV_COD from ELENCO_RESPONSABILI_AZI  where RUOLO in (\'RUP\',\'RUP_PDG\') and idpfu =  ' + idpfuUtenteCollegato + ' )';
			FilterDom( 'UserRUP' , 'UserRUP' , getExtraAttrib('val_UserRUP' , 'value' ) , filter ,'', '','','','yes');
			
		}
	}
	
}


function mostra_punteggio()
{
	//return;
	if( ( getObjValue( 'CriterioAggiudicazioneGara' ) == '15532' ) )
	{
		$( "#cap_PunteggioTecnico" ).parents("table:first").css({"display":""});
		$( "#cap_PunteggioEconomico" ).parents("table:first").css({"display":""});
		$( "#PunteggioTecnico_V" ).parents("td:first").css({"display":""});
		$( "#PunteggioEconomico_V" ).parents("td:first").css({"display":""});	
		$( "#Cell_PunteggioTecnico" ).parents("table:first").css({"display":""});
		$( "#Cell_PunteggioEconomico" ).parents("table:first").css({"display":""});
	}
	else
	{
	  
		try{SetNumericValue('PunteggioEconomico', 0);} catch (e) {}     
		try{SetNumericValue('PunteggioTecnico', 0);} catch (e) {}     
		$( "#cap_PunteggioTecnico" ).parents("table:first").css({"display":"none"});
		$( "#cap_PunteggioEconomico" ).parents("table:first").css({"display":"none"});
		$( "#PunteggioTecnico_V" ).parents("td:first").css({"display":"none"});
		$( "#PunteggioEconomico_V" ).parents("td:first").css({"display":"none"});		
		$( "#Cell_PunteggioTecnico" ).parents("table:first").css({"display":"none"});
		$( "#Cell_PunteggioEconomico" ).parents("table:first").css({"display":"none"});
	}
}


function OnChangeCriterio( o )
{

  if( ( getObjValue( 'CriterioAggiudicazioneGara' ) == '15532' ) || ( getObjValue( 'CriterioAggiudicazioneGara' ) == '25532' ) ) //-- vantaggiosa or costo fisso

    FilterDom( 'Conformita' ,  'Conformita' , 'No' , 'SQL_WHERE=  DMV_COD = \'No\' ' , '' , ''); //-- solo no
  else
    FilterDom( 'Conformita' ,  'Conformita' , getObjValue( 'Conformita' ) , '' , '' , ''); //-- tutto


  
  
  HideConformita();
  mostra_punteggio();
  
  
}


function OnChangeProcedura( o )
{
 
  if( getObjValue( 'TipoProceduraCaratteristica' ) != 'RDO' ) 
  {
      //alert(getObjValue( 'TipoSceltaContraente' ));
      if( getObjValue( 'TipoSceltaContraente' ) != 'ACCORDOQUADRO' ) {
      
      
        if(  getObjValue( 'ProceduraGara' ) == '15476' || getObjValue( 'ProceduraGara' ) == '15477' || getObjValue( 'ProceduraGara' ) == '' ) //-- Aperta o Ristretta
        {
          
			FilterDom( 'TipoBandoGara' ,  'TipoBandoGara' , '2' , 'SQL_WHERE=  tdrcodice = \'2\' ' , '' , 'OnChangeTipoBando( this )'); //-- solo bando
		  
			FilterDom( 'Divisione_lotti' ,  'Divisione_lotti' , getObjValue( 'Divisione_lotti' ) , '' , '' , 'OnChangeLotti( this );'); //--come inizio
		  
			if( getObjValue( 'Concessione' ) == 'si' )
        		FilterDom( 'CriterioAggiudicazioneGara' ,  'CriterioAggiudicazioneGara' , getObjValue( 'CriterioAggiudicazioneGara' )  , 'SQL_WHERE=DMV_COD <> \'\' ' , '' , 'OnChangeCriterio(this);'); //-- RIMUOVE il filtro
            else
        		FilterDom( 'CriterioAggiudicazioneGara' ,  'CriterioAggiudicazioneGara' ,  getObjValue( 'CriterioAggiudicazioneGara' ) , 'SQL_WHERE=DMV_COD <> \'16291\' ' , '' , 'OnChangeCriterio(this);'); //-- filtro il prezzo più alto
			
			
			
			OnChangeCriterio (); 
        }
		else if ( getObjValue( 'ProceduraGara' ) == '15583' || getObjValue( 'ProceduraGara' ) == '15479' )//-- Affidamento Diretto  o Richiesta Preventivo
		{
			FilterDom( 'TipoBandoGara' ,  'TipoBandoGara' , '3' , 'SQL_WHERE=  tdrcodice = \'3\' ' , '' , 'OnChangeTipoBando( this )'); //-- solo invito
			SelectreadOnly( 'TipoBandoGara' , true );
			
			FilterDom( 'CriterioAggiudicazioneGara' ,  'CriterioAggiudicazioneGara' , '15531' , 'SQL_WHERE=DMV_COD = \'15531\' ' , '' , 'OnChangeCriterio(this);'); //-- SOLO Prezzo più basso
			SelectreadOnly( 'CriterioAggiudicazioneGara' , true );
			
			FilterDom( 'Conformita' ,  'Conformita' , 'No' , 'SQL_WHERE=  DMV_COD = \'No\' ' , '' , ''); //-- solo no
			SelectreadOnly( 'Conformita' , true );
			
			FilterDom( 'Divisione_lotti' ,  'Divisione_lotti' , getObjValue( 'Divisione_lotti' ) , 'SQL_WHERE=  DMV_COD <> \'1\' ' , '' , 'OnChangeLotti( this );'); //--FILTRO   MULTIVOCE
		}
        else
        {
			//FilterDom( 'TipoBandoGara' ,  'TipoBandoGara' , getObjValue( 'TipoBandoGara' ) , 'SQL_WHERE=  tdrcodice = \'3\' ' , ''  , '');
			FilterDom( 'TipoBandoGara' ,  'TipoBandoGara' , getObjValue( 'TipoBandoGara' ) , 'SQL_WHERE=  tdrcodice <> \'2\' ' , ''  , 'OnChangeTipoBando( this )');
			FilterDom( 'CriterioAggiudicazioneGara' ,  'CriterioAggiudicazioneGara' , getObjValue( 'CriterioAggiudicazioneGara' )  , 'SQL_WHERE=DMV_COD <> \'16291\' ' , '' , 'OnChangeCriterio(this);'); //-- filtro il prezzo più alto
			FilterDom( 'Divisione_lotti' ,  'Divisione_lotti' , getObjValue( 'Divisione_lotti' ) , '' , '' , 'OnChangeLotti( this );'); //--come inizio
			//setVisibility(getObj('cap_TipoProceduraCaratteristica'), '');
			//setVisibility(getObj('TipoProceduraCaratteristica'), '');
			
			OnChangeCriterio (); 
		   
        }
      
      }

   
  }
  
  GESTIONE_TipoProceduraCaratteristica();
  
  
}


function  OnChangeTipoBando( obj )
{
	GESTIONE_TipoProceduraCaratteristica();
}


function OnChangeLotti( o )
{
  if( getObjValue( 'Divisione_lotti' ) != '' && getObjValue( 'Divisione_lotti' ) != '0' )
  {
    
    //sul modello della RDO Complex non presente
    try
	{
		try{getObj('Complex').disabled=false;}catch(e){}		
		try{$( "#cap_Complex" ).parents("table:first").css({"display":""});}catch(e){}		
		try{$( "#val_Complex" ).parents("td:first").css({"display":""});}catch(e){}
		try{$( "#Cell_Complex" ).parents("table:first").css({"display":""});}catch(e){}
	  
	}catch(e){}
    
  }
  else
  {
    //sul modello della RDO Complexnon presente
    try
	{
	  try{getObj('Complex').value='0';}catch(e){}		
	  try{getObj('Complex').disabled=true;}catch(e){}		
      try{$( "#cap_Complex" ).parents("table:first").css({"display":"none"});}catch(e){}		
	  try{$( "#val_Complex" ).parents("td:first").css({"display":"none"});}catch(e){}
	  try{$( "#Cell_Complex" ).parents("table:first").css({"display":"none"});}catch(e){}
    }catch(e){}
	
  }
	
	HideConformita();  
  
}
function OnChangeFormulazione( o )
{

}

function HideConformita()
{
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


function ChangeImpAppalto( obj )
{
    var Oneri = Number( getObj( 'Oneri' ).value ) ;
    var importoBaseAsta2 = Number( getObj( 'importoBaseAsta2' ).value ) ;
    var Opzioni = Number( getObj( 'Opzioni' ).value ) ;

    
    SetNumericValue( 'importoBaseAsta' , Oneri + importoBaseAsta2 + Opzioni );

}


function OnChangeModalita( o )
{
    if( getObjValue( 'ModalitadiPartecipazione' ) == '16308' ) //-- Telematica
    {
        //FilterDom( 'Divisione_lotti' ,  'Divisione_lotti' , getObjValue( 'Divisione_lotti' ) , 'SQL_WHERE=  DMV_COD <> \'1\' ' , '' , ''); //-- tutto
        FilterDom( 'Divisione_lotti' ,  'Divisione_lotti' , getObjValue( 'Divisione_lotti' ) , '' , '' , 'OnChangeLotti( this );'); //-- tutto
    }
    else
    {
        FilterDom( 'Divisione_lotti' ,  'Divisione_lotti' , '0' , 'SQL_WHERE=  DMV_COD = \'0\' ' , '' , 'OnChangeLotti( this );'); //-- niente lotti
    }
    
    OnChangeLotti( o );
}



function OnChangeTipoAppalto( obj )
{
    var TipoAppaltoGara = getObjValue( 'TipoAppaltoGara' );
    if (
            (  getObjValue( 'TipoSceltaContraente' ) != 'ACCORDOQUADRO'  && getObjValue( 'TipoSceltaContraente' ) != 'ACCORDOQUADRO_RUPAR'  && getObjValue( 'TipoSceltaContraente' ) != 'AQ_STRU_INFORMATICA' )
            && 
            ( TipoAppaltoGara == '2' || TipoAppaltoGara == '3' ) //-- mostriamola scelta per indicare se la gara è di tipo concessione per LAvori e Servizi
        )
    {
         //-- mostra        
		try{$( "#cap_Concessione" ).parents("table:first").css({"display":""});}catch(e){}		
		try{$( "#val_Concessione" ).parents("td:first").css({"display":""});}catch(e){}
		try{$( "#Cell_Concessione" ).parents("table:first").css({"display":""});}catch(e){}
                 
    }
    else
    {
        //-- nascondi
        getObj('Concessione').value='no';
        if (getObjValue('StatoFunzionale') == 'InLavorazione' || getObjValue('StatoFunzionale') == 'AnalisiStrategiaNonApp' ) 
		{
			OnChangeConcessione( obj );
		}      
        try{$( "#cap_Concessione" ).parents("table:first").css({"display":"none"});}catch(e){}		
		try{$( "#val_Concessione" ).parents("td:first").css({"display":"none"});}catch(e){}
		try{$( "#Cell_Concessione" ).parents("table:first").css({"display":"none"});}catch(e){}
    }
	
	DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
    
	//SE LA SEZIONE NON E' EDITABLE NON CHIAMO LA FUNZIONE
	if ( DOCUMENT_READONLY == '0' ) 
	{
		GESTIONE_TipoProceduraCaratteristica();
	}

}

function OnChangeConcessione( obj )
{

    var PG = getObjValue( 'ProceduraGara' );
	
    //-- l'attivazione delle concessioni limita il Tipo procedurea ad Aperta e Ristretta
	var ColNotEditable = getObjValue( 'NotEditable' );
	
	
	//se la colonna ProceduraGara è editabile allora faccio il filtro
	if ( ColNotEditable.indexOf(' ProceduraGara ') < 0 ) {
	
		if( getObjValue( 'Concessione' ) == 'si' )
		{
			
			FilterDom( 'ProceduraGara' ,  'ProceduraGara' , PG  , 'SQL_WHERE=  tdrcodice in ( select tdrcodice from Filter_User_Tipo_Procedura where idpfu = <ID_USER> ) and tdrcodice in (  \'15476\' , \'15478\'  )' , '',  'OnChangeProcedura(this)' , 'DT'); 
		
		}
		else
		{
			FilterDom( 'ProceduraGara' ,  'ProceduraGara' , PG  , 'SQL_WHERE=  tdrcodice in ( select tdrcodice from Filter_User_Tipo_Procedura where idpfu = <ID_USER> ) and tdrcodice not in ( \'15585\' )' , '' ,  'OnChangeProcedura(this)' , 'DT'); 
		}
	
		if ( PG != '' )
			OnChangeProcedura( obj );
	}
	
}



function hide_cestino_atti()
{
	
    try
	{
        var i = 0;
		
		var documentReadonly = getObj('DOCUMENT_READONLY').value;
		
		//Se non è readonly
		if (documentReadonly !== '1')
		{
			for( i=0; i < ATTIGrid_EndRow+1 ; i++ )
			{
				if( getObjValue( 'RATTIGrid_' + i + '_NotEditable' ).indexOf(' FNZ_DEL ') > -1 )
				{
					getObj( 'ATTIGrid_r' + i + '_c0' ).innerHTML = '&nbsp;';
				}
			}
		}
	}catch(e){}
	


}



function hide_cestino_determina()
{
	
    try
	{
        var i = 0;
		
		var documentReadonly = getObj('DOCUMENT_READONLY').value;
		
		//Se non è readonly
		if (documentReadonly !== '1')
		{
			for( i=0; i < DETERMINAGrid_EndRow+1 ; i++ )
			{
				if( getObjValue( 'RDETERMINAGrid_' + i + '_NotEditable' ).indexOf(' FNZ_DEL ') > -1 )
				{
					getObj( 'DETERMINAGrid_r' + i + '_c0' ).innerHTML = '&nbsp;';
				}
			}
		}
	}catch(e){}
	


}

function ATTI_AFTER_COMMAND ()
{	
	
	Change_Allega_file_ATTI();
	ExecDocProcess( 'FITTIZIO2,DOCUMENT,,NO_MSG');
	
}

function DETERMINA_AFTER_COMMAND ()
{
	
	Change_Allega_file_DETERMINA();
	ExecDocProcess( 'FITTIZIO2,DOCUMENT,,NO_MSG');	
	
}

function Change_Allega_file_ATTI()
{
	
	try
	{	
	
		//SE SIAMO IN COMPILAZIONE ATTI INSERISCO LA FUNZIONE SULLA COLONNA "ALLEGATO" DELLA GRIGLIA PER CALCOLARE HASH DEL FILE CHE INSERISCO	
		if ( getObjValue('StatoFunzionale') == 'CompilazioneAtti' ) 
		{
			numrow = GetProperty( getObj('ATTIGrid') , 'numrow');
			for( i = 0 ; i <= numrow ; i++ )
			{
				getObj('RATTIGrid_' + i + '_F3_SIGN_ATTACH_V_BTN').setAttribute("onclick", "ExecFunctionCenterDoc('../functions/field/uploadattachsigned.asp?TABLE=CTL_DOC_SIGN&NO_REFRESH_PARENT=YES&IDDOC=' + getObjValue('ATTIGrid_idRow_" + i + "') + '&OPERATION=INSERTSIGN&PATH=../../&SAVE_HASH=YES&IDENTITY=IdRow&AREA=F3&AREA_VISUAL=RATTIGrid_" + i + "&DOMAIN=FileExtention&FORMAT=#AllegaFirma#600,400');" );
			}
		}
		
		//SE SIAMO IN FIRMA ATTI INSERISCO LA FUNZIONE SULLA COLONNA "1 FIRMA" DELLA GRIGLIA PER CALCOLARE HASH DEL FILE CHE INSERISCO	
		if ( getObjValue('StatoFunzionale') == 'FirmaAtti' ) 
		{
			numrow = GetProperty( getObj('ATTIGrid') , 'numrow');
			for( i = 0 ; i <= numrow ; i++ )
			{
				getObj('RATTIGrid_' + i + '_F1_SIGN_ATTACH_V_BTN').setAttribute("onclick", "ExecFunctionCenterDoc('../functions/field/uploadattachsigned.asp?TABLE=CTL_DOC_SIGN&NO_REFRESH_PARENT=YES&IDDOC=' + getObjValue('ATTIGrid_idRow_" + i + "') + '&OPERATION=INSERTSIGN&PATH=../../&SAVE_HASH=YES&IDENTITY=IdRow&AREA=F1&AREA_VISUAL=RATTIGrid_" + i + "&FORMAT=&DOMAIN=FileExtention&#AllegaFirma#600,400');" );
			}
		}
		
		//SE SIAMO IN FirmaAttiEDetermina INSERISCO LA FUNZIONE SULLA COLONNA "2 FIRMA" DELLA GRIGLIA PER CALCOLARE HASH DEL FILE CHE INSERISCO	
		if ( getObjValue('StatoFunzionale') == 'FirmaAttiEDetermina' ) 
		{
			numrow = GetProperty( getObj('ATTIGrid') , 'numrow');
			for( i = 0 ; i <= numrow ; i++ )
			{
				getObj('RATTIGrid_' + i + '_F2_SIGN_ATTACH_V_BTN').setAttribute("onclick", "ExecFunctionCenterDoc('../functions/field/uploadattachsigned.asp?TABLE=CTL_DOC_SIGN&NO_REFRESH_PARENT=YES&IDDOC=' + getObjValue('ATTIGrid_idRow_" + i + "') + '&OPERATION=INSERTSIGN&PATH=../../&SAVE_HASH=YES&IDENTITY=IdRow&AREA=F2&AREA_VISUAL=RATTIGrid_" + i + "&DOMAIN=FileExtention&FORMAT=#AllegaFirma#600,400');" );
			}
		}
		
	}catch(e){}
	
}

function Change_Allega_file_DETERMINA()
{
	
	try
	{		
	
		//SE SIAMO IN AllegaDetermina INSERISCO LA FUNZIONE SULLA COLONNA "ALLEGATO" DELLA GRIGLIA PER CALCOLARE HASH DEL FILE CHE INSERISCO	
		if ( getObjValue('StatoFunzionale') == 'AllegaDetermina' ) 
		{
			numrow = GetProperty( getObj('DETERMINAGrid') , 'numrow');
			for( i = 0 ; i <= numrow ; i++ )
			{
				getObj('RDETERMINAGrid_' + i + '_F3_SIGN_ATTACH_V_BTN').setAttribute("onclick", "ExecFunctionCenterDoc('../functions/field/uploadattachsigned.asp?TABLE=CTL_DOC_SIGN&NO_REFRESH_PARENT=YES&IDDOC=' + getObjValue('DETERMINAGrid_idRow_" + i + "') + '&OPERATION=INSERTSIGN&PATH=../../&SAVE_HASH=YES&IDENTITY=IdRow&AREA=F3&AREA_VISUAL=RDETERMINAGrid_" + i + "&DOMAIN=FileExtention&FORMAT=#AllegaFirma#600,400');" );
			}
		}
		
		//SE SIAMO IN FirmaAttiEDetermina INSERISCO LA FUNZIONE SULLA COLONNA "1 FIRMA" DELLA GRIGLIA PER CALCOLARE HASH DEL FILE CHE INSERISCO	
		if ( getObjValue('StatoFunzionale') == 'FirmaAttiEDetermina' ) 
		{
			numrow = GetProperty( getObj('DETERMINAGrid') , 'numrow');
			for( i = 0 ; i <= numrow ; i++ )
			{
				getObj('RDETERMINAGrid_' + i + '_F1_SIGN_ATTACH_V_BTN').setAttribute("onclick", "ExecFunctionCenterDoc('../functions/field/uploadattachsigned.asp?TABLE=CTL_DOC_SIGN&NO_REFRESH_PARENT=YES&IDDOC=' + getObjValue('DETERMINAGrid_idRow_" + i + "') + '&OPERATION=INSERTSIGN&PATH=../../&SAVE_HASH=YES&IDENTITY=IdRow&AREA=F1&AREA_VISUAL=RDETERMINAGrid_" + i + "&DOMAIN=FileExtention&FORMAT=#AllegaFirma#600,400');" );
			}
		}
		
	}catch(e){}
}

function afterProcess( param )
{
	if ( param == 'FITTIZIO' )
    {
		DMessageBox( '../' , 'allegato correttamente salvato e Documento Salvato' , 'Attenzione' , 1 , 400 , 300 );
	}
}
	
	

function F3_SIGN_ATTACH_OnChange(){
		
	//alert('Save F1');
	ExecDocProcess( 'FITTIZIO,DOCUMENT,,NO_MSG');
		
}

function F1_SIGN_ATTACH_OnChange(){
		
	//alert('Save F1');
	ExecDocProcess( 'FITTIZIO,DOCUMENT,,NO_MSG');
		
}

function F2_SIGN_ATTACH_OnChange(){
		
	//alert('Save F1');
	ExecDocProcess( 'FITTIZIO,DOCUMENT,,NO_MSG');
		
}




function onChangeRUPProp()
{

	
}


function GESTIONE_TipoProceduraCaratteristica()
{
	//SE E' NEGOZIATA, INVITO E' NON E' LAVORI VISUALIZZA IL CAMPO CARATTERISTICA VISIBILE
	if ( getObjValue( 'ProceduraGara' ) == '15478' && getObjValue( 'TipoBandoGara' ) == '3' && getObjValue( 'TipoAppaltoGara' ) != '2' )
	{
		setVisibility(getObj('cap_TipoProceduraCaratteristica'), '');
		setVisibility(getObj('TipoProceduraCaratteristica'), '');
	}
	else
	{
		setVisibility(getObj('cap_TipoProceduraCaratteristica'), 'none');
		setVisibility(getObj('TipoProceduraCaratteristica'), 'none');
	}
}

//CRONOLOGIAGrid_FNZ_OPEN_extraAttrib
function hide_lente_operazioni_effettuate()
{
	var cod;
	numrow = GetProperty( getObj('CRONOLOGIAGrid') , 'numrow');
	pos = GetPositionCol( 'CRONOLOGIAGrid' , 'FNZ_OPEN' , '' );

	for( i = 0 ; i <= numrow ; i++ )
	{
		
		cod = getObj( 'R' + i + '_CRONOLOGIAGrid_ID_DOC').value;
		
		if ( cod > 0 )
		{
			cod=cod;
		}
		else
		{			
			getObj( 'CRONOLOGIAGrid_r' + i + '_c' + pos ).innerHTML = '&nbsp;';			
			setClassName(getObj(  'CRONOLOGIAGrid_r' + i + '_c' + pos  ),'');
			
		}
	}	


}


function SetCaptionAllegato()
{
	var ML_KEY_Allegato = 'Allegato';
	var j = getObjValue( 'ML_Description');
	var obj = JSON.parse(j);
	var sf = ',' +  getObjValue( 'StatoFunzionale' ) + ',';


	var l = obj.ElencoStati.length;

	for( i = 0 ; i < l ; i++ )
	{
		if( obj.ElencoStati[i].StatoFunzionale.indexOf( sf ) >= 0 )
		{
			ML_KEY_Allegato = obj.ElencoStati[i].Caption;
			i = l;
		}
	}
	
	
	var NewCap = CNV( pathRoot,ML_KEY_Allegato)
	
	getObj( 'cap_SIGN_ATTACH' ).innerHTML = NewCap;
	
}


function Change_Allega_file()
{

	//-- ALLEGATO IOL DA FIRMARE
	if( getObj( 'F1_SIGN_ATTACH_V_BTN' ) )
	{
		try{ getObj('F1_SIGN_ATTACH_V_BTN').setAttribute("onclick", "ExecFunctionCenterDoc('../functions/field/uploadattachsigned.asp?TABLE=CTL_DOC_SIGN&NO_REFRESH_PARENT=YES&IDDOC=' + getObjValue('IDDOC') + '&OPERATION=INSERTSIGN&PATH=../../&SAVE_HASH=YES&IDENTITY=IdHeader&AREA=F1&DOMAIN=FileExtention&FORMAT=#AllegaFirma#600,400');" );}catch( e ) {};
	}
	
	//-- ALLEGATO IOL FIRMATO
	if( getObj( 'F2_SIGN_ATTACH_V_BTN' ) )
	{
		try{ getObj('F2_SIGN_ATTACH_V_BTN').setAttribute("onclick", "ExecFunctionCenterDoc('../functions/field/uploadattachsigned.asp?TABLE=CTL_DOC_SIGN&IDDOC=' + getObjValue('IDDOC') + '&OPERATION=INSERTSIGN&PATH=../../&IDENTITY=IdHeader&AREA=F2&DOMAIN=FileExtention&FORMAT=EXT:P7M#AllegaFirma#600,400');" );}catch( e ) {};
	}
			
	
    

}


function OnChangeQuotidiani  ( objQuotidiani )
{
		//alert(objQuotidiani.name);
		
		var strName = objQuotidiani.name;
		strName = strName.replace('_edit','');
		
		//alert (strName);
		
		//alert( getObj(strName).value );
		
		
		UpdateFieldVisualGrid( getObj(strName) ,'PUBBLICITA_LEGALE_PREVENTIVO_QUOTIDIANI', 'VIEW_QUOTIDIANI_FORNITORI' , '' , '=','parent','' );
		
		//travaso il contenuto di questo R0_Fornitore_edit in R0_Fornitore_edit_new
		//nella libreria non viene valorizzato
		//individuo indice di riga
		//var v = strName.split('_');
		//var ind = v[0].substr(1);
		
		//alert(getObj('R' +  ind + '_Fornitore_edit').value);
		//getObj('R' + ind + '_Fornitore_edit_new').value = getObj('R' +  ind + '_Fornitore_edit').value;
		//SaveDoc( '');
		
}


