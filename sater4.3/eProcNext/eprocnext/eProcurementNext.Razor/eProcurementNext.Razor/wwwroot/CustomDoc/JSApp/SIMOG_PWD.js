window.onload = onLoadFunc;

function onLoadFunc()
{
	var DOCUMENT_READONLY = '0';
	DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	
	if (DOCUMENT_READONLY == '0')
		getObj('JumpCheck').type = "password";
}