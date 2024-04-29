window.onload = ON_LOAD_DOCUMENT;



function ON_LOAD_DOCUMENT()
{

	CheckCreaBando();
	
	//-- Caption del campo allegato in funzione della fase
	SetCaptionAllegato();
	
	
	HideDocumentazione();
	
	Handle_Attrib_MODULO_APPALTO_PNRR_PNC();	
	
	//se esiste la relazione PREGARA_ENTE_APPALTANTE e statofunzionale in lavorazione
	//cambio evento onchange sul campo tipoappaltogara
	Handle_PREGARA_ENTE_APPALTANTE();
	
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
	filtraDirigente();
	
	if ( DOCUMENT_READONLY == '0' )
	{
		hide_cestino_atti();
		hide_cestino_determina();
	}
	
	Change_Allega_file_ATTI();
	Change_Allega_file_DETERMINA();
	
	hide_lente_operazioni_effettuate();
    
	//se documento editabile blocco divisione lotti se RICHIESTA CIG = "Si smart CIG"
	if ( DOCUMENT_READONLY == '0' )
	{
		if( ( getObjValue( 'RichiestaCigPreGara' ) == 'si_smartcig' ) )
			SelectreadOnly( 'Divisione_lotti' , true );
		
		setRegExpCIG();
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
			
			//SelectreadOnly( 'RupProponente' , false );		
			//SQL_WHERE=  DMV_Cod= ''			
			if ( getObj('IdPfu').value == getObj('IdpfuInCharge').value )
			{				
				
				filter =  'SQL_WHERE=  dmv_cod in ( Select DMV_COD from ELENCO_RESPONSABILI where idpfu =  <ID_USER>  and RUOLO in (\'RUP\',\'RUP_PDG\')  )';
			}
			else
			{		
				filter =  'SQL_WHERE= dmv_cod in (Select DMV_COD from ELENCO_RESPONSABILI_AZI  where RUOLO in (\'RUP\',\'RUP_PDG\') and idpfu = (select top 1 idpfu from ProfiliUtente where pfuIdAzi=' + EnteProponente + ') )';
			}
			//FilterDom( 'RupProponente' , 'RupProponente' , getObj('val_RupProponente_extraAttrib').value.split('#=#')[1] , filter ,'', '','','',editable);
			FilterDom( 'RupProponente' , 'RupProponente' , getExtraAttrib('val_RupProponente' , 'value' ) , filter ,'', 'onChangeRUPProp()','','','yes');
			
		}
	}
	
}


