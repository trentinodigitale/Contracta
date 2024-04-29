var flag=0;
var OldValueTipoBando = '';

window.onload = OnLoadPage; 

function OnLoadPage()
{

	//cambia la tooltip della matita per Aprire il dettaglio del modello	
	var tmpMlg = '';
	try{
		tmpMlg = CNV( pathRoot ,'Modifica Modello Gara');
		getObj('RTESTATA_PRODOTTI_MODEL_FNZ_UPD_link').firstChild.alt= tmpMlg;
		getObj('RTESTATA_PRODOTTI_MODEL_FNZ_UPD_link').firstChild.title=tmpMlg;
	}catch( e ) {};
    
	//ricarico la sezione 
	//ExecDocCommandInMem(  'TESTATA_PRODOTTI#RELOAD', idpfuUtenteCollegato , 'BANDO_GARA');

    //-- filtro il dominio dei modelli
    //FilterDom(  'CriterioFormulazioneOfferte' , 'CriterioFormulazioneOfferte' , getObjValue( 'CriterioFormulazioneOfferte' ), 'SQL_WHERE= tdrcodice in ( select CriterioFormulazioneOfferte  from Document_Modelli_MicroLotti_Formula where Codice =  \'' + getObjValue( 'TipoBando' ) + '\' ) ' , '' , '')
    //RTESTATA_PRODOTTI_MODEL_TipoBando


//    var Criterio = getObjValue( 'CriterioFormulazioneOfferte' ); 
//    var Conform = getObjValue( 'Conformita' ); 
//    var CriterioAggiudicazione = getObjValue( 'CriterioAggiudicazioneGara' );   
//    var Complex = getObjValue( 'Complex' ); 
//    if ( Complex == '' )
//    {
//        Complex=0;
//    }
//    var filter =  'SQL_WHERE= DMV_Father  <> \'1\' and DMV_Cod in ( select codice  from View_Modelli_Lotti where  CriterioFormulazioneOfferte = \'' + Criterio +  '\'  and CriterioAggiudicazioneGara like \'%###' + CriterioAggiudicazione +  '###%\' and Conformita like \'%###' +  Conform +  '###%\' and Complex = ' +  Complex +' and Ambito = \'' + Ambito + '\' )';

//    try
//    {
//        if( getObjValue(   'StatoFunzionale' ) == 'InLavorazione' )
//        {
//            FilterDom( 'RTESTATA_PRODOTTI_MODEL_TipoBando' , 'TipoBando' , getObjValue('RTESTATA_PRODOTTI_MODEL_TipoBando') , filter , 'RTESTATA_PRODOTTI_MODEL'  , 'OnChangeModello( this );');
//        }
//    }catch( e ) {};

    FiltraModelli();



    //-- visualizza le date e le relative descrizioni in coerenza con la tipologia di documento
    if (  getObjValue( 'ProceduraGara' ) == '15478' && getObjValue( 'TipoBandoGara' )  == '4' ) //-- Negoziata - Avviso con risposta
    {

        getObj( 'cap_DataRiferimentoInizio' ).innerHTML = CNV( pathRoot,'Inizio Presentazioni Manifestazione di Interesse');
        getObj( 'cap_DataScadenzaOfferta' ).innerHTML   = CNV( pathRoot,'Termine Presentazione Manifestazione di Interesse');

        //setVisibility( getObj( 'cap_DataAperturaOfferte' ).offsetParent.offsetParent , 'none' );

    }    

    if (  getObjValue( 'ProceduraGara' ) == '15478' && getObjValue( 'TipoBandoGara' )  == '1' ) //-- Negoziata - Avviso 
    {

        //getObj( 'cap_DataAperturaOfferte' ).innerHTML   = CNV( pathRoot,'Data Presunta Pubblicazione Invito');

        setVisibility( getObj( 'cap_DataRiferimentoInizio' ).offsetParent.offsetParent , 'none' );
        setVisibility( getObj( 'cap_DataScadenzaOfferta' ).offsetParent.offsetParent , 'none' );

    }    

    if (  getObjValue( 'ProceduraGara' ) == '15477' && getObjValue( 'TipoBandoGara' )  == '1' ) //-- Ristretta - Bando
    {

        getObj( 'cap_DataRiferimentoInizio' ).innerHTML = CNV( pathRoot,'Inizio Presentazioni Domanda di Partecipazione');
        getObj( 'cap_DataScadenzaOfferta' ).innerHTML   = CNV( pathRoot,'Termine Presentazione Domanda di Partecipazione');

    }

    //-- nascondo sulla sezione di riepilogo lotti la colonna dei criteri se non è economicamente vantaggiosa
    //var criterio = getObjValue( 'CriterioAggiudicazioneGara' );
    //if ( criterio == '15532' //-- coorisponde offerta economica vantaggiosa 

    DisplaySection();   
		
	//gestisco i campi per gli appalti verdi
	try
	{
	   if (  getObjValue( 'Appalto_Verde' ) != 'si' )
	   {
			getObj( 'Motivazione_Appalto_Verde').value='';
			getObj( 'Motivazione_Appalto_Verde').disabled=true;
			
	   }
	}catch(e){}
	try
	{	
	   if (  getObjValue( 'Acquisto_Sociale' ) != 'si' )
	   {
			getObj( 'Motivazione_Acquisto_Sociale').value='';
			getObj( 'Motivazione_Acquisto_Sociale').disabled=true;
			
	   }
    }catch(e){}  
	
    OnChange_Riparametrazione();
	//setto evento onchange se RDO
	//if( getObj( 'TipoProceduraCaratteristica' ).value == 'RDO' )
    //{
	//	try{ getObj('DataScadenzaOfferta_V').setAttribute("onchange","OnChangeDataScadenzaOfferta()");}catch(e){};
	//}
	  //se la gara è economicamente vantaggiosa allora bisogna mettere un filtro nella scelta della formula
	  //CriterioFormulazioneOfferte = 15537 Percentuale
	  //CriterioFormulazioneOfferte = 15536 Prezzo

	  var CriterioAggiudicazione = getObjValue( 'CriterioAggiudicazioneGara' );   
	  var filter = '';
	  if ( CriterioAggiudicazione == '15532' || CriterioAggiudicazione == '25532' )
	  {
	  
  		if ( getObjValue('CriterioFormulazioneOfferte') == '15537' )
  		{
  			filter ='SQL_WHERE= CategorieUSO like \'%,sconto,%\' and CategorieUSO like \'%,asta,%\' '
  		}
  		
  		if ( getObjValue('CriterioFormulazioneOfferte') == '15536' )
  		{
  			filter ='SQL_WHERE= CategorieUSO like \'%,prezzo,%\' and CategorieUSO like \'%,asta,%\''
  		}
  		
  		FilterDom( 'FormulaEcoSDA' , 'FormulaEcoSDA' , getObjValue('FormulaEcoSDA') , filter , ''  , 'OnChangeFormula( this );flagmodifica();');
  		//FilterDom( 'OffAnomale' , 'OffAnomale' , getObjValue('OffAnomale') , 'SQL_WHERE= tdrcodice = \'16310\' ' , ''  , '');	
		
		
	  }
	  
	  if( getObj( 'TipoProceduraCaratteristica' ).value == 'RDO' )
	  {
  		//per le RDO se Lista Albi è vuoto allora disabilito le classi di iscrizione
  		if ( getObj( 'ListaAlbi' ).value == '' ) 
  		{
  			DisableObj( 'ClasseIscriz' , true );
  		}
  		else
  		{
  			DisableObj( 'ClasseIscriz' , false );
  		}
  		//filtro le classi iscrizione in base all'albo scelto solo se il documento è in lavorazione
  		if(  getObjValue( 'StatoFunzionale' ) == 'InLavorazione'  )
  		{
  		
  			var class_bando = getObj('ClasseIscriz_Bando').value;
  			var filter = '';
  			
  			filter =  GetProperty ( getObj('ClasseIscriz'),'filter') ;				
  			
  				if ( filter == '' || filter == undefined || filter == null )
  				{					
  					SetProperty( getObj('ClasseIscriz'),'filter','SQL_WHERE= dmv_cod in (  select top 1000000  B.dmv_cod  from ClasseIscriz a  INNER JOIN ClasseIscriz B ON a.dmv_father = left( b.dmv_father , len ( a.dmv_father ) )  or  b.dmv_father = \'000.\'  or b.dmv_father = left( a.dmv_father , len ( b.dmv_father ) )     where  \'' + class_bando + '\' like \'%###\' + A.DMV_COD + \'###%\'    )');
  					
  				}			
  		}	
		
		
		
	  }  
	  
	  //nascondo la busta tecnica per i lotti che non ne hanno bisogno
	  HideBustaTecnicaLotti();
	  //solo per le RDO nascondi i farmaci dall'ambito
	  if( getObj( 'TipoProceduraCaratteristica' ).value == 'RDO' )
	  {
		 var filter =  'SQL_WHERE=  DMV_Cod <> 1';

         FilterDom( 'RTESTATA_PRODOTTI_MODEL_Ambito' , 'Ambito' , getObjValue('RTESTATA_PRODOTTI_MODEL_Ambito') , filter , 'TESTATA_PRODOTTI_MODEL'  , 'OnChangeAmbito( this );');
	  
	  }
	 
	 //se doc non è readonly applico filtro ai riferimenti
	if ( getObj( 'DOCUMENT_READONLY' ).value == '0') 
	{
		
		FilterRiferimenti();
	}
	  
}

