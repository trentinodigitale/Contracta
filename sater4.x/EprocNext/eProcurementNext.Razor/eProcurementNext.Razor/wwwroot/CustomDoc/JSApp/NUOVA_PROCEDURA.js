window.onload = CheckCreaBando; 

function CheckCreaBando()
{

  //recupero flag Cottimo_Gara_Unificato_Attivo
  if ( getObj('Cottimo_Gara_Unificato_Attivo') )
  {  
 	SelectreadOnly( 'TipoProceduraCaratteristica' , true );	
  }

  
  //var strStatoFunzionale = getObj( 'StatoFunzionale' ).value;
  var JumpCheck = getObj( 'JumpCheck' ).value;
  
  
  
  //if ( strStatoFunzionale == 'InLavorazione')
  if( JumpCheck == 'OK' )
  {
//    //-- se la gara è in lotti apre la procedura adeguata
//    if ( getObjValue( 'Divisione_lotti') == '0' )
//    {
//      CreaBandoFlussoUnico('');
//    }
//    else
    {
       if( isSingleWin() == true )
	   {
			
			LoadDocument('BANDO_GARA' , getObjValue('IDDOC') );
			
	   }
	   else
	   {
			ShowDocumentPath( 'BANDO_GARA' , getObjValue('IDDOC') , '../');
			 window.close();
	    }
    }

   

  }
  else
  {
    //-- setta il filtro per il tipobandogara
    OnChangeProcedura(this);
  }
  
//  if( getObjValue( 'Divisione_lotti' ) == '' || getObjValue( 'Divisione_lotti' ) == '0' )
//	getObj('Complex').disabled=true;
	
	OnChangeLotti(this);
	OnChangeProcedura(this);

	//-- regola la visualizzazione  del campo "Concessione"
	OnChangeTipoAppalto( this );

    
    
}


function OnChangeCriterio( o )
{

  if( ( getObjValue( 'CriterioAggiudicazioneGara' ) == '15532' ) || ( getObjValue( 'CriterioAggiudicazioneGara' ) == '25532' ) ) //-- vantaggiosa or costo fisso
    FilterDom( 'Conformita' ,  'Conformita' , 'No' , 'SQL_WHERE=  DMV_COD = \'No\' ' , '' , ''); //-- solo no
  else
    FilterDom( 'Conformita' ,  'Conformita' , getObjValue( 'Conformita' ) , '' , '' , ''); //-- tutto
  
  HideConformita();
}


