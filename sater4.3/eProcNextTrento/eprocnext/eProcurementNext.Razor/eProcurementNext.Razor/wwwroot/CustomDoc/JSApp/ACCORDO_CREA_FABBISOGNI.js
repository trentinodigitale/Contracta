
function MyExcelDestinatari (param)
{
	var win;
	
	param = param + '&IDENTITY=IdHeader&FILTER=Idheader=' + getObj ('IDDOC').value;
	
	win = ExecFunction( '../../dashboard/viewerExcel_x.asp?OPERATION=EXCEL' +  '&'  + param  , '' , '' );
}