function onchangeAppalto_Verde()
{
	try
	{
		if (  getObjValue( 'Appalto_Verde' ) != 'si' )
		{	
			getObj( 'Motivazione_Appalto_Verde').value='';
			getObj( 'Motivazione_Appalto_Verde').disabled=true;
			
		}
	 }catch(e){}  
	try
	{
		if (  getObjValue( 'Appalto_Verde' ) == 'si' )
		 {	
			
			getObj( 'Motivazione_Appalto_Verde').disabled=false;
			
		 }
	}catch(e){}  	
	
}
function onchangeAcquisto_Sociale()
{
	try
	{
		if (  getObjValue( 'Acquisto_Sociale' ) != 'si' )
		 {	
			getObj( 'Motivazione_Acquisto_Sociale').value='';
			getObj( 'Motivazione_Acquisto_Sociale').disabled=true;
			
		 }
	}catch(e){}  		
	try
	{
		if (  getObjValue( 'Acquisto_Sociale' ) == 'si' )
		 {			
			getObj( 'Motivazione_Acquisto_Sociale').disabled=false;
			
		 }
	}catch(e){}  		
	
}


function OnChangeAmbito()
{
	var iddoc = getObj('IDDOC').value;	
	
	var Ambito = getObjValue('RTESTATA_PRODOTTI_MODEL_Ambito');
	            
	if (getObjValue( 'TipoBando' ) != '' )
	{
		alert( CNV( pathRoot,'Il cambio dell\'ambito comporta un azzeramento del modello dei prodotti'));

        ExecDocProcess( 'SVUOTA_SOLO_MODELLO_PRODOTTI,BANDO_GARA');

	}
	else
	{
        FiltraModelli();
	}
}


function FiltraModelli()
{
    try
    {
        if( getObjValue(   'StatoFunzionale' ) == 'InLavorazione' )
        {

            var Ambito = getObjValue( 'RTESTATA_PRODOTTI_MODEL_Ambito' ); 
            var Criterio = getObjValue( 'CriterioFormulazioneOfferte' ); 
            var Conform = getObjValue( 'Conformita' ); 
            var CriterioAggiudicazione = getObjValue( 'CriterioAggiudicazioneGara' );   
            var Complex = getObjValue( 'Complex' ); 
			var TipoProceduraCaratteristica=getObj('TipoProceduraCaratteristica').value;
			var ProceduraGara=getObjValue('ProceduraGara');
            
            
            
            var Monolotto = 0;
            if ( Complex == '' )
            {
                Complex=0;
            }

            if ( getObjValue( 'Divisione_lotti' ) == '0' )
            {
                Monolotto = 1
            }
            
            var filter =  'SQL_WHERE= DMV_Father  <> \'1\' and DMV_Cod in ( select codice  from View_Modelli_Lotti where  TipoProcedureApplicate like \'%###\' + dbo.GetDescTipoProcedura( \'BANDO_ASTA\' , \'' + TipoProceduraCaratteristica + '\' , \'' + ProceduraGara + '\' ) + \'###%\' and CriterioFormulazioneOfferte = \'' + Criterio +  '\'  and CriterioAggiudicazioneGara like \'%###' + CriterioAggiudicazione +  '###%\' and Conformita like \'%###' +  Conform +  '###%\' and Complex = ' +  Complex +' and Ambito = \'' + Ambito + '\' and Monolotto = ' + Monolotto + ' )';

            FilterDom( 'RTESTATA_PRODOTTI_MODEL_TipoBandoScelta' , 'TipoBandoScelta' , getObjValue('RTESTATA_PRODOTTI_MODEL_TipoBandoScelta') , filter , 'TESTATA_PRODOTTI_MODEL'  , 'OnChangeModello( this );');
        }
    }catch( e ) {};

}



function RefreshContent()
{
	
	if( getObjValue(   'StatoFunzionale' ) != 'InLavorazione' )
    {
		RefreshDocument('');
	}
	else
	{
		ExecDocCommand( 'LISTA_BUSTE#RELOAD' );
		ExecDocCommand( 'DESTINATARI_1#RELOAD' );
		
	}
}


function CreateBandoSemplificato( objGrid , Row , c )
{
	var cod;
	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
	var w = screen.availWidth;
  var h = screen.availHeight;
  parent.opener.DOC_NewDocumentFrom( 'BANDO_SEMPLIFICATO#BANDO_SDA_ADERENTE,' + cod + '#' + w + ',' + h + '###../ctl_library/document/document.asp?' );

  parent.parent.close();
}

function OnChangePrimaSeduta(obj)
{
    try
    {
        if ( getObj('GG_PrimaSeduta').value > 3 ) 
        {
        		//DMessageBox( '../' , 'La data di prima seduta viene calcolata sommando il numero di giorni inseriti alla data scadenza offerta' , 'Attenzione' , 1 , 400 , 300 );
        }
    }catch(e){};

}

function OnChangeQuesito(obj)
{
    try
    {
        if ( getObj('RichiestaQuesito').value == '2' ) 
        {
            getObj( 'gg_QuesitiScadenza_V' ).disabled= true;
            SetNumericValue( 'gg_QuesitiScadenza' , 0 );
        }
        else
        {
            getObj( 'gg_QuesitiScadenza_V' ).disabled= false;
        }
    }catch(e){};

}

function OnChangeTipoBando( obj )
{
    
    //-- aggiorna il modello da usare per la sezione prodotti
    //ExecDocProcess( 'SELECT_MODELLO_SDA,BANDO_SDA');
}

//-- associo il nuovo modello al documento 
function OnChangeModello( o )
{

    //-- verifico che siano state selezioante delle classi di iscrizione prima di proseguire
    if( getObj( 'TipoProceduraCaratteristica' ).value == 'RDO' )
    {
        if( getObj( 'ClasseIscriz').value == '' )
        {
            getObj( 'TipoBando').value = '';
            //getObj('RTESTATA_PRODOTTI_MODEL_TipoBando').value = '';
            
            DocShowFolder( 'FLD_COPERTINA' );	   
            getObj('ClasseIscriz_button' ).focus();
            DMessageBox( '../' , 'E\' necessario selezionare prima le Classi merceologiche' , 'Attenzione' , 1 , 400 , 300 );

            return;
        }
    }
    
        
    
    //-- aggiorna il modello da usare per la sezione prodotti
   // ExecDocProcess( 'SELECT_MODELLO_SDA,BANDO_SDA');
	ExecDocProcess( 'SELECT_MODELLO_BANDO,BANDO');
} 

