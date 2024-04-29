//DEV

//--disable right mouse click Script 
//document.onmousedown="if (event.button==2) return false"; 
//document.oncontextmenu=new Function("return false"); 

var DocW = 0;
var DocH = 0;

document.onkeydown = showDown; 

function showDown(evt) { 
	evt = (evt)? evt : ((event)? event : null); 
	if (evt) { 
		
		if (event.keyCode == 8 && (event.srcElement.type!= "text" && event.srcElement.type!= "textarea" && event.srcElement.type!= "password")) { 
			// When backspace is pressed but not in form element 
			cancelKey(evt); 
		} 
		else 
		
		if (event.keyCode == 116) { 
			// When F5 is pressed 
			cancelKey(evt); 
		} 
		
		else if (event.keyCode == 122) { 
			// When F11 is pressed 
			cancelKey(evt); 
		} 
		
		//else if (event.ctrlKey && (event.keyCode == 78 ¦¦ event.keyCode == 82)){
		else if (event.ctrlKey && ( event.keyCode == 78 || event.keyCode == 82)) {
			// When ctrl is pressed with R or N 
			cancelKey(evt); 
		} 
		
		else if (event.altKey && event.keyCode==37 ) { 
			// stop Alt left cursor 
			return false; 
		} 
		
		
	} 
} 

function cancelKey(evt) { 
	if (evt.preventDefault) { 
		evt.preventDefault(); 
		return false; 
	} 
	else { 
		evt.keyCode = 0; 
		evt.returnValue = false; 
	} 
} 


function SaveDoc( )
{

    ShowWorkInProgress();
//	try
//	{
//		getObj('INFO_PROCESS').style.display='block';
//	}
//	catch(e)
//	{}

//	try
//	{
//		getObj('INFO_PROCESS2').style.display='block';
//	}
//	catch(e)
//	{}	
	
	//debugger;
	var CommandQueryString = getObj('CommandQueryString').value;
	var IDDOC = getObj( 'IDDOC' ).value;
	var TYPEDOC = getObj( 'TYPEDOC' ).value;
	
	var objForm=getObj('FORMDOCUMENT');
	
	objForm.action='document.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=SAVE';
	//objForm.target=TYPEDOC + '_Command_' + IDDOC;
	objForm.target='';

	try{  CloseRTE() }catch(e){};
	
	objForm.submit();

}


function ExecDocCommand( parametri )
{
//	debugger;
	var section;
	var command;
	var param;
	var vet;
	
	//abilito il work in progress sul chiamante
	try{
		parent.opener.ShowWorkInProgress(true);
	}catch( e ){ ShowWorkInProgress(true); };
	
	vet = parametri.split( '#' );
	section = vet[0];
	command = vet[1];
	param = vet[2];
	
	var CommandQueryString = getObj('CommandQueryString').value;
	
	var IDDOC = getObj( 'IDDOC' ).value;
	var TYPEDOC = getObj( 'TYPEDOC' ).value;
	
	var objForm=getObj('FORMDOCUMENT');
	
	
	
	if (section != '')
	{
		CommandQueryString=CommandQueryString.replace('lo=base','lo=none');
		objForm.action='document.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=' + section + '.' + command + '&' + param;
		
		objForm.target=TYPEDOC + '_Command_' + IDDOC;
		

	}
	else
	{
	    if ( param != '' )
	        param = '&' + param;
	        
		objForm.action='document.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=' + command + param;
		objForm.target='';
	}
	
	try{  CloseRTE() }catch(e){};
	objForm.submit();



}

function ExecDocCommand2( section , command , param )
{
//	debugger;
	
	var CommandQueryString = getObj('CommandQueryString').value;
	var IDDOC = getObj( 'IDDOC' ).value;
	var TYPEDOC = getObj( 'TYPEDOC' ).value;
	
	var objForm=getObj('FORMDOCUMENT');
	
	//alert( param );
	
	objForm.action='document.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=' + section + '.' + command + '&' + param;
	objForm.target=TYPEDOC + '_Command_' + IDDOC;
	
	try{  CloseRTE() }catch(e){};
	objForm.submit();


}




function RefreshPage( param )
{
	//debugger;
	var CommandQueryString = getObj('CommandQueryString').value;
	var IDDOC = getObj( 'IDDOC' ).value;
	var TYPEDOC = getObj( 'TYPEDOC' ).value;
	
	var objForm=getObj('FORMDOCUMENT');
	
	objForm.action='document.asp?' + param;
	//objForm.target=TYPEDOC + '_Command_' + IDDOC;
	objForm.target='';
	
	try{  CloseRTE() }catch(e){};
	objForm.submit();

}

var bProc = false;

function ExecDocProcess( parametri )
{
//	debugger;
	var section;
	var command;
	var param;
	var vet;
	
	if( bProc == true )
	{
		return;
	}
	bProc = true;
	

    ShowWorkInProgress();
//	try
//	{
//		getObj('INFO_PROCESS').style.display='block';
//	}
//	catch(e)
//	{}

//	try
//	{
//		getObj('INFO_PROCESS2').style.display='block';
//	}
//	catch(e)
//	{}	
	
	var CommandQueryString = getObj('CommandQueryString').value;
	var IDDOC = getObj( 'IDDOC' ).value;
	var TYPEDOC = getObj( 'TYPEDOC' ).value;
	
	var objForm=getObj('FORMDOCUMENT');
	
	objForm.action='document.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=PROCESS&PROCESS_PARAM=' + parametri;
	//objForm.target=TYPEDOC + '_Command_' + IDDOC;
	objForm.target='';
	
	try{  CloseRTE() }catch(e){};
	objForm.submit();

	//window.disableExternalCapture();
	//document.hideFocus = true;

	//blur();


}

function RemoveMessageFromMem()
{
	var idMsg;
	var IDDOC = getObj( 'IDDOC' ).value;
	var TYPEDOC = getObj( 'TYPEDOC' ).value;

	idMsg =  'DOC_' + TYPEDOC + '_' + IDDOC 
	document.location = 'document.asp?DOCUMENT=' + TYPEDOC + '&MODE=REMOVE_FROM_MEM&IDDOC=' + IDDOC ;
	
	if ( isSingleWin() == false)
		self.close();
}


function NewDocument( param )
{
	var idRow;
	var vet;
	var altro;
	
	//debugger;
	vet = param.split( '#' );

	var w;
	var h;
	var Left;
	var Top;
    
    if( vet.length < 3  )
    {
		w = screen.availWidth;
		h = screen.availHeight;
		Left=0;
		Top=0;
	}
	else    
	{
		var d;
		d = vet[2].split( ',' );
		w = d[0];
		h = d[1];
		Left = (screen.availWidth-w)/2;
		Top  = (screen.availHeight-h)/2;
		
		if( vet.length > 3 )
		{
			altro = vet[3];
		}
	}
  
	
	ExecFunction(  vet[0]  , vet[1] , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );

}

function OpenDocument( objGrid , Row , c )
{
	var cod;
	var nq;

	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
	

  
	var strDoc;
	strDoc = getObj('DOCUMENT').value;
	
	ShowDocument( strDoc , cod );
}

function OpenDocumentColumn( objGrid , Row , c )
{
	var cod;
	var nq;

	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
 
	var strDoc = '';
	
	try	{ 	strDoc = getObj( 'R' + Row + '_OPEN_DOC_NAME').value;	}catch( e ) {};
	
	if ( strDoc == '' || strDoc == undefined )
	{
		try	{ 	strDoc = getObj( 'R' + Row + '_OPEN_DOC_NAME')[0].value; }catch( e ) {};
	}
	
	if ( strDoc == '' || strDoc == undefined ) 
	{
		alert( 'Errore tecnico - ' +  'R' + Row + '_OPEN_DOC_NAME - non trovato' );
		return;
	}
	
	
	
	//se strDoc contiene CheckTypeViewer.asp? allora redirect alla pagina per controllare
	//se aprire una lista oppure 1 doc altrimenti come adesso
	if (strDoc.indexOf('CheckTypeViewer.asp?')>=0){
    
    var Target =  'CheckTypeViewer_DOC_' + cod;
				  
	  try{
		  if( eval( 'BrowseInPage' ) == 1 )
		    Target = 'Content';
	  }	catch(e){		}
    
    //apro pagina per capire se aprire una lista oppure un documento
    var NewWin = MakeWinDoc( 'CheckTypeViewer' , cod );
	  NewWin = ExecFunction(  strDoc ,  Target , '' );
	  NewWin.focus();
	  return NewWin;
	
    
  }else{
		
    if ( strDoc == 'DOCUMENTO_GENERICO')
      
  		GridSecOpenDocGen( objGrid , Row , c )
  				
  	else
  		
  		ShowDocument( strDoc , cod );
	}
}

