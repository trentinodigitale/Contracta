
function DownLoadXLSX()
{
   ExecFunction('../../CTL_Library/accessBarrier.asp?goto=xlsx.aspx&TitoloFile=Elenco_Valori_Dominio&TIPODOC=&FILTERHIDE=DMV_DM_ID=\'DOMINIO\'&MODEL=GESTIONE_DOMINIO_VALORI&VIEW=CTL_DomainValues&HIDECOL=&Sort=DMV_Father asc&IDDOC=' + getObjValue('IDDOC'), '_blank', '');
}

function DownLoadXLSXLNG()
{
   ExecFunction('../../CTL_Library/accessBarrier.asp?goto=xlsx.aspx&TitoloFile=Elenco_Descrizioni_lingua&TIPODOC=&FILTERHIDE=DMV_DM_ID=\'LNG_DESC\'&MODEL=GESTIONE_DOMINIO_LINGUA&VIEW=CTL_DomainValues&HIDECOL=&Sort=DMV_COD asc&IDDOC=' + getObjValue('IDDOC'), '_blank', '');
}


function UpLoadXLSX(obj)
{
    var DOCUMENT_READONLY = getObjValue('DOCUMENT_READONLY');	

    if (DOCUMENT_READONLY == "1")
        DMessageBox('../', 'Documento in sola lettura', 'Attenzione', 1, 400, 300);
    else
        ImportExcel('CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=&SHEET=0&PARAM=posizionale&PROCESS=LOAD_PRODOTTI,GESTIONE_DOMINIO_VALORI&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#400,300');
}

function UpLoadXLSXLNG(obj)
{
    var DOCUMENT_READONLY = getObjValue('DOCUMENT_READONLY');	

    if (DOCUMENT_READONLY == "1")
        DMessageBox('../', 'Documento in sola lettura', 'Attenzione', 1, 400, 300);
    else
        ImportExcel('CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=&SHEET=0&PARAM=posizionale&PROCESS=LOAD_PRODOTTI,GESTIONE_DOMINIO_LINGUA&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#400,300');
}