function OnClickProdotti( obj )
{
    var TipoBando = getObjValue( 'TipoBando' );
    
    if ( TipoBando == '' )
    {
      //alert( CNV( '../','E\' necessario selezionare prima il modello'));
      DMessageBox( '../' , 'E\' necessario selezionare prima il modello' , 'Attenzione' , 1 , 400 , 300 );
      return ;
    }
    
    //-- verifico che siano state selezioante delle classi di iscrizione prima di proseguire
    if( getObj( 'TipoProceduraCaratteristica' ).value == 'RDO' )
    {
        if( getObj( 'ClasseIscriz').value == '' )
        {
            getObj( 'TipoBando').value = '';
            getObj('RTESTATA_PRODOTTI_MODEL_TipoBando').value = '';
            
            DocShowFolder( 'FLD_COPERTINA' );	   
            getObj('ClasseIscriz_button' ).focus();
            DMessageBox( '../' , 'E\' necessario selezionare prima le Classi merceologiche' , 'Attenzione' , 1 , 400 , 300 );

            return;
        }
    }


    var DOCUMENT_READONLY = getObj( 'DOCUMENT_READONLY' ).value;
    if ( DOCUMENT_READONLY == "1" )
        DMessageBox( '../' , 'Documento in sola lettura' , 'Attenzione' , 1 , 400 , 300 );
    else
        ImportExcel( 'CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=RTESTATA_PRODOTTI_MODEL_Allegato&SHEET=0&PARAM=posizionale&PROCESS=LOAD_PRODOTTI,BANDO_GARA&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#400,300' );
}


function OnChangeClassIscriz( obj )
{
    //-- svuoto i prodotti caricati ed il modello selezionato perchè potrebbe essere incoerente con le classi caricate
    //if( getObj( 'TipoBando').value != '' || DESTINATARI_1Grid_NumRow != -1 )
    {
        ExecDocProcess( 'SVUOTA_MODELLO_PRODOTTI,BANDO_GARA');
    }
    
}

function ChangeOE( param )
{
    //-- verifico che siano state selezioante delle classi di iscrizione prima di proseguire
    if( getObj( 'TipoProceduraCaratteristica' ).value == 'RDO' )
    {
        if( getObj( 'ClasseIscriz').value == '' )
        {
            getObj( 'TipoBando').value = '';
            getObj('RTESTATA_PRODOTTI_MODEL_TipoBando').value = '';
            
            DocShowFolder( 'FLD_COPERTINA' );	   
            getObj('ClasseIscriz_button' ).focus();
            DMessageBox( '../' , 'E\' necessario selezionare prima le Classi merceologiche' , 'Attenzione' , 1 , 400 , 300 );

            return;
        }
    }
    
    MakeDocFrom( param );
}

function LISTA_DOCUMENTI_OnLoad()
{
    OnChangeQuesito();
    
    /*
	if (getObj('IDDOC').value.substring(0,3) == 'new' )
  	{
  		LISTA_DOCUMENTI.location = '../../DASHBOARD/Viewer.asp?TOOLBAR=&Table=BANDO_SDA_LISTA_DOCUMENTI&JSCRIPT=BANDO_SDA&IDENTITY=Id&DOCUMENT=BANDO_SDA&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=&Height=0,100*,0&numRowForPag=15&Sort=data&ActiveSel=2&SortOrder=asc&Exit=no&ShowExit=0&FilterHide=IdDoc = 0 ';
  	}
  	else
  	{
  		LISTA_DOCUMENTI.location = '../../DASHBOARD/Viewer.asp?TOOLBAR=&Table=BANDO_SDA_LISTA_DOCUMENTI&JSCRIPT=BANDO_SDA&IDENTITY=Id&DOCUMENT=BANDO_SDA&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=&Height=0,100*,0&numRowForPag=15&Sort=data&ActiveSel=2&SortOrder=asc&Exit=no&ShowExit=0&FilterHide=LinkedDoc =' + getObj('IDDOC').value ;;	
  	}
	*/
  	
}

function DESTINATARI_1_OnLoad()
{
    //DisplaySection();
}

function flagmodifica()
{
    flag=1;
}


function MySend(param)
{
    //alert(param);
    if( ControlliSend( param ) == -1 ) return -1;
    ExecDocProcess(param);
 
}

