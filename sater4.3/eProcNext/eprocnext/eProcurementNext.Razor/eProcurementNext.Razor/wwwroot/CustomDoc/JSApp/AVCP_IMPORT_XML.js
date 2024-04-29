
function ImportXml ( param )
{
	var IDDOC = getObj( 'IDDOC' ).value;
	
	ExecFunctionCenter( '../functions/FIELD/UploadAttach.asp?PAGE=./UploadXmlAvcp.asp&IDDOC=' + IDDOC + '#new#400,300');
}
