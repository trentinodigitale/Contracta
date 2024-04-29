window.onload = InitDocument;

function PRODOTTI_AFTER_COMMAND ()
{
	InitDocument();
	SetFilterArticoliPrimari();
}

function InitDocument()
{
	try{
			if( getObj('TipoDoc').value == 'CONVENZIONE_UPD_PRODOTTI' )
			{
				var TipoConvenzione;
				TipoConvenzione=getObj('TipoConvenzione').value;
				
				//TipoAcquisto visibile e obbligatoria se TipoConvenzione='Mista'
				if( TipoConvenzione != 'miste' )
				{
					ShowCol( 'PRODOTTI' , 'TipoAcquisto' , 'none' );
					ShowCol( 'PRODOTTI' , 'StatoRiga' , 'none' );
					
					
				}
				else
				{
					ShowCol( 'PRODOTTI' , 'StatoRiga' , 'none' );
					
				}
				SetFilterArticoliPrimari();
			}
		}catch(e){}
}

function AggiungiProdotti(){
  
  var idRow;
  var parametri;
  var strURL;
  var doc_to_upd=getQSParam('doc_to_upd');
  var result;
  ShowWorkInProgress(true);
	if ( isSingleWin() == false )
	{
		pathRoot='../';
	}
	//-- recupera il codice delle righe selezionate
	idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	
	if( idRow == '' )
	{
	  ShowWorkInProgress(false);	
	  DMessageBox( '../' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );  
	  return -1;
	}
	if( idRow.indexOf('~~~') > -1 )
	{
	  ShowWorkInProgress(false);	
	  DMessageBox( '../' , 'E\' necessario selezionare una sola riga' , 'Attenzione' , 2 , 400 , 300 );  
	  return -1;
	}
	else
	{	
		ajax = GetXMLHttpRequest(); 
		if(ajax)
		{
			//cancello i prodotti alla griglia prodotti_OLD
			parametri =  'PRODOTTI_OLD#DELETE_ALL#IDROW=' + idRow + '&IDDOC='+ doc_to_upd +'&RESPONSE_ESITO=YES&TABLEFROMADD=View_CONVENZIONE_UPD_PRODOTTI_OLD&DOCUMENT=CONVENZIONE_UPD_PRODOTTI';
			vet = parametri.split( '#' );
			section = vet[0];
			command = vet[1];
			param = vet[2];
			strURL= pathRoot + 'ctl_library/document/document.asp?MODE=SHOW&COMMAND=' + section + '.' + command + '&' + param;
			ajax.open("GET", strURL  , false);
			ajax.send(null);

			if(ajax.readyState == 4) 
			{
				//alert(strURL);
				//alert(ajax.status);
				if(ajax.status == 200 || ajax.status == 404 || ajax.status == 500)
				{							
					result =  ajax.responseText;
				}
			}

			
			//aggiungi i prodotti alla griglia prodotti_OLD
			parametri =  'PRODOTTI_OLD#ADDFROM#IDROW=' + idRow + '&IDDOC='+ doc_to_upd +'&RESPONSE_ESITO=YES&TABLEFROMADD=View_CONVENZIONE_UPD_PRODOTTI_OLD&DOCUMENT=CONVENZIONE_UPD_PRODOTTI';
			vet = parametri.split( '#' );
			section = vet[0];
			command = vet[1];
			param = vet[2];
			strURL= pathRoot + 'ctl_library/document/document.asp?MODE=SHOW&COMMAND=' + section + '.' + command + '&' + param;
			ajax.open("GET", strURL  , false);
			ajax.send(null);

			if(ajax.readyState == 4) 
			{
				//alert(strURL);
				//alert(ajax.status);
				if(ajax.status == 200 || ajax.status == 404 || ajax.status == 500)
				{							
					result =  ajax.responseText;
				}
			}
			
			//cancello i prodotti alla griglia prodotti
			parametri =  'PRODOTTI#DELETE_ALL#IDROW=' + idRow + '&IDDOC='+ doc_to_upd +'&RESPONSE_ESITO=YES&TABLEFROMADD=View_CONVENZIONE_UPD_PRODOTTI&DOCUMENT=CONVENZIONE_UPD_PRODOTTI';
			vet = parametri.split( '#' );
			section = vet[0];
			command = vet[1];
			param = vet[2];			
			strURL= pathRoot + 'ctl_library/document/document.asp?MODE=SHOW&COMMAND=' + section + '.' + command + '&' + param;
			ajax.open("GET", strURL  , false);
			ajax.send(null);

			if(ajax.readyState == 4) 
			{
				//alert(strURL);
				//alert(ajax.status);
				if(ajax.status == 200 || ajax.status == 404 || ajax.status == 500)
				{						
					result =  ajax.responseText;	
				}
			}

			
			//aggiungi i prodotti alla griglia prodotti
			parametri =  'PRODOTTI#ADDFROM#IDROW=' + idRow + '&IDDOC='+ doc_to_upd +'&RESPONSE_ESITO=YES&TABLEFROMADD=View_CONVENZIONE_ADDFROMUPD_PRODOTTI&DOCUMENT=CONVENZIONE_UPD_PRODOTTI';
			vet = parametri.split( '#' );
			section = vet[0];
			command = vet[1];
			param = vet[2];
			strURL= pathRoot + 'ctl_library/document/document.asp?MODE=SHOW&COMMAND=' + section + '.' + command + '&' + param;
			ajax.open("GET", strURL  , false);
			ajax.send(null);

			if(ajax.readyState == 4) 
			{
				//alert(strURL);
				//alert(ajax.status);
				if(ajax.status == 200 || ajax.status == 404 || ajax.status == 500)
				{			
					result =  ajax.responseText;					
				}
			}

		}
	} 
 
 
	//visualizzo messaggio operazione 
	if ( isSingleWin() == true )
	{
		DMessageBox( '../' , 'Articolo aggiunto correttamente' , 'Info' , 1 , 400 , 300 );  
	}
	ShowWorkInProgress(false);	
	if ( isSingleWin() == false )
	{
		DMessageBox( '../ctl_library/' , 'Articolo aggiunto correttamente' , 'Info' , 1 , 400 , 300 );  
		parent.opener.RefreshContent();	
	}
 
}