function ControlliSend(param)
{
    
	var criterio = getObjValue( 'CriterioAggiudicazioneGara' );
	

	if ( ( criterio == '15532' || criterio == '25532')//-- coorisponde offerta economica vantaggiosa 
        &&  
        //-- non deve essere "ristretta bando" o "negoziata avviso"
        !( getObjValue( 'ProceduraGara' ) == '15477' && getObjValue( 'TipoBandoGara' )  == '2')//-- ristretta Bando
        &&
        !(getObjValue( 'ProceduraGara' ) == '15478' && getObjValue( 'TipoBandoGara' )  == '1') //-- negoziata avviso
    ) 
	{
		var PunteggioEconomico=parseFloat(getObjValue( 'PunteggioEconomico' ));
		var PunteggioTecnico=parseFloat(getObjValue( 'PunteggioTecnico' ));
		//solo per le gare diverse da tradizionale
		if ( getObj('ModalitadiPartecipazione').value != '16307' )
		{
			if ( PunteggioEconomico == 0 || getObjValue( 'PunteggioEconomico_V' ) == '')	
			{
				DocShowFolder( 'FLD_CRITERI' );	   
				tdoc();
				DMessageBox( '../' , 'Digitare un punteggio Economico superiore a 0' , 'Attenzione' , 1 , 400 , 300 );
				getObj('PunteggioEconomico_V').focus();
				return -1;
			}
			if ( PunteggioTecnico == 0 || getObjValue( 'PunteggioTecnico_V' ) == '' )	
			{
				DocShowFolder( 'FLD_CRITERI' );	   
				tdoc();
				DMessageBox( '../' , 'Digitare un punteggio Tecnico superiore a 0' , 'Attenzione' , 1 , 400 , 300 );
				getObj('PunteggioTecnico_V').focus();
				return -1;
			}	
			
			if ( PunteggioEconomico + PunteggioTecnico < 100 )	
			{
				DocShowFolder( 'FLD_CRITERI' );	   
				tdoc();
				DMessageBox( '../' , 'La somma del punteggio tecnico e del punteggio economico deve essere 100' , 'Attenzione' , 1 , 400 , 300 );
				getObj('PunteggioEconomico_V').focus();
				return -1;
			}
		}
		
		if ( getObjValue( 'PunteggioTecMin' ) != '' &&  getObjValue( 'PunteggioTecMin' ) > PunteggioTecnico )
		{
			DocShowFolder( 'FLD_CRITERI' );	   
			tdoc();
			DMessageBox( '../' , 'La soglia minima del punteggio Tecnico non puo\' essere maggiore del punteggio tecnico' , 'Attenzione' , 1 , 400 , 300 );
			getObj('PunteggioTecMin_V').focus();
			return -1;
		}
		//solo per le gare diverse da tradizionale
		if ( getObj('ModalitadiPartecipazione').value != '16307' )
		{
			if ( getObjValue( 'FormulaEcoSDA' )== '')
			{
				DocShowFolder( 'FLD_CRITERI' );	   
				tdoc();
				DMessageBox( '../' , 'Nella sezione dei criteri per la valutazione della busta economica selezionare il "Criterio Economica"' , 'Attenzione' , 1 , 400 , 300 );
				getObj('FormulaEcoSDA').focus();
				return -1;
			}
		}			
		
		//solo per le gare diverse da tradizionale
		if ( getObj('ModalitadiPartecipazione').value != '16307' )
		{
			if( getObj('FormulaEcoSDA').value.indexOf( ' Coefficiente X ' ) >= 0 )
			{
				if( getObjValue('Coefficiente_X') == '' )
				{
					DocShowFolder( 'FLD_CRITERI' );	   
					tdoc();
					DMessageBox( '../' , 'Nella sezione dei criteri per la valutazione della busta economica selezionare un valore per il campo "Coefficiente X"' , 'Attenzione' , 1 , 400 , 300 );
					getObj('Coefficiente_X').focus();
					return -1;
				}
				
			}
			
			if( getObj('FormulaEcoSDA').value.indexOf( ' Alfa ' ) >= 0 )
			{
				if( getObjValue('Alfa') == '' )
				{
					DocShowFolder( 'FLD_CRITERI' );	   
					tdoc();
					DMessageBox( '../' , 'Nella sezione dei criteri per la valutazione della busta economica selezionare un valore per il campo "Alfa"' , 'Attenzione' , 1 , 400 , 300 );
					getObj('Alfa_V').focus();
					return -1;
				}
				
			}
			
		}
		//controlli sulla griglia
		//solo per le gare diverse da tradizionale
		if ( getObj('ModalitadiPartecipazione').value != '16307' )
		{
			if( GetProperty( getObj('CRITERIGrid') , 'numrow')==-1)
			{
				DocShowFolder( 'FLD_CRITERI' );	   
				tdoc();
				DMessageBox( '../' , 'Nella griglia Criteri di valutazione busta tecnica deve essere presente almeno una riga.' , 'Attenzione' , 1 , 400 , 300 );
				return -1;
			
			}
		}
		if( GetProperty( getObj('CRITERIGrid') , 'numrow')!=-1)
		{
			var numrighe=GetProperty( getObj('CRITERIGrid') , 'numrow');
			var i=0;
			var k=0;
			var totpunteggiorighe=0;
			//alert(numrighe);
			for( i = 0 ; i <= numrighe ; i++ )
			{		
				
			    if(getObjValue('RCRITERIGrid_'+i+'_CriterioValutazione') == '')
				{
					DocShowFolder( 'FLD_CRITERI' );	   
					tdoc();
					DMessageBox( '../' , 'Sulla griglia Criteri di valutazione il "Criterio" su ogni riga.' , 'Attenzione' , 1 , 400 , 300 );
					getObj('RCRITERIGrid_'+i+'_CriterioValutazione').focus();
					return -1;	
				}
				if (isNaN(parseFloat(getObjValue('RCRITERIGrid_'+i+'_PunteggioMax'))) || parseFloat(getObjValue('RCRITERIGrid_'+i+'_PunteggioMax')) == 0 )
				{
					DocShowFolder( 'FLD_CRITERI' );	   
					tdoc();
					DMessageBox( '../' , 'Sulla griglia Criteri di valutazione il punteggio per ogni singola riga deve essere maggiore di zero.' , 'Attenzione' , 1 , 400 , 300 );
					getObj('RCRITERIGrid_'+i+'_PunteggioMax_V').focus();
					return -1;	
				}					
				totpunteggiorighe=totpunteggiorighe+parseFloat(getObjValue('RCRITERIGrid_'+i+'_PunteggioMax'));
				if (getObjValue('RCRITERIGrid_'+i+'_DescrizioneCriterio')=='')
				{
					DocShowFolder( 'FLD_CRITERI' );	   
					tdoc();
					DMessageBox( '../' , 'Sulla griglia Criteri di valutazione busta tecnica inserire una descrizione su ogni riga' , 'Attenzione' , 1 , 400 , 300 );
					getObj('RCRITERIGrid_'+i+'_DescrizioneCriterio').focus();
					return -1;
				}
				if(getObjValue('RCRITERIGrid_'+i+'_CriterioValutazione') == 'quiz')
				{
					if(getObjValue('RCRITERIGrid_'+i+'_AttributoCriterio') == '')
					{
						DocShowFolder( 'FLD_CRITERI' );	   
						tdoc();
						DMessageBox( '../' , 'Sulla griglia Criteri di valutazione busta tecnica selezionare un valore per la colonna attributo se il criterio e\' quiz.' , 'Attenzione' , 1 , 400 , 300 );
						getObj('RCRITERIGrid_'+i+'_AttributoCriterio').focus();
						return -1;
					}
					else
					{
						for(k=0;k<i;k++)
						{
							if(getObjValue('RCRITERIGrid_'+k+'_AttributoCriterio') == getObjValue('RCRITERIGrid_'+i+'_AttributoCriterio') )
							{
								DocShowFolder( 'FLD_CRITERI' );	   
								tdoc();
								DMessageBox( '../' , 'Sulla griglia Criteri di valutazione busta tecnica l\'attributo deve essere univoco.' , 'Attenzione' , 1 , 400 , 300 );
								getObj('RCRITERIGrid_'+i+'_AttributoCriterio').focus();
								return -1;	
							}
						}
					}
				}
				
				
			}
			if( PunteggioTecnico != totpunteggiorighe )
			{
				DocShowFolder( 'FLD_CRITERI' );	   
				tdoc();
				DMessageBox( '../' , 'Il Punteggio Tecnico deve essere uguale alla somma dei punteggi presenti sulle righe. ' , 'Attenzione' , 1 , 400 , 300 );
				return -1;
			}
		}
		
		if( getObj('FormulaEcoSDA').value.indexOf( ' Coefficiente X ' ) >= 0 &&  getObj('Coefficiente_X').value == '')
		{
			DocShowFolder( 'FLD_CRITERI' );	   
			tdoc();
			DMessageBox( '../' , 'Per la formula selezionata e\' necessario indicare un valore per il Coefficiente X' , 'Attenzione' , 1 , 400 , 300 );
			getObj('Coefficiente_X').focus();
			return -1;
		
		}
		
		if( getObj('FormulaEcoSDA').value.indexOf( ' Alfa ' ) >= 0 &&  getObj('Alfa').value == '')
		{
			DocShowFolder( 'FLD_CRITERI' );	   
			tdoc();
			DMessageBox( '../' , 'Per la formula selezionata e\' necessario indicare un valore per il Coefficiente X' , 'Attenzione' , 1 , 400 , 300 );
			getObj('Alfa_V').focus();
			return -1;
		
		}

		
  }
    		
    var numrowlotto=-1;
    var z=0;
	
  //-- SOLO GARE CHE PREVEDONO I PRODOTTI
  if (  //-- non deve essere "ristretta bando" o "negoziata avviso"
          !( getObjValue( 'ProceduraGara' ) == '15477' && getObjValue( 'TipoBandoGara' )  == '2')//-- ristretta Bando
          &&
          !(getObjValue( 'ProceduraGara' ) == '15478' && getObjValue( 'TipoBandoGara' )  == '1') //-- negoziata avviso
      )
  {
  
  
    //-- divisione_lotti <> 0 non è monolotto 
    try{
        if ( getObjValue( 'Divisione_lotti' ) != '0' )
            numrowlotto=GetProperty( getObj('LISTA_BUSTEGrid') , 'numrow');
  	}
  	catch( e ) {}
  		
  		
    for(z=0;z<=numrowlotto;z++)
    {
    	
    	//commentato perchè adesso ilpunteggio tecnico potrebbe essere specializzato e la vista ritorna sempre quello del bando 
      //if ( !isNaN(parseFloat(getObjValue('RLISTA_BUSTEGrid_'+z+'_somma_punt_lotto'))) && parseFloat(getObjValue('RLISTA_BUSTEGrid_'+z+'_somma_punt_lotto')) != PunteggioTecnico ) 
    	//alert(getObjValue('val_RLISTA_BUSTEGrid_'+z+'_Criteri_di_valutaz'));
      if ( getObjValue('val_RLISTA_BUSTEGrid_'+z+'_Criteri_di_valutaz') == 'valutato_err' )
    	{
    		DocShowFolder( 'FLD_LISTA_LOTTI' );	   
    		tdoc();
    		//DMessageBox( '../' , 'Sono presenti dei lotti con un punteggio sbagliato' , 'Attenzione' , 1 , 400 , 300 );
    		DMessageBox( '../' , 'Sono presenti dei lotti non compilati correttamente' , 'Attenzione' , 1 , 400 , 300 );
    		return -1;
    	}
    }
  	
  
	//se ModalitadiPartecipazione non è tradizionale 16307 faccio i controlli sui prodotti
	if ( getObj('ModalitadiPartecipazione').value != '16307' )
	{
		if( GetProperty( getObj('PRODOTTIGrid') , 'numrow')==-1)
		{
			
			DocShowFolder( 'FLD_PRODOTTI' );	   
			tdoc();
			DMessageBox( '../' , 'Compilare correttamente la sezione dei prodotti' , 'Attenzione' , 1 , 400 , 300 );
			return -1;
		}	
	}
  	if( GetProperty( getObj('RIFERIMENTIGrid') , 'numrow')==-1)
  	{
  		
      DocShowFolder( 'FLD_RIFERIMENTI' );	   
      tdoc();
      DMessageBox( '../' , 'Compilare correttamente la sezione dei Riferimenti' , 'Attenzione' , 1 , 400 , 300 );
      return -1;
  		
  	}	
  	
  	//se ModalitadiPartecipazione non è tradizionale 16307 faccio i controlli sui prodotti
	if ( getObj('ModalitadiPartecipazione').value != '16307' )
	{
		if( getObjValue('TipoBando') == '' )
		{
			
			DocShowFolder( 'FLD_PRODOTTI' );	   
			tdoc();
			DMessageBox( '../' , 'Compilare correttamente la sezione dei prodotti' , 'Attenzione' , 1 , 400 , 300 );
			return -1;
		}
	}	
  	
  }

 	if( getObjValue( 'UserRUP' ) == '' )
	{
	    DocShowFolder( 'FLD_COPERTINA' );	   
		tdoc();
		DMessageBox( '../' , 'Compilare il campo R.U.P.' , 'Attenzione' , 1 , 400 , 300 );
		return -1;
	
	}

    var dateObj = new Date();
    var Riferimento = zero( dateObj.getFullYear(),4) + '-' + zero( (dateObj.getMonth()+1),2) + '-' + zero(dateObj.getDate(),2);
	
	//-- controllo le date in coerenza con la tipologia di documento
    if (  getObjValue( 'ProceduraGara' ) == '15478' && getObjValue( 'TipoBandoGara' )  == '4' ) //-- Negoziata - Avviso con risposta
    {
        if(  CheckData( 'DataRiferimentoInizio' , Riferimento , 'Compilare Inizio Presentazioni Manifestazione di Interesse'  , 'Inizio Presentazioni Manifestazione di Interesse deve essere maggiore di oggi' ) == -1 ) return -1;
        if(  CheckData( 'DataTermineQuesiti' , getObjValue( 'DataRiferimentoInizio' ) , 'Compilare Termine Richiesta Quesiti'  , 'Termine Richiesta Quesiti deve essere maggiore di Inizio Presentazioni Manifestazione di Interesse' ) == -1 ) return -1;
        if(  CheckData( 'DataScadenzaOfferta' , getObjValue( 'DataTermineQuesiti' ) , 'Compilare Termine Presentazione Manifestazione di Interesse'  , 'Termine Presentazione Manifestazione di Interesse deve essere maggiore di Termine Richiesta Quesiti' ) == -1 ) return -1;

    }
    else if (  getObjValue( 'ProceduraGara' ) == '15478' && getObjValue( 'TipoBandoGara' )  == '1' ) //-- Negoziata - Avviso 
    {

        if(  CheckData( 'DataTermineQuesiti' ,Riferimento , 'Compilare Termine Richiesta Quesiti'  , 'Termine Richiesta Quesiti deve essere maggiore di oggi' ) == -1 ) return -1;
        //if(  CheckData( 'DataAperturaOfferte' , getObjValue( 'DataTermineQuesiti' ) , 'Compilare Data Presunta Pubblicazione Invito'  , 'Data Presunta Pubblicazione Invito deve essere maggiore di Termine Richiesta Quesiti' ) == -1 ) return -1;
    
        //-- riporta la data apertura sulla data scadenza che risulta nascosta
        //getObj( 'DataScadenzaOfferta' ).value = getObj( 'DataAperturaOfferte' ).value;

    }    
    else  if (  getObjValue( 'ProceduraGara' ) == '15477' && getObjValue( 'TipoBandoGara' )  == '2' ) //-- Ristretta - Bando
    {

        if(  CheckData( 'DataRiferimentoInizio' , Riferimento , 'Compilare Inizio Presentazioni Domanda di Partecipazione'  , 'Inizio Presentazioni Domanda di Partecipazione deve essere maggiore di oggi' ) == -1 ) return -1;
        if(  CheckData( 'DataTermineQuesiti' , getObjValue( 'DataRiferimentoInizio' ) , 'Compilare Termine Richiesta Quesiti'  , 'Termine Richiesta Quesiti deve essere maggiore di Inizio Presentazioni Domanda di Partecipazione' ) == -1 ) return -1;
        if(  CheckData( 'DataScadenzaOfferta' , getObjValue( 'DataTermineQuesiti' ) , 'Compilare Termine Presentazione Domanda di Partecipazione'  , 'Termine Presentazione Domanda di Partecipazione deve essere maggiore di Termine Richiesta Quesiti' ) == -1 ) return -1;
       //if(  CheckData( 'DataAperturaOfferte' , getObjValue( 'DataScadenzaOfferta' ) , 'Compilare Data Prima Seduta'  , 'Data Prima Seduta deve essere maggiore di Termine Presentazione Domanda di Partecipazione' ) == -1 ) return -1;

    }    
    else  //-- per i restanti casi
    {

        if(  CheckData( 'DataRiferimentoInizio' , Riferimento , 'Compilare Inizio Asta'  , 'Inizio Asta deve essere maggiore di oggi' ) == -1 ) return -1;
        //if(  CheckData( 'DataTermineQuesiti' , getObjValue( 'DataRiferimentoInizio' ) , 'Compilare Termine Richiesta Quesiti'  , 'Termine Richiesta Quesiti deve essere maggiore di Inizio Presentazioni Offerte' ) == -1 ) return -1;
        if(  CheckData( 'DataScadenzaOfferta' , getObjValue( 'DataTermineQuesiti' ) , 'Compilare Chiusura Asta Prevista'  , 'Chiusura Asta Prevista deve essere maggiore di Termine Richiesta Quesiti' ) == -1 ) return -1;
        //if(  CheckData( 'DataAperturaOfferte' , getObjValue( 'DataScadenzaOfferta' ) , 'Compilare Data Prima Seduta'  , 'Data Prima Seduta deve essere maggiore di Termine Presentazione Offerta' ) == -1 ) return -1;

    }    
      //controllo che siano presenti le motivazioni per un appalto verde oppure per un acquisto sociale
			try
			{
				if ( getObjValue( 'Appalto_Verde' ) == 'si')
				{
					if ( getObjValue( 'Motivazione_Appalto_Verde' ) == '')
					{	
						DocShowFolder( 'FLD_COPERTINA' );	   
						tdoc();
						DMessageBox( '../' , 'Per un bando con "Appalto Verde" indicare una motivazione' , 'Attenzione' , 1 , 400 , 300 );
						getObj('Motivazione_Appalto_Verde').focus();
						return -1;
					}
				}	
			}catch(e){}  
			try
			{
				if ( getObjValue( 'Acquisto_Sociale' ) == 'si')
				{
					if ( getObjValue( 'Motivazione_Acquisto_Sociale' ) == '')
					{	
						DocShowFolder( 'FLD_COPERTINA' );	   
						tdoc();
						DMessageBox( '../' , 'Per un bando con "Acquisto_Sociale" indicare una motivazione' , 'Attenzione' , 1 , 400 , 300 );
						getObj('Motivazione_Acquisto_Sociale').focus();
						return -1;
					}
				}	
			}catch(e){}  			
		
		  

	//ExecDocProcess(param);
}