function OnChangeProcedura( o )
{
  
  try 
  { 
	var AFFIDAMENTO_DIRETTO_DUE_FASI = document.getElementById('AFFIDAMENTO_DIRETTO_DUE_FASI').value;
   
  }	catch(e){}
  
  try
  {
	  manageRegimeAllegerito();
  }
  catch(e)
  {}
  
  if( getObjValue( 'TipoProceduraCaratteristica' ) != 'RDO' ) 
  {
      //alert(getObjValue( 'TipoSceltaContraente' ));
      if( getObjValue( 'TipoSceltaContraente' ) != 'ACCORDOQUADRO' ) 
	  {
      
      
        if(  getObjValue( 'ProceduraGara' ) == '15476' || getObjValue( 'ProceduraGara' ) == '15477' || getObjValue( 'ProceduraGara' ) == '' ) //-- Aperta o Ristretta
        {
          
			FilterDom( 'TipoBandoGara' ,  'TipoBandoGara' , '2' , 'SQL_WHERE=  dmv_cod = \'2\' ' , '' , ''); //-- solo bando
		  
			FilterDom( 'Divisione_lotti' ,  'Divisione_lotti' , getObjValue( 'Divisione_lotti' ) , '' , '' , 'OnChangeLotti( this );'); //--come inizio
		  
			if( getObjValue( 'Concessione' ) == 'si' )
        		FilterDom( 'CriterioAggiudicazioneGara' ,  'CriterioAggiudicazioneGara' , getObjValue( 'CriterioAggiudicazioneGara' ) , 'SQL_WHERE=DMV_COD <> \'\' ' , '' , 'OnChangeCriterio(this);'); //-- RIMUOVE il filtro
            else
        		FilterDom( 'CriterioAggiudicazioneGara' ,  'CriterioAggiudicazioneGara' , getObjValue( 'CriterioAggiudicazioneGara' ) , 'SQL_WHERE=DMV_COD <> \'16291\' ' , '' , 'OnChangeCriterio(this);'); //-- filtro il prezzo più alto

			//setto standard (vuoto) in Caratteristica
			getObj( 'TipoProceduraCaratteristica' ).value = '';
			SelectreadOnly( 'TipoProceduraCaratteristica' , true );
				
			//getObj('TipoProceduraCaratteristica').value='';
			//setVisibility(getObj('cap_TipoProceduraCaratteristica'), 'none');
			//setVisibility(getObj('TipoProceduraCaratteristica'), 'none');
			OnChangeCriterio (); 
        }
		else if ( getObjValue( 'ProceduraGara' ) == '15583' || getObjValue( 'ProceduraGara' ) == '15479' )//-- Affidamento Diretto  o Richiesta Preventivo
		{
			if (AFFIDAMENTO_DIRETTO_DUE_FASI == '0' || getObjValue( 'ProceduraGara' ) == '15479')
			{
				//come prima senza affidamsneto a due fasi
				FilterDom( 'TipoBandoGara' ,  'TipoBandoGara' , '3' , 'SQL_WHERE=  tdrcodice = \'3\' ' , '' , ''); //-- solo invito
				SelectreadOnly( 'TipoBandoGara' , true );
											
			}
			else
			{
				//con affidamento diretto a due fasi
				if (AFFIDAMENTO_DIRETTO_DUE_FASI == '1')
				{
					FilterDom( 'TipoBandoGara' ,  'TipoBandoGara' , getObjValue( 'TipoBandoGara' ) , 'SQL_WHERE=  tdrcodice in (\'3\',\'4\',\'5\') ' , '' , ''); //-- solo invito
					SelectreadOnly( 'TipoBandoGara' , false );											
				
				}				
			}		

			FilterDom( 'CriterioAggiudicazioneGara' ,  'CriterioAggiudicazioneGara' , '15531' , 'SQL_WHERE=DMV_COD = \'15531\' ' , '' , 'OnChangeCriterio(this);'); //-- SOLO Prezzo più basso
			SelectreadOnly( 'CriterioAggiudicazioneGara' , true );
			
			FilterDom( 'Conformita' ,  'Conformita' , 'No' , 'SQL_WHERE=  DMV_COD = \'No\' ' , '' , ''); //-- solo no
			SelectreadOnly( 'Conformita' , true );
			
			FilterDom( 'Divisione_lotti' ,  'Divisione_lotti' , getObjValue( 'Divisione_lotti' ) , 'SQL_WHERE=  DMV_COD <> \'1\' ' , '' , 'OnChangeLotti( this );'); //--FILTRO   MULTIVOCE
			
			//setto standard (vuoto) in Caratteristica
			getObj( 'TipoProceduraCaratteristica').value='';
			SelectreadOnly( 'TipoProceduraCaratteristica' , true );
			
		}
        else
        {
			//PROCEDURE NEGOZIATA
			if ( getObj('Cottimo_Gara_Unificato_Attivo') )
			{	
				//se cottimo_gara_unifcato attivo e "Tipo di Appalto" = lavori (2) agg a caratteristica il valore "Cottimo"
				if ( getObj('Cottimo_Gara_Unificato_Attivo').value == 'YES' &&  getObj('TipoAppaltoGara').value == '2' )
				{	
					FilterDom( 'TipoProceduraCaratteristica' ,  'TipoProceduraCaratteristica' , getObjValue( 'TipoProceduraCaratteristica' ) , 'SQL_WHERE=  tdrcodice in (\'\',\'Cottimo\')' , '' , ' OnChangeTipoAppalto( this ); ');
					
				}
				else
				{	
					getObj( 'TipoProceduraCaratteristica' ).value='';
					SelectreadOnly( 'TipoProceduraCaratteristica' , true );		
				
				}
			}	
			
			//FilterDom( 'TipoBandoGara' ,  'TipoBandoGara' , getObjValue( 'TipoBandoGara' ) , 'SQL_WHERE=  tdrcodice = \'3\' ' , ''  , '');
			FilterDom( 'TipoBandoGara' ,  'TipoBandoGara' , getObjValue( 'TipoBandoGara' ) , 'SQL_WHERE=  tdrcodice not in (\'2\',\'4\',\'5\') ' , ''  , '');
			FilterDom( 'CriterioAggiudicazioneGara' ,  'CriterioAggiudicazioneGara' , getObjValue( 'CriterioAggiudicazioneGara' ) , 'SQL_WHERE=DMV_COD <> \'16291\' ' , '' , 'OnChangeCriterio(this);'); //-- filtro il prezzo più alto
			FilterDom( 'Divisione_lotti' ,  'Divisione_lotti' , getObjValue( 'Divisione_lotti' ) , '' , '' , 'OnChangeLotti( this );'); //--come inizio
			//setVisibility(getObj('cap_TipoProceduraCaratteristica'), '');
			//setVisibility(getObj('TipoProceduraCaratteristica'), '');
			OnChangeCriterio (); 
		   
        }
      
      }

   
  }
  
  
  
}