function MyOpenViewer(param)
{	
	ExecDocProcess( 'SAVE_AND_GO,CONVENZIONE_ADD_PRODOTTI,,NO_MSG');
}

function afterProcess( param )
{
	if ( param == 'SAVE_AND_GO' )
    {
		
		var strCaption = 'Lista articoli convezione' ; 
		var strLinkedDoc  = getObj('LinkedDoc').value ;
	   
		if ( getObj('JumpCheck').value == 'LISTINO_ORDINI' )
		{   
			strCaption = 'Lista articoli listino ordini' ; 
			strLinkedDoc  = getObj('idDocListinoOrdini').value ; 	
		}	
		
       OpenViewer('Viewer.asp?OWNER=&Table=View_CONVENZIONE_UPD_PRODOTTI&ModelloFiltro=Convenzione_Modifica_ProdottiFiltro&ModGriglia=' + getObj('ModelloConvenzione').value + '&IDENTITY=ID&lo=base&HIDE_COL=FNZ_DEL,EsitoRiga,&DOCUMENT=CONVENZIONE_UPD_PRODOTTI&PATHTOOLBAR=../CustomDoc/&JSCRIPT=CONVENZIONE_UPD_PRODOTTI&AreaAdd=no&Caption=' + strCaption + '&Height=180,100*,210&numRowForPag=20&Sort=Id&SortOrder=asc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_LISTA_PRODOTTI&ACTIVESEL=2&FilterHide=IdHeader='+ strLinkedDoc + ' and StatoRiga in (\'Saved\',\'\',\'Inserito\',\'Variato\') &doc_to_upd='+ getObj('IDDOC').value);
    }
	
	if ( param == 'SAVE_DOC' )
	{
		ElabAIC();  
	}
	
	
	if ( param == 'SAVE_DOC_DM' )
	{
		Elab_DM();  
	}
	
	
}



//setta il filtro sul dominio ArticoliPrimari per considerare solo gli articoli della convenzione corrente
function SetFilterArticoliPrimari(){
  
  
  //numRow = eval('PRODOTTIGrid_NumRow') ;
  var numRow = GetProperty( getObj('PRODOTTIGrid') , 'numrow');
  
  for( i = 0; i <= numRow ; i++ ){
    
    SetProperty( getObj('RPRODOTTIGrid_' + i + '_ArticoliPrimari'),'filter','SQL_WHERE=c.id in ( ' + getObj('IDDOC').value + ',' + getObj('LinkedDoc').value + ')' );
    
	//se presente inizializzo il filtro per la colonna "Riferimento Listino Ordinativi"
	try
	{
		SetProperty( getObj('RPRODOTTIGrid_' + i + '_IdRigaRiferimento'),'filter','SQL_WHERE= c.id=' + getObj('LinkedDoc').value );
	}catch(e){}
	
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



function GetDatiAIC()
{
	ExecDocProcess('SAVE_DOC,AIC,,NO_MSG');
}


function ElabAIC()
{
	// IdOfferta
	var IDDOC = getObjValue('IDDOC');
	
	
	
	if ( isSingleWin() )
	{
		var url;
		
		url = encodeURIComponent( 'CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=CONVENZIONE_UPD_PRODOTTI&lo=base' );
		NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
		
	}
	else
	{
		ExecFunctionCenter('../../CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=CONVENZIONE_UPD_PRODOTTI' );
	}  
	
	
	
	//alert(IDDOC);
}




function GetDatiDM()
{
	ExecDocProcess('SAVE_DOC_DM,DM,,NO_MSG');
}




function Elab_DM()
{
	// IdOfferta
	var IDDOC = getObjValue('IDDOC');
	
	
	
	if ( isSingleWin() )
	{
		var url;
		
		url = encodeURIComponent( 'CustomDoc/DM_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=CONVENZIONE_UPD_PRODOTTI&lo=base' );
		NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
		
	}
	else
	{
		ExecFunctionCenter('../../CustomDoc/DM_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=CONVENZIONE_UPD_PRODOTTI' );
	}  
	
	
	
	//alert(IDDOC);
}