function CheckData( FieldData , Riferimento , msgVuoto , msgMinoreRif )
{
    if( getObjValue( FieldData ) == '' )
    {
 	    DocShowFolder( 'FLD_COPERTINA' );	   
  		tdoc();
        try{ getObj( FieldData + '_V' ).focus(); }catch( e ) {};
        DMessageBox( '../' , msgVuoto , 'Attenzione' , 1 , 400 , 300 );
        return -1;       
	}

    if( getObjValue( FieldData ) <= Riferimento )
    {
 	    DocShowFolder( 'FLD_COPERTINA' );	   
  		tdoc();
        try{ getObj( FieldData + '_V' ).focus(); }catch( e ){};
        DMessageBox( '../' , msgMinoreRif , 'Attenzione' , 1 , 400 , 300 );
        return -1;       
    }
    
    return 0;
}


function OpenSeduta(objGrid , Row , c) 
{
    var cod = getObj( 'R' + Row + '_idSeduta').value;

    GridSecOpenDoc(objGrid , Row , c) 
    
}

function ChangeImpAppalto( obj )
{
    var Oneri = Number( getObj( 'Oneri' ).value ) ;
    var importoBaseAsta2 = Number( getObj( 'importoBaseAsta2' ).value ) ;
   var Opzioni = Number( getObj( 'Opzioni' ).value ) ;
    
    SetNumericValue( 'importoBaseAsta' , Oneri + importoBaseAsta2 + Opzioni );

}

