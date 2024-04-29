function ShowDoc_WithCondition( objGrid , Row , c )
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
  
	var strDoc='';
	try { strDoc = getObj('DOCUMENT').value; } catch( e ) {};
	
  var strStato;
  strStato='2';
  
  try {  strStato = getObjGrid('val_R' + Row + '_StatoGD').value;  } catch( e ) {};
    
  if (strStato=='4'){
  
      DMessageBox( '../ctl_library/' , 'Documento Invalidato' , 'Attenzione' , 1 , 400 , 300 );
  
  }else{
	 
   ExecFunction(  '../Aflcommon/FolderGeneric/OpenDoc.asp?lIdMsgPar=' + cod+ '&Name=' + strDoc + '&lIdmpPar=1&StrCommandPar=OPENDOC&strFunctionContext=P&ProvenienzaDocCollegato=' , 'OPEN_GENERIC_DOC_' + cod , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
	
  }
  

}
