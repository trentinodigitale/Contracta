 
 
 
 //window.onload = onloadpage; 
 $( document ).ready(function() {
    OnLoadPage();
});
 function OnLoadPage()
{
	//nascondo le colonne apri,stato,fnz_add
	ShowCol( 'PRODOTTI' , 'FNZ_OPEN' , 'none' );    
	ShowCol( 'PRODOTTI' , 'FNZ_ADD' , 'none' );    
	ShowCol( 'PRODOTTI' , 'StatoRiga' , 'none' );    
}
 



/*
function DownLoadCSV()
{

    var Ambito = getObjValue( 'Ambito' );
    
       
    ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + getObjValue('IDDOC') + '&HIDECOL=&TIPODOC=CARICA_MACROPRODOTTI&MODEL=ELENCO_CODIFICHE_META_PRODOTTI_' + Ambito + '_MOD_Griglia'  , '_blank' ,'');
    
}
*/

function DownLoadCSV() 
{
	
	
	var Ambito = getObjValue( 'Ambito' );
	
	var HideCol = 'FNZ_OPEN,FNZ_ADD,StatoRiga,ESITORIGA';
	
	var HideColExtra = getObjValue( 'HideColExtra' );
	
	if ( HideColExtra != '' )
		HideCol = HideCol + ',' + HideColExtra ;
    
	ExecFunction('../../CTL_Library/accessBarrier.asp?goto=xlsx.aspx&TitoloFile=ListaMacroprodotti&FILTER=&TIPODOC=CARICA_MACROPRODOTTI&MODEL=ELENCO_CODIFICHE_META_PRODOTTI_' + Ambito + '_MOD_Griglia&VIEW=&HIDECOL=' + HideCol +'&Sort=&IDDOC=' + getObjValue('IDDOC'), '_blank', '');
}


function OnClickProdotti( obj )
{
   
    var Ambito = getObjValue( 'Ambito' );
   
    var DOCUMENT_READONLY = getObj( 'DOCUMENT_READONLY' ).value;
    if ( DOCUMENT_READONLY == "1" )
        DMessageBox( '../' , 'Documento in sola lettura' , 'Attenzione' , 1 , 400 , 300 );
    else
        ImportExcel( 'CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=RTESTATA_PRODOTTI_MODEL_Allegato&SHEET=0&PARAM=posizionale&PROCESS=LOAD_PRODOTTI,CARICA_MACROPRODOTTI&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#400,300' );
}