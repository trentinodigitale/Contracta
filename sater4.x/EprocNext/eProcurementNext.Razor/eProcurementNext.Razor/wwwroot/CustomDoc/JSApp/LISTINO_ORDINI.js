
window.onload = Init_Listino_Ordini;

function Init_Listino_Ordini()
{
	
	
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


function DownLoadCSV()
{

    var Tipomod = getObjValue( 'Tipo_Modello_Convenzione' );
	var iddoc = getObj('IDDOC').value;
	
    
    if ( Tipomod == '' )
    {
      alert( CNV( '../','E\' necessario selezionare prima il modello'));
      return ;
    }
	
    ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + iddoc + '&TIPODOC=LISTINO_ORDINI&OPERATION=&MODEL=MODELLO_BASE_CONVENZIONI_' + Tipomod + '_MOD_ListinoOrdini&HIDECOL=ESITORIGA,StatoRiga,TipoDoc'  , '_blank' ,'');
    
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
        ImportExcel( 'CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=RTESTATA_PRODOTTI_MODEL_Allegato&SHEET=0&PARAM=posizionale&PROCESS=LOAD_PRODOTTI,LISTINO_ORDINI&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#600,450' );
}



function GetDatiAIC()
{
	ExecDocProcess('SAVE_DOC,AIC,,NO_MSG');
}

function afterProcess( param )
{	
	if ( param == 'SAVE_DOC' )
	{
		ElabAIC();  
	}
	
	if ( param == 'SAVE_DOC_DM' )
	{
		Elab_DM();  
	}
	
}


function ElabAIC()
{
	// IdOfferta
	var IDDOC = getObjValue('IDDOC');
	
	
	
	if ( isSingleWin() )
	{
		var url;
		
		url = encodeURIComponent( 'CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=LISTINO_ORDINI&lo=base' );
		NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
		
	}
	else
	{
		ExecFunctionCenter('../../CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=LISTINO_ORDINI' );
	}  
	
	
	
	//alert(IDDOC);
}



//setta il filtro sul dominio ArticoliPrimari per considerare solo gli articoli della convenzione corrente
function SetFilterArticoliPrimari()
{
  
  
  
  //numRow = eval('PRODOTTIGrid_NumRow') ;
  var numRow = GetProperty( getObj('PRODOTTIGrid') , 'numrow');
  
  var len ;
  
  for( i = 0; i <= numRow ; i++ ){
    
    SetProperty( getObj('RPRODOTTIGrid_' + i + '_ArticoliPrimari'),'filter','SQL_WHERE= c.id=' + getObj('IDDOC').value );
	
	
	SetProperty( getObj('RPRODOTTIGrid_' + i + '_IdRigaRiferimento'),'filter','SQL_WHERE= c.id=' + getObj('LinkedDoc').value );
    
	
	
	//setto til title sul campo Riferimenti listino ordine
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
	//fine setto title 
	
  }
  
  

}

function SetTitle ( strName )
{
	var obj = getObj( strName );
	
	var len =  obj.value.length * 10 ;
	//var strHTMLDiv  = '<div class=Date>' + obj.value + '</div>';
	//var len = $ ( strHTMLDiv ).width(); ;
	
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

/*
<script type="text/javascript">
    $(document).ready(function () {
        $("#chkText").on('input', function () {
            var lng = $("#chkText").val().length;
            $("#chkText").width(lng * 10);
        });
    });
</script>

*/


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
		
		url = encodeURIComponent( 'CustomDoc/DM_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=LISTINO_ORDINI&lo=base' );
		NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
		
	}
	else
	{
		ExecFunctionCenter('../../CustomDoc/DM_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=LISTINO_ORDINI' );
	}  
	
	
	
	//alert(IDDOC);
}



