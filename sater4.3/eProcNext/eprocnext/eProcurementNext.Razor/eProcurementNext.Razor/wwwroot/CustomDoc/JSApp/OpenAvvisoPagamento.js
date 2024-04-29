

function OpenAvvisoPagamento( objGrid , Row , c )
{
	var cod;
	var nq;

	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
	
	var w;
	var h;
	var Left;
	var Top;
    
	w = 800; 
	h = 600; 
	Left= (screen.availWidth - 800) / 2;
	Top= (screen.availHeight - 600) / 2;;
  
	var strDoc;
	strDoc = getObj('DOCUMENT').value;
	
//	ExecFunction(  '../CTL_Library/Document/document.asp?DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + cod  , 'COMMISSIONE_DOC_' + cod , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );


	//ExecFunction(  '../Aflcommon/FolderGeneric/OpenDoc.asp?lIdMsgPar=' + cod+ '&Name=' + strDoc + '&lIdmpPar=1&StrCommandPar=OPENDOC&strFunctionContext=P&ProvenienzaDocCollegato=' , 'OPEN_GENERIC_DOC_' + cod , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );

	Command_On_Document(cod ,'OPENDOC','IdFatture#IdFatture#55#506~Name;100#DataDistinta;100#NumeroDistinta;100~1');
	//Command_On_Document(36236,'OPENDOC','IdFatture#IdFatture#55#506~Name;100#DataDistinta;100#NumeroDistinta;100~1');
}



function Command_On_Document(lIdMsgDoc,strCommand,strParam)
{
	const_width=690;
	const_height=500;
	sinistra=(screen.width-const_width)/2;
	alto=(screen.height-const_height)/2;
	strParam=escape(strParam);
	strCommand=escape(strCommand);
	strFunctionContext='P';//'<%=strFunctionContext%>';

	strUrl='../AFLCommon/FolderGeneric/COmmand/Document/Command_From_Folder.asp?'
	
	strUrl= strUrl+ 'lIdMsg='+lIdMsgDoc+'&strCommand='+strCommand+'&strParam='+strParam+'&strFunctionContext='+strFunctionContext;	
	
	window.open(strUrl,'Command_On_Document','toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
}

