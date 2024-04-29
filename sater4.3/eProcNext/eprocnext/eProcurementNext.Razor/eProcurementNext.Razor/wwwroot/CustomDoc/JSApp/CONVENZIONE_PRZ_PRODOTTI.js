window.onload = InitDocument;


function InitDocument()
{
	try{
		
		if( getObj('TipoDoc').value == 'CONVENZIONE_PRZ_PRODOTTI' )
		{
			var ConAccessori;
			var TipoVariazione;
			TipoVariazione=getObj('TipoVariazione').value;
			ConAccessori=getObj('ConAccessori').value;			
			getObj('varia_importo').onchange=Onchange_Varia_Importo;
			getObj('varia_accessorio').onchange=Onchange_Varia_Accessorio;
			
			if( ConAccessori == 'no' )
			{
				//nascondo i campi realtivi agli accessori
				ShowCol( 'PRODOTTI' , 'PREZZO_ACCESSORIO_PER_UM' , 'none' );
				ShowCol( 'PRODOTTI' , 'PREZZO_ACCESSORIO_PER_UM_VARIATO' , 'none' );
				$( "#cap_varia_accessorio" ).parents("table:first").css({"display":"none"})
				$( "#cap_ImportoModificaAccessori" ).parents("table:first").css({"display":"none"})
				$( "#cap_PercModificaAccessori" ).parents("table:first").css({"display":"none"})	
				getObj('varia_importo').checked=true;
				
			}
			else 
			{
				//$( "#cap_ImportoModificaImporto" ).parents("table:first").css({"display":"none"})
				//$( "#cap_PercModificaImporto" ).parents("table:first").css({"display":"none"})	
			}
			if ( getObj('StatoFunzionale').value == 'InLavorazione'  && TipoVariazione == 'Massiva')
			{
				Onchange_Varia_Importo();
				Onchange_Varia_Accessorio();
			}
			if (TipoVariazione != 'Massiva')
			{
				$( "#cap_varia_importo" ).parents("table:first").css({"display":"none"})
				$( "#cap_ImportoModificaImporto" ).parents("table:first").css({"display":"none"})
				$( "#cap_PercModificaImporto" ).parents("table:first").css({"display":"none"})	
				$( "#cap_varia_accessorio" ).parents("table:first").css({"display":"none"})
				$( "#cap_ImportoModificaAccessori" ).parents("table:first").css({"display":"none"})
				$( "#cap_PercModificaAccessori" ).parents("table:first").css({"display":"none"})	
			}
		 }
		 
		}catch(e){}
		
		
		//se sono sul listino ordini cambio help
		if ( getObj('JumpCheck').value == 'LISTINO_ORDINI' )
		{	
			getObj('cap_LblHelpVariazionePrezzi').innerHTML = CNV( '../../','LblHelpVariazionePrezziListinoOrdini');
		}
}

function Onchange_Varia_Importo()
{
	var ConAccessori;
	var esegui_proc;
	ConAccessori=getObj('ConAccessori').value;
    if( ConAccessori == 'no' )
	{
		getObj('varia_importo').checked=true;		
		 
	}
	else
	{
		if( getObj('varia_importo').checked == true)
		{			
			$( "#cap_ImportoModificaImporto" ).parents("table:first").css({"display":""})
			$( "#cap_PercModificaImporto" ).parents("table:first").css({"display":""})	
			
		}
		else
		{
			$( "#cap_ImportoModificaImporto" ).parents("table:first").css({"display":"none"})
			$( "#cap_PercModificaImporto" ).parents("table:first").css({"display":"none"})				
			
			if ( Number(getObj( 'ImportoModificaImporto' ).value ) > 0 || Number(getObj( 'PercModificaImporto' ).value ) > 0 )
			{
				esegui_proc='SI';				 
			}
			SetNumericValue( 'ImportoModificaImporto' , 0 );	
			SetNumericValue( 'PercModificaImporto' , 0 );	
			if ( esegui_proc == 'SI' )
			{
				ExecDocProcess( 'AGGIORNA_PRODOTTI,CONVENZIONE_PRZ_PRODOTTI'); 
			}
		}
		
	}
	
	
}
function Onchange_Varia_Accessorio()
{
	var ConAccessori;
	var esegui_proc;
	ConAccessori=getObj('ConAccessori').value;
    if( ConAccessori == 'si' )
	{
		if( getObj('varia_accessorio').checked == true)
		{			
			//alert('NO');
			$( "#cap_ImportoModificaAccessori" ).parents("table:first").css({"display":""})
			$( "#cap_PercModificaAccessori" ).parents("table:first").css({"display":""})	
			
			
		}
		else
		{
			//alert('OK');
			$( "#cap_ImportoModificaAccessori" ).parents("table:first").css({"display":"none"})
			$( "#cap_PercModificaAccessori" ).parents("table:first").css({"display":"none"})
			
			if ( Number(getObj( 'ImportoModificaAccessori' ).value ) > 0 || Number(getObj( 'PercModificaAccessori' ).value ) > 0 )
			{
				esegui_proc='SI';					
			}
			SetNumericValue( 'ImportoModificaAccessori' , 0 );	
			SetNumericValue( 'PercModificaAccessori' , 0 );	
			if ( esegui_proc == 'SI' )
			{
				ExecDocProcess( 'AGGIORNA_PRODOTTI,CONVENZIONE_PRZ_PRODOTTI'); 
			}
		
		}
		
	}

}


