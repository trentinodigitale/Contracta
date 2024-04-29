function MySaveDoc()
{

    var TipoOrdine = 'S';
    try{ TipoOrdine = getObjValue( 'TipoOrdine' );   } catch ( e ) {TipoOrdine = 'S';};
    if( TipoOrdine == 'B' )
    {
            DisableObj(  'RicPropBozza' ,false );
            getObj('RicPropBozza').value = '0';

            DisableObj(  'RicPreventivo' ,false );
            getObj('RicPreventivo').value = '1';
    }
    
    SaveDoc();
}


function Seleziona_Ente ( objGrid , Row , c )
{
 

	var cod;
	var strcommand;
	var Prec_Azienda = '';
	
	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
	
	
	Prec_Azienda = parent.self.opener.getObj('Azienda').value ;
	
	parent.self.opener.getObj('Value_tec__Azi').value = cod;
	parent.self.opener.getObj('Azienda').value = cod;
	
	//se azienda selezionata diversa cambio il filtro al campo "Struttura Aziendale"
	//e svuoto gli elementi
	if ( Prec_Azienda != '' && Prec_Azienda != cod )
	{	
		parent.self.opener.filtroPlant( 1 );	
	}
	
	parent.close();
	
	parent.self.opener.ExecDocProcess( 'SEL_ENTE,QUOTA');
	//SaveDoc();

 }


function InvioQuota ( param )
{

	
	var Totale = 0;
	var i;	
	var numRow = 0;
	
	
	
	//-- sommo tutte le righe
	
	if (GetProperty(getObj('LOTTIGrid'), 'numrow') != -1) 
	{
		//-- recupero il numero delle righe presenti sulla griglia	
		numRow=Number( GetProperty(getObj('LOTTIGrid'), 'numrow') );
	
		for( i = 0; i <= numRow ; i++ )
		{
			Totale +=  Number( getObjValue(  'RLOTTIGrid_' + i + '_Importo' ));
		}
	
		//-- aggiorna il campo con ImportoAllocato
		if ( Totale > 0	)
		{
			try	{ SetNumericValue(  'Importo' ,Totale );	} catch( e ) {}; 
		}
	 }
	
	
  if( trim(getObjValue( 'Titolo' )) == '' )
  {
	  //alert( CNV( '../', 'Per proseguire e\' necessariao inserire il titolo.' ));
	  DMessageBox( '../' , 'Per proseguire e\' necessariao inserire il titolo.' , 'Attenzione' , 1 , 400 , 300 );
	  getObj('Titolo').focus();
	  return;
  }
   var v = Number( getObjValue( 'Importo') );
   var nImporto_Allocato_Prec = getObjValue( 'Importo_Allocato_Prec') ;
   
   //se nuova quota non consentiamo 0
   if ( nImporto_Allocato_Prec == '' )
   {
	   if ( v==0)
	   {
	   
		//alert( CNV( '../', 'Per proseguire e\' necessariao avvalorare il campo Importo allocato.' ));
		DMessageBox( '../' , 'Per proseguire e\' necessariao avvalorare il campo Importo allocato.' , 'Attenzione' , 1 , 400 , 300 );
		getObj('Importo_V').focus();
		
		return;
	   
	   }
	   
	   
	   
	   
	}
	
	
	if (GetProperty(getObj('LOTTIGrid'), 'numrow') != -1) 
	{
		//-- recupero il numero delle righe presenti sulla griglia	
		numRow=Number( GetProperty(getObj('LOTTIGrid'), 'numrow') );
	
		for( i = 0; i <= numRow ; i++ )
		{
			v =  Number( getObjValue(  'RLOTTIGrid_' + i + '_Importo' ));
			nImporto_Allocato_Prec = Number( getObjValue(  'RLOTTIGrid_' + i + '_Importo_Allocato_Prec' ));
	
			if ( v==0 && nImporto_Allocato_Prec == 0)
			{			
				DMessageBox( '../' , 'Per proseguire e\' necessariao valorizzare la colonna Importo allocato su tutte le righe' , 'Attenzione' , 1 , 400 , 300 );			
				return;
			}
		}
	 }

    /*
   if ( v > Number( getObjValue( 'Importo_Residuo_Quote') ) )
   {
    
    //alert( CNV( '../', 'L\' importo allocato non puo\' essere superiore all\' importo residuo quote.' ));
    DMessageBox( '../' , 'L\' importo allocato non puo\' essere superiore all\' importo residuo quote.' , 'Attenzione' , 1 , 400 , 300 );
	getObj('Importo_V').focus();
	
	return;
   
   }
   */
   
   if( trim(getObjValue( 'Value_tec__Azi' )) == '' )
  {
    //alert( CNV( '../', 'Per proseguire e\' necessario selezionare l\'ente.' ));
    DMessageBox( '../' , 'Per proseguire e\' necessario selezionare l\'ente.' , 'Attenzione' , 1 , 400 , 300 );
  
  return;
  }

  ExecDocProcess( 'PUBBLICA,QUOTA');
}


function trim(str)
{
	return str.replace(/^\s+|\s+$/g,"");
}


window.onload = InitToolbar ;

