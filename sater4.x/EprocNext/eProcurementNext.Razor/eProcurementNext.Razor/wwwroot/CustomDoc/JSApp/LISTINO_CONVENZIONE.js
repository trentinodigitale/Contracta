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
	
	if ((getObjValue('SIGN_LOCK') =='0' || getObjValue('SIGN_LOCK') =='')   && (Stato=='Inviato') && IdpfuInCharge == tmp_idpfuUtenteCollegato )
		{
		document.getElementById('generapdf').disabled = false; 
		document.getElementById('generapdf').className ="generapdf";
		}
	else
	   {
	   document.getElementById('generapdf').disabled = true; 
	   document.getElementById('generapdf').className ="generapdfdisabled";
	   }

	 
	if ( getObjValue('SIGN_LOCK') != '0'   && (Stato=='Inviato') && IdpfuInCharge == tmp_idpfuUtenteCollegato )
		{
		document.getElementById('editistanza').disabled = false; 
		document.getElementById('editistanza').className ="attachpdf";
		}
	else
	   {
	   document.getElementById('editistanza').disabled = true; 
	   document.getElementById('editistanza').className ="attachpdfdisabled";
	   } 
	if ( getObjValue('SIGN_ATTACH') == ''  &&  (Stato=='Inviato') && getObjValue('SIGN_LOCK') != '0'  && IdpfuInCharge == tmp_idpfuUtenteCollegato  )
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

window.onload = FIRMA_OnLoad;


function GeneraPDF()
{	
	
	ExecDocProcess( 'CONTROLLO_PRODOTTI,LISTINO_CONVENZIONE');
	
}


function afterProcess( param )
{

	var value='';
    var JumpCheck = getObjValue('JumpCheck');
	if ( param == 'CONTROLLO_PRODOTTI' )
    {
		value=controlloEsitoRiga('');
	
		if (value == -1)
		{
			alert( CNV( '../','Sono presenti righe con anomalie.'));
			return ;
		} 
		
		
		if ( JumpCheck == 'RICHIESTA-FIRMA:no' ) 
		{
			PrintPdf('/report/prn_LISTINO_CONVENZIONE.ASP?PDF_NAME=LISTINO_CONVENZIONE');
			return;
		}
		else
		{
			PrintPdfSign('URL=/report/prn_LISTINO_CONVENZIONE.ASP?SIGN=YES&PDF_NAME=LISTINO_CONVENZIONE');
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
	ExecDocProcess( 'SIGN_ERASE_LISTINO,FirmaDigitale');  
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
	
    ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + iddoc + '&TIPODOC=LISTINO_CONVENZIONE&HIDECOL=TipoDoc&OPERATION=&MODEL=MODELLO_BASE_CONVENZIONI_' + Tipomod + '_MOD_PerfListino&HIDECOL=ESITORIGA'  , '_blank' ,'');
    
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
        ImportExcel( 'CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=RTESTATA_PRODOTTI_MODEL_Allegato&SHEET=0&PARAM=posizionale&PROCESS=LOAD_PRODOTTI,LISTINO_CONVENZIONE&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#600,450' );
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
		
		url = encodeURIComponent( 'CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=LISTINO_CONVENZIONE&lo=base' );
		NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
		
	}
	else
	{
		ExecFunctionCenter('../../CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=LISTINO_CONVENZIONE' );
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
		
		url = encodeURIComponent( 'CustomDoc/DM_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=LISTINO_CONVENZIONE&lo=base' );
		NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
		
	}
	else
	{
		ExecFunctionCenter('../../CustomDoc/DM_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=LISTINO_CONVENZIONE' );
	}  
	
	
	
	//alert(IDDOC);
}



