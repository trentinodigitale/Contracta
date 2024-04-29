function OpenDettaglio(  )
{
	var altro;
	var cod;
	var nq;   
	var strDoc='';
	var w;
	var h;
	var Left;
	var Top;
	var tmpVirtualDir;
	
	try { strDoc = getObj('DOCUMENT').value; } catch( e ) {};
	
	cod=prendiElementoDaId('ID_FROM').value;

	tmpVirtualDir = '/Application';

	if ( isSingleWin() )
		tmpVirtualDir = urlPortale;
    
	w = screen.availWidth * 0.72;
	h = screen.availHeight  * 0.72;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;

	parent.location = tmpVirtualDir + '/Aflcommon/FolderGeneric/PrintDoc.asp?FileTemplate=Portale&lIdMsgPar=' + cod + '&Name=' + strDoc + '&lIdmpPar=1&StrCommandPar=OPENDOC&ProvenienzaPortale=1' ;
	
}