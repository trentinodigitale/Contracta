
function Crea_Verbale_Seduta()
{
    var IDSEDUTA = getObjValue( 'guid' );

    var IDTEMPLATE = getObj( 'JumpCheck' ).value;
    
    //recupero info PDA 
 		var IDDOC = getObj( 'LinkedDoc' ).value; //getObj( 'IDDOC' ).value;
		var TYPEDOC = 'BANDO_SDA'; //getObj( 'TYPEDOC' ).value;
    
    ExecFunctionSelf( '../../customdoc/Crea_Verbale_Seduta.asp?IDDOC='+ IDDOC + '&TYPEDOC='+ TYPEDOC + '&IDSEDUTA=' + escape( IDSEDUTA ) + '&IDTEMPLATE=' + escape( IDTEMPLATE ) + '#VerbaleSeduta' )

}

function SelezioneSingola( g , r , c )
{


    for ( i = 0 ; i <= VERBALEGrid_NumRow ; i++ )
    {
        getObj( 'RVERBALEGrid_' + i + '_SelRow' ).checked = false;
    }

    getObj( 'RVERBALEGrid_' + r + '_SelRow' ).checked = true;
    getObj( 'JumpCheck' ).value = getObjValue( 'RVERBALEGrid_' + r + '_guid' ); 

}

function RefreshContent()
{
	var tmpVirtualDir;
	tmpVirtualDir = '/Application';

	if ( isSingleWin() )
		tmpVirtualDir = urlPortale;

    RefreshDocument(tmpVirtualDir + '/CTL_LIBRARY/document/');
}

function DownloadZipPdf()
{
	var IDDOC=getObjValue( 'IDDOC' );
	//ExecFunctionCenter('/Application/CTL_LIBRARY/pdf/zip_pdf.asp?ID=' + IDDOC + '&NOME_FILE=Comunicazioni&VIEW=SEDUTA_SDA_3_CLICK_SIGNATURE&PDF_URL=TO_SIGN%3DYES%26URL%3D%2FCTL_Library%2FDocument%2FToPrintDocument.asp%3F%26TABLE_SIGN%3DCTL_DOC%26lo%3Dprint%26backoffice%3Dyes%26NO_SECTION_PRINT%3DFIRMA%252CRESPONSABILE%26PROCESS%3DDOCUMENT%2540%2540%2540PROTOCOLLA%26MODE%3DSHOW%26COMMAND%3DPRINT%26OPERATION%3DPRINT%26FORCE%5FSIGN%3DYES#DownloadZip#480,360');
	
	var tmpVirtualDir;
	tmpVirtualDir = '/Application';

	if ( isSingleWin() )
		tmpVirtualDir = urlPortale;
	
	ExecFunctionCenter(tmpVirtualDir + '/CTL_LIBRARY/pdf/zip_pdf.asp?ID=' + IDDOC + '&NOME_FILE=Comunicazioni&VIEW=SEDUTA_SDA_3_CLICK_SIGNATURE&PDF_URL=TO_SIGN%3DYES%26URL%3D%2Freport%2F%253CTIPO_DOC%253E.asp%26TABLE_SIGN%3DCTL_DOC%26PROCESS%3DDOCUMENT%2540%2540%2540PROTOCOLLA%26FORCE_SIGN%3DYES#DownloadZip#480,360');
	
}

function UploadZipFirmato()
{
	var IDDOC=getObjValue( 'IDDOC' ) ;
	
	var tmpVirtualDir;
	tmpVirtualDir = '/Application';

	if ( isSingleWin() )
		tmpVirtualDir = urlPortale;
	
	ExecFunctionCenter(tmpVirtualDir + '/ctl_Library/functions/FIELD/UploadAttach.asp?PAGE=../../pdf/importa_zip_pdf.asp&ID=' + IDDOC + '&VIEW=SEDUTA_SDA_3_CLICK_SIGNATURE&PDF_URL=1%261%26TABLE%3Dctl_doc%26IDENTITY%3DId%26AREA%3D%261%3D1#UploadZip#480,360');
}



function ELENCO_OnLoad()
{
	
	
/*if ( getObj('StatoDoc').value != 'Saved')
    {
    ELENCO.location ='../../DASHBOARD/Viewer.asp?ModGriglia=SEDUTA_SDA_COMUNICAZIONI&Table=SEDUTA_SDA_VIEW_COMUNICAZIONI&OWNER=&IDENTITY=ID&TOOLBAR=&PATHTOOLBAR=../customdoc/&JSCRIPT=yes&AreaFiltro=no&HEIGHT=600,600*,600&FilteredOnly=no&Sort=&SortOrder=&DOCUMENT=SEDUTA_SDA&FilterHide=IdHeader=' + getObj('IDDOC').value + '&AreaAdd=no&ACTIVESEL=1&numRowForPag=20' ;
    }
else
{
	
ELENCO.location ='../../DASHBOARD/Viewer.asp?ModGriglia=SEDUTA_SDA_COMUNICAZIONI&Table=SEDUTA_SDA_VIEW_COMUNICAZIONI&OWNER=&IDENTITY=ID&TOOLBAR=SEDUTA_SDA_COMUNICAZIONI_TOOLBAR&PATHTOOLBAR=../customdoc/&JSCRIPT=yes&AreaFiltro=no&HEIGHT=600,600*,600&FilteredOnly=no&Sort=&SortOrder=&DOCUMENT=SEDUTA_SDA&FilterHide=IdHeader=' + getObj('IDDOC').value + '&AreaAdd=no&ACTIVESEL=2&numRowForPag=20' ;
    }*/
	
}



function My_MAIL_SYSTEM( param ){
	

	
	var IdDoc;
	var TypeDoc;
	var lIdMsgPar;
    	var	iType;
	var iSubType;
        var strFilterHide;
  
	IdDoc= getObj( 'IDDOC' ).value;
	TypeDoc=getObj( 'TYPEDOC' ).value;
		
		
	ExecFunctionSelf('../../DASHBOARD/Viewer.asp?OWNER=&lo=base&ModGriglia=DASHBOARD_VIEW_LISTA_MAILGriglia&ModelloFiltro=DASHBOARD_VIEW_LISTA_MAILFiltro&Table=DASHBOARD_VIEW_SEDUTA_SDA_LISTA_MAIL&IDENTITY=ID&DOCUMENT=LISTA_MAIL&PATHTOOLBAR=../CustomDoc/&JSCRIPT=LISTA_MAIL&AreaAdd=no&Caption=Lista Mail&Height=180,100*,210&numRowForPag=20&Sort=MailData&SortOrder=desc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL&ACTIVESEL=2&FilterHide=IdDoc=' + IdDoc +'#INFO_MAIL#900,800');
	
}

window.onload =gestione_bottoni_zip_firme;

function gestione_bottoni_zip_firme()
{
	if (getObj('DOCUMENT_READONLY').value == '1' )
	{
		
		document.getElementById('genera_pdf_buste').disabled = true; 
		document.getElementById('genera_pdf_buste').className ="genera_buste_pdf_disabled";

		document.getElementById('importa_pdf_buste').disabled = true; 
		document.getElementById('importa_pdf_buste').className ="gimporta_buste_pdf_disabled";
		
		
	}
}
