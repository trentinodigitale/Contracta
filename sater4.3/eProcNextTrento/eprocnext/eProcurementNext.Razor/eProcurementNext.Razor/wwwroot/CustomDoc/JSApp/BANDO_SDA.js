window.onload = OnLoadPage; 

function OnLoadPage()
{

	//cambia la tooltip della matita per Aprire il dettaglio del modello	
	var tmpMlg = '';
	try
	{
		tmpMlg = CNV( pathRoot ,'Modifica Modello Gara');
		getObj('FNZ_UPD_link').firstChild.alt= tmpMlg;
		getObj('FNZ_UPD_link').firstChild.title=tmpMlg;	
	}catch(e){};
	//versione_sda se = 2 sono nella versione 2016 dello sda
	try
	{
		if ( getObj('Versione').value == '2' || getObj('Versione').value == 'IC' || getObj('Versione').value == '3' || getObj('Versione').value == 'RP' )
		{
			if (getObj('Elenco_Categorie_Merceologiche').value == '')
				SelectreadOnly( 'Livello_Categorie_Merceologiche' , true );
			if (getObj('Livello_Categorie_Merceologiche').value == '')
				getObj('Categorie_Merceologiche_button').style.display='none';	
			
			OnchangeLivello();
			OnchangeElenco();
			
		}
	}catch(e){};
	
	
	try
	{
		if( getObjValue( 'DOCUMENT_READONLY') == '0' )
			getObj('PresenzaDGUE' ).onchange = DGUE_Request_Active;
	}catch(e){}
	
	try
	{
		if ( getObjValue( 'DGUEAttivo') != 'si' )
		{
			document.getElementById('DGUE').style.display = "none";
		}
	}catch(e){}
	
	//-- nascondo la scelta del modello se non precedentemente selezionato
	if( getObjValue( 'TipoBandoScelta') == '' )
	{
		getObj('BANDO_SDA_TESTATA_2NEW').rows[3].style.display = 'none';
		getObj('BANDO_SDA_TESTATA_2NEW').rows[4].style.display = 'none';
	}
	
	try{getObj( 'STRUTTURA' ).style.display='none';}catch(e){};
	
}

function OnChangeTipoBando( obj )
{
    //-- aggiorna il modello da usare per la sezione prodotti
    //ExecDocProcess( 'SELECT_MODELLO_SDA,BANDO_SDA');
	ExecDocProcess( 'SELECT_MODELLO_BANDO,BANDO');
	
}

function OnClickProdotti( obj )
{
    var DOCUMENT_READONLY = getObj( 'DOCUMENT_READONLY' ).value;
    if ( DOCUMENT_READONLY == "1" )
        DMessageBox( '../' , 'Documento in sola lettura' , 'Attenzione' , 1 , 400 , 300 );
    else
        ImportExcel( 'CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=RTESTATA_PRODOTTI_MODEL_Allegato&SHEET=0&PARAM=posizionale&PROCESS=LOAD_PRODOTTI,BANDO_SDA&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#400,300' );
}


function LISTA_DOCUMENTI_OnLoad()
{
    
    if (getObj('IDDOC').value.substring(0,3) == 'new' )
	{
		LISTA_DOCUMENTI.location = '../../DASHBOARD/Viewer.asp?TOOLBAR=&Table=BANDO_SDA_LISTA_DOCUMENTI&JSCRIPT=BANDO_SDA&IDENTITY=Id&DOCUMENT=BANDO_SDA&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=&Height=0,100*,0&numRowForPag=15&Sort=data&ActiveSel=2&SortOrder=asc&Exit=no&ShowExit=0&FilterHide=IdDoc = 0 ';
	}
	else
	{
		LISTA_DOCUMENTI.location = '../../DASHBOARD/Viewer.asp?TOOLBAR=&Table=BANDO_SDA_LISTA_DOCUMENTI&JSCRIPT=BANDO_SDA&IDENTITY=Id&DOCUMENT=BANDO_SDA&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=&Height=0,100*,0&numRowForPag=15&Sort=data&ActiveSel=2&SortOrder=asc&Exit=no&ShowExit=0&FilterHide=LinkedDoc =' + getObj('IDDOC').value ;;	
	}
}


