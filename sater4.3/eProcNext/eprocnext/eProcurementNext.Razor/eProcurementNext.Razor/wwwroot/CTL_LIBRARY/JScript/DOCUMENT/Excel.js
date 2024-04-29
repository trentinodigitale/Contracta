
function Excel( )
{
	//debugger;
	var CommandQueryString = getObj('CommandQueryString').value;
	var IDDOC = getObj( 'IDDOC' ).value;
	var TYPEDOC = getObj( 'TYPEDOC' ).value;
	var strPrecTarget;
	
	var objForm=getObj('FORMDOCUMENT');
	
	strPrecTarget=objForm.target;
	objForm.action='Excel.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=EXCEL&OPERATION=EXCEL';
	objForm.target='ExcelDocument';
	
	objForm.submit();
	
	objForm.target=strPrecTarget;
	
}