function ChangeTipoAsta( obj ) 
{
    var CriterioAggiudicazione = getObjValue( 'CriterioAggiudicazioneGara' );  
    var CriterioFormulazioneOfferte = getObjValue( 'CriterioFormulazioneOfferte' );
	   
	 var ValoreTipoAsta = '' ;
	 var ValoreTipoAstaDESC = '' ;
	
	if ( CriterioAggiudicazione == '15532' || CriterioAggiudicazione == '25532' )
	{
		ValoreTipoAsta = 'TA_OEV';
		
	}
	else
	{
		if ( CriterioFormulazioneOfferte == '15537' ) //-- Percentuale
		{
			ValoreTipoAsta = 'TA_Sconto';
		}
		
		if( CriterioFormulazioneOfferte == '15536' ) //-- Prezzo
		{
			ValoreTipoAsta = 'TA_Prezzo';
		}
		
	}
  ValoreTipoAstaDESC=CNV( pathRoot ,ValoreTipoAsta );
 // getObj('TipoAsta').value=ValoreTipoAsta;
  //getObj('val_TipoAsta').childNodes[0].nodeValue = CNV( pathRoot ,ValoreTipoAsta ) + '<input type="hidden" name="TipoAsta"  id="TipoAsta"  value="" />';
  //getObj('val_TipoAsta').innerHTML = CNV( pathRoot ,ValoreTipoAsta ) + '<input type="hidden" name="TipoAsta"  id="TipoAsta"  value="' + ValoreTipoAsta + '" />';
  //getObj('TipoAsta').value = ValoreTipoAsta ;
  SetDomValue( 'TipoAsta', ValoreTipoAsta,ValoreTipoAstaDESC );
  
}


function DisplaySection( obj )
{
	
	ChangeTipoAsta( obj );
	
    var crit = getObjValue( 'CriterioAggiudicazioneGara' );
    var conf = getObjValue( 'Conformita' );
 /*   
    //-- se è privista la conformita Ex-Ante oppure è economicamente più vantaggiosa
    if( conf == 'Ex-Ante' || crit == '15532' )
    {
        DocDisplayFolder(  'ECONOMICA'   ,'none' );
        DocDisplayFolder(  'LISTA_LOTTI' ,'' );
//        if( crit == '15532')
//        {        
//            ShowCol( 'LISTA_BUSTE' , 'FNZ_QUOT' , '' )
//            ShowCol( 'LISTA_BUSTE' , 'FNZ_CONTROLLI'  , '' )
//        }
//        else
//        {        
//            ShowCol( 'LISTA_BUSTE' , 'FNZ_QUOT' , 'none' )
//            ShowCol( 'LISTA_BUSTE' , 'FNZ_CONTROLLI'  , 'none' )
//        }



    }
    else
    {
        DocDisplayFolder(  'ECONOMICA'   ,'' );
        DocDisplayFolder(  'LISTA_LOTTI' ,'none' );
    }
 */
 
    //--  nel caso di economicamente vantaggiosa si filtra la conformità
    var Conformita = getObj( 'Conformita' );
 
    
    //gestione commentata per le gare miste
    if( crit == '15532' ||  crit == '25532' )
    {
        DocDisplayFolder(  'CRITERI'   ,'' );
        //try{ShowCol( 'LISTA_BUSTE' , 'Criteri_di_valutaz'  , '' );}catch(e){};
        

//        Conformita.value = 'No' ;
//        Conformita.disabled = true;
    }
    else
    {
        DocDisplayFolder(  'CRITERI'   ,'none' );
        //try{ShowCol( 'LISTA_BUSTE' , 'Criteri_di_valutaz'  , 'none' );}catch(e){};

//        Conformita.disabled = false;
    }




    if ( getObjValue ( 'TipoBandoGara') == '3' )
    {
       //DocDisplayFolder(  'DESTINATARI'   ,'' );
       
       var StatoFunzionale = getObjValue( 'StatoFunzionale' );
       if ( StatoFunzionale == 'InLavorazione' )
       {
            //alert(getObjValue( 'ProceduraGara' ));
			       if( getObjValue( 'ProceduraGara' ) == '15477' )//la  ristretta prevede solo gli OE che hanno fatto domanda di partecipazione
            {
			        setVisibility( getObj('DESTINATARI_1') , 'none' );
            }
            
            //-- se non esiste il documento di avviso nascondo i partecipanti dell'avviso
            if( getObjValue( 'LinkedDoc' ) == '' ||  getObjValue( 'LinkedDoc' ) == '0' )
            {
              try{setVisibility( getObj('DESTINATARI_2') , 'none' );}catch(e){}
            }
            
       
       }
       else
       {
            try{setVisibility( getObj('DESTINATARI_2') , 'none' );}catch(e){}
       }
       
       
    }
	/*
    else
    {
       DocDisplayFolder(  'DESTINATARI'   ,'none' );
    }
    */


}



function DownLoadCSV()
{

    var TipoBando = getObjValue( 'TipoBando' );
    
    if ( TipoBando == '' )
    {
      alert( CNV( pathRoot,'E\' necessario selezionare prima il modello'));
      return ;
    }
   
	ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + getObjValue('IDDOC') + '&TIPODOC=BANDO_GARA&MODEL=MODELLI_LOTTI_' + TipoBando + '_MOD_BANDO_LOTTI&HIDECOL=ESITORIGA'  , '_blank' ,'');
    
}


function OpenEconomica(objGrid , Row , c) 
{
	var cod;
	try
	{
		cod = getObj( 'R' + Row + '_id').value;
	}catch( e ) 
	{
		cod = getObj( 'RLISTA_BUSTEGrid_' + Row + '_id').value;
	}

    ShowDocumentPath( 'BANDO_SEMP_OFF_ECO' , cod ,'../');
    
}

function OpenTecnica(objGrid , Row , c) 
{
	var cod;
	try
	{
		cod = getObj( 'R' + Row + '_id').value;
	}catch( e ) 
	{
		cod = getObj( 'RLISTA_BUSTEGrid_' + Row + '_id').value;
	}

    ShowDocumentPath( 'BANDO_SEMP_OFF_TEC' , cod ,'../');
    
}

function OpenCriteri(objGrid , Row , c) 
{
    if( flag == 1 )
	{
			if( confirm(CNV( pathRoot,'Sono state effettuare delle modifiche al documento prima di procedere e richiesto un salvataggio.Vuoi procedere?')))
			{
			SaveDoc();
			return;
			}
			else return -1;
	}
	var cod = getObj( 'RLISTA_BUSTEGrid_' + Row + '_id').value;

    
    if ( isSingleWin() == true ) 
    {
        ReloadDocFromDB( cod , 'BANDO_SEMP_OFF_EVAL' );
        ShowDocument( 'BANDO_SEMP_OFF_EVAL' , cod );
    }
    else
    {
        ReloadDocFromDB( cod , 'BANDO_SEMP_OFF_EVAL' );
        ShowDocumentPath( 'BANDO_SEMP_OFF_EVAL' , cod ,'../');
    }
}