function MySend(param)
{
    
	
	if( GetProperty( getObj('ENTIGrid') , 'numrow')==-1)
	{
		ExecDocCommand( 'ENTI#AddNew#');
		DocShowFolder( 'FLD_PLANT' );	   
		tdoc();
		DMessageBox( '../' , 'Compilare la sezione degli Enti Aderenti' , 'Attenzione' , 1 , 400 , 300 );
		return -1;
	}	
	
	if ( GetProperty( getObj('ENTIGrid') , 'numrow')>-1 && ( getObj( 'RENTIGrid_0_AZI_Ente' ).value == '' ))
	{
		DocShowFolder( 'FLD_PLANT' );	   
		tdoc();
		DMessageBox( '../' , 'Compilare correttamente la sezione degli Enti Aderenti' , 'Attenzione' , 1 , 400 , 300 );
		return -1;
	}
	
  if ( getObj('RichiediProdotti').value != 2 ){
	
  	if( GetProperty( getObj('PRODOTTIGrid') , 'numrow') == -1 )
  	{
  		
  	  DocShowFolder( 'FLD_PRODOTTI' );	   
  		tdoc();
  		DMessageBox( '../' , 'Compilare correttamente la sezione dei prodotti' , 'Attenzione' , 1 , 400 , 300 );
  		return -1;
  	}	
  	
	}
	
	
	// ODIROS -- controllo sulla sezione Busta documentazione richiesta
	// function ControlliSend
	// numero di criteri 0-based
	try
	{
		var NumDocRic =  GetProperty(getObj('DOCUMENTAZIONE_RICHIESTAGrid'), 'numrow')  ;
		var RichiediFirma;
		var TipoFile;
		
		if (NumDocRic >= 0)
		{
			for (indice = 0; indice <= NumDocRic; indice++) 
			{
					  
				RichiediFirma = getObj('RDOCUMENTAZIONE_RICHIESTAGrid_' + indice + '_RichiediFirma').checked;
				TipoFile = getObj('RDOCUMENTAZIONE_RICHIESTAGrid_' + indice + '_TipoFile').value;
				
				TipoFile = TipoFile.toUpperCase();
				
				if ( (RichiediFirma == true) && (TipoFile.indexOf('###PDF###') < 0 || TipoFile.indexOf('###P7M###') < 0) )
				{
					DocShowFolder('FLD_DOCUMENTAZIONE_RICHIESTA');
					tdoc();
					DMessageBox('../', 'Nella Busta Documentazione sulle righe con Richiedi Firma = SI il Tipo File deve contenere obbligatoriamente almeno i tipi P7M e PDF', 'Attenzione', 1, 400, 300);
					//getObj('Motivazione_Acquisto_Sociale').focus();
					return -1;
				}
				//alert (RichiediFirma);
				//alert (TipoFile);
			}
		}
		
	}
	catch(e)
	{
	}
	
	
	//if( GetProperty( getObj('ENTIGrid') , 'numrow') > -1 &&   GetProperty( getObj('PRODOTTIGrid') , 'numrow') > -1 ) 
	//{
	
		ExecDocProcess(param);
	//}
	
	
}

function OpenSeduta(objGrid , Row , c) 
{
    var cod = getObj( 'R' + Row + '_idSeduta').value;

    GridSecOpenDoc(objGrid , Row , c) 
    
}


function DownLoadCSV()
{

    var TipoBando = getObjValue( 'TipoBando' );
    
    ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=-1&TIPODOC=BANDO_SDA&MODEL=MODELLI_LOTTI_' + TipoBando + '_MOD_Bando' );
    
}

function Cancella_Iscrizione(objGrid , Row , c){

  /*var cod;
	
  //-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
  
  //se lo stato è cancellato allora messaggio
  var ValueStatoIscrizione;
  ValueStatoIscrizione = getObj( 'val_RISCRITTIGrid_' + Row + '_StatoIscrizione_extraAttrib').value;
  
  if (ValueStatoIscrizione == 'value#=#Cancellato'){
  
    DMessageBox( '../' , 'iscrizione operatore gia cancellata' , 'Attenzione' , 1 , 400 , 300 );
    
  }else{
    
    //innesco createfrom per creare documento CANCELLA_ISCRIZIONE
    //ExecFunctionSelf(  pathRoot + 'ctl_Library/document/MakeDocFrom.asp?TYPE_TO=CANCELLA_ISCRIZIONE&IDDOC='+ cod + '&TYPEDOC=BANDO_ISCRIZ_ALBO' , '', '');
   	var strURL = 'ctl_library/document/document.asp?';
    url = encodeURIComponent(strURL + 'JScript=CANCELLA_ISCRIZIONE&lo=base&DOCUMENT=CANCELLA_ISCRIZIONE&MODE=CREATEFROM&PARAM=BANDO_SDA,' + cod );
	  return ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
    
  }  */
  
  
	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
  
   //alert(cod);
  
	var strDoc = '';
	
	try	{ 	strDoc = getObj( 'R'+ objGrid + '_' + Row + '_OPEN_DOC_NAME').value;	}catch( e ) {};
	
	if ( strDoc == '' || strDoc == undefined )
	{
		try	{ 	strDoc = getObj( 'R' + objGrid + '_' + Row + '_OPEN_DOC_NAME')[0].value; }catch( e ) {};
	}
	
	if ( strDoc == '' || strDoc == undefined ) 
	{
		alert( 'Errore tecnico - ' +  'R' + objGrid + '_' + Row + '_OPEN_DOC_NAME - non trovato' );
		return;
	}
	
	var TYPEDOC = '';
	
	try	{ 	TYPEDOC = getObj( 'R' + objGrid + '_'  + Row + '_MAKE_DOC_NAME').value;	}catch( e ) {};
	
	if ( TYPEDOC == '' || TYPEDOC == undefined )
	{
		try	{ 	TYPEDOC = getObj( 'R' + objGrid + '_' + Row + '_MAKE_DOC_NAME')[0].value; }catch( e ) {};
	}
	
	if ( TYPEDOC == '' || TYPEDOC == undefined ) 
	{
		alert( 'Errore tecnico - ' +  'R' + objGrid + '_' + Row + '_MAKE_DOC_NAME - non trovato' );
		return;
	}

	var param='';
    if ( isSingleWin() )
	{
		param =  TYPEDOC + '##' +  strDoc + '#' + cod + '#' ;
	}
	else
	{
		param =  TYPEDOC + '##' +  strDoc + '#' + cod ;
	}
    MakeDocFrom ( param ) ;
    

}