function InitToolbar() {
  
	try
	{
		//var temp =  GetProperty( getObj( 'val_StatoDoc' ), 'value' ) ;
		var temp =  getObj( 'StatoDoc' ).value ;
		if ( temp == 'Sent' || temp == 'Invalidate' )
		  getObj('QUOTA_TOOLBAR_DOCUMENT_ADD').style.display='none';

	}catch(e){
	}

	try
	{
		var temp_statofunzionale =  GetProperty( getObj( 'val_StatoFunzionale' ), 'value' ) ;
		
		//se statofunzionale = InvioInCorso allora sono sulla document new ed è lo stato del precedente 
		//tolgo i comandi dalla toolbar per aspettare che si completi l'invio del documento precedente
		if (  temp_statofunzionale == 'InvioInCorso' )
		{
			getObj('QUOTA_TOOLBAR_DOCUMENT_ADD').style.display='none';
			getObj('QUOTA_TOOLBAR_DOCUMENT_SEND').style.display='none';
			getObj('QUOTA_TOOLBAR_DOCUMENT_20').style.display='none';
		}	
		
		//se statofunzionale= inviato ma il protocollo è vuoto allora sono sulla document new e metto in lavorazione
		//perchè lo statofunzionale è del documento da cui provengo
		var temp_prot =  getObj( 'Protocollo' ).value ;
		if (  temp_statofunzionale == 'Inviato' && temp_prot == '' )
		{
			getObj( 'val_StatoFunzionale' ).innerHTML ='In Lavorazione' ;
		}
		
	}catch(e){
	}
  
  
  //Importo Totale Allocato non editable se ci sono righe nella griglia dei lotti
   if (GetProperty(getObj('LOTTIGrid'), 'numrow') != -1 || getObj( 'JumpCheck' ).value == 'QUOTA_PER_LOTTI' ) 
   {
		NumberreadOnly( 'Importo' , true );   	
		getObj( 'JumpCheck' ).value='QUOTA_PER_LOTTI';
   }
   else
   {
	   NumberreadOnly( 'Importo' , false );
	   //NASCONDE LA GRIGLIA
	   getObj('div_LOTTIGrid').style.display='none';
	   getObj('QUOTA_LOTTI_TOOLBAR_Lotto_da_convezione').style.display='none';
	   getObj( 'JumpCheck' ).value='QUOTA_SENZA_LOTTI';
	   
   }
	   
  
	//se doc editabile e il campo StrutturaAziendale Visibile
	//setto il filtro a seconda dell'ente selezionato
	var DOCUMENT_READONLY = '0';
	try
	{
		DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	}
	catch(e){}
	
	if (DOCUMENT_READONLY == '0')
	{
		filtroPlant( 0 );	
	}	
	
	
}

function MyDetail_AddFrom(param)
{
	//var temp =  GetProperty( getObj( 'val_StatoDoc' ), 'value' ) ;
	var temp =   getObj( 'StatoDoc' ).value;
	
	if ( temp == 'Sent' || temp == 'Sended' || temp == 'Invalidate' )
	{
		DMessageBox( '../' , 'La selezione dell\'ente e\' consentita solo per le nuove quote' , 'Attenzione' , 1 , 400 , 300 );
	}
	else
	{
		Detail_AddFrom(param);
	}
}


function MyOpenViewer(param)
{	
	ExecDocProcess( 'SAVE_AND_GO,QUOTA_ADD_LOTTO,,NO_MSG');
}

function afterProcess( param )
{
	if ( param == 'SAVE_AND_GO' )
    {
       OpenViewer('Viewer.asp?OWNER=&Table=CONVENZIONE_CAPIENZA_LOTTI_VIEW&ModelloFiltro=&ModGriglia=CONVENZIONE_LOTTI&IDENTITY=idRow&lo=base&HIDE_COL=&DOCUMENT=QUOTA&PATHTOOLBAR=../CustomDoc/&JSCRIPT=QUOTA&AreaAdd=no&Caption=Lista lotti convezione&Height=180,100*,210&numRowForPag=20&Sort=NumeroLotto&SortOrder=asc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_LISTA_PRODOTTI&ACTIVESEL=2&FilterHide=IdHeader='+ getObj('LinkedDoc').value + '&doc_to_upd='+ getObj('IDDOC').value);
    }
	
}

function AggiungiProdotti(){
  
  var idRow;
  var doc_to_upd=getQSParam('doc_to_upd');
  
	//-- recupera il codice delle righe selezionate
	idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	
	if( idRow == '' )
	{
	  DMessageBox( '../' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );  
	}
	else
	{					
		var parametri='';
		if ( isSingleWin() )
		{
			parametri =  'LOTTI#ADDFROM#IDROW=' + idRow + '&IDDOC='+ doc_to_upd +'&RESPONSE_ESITO=YES&TABLEFROMADD=CONVENZIONE_QUOTA_LOTTI_FROMADD&DOCUMENT=QUOTA';
		}
		else
		{
			parametri =  'LOTTI#ADDFROM#IDROW=' + idRow + '&TABLEFROMADD=CONVENZIONE_QUOTA_LOTTI_FROMADD&RESPONSE_ESITO=YES'
		}
		
		Viewer_Dettagli_AddSel( parametri);	
	}  
}


//serve solo nella versione multi finestra
function RefreshContent()
{
	if ( isSingleWin() == false )
	{
		ExecDocProcess( 'FITTIZIO,DOCUMENT,,NO_MSG');
	}
}


//applico il filtro al dominio della struttura di appartenenza
//per caricare solo i  rami relativi all'azienda collegata
function filtroPlant( nSvuota )
{

	var filter = '';

	try
	{ 
		var objBtn_Struttura = getObj('StrutturaAziendale_button');
		if (objBtn_Struttura != null)
		{	
			if ( getObj('Azienda').value != '' )
			{ 	
				filter = 'idaz in ( ' + getObj('Azienda').value + ' )' ;
				getObj('StrutturaAziendale_extraAttrib').value= 'strformat#=#M#@#filter#=#SQL_WHERE= ' + filter + '#@#multivalue#=#1';
			}	
			
			//svuoto il campo
			if ( nSvuota == 1)
			{	
				getObj( 'StrutturaAziendale').value = '';
				getObj( 'StrutturaAziendale_edit_new').value = '0 Selezionati';
			}
			
		}
	}
	catch(e){};
		
}