function EditCriterio( objGrid , Row , c )
{
    if(  getObjValue( 'RCRITERIGrid_' + Row + '_CriterioValutazione' ) == 'quiz'  )
    {
        
        //recupero TipoGiudizioTecnico
        var TipoGiudizioTecnico  ='';
        try{
          var TipoGiudizioTecnico  = getObj( 'TipoGiudizioTecnico').value;
        }catch(e){};
        
        if( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' )
        {
            Open_Quiz( '../' , 'RCRITERIGrid_' + Row + '_Formula' , 'C' , getObjValue('RCRITERIGrid_' + Row + '_DescrizioneCriterio') , TipoGiudizioTecnico );
        }
        else
        {
            Open_Quiz( '../' , 'RCRITERIGrid_' + Row + '_Formula' , 'V' , getObjValue('RCRITERIGrid_' + Row + '_DescrizioneCriterio') , TipoGiudizioTecnico );
        }
        
    }
    
    
}


function CRITERI_OnLoad()
{

	//alert('criteri on load');
	
    FilterDominio();
    
    //--filtro il dominio CriterioFormulazioneOfferte in funzione dei criteri espressi sul modello selezionato
    //FilterDom(  'CriterioFormulazioneOfferte' , 'CriterioFormulazioneOfferte' , getObjValue( 'CriterioFormulazioneOfferte' ), 'SQL_WHERE= tdrcodice in ( select CriterioFormulazioneOfferte  from Document_Modelli_MicroLotti_Formula where Codice =  \'' + getObjValue( 'TipoBando' ) + '\' ) ' , '' , '')

    //-- abilito il coefficiente X in funzione della formula
    OnChangeFormula(this);

}

function CRITERI_AFTER_COMMAND( param )
{
    FilterDominio();
}

function OnChangeCriterio( obj )
{
    try
    {
        var i = obj.id.split('_');

        //FilterDom(  'RCRITERIGrid_' + i[1] + '_AttributoCriterio' , 'AttributoCriterio' , getObjValue( 'RCRITERIGrid_' + i[1] + '_AttributoCriterio' ), 'SQL_WHERE= TipoBando = \'' + getObjValue( 'TipoBando' ) + '\' and DZT_NAME = \'MOD_OffertaTec\' and DZT_Type not in ( 18 ) ' , 'CRITERIGrid_' + i[1]  , '')

        if( getObjValue(  'RCRITERIGrid_' + i[1] + '_CriterioValutazione' ) == 'quiz' )
        {
              setVisibility( getObj( 'RCRITERIGrid_' + i[1] + '_AttributoCriterio' ) , '' );
              setVisibility( getObj( 'RCRITERIGrid_' + i[1] + '_FNZ_OPEN' ) , '' );   

              try{
                
                //disabilito il punteggio solo se la tipologia di giudizio è a dominio 
                var TipoGiudizioTecnico  ='';
                
                try{
                  var TipoGiudizioTecnico  = getObj( 'TipoGiudizioTecnico').value;
                }catch(e){};
                
                if ( TipoGiudizioTecnico != 'domain')
                  getObj( 'RCRITERIGrid_' + i[1] + '_PunteggioMax_V' ).disabled = true; 
                
              }catch(e){};
              AggiornaCriteriTecnici( 'RCRITERIGrid_' + i[1] + '_Formula' , '' , '' );

            FilterDom(  'RCRITERIGrid_' + i[1] + '_AttributoCriterio' , 'AttributoCriterio' , getObjValue( 'RCRITERIGrid_' + i[1] + '_CampoTesto_1' ), 'SQL_WHERE= TipoBando = \'' + getObjValue( 'TipoBando' ) + '\' and DZT_NAME = \'MOD_OffertaTec\' and DZT_Type not in ( 18 ) ' , 'CRITERIGrid_' + i[1]  , '')

        }
        else
        {
              setVisibility( getObj( 'RCRITERIGrid_' + i[1] + '_AttributoCriterio' ) , 'none' );
              setVisibility( getObj( 'RCRITERIGrid_' + i[1] + '_FNZ_OPEN' ) , 'none' );
              
              try{ 
                getObj( 'RCRITERIGrid_' + i[1] + '_PunteggioMax_V' ).disabled = false; 
              }catch(e){};


        }
    }catch( e ){};

    flagmodifica();

	//FilterDominio();
}

function FilterDominio()
{
    //-- per tutte le righe definisco il filtro sul dominio e la presenza del comando per aprire il dialogo
    var n = 100//-- numero righe
    var i;
    
    try{

		var statFunz;
		var statFunzVal;
		
		try
		{
			//Se FilterDominio() viene chiamato dall'iframe dei comandi non avremo il campo statoFunzionale.
			//quindi assumo un default 'InLavorazione'
			statFunz = getObj('StatoFunzionale').value;
		}
		catch(e)
		{
			statFunz = 'InLavorazione';
		}

	
		for( i = 0 ; i < n && getObj( 'RCRITERIGrid_' + i + '_CriterioValutazione' ) != null ; i++ )
		{
			if( statFunz == 'InLavorazione' && getObjValue( 'RCRITERIGrid_' + i + '_CriterioValutazione' ) == 'quiz' ) 
			{
				FilterDom(  'RCRITERIGrid_' + i + '_AttributoCriterio' , 'AttributoCriterio' , getObjValue( 'RCRITERIGrid_' + i + '_CampoTesto_1' ), 'SQL_WHERE= TipoBando = \'' + getObjValue( 'TipoBando' ) + '\' and DZT_NAME = \'MOD_OffertaTec\' and DZT_Type not in ( 18 ) ' , 'CRITERIGrid_' + i  , '')
			}
						
			if( getObjValue( 'RCRITERIGrid_' + i + '_CriterioValutazione' ) == 'quiz' )
			{
				  try{ setVisibility( getObj( 'RCRITERIGrid_' + i + '_AttributoCriterio' ) , '' ); }catch(e){};
				  setVisibility( getObj( 'RCRITERIGrid_' + i + '_FNZ_OPEN' ) , '' );
				  
				  var TipoGiudizioTecnico  ='';
			
				  try{
					var TipoGiudizioTecnico  = getObj( 'TipoGiudizioTecnico').value;
				  }catch(e){};
			
				 try{ 
					if ( TipoGiudizioTecnico != 'domain')
					  getObj( 'RCRITERIGrid_' + i + '_PunteggioMax_V' ).disabled = true; 
				  }catch(e){};
			}
			else
			{
				  try{ setVisibility( getObj( 'RCRITERIGrid_' + i + '_AttributoCriterio' ) , 'none' ); }catch(e){};
				  setVisibility( getObj( 'RCRITERIGrid_' + i + '_FNZ_OPEN' ) , 'none' );

			}
		
		}
        
    }
	catch(e)
	{ 
		//alert( 'error ' + e);
	}
}


function OnChangeFormula( obj )
{
    
    SetTextValue( 'FormulaEconomica' ,  getObj('FormulaEcoSDA').value);
    if( getObj('FormulaEcoSDA').value.indexOf( ' Coefficiente X ' ) >= 0 )
    {
        getObj('Coefficiente_X').style.display='';
		getObj('cap_Coefficiente_X').style.display='';
		//getObj('Coefficiente_X').disabled = false;
		
    }
    else
    {
        
		getObj('Coefficiente_X').style.display='none';
		getObj('cap_Coefficiente_X').style.display='none';
		getObj('Coefficiente_X').value = '';
		//getObj('Coefficiente_X').disabled = true;

    }
	
	/* GESTIONE DELLA COSTANTE ALFA */
	if( getObj('FormulaEcoSDA').value.indexOf( ' Alfa ' ) >= 0 )
	{
	
		getObj('Alfa_V').style.display = '';
		getObj('cap_Alfa').style.display = '';
	} 
	else 
	{

		getObj('Alfa_V').style.display = 'none';
		getObj('cap_Alfa').style.display = 'none';
		getObj('Alfa_V').value = '';
		getObj('Alfa').value = '';

	}
    
  
}


//-- determino il punteggio massimo del criterio oggettivo
function AggiornaCriteriTecnici( strField , p1 , p2 )
{
    var obj = getObj( strField );
    var R = strField.split( '_' );
    var M = 0;
    var i;

    try{    
        var v = obj.value.split( '#=#' )[2].split( '#~#' )
    var l = v.length;
        for( i = 3 ; i < l ; i += 4 )
        {
            if( Number( v[i] ) > M ) M = Number( v[i] ) ;
        }
    }catch(e){};
    
    //aggiorno il punteggio solo se tipogiudiziotecnico è edit
    var TipoGiudizioTecnico  ='';
    try{
      var TipoGiudizioTecnico  = getObj( 'TipoGiudizioTecnico').value;
    }catch(e){};
    
    
    if ( TipoGiudizioTecnico != 'domain')
      SetNumericValue( R[0] + '_' + R[1] + '_PunteggioMax' , M );


}

function PrintAndSend(param)
{
	//avvalora Dataprimaseduta se RDO
	if( getObj( 'TipoProceduraCaratteristica' ).value == 'RDO' )
    {
		try{ 
				getObj( 'DataAperturaOfferte' ).value = getObj( 'DataScadenzaOfferta' ).value.substr(0,17)+'01';
			}
			catch(e){};
	}	
	
	
    if( ControlliSend( param ) == -1 ) return -1;

	ShowWorkInProgress(true);
	
	ToPrint(param);
}



//-- 0 -- no
//-- 1 -- Dopo la soglia di sbarramento
//-- 2 -- Prima della soglia di sbarramento
function OnChange_Riparametrazione( obj )
{
    try{
        if( getObjValue( 'PunteggioTEC_100' ) <= '0' )
        {
            //-- se non viene chiesta la riparametrazione si nasconde il criterio    
            setVisibility( getObj( 'PunteggioTEC_TipoRip' ), 'none' );
            setVisibility( getObj( 'cap_PunteggioTEC_TipoRip' ), 'none' );
        
        }
        else
        {
            setVisibility( getObj( 'PunteggioTEC_TipoRip' ), '' );
            setVisibility( getObj( 'cap_PunteggioTEC_TipoRip' ), '' );
            if( getObjValue( 'PunteggioTEC_TipoRip' ) < 1  )
            {
                getObj( 'PunteggioTEC_TipoRip' ).value = '1';
            }
        }
    }catch(e){};    
}

function onChangeCalcoloSoglia(obj)
{
	try
	{
		if (  getObjValue( 'CalcoloAnomalia' ) != '1' )
		{
			getObj( 'OffAnomale').value='';
			getObj( 'OffAnomale').disabled=true;
		}
		else
		{
			getObj( 'OffAnomale').disabled=false;
		}
	}
	catch(e)
	{
	}
}

//-- 1 - Riparametro per punteggio Lotto
//-- 2 - Riparametro per punteggio parametro
//-- 3 - Riparametro per punteggio parametro e per punteggio Lotto
function OnChange_RiparametrazioneCriterio( obj )
{
    if( getObjValue( 'PunteggioTEC_TipoRip' ) < 1 )
    {
        getObj( 'PunteggioTEC_TipoRip' ).value = '1';
    }
}

function AddProdotto( )
{
	var strCommand = 'PRODOTTI#ADDFROM#IDROW=' + getObjValue( 'IDDOC' ) + '&TABLEFROMADD=DOCUMENT_ADD_PRODOTTO' 

    ExecDocCommand( strCommand );
	
}

function UpdateModelloBando()
{
    var TipoBando = getObjValue( 'TipoBando' );
	var cod=getObjValue( 'id_modello' );
	var docReadonly = getObjValue( 'DOCUMENT_READONLY' );
	
    if ( TipoBando == '' || cod == '' )
    {
		DMessageBox( '../' , 'E\' necessario selezionare prima il modello' , 'Attenzione' , 1 , 400 , 300 );
		return;
	}

	//Se il documento non è readonly l'apertura del documento CONFIG_MODELLI_LOTTI la posticipiamo al reload del documento, nell'after process
	if ( docReadonly == '1' )
		ShowDocumentPath( 'CONFIG_MODELLI_LOTTI' , cod ,'../');
	else
		ExecDocProcess( 'FITTIZIO,DOCUMENT,,NO_MSG');

}

function afterProcess( param )
{
	if ( param == 'FITTIZIO' )
    {
		var cod=getObjValue( 'id_modello' );
		ShowDocumentPath( 'CONFIG_MODELLI_LOTTI' , cod ,'../');
	}
}

function OnChangeListaAlbi()
{
	DisableObj( 'ClasseIscriz' , false );
	ExecDocProcess( 'CHANGE_LISTA_ALBI,BANDO_GARA,,NO_MSG');
}

function OnChangeDataTermineQuesiti()
{
  var dateObj = new Date();
  var Riferimento = zero( dateObj.getFullYear(),4) + '-' + zero( (dateObj.getMonth()+1),2) + '-' + zero(dateObj.getDate(),2);
	
  if(  CheckData( 'DataTermineRispostaQuesiti' , Riferimento , 'Compilare Data Termine Risposta Quesiti'  , 'Data Termine Risposta Quesiti deve essere maggiore di oggi' ) == -1 ) return -1;
  if(  CheckData( 'DataScadenzaOfferta' , getObjValue( 'DataTermineRispostaQuesiti' ) , 'Compilare Chiusura Asta Prevista'  , 'Data Termine Risposta Quesiti deve essere minore di Chiusura Asta Prevista' ) == -1 ) return -1;
	
}
function OnChangeDataScadenzaOfferta()
{
	var dateObj = new Date();
	var Riferimento = zero( dateObj.getFullYear(),4) + '-' + zero( (dateObj.getMonth()+1),2) + '-' + zero(dateObj.getDate(),2);

	if(  CheckData( 'DataScadenzaOfferta' , Riferimento , 'Compilare Chiusura Asta Prevista'  , 'Chiusura Asta Prevista deve essere maggiore di oggi' ) == -1 ) return -1;
	if(  CheckData( 'DataScadenzaOfferta' , getObjValue( 'DataTermineRispostaQuesiti' ) , 'Compilare Data Termine Risposta Quesiti'  , 'Chiusura Asta Prevista deve essere maggiore di Data Termine Risposta Quesiti' ) == -1 ) return -1;

}

//per nascondere il contenuto della colonna Busta Tecnica per quei lotti che non ne hanno bisogno
function HideBustaTecnicaLotti(){

  //-- divisione_lotti <> 0 non è monolotto 
    var numrowlotto=-1;
    
    try{
        if ( getObjValue( 'Divisione_lotti' ) != '0' )
            numrowlotto=GetProperty( getObj('LISTA_BUSTEGrid') , 'numrow');
  	}
  	catch( e ) {}
  		
  		
    for(z=0;z<=numrowlotto;z++)
    {
      if ( getObjValue('RLISTA_BUSTEGrid_' + z + '_PresenzaBustaTecnica') == '0' )
    	{
    		
    		getObj('LISTA_BUSTEGrid_r'+ z + '_c3').innerHTML='';
    		
    	}
    }

}

function OnChangeAlfa(obj) 
{
	var idAlfa = obj.id.replace('_V','');
	var alfa = getObjValue(idAlfa);

	if ( alfa != '' )
	{
		var numberAlfa = parseFloat(alfa);
			
		/* ACCETTO VALORI > DI 0 E <> DA 1 */
		if ( numberAlfa <= 0 || numberAlfa == 1 )
		{
			obj.value = '';
			getObj(idAlfa).value = '';
			DMessageBox( '../' , 'La costante alfa deve essere un valore maggiore di 0 e diverso da 1' , 'Attenzione' , 1 , 400 , 300 );
		}
		
		
	}
	
}


function RIFERIMENTI_AFTER_COMMAND( param )
{
  FilterRiferimenti();
}

function FilterRiferimenti(){
	
	
	var filterUser = '';	
	var i;
	var numrighe=GetProperty( getObj('RIFERIMENTIGrid') , 'numrow');

	
	
	
	filterUser = 'SQL_WHERE= idpfu in ( select idpfu from RiferimentiForBando where DOC_ID = \'BANDO_SEMPLIFICATO\'  and  OWNER = <ID_USER> )';
	
	
	try
	{
		
		for( i = 0 ; i < numrighe+1 ; i++ )
		{
		

			try
			{
				//AGGIUNGO IL FILTRO QUANDO LA RIGA E' ReferenteTecnico per mostrare  gli utenti con il profilo di ReferenteTecnico di tutte le aziende
				if ( getObjValue( 'RRIFERIMENTIGrid_' + i + '_RuoloRiferimenti' ) == 'ReferenteTecnico' )
				{
					filterUser = 'SQL_WHERE= idpfu in ( select ID_FROM from USER_DOC_PROFILI_FROM_UTENTI where profilo =\'Referente_Tecnico\' )';
				}
				else
				{				
					filterUser = 'SQL_WHERE= idpfu in ( select idpfu from RiferimentiForBando where DOC_ID = \'BANDO_ASTA\'  and  OWNER = <ID_USER> )';
				}
				
				FilterDom(  'RRIFERIMENTIGrid_' + i + '_IdPfu' , 'IdPfu' , getObjValue( 'val_RRIFERIMENTIGrid_' + i + '_IdPfu' ), filterUser , 'RIFERIMENTIGrid_' + i  , '')
			}
			catch(e)
			{
			}

		}
		
	}catch(e){};

}