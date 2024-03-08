 
 
 
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
 





function DownLoadCSV() 
{
	
	var HideCol = 'FNZ_OPEN,FNZ_ADD,StatoRiga,ESITORIGA';
    
	ExecFunction('../../CTL_Library/accessBarrier.asp?goto=xlsx.aspx&TitoloFile=ListaIniziativa&FILTER=&TIPODOC=&MODEL=CARICA_INIZIATIVE_DETTAGLI&VIEW=document_programmazione_iniziativa&HIDECOL=' + HideCol +'&Sort=idrow asc&IDDOC=' + getObjValue('IDDOC'), '_blank', '');
}


function OnClickProdotti( obj )
{
   
    
    var DOCUMENT_READONLY = getObj( 'DOCUMENT_READONLY' ).value;
    if ( DOCUMENT_READONLY == "1" )
        DMessageBox( '../' , 'Documento in sola lettura' , 'Attenzione' , 1 , 400 , 300 );
    else
        ImportExcel( 'CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=RTESTATA_PRODOTTI_MODEL_Allegato&SHEET=0&PARAM=posizionale&PROCESS=LOAD_INIZIATIVE,CARICA_INIZIATIVE&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#400,300' );
}