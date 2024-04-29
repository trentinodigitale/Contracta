//Variabile di appoggio per contenere l'idpfu dell'utente collegato e gestire l'applicazione sia se accessibile sia no
var tmp_idpfuUtenteCollegato;

function FIRMA_OnLoad()
{
   
	var Stato ='';
	var IdpfuInCharge=0;
	Stato = getObjValue('StatoFunzionale');
	IdpfuInCharge = getObjValue('IdpfuInCharge');
	
	//if ( idpfuUtenteCollegato == undefined )
	//	var idpfuUtenteCollegato = getObjValue('IdpfuInCharge');
	if ( typeof idpfuUtenteCollegato === 'undefined' )
		tmp_idpfuUtenteCollegato = getObjValue('IdpfuInCharge');
	else
		tmp_idpfuUtenteCollegato = idpfuUtenteCollegato;
	
	if ((getObjValue('SIGN_LOCK') =='0' || getObjValue('SIGN_LOCK') =='')   && ( Stato=='Inviato' || Stato=='Rifiutato' ) && IdpfuInCharge == tmp_idpfuUtenteCollegato )
		{
		document.getElementById('generapdf').disabled = false; 
		document.getElementById('generapdf').className ="generapdf";
		}
	else
	   {
	   document.getElementById('generapdf').disabled = true; 
	   document.getElementById('generapdf').className ="generapdfdisabled";
	   }

	 
	if ( getObjValue('SIGN_LOCK') != '0'   && ( Stato=='Inviato' || Stato=='Rifiutato' )  && IdpfuInCharge == tmp_idpfuUtenteCollegato )
		{
		document.getElementById('editistanza').disabled = false; 
		document.getElementById('editistanza').className ="attachpdf";
		}
	else
	   {
	   document.getElementById('editistanza').disabled = true; 
	   document.getElementById('editistanza').className ="attachpdfdisabled";
	   } 
	
	if ( getObjValue('SIGN_ATTACH') == ''  &&  ( Stato=='Inviato' || Stato=='Rifiutato' ) && getObjValue('SIGN_LOCK') != '0'  && IdpfuInCharge == tmp_idpfuUtenteCollegato  )
		{
		document.getElementById('attachpdf').disabled = false; 
		document.getElementById('attachpdf').className ="editistanza";
		}
	else
	   {
	   document.getElementById('attachpdf').disabled = true; 
	   document.getElementById('attachpdf').className ="editistanzadisabled";
	   }
	
}

window.onload = Init_Listino_Ordini;

function Init_Listino_Ordini()
{
	//gestiione dell'are a per la firna
	FIRMA_OnLoad();
	
	//tolgo la lente dalla cronologia dove non ci sono documenti da aprire
	hide_lente_operazioni_effettuate();
	
	
	var DOCUMENT_READONLY = '0';
	
	try
	{
		DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	}
	catch(e)
	{
		
	}
	
	//se il documento è editabile faccio i settaggi 
	if ( DOCUMENT_READONLY == '0' )
	{
		
		//innesco funzione per settare filtro su dominio ArticoliPrimari per tutte le righe
		SetFilterArticoliPrimari();
		
		
		
	}
	
	
}


function GeneraPDF()
{	
	
	ExecDocProcess( 'CONTROLLO_PRODOTTI_2,LISTINO_ORDINI_OE');
	
}


