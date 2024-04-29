window.onload = InitDocument;

function PRODOTTI_AFTER_COMMAND ()
{
	InitDocument();
	SetFilterArticoliPrimari();
}

function InitDocument()
{
	try{
			if( getObj('TipoDoc').value == 'CONVENZIONE_ADD_PRODOTTI' )
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
  var doc_to_upd=getQSParam('doc_to_upd');
  
	//-- recupera il codice delle righe selezionate
	idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	
	//alert(idRow);
	
	if( idRow == '' )
	{
	  DMessageBox( '../' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );  
	}
	else
	{		
		var parametri='';
		if ( isSingleWin() )
		{
			parametri =  'PRODOTTI#ADDFROM#IDROW=' + idRow + '&IDDOC='+ doc_to_upd +'&RESPONSE_ESITO=YES&TABLEFROMADD=View_CONVENZIONE_FROMADD_PRODOTTI&DOCUMENT=CONVENZIONE_ADD_PRODOTTI';
		}
		else
		{
			parametri =  'PRODOTTI#ADDFROM#IDROW=' + idRow + '&TABLEFROMADD=View_CONVENZIONE_FROMADD_PRODOTTI&RESPONSE_ESITO=YES'
		}
		Viewer_Dettagli_AddSel( parametri);				
		
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
       OpenViewer('Viewer.asp?OWNER=&Table=View_CONVENZIONE_ADD_PRODOTTI&ModelloFiltro=Convenzione_Modifica_ProdottiFiltro&ModGriglia=' + getObj('ModelloConvenzione').value + '&IDENTITY=ID&lo=base&HIDE_COL=FNZ_DEL,EsitoRiga,&DOCUMENT=CONVENZIONE_ADD_PRODOTTI&PATHTOOLBAR=../CustomDoc/&JSCRIPT=CONVENZIONE_ADD_PRODOTTI&AreaAdd=no&Caption=' +  strCaption + '&Height=180,100*,210&numRowForPag=20&Sort=Id&SortOrder=asc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_LISTA_PRODOTTI&ACTIVESEL=2&FilterHide=IdHeader=' +  strLinkedDoc + '&doc_to_upd='+ getObj('IDDOC').value);
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
    
    SetProperty( getObj('R' + i + '_ArticoliPrimari'),'filter','SQL_WHERE=c.id in ( ' + getObj('IDDOC').value + ',' + getObj('LinkedDoc').value + ')' );
    
	//se presente inizializzo il filtro per la colonna "Riferimento Listino Ordinativi"
	try
	{
		SetProperty( getObj('R' + i + '_IdRigaRiferimento'),'filter','SQL_WHERE= c.id=' + getObj('LinkedDoc').value );
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
		
		url = encodeURIComponent( 'CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=CONVENZIONE_ADD_PRODOTTI&lo=base' );
		NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
		
	}
	else
	{
		ExecFunctionCenter('../../CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=CONVENZIONE_ADD_PRODOTTI' );
	}  
	
	
	
	//alert(IDDOC);
}




function MyDettagliOperation ( grid , r , c )
{
	
	DettagliDel (grid , r , c);
		
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
		
		url = encodeURIComponent( 'CustomDoc/DM_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=CONVENZIONE_ADD_PRODOTTI&lo=base' );
		NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
		
	}
	else
	{
		ExecFunctionCenter('../../CustomDoc/DM_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=CONVENZIONE_ADD_PRODOTTI' );
	}  
	
	
	
	//alert(IDDOC);
}