function AddProdotto( )
{
  
  //alert('addprodotto');
  
	var strCommand = 'PRODOTTI#ADDFROM#IDROW=' + getObjValue( 'IDDOC' ) + '&TABLEFROMADD=DOCUMENT_ADD_PRODOTTO' 

  ExecDocCommand( strCommand );

	
}

function ListaIscrittiToExcel(param)
{

	var QS = param;
	
	var win;
	
	win = ExecFunction( '../../dashboard/viewerExcel.asp?OPERATION=EXCEL' +  '&'  + QS + '&'  , '' , '' );
	

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


function RefreshContent()
{
	RefreshDocument('');
}
function OnchangeElenco_Scelta()
{
	if ( getObj('Elenco_Categorie_Merceologiche').value != '' )
	{
		//abilita il dominio per scegliere il livello
		getObj('Livello_Categorie_Merceologiche').value='';	
		SelectreadOnly( 'Livello_Categorie_Merceologiche' , false );
		//disattivo e svuoto le categorie
		getObj('Categorie_Merceologiche').value='';	
		getObj('Categorie_Merceologiche_edit').value='';	
		getObj('Categorie_Merceologiche_edit_new').value='';			
		getObj('Categorie_Merceologiche_button').style.display='none';	
		
		//filtro il dominio del livello in base alla scelta			
			var val=getObj('Elenco_Categorie_Merceologiche').value;
			var filter =  'SQL_WHERE= DMV_COD in  ( Select distinct DMV_LEVEL from Categorie_Merceologiche where DMV_DM_ID =\''+val+'\') ';
			
			//alert(filter);
			try
			{				
				FilterDom( 'Livello_Categorie_Merceologiche' , 'Livello_Categorie_Merceologiche' , getObjValue('Livello_Categorie_Merceologiche') , filter , ''  , 'OnchangeLivello();');
				
			}catch( e ) {};		
		
	}
	if ( getObj('Elenco_Categorie_Merceologiche').value == '' )
	{
		SelectreadOnly( 'Livello_Categorie_Merceologiche' , true );
		getObj('Livello_Categorie_Merceologiche').value='';
		getObj('Categorie_Merceologiche_button').style.display='none';	
		getObj('Categorie_Merceologiche').value='';
		getObj('Categorie_Merceologiche_edit_new').value='';
		
	}
}
function OnchangeElenco()
{
	if ( getObj('Elenco_Categorie_Merceologiche').value != '' )
	{
		//abilita il dominio per scegliere il livello
		SelectreadOnly( 'Livello_Categorie_Merceologiche' , false );
		
		//filtro il dominio del livello in base alla scelta			
			var val=getObj('Elenco_Categorie_Merceologiche').value;
			var filter =  'SQL_WHERE= DMV_COD in  ( Select distinct DMV_LEVEL from Categorie_Merceologiche where DMV_DM_ID =\''+val+'\') ';
			
			//alert(filter);
			try
			{				
				FilterDom( 'Livello_Categorie_Merceologiche' , 'Livello_Categorie_Merceologiche' , getObjValue('Livello_Categorie_Merceologiche') , filter , ''  , 'OnchangeLivello();');
				
			}catch( e ) {};		
		
	}
	if ( getObj('Elenco_Categorie_Merceologiche').value == '' )
	{
		SelectreadOnly( 'Livello_Categorie_Merceologiche' , true );
		getObj('Livello_Categorie_Merceologiche').value='';
		getObj('Categorie_Merceologiche_button').style.display='none';	
		getObj('Categorie_Merceologiche').value='';
		getObj('Categorie_Merceologiche_edit_new').value='';
		
	}
}
function OnchangeLivello()
{
	if ( getObj('Livello_Categorie_Merceologiche').value != '' )
	{
		getObj('Categorie_Merceologiche_button').style.display='block';	
		var filter = '';
		var filtro='';
		var val_cat=getObj('Elenco_Categorie_Merceologiche').value;
		var val_liv=getObj('Livello_Categorie_Merceologiche').value;
		
		//filter =  GetProperty ( getObj('Categorie_Merceologiche'),'filter') ;	
		filtro= 'SQL_WHERE= DMV_DM_ID = \'' + val_cat + '\' and DMV_LEVEL <= ' + val_liv 
		//if ( filter == '' || filter == undefined || filter == null )
		//{					
			SetProperty( getObj('Categorie_Merceologiche'),'filter',filtro);
		//}		
	}
	if ( getObj('Livello_Categorie_Merceologiche').value == '' )
	{
		SetProperty( getObj('Categorie_Merceologiche'),'filter','');
		getObj('Categorie_Merceologiche_button').style.display='none';	
	}
	
}


function DGUE_Request_Active()
{
	//--- attiva la presenza del template che se assente viene creato con un processo
	if( getObjValue( 'PresenzaDGUE' ) == 'si' && getObjValue( 'idTemplate') == '' )
	{
		ExecDocProcess( 'ATTIVA_DGUE,BANDO,,NO_MSG');
	}
	
}


function DGUE_Request()
{
	if( getObjValue( 'PresenzaDGUE' ) == 'si' )
	{
		MakeDocFrom ( 'TEMPLATE_CONTEST##BANDO' ) ;	
	}
	else
	{
		DMessageBox('../', 'E\' necessario aver selezionato la presenza del DGUE', 'Attenzione', 1, 400, 300);
	}
	
}


function MyOpenViewer(param)
{
	OpenViewer('Viewer.asp?STORED_SQL=yes&OWNER=&Table=DASHBOARD_SP_DASHBOARD_VIEW_OE_ALBO&ModelloFiltro=DASHBOARD_VIEW_OE_ALBOFiltro&ModGriglia=DASHBOARD_VIEW_OE_ALBOGriglia&IDENTITY=idrow&lo=base&HIDE_COL=classeiscriz&DOCUMENT=PDA_COMUNICAZIONE_GENERICA&PATHTOOLBAR=../CustomDoc/&JSCRIPT=PDA_COMUNICAZIONE_GENERICA&AreaAdd=no&Caption=Ricerca Operatori Economici&Height=180,100*,210&numRowForPag=20&Sort=idrow&SortOrder=asc&Exit=si&AreaFiltro=&FilteredOnly=yes&ONSUBMIT=WiewLoading()&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_RICERCA_OPERATORI_ECONOMICI&ACTIVESEL=1&FilterHide=IdHeader='+ getObj('IDDOC').value );
}


function ActiveSelStruttura()
 {
	 getObj( 'TIPO_AMM_ER_button' ).onclick();
 }
 
  function ADD_Enti( obj)
 {
	 ExecDocProcess( 'ADD_ENTI,BANDO_GARA,,NO_MSG' );
 }


function Confirm_MakeDocFrom (param)
{
	//SE IL FLAG INDICA CHE DEVO FARE UNA NUOVA ESTRAZIONE E SONO IL RUP CHIEDO CONFERMA PRIMA DI FARLO
	 var numrighe = GetProperty(getObj('COMMISSIONEGrid'), 'numrow');
	 for (i = 0; i <= numrighe; i++) 
	 {
		  if (getObjValue('R' + i + '_RuoloCommissione') == '15550') 
		  {
				responsabile_procedimento=getObjValue('R' + i + '_IdPfu');			 
		  }
	 }
	
	if ( getObjValue('FLAG_NUOVA_ESTRAZIONE_OE') == '1'  && idpfuUtenteCollegato == responsabile_procedimento  )
	{
		ML_text = 'Si desidera eseguire una nuova estrazione?';
		Title = 'Informazione';					
		ICO = 1;
		page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);
			
		ExecFunctionModaleConfirm( page, Title , 200 , 420 , null , 'MakeDocFrom@@@@' + param  ,'');
	}
	else
	{
		MakeDocFrom ( param ) ;
	}
}