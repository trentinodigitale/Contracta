
//-- cerco la pagna dove si trovano gli attributi estesi
function SearchDocumentForExtendeAttrib()
{
	
	var path = '';
	var i = 1;
	var obj;
	
	
	
	try
	{
		obj =  getObjPage( 'ExtAttrib_' + i + '_div' , path );
		
		while( obj == null && i < 10)
		{
			if ( path == '' )
			{
				path = 'parent';
				
			}
			else
			{
				path = path + '.parent';
			}
			i++;
	
			obj =  getObjPage( 'ExtAttrib_' + i + '_div' , path );
			
		}
		
		if ( i < 10 )
		{
			if ( path == '' )
			{
				return self;
			}
			else
			{
				
				return eval( path ); 
				
			}
		}
		
	}catch( e )
	{
		alert('SearchDocumentForExtendeAttrib errore='+e);
	};
	
	return null;

}


//-- cerca la posizione del controllo navigando le pagine fino alla posizione dei controlli estesi
//-- la funzione attualmente si ferma al livello sottostante andrebbe estesa
function PosTopExt( obj )
{

	var p;
	var t;
	var objDoc = null;
	var start = 0;
	var path = '';
	
	//debugger;
	

	t = obj.offsetTop;
	
	p = obj.offsetParent;

	while( objDoc == null )
	{
	
		while( p != null )
		{
			t += p.offsetTop;
			p = p.offsetParent;	
		}

		//-- verifica se sulla pagina sono presenti i controlli estesi
		//-- in tal caso ci si ferma
		objDoc =  getObjPage( 'ExtAttrib_' + 1 + '_div' , path );
		if ( objDoc == null )
		{
		
		    //-- in questo caso si stà scendendo di livello e bisogna verificare la presenza di scroll 
		    //-- che in tal caso vanno sottratte dalle coordinate
		    
			try { t -= obj.document.body.scrollTop;}catch(e){
				
				try {t -= document.body.scrollTop;} catch(e){}
				
			}
		
			if ( start == 0 )
			{
				p = self.frameElement.offsetParent;
				start = 1;
				path = 'parent';
			}
			else
			{
				//path = path + '.parent';
				//p =eval( path );
				return t;
			}
		}
	}

	
	return t;
}

//-- cerca la posizione del controllo navigando le pagine fino alla posizione dei controlli estesi
//-- la funzione attualmente si ferma al livello sottostante andrebbe estesa
function PosLeftExt( obj )
{


	//debugger;
	var p;
	var t;
	var objDoc = null;
	var start = 0;
	var path = '';
	

	t = obj.offsetLeft;
	
	p = obj.offsetParent;

	while( objDoc == null )
	{
	
		while( p != null )
		{
			t += p.offsetLeft;
			p = p.offsetParent;	
		}

		//-- verifica se sulla pagina sono presenti i controlli estesi
		//-- in tal caso ci si ferma
		objDoc =  getObjPage( 'ExtAttrib_' + 1 + '_div' , path );
		if ( objDoc == null )
		{

		    //-- in questo caso si stà scendendo di livello e bisogna verificare la presenza di scroll 
		    //-- che in tal caso vanno sottratte dalle coordinate
		    try { t -= obj.document.body.scrollLeft; } catch(e){
				
				try { t -= obj.document.body.scrollLeft;} catch(e){}
				
			}
		
			if ( start == 0 )
			{
				p = self.frameElement.offsetParent;
				start = 1;
				path = 'parent';
			}
			else
			{
				//path = path + '.parent';
				//p =eval( path );
				return t;
			}
		}
	}

	
	return t;

}

//--Data la posizione di un controllo posiziona il controllo esteso sopra o sotto 
//-- in funzione dello spazio disponibile
function SetExtFldPositionXY( objSrc , objDivExt )
{
	//debugger;
	var doc = SearchDocumentForExtendeAttrib();
	
	var Y =  PosTopExt( objSrc );
	
	try {
		if( Y + objSrc.offsetHeight + objDivExt.offsetHeight > doc.frameElement.offsetHeight )
		{
			objDivExt.style.top = Y - objDivExt.offsetHeight; 
		}
		else
		{
			objDivExt.style.top = Y + objSrc.offsetHeight; 
		}
	} catch( e ) {
	
		objDivExt.style.top = Y + objSrc.offsetHeight; 
	}
	objDivExt.style.left = PosLeftExt( objSrc );

}
