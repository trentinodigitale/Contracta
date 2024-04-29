function MyExcel( param )
{
	
	
	var win;
	
	var FILTER = 'id_origin=' + getObj('IDDOC').value;
	
	param = param + '&IDDOC=' + getObj('IDDOC').value + '&FILTER=' + FILTER ;
	
	//alert(param);
	
	win = ExecFunction( '../../dashboard/viewerExcel_x.asp?OPERATION=EXCEL' +  '&'  + param   , '' , '' );
}