function filtraDirigente()
{
	if (DOCUMENT_READONLY == '0' )
	{
		var filter=''
		var editable='yes';
		var EnteProponente=getObjValue('EnteProponente').split('#')[0];	
		
		if ( getObj('IdPfu').value == getObj('IdpfuInCharge').value )
		{				
			
			filter =  'SQL_WHERE=  IdPfu in ( Select DMV_COD from ELENCO_RESPONSABILI where idpfu =  <ID_USER>  and RUOLO in (\'RUP\',\'RUP_PDG\')  )';
		}
		else
		{		
			filter =  'SQL_WHERE= IdPfu in (Select DMV_COD from ELENCO_RESPONSABILI_AZI  where RUOLO in (\'RUP\',\'RUP_PDG\') and idpfu = (select top 1 idpfu from ProfiliUtente where pfuIdAzi=' + EnteProponente + ') )';
		}
		
		FilterDom( 'UserDirigente' , 'UserDirigente' , getExtraAttrib('val_UserDirigente' , 'value' ) , filter ,'', '','','','yes');
		
		
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
	
	if (param == 'FITTIZIO4') 
	{
		if ( validaDatiSimogPNRR() )
			MakeDocFrom ( 'RICHIESTA_CIG##PREGARA' );
	}
	
	if (param == 'FITTIZIO3') 
	{
		MakeDocFrom ( 'RICHIESTA_SMART_CIG##PREGARA' );
	}
	
	if (param == 'SELECT_ENTE_APPALTANTE') 
	{
		OnChangeTipoAppalto( getObj('TipoAppaltoGara') );
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
	//return 0;
	//var EnteProponente=getObjValue('EnteProponente').split('#')[0];	
	//var enteappaltante=getObjValue('Azienda');
	/*
	if ( EnteProponente == enteappaltante ) //se coincidono valorizzo Rup con lo stesso valore di RupProponente ed il campo non è editabile
	{
		//-- se il controllo è la select vuol dire che è editabile
		if( getObj('UserRUP').type != 'select-one' )
		{
		
			SetDomValue( 'UserRUP' , getObj('RupProponente').value , '');
			
			//-- effettua il salvataggio per visualizzare il rup
			ExecDocProcess('CAMBIO_RUP,DOCUMENT');
			
		}
	}
	*/
	
	//si attiva un processo 
	//Al cambiamento del RUP Proponente se lo stato del doc diverso da INLAVORAZIONE RUPPROPONENTE_OLD=COMPILATORE viene aggiornato anche il Compilatore con il nuovo RUPProponente
	/*
	if( getObjValue('StatoFunzionale') != 'InLavorazione' )
	{
		if ( getObj('RupProponente_OLD').value == getObj('IdPfu').value )
		{
			ExecDocProcess('CAMBIO_RUPPROPONENTE,DOCUMENT,,NO_MSG');
		}
	}	
	*/
	
	//-- se l'utente che cambia il RUP Proponente non è il compilatore del documento
	//-- allora potrebbe essere necessario cambiare anche il compilatore del documento
	if ( getObjValue('IdpfuInCharge') != getObjValue('IdPfu') )
	{
		ExecDocProcess('CAMBIO_RUPPROPONENTE,DOCUMENT,,NO_MSG');
	}
	
	
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


function hide_lente_operazioni_effettuate()
{
	var cod;
	numrow = GetProperty( getObj('CRONOLOGIAGrid') , 'numrow');
	for( i = 0 ; i <= numrow ; i++ )
	{
		
		cod = getObj( 'R' + i + '_CRONOLOGIAGrid_ID_DOC').value;
		
		if ( cod > 0 )
		{
			cod=cod;
		}
		else
		{			
			getObj( 'CRONOLOGIAGrid_r' + i + '_c11' ).innerHTML = '&nbsp;';			
			setClassName(getObj( 'CRONOLOGIAGrid_r' + i + '_c11' ),'');
			
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


function OnChangeRichiestaCig ()
{
	
	//if ( getObjValue('RichiestaCigPreGara') == 'si_smartcig' )
	//{
		ExecDocProcess('COERENZA_RICHIESTA_CIG,PREGARA,,NO_MSG');
	//}

}


function openGEO_simog()
{
	codApertura = 'M-1-11-ITA';
	
	var tmp = getObjValue('COD_LUOGO_ISTAT');
	
	if ( tmp !== '' )
	{
		codApertura = tmp;
	}
	
	//aggiunto il parametro cod_to_exclude per non visualizzare i codici che finiscono con XXX, quindi gli elementi 'altro' del dominio
	ExecFunction(  '../../Ctl_Library/gerarchici.asp?lo=content&portale=no&cod_to_exclude=%25XXX&fieldname=localita&path_filtra=GEO&caption=Dominio GEO&help=help_geo_ente&path_start=GEO&lvl_sel=,5,6,7,&lvl_max=7&sel_all=1&cod=' + codApertura + '&js=impostaLuogoIstat' , 'DOMINIO_GEO' , ',width=700,height=750' );
}




function impostaLuogoIstat(cod,fieldName)
{

	ajax = GetXMLHttpRequest(); 

	if(ajax)
	{
		ajax.open("GET", '../../ctl_library/functions/infoNodoGeo.asp?fldname=stato&cod=' + escape(cod), false);

		ajax.send(null);

		if(ajax.readyState == 4) 
		{
			//Se non ci sono stati errori di runtime
			if(ajax.status == 200)
			{
				if ( ajax.responseText != '' ) 
				{
					var res = ajax.responseText;
					
					//Se l'esito della chiamata è stato positivo
					if ( res.substring(0, 2) == '1#' ) 
					{
						try
						{
							var vet = res.split( '###' );
							
							var desc;

							desc = vet[1];

							getObj('DESC_LUOGO_ISTAT').value = desc;
							getObj('DESC_LUOGO_ISTAT_V').innerHTML = desc;
							getObj('COD_LUOGO_ISTAT').value = cod;

						}
						catch(e)
						{
							alert('Errore:' + e.message);
						}
					}
				}
			}

		}

	}
}



//verifico che i campi di controllo siano valorizzati prima di invocare la stored 
function richiedi_documento_cig()
{	
	Tipo_Rup = getObjValue( 'Tipo_Rup' );
	
	if ( Tipo_Rup == 'UserRUP')
	{		
		if ( getObjValue( 'UserRUP' ) != '' ) 
		{
			ExecDocProcess('FITTIZIO4,DOCUMENT,,NO_MSG');	
		}
		else 
		{
			DMessageBox('../', 'Per effettuare la richiesta dei CIG Occorre aver indicato il RUP', 'Attenzione', 1, 400, 300);
		}
	}
	else	
		
	{		
		if ( getObjValue( 'RupProponente' ) != '' ) 
		{
			ExecDocProcess('FITTIZIO4,DOCUMENT,,NO_MSG');	
		}
		else 
		{
			DMessageBox('../', 'Per effettuare la richiesta dei CIG Occorre aver indicato il RUP proponente', 'Attenzione', 1, 400, 300);
		}
	}
	
	
	
}


//verifico che i campi di controllo siano valorizzati prima di invocare la stored 
function richiedi_documento_smart_cig()
{	
	
	Tipo_Rup = getObjValue( 'Tipo_Rup' );
	if ( Tipo_Rup == 'UserRUP')
	{		
		if ( getObjValue( 'UserRUP' ) != '' ) 
		{
			ExecDocProcess('FITTIZIO3,DOCUMENT,,NO_MSG');	
		}
		else 
		{
			DMessageBox('../', 'Per effettuare la richiesta dei CIG Occorre aver indicato il RUP', 'Attenzione', 1, 400, 300);
		}
	}
	else	
		
	{		
		if ( getObjValue( 'RupProponente' ) != '' ) 
		{
			ExecDocProcess('FITTIZIO3,DOCUMENT,,NO_MSG');	
		}
		else 
		{
			DMessageBox('../', 'Per effettuare la richiesta dei CIG Occorre aver indicato il RUP proponente', 'Attenzione', 1, 400, 300);
		}
	}
	
	

}




function setRegExpCIG()
{
	try
	{
		var DOCUMENT_READONLY = '0';
		
		var strStatoFunzionale = getObjValue('StatoFunzionale');
		var RichiestaCigPreGara = getObjValue( 'RichiestaCigPreGara' );
		
		
		
		try
		{
			DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
		}
		catch(e){DOCUMENT_READONLY = '1'}

		if (DOCUMENT_READONLY == '0' && strStatoFunzionale == 'AttiDefinitivi' && RichiestaCigPreGara=='no' ) 
		{
			var divisioneLotti = getObjValue('Divisione_lotti');
			var oldOnChange = getObj('CIG').getAttribute('onchange');
			
			var newOnChange = '';

			// Se divisione in lotti NO, obbligo un CIG di lunghezza 10. Altrimenti Se divisione in lotti <> 0 lo imposto su 7
			if ( divisioneLotti == '0' )
			{
				//newOnChange = ReplaceExtended(oldOnChange,'^[\da-zA-Z]{7,7}$', '^[\da-zA-Z]{10,10}$');
				//newOnChange = ReplaceExtended(newOnChange,'^[\da-zA-Z]{7,10}$', '^[\da-zA-Z]{10,10}$');
				newOnChange = "validateField('^[\\\\da-zA-Z]{10,10}$',this);" ;
			}
			else
			{
				//newOnChange = ReplaceExtended(oldOnChange,'^[\da-zA-Z]{7,10}$', '^[\da-zA-Z]{7,7}$');
				//newOnChange = ReplaceExtended(newOnChange,'^[\da-zA-Z]{10,10}$', '^[\da-zA-Z]{7,7}$');
				newOnChange = "validateField('^[\\\\da-zA-Z]{7,7}$',this);" ;
			}

			getObj('CIG').setAttribute('onchange', newOnChange);
		}

	}
	catch(e)
	{
	}
}




function onChangeCPV()
{
	var valCodiceCPV = getObjValue('CODICE_CPV');
	
	if ( valCodiceCPV != '' )
	{
	
		var ultimi6 = valCodiceCPV.substr(valCodiceCPV.length - 6);
		var ultimi5 = valCodiceCPV.substr(valCodiceCPV.length - 5);
		
		// Consentiamo la selezione solo dei livelli maggiori o uguale al 3
		if ( ultimi6 == '000000' || ultimi5 == '00000' ) 
		{
			
			//per i livelli inferiore al terzo consento la selezione solo dei nodi foglie
			//effettuo il controllo con chiamata ajax
			var nocache = new Date().getTime();
			
			ajax = GetXMLHttpRequest();		
	
			ajax.open("GET",'../../ctl_library/functions/FIELD/CK_FldHierarchy_ChildNode.asp?DOMAIN=CODICE_CPV&CODICE=' + valCodiceCPV + '&nocache=' + nocache , false);
			ajax.send(null);
			
			if(ajax.readyState == 4) 
			{
			    //alert(ajax.status); 
				if(ajax.status == 404 || ajax.status == 500)
				{
				  alert('Errore invocazione pagina');	
				  return;
				}
			    //alert(ajax.responseText); 
				if ( ajax.responseText != 'YES' ) 
				{
					getObj('CODICE_CPV').value = '';
					getObj('CODICE_CPV_edit_new').value = '';
				
					//DMessageBox( '../' , 'Selezione non valida. Selezionare un voce con un livello di profondita\' maggiore o uguale al terzo' , 'Attenzione' , 1 , 400 , 300 );
					DMessageBox( '../' , 'Selezione non valida. Selezionare un nodo con un livello maggiore o uguale al terzo oppure un nodo foglia di livello minore al terzo' , 'Attenzione' , 1 , 400 , 300 );
				}
			}	
		}
		
	} 

}

function Handle_Attrib_MODULO_APPALTO_PNRR_PNC()
{

	//Se il campo Appalto_PNRR_PNC non esiste usciamo
	if ( !getObj('Appalto_PNRR_PNC') )
	{
		return;
	}

	DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;

	var val_SpuntaPNRR_PNC = 0;
	var HideCampi = 'no';

	// recupero il valore della spunta di selezione
	if ( DOCUMENT_READONLY == 0 )
	{
		strSpuntaPNRR_PNC = getObj('Appalto_PNRR_PNC').checked ;
		if (strSpuntaPNRR_PNC)
			val_SpuntaPNRR_PNC = 1;
	}
	else	
	{
		val_SpuntaPNRR_PNC = getObj('Appalto_PNRR_PNC').value;
	}	

	if ( val_SpuntaPNRR_PNC != 1)
		HideCampi = 'yes';

	

	if ( HideCampi == 'yes')
	{	
		$("#cap_Appalto_PNRR").parents("table:first").parents("tr:first").css({"display": "none"});
		$("#cap_Motivazione_Appalto_PNRR").parents("table:first").parents("tr:first").css({"display": "none"});
		$("#cap_Appalto_PNC").parents("table:first").parents("tr:first").css({"display": "none"});
		$("#cap_Motivazione_Appalto_PNC").parents("table:first").parents("tr:first").css({"display": "none"});
		
		//Se i nuovi campi del simog esistono
		if ( getObj('cap_FLAG_PREVISIONE_QUOTA') )
		{
		
			$("#cap_FLAG_PREVISIONE_QUOTA").parents("table:first").parents("tr:first").css({"display": "none"});
			$("#cap_QUOTA_FEMMINILE").parents("table:first").parents("tr:first").css({"display": "none"});
			$("#cap_QUOTA_GIOVANILE").parents("table:first").parents("tr:first").css({"display": "none"});
			$("#cap_ID_MOTIVO_DEROGA").parents("table:first").parents("tr:first").css({"display": "none"});
			$("#cap_FLAG_MISURE_PREMIALI").parents("table:first").parents("tr:first").css({"display": "none"});
			$("#cap_ID_MISURA_PREMIALE").parents("table:first").parents("tr:first").css({"display": "none"});
		}
		
	}
	else
	{
		
		$("#cap_Appalto_PNRR").parents("table:first").parents("tr:first").css({"display": ""});
		$("#cap_Motivazione_Appalto_PNRR").parents("table:first").parents("tr:first").css({"display": ""});
		$("#cap_Appalto_PNC").parents("table:first").parents("tr:first").css({"display": ""});
		$("#cap_Motivazione_Appalto_PNC").parents("table:first").parents("tr:first").css({"display": ""});

		//Se i nuovi campi del simog esistono
		if ( getObj('cap_FLAG_PREVISIONE_QUOTA') )
		{
			$("#cap_FLAG_PREVISIONE_QUOTA").parents("table:first").parents("tr:first").css({"display": ""});
			$("#cap_QUOTA_FEMMINILE").parents("table:first").parents("tr:first").css({"display": ""});
			$("#cap_QUOTA_GIOVANILE").parents("table:first").parents("tr:first").css({"display": ""});
			$("#cap_ID_MOTIVO_DEROGA").parents("table:first").parents("tr:first").css({"display": ""});
			$("#cap_FLAG_MISURE_PREMIALI").parents("table:first").parents("tr:first").css({"display": ""});
			$("#cap_ID_MISURA_PREMIALE").parents("table:first").parents("tr:first").css({"display": ""});
		}
	}	

	
}

function validaDatiSimogPNRR()
{
	var Modulo_Attivo = 'yes';
	
	if ( getObj('ATTIVA_MODULO_PNRR_PNC') )
		Modulo_Attivo = getObj('ATTIVA_MODULO_PNRR_PNC').value;

	if ( Modulo_Attivo == 'yes' )
	{
		if ( getObj('Appalto_PNRR_PNC').checked )
		{
			var quotaMaggiore = getObj('FLAG_PREVISIONE_QUOTA').value;
			var quotaFem = getObj('QUOTA_FEMMINILE').value;
			var quotaGio = getObj('QUOTA_GIOVANILE').value;
			var motivoDeroga = getObj('ID_MOTIVO_DEROGA').value;
			var flagMisurePremiali = getObj('FLAG_MISURE_PREMIALI').value;
			var misuraPremiali = getObj('ID_MISURA_PREMIALE').value;		
			
			//blocco Se il campo 'Quota >=30% pari opportunità' non è valorizzato e 'Appalto_PNRR_PNC' è spuntato
			if ( quotaMaggiore == '' )
			{
				DMessageBox('../', 'Valorizzare il campo Quota 30 pari opportunita' , 'Attenzione', 1, 400, 300);
				DocShowFolder( 'FLD_DATI_SIMOG' );
				return false;
			}
			
			if ( quotaFem == '' && quotaMaggiore == 'Q' && ( quotaGio == '' || quotaGio == '0' ) )
			{
				DMessageBox('../', 'Non e stato indicato il valore della Previsione di una quota inferiore con riferimento occupazione femminile' , 'Attenzione', 1, 400, 300);
				DocShowFolder( 'FLD_DATI_SIMOG' );
				return false;
			}
			
			//Se il campo quotaFem è valorizzato con una quota >=30%
			if ( Number(quotaFem) >= 30 )
			{
				DMessageBox('../', 'Il campo quota fem prevede l\'inserimento di una quota inferiore al 30'  , 'Attenzione', 1, 400, 300);
				DocShowFolder( 'FLD_DATI_SIMOG' );
				return false;
			}
			
			//Se il campo 'QUOTA_GIOVANILE' non è valorizzato e il campo 'FLAG_PREVISIONE_QUOTA'= SI e 'QUOTA_FEMMINILE'=0%
			if ( quotaGio == '' && quotaMaggiore == 'Q' && ( quotaFem == '' || quotaFem == '0' ) )
			{
				DMessageBox('../', 'Non e stato indicato il valore della Previsione di una quota inferiore con riferimento occupazione giovanile' , 'Attenzione', 1, 400, 300);
				DocShowFolder( 'FLD_DATI_SIMOG' );
				return false;
			}
			
			//Se il campo quotaFem è valorizzato con una quota >=30%
			if ( Number(quotaGio) >= 30 )
			{
				DMessageBox('../', 'Il campo quota giov prevede l\'inserimento di una quota inferiore al 30' , 'Attenzione', 1, 400, 300);
				DocShowFolder( 'FLD_DATI_SIMOG' );
				return false;
			}
			
			//motivo deroga Obbligatorio Se il campo S02.23= SI quota inferiore oppure S02.23= NO
			if ( motivoDeroga == '' && ( quotaMaggiore == 'Q' || quotaMaggiore == 'N' ) )
			{
				DMessageBox('../', 'Il campo Motivo deroga e\' obbligatorio' , 'Attenzione', 1, 400, 300);
				DocShowFolder( 'FLD_DATI_SIMOG' );
				return false;
			}
			
			if ( flagMisurePremiali == 'S' && misuraPremiali == '' )
			{
				DMessageBox('../', 'Il campo Misure premiali e\' obbligatorio' , 'Attenzione', 1, 400, 300);
				DocShowFolder( 'FLD_DATI_SIMOG' );
				return false;
			}
			
			if ( flagMisurePremiali == '' )
			{
				DMessageBox('../', '"Presenza di misure premiali" e\' obbligatorio se "Appalto PNRR/PNC" e\' selezionato' , 'Attenzione', 1, 400, 300);
				DocShowFolder( 'FLD_DATI_SIMOG' );
				return false;
			}

		}
	}
	
	return true;
}	




function Handle_PREGARA_ENTE_APPALTANTE ()
{
	//se lo stato in lavorazione ed esiste la relazione  "PREGARA_ENTE_APPALTANTE" 
	//innesco un processo per impostare il campo azienda sul documento 
	
	if ( getObjValue('StatoFunzionale') == 'InLavorazione' ) 
	{
		if ( getObjValue('Presenza_PREGARA_ENTE_APPALTANTE') == 'si' ) 		
		{	
			//cambio evento di onchange sul campo TipoAppaltoGara
			getObj('TipoAppaltoGara' ).onchange = OnChangeTipoAppaltoGara;
		}
			
	}
}



function OnChangeTipoAppaltoGara()
{
	ExecDocProcess('SELECT_ENTE_APPALTANTE,PREGARA');
}