function  OnChangeTipoBando( obj )
{

}


function OnChangeLotti( o )
{
  if( getObjValue( 'Divisione_lotti' ) != '' && getObjValue( 'Divisione_lotti' ) != '0' && getObjValue( 'Divisione_lotti' ) != '2' )
  {
    
    //sul modello della RDO Complex non presente
    try{
      getObj('Complex').disabled=false;
      setVisibility(getObj('cap_Complex'), '');
      setVisibility(getObj('Complex'), '');
	  }catch(e){}
	  
    //cambio caption attributo "Criterio Aggiudicazione Gara" se divisione lotti<>no
	  if( getObjValue('TipoSceltaContraente') == 'ACCORDOQUADRO' ) 
      getObj('cap_CriterioAggiudicazioneGara').innerHTML =  CNV( '../../','Criterio Valutazione Prevalente');
    else
      getObj('cap_CriterioAggiudicazioneGara').innerHTML =  CNV( '../../','CriterioAggiudicazioneGara Prevalente');  
    
    
  }
  else
  {
    //sul modello della RDO Complexnon presente
    try{
	   getObj('Complex').value='0';
	   getObj('Complex').disabled=true;
      setVisibility(getObj('cap_Complex'), 'none');
      setVisibility(getObj('Complex'), 'none');
    }catch(e){}
    
    if( getObjValue('TipoSceltaContraente') == 'ACCORDOQUADRO' ) 
      getObj('cap_CriterioAggiudicazioneGara').innerHTML =  CNV( '../../','Criterio Valutazione');
    else
      getObj('cap_CriterioAggiudicazioneGara').innerHTML =  CNV( '../../','CriterioAggiudicazioneGara');  
      
    
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
    var Oneri = Number( getObj( 'Oneri' ).value );
    var importoBaseAsta2 = Number( getObj( 'importoBaseAsta2' ).value );
    var Opzioni = Number( getObj( 'Opzioni' ).value );

	var ulterioriSomme;
	var sommeRipetizioni;
	
    var totale = Oneri + importoBaseAsta2 + Opzioni;
	
	try
	{
		ulterioriSomme = Number( getObj( 'pcp_UlterioriSommeNoRibasso' ).value );
		sommeRipetizioni = Number( getObj( 'pcp_SommeRipetizioni' ).value );
		
		totale = totale + ulterioriSomme + sommeRipetizioni;
	}
	catch(e)
	{
	}
	
    SetNumericValue( 'importoBaseAsta' , totale );

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

function LocSaveDoc() 
{

    
    if( getObjValue( 'TipoProceduraCaratteristica' ) == 'RDO'  ) 
    {	
		
		//controllo su importo supera le soglie impostate
		if ( getObjValue( 'TipoAppaltoGara') == '1' ) //forniture
		{
			
			if ( Number(getObjValue( 'importoBaseAsta' )) >  Number(getObjValue( 'Importo_forniture' ))  )
			{
				DMessageBox( '../' , 'Attenzione Importo Appalto maggiore della soglia stabilita.' , 'Attenzione' , 1 , 400 , 300 );
				return -1;				
			}		
			
			
			if ( Number(getObjValue( 'importoBaseAsta' )) >  Number(getObjValue( 'Importo_Warning_forniture' ))  )
			{
				if( confirm(CNV( '../../','Attenzione Importo Appalto maggiore della soglia di Warning stabilita. Sei sicuro?')) == false  ) 
				{	
					return -1;
				}
			}				
			
		}
		//controllo su importo supera le soglie impostate
		if ( getObjValue( 'TipoAppaltoGara') == '3' ) //servizi
		{	
			
			if ( Number(getObjValue( 'importoBaseAsta' )) >  Number(getObjValue( 'Importo_servizi' ))  )
			{
				DMessageBox( '../' , 'Attenzione Importo Appalto maggiore della soglia stabilita.' , 'Attenzione' , 1 , 400 , 300 );
				return -1;
			}	
			
			if ( Number(getObjValue( 'importoBaseAsta' )) >  Number( getObjValue( 'Importo_Warning_servizi' ))  )
			{
				if( confirm(CNV( '../../','Attenzione Importo Appalto maggiore della soglia di Warning stabilita. Sei sicuro?')) == false  ) 
				{	
					return -1;
				}
			}
			
		
		}		
		
    }

	/* ALMENO PER ORA IL REGIME ALLEGERITO NON DEVE PIU' ESSERE OBBLIGATORIO 
	var valProceduraGara = getObjValue( 'ProceduraGara' );
	var objRegAllVal = getObjValue('RegimeAllegerito');
	
	//Il campo "regime allegerito" è obbligatorio a meno delle procedure di "Affidamento diretto", "Negoziata" o "Ristretta"
	if ( !( valProceduraGara == '' || valProceduraGara == '15583' || valProceduraGara == '15478' || valProceduraGara == '15477' ) && objRegAllVal == '' )
	{
		DMessageBox( '../' , 'Il campo Regime Allegerito e\' obbligatorio' , 'Attenzione' , 1 , 400 , 300 );
		return -1;
	}
	*/

	ExecDocProcess( 'SAVE,NUOVA_PROCEDURA' );

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
		//lo mopstro se non si tratta di un cottimo (nel caso di Cottimo_Gara_Unificato)
		if ( getObj('TipoProceduraCaratteristica').value != 'Cottimo'  ) 
		{	
			setVisibility(getObj('cap_Concessione'), '');
			setVisibility(getObj('Concessione'), '');         
		}
		else
		{	
			getObj('Concessione').value='no';
			OnChangeConcessione( obj );
			setVisibility(getObj('cap_Concessione'), 'none');
			setVisibility(getObj('Concessione'), 'none');        
        }      
    }
    else
    {
        //-- nascondi
        getObj('Concessione').value='no';
        OnChangeConcessione( obj );
        setVisibility(getObj('cap_Concessione'), 'none');
        setVisibility(getObj('Concessione'), 'none');         
        
    }
	
	
	OnChangeProcedura(this);
	
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
			
			FilterDom( 'ProceduraGara' ,  'ProceduraGara' , PG  , 'SQL_WHERE=  tdrcodice in ( select tdrcodice from Filter_User_Tipo_Procedura where idpfu = <ID_USER> ) and tdrcodice in (  \'15476\' , \'15478\' , \'15477\' )' , '',  'OnChangeProcedura(this)' , 'DT'); 
		
		}
		else
		{
			FilterDom( 'ProceduraGara' ,  'ProceduraGara' , PG  , 'SQL_WHERE=  tdrcodice in ( select tdrcodice from Filter_User_Tipo_Procedura where idpfu = <ID_USER> ) and tdrcodice not in ( \'15585\' )' , '' ,  'OnChangeProcedura(this)' , 'DT'); 
		}
	
		if ( PG != '' )
			OnChangeProcedura( obj );
	}
	
}

