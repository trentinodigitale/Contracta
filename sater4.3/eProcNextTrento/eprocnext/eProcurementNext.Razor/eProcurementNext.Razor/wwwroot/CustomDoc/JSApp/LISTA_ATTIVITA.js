function Prosegui2(param)
{
	
	var STRURLPARTECIPA='';  
	
	//recupero STRURLPARTECIPA dalla QueryString
	STRURLPARTECIPA = getQSParam('STRURLPARTECIPA');
	
	if (STRURLPARTECIPA == null)
		STRURLPARTECIPA='';


  	Provenienza='LISTA'
  	self.location='../checkattivita.asp?STRURLPARTECIPA=' + escape( STRURLPARTECIPA ) +  '&OpenApplication=1&Provenienza=' + Provenienza + '&lScreen=' + window.screen.availWidth;

    /*
	if( isSingleWin() == true )
	{     
		try
		{
			document.Viewer_Command.location =  'ViewerCommand.asp?IDLISTA=1&PROCESS_PARAM=' + param + '&SHOW_MSG_INFO=no&STRURLPARTECIPA=' + escape( STRURLPARTECIPA ) ;	
		}
		catch(e)
		{
			document.getElementById('Viewer_Command').src = 'ViewerCommand.asp?IDLISTA=1&PROCESS_PARAM=' + param + '&SHOW_MSG_INFO=no&STRURLPARTECIPA=' + escape( STRURLPARTECIPA );
		}
	}
	else
	{
		windows.location = parent.ViewerGriglia.location;
		parent.Viewer_Command.location =  'ViewerCommand.asp?IDLISTA=1&PROCESS_PARAM=' + param + '&SHOW_MSG_INFO=no&STRURLPARTECIPA=' + escape( STRURLPARTECIPA ) ;
	}
    */
}


function Prosegui(){

		
	
	var STRURLPARTECIPA='';
  
  try{
    STRURLPARTECIPA= getObjPage( "STRURLPARTECIPA", "parent").value ;
	}catch(e){}
	
	if ( ( GridViewer_NumRow == 0 && getObj('GridViewer_idRow_0').value == -1 ) )	
	{
		Provenienza='LISTA'
		self.location='../checkattivita.asp?STRURLPARTECIPA=' + escape( STRURLPARTECIPA ) +  '&OpenApplication=1&Provenienza=' + Provenienza + '&lScreen=' + window.screen.availWidth;
	}else{
		
			if( isApplicationAccessible() == true )
			{
				
				window.location = window.location + '&FilterHide= id <> -1' ;
				document.Viewer_Command.location =  'ViewerCommand.asp?IDLISTA=1&PROCESS_PARAM=PROSEGUI,COM_DPE_FORNITORE&SHOW_MSG_INFO=no';
			}
			else
			{
				//parent.ViewerGriglia.location = parent.ViewerGriglia.location + '&FilterHide= id <> -1' ;
				parent.ViewerGriglia.location = parent.ViewerGriglia.location;  
				parent.Viewer_Command.location =  'ViewerCommand.asp?IDLISTA=1&PROCESS_PARAM=PROSEGUI,COM_DPE_FORNITORE&SHOW_MSG_INFO=no';
			}
		
	
		 }
}


function Salta(){
	
	
	try{
  	var STRURLPARTECIPA='';
    
    STRURLPARTECIPA = getQSParam('STRURLPARTECIPA');
    if (STRURLPARTECIPA == null)
      STRURLPARTECIPA='';
  	
  	if ( GridViewer_NumRow == -1 )
  	{
  		Provenienza='LISTA'
  		self.location='../checkattivita.asp?STRURLPARTECIPA=' + escape( STRURLPARTECIPA ) +  '&OpenApplication=0&Provenienza=' + Provenienza + '&lScreen=' + window.screen.availWidth;
  	}
  }catch(e){
  }
  
}


//per aprire i documenti dalla lista ATV
function OpenDocFromListaATV( objGrid , Row , c )
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

	var strDoc='DOCUMENTO_GENERICO';
  
  try	{ 	strDoc = getObjValue( 'R' + Row + '_OPEN_DOC_NAME');	}catch( e ) {};
	
	if ( strDoc == undefined ) 
	{
    	strDoc='DOCUMENTO_GENERICO';
	}
  
  
    
	var strStatoDoc = 'Sended';
  
  try {  
    strStatoDoc = getObjGrid('val_R' + Row + '_StatoDoc').value;  
  }catch(e) {
    strStatoDoc = getObjGrid('R' + Row + '_StatoDoc').value;
  }
  
  if ( strDoc != 'DOCUMENTO_GENERICO' ){
      
      //NUOVI DOCUMENTI
      if ( strStatoDoc == 'Saved' )
        //apertura in mod. editabile 
        LoadDoc( strDoc , cod );
      
      else{
      
          var v = strDoc.split( '.' );
	     		if ( v.length > 1 )
			    {
			     strDoc = v[0];
			    }

        if ( isApplicationAccessible() == true )
        {
			url = pathRoot + 'ctl_library/path.asp?url=' + encodeURIComponent('dashboard/reportDocument.asp?lo=lista_attivita&Provenienza=LISTA_ATV&IDDOC=' + cod + '&DOCUMENT=' + strDoc);
			url = url + '&KEY=DOCUMENT';	
			ExecFunctionSelf(url,'','');
        }
        else
        {			
            //apertura in mod. stampa
            ExecFunction('PrnDocPortale.asp?Provenienza=LISTA_ATV&COD=' + cod + '&DOCUMENT=' + strDoc , 'Content' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
        }	
      }

	}else{
	    
	    //DOCUMENTO GENERICO
  		if ( strStatoDoc == 'Saved' )
  	
    		//apertura in mod. editabile 
  	    ExecFunction('../Aflcommon/FolderGeneric/OpenDoc.asp?lIdMsgPar=' + cod + '&Name=' + strDoc + '&lIdmpPar=1&StrCommandPar=OPENDOC' , 'Content' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  ); 
    		
  		else
        //apertura in mod. stampa
        ExecFunction('../Aflcommon/FolderGeneric/PrintDoc.asp?Provenienza=LISTA_ATV&FileTemplate=bandocentrico&lIdmpPar=1&StrCommandPar=PRINT&ProvenienzaPortale=1&lIdMsgPar=' + cod + '&Name=' + strDoc , 'Content' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );			
      
  }
  
  
}


window.onload = Salta ;