function afterProcess( param )
{

	var value='';
    var JumpCheck = getObjValue('JumpCheck');
	if ( param == 'CONTROLLO_PRODOTTI_2' )
    {
		value=controlloEsitoRiga('');
	
		if (value == -1)
		{
			alert( CNV( '../','Sono presenti righe con anomalie.'));
			return ;
		} 
		
		
		if ( JumpCheck == 'RICHIESTA-FIRMA:no' ) 
		{
			PrintPdf('/report/prn_LISTINO_CONVENZIONE.ASP?CONTESTO=LISTINO_ORDINI&PDF_NAME=LISTINO_ORDINI');
			return;
		}
		else
		{
			PrintPdfSign('URL=/report/prn_LISTINO_CONVENZIONE.ASP?CONTESTO=LISTINO_ORDINI&SIGN=YES&PDF_NAME=LISTINO_ORDINI');
			return;
		}	
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
function controlloEsitoRiga()
{
	var numeroRighe = GetProperty( getObj('PRODOTTIGrid') , 'numrow');
	for( i = 0 ; i <= numeroRighe ; i++ )
	 {
		try
		{
			if ( getObj('RPRODOTTIGrid_' + i + '_EsitoRiga').value.indexOf('State_ERR.gif') > 0 )
			{
				return -1;
			}
		
		}catch(e)	  {	  }
	}

}

function TogliFirma () 
{
	DMessageBox( '../' , 'Si sta per eliminare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );	
	ExecDocProcess( 'SIGN_ERASE_LISTINO_ORDINI,FirmaDigitale');  
}


function DownLoadCSV()
{

    var Tipomod = getObjValue( 'Tipo_Modello_Convenzione' );
	var iddoc = getObj('IDDOC').value;
	
    
    if ( Tipomod == '' )
    {
      alert( CNV( '../','E\' necessario selezionare prima il modello'));
      return ;
    }
	
    ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + iddoc + '&TIPODOC=LISTINO_ORDINI_OE&OPERATION=&MODEL=MODELLO_BASE_CONVENZIONI_' + Tipomod + '_MOD_PerfListinoOrdini&HIDECOL=ESITORIGA,StatoRiga,TipoDoc'  , '_blank' ,'');
    
}


function OnClickProdotti( obj )
{
     var Tipomod = getObjValue( 'Tipo_Modello_Convenzione' );
    
    if ( Tipomod == '' )
    {
      //alert( CNV( '../','E\' necessario selezionare prima il modello'));
      DMessageBox( '../' , 'E\' necessario selezionare prima il modello' , 'Attenzione' , 1 , 400 , 300 );
      return ;
    }

    var DOCUMENT_READONLY = getObj( 'DOCUMENT_READONLY' ).value;
    if ( DOCUMENT_READONLY == "1" )
        DMessageBox( '../' , 'Documento in sola lettura' , 'Attenzione' , 1 , 400 , 300 );
    else
        ImportExcel( 'CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=RTESTATA_PRODOTTI_MODEL_Allegato&SHEET=0&PARAM=posizionale&PROCESS=LOAD_PRODOTTI,LISTINO_ORDINI_OE&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#600,450' );
}
function RefreshContent()
{
	
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
		
		url = encodeURIComponent( 'CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=LISTINO_ORDINI_OE&lo=base' );
		NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
		
	}
	else
	{
		ExecFunctionCenter('../../CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=LISTINO_ORDINI_OE' );
	}  
	
	
	
	//alert(IDDOC);
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

//per fare le operazioni sulla griglia

function MyDettagliOperation ( grid , r , c )
{
	
	
	//getExtraAttrib( 'val_R' + indRow +  '_VerificaCampionatura' , 'value' )
	//val_RPRODOTTIGrid_1_StatoRiga_extraAttrib
	
	var Val_Statoriga = getObj ( 'RPRODOTTIGrid_' + r +  '_StatoRiga' ).value;
	
	//alert(Val_Statoriga);
	//se statoriga = inserted allora è una riga di iniziativa che posso cancellare e chiamo la DettagliDel classica
	if ( Val_Statoriga == 'Inserito' )
	{
		DettagliDel (grid , r , c);
		return;
	}
	
	//se staoriga vale Saved alloro lo metto a cancellato
	if ( Val_Statoriga == 'Saved' || Val_Statoriga == '' )
	{
		getObj ( 'RPRODOTTIGrid_' + r +  '_StatoRiga' ).value = 'Deleted';
		getObj ( 'val_RPRODOTTIGrid_' + r + '_StatoRiga' ).innerHTML = 'Cancellato';
		
		//cambio icona per evidenziare che adesso posso ripristinare
		getObj('RPRODOTTIGrid_' + r + '_FNZ_DEL').innerHTML = '<tbody><tr><td title=""><img class="img_label_alt" alt="Ripristina" src="../images/Domain/../toolbar/ripristina.png" title="Ripristina"></td><td class="nowrap GridCol_Link_label" id="RPRODOTTIGrid_' + r + '_FNZ_DEL_label"></td></tr></tbody>';
		
		return;
	}
	
	//se statoriga vale  Deleted alloro lo metto a Saved
	if ( Val_Statoriga == 'Deleted' )
	{
		getObj ( 'RPRODOTTIGrid_' + r +  '_StatoRiga' ).value = 'Saved';
		getObj ( 'val_RPRODOTTIGrid_' + r + '_StatoRiga' ).innerHTML = '';
		
		//cambio icona per evidenziare che adesso posso eliminare
		getObj('RPRODOTTIGrid_' + r + '_FNZ_DEL').innerHTML = '<tbody><tr><td title=""><img class="img_label_alt" alt="Cancella" src="../images/Domain/../toolbar/Delete_Light.GIF" title="Cancella"></td><td class="nowrap GridCol_Link_label" id="RPRODOTTIGrid_' + r + '_FNZ_DEL_label"></td></tr></tbody>';
		
		
		return;
	}
}



//setta il filtro sul dominio ArticoliPrimari per considerare solo gli articoli della convenzione corrente
function SetFilterArticoliPrimari()
{
  
  var Val_StatorigaM;
  
  //numRow = eval('PRODOTTIGrid_NumRow') ;
  var numRow = GetProperty( getObj('PRODOTTIGrid') , 'numrow');
  
  for( i = 0; i <= numRow ; i++ )
  {
    
    SetProperty( getObj('RPRODOTTIGrid_' + i + '_ArticoliPrimari'),'filter','SQL_WHERE= c.id=' + getObj('IDDOC').value );
	
	SetProperty( getObj('RPRODOTTIGrid_' + i + '_IdRigaRiferimento'),'filter','SQL_WHERE= c.id=' + getObj('LinkedDoc').value );
    
	
	//aggiusto icona sulla riga se 
	//se statoriga = deleted allora metto icona del cancellato
	
	Val_Statoriga = getObj ( 'RPRODOTTIGrid_' + i +  '_StatoRiga' ).value;
	
	if ( Val_Statoriga == 'Deleted' )
	{
		getObj('RPRODOTTIGrid_' +  i + '_FNZ_DEL').innerHTML = '<tbody><tr><td title=""><img class="img_label_alt" alt="Ripristina" src="../images/Domain/../toolbar/ripristina.png" title="Ripristina"></td><td class="nowrap GridCol_Link_label" id="RPRODOTTIGrid_' +  i + '_FNZ_DEL_label"></td></tr></tbody>';
	}
	if ( Val_Statoriga == 'Saved' )
	{
		getObj('RPRODOTTIGrid_' +  i + '_FNZ_DEL').innerHTML = '<tbody><tr><td title=""><img class="img_label_alt" alt="Cancella" src="../images/Domain/../toolbar/Delete_Light.GIF" title="Cancella"></td><td class="nowrap GridCol_Link_label" id="RPRODOTTIGrid_' + i + '_FNZ_DEL_label"></td></tr></tbody>';
	}


	//setto il title sul campo Riferimenti listino ordine
	try 
	{
		objCurrent = getObj('RPRODOTTIGrid_' + i + '_IdRigaRiferimento_edit');
		
		strName = 'RPRODOTTIGrid_' + i + '_IdRigaRiferimento_edit' ;
		
		Old_Onchange = GetProperty( objCurrent ,'onchange') ;	 
		
		if (  Old_Onchange != '' && Old_Onchange.indexOf(";",Old_Onchange.length-1) < 0 )
		{
			Old_Onchange = Old_Onchange + ';' ;
		}	
		
		Old_Onchange = Old_Onchange  + 'SetTitle (\'' + strName + '\');';
		
		objCurrent.setAttribute('onchange', Old_Onchange );	
		
		SetTitle ( strName );
		
	}catch(e)
	{
		//quando la riga non editabile per gestire l'eccezione
	}	
	//fine setto title 
	
	
  }
  
  

}


function SetTitle ( strName )
{
	var obj = getObj( strName );
	
	var len =  obj.value.length * 10 ;
	
	//alert(len);
	
	var ObjVis = getObj( strName + '_new' );
	
	if ( len > $(ObjVis).width() )
	{	
		
		$(ObjVis).attr('title', obj.value );
	} 
	else
	{	
		$(ObjVis).attr('title', '' );	
	
	} 
}



function PRODOTTI_AFTER_COMMAND( com )
{
    
    SetFilterArticoliPrimari();
    
}



function PRODOTTI_OnLoad()
{
    
	
	var DOCUMENT_READONLY = '0';
	
	try
	{
		DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	}
	catch(e)
	{
		
	}
	
	//Se il documento è editabile
	if (DOCUMENT_READONLY == '0')
	{

		SetFilterArticoliPrimari();
		
	}
	
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
		
		url = encodeURIComponent( 'CustomDoc/DM_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=LISTINO_ORDINI_OE&lo=base' );
		NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
		
	}
	else
	{
		ExecFunctionCenter('../../CustomDoc/DM_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=LISTINO_ORDINI_OE' );
	}  
	
	
	
	//alert(IDDOC);
}