function Onchange_Valore(obj)
{
	if( obj.id == 'ImportoModificaImporto_V' )
	{
		SetNumericValue( 'PercModificaImporto' , 0 );	
		ExecDocProcess( 'AGGIORNA_PRODOTTI,CONVENZIONE_PRZ_PRODOTTI'); 
	}
	if( obj.id == 'PercModificaImporto_V' )
	{
		SetNumericValue( 'ImportoModificaImporto' , 0 );
		ExecDocProcess( 'AGGIORNA_PRODOTTI,CONVENZIONE_PRZ_PRODOTTI'); 		
	}
	
	if( obj.id == 'ImportoModificaAccessori_V' )
	{
		SetNumericValue( 'PercModificaAccessori' , 0 );	
		ExecDocProcess( 'AGGIORNA_PRODOTTI,CONVENZIONE_PRZ_PRODOTTI'); 
	}
	if( obj.id == 'PercModificaAccessori_V' )
	{
		SetNumericValue( 'ImportoModificaAccessori' , 0 );	
		ExecDocProcess( 'AGGIORNA_PRODOTTI,CONVENZIONE_PRZ_PRODOTTI'); 
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
			parametri =  'PRODOTTI#ADDFROM#IDROW=' + idRow + '&IDDOC='+ doc_to_upd +'&RESPONSE_ESITO=YES&TABLEFROMADD=View_CONVENZIONE_PRZ_PRODOTTI&DOCUMENT=CONVENZIONE_PRZ_PRODOTTI';
		}
		else
		{
			parametri =  'PRODOTTI#ADDFROM#IDROW=' + idRow + '&TABLEFROMADD=View_CONVENZIONE_PRZ_PRODOTTI&RESPONSE_ESITO=YES'
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
	   
       OpenViewer('Viewer.asp?OWNER=&Table=View_CONVENZIONE_PRZ_PRODOTTI&ModelloFiltro=Convenzione_Modifica_ProdottiFiltro&ModGriglia=' + getObj('ModelloConvenzione').value + '&IDENTITY=ID&lo=base&HIDE_COL=FNZ_DEL,EsitoRiga,&DOCUMENT=CONVENZIONE_PRZ_PRODOTTI&PATHTOOLBAR=../CustomDoc/&JSCRIPT=CONVENZIONE_PRZ_PRODOTTI&AreaAdd=no&Caption=' + strCaption + '&Height=180,100*,210&numRowForPag=20&Sort=Id&SortOrder=asc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_LISTA_PRODOTTI&ACTIVESEL=2&FilterHide=IdHeader='+  strLinkedDoc + ' and StatoRiga in (\'Saved\',\'\',\'Inserito\',\'Variato\') &doc_to_upd='+ getObj('IDDOC').value);
    }
	
}


function PRODOTTI_AFTER_COMMAND ( command )
{
	
	
	if (command == 'ADDFROM' )
	{  
		
		if ( isSingleWin() == true )
		{		
			
			//VALORIZZO FITTIZIO DEL FORM PER NON FARMI BLOCCARE DALLA SICUREZZA
			
			var myReq = GetXMLHttpRequest(); 
			var res = false;
			var doc_to_upd = getQSParam('doc_to_upd');
			var TYPEDOC = 'CONVENZIONE_PRZ_PRODOTTI';
			var nocache = new Date().getTime();				
			var STR_URL =  pathRoot + 'ctl_library/document/document.asp?lo=base&JScript=CONVENZIONE_PRZ_PRODOTTI&DOCUMENT=CONVENZIONE_PRZ_PRODOTTI&IDDOC='+ doc_to_upd +'&MODE=SHOW&COMMAND=PROCESS&PROCESS_PARAM=AGGIORNA_PRODOTTI,CONVENZIONE_PRZ_PRODOTTI,,NO_MSG&nocache=' + nocache;
			
			myReq.open('POST', STR_URL, false);			
			param='PIPPO=PLUTO';			   

			myReq.setRequestHeader("Content-Type","application/x-www-form-urlencoded; charset=UTF-8");
			myReq.send(param);			
			//alert(myReq.responseText);
			
			//FINE VALORIZZO FITTIZIO DEL FORM PER NON FARMI BLOCCARE DALLA SICUREZZA
			
			//var doc_to_upd=getQSParam('doc_to_upd');
			//getObj('Viewer_Command').src =pathRoot + 'ctl_library/document/document.asp?lo=base&JScript=CONVENZIONE_PRZ_PRODOTTI&DOCUMENT=CONVENZIONE_PRZ_PRODOTTI&IDDOC='+ doc_to_upd +'&MODE=SHOW&COMMAND=PROCESS&PROCESS_PARAM=AGGIORNA_PRODOTTI,CONVENZIONE_PRZ_PRODOTTI,,NO_MSG'
		}
		
		
		
	}
	
	InitDocument();
}

//serve solo nella versione multi finestra
function RefreshContent()
{
	
	if ( isSingleWin() == false )
	{
		//ExecDocProcess( 'FITTIZIO,DOCUMENT,,NO_MSG');
		ExecDocProcess( 'AGGIORNA_PRODOTTI,CONVENZIONE_PRZ_PRODOTTI,,NO_MSG');
		
	}
}

function Onchange_Tipo_Variazione()
{
	//alert(getObj('TipoVariazione').value);
	ExecDocProcess( 'AGGIORNA_PRODOTTI,CONVENZIONE_PRZ_PRODOTTI,,NO_MSG');
}