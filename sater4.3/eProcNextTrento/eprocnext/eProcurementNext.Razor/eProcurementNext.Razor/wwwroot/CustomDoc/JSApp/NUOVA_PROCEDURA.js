 


//crea un bando flusso unico
function CreaBandoFlussoUnico(param)
{

  var ParamNewDoc;
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
  
  //recupero identificativo nuovo documento
  var IDDOC = getObj( 'IDDOC' ).value;
  
  //alert(IDDOC);
  //strSql='select iddoc,Attach from  view_progetti_attidigara where iddoc = ' + IDDOC ;
  
  var strSqlProdotti='select top 1 * from document where iddcm=-1';
  
  
  //recupero valori attributi
  var strTipoAppalto = getObjValue( 'TipoAppaltoGara');
  switch (strTipoAppalto){
    case '1':
              strTipoAppalto='15495';
		          break;
    case '2':
              strTipoAppalto='15496';
		          break;
    case '3':
              strTipoAppalto='15494';
		          break;
    case '4':
              strTipoAppalto='';
		          break;        	
  }
  
  var strModalitadiPartecipazione= getObjValue( 'ModalitadiPartecipazione');
  var strProceduraGara = getObjValue( 'ProceduraGara');
  var strTipoBandoGara = getObjValue( 'TipoBandoGara');
  var strCriterioAggiudicazioneGara = getObjValue( 'CriterioAggiudicazioneGara');
  var strDivisione_lotti = getObjValue( 'Divisione_lotti');
  var strImportoAppalto = getObjValue( 'importoBaseAsta');
  var strCriterioFormulazioneOfferte = getObjValue( 'CriterioFormulazioneOfferte');
  var strimportoBaseAsta2 = getObjValue( 'importoBaseAsta2');
  
  //completo la query per la testata
  strSqltestata = 'select ' + strModalitadiPartecipazione + ' as ModalitadiPartecipazione, ' + strTipoAppalto + ' as tipoappalto, ' + strProceduraGara + ' as  ProceduraGara, ' + strTipoBandoGara + ' as TipoBando, ' + strCriterioAggiudicazioneGara + ' as CriterioAggiudicazioneGara, ' ;
  strSqltestata = strSqltestata  +  strDivisione_lotti + ' as Divisione_lotti, '  + strImportoAppalto +  ' as importoBaseAsta, ' + strimportoBaseAsta2 +  ' as importoBaseAsta2, '  + strCriterioFormulazioneOfferte +  ' as CriterioFormulazioneOfferte ' ;  
  
  //parametri per creare il nuovo documento
  //sottotipo;modello prodotti;pos sezione prodotti;pos area prodotti;TabName;modalit
  ParamNewDoc = '167;4784;1;1;BANDO;SHOW;';
  
  //compongo url
  strUrl='../../dashboard/NewGenDoc.asp?FieldForNameDoc=&SQLTESTATA=' + strSqltestata + '&SQLPRODOTTI=' + strSqlProdotti + '&PARAM=' + ParamNewDoc ;

  //creo doc
  ExecFunction(  strUrl , 'NEWGENDOC' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );

}



window.onload = CheckCreaBando;


function CheckCreaBando()
{

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
  var AFFIDAMENTO_DIRETTO_DUE_FASI = document.getElementById('AFFIDAMENTO_DIRETTO_DUE_FASI').value
  
  if( getObjValue( 'TipoProceduraCaratteristica' ) != 'RDO' ) 
  {
      //alert(getObjValue( 'TipoSceltaContraente' ));
      if( getObjValue( 'TipoSceltaContraente' ) != 'ACCORDOQUADRO' ) {
      
      
        if(  getObjValue( 'ProceduraGara' ) == '15476' || getObjValue( 'ProceduraGara' ) == '15477' || getObjValue( 'ProceduraGara' ) == '' ) //-- Aperta o Ristretta
        {
          
			FilterDom( 'TipoBandoGara' ,  'TipoBandoGara' , '2' , 'SQL_WHERE=  dmv_cod = \'2\' ' , '' , ''); //-- solo bando
		  
			FilterDom( 'Divisione_lotti' ,  'Divisione_lotti' , getObjValue( 'Divisione_lotti' ) , '' , '' , 'OnChangeLotti( this );'); //--come inizio
		  
			if( getObjValue( 'Concessione' ) == 'si' )
        		FilterDom( 'CriterioAggiudicazioneGara' ,  'CriterioAggiudicazioneGara' , getObjValue( 'CriterioAggiudicazioneGara' ) , 'SQL_WHERE=DMV_COD <> \'\' ' , '' , 'OnChangeCriterio(this);'); //-- RIMUOVE il filtro
            else
        		FilterDom( 'CriterioAggiudicazioneGara' ,  'CriterioAggiudicazioneGara' , getObjValue( 'CriterioAggiudicazioneGara' ) , 'SQL_WHERE=DMV_COD <> \'16291\' ' , '' , 'OnChangeCriterio(this);'); //-- filtro il prezzo più alto
			
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
		
		}
        else
        {
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

function LocSaveDoc() 
{

    
    if( getObjValue( 'TipoProceduraCaratteristica' ) == 'RDO'  ) 
    {	
		/* obsoleto
        if ( Number(getObjValue( 'importoBaseAsta' ))  > 200000 )
        {
        
    		DMessageBox( '../' , 'Per le RdO "Importo Appalto &euro;" non puo\' superare i 200.000 &euro;' , 'Attenzione' , 1 , 400 , 300 );
    		getObj( 'importoBaseAsta' ).focus();
            return -1;
        }
		*/
		
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
        setVisibility(getObj('cap_Concessione'), '');
        setVisibility(getObj('Concessione'), '');         
                 
    }
    else
    {
        //-- nascondi
        getObj('Concessione').value='no';
        OnChangeConcessione( obj );
        setVisibility(getObj('cap_Concessione'), 'none');
        setVisibility(getObj('Concessione'), 'none');         
        
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
