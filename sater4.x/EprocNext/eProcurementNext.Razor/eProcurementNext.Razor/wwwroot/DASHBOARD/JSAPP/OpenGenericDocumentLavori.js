function OpenGenericDocumentLavori( objGrid , Row , c )
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
  
  if (BrowseInPage != 1)
	   ExecFunction(  '../Aflcommon/FolderGeneric/OpenDoc.asp?lIdMsgPar=' + cod+ '&Name=' + strDoc + '&lIdmpPar=1&StrCommandPar=OPENDOC' , 'OPEN_GENERIC_DOC_' + cod , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
	else
	{
		
		try{
		    parent.parent.parent.getObj('INFO_PROCESS').style.display='';
		    parent.parent.parent.getObj('INFO_PROCESS2').style.display='';
		}catch(e){
			//alert('errore vis loading' );
		};
		
		ExecFunction('../Aflcommon/FolderGeneric/PrintDoc.asp?FileTemplate=bandocentrico&lIdmpPar=1&StrCommandPar=PRINT&ProvenienzaPortale=1&lIdMsgPar=' + cod + '&Name=' + strDoc , 'Content' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );			
		
		
  }
  

}



function OpenRisultatoDiGara( objGrid , Row , c )
{
	var cod;
	var nq;
	var protbando;
	
	cod = prendiElementoDaId('R'+ Row + '_idDoc').value;		
	
	protbando = prendiElementoDaId('R'+ Row + '_ProtocolloBando').value;		
	
	var w;
	var h;
	var Left;
	var Top;
    
	w = screen.availWidth;
	h = screen.availHeight;
	Left=0;
	Top=0;
  
	//var strDoc;
	//strDoc = getObj('DOCUMENT').value;
	
	if (cod != '0')	
		parent.parent.location='../report/light_RisultatoDiGara_int.asp?PROTOCOLLOBANDO='+ escape(protbando) +'&BACKOFFICE=yes&TYPEDOC=RISULTATODIGARA&MODE=OPEN&IDDOC=' + cod ;
	
}