function manageRegimeAllegerito()
{
	var valProceduraGara = getObjValue( 'ProceduraGara' );
	var objRegAll = getObj('RegimeAllegerito');
	var objCapRegAll = getObj('cap_RegimeAllegerito');
	
	//Se il campo "Regime Allegerito" è presente nel dom ( non è messo ad HIDE di modello/parametro ), lo capiamo dalla presenza della sua label
	if ( objCapRegAll )
	{
		//Il campo ( regime allegerito ) non dovrà essere visibile  nel caso in cui il tipo procedura sia: Affidamento diretto, Negoziata o Ristretta
		if ( valProceduraGara == '' || valProceduraGara == '15583' || valProceduraGara == '15478' || valProceduraGara == '15477' )
		{
			objRegAll.value = '';
			
			if (typeof isFaseII !== 'undefined' && isFaseII) 
			{
				objRegAll.closest(".row").style.display = "none";
			}
			else 
			{
				objCapRegAll.closest(".VerticalModel_Caption").style.display = "none";
				objRegAll.closest(".VerticalModel_Value").style.display = "none";
			}
		}
		else
		{
			if (typeof isFaseII !== 'undefined' && isFaseII) 
			{
				objRegAll.closest(".row").style.display = "";
			}
			else 
			{
				objCapRegAll.closest(".VerticalModel_Caption").style.display = "";
				objRegAll.closest(".VerticalModel_Value").style.display = "";
			}
		}
	}
}
