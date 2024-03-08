function PrnDocPortale ( objGrid , Row , c )
{
	
	var cod;
	var nq;

	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
	
	var w;
	var h;
	var Left;
	var Top;
  var StrULR
    
	w = 800; 
	h = 600; 
	Left= (screen.availWidth - 800) / 2;
	Top= (screen.availHeight - 600) / 2;;
  
	var strDoc='';
  try	{ 	
    strDoc = getObjValue( 'R' + Row + '_OPEN_DOC_NAME');	
  }catch( e ) {};
  
	if ( strDoc == undefined ) 
	{
    	strDoc='';
	}
	
	var strStato = '1';
  var strAdvancedState='';
  try {  strStato = getObjGrid('val_R' + Row + '_StatoGD').value;  } catch( e ) {};
  try {  strStato = getObjGrid('R' + Row + '_StatoGD').value;  } catch( e ) {};
  try {  strAdvancedState = getObjGrid('R' + Row + '_advancedstate').value;  } catch( e ) {};

  
	if ( strDoc != ''){
	   
      //apertura nuovo documento
      
      if ( strStato == '1' ){
        
        
        LoadDoc( strDoc , cod );
        
      }else{
        //LoadPrintDoc( strDoc , cod );
        
        //var strURL = '../ctl_library/document/ToPrintDocument.asp?SHOWTOOLBAR=YES&IDDOC=' + cod + '&DOCUMENT=' + strDoc +  '&MODE=SHOW&COMMAND=OPEN&OPERATION=PRINT' ;
		//ExecFunction( strURL , 'Content' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );  
		      ExecFunction('PrnDocPortale.asp?COD=' + cod + '&DOCUMENT=' + strDoc , 'Content' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );	
        
      }
	     
	
  }else{
  	
  	//stampa documento generico
    if (BrowseInPage != 1)
  	   ExecFunction(  '../Aflcommon/FolderGeneric/OpenDoc.asp?lIdMsgPar=' + cod+ '&Name=' + strDoc + '&lIdmpPar=1&StrCommandPar=OPENDOC' , 'OPEN_GENERIC_DOC_' + cod , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
  	else
  	{
  		
  		try{
  		    //parent.parent.parent.getObj('INFO_PROCESS').style.display='';
  		    //parent.parent.parent.getObj('INFO_PROCESS2').style.display='';
  		}catch(e){
  			//alert('errore vis loading' );
  		};
  		
  	  
  		var Cifratura = '0' ;
  		try {  Cifratura = getObjGrid('R' + Row + '_Cifratura').value;  } catch( e ) {};
  		
  		if ( (strStato == '1' || Cifratura == '1') ){
  	
        ExecFunction('../Aflcommon/FolderGeneric/OpenDoc.asp?lIdMsgPar=' + cod+ '&Name=' + strDoc + '&lIdmpPar=1&StrCommandPar=OPENDOC' , 'Content' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  ); 
    		
  		}else
        
        //ExecFunction('../Aflcommon/FolderGeneric/PrintDoc.asp?FileTemplate=bandocentrico&lIdmpPar=1&StrCommandPar=PRINT&ProvenienzaPortale=1&lIdMsgPar=' + cod + '&Name=' + strDoc , 'Content' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );			
        ExecFunction('PrnDocPortale.asp?COD=' + cod + '&DOCUMENT=' + strDoc , 'Content' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );			
  		
    }
  
  }
  
  try{
    parent.parent.parent.Modal.hide();
  }catch(e){
  			//alert('errore chiusura modale' );
  };

}