function DocWH( w , h )
{
	DocW = w;
	DocH = h;
}

function ShowDocument( strDoc , cod )
{
    var localPath = '';
	
	//Testo la presenza del campo hidden per capire se mi trovo su un documento o su un viewer
	if ( getObj('DOCUMENT_READONLY') )
	{
		localPath = '../';
	}
	
    return ShowDocumentPath( strDoc , cod  , localPath, extraParam );
   
}

function ShowDocumentPath( strDoc , cod  , path)
{
	var NewWin = MakeWinDoc( strDoc , cod );
	NewWin = LoadDocPath( strDoc , cod , path );
	NewWin.focus();
	return NewWin;
}




function ExecCommandFromDash( param )
{
	var idRow;
	var vet;
	var altro;
	var target;
	
	//debugger;
	vet = param.split( '#' );

	var w;
	var h;
	var Left;
	var Top;
	
	target = "Viewer_Command";
    if( vet.length >= 2  )
    {
		target = vet[1];
	}
	
    if( vet.length < 3  )
    {
		w = screen.availWidth;
		h = screen.availHeight;
		Left=0;
		Top=0;
	}
	else    
	{
		var d;
		d = vet[2].split( ',' );
		w = d[0];
		h = d[1];
		Left = (screen.availWidth-w)/2;
		Top  = (screen.availHeight-h)/2;
		
		if( vet.length > 3 )
		{
			altro = vet[3];
		}
	}
  
	
	//-- recupera il codice della riga selezionata
	idRow = GetIdSelectedRow( 'Grid' , 'RadioSel' , 'this' );
	
	if( idRow == '' )
	{
		//alert( "E' necessario selezionare prima una riga" );
		DMessageBox( '../ctl_library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
	}
	else
	{
		ExecFunction(  vet[0] + '&IDROW=' + idRow  , target , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
	}

}


function DisableDoc()
{
	this.blur();
}


function ShowDocumentFromAttrib( param )
{
/*
1- nome documento
2- attributo dove recuperare l'id
3- larghezza
4- altezza
*/	
	var s = param.split(',')
	var strDoc= s[0];
	var cod = getObj( s[1]).value;
	var altro = '';
	
    var v = strDoc.split('#');
	if (v.length > 1)
	{
	    strDoc = v[0];
	    altro  = v[1]; 
	}

	var nq;
	var w ;
	var h ;

	try{
		if (s.length > 2)
		{
			w = s[2];
			h = s[3];
		}
		else
		{

			w = screen.availWidth * 0.9;
			h = screen.availHeight  * 0.9;

		}
	}catch(e){
		w = screen.availWidth * 0.9;
		h = screen.availHeight  * 0.9;

	};
	

	var Left;
	var Top;
    
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
  
	var Target =  strDoc + '_DOC_' + cod;
				  
	try{
		if( eval( 'BrowseInPage' ) == 1 )
		{
			Target = 'Content';
		}
	}	catch(e){		}
	
	ExecFunction(  'document.asp?JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + cod + altro ,  Target , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );


}



function ShowDocumentCTLFromAttrib( param )
{
/*
1- nome documento
2- attributo dove recuperare l'id
3- larghezza
4- altezza
*/	
	var s = param.split(',')
	var strDoc= s[0];
	var cod = getObj( s[1]).value;
	var altro = '';
	
    var v = strDoc.split('#');
	if (v.length > 1)
	{
	    strDoc = v[0];
	    altro  = v[1]; 
	}

	var nq;
	var w ;
	var h ;

	try{
		if (s.length > 2)
		{
			w = s[2];
			h = s[3];
		}
		else
		{

			w = screen.availWidth * 0.9;
			h = screen.availHeight  * 0.9;

		}
	}catch(e){
		w = screen.availWidth * 0.9;
		h = screen.availHeight  * 0.9;

	};
	

	var Left;
	var Top;
    
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
  
	var Target =  strDoc + '_DOC_' + cod;
				  
	try{
		if( eval( 'BrowseInPage' ) == 1 )
		{
			Target = 'Content';
		}
	}	catch(e){		}
	
	if ( isSingleWin() )
	{
		
		url = encodeURIComponent('ctl_library/document/documentCTL.asp?lo=base&IDDOC=' + encodeURIComponent(cod) + altro);

		return ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?reset=&url=' + url + '&KEY=document'   ,  '' , '');
		
	}
	else
	{
		ExecFunction(  'documentCTL.asp?IDDOC=' + cod + altro ,  Target , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
	}

}




function DASH_NewDocumentFrom( parametri )
{
	var altro='';

	var cod;
	var nq;
	var idRow;	
	var vet;
	var documento;
	var docfrom;
	var only_doc;
	var sezione;

	vet = parametri.split( '#' );
	documento = vet[0];
	docfrom = vet[1];
	only_doc= vet[3];
	
	sezione = '';
	
	if( vet.length >= 5  )
		sezione = vet[5];
	
	
	if (sezione != '')
		idRow = Grid_GetIdSelectedRow( sezione + 'Grid' );	
	else
		idRow = Grid_GetIdSelectedRow( 'GridViewer' );	
	
	
	idRow = idRow.replace( /~~~/g, ',')
	
	//verifico presenza path
	//var strPath = '../';
	var strPath = '';
	
	try
	{
		if(  vet.length > 6 )
		{
			strPath = vet[6];
		}
	}
	catch( e )
	{
	}
	
	
	try{
		if (only_doc != '')
		  {
		    z = idRow.split( ',' );
			if(  z.length > 1 ) 
				{
				  DMessageBox( strPath + '../ctl_library/' , 'E\' necessario selezionare una sola riga' , 'Attenzione' , 2 , 400 , 300 );
					return;				  
				}				
		  }

	
	}
	catch( e ) {
	

	}

	try{
		s = docfrom.split( ',' );
		if(  s.length > 1 ) 
		{
			docfrom = s[0];
			idRow = s[1];

		}
	}
	catch( e ) {
	

	}

	if( idRow == '' )
	{
		DMessageBox( strPath + '../ctl_library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
		//alert( "E' necessario selezionare prima una riga" );
		return;
	}
	
	var nq;

	
	var w;
	var h;
	var Left;
	var Top;
    
	w = screen.availWidth * 0.9;
	h = screen.availHeight  * 0.9;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;


     if( vet.length < 4  )
    {
	}
	else    
	{
		var d;
		if ( vet[2] != '' )
		{
		d = vet[2].split( ',' );
		w = d[0];
		h = d[1];
		Left = (screen.availWidth-w)/2;
		Top  = (screen.availHeight-h)/2;
		}
		if( vet.length > 3 )
		{
			altro = vet[4];
		}
	}
  
	//var strDoc;
	//strDoc = getObj('DOCUMENT').value;
	
	//ExecFunction(  '../ctl_library/document/document.asp?JScript=' + documento + '&DOCUMENT=' + documento + '&MODE=CREATEFROM&PARAM=' + docfrom + ',' + idRow , documento + '_DOC_createfrom' + idRow  , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
  //ExecFunction(  '../ctl_library/document/document.asp?JScript=' + documento + '&DOCUMENT=' + documento + '&MODE=CREATEFROM&PARAM=' + docfrom + ',' + idRow , documento + '_DOC_createfrom' + idRow  , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
  ExecFunction(  strPath + '../ctl_library/document/document.asp?JScript=' + documento + '&DOCUMENT=' + documento + '&MODE=CREATEFROM&PARAM=' + docfrom + ',' + idRow , documento + '_DOC_createfrom' + idRow + docfrom , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
    	
}

function DOC_NewDocumentFrom( parametri )
{

	var cod;
	var nq;
	var altro;
	var altroDOC = '';
	var s;
	var strURL = 'document.asp?';

	//alert( idRow );
	
	var vet;
	var documento;
	var docfrom;

	vet = parametri.split( '#' );
	documento = vet[0];
	docfrom = vet[1];

	
	try{
		idRow = getObj('IDDOC').value;
	}
	catch( e ) {
	

	}
	try{
		s = docfrom.split( ',' );
		if(  s.length > 1 ) 
		{
			docfrom = s[0];
			idRow = s[1];
		}
	}
	catch( e ) {
	

	}

	if( idRow == '' )
	{
		DMessageBox( '../' , 'E\' necessario prima il documento' , 'Attenzione' , 1 , 400 , 300 );
		//alert( "E' necessario prima il documento" );
		return;
	}

	
	var nq;

	
	var w;
	var h;
	var Left;
	var Top;
    
	w = screen.availWidth * 0.9;
	h = screen.availHeight  * 0.9;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
 
     if( vet.length < 3  )
    {
	}
	else    
	{
		var d;
		d = vet[2].split( ',' );
		w = d[0];
		h = d[1];
		Left = (screen.availWidth-w)/2;
		Top  = (screen.availHeight-h)/2;
		
		if( vet.length > 3 )
		{
			altro = vet[3];
		}

		if( vet.length > 4 )
		{
			altroDOC = vet[4];
		}
		
		if( vet.length > 5 )
		{
			strURL = vet[5];
		}


	}

 
  
	//var strDoc;
	//strDoc = getObj('IDDOC').value;

	var Target = documento + '_DOC_createfrom' ;// strDoc + '_DOC_' + cod;

	try{
		if( eval( 'BrowseInPage' ) == 1 )
		{
			Target = 'Content';
		}
	}	catch(e){		}

	
	ExecFunction(  strURL + 'JScript=' + documento + '&DOCUMENT=' + documento + '&MODE=CREATEFROM&PARAM=' + docfrom + ',' + idRow +  altroDOC  , Target  , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
	
}
function DMessageBox( path , Text , Title , ICO , w , h)
{


	//var path = document.location.pathname.toUpperCase();
	/*
	var vp = path.split('/');
	
	var i = 0;
	
	alert( vp.length );
	for( i = 0 ; i < vp.length ; i++ )
	{
		if( vp[i] == 'CTL_LIBRARY' )
		{
			path = '/' + vp[ i - 1 ] + '/' + vp[i] + '/';
		
			break;
		}
	
	}
	alert( path );
	*/


	//var w = 400;
	//var h = 250;
	var Left = (screen.availWidth-w)/2;
	var Top  = (screen.availHeight-h)/2;
	var strPosition = ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h ;
		

	ExecFunction( path + 'MessageBoxWin.asp?ML=yes&MSG=' + Text +'&CAPTION=' + Title + '&ICO=' + ICO , 'MSGBOX' , strPosition );


}
//-- apre un documento partendo da una colonna di una sezione del documetno
//-- Il presupposto è una colonna nascosta che contiene l'id del documento da aprire , ed una che contiene il tipo di documento
//-- le colonne nascoste devono cominciare con il nome della sezione seguite da Grid , '_ID_DOC' e '_OPEN_DOC_NAME
function GridSecOpenDoc( objGrid , Row , c )
{

	var cod;
	var strDoc;

	//-- recupero il codice della riga passata
	//if ( getObj( 'R' + Row + '_' + objGrid + '_ID_DOC').count == 0 )
	{
		cod = getObj( 'R' + Row + '_' + objGrid + '_ID_DOC').value;
	} 
	
	//else {
	//	cod = getObj( 'R' + Row + '_' + objGrid + '_ID_DOC')[0].value;
	//}
    
	//-- recupero il documento da aprire
	//if ( getObj( 'R' + Row + '_' + objGrid + '_OPEN_DOC_NAME').count == 0 )
	{
		strDoc = getObj( 'R' + Row + '_' + objGrid + '_OPEN_DOC_NAME').value;
	}
	// else {
	//	strDoc = getObj( 'R' + Row + '_' + objGrid + '_OPEN_DOC_NAME')[0].value;
	//}

	//ShowDocument( strDoc , cod );
	
	var UpdParent = 'no';
	//--recupera il campo nascosto che indica se aggiornare oppure no il chiamante
	try{
		var vu = getObj( 'UpdParent_' + strDoc ).value;
		UpdParent = vu;
	}catch(e){};


	//--recupera il campo nascosto che indica se aggiornare oppure no il chiamante
	try{
		var vu2 = getObj( 'R' + Row + '_' + objGrid + '_UpdParent' ).value;
		UpdParent = vu2;
	}catch(e){};


	var w;
	var h;
	var Left;
	var Top;
    
	w = screen.availWidth * 0.9;
	h = screen.availHeight  * 0.9;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
  
	
	ExecFunction(  'document.asp?UpdateParent=' + UpdParent + '&JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + cod  , strDoc + '_DOC_' + cod , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
	//ShowDocument(strDoc , cod );

}
//-- apre un documento generico partendo da una colonna di una sezione del documento
//-- Il presupposto è una colonna nascosta che contiene l'id del documento da aprire 
//-- le colonne nascoste devono cominciare con il nome della sezione seguite da Grid , '_ID_DOC' 
function GridSecOpenDocGen( objGrid , Row , c )
{

	var cod;
	var strDoc;

	//-- recupero il codice della riga passata
	try{
		cod = getObj( 'R' + Row + '_' + objGrid + '_ID_DOC').value;
	} catch(e){
	  cod = GetIdRow( objGrid , Row , 'self' );
  }


	var w;
	var h;
	var Left;
	var Top;
    
	w = 800; //screen.availWidth * 0.9;
	h = 600; //screen.availHeight  * 0.9;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
  
	if( eval( 'BrowseInPage' ) == 1 )
	 {

		try
		{
			parent.parent.parent.getObj('INFO_PROCESS').style.display='block';
		}
		catch(e)
		{}

		try
		{
			parent.parent.parent.getObj('INFO_PROCESS2').style.display='block';
		}
		catch(e)
		{}			
		
		
		//parent.parent.location= '../Aflcommon/FolderGeneric/OpenDoc.asp?lIdMsgPar=' + cod+ '&Name=' + strDoc + '&lIdmpPar=1&StrCommandPar=OPENDOC';
		
		var strStato = '1';
		var strAdvancedState='';
		try {  strStato = getObjGrid('val_R' + Row + '_StatoGD').value;  } catch( e ) {};
		try {  strStato = getObjGrid('R' + Row + '_StatoGD').value;  } catch( e ) {};
		try {  strAdvancedState = getObjGrid('R' + Row + '_advancedstate').value;  } catch( e ) {};
		
		var Cifratura = '0' ;
		try {  Cifratura = getObjGrid('R' + Row + '_Cifratura').value;  } catch( e ) {};
		
		if ( (strStato == '1' || Cifratura == '1') ){
	
  		//alert('../Aflcommon/FolderGeneric/PrintDoc.asp?FileTemplate=Portale1&lIdmpPar=1&StrCommandPar=OPENDOC&ProvenienzaPortale=1&lIdMsgPar=' + cod + '&Name=' + strDoc);
	    ExecFunction('../Aflcommon/FolderGeneric/OpenDoc.asp?lIdMsgPar=' + cod+ '&Name=' + strDoc + '&lIdmpPar=1&StrCommandPar=OPENDOC' , 'Content' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  ); 
  		
		}else{
		  //controllo come devo aprire la stampa del documento
      var modeOpenPrint=0;
      try{
          modeOpenPrint=parent.parent.parent.SYS_MODALITAAPERTAURASTAMPA ;
      }catch(e){}
      
      strUrlOpen='../Aflcommon/FolderGeneric/PrintDoc.asp?FileTemplate=bandocentrico&lIdmpPar=1&StrCommandPar=PRINT&ProvenienzaPortale=1&lIdMsgPar=' + cod + '&Name=' + strDoc ; 
      
      if ( modeOpenPrint==1 )    
        strUrlOpen= 'PrnDocPortale.asp?COD=' + cod + '&DOCUMENT=';
        
      ExecFunction( strUrlOpen , 'Content' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );			
		}
		
		try{
		    parent.parent.parent.Modal.hide();
		}catch(e){
			//alert('errore chiusura modale' );
		};
  }
  else
	 //ExecFunction(  'document.asp?UpdateParent=' + UpdParent + '&JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + cod  , strDoc + '_DOC_' + cod , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
	 ExecFunction(  '../Aflcommon/FolderGeneric/OpenDoc.asp?lIdMsgPar=' + cod+ '&Name=' + strDoc + '&lIdmpPar=1&StrCommandPar=OPENDOC' , 'OPEN_GENERIC_DOC_' + cod , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );

}


function OpenAllDocument( Param )
{
	var cod;
	var nq;
	try
	{
		
	}catch( e ) { objGrid = 'Grid'; };


	//-- recupera il codice della riga selezionata
	idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	var ListRow = Grid_GetIndSelectedRow( 'GridViewer' );
	
	if( idRow == '' )
	{
		DMessageBox( '../ctl_library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
		return;
	}


	var w;
	var h;
	var Left;
	var Top;

	var vet;
	
	vet = idRow .split( '~~~' );
	var vetRow = ListRow.split ( '~~~' );

	var d;

	if( Param == '' )
	{

		d = Param.split( ',' );
		w = d[0];
		h = d[1];
		Left = (screen.availWidth-w)/2;
		Top  = (screen.availHeight-h)/2;
	}
	else
	{
		w = screen.availWidth * 0.9;
		h = screen.availHeight * 0.9;
		Left=0;	
		Top=0;

	}

    
  
	var RowstrDoc='';
	var strDoc;
	strDoc = getObj('DOCUMENT').value;
	var i = 0;

	try{
		RowstrDoc = getObj( 'R' + vetRow[i] + '_OPEN_DOC_NAME')[0].value;
	} catch( e ) { RowstrDoc = strDoc ;}
	var FirstWin = MakeWinDoc( RowstrDoc , vet[i] );
	for ( i = 1 ; i < vet.length ; i++ )
	{
	
		//ShowDocument( strDoc , vet[i] );
		try{
			RowstrDoc = getObj( 'R' + vetRow[i] + '_OPEN_DOC_NAME')[0].value;
		} catch( e ) { RowstrDoc = strDoc ;}
		MakeWinDoc( RowstrDoc, vet[i] );

	}
	FirstWin.focus();

	for ( i = 0 ; i < vet.length ; i++ )
	{
		try{
			RowstrDoc = getObj( 'R' + vetRow[i]  + '_OPEN_DOC_NAME')[0].value;
		} catch( e ) { RowstrDoc = strDoc ;}
	
		LoadDoc( RowstrDoc, vet[i] );

	}

}

function ImportExcel( parametri )
{
	ExecFunctionCenter( '../functions/FIELD/UploadAttach.asp?PAGE=../../document/UploadExcel.asp&' + parametri );
}

function ImportXml( parametri )
{
	var tmpVirtualDir;
	tmpVirtualDir = '/Application';

	if ( isSingleWin() )
		tmpVirtualDir = urlPortale;
	
	ExecFunctionCenter( tmpVirtualDir + '/ctl_library/functions/FIELD/UploadAttach.asp?PAGE=../../document/UploadExcel.asp&' + parametri );
}


function  ShowEvidenza( field , Style )
{
	try
	{
		
		var v = getObj( field ).value;
		
		while (v.indexOf('  ')>=0)
			v=v.replace('  ',',');
		
		while (v.indexOf(' ')>=0)
			v=v.replace(' ','');
			
		var vet = v.split( ',' );

		var y;
		
		for (  y = 0 ; y <= vet.length ; y++ )
		{
			try
			{
				obj = getObj('Cell_' + vet[y] );
				if (typeof isFaseII !== 'undefined' && isFaseII) {
					if (obj && obj.firstElementChild) {
						const childStyle = getComputedStyle(obj.firstElementChild)
						try {
							if (childStyle.borderWidth && (parseInt(childStyle.borderWidth.split("px")[0]) != 0)) {
								console.log(obj.firstElementChild);
								obj.firstElementChild.style.setProperty('border', Style, 'important');
							} else {
								obj.style.border = Style;
							}

						} catch (ex) {
							obj.style.border = Style;
						}
					} else if(obj) {
						obj.style.border = Style;
					}
				} else {
					obj.style.border = Style;

				}
			}
			catch(e){}
	
		}
	}catch( e ) {};
}



function MakeDocFrom( param, resetBreadCrumb ,UpdateCur )
{
	
	
	//se editabile effettuo il salva in memoria del documento corrente
	try{
		var DOCUMENT_READONLY = getObj( 'DOCUMENT_READONLY' ).value;
		if ( UpdateCur != 'no' )
		{
			if ( DOCUMENT_READONLY != "1" ) 
			{
				UpdateDocInMem( getObj( 'IDDOC' ).value, getObj( 'TYPEDOC' ).value );
			}
		}
	 }catch(e){}		
	
	var nq;
	var NewWin;
    var V = param.split( '#' );
	var strDoc = V[0];
	var w;
	var h;
	var Left;
	var Top;
	var Param = '';
	var cod = 0;
	var idRow;
	var IDDOC;
	var TYPEDOC;
	var BUFFER = '';

	try
	{
		Param = V[1];
	}
	catch( a )
	{
		Param = ''
	}
	
  	if( Param != '' )
	{
		d = Param.split( ',' );
		w = d[0];
		h = d[1];
		Left = (screen.availWidth-w)/2;
		Top  = (screen.availHeight-h)/2;
	}
	else
	{
        w = screen.availWidth * 0.9;
        h = screen.availHeight  * 0.9;
        Left= (screen.availWidth - w) / 2;
        Top= (screen.availHeight - h ) / 2;
    }
	
	try { IDDOC = getObjValue( 'IDDOC' ); }catch( a ){};
	try { TYPEDOC = getObjValue( 'TYPEDOC' ); }catch( a ){};

    //-- verifico la presenza di un from specifico
	try
	{
        if(  V.length > 2 )
        {
			TYPEDOC = V[2];
		}
	}catch( a ){};

    //-- verifico la presenza di un IDDOC specifico
	try
	{
        if(  V.length > 3 )
        {
			if ( V[3]!= '')				
				IDDOC = V[3];
		}

	}catch( a ){};

	//verifico presenza path
	var strPath = '../';
	try
	{
		if(  V.length > 4 )
		{
			strPath = V[4];
		}
	}
	catch( a )
	{
	}

	//verifico presenza selezione da viewer
	try
	{
		if(  V.length > 5 )
		{
			if ( V[5] == 'VIEWER' ) 
			{

				idRow = Grid_GetIdSelectedRow( 'GridViewer' );	
				idRow = idRow.replace( /~~~/g, ',');
				z = idRow.split( ',' );

				if(  z.length != 1 || z == '' ) 
				{
					DMessageBox( '../ctl_library/' , 'E\' necessario selezionare una sola riga' , 'Attenzione' , 2 , 400 , 300 );
					return;				  
				}

				IDDOC = idRow;

			}
		}
	}catch( a ){};

	try
	{
		if(  V.length > 6 )
		{
			if ( V[6] == 'BUFFER' ) 
			{
				idRow = Grid_GetIdSelectedRow( 'GridViewer' );

				if( idRow == '' )
				{
					DMessageBox( '../ctl_library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
					return;
				}
				
				BUFFER = idRow.replace( /~~~/g, ',');
			}
		}

	}
	catch( a ){}

	
	
	try
		{
			NEW_WIN='';
			SHOWCAPTION='';
			if(  V.length > 7 )
			{
				if ( V[7] == 'NEW_WIN' ) 
				{
					NEW_WIN = 'YES';
					SHOWCAPTION='YES';
				}
			}
		}catch(a){}

	//-- ulteriori elementi da aggiungere alla chiamata
	var Altro = '';
	try
	{
		if(  V.length > 8 )
		{
			Altro = '&' + V[8];
		}

	}
	catch( a ){}	
		
	var NewWin;
	
	var strMakeWin='';
  
	var Target = strDoc + '_DOC_FROM_' + IDDOC;
	
	try{
		if( eval( 'BrowseInPage' ) == 1  &&  NEW_WIN !== 'YES' && Altro == '' )
		{
			Target = 'Content';
				
			//visualizzo il loading se lo attivo da un viewer lato bandocentrico
			try
			{
				parent.parent.parent.getObj('INFO_PROCESS').style.display='block';
			}catch(e){}
		
			try
			{
				parent.parent.parent.getObj('INFO_PROCESS2').style.display='block';
			}catch(e){}	
				
			//creo iframe nascosto a volo dove carico la pagina makedocfrom.asp
			var objIFrameHidden = document.createElement('iframe');
			objIFrameHidden.style.display = 'none';
			objIFrameHidden.setAttribute("id","temp_iframe_makedocfrom");
			objIFrameHidden.setAttribute("name","temp_iframe_makedocfrom");
			objIFrameHidden.setAttribute("src","../loading.html");
			objIFrameHidden.setAttribute("height","400");
			objIFrameHidden.setAttribute("width","460");
			document.body.appendChild(objIFrameHidden);

			Target='temp_iframe_makedocfrom';
			
			strMakeWin='&MAKEWIN=YES';
			
			
		}
	}	catch(e){		}

    NewWin = ExecFunction(  strPath + '../ctl_Library/document/MakeDocFrom.asp?TYPE_TO=' + strDoc + '&IDDOC='+ IDDOC + '&NEW_WIN=' + NEW_WIN + '&SHOWCAPTION='+ SHOWCAPTION + '&TYPEDOC='+ TYPEDOC + strMakeWin  +  Altro, Target ,'left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + ',scrollbars=yes' );

	DocW = 0;
	DocH = 0;

	NewWin.focus();
	return NewWin;
}

//-- per le tipologie precedenti si usa la forma tipo;sottotipo
function OpenAnyDoc( idMsg , TypeDoc , path )
{
	var nq;

	var w;
	var h;
	var Left;
	var Top;
	var Param = '';
    
//	w = screen.availWidth * 0.9;
//	h = screen.availHeight  * 0.9;
//	Left= (screen.availWidth - w) / 2;
//	Top= (screen.availHeight - h ) / 2;
	
	var NewWin;
	
  
  if ( TypeDoc == 'DOCUMENTO_GENERICO' )
    TypeDoc ='';
  
  
	MakeWinDoc( TypeDoc , idMsg );
	//NewWin = ExecFunction(  path  + '../ctl_Library/document/OpenDocFromDossier.asp?IDDOC=' + idMsg + '&DOCUMENT=' + TypeDoc,'DOSSIER_DOC_' + idMsg ,'left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
	
	if( TypeDoc.indexOf( ';' ) > -1 || TypeDoc == '' )
	{
        var Target = TypeDoc + '_DOC_' + idMsg ;

	    Target = Target.replace( ';' , '_' );
	    Target = Target.replace( '-' , '_' );
        
   	    try{
		    if( eval( 'BrowseInPage' ) == 1 )
		    {
			    Target = 'Content';
		    }
	    }	catch(e){		}
	    
		if ( isSingleWin() )
		{
			var url;
			TypeDoc = TypeDoc.replace( '-' , '_' );
			url = encodeURIComponent('ctl_library/document/OpenDocFromDossier.asp?lo=base&IDDOC=' + idMsg + '&DOCUMENT=' + TypeDoc,Target  );			
			NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
			
			
		}
		else
		{
			TypeDoc = TypeDoc.replace( '-' , '_' );
			NewWin = ExecFunction(  path  + '../ctl_Library/document/OpenDocFromDossier.asp?IDDOC=' + idMsg + '&DOCUMENT=' + TypeDoc,Target ,'left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
		}  
	
	}
	else
	{
    	//NewWin = LoadDoc( TypeDoc , idMsg );
    	NewWin = LoadDocPath( TypeDoc , idMsg , path );
	}
	
	NewWin.focus();
	return NewWin;
}

function OpenAnyDocGrid( objGrid , Row , c )
{
	var cod;
	var nq;
	var strDoc='';
	
	try	{ 	strDoc = getObjValue( 'R' + Row + '_OPEN_DOC_NAME');	}catch( e ) {};
	
	if ( strDoc == '' || strDoc == undefined ) 
	{
    	strDoc = getObj('DOCUMENT').value;
	}

	if ( strDoc == '' || strDoc == undefined ) 
	{
		alert( 'Errore tecnico - ' +  'R' + Row + '_OPEN_DOC_NAME - non trovato' );
		return;
	}
	
	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
   
 	OpenAnyDoc( cod , strDoc , '' );
}

function OpenDocFromDossier( idMsg , path )
{
    return OpenAnyDoc( idMsg , '' , path )
}


function OpenDocDossier( objGrid , Row , c )
{
	var cod;
	var nq;

	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );

 	OpenDocFromDossier( cod , '' );
}


function MakeWinDoc( strDoc , cod )
{
	var nq;

	
	var w;
	var h;
	var Left;
	var Top;
    
	w = screen.availWidth * 0.9;
	h = screen.availHeight  * 0.9;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
  
	try
	{
		w = DocW;
		h = DocH;
		if ( w == 0 ){w = screen.availWidth  * 0.9;}
		if ( h == 0 ){h = screen.availHeight * 0.9;}
		
		Left= (screen.availWidth - w) / 2;
		Top= (screen.availHeight - h ) / 2;	
	
	}catch( e ) {};
	
	v = strDoc.split( '.' );
	if ( v.length > 1 )
	{
		strDoc = v[0];
		w = Number( v[1] );
		h = Number( v[2] );
		Left= (screen.availWidth - w) / 2;
		Top= (screen.availHeight - h ) / 2;	
	}
	var NewWin;
	var ok = 0;
	var Target =  strDoc + '_DOC_' + cod;
	
	Target = Target.replace( ';' , '_' );
	Target = Target.replace( '-' , '_' );
	
	try{
		if( eval( 'BrowseInPage' ) == 1 )
		{
			Target = 'Content';
		}
	}	catch(e){		}
	
	NewWin = ExecFunction(  ''  , Target , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
	NewWin.document.innerHTML = '<table class="Loading" width="100%" height="100%" ><tr><td width="100%" height="100%" align="center" valign="center" >Loading ...</td></tr></table>';
	
	
	DocW = 0;
	DocH = 0;

	//NewWin.focus();
	return NewWin;
}

function LoadDoc( strDoc , cod )
{
    return  LoadDocPath( strDoc , cod , '' );
}

function LoadDocPath( strDoc , cod , path)
{
	var nq;

	v = strDoc.split( '.' );
	if ( v.length > 1 )
	{
		strDoc = v[0];
	}
	
  var w ;
	var h ;
	try{
		if (v.length > 2)
		{
			w = v[2];
			h = v[3];
		}
		else
		{

			w = screen.availWidth * 0.9;
			h = screen.availHeight  * 0.9;

		}
	}catch(e){
		w = screen.availWidth * 0.9;
		h = screen.availHeight  * 0.9;

	};
	var Left;
	var Top;
    
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
	
	
	Target = strDoc + '_DOC_' + cod ;

	Target = Target.replace( ';' , '_' );
	Target = Target.replace( '-' , '_' );

    try{
		if( eval( 'BrowseInPage' ) == 1 )
		{
			Target = 'Content';
		}
	}	catch(e){		}
	
	NewWin = ExecFunction( path +  '../ctl_library/document/document.asp?JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + cod  ,  Target , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h );
	return 	NewWin ;
}

function ShowDocumentFromAttribModale( param )
{
/*
1- nome documento
2- attributo dove recuperare l'id
3- larghezza
4- altezza
*/	
	var s = param.split(',')
	var strDoc= s[0];
	var  cod = getObj( s[1]).value;

	var nq;
	var w ;
	var h ;

	try{
		if (s.length > 2)
		{
			w = s[2];
			h = s[3];
		}
		else
		{

			w = screen.availWidth * 0.9;
			h = screen.availHeight  * 0.9;

		}
	}catch(e){
		w = screen.availWidth * 0.9;
		h = screen.availHeight  * 0.9;

	};
	

	var Left;
	var Top;
    
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
  
	var Target =  strDoc + '_DOC_' + cod;
				  
	
	parent.OpenModale('../ctl_library/document/modaledocument.asp?JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + cod,Target);
	
	//ExecFunction(  'modaledocument.asp?JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + cod  ,  Target , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );

}


function RefreshDocument( path )
{
	var cod = getObj( 'IDDOC' ).value;
	var strDoc = getObj( 'TYPEDOC' ).value;
    URL =   path + 'document.asp?JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=SHOW&IDDOC=' + cod + '&COMMAND=RELOAD' ;
    Target = 'self';
   	try{
		if( eval( 'BrowseInPage' ) == 1 )
		{
			Target = 'Content';
	        NewWin = ExecFunction(  URL ,  Target , '' );

		}
		else
		{
            self.location =   URL ;
		}
	}	catch(e){		}
}

//../../CTL_Library/updateblacklist.asp?toupdate=' + getObj('guid').value
function execAjaxAsp(url)
{
	ajax = GetXMLHttpRequest(); 

	if(ajax)
	{
			ajax.open("GET", url, false);
			 
			ajax.send(null);
			if(ajax.readyState == 4) {
				if(ajax.status == 200)
				{
					alert(ajax.responseText);
					RefreshDocument('./');
				}
			}

	}
}





function OpenPrint( objGrid , Row , c )
{
	var cod;
	var nq;
	

	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
 
	var strDoc = '';
	
	try	{ 	strDoc = getObj( 'R' + Row + '_OPEN_DOC_NAME').value;	}catch( e ) {};
	
	if ( strDoc == '' || strDoc == undefined )
	{
		try	{ 	strDoc = getObj( 'R' + Row + '_OPEN_DOC_NAME')[0].value; }catch( e ) {};
	}
	
	if ( strDoc == '' || strDoc == undefined ) 
	{
    	strDoc = getObj('DOCUMENT').value;
	}

	if ( strDoc == '' || strDoc == undefined ) 
	{
		alert( 'Errore tecnico - ' +  'R' + Row + '_OPEN_DOC_NAME - non trovato' );
		return;
	}
	

	//ShowDocument( strDoc , cod );
	//var NewWin = MakeWinDoc( strDoc , cod );
	

	
	var w;
	var h;
	var Left;
	var Top;
    
	w = screen.availWidth * 0.9;
	h = screen.availHeight  * 0.9;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
  
	try
	{
		w = DocW;
		h = DocH;
		if ( w == 0 ){w = screen.availWidth  * 0.9;}
		if ( h == 0 ){h = screen.availHeight * 0.9;}
		
		Left= (screen.availWidth - w) / 2;
		Top= (screen.availHeight - h ) / 2;	
	
	}catch( e ) {};
	
	v = strDoc.split( '.' );
	if ( v.length > 1 )
	{
		strDoc = v[0];
		w = Number( v[1] );
		h = Number( v[2] );
		Left= (screen.availWidth - w) / 2;
		Top= (screen.availHeight - h ) / 2;	
	}
	var NewWin;
	var ok = 0;
	var Target =  strDoc + '_PRINT_' + cod;

	try{
		if( eval( 'BrowseInPage' ) == 1 )
		{
			Target = 'Content';
		}
	}	catch(e){		}
	
	NewWin = ExecFunction(  ''  , Target , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
	
	
	
	NewWin.document.innerHTML = '<table class="Loading" width="100%" height="100%" ><tr><td width="100%" height="100%" align="center" valign="center" >Loading ...</td></tr></table>';
	
	
	DocW = 0;
	DocH = 0;

	
	
	NewWin = LoadPrintDoc( strDoc , cod );
	NewWin.focus();
	return NewWin;	
	
}
function LoadPrintDoc( strDoc , cod )
{
	var nq;

	v = strDoc.split( '.' );
	if ( v.length > 1 )
	{
		strDoc = v[0];
	}
	
	
	Target = strDoc + '_PRINT_' + cod ;
    try{
		if( eval( 'BrowseInPage' ) == 1 )
		{
			Target = 'Content';
		}
	}	catch(e){		}


	
	//NewWin = ExecFunction(  '../report/' + strDoc + '.asp?' + 'IDDOC='+ cod + '&TYPEDOC='+ strDoc  ,  Target , '' );
	
	
	//NewWin = ExecFunction(  '../ctl_library/document/print_base_template.asp?IDDOC='+ cod + '&TYPEDOC='+ strDoc  ,  Target , '' );
	
	
	var tmpPath = '../' ;
	
	if ( isSingleWin() )
	{
		tmpPath = pathRoot ;
  }
	   
   NewWin = ExecFunction(  tmpPath + 'ctl_library/document/print_base_template.asp?IDDOC='+ cod + '&TYPEDOC='+ strDoc  ,  Target , '' );
	   
   
	
	return 	NewWin ;
}

function Xml( )
{
	//debugger;
	var CommandQueryString = getObj('CommandQueryString').value;
	var IDDOC = getObj( 'IDDOC' ).value;
	var TYPEDOC = getObj( 'TYPEDOC' ).value;
	var strPrecTarget;
	
	var objForm=getObj('FORMDOCUMENT');
	
	strPrecTarget=objForm.target;
	objForm.action='xml.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=EXCEL&OPERATION=XML&XML_ATTACH_TYPE=2&READONLY=YES';
	objForm.target='XmlDocument';
	
	try{  CloseRTE() }catch(e){};
	objForm.submit();
	
	objForm.target=strPrecTarget;
	

}

  
    
function DocDisplayFolder( name , stato )
{
    var folder = $(".Folder_Label");
    
    if (folder.length > 0 ) 
    {

        for( i = 0  ; i < folder.length ; i++ )
        {
        
            if( folder.get(i).id.toString().substring(0, name.length) == name )
            {
                setVisibility( folder.get(i) , stato ); 
            }
            
        }
    } 
}
//apre un documento generico dalla toolbar di un documento 
function OpenDocGen( param )
{
	/*
1- attributo dove recuperare l'id
2- larghezza
3- altezza
4- strdoc
*/	

	var strDoc='';
	var w;
	var h;
	var Left;
	var Top;
	
	var s = param.split(',')
	
	var cod = getObj( s[0]).value;
	
	try{
		if (s.length > 1)
		{
			w = s[1];
			h = s[2];
		}
		else
		{
			
				w = screen.availWidth * 0.9;
				h = screen.availHeight  * 0.9;
		}
	}catch(e){
		w = screen.availWidth * 0.9;
		h = screen.availHeight  * 0.9;

	};
	
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
	try{
		if (s.length > 3)
		{
			strDoc = s[3];
		}
	}catch(e){}
		
  
	
	//ExecFunction(  'document.asp?UpdateParent=' + UpdParent + '&JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + cod  , strDoc + '_DOC_' + cod , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
	ExecFunction(  '../../Aflcommon/FolderGeneric/OpenDoc.asp?lIdMsgPar=' + cod+ '&Name=' + strDoc + '&lIdmpPar=1&StrCommandPar=OPENDOC' , 'OPEN_GENERIC_DOC_' + cod , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  ).focus();

}

function ScaricaAllegati( param ){
 
  var IDDOC = getObj( 'IDDOC' ).value;
  var TYPEDOC = getObj( 'TYPEDOC' ).value;
  
  var strUrl = 'DownloadAttach.asp?IDDOC=' + IDDOC + '&DOCUMENT=' + TYPEDOC + '&SOURCE' + param ;
  
  ExecFunction( strUrl  , 'ScaricaAllegati' , '');
 
}

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


//esegue un comando sul documento in input
function ExecDocCommandInMem( parametri , IDDOC , TYPEDOC )
{
//	debugger;
	var section;
	var command;
	var param;
	var vet;
	
  param = '';
  
	vet = parametri.split( '#' );
	section = vet[0];
	if( vet.length > 1 )
	{
	    command = '.' + vet[1];
	    if( vet.length > 2 )
	     param = vet[2];
	}
	else
	{
	    command = '';
	    param = '';
	}
	
	//alert(section);
	//alert(command);
	
	//var IDDOC_CURR = getObj( 'IDDOC' ).value;
	//var TYPEDOC_CURR = getObj( 'TYPEDOC' ).value;
	
	//OFFERTA_PARTECIPANTI_Command_58732
	//alert(TYPEDOC_CURR + '_Command_' + IDDOC_CURR);
	
	//var objFrame = getObj(TYPEDOC_CURR + '_Command_' + IDDOC_CURR);
	
	//var objFrame = document.createElement("IFRAME");
  //setVisibility( objFrame, 'none');
  //objFrame.style.display = "none";
  //alert (objFrame);
  
  var tmpPath = '';

	if ( isSingleWin() )
	{
		tmpPath = pathRoot;
	}
	else
	{
		tmpPath = '../../';
	}
  
  var nocache = new Date().getTime();
  
  //OUTPUT MESSO A YES DA CAMBIARE
  var URL_RELOAD =  tmpPath + 'ctl_library/document/userdocument.asp?UPD_STACK=NO&OUTPUT=YES&DOCUMENT=' + TYPEDOC + '&lo=content&IDDOC=' +  encodeURIComponent(IDDOC) + '&MODE=SHOW&COMMAND=' + section + command + '&' + param + '&nocache=' + nocache;
  //objFrame.setAttribute("src", URLREFRESH );
  //alert(URL_RELOAD);
  
  var ajax = GetXMLHttpRequest(); 
  
  
	if(ajax){
				 
		
			ajax.open("GET", URL_RELOAD , false);
			 
			ajax.send(null);
			if(ajax.readyState == 4) {
			   //alert(ajax.status) ;
				if(ajax.status == 200)
				{
					//return ajax.responseText;
					;
				}else{
          alert('errore nel reload della sezione documento ' + parametri );
        }
			}

	}
	
	
	//objFrame.src='document.asp?OUTPUT=NO&DOCUMENT=' + TYPEDOC + '&lo=content&IDDOC=' + IDDOC + '&MODE=SHOW&COMMAND=' + section +  + command + '&' + param;
	
}


function UpdateDocInMem( IDDOC , TYPEDOC )
{
	var aggiorna;
	aggiorna = true;

	//-- se la navigazione è a finestre separate non è necessario aggiornare il server perchè la fiunestra corrente resta aperta
	//-- oppure il documento è non editabile, non è necessario aggiornare la memoria del documento sul server perchè l'utente non ha potuto modificare niente 
	//if ( isSingleWin() && getObjValue('DOCUMENT_READONLY') == '1' )
	if ( !isSingleWin() || getObjValue('DOCUMENT_READONLY') == '1' )
	{
		aggiorna = false;
	}

	if ( aggiorna ) 
	{
		var tmpPath = '';

		if ( isSingleWin() )
		{
			tmpPath = pathRoot;
		}
		else
		{
			tmpPath = '../../';
		}

		var IDDOC = getObj( 'IDDOC' ).value;
		var TYPEDOC = getObj( 'TYPEDOC' ).value;
		var nocache = new Date().getTime();
		var STR_URL =  tmpPath + 'ctl_library/document/document.asp?OUTPUT=NO&DOCUMENT=' + TYPEDOC + '&lo=content&IDDOC=' + IDDOC + '&MODE=SHOW&nocache=' + nocache;
		var FORM_NAME = 'FORMDOCUMENT';

		ShowWorkInProgress(false);

		var bCheck = SEND_FORM_AJAX (  STR_URL, FORM_NAME, null, false );

		if ( ! bCheck )
			alert('errore nel save del documento in memoria');

		ShowWorkInProgress(true);

	}

}


function ReloadDocFromDB( IDDOC , TYPEDOC )
{
  /*
	//debugger;
	//var CommandQueryString = getObj('CommandQueryString').value;
	var IDDOC = getObj( 'IDDOC' ).value;
	var TYPEDOC = getObj( 'TYPEDOC' ).value;
	
	var objForm=getObj('FORMDOCUMENT');
	//alert('document.asp?OUTPUT=NO&DOCUMENT=' + TYPEDOC + '&lo=content&IDDOC=' + IDDOC + '&MODE=SHOW');
	objForm.action='document.asp?OUTPUT=NO&DOCUMENT=' + TYPEDOC + '&lo=content&IDDOC=' + IDDOC + '&MODE=SHOW';
	//objForm.target=TYPEDOC + '_Command_' + IDDOC;
	objForm.target='_blank';
	//alert(objForm.target);
	
	//try{  CloseRTE() }catch(e){};
	objForm.submit();
  //alert(objForm.action);
  */
  
  ShowWorkInProgress(false);
  
	//var linkedDoc = getObjValue('LinkedDoc');
	//var tipoDocChiamante = getObjValue('VersioneLinkedDoc');
	var tmpPath = '';

	if ( isSingleWin() )
	{
		tmpPath = pathRoot;
	}
	else
	{
		tmpPath = '../../';
	}
  
  var nocache = new Date().getTime();
  
	var urlRefreshDocument =  tmpPath + 'ctl_library/document/document.asp?OUTPUT=NO&DOCUMENT=' + TYPEDOC + '&MODE=SHOW&IDDOC=' + IDDOC + '&COMMAND=RELOAD&nocache=' + nocache;

	ajax = GetXMLHttpRequest();

	if(ajax)
	{
		ajax.open("GET", urlRefreshDocument, false);
		ajax.send(null);

		if(ajax.readyState == 4) 
		{
			if(ajax.status == 200)
			{
				//alert('ok');
				;
			}
			else
			{
				alert('errore nel refresh del documento ' + tipoDocChiamante);
			}
		}
	}
	
	ShowWorkInProgress(true);
  
}


function ShowWorkInProgress(nascondi)
{
	var disp = 'block';
	
	try
	{
		if (nascondi === undefined)
		{
			disp = 'block';
		}
		else
		{
			if (nascondi == false)
			{
				disp = ''; 
			}
			else
			{
				disp = 'block';
			}
		}
		
	}
	catch(e)
	{
		disp = 'block';
	}

	try
	{
		getObj('INFO_PROCESS').style.display = disp;
		getObj('INFO_PROCESS').style.height = $( document ).height()+'px';
	}
	catch(e)
	{}

	try
	{
		getObj('INFO_PROCESS2').style.display = disp;
		getObj('INFO_PROCESS2').style.height = $( document ).height()+'px';
	}
	catch(e)
	{}
}



//makedoc from dal viewer sia da un documento generico che per un nuovo documento
function MakeDocFromExetended( objGrid , Row , c ){

 
  //-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
  
  //alert(cod);
  
	var strDoc = '';
	
	try	{ 	strDoc = getObj( 'R' + Row + '_OPEN_DOC_NAME').value;	}catch( e ) {};
	
	if ( strDoc == '' || strDoc == undefined )
	{
		try	{ 	strDoc = getObj( 'R' + Row + '_OPEN_DOC_NAME')[0].value; }catch( e ) {};
	}
	
	if ( strDoc == '' || strDoc == undefined ) 
	{
		alert( 'Errore tecnico - ' +  'R' + Row + '_OPEN_DOC_NAME - non trovato' );
		return;
	}
	
	var TYPEDOC = '';
	
	try	{ 	TYPEDOC = getObj( 'R' + Row + '_MAKE_DOC_NAME').value;	}catch( e ) {};
	
	if ( TYPEDOC == '' || TYPEDOC == undefined )
	{
		try	{ 	TYPEDOC = getObj( 'R' + Row + '_MAKE_DOC_NAME')[0].value; }catch( e ) {};
	}
	
	if ( TYPEDOC == '' || TYPEDOC == undefined ) 
	{
		alert( 'Errore tecnico - ' +  'R' + Row + '_MAKE_DOC_NAME - non trovato' );
		return;
	}
	
	//alert( 'from=' + strDoc + ' to=' + TYPEDOC );
	
  //per i nuovi documenti chiamo makedocfrom (PDA_MICROLOTTI#1024,768#BANDO_GARA#-1##VIEWER)
  
  //per il documento generico chiamo
  //OPEN_CREATE(strParam,IdMsgPar,lIdMp,strFunctionContext,NameSource)
  var param='';
  
  
  if ( TYPEDOC.substr(0,18) == 'DOCUMENTO_GENERICO'){
      
    var Target = TYPEDOC.substr(0,18) + '_DOC_' + cod ;

    Target = Target.replace( ';' , '_' );
    Target = Target.replace( '-' , '_' );
      
 	  try{
	   if( eval( 'BrowseInPage' ) == 1 )
	   {
		  Target = 'Content';
	   }
    }	catch(e){		}
    
    var strUrl = '';
    
    var NameSource = '';
    
    try	{ 	NameSource = getObj( 'R' + Row + '_ProtocolloBando').value;	}catch( e ) {};
	
  	if ( NameSource == '' || NameSource == undefined )
  	{
  		try	{ 	NameSource = getObj( 'R' + Row + '_ProtocolloBando')[0].value; }catch( e ) {};
  	}
  	
    var strParam = TYPEDOC.substr(21, TYPEDOC.length );
    //alert ( strParam ) ;
    
    strUrl='../AFLCommon/FolderGeneric/Command/Document/LinkedMessage.asp?Name='+ escape(NameSource) +'&strCommand=OPEN_CREATE&IdMsgPar='+cod+'&strParam='+escape(strParam)+'&lIdMp=0&strFunctionContext=' ;
    
    w = screen.availWidth * 0.9;
  	h = screen.availHeight  * 0.9;
  	Left= (screen.availWidth - w) / 2;
  	Top= (screen.availHeight - h ) / 2;
    //alert(Target);  
    
    NewWin = ExecFunction(  strUrl ,Target ,'left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
    
  }else{
    
    param =  TYPEDOC + '##' +  strDoc + '#' + cod + '#' ;
	
    MakeDocFrom ( param ) ;
    
    
  }
  
}



function DOC_OpenPrint( objGrid , Row , c ){
  
  OpenPrint( objGrid , Row , c );
  
}
//apre un documento selezionando la riga di un viewer, prende il tipodoc dalla colonna del viewer se non lo trova dai parametri
function DASH_ShowDocumentFromAttrib ( parametri )
{
	var idRow;

	idRow = Grid_GetIdSelectedRow( 'GridViewer' );	
	idRow = idRow.replace( /~~~/g, ',')
	var vet;
	var documento;
	
	vet = parametri.split( '#' );
	//controllo che sia selezionata almeno una riga
	if( idRow == '' )
	{
		DMessageBox( '../ctl_library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
		return;
	}
	
	//controllo che sia selezionato una sola riga
	z = idRow.split( ',' );
	if(  z.length > 1 ) 
	{
		DMessageBox( '../ctl_library/' , 'E\' necessario selezionare una sola riga' , 'Attenzione' , 2 , 400 , 300 );
		return;				  
	}				
	//recupero il tipo documento
	try	{ 	documento = getObj( 'R' + Row + '_OPEN_DOC_NAME').value;	}catch( e ) {};
	
	if ( documento == '' || documento == undefined )
	{
		try	{ 	documento = getObj( 'R' + Row + '_OPEN_DOC_NAME')[0].value; }catch( e ) {};
	}
	if ( documento == '' || documento == undefined )
	{
		try	{documento = vet[0];}catch( e ) {};
	}
	
	var w;
	var h;
	var Left;
	var Top;
    
	w = screen.availWidth * 0.9;
	h = screen.availHeight  * 0.9;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;


     if( vet.length < 4  )
    {
	}
	else    
	{
		var d;
		if ( vet[2] != '' )
		{
		d = vet[2].split( ',' );
		w = d[0];
		h = d[1];
		Left = (screen.availWidth-w)/2;
		Top  = (screen.availHeight-h)/2;
		}
		if( vet.length > 3 )
		{
			altro = vet[4];
		}
	}
	if ( isSingleWin() )
	{
		var url;
		url = encodeURIComponent('ctl_library/document/document.asp?lo=base&JScript=' + documento + '&DOCUMENT=' + documento + '&MODE=OPEN&IDDOC=' + encodeURIComponent(idRow) );
	
		return ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
		
	}
	else
	{
		ExecFunction(  '../ctl_library/document/document.asp?JScript=' + documento + '&DOCUMENT=' + documento + '&MODE=OPEN&IDDOC=' + idRow , 'left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
	}
	
	
	
}

function removeDocFromMem(IDDOC,TYPEDOC)
{
	var nocache = new Date().getTime();
	var tmpPath = '../../';

	if ( isSingleWin() )
	{
		tmpPath = pathRoot;
	}

	var URL_RELOAD =  tmpPath + 'ctl_library/document/document.asp?DOCUMENT=' + TYPEDOC + '&MODE=REMOVE_FROM_MEM&IDDOC=' + IDDOC + '&nocache=' + nocache;
	var ajax = GetXMLHttpRequest();

	if(ajax)
	{
		ajax.open("GET", URL_RELOAD , false);
		ajax.send(null);

		if(ajax.readyState == 4) 
		{
			if(ajax.status != 200)
			{
				alert('errore nel reload del document ' + TYPEDOC );
			}
		}
		else
		{
			alert('errore nel reload del document ' + TYPEDOC );
		}

	}

}





function DOC_SignInitButton()
{
  
	var StatoFunzionale ='';
	var tmp_idpfuUtenteCollegato;

	StatoFunzionale = getObjValue('StatoFunzionale');


	if ( typeof idpfuUtenteCollegato === 'undefined' )
		tmp_idpfuUtenteCollegato = getObjValue('IdpfuInCharge');
	else
		tmp_idpfuUtenteCollegato = 	 idpfuUtenteCollegato;

		
	if ( (getObjValue('SIGN_LOCK') =='0' || getObjValue('SIGN_LOCK') =='')   && StatoFunzionale=='InLavorazione' &&  getObjValue('DOCUMENT_READONLY') != '1' )
	{
		document.getElementById('generapdf').disabled = false; 
		document.getElementById('generapdf').className ="generapdf";
	}
	else
	{
		document.getElementById('generapdf').disabled = true; 
		document.getElementById('generapdf').className ="generapdfdisabled";
	}	

	if ( getObjValue('SIGN_LOCK') != '0'   && StatoFunzionale=='InLavorazione' &&  getObj('IdpfuInCharge').value == tmp_idpfuUtenteCollegato )
	{
		document.getElementById('editistanza').disabled = false; 
		document.getElementById('editistanza').className ="attachpdf";
	}
	else
	{
		document.getElementById('editistanza').disabled = true; 
		document.getElementById('editistanza').className ="attachpdfdisabled";
	} 

	if ( getObjValue('SIGN_ATTACH') == ''  &&  StatoFunzionale=='InLavorazione' &&  getObjValue('SIGN_LOCK') != '0' &&  getObj('IdpfuInCharge').value == tmp_idpfuUtenteCollegato )
	{
		document.getElementById('attachpdf').disabled = false; 
		document.getElementById('attachpdf').className ="editistanza";
	}
	else
	{
		document.getElementById('attachpdf').disabled = true; 
		document.getElementById('attachpdf').className ="editistanzadisabled";
	}
	
}



function DOC_SignErase() 
{
	if ( confirm(CNV('../../', 'Si sta per eliminare il file firmato.')) ) 
	{ 
		ExecDocProcess( 'SIGN_ERASE,DOCUMENT');  
	} 	
}

function MakeDocFromSelecteRows( pageDest )
{
	var NewWin;
	var idRow;
	var strPath = '../';
	var url;
	var lo='';
		
	try
	{
		idRow = Grid_GetIdSelectedRow( 'GridViewer' );

		if( idRow == '' ) 
		{
			DMessageBox( '../ctl_library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
			return;
		}
		
		idRow = idRow.replace( /~~~/g, ',');

	}
	catch( a ){}

	if ( isSingleWin() == false)
	{
		NewWin = ExecFunction(  strPath + '../CustomDoc/' + pageDest + '?ROWS=' + encodeURIComponent(idRow), 'target_new' ,'left=200,top=200,width=900,height=800,scrollbars=yes' );
		NewWin.focus();
	}
	else
	{
		lo=layout;
		url = encodeURIComponent('CustomDoc/' + pageDest + '?lo=base&ROWS=' + encodeURIComponent(idRow));

		ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=GROUP_VIEW' ,  '' , '');
	}

}



function Set_Change_Document()
{
	
	var DOCUMENT_READONLY = '0';
	
	try
	{
		DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	}catch(e){
		//se non esite il campo DOCUMENT_READONLY non sono su un documento
		DOCUMENT_READONLY = '1';
	}
	
	//alert(DOCUMENT_READONLY);
	if (DOCUMENT_READONLY == '0') 
	{
		FLAG_CHANGE_DOCUMENT = 1;
		
	}
	
}

function Set_OnClick_Document()
{
	 //document.title=Date.now();
	 TimeLastClick = Date.now();
}
	
function breadCrumbPop()
{
	
	if ( isSingleWin() == 'YES' )
	{
		if ( document.getElementById('last_breadcrumb') )
		{
			try
			{
				document.getElementById('last_breadcrumb').click();
			}
			catch(e)
			{
				alert('errore nel pop dalle molliche di pane');
			}
		}
		else
		{
			try
			{
				var lastElement = $('a.breadcrumb_element:last')[0].click();
			}
			catch(e){}
		}
	}
	else
	{
		try{ parent.LoadFolder(); }catch(e){self.close();}	
	}
}

/* 
function TxtErr( field )
{
	try{ getObj(field).style.backgroundColor='#FFBE7D'; }catch(e){};
	try{ getObj(field + '_V' ).style.backgroundColor='#FFBE7D'; }catch(e){};
	try{ getObj(field + '_edit' ).style.backgroundColor='#FFBE7D'; }catch(e){};
	try{ getObj(field + '_edit' ).style.backgroundColor='#FFBE7D'; }catch(e){};
	try{ getObj( field  + '_edit_new' ).style.borderColor='#FFBE7D'; }catch(e){};
	try{ getObj(field + '_edit_new' ).style.backgroundColor='#FFBE7D'; }catch(e){};
	
	if ( getObj(field  ).type == 'checkbox' )
	{
		try{ getObj(field  ).offsetParent.style.backgroundColor='#FFBE7D'; }catch(e){};
	}
	try{ getObj(field).style.display = "inline !important";}catch(e){};
}

function TxtOK( field )
{
	
	try{ getObj( field ).style.backgroundColor='#FFF'; }catch(e){};
	try{ getObj( field  + '_V' ).style.backgroundColor='#FFF'; }catch(e){};
	try{ getObj( field  + '_edit' ).style.backgroundColor='#FFF'; }catch(e){};
	try{ getObj( field  + '_edit_new' ).style.borderColor='#FFF'; }catch(e){};
	try{ getObj(field + '_edit_new' ).style.backgroundColor='#FFF'; }catch(e){};
	
	try
	{
		if ( getObj(field).type == 'checkbox' )
		{
			try{ getObj(field  ).offsetParent.style.backgroundColor='#F4F4F4'; }catch(e){};
		}
	}
	catch( e ) 
	{
	}

} */


/*-----------------ReplaceExtended---------------------------------------------
DESCRIZIONE: effettua la replace di tutte le occorrenze di una stringa
input:
  strExpression= la stringa in vui fare la replace
  strFind=la stringa da cercare
  strReplace=la stringa da sostituire
		
output: la nuova stringa
*/
function ReplaceExtended(strExpression,strFind,strReplace){

  while (strExpression.indexOf(strFind)>=0)
  	strExpression=strExpression.replace(strFind,strReplace);
		
  return strExpression;
}

//funzione invocata dopo ogni comando suldocumento 
function DOCUMENT_AFTER_COMMAND( Command, Section_Id, TipoSezione )
{
	//tolgo il workinprogress sul documento
	//ShowWorkInProgress(false);

	if (typeof isFaseII !== 'undefined' && isFaseII) {
		initializeResizableGrids()
	}

}
