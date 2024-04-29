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

	try{
		getObj('INFO_PROCESS').style.display='';
		getObj('INFO_PROCESS2').style.display='';
	}catch(e){};
	
	//debugger;
	var CommandQueryString = getObj('CommandQueryString').value;
	var IDDOC = getObj( 'IDDOC' ).value;
	var TYPEDOC = getObj( 'TYPEDOC' ).value;
	
	var objForm=getObj('FORMDOCUMENT');
	
	objForm.action='document.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=SAVE';
	//objForm.target=TYPEDOC + '_Command_' + IDDOC;
	objForm.target='';
	
	objForm.submit();

}


function ExecDocCommand( parametri )
{
//	debugger;
	var section;
	var command;
	var param;
	var vet;
	
	
	vet = parametri.split( '#' );
	section = vet[0];
	command = vet[1];
	param = vet[2];
	
	var CommandQueryString = getObj('CommandQueryString').value;
	var IDDOC = getObj( 'IDDOC' ).value;
	var TYPEDOC = getObj( 'TYPEDOC' ).value;
	
	var objForm=getObj('FORMDOCUMENT');
	
	objForm.action='document.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=' + section + '.' + command + '&' + param;
	
	objForm.target=TYPEDOC + '_Command_' + IDDOC;
	
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
	
	try{
		getObj('INFO_PROCESS').style.display='';
		getObj('INFO_PROCESS2').style.display='';
	}catch(e){};
	
	var CommandQueryString = getObj('CommandQueryString').value;
	var IDDOC = getObj( 'IDDOC' ).value;
	var TYPEDOC = getObj( 'TYPEDOC' ).value;
	
	var objForm=getObj('FORMDOCUMENT');
	
	objForm.action='document.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=PROCESS&PROCESS_PARAM=' + parametri;
	//objForm.target=TYPEDOC + '_Command_' + IDDOC;
	objForm.target='';
	
	objForm.submit();

	//window.disableExternalCapture();
	//document.hideFocus = true;

	//blur();


}

function RemoveMessageFromMem(  )
{
	var idMsg;
	var IDDOC = getObj( 'IDDOC' ).value;
	var TYPEDOC = getObj( 'TYPEDOC' ).value;

	idMsg =  'DOC_' + TYPEDOC + '_' + IDDOC 
	document.location = 'document.asp?DOCUMENT=' + TYPEDOC + '&MODE=REMOVE_FROM_MEM&IDDOC=' + IDDOC ;
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
	

	ShowDocument( strDoc , cod );
}

function DocWH( w , h )
{
	DocW = w;
	DocH = h;
}

function ShowDocument( strDoc , cod )
{
/*
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
	
	NewWin = ExecFunction(  '../CTL_Library/Document/document.asp?JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + cod  , strDoc + '_DOC_' + cod , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
	
	
	DocW = 0;
	DocH = 0;

	NewWin.focus();
	
*/

	var NewWin = MakeWinDoc( strDoc , cod );
	NewWin = LoadDoc( strDoc , cod );
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
		DMessageBox( '../CTL_Library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
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
				  
	try{
		if( eval( 'BrowseInPage' ) == 1 )
		{
			Target = 'Content';
		}
	}	catch(e){		}
	
	ExecFunction(  'document.asp?JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + cod  ,  Target , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );


}


function DASH_NewDocumentFrom( parametri )
{
	var altro;

	var cod;
	var nq;

	idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	
	idRow = idRow.replace( '~~~' , ',')
	
	var vet;
	var documento;
	var docfrom;

	vet = parametri.split( '#' );
	documento = vet[0];
	docfrom = vet[1];
	

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
		DMessageBox( '../CTL_Library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
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
	}
  
	//var strDoc;
	//strDoc = getObj('DOCUMENT').value;
	
	ExecFunction(  '../CTL_Library/Document/document.asp?JScript=' + documento + '&DOCUMENT=' + documento + '&MODE=CREATEFROM&PARAM=' + docfrom + ',' + idRow , documento + '_DOC_createfrom' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
	
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
	
	ExecFunction(  strURL + 'JScript=' + documento + '&DOCUMENT=' + documento + '&MODE=CREATEFROM&PARAM=' + docfrom + ',' + idRow +  altroDOC  , documento + '_DOC_createfrom' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
	
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

	var w;
	var h;
	var Left;
	var Top;
    
	w = screen.availWidth * 0.9;
	h = screen.availHeight  * 0.9;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
  
	
	ExecFunction(  'document.asp?UpdateParent=' + UpdParent + '&JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + cod  , strDoc + '_DOC_' + cod , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );

}

//-- apre un documento generico partendo da una colonna di una sezione del documento
//-- Il presupposto è una colonna nascosta che contiene l'id del documento da aprire 
//-- le colonne nascoste devono cominciare con il nome della sezione seguite da Grid , '_ID_DOC' 
function GridSecOpenDocGen( objGrid , Row , c )
{

	var cod;
	var strDoc;

	//-- recupero il codice della riga passata
	{
		cod = getObj( 'R' + Row + '_' + objGrid + '_ID_DOC').value;
	} 


	var w;
	var h;
	var Left;
	var Top;
    
	w = 800; //screen.availWidth * 0.9;
	h = 600; //screen.availHeight  * 0.9;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
  
	
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
		DMessageBox( '../CTL_Library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
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
	ExecFunctionCenter( '../functions/FIELD/UploadAttach.asp?PAGE=../../Document/UploadExcel.asp&' + parametri );
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
			obj = getObj('Cell_' + vet[y] );
			obj.style.border = Style;
		}
	}catch( e ) {};
}



function MakeDocFrom( param  )
{
	var nq;

	var strDoc = param.split( '#' )[0];
	var w;
	var h;
	var Left;
	var Top;
	var Param = '';
	try
	{
		Param = param.split( '#' )[1];
	}catch( a ){Param = ''};
    
	w = screen.availWidth * 0.9;
	h = screen.availHeight  * 0.9;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
	
	var IDDOC = getObj( 'IDDOC' ).value;
	var TYPEDOC = getObj( 'TYPEDOC' ).value;

	
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
	var NewWin;
	
		NewWin = ExecFunction(  '../../CTL_Library/Document/MakeDocFrom.asp?TYPE_TO=' + strDoc + '&IDDOC='+ IDDOC + '&TYPEDOC='+ TYPEDOC , strDoc + '_DOC_' + cod ,'left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
	
	
	DocW = 0;
	DocH = 0;

	NewWin.focus();
	return NewWin;
}



function OpenDocFromDossier( idMsg , path )
{
	var nq;

	var w;
	var h;
	var Left;
	var Top;
	var Param = '';
    
	w = screen.availWidth * 0.9;
	h = screen.availHeight  * 0.9;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
	
	var NewWin;
	
	NewWin = ExecFunction(  path  + '../CTL_Library/Document/OpenDocFromDossier.asp?IDDOC=' + idMsg ,'DOSSIER_DOC_' + idMsg ,'left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
	
	NewWin.focus();
	return NewWin;
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
	var nq;
	Target = strDoc + '_DOC_' + cod ;
  try{
		if( eval( 'BrowseInPage' ) == 1 )
		{
			Target = 'Content';
		}
	}	catch(e){		}
	
	NewWin = ExecFunction(  '../CTL_Library/Document/document.asp?JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + cod  ,  Target , '' );
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
