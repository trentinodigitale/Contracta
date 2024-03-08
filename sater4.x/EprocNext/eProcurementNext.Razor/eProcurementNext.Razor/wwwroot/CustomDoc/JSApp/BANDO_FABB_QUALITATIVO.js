var flag=0;
var OldValueTipoBando = '';

window.onload = OnLoadPage; 

function DESTINATARI_AFTER_COMMAND( command )
{
	if ( command == 'PAGINAZIONE' )  
	{
		rimuovilente();
	}
}

function OnLoadPage()
{


	rimuovilente();

	//-- per il template
	ShowAttriutoPerRiga();	


}


function OnChangeTemplate( obj )
{
	
	try{
		if( getObjValue( 'RTESTATA_TEMPLATE_MODEL_Template_Elenco') != '')
		{
			ExecDocProcess( 'LOAD_TEMPLATE,BANDO_FABB_QUALITATIVO,,NO_MSG');
		}
	}catch(e){};
	
}


function rimuovilente()
{
  // rimuove la funzione di onclick quando non esiste il questionario
  var onclick = '';
  var numeroRighe0 = GetProperty( getObj('DESTINATARIGrid') , 'numrow');
	if(  Number( numeroRighe0 ) > 0 )
	{
		for( i = 0 ; i <= numeroRighe0 ; i++ )
		{
		 try{
				if( getObjValue('R' + i + '_DESTINATARIGrid_ID_DOC') == '' )
				{
					obj=getObj('R' + i + '_FNZ_OPEN' ).parentElement;
					onclick='';			
					obj.innerHTML = onclick;
				}
			}
		  catch(e){};
		}
	}
}




function RefreshContent()
{
	
	if( getObjValue(   'StatoFunzionale' ) != 'InLavorazione' )
    {
		RefreshDocument('');
	}
	else
	{
		
		ExecDocCommand( 'DESTINATARI_1#RELOAD' );
		
	}
}





function MySend(param)
{
    if( ControlliSend( param ) == -1 ) return -1;
    ExecDocProcess(param);
 
}

function ControlliSend(param)
{
    

  

  	if( GetProperty( getObj('RIFERIMENTIGrid') , 'numrow')==-1)
  	{
  		
      DocShowFolder( 'FLD_RIFERIMENTI' );	   
      tdoc();
      DMessageBox( '../' , 'Compilare correttamente la sezione dei Riferimenti' , 'Attenzione' , 1 , 400 , 300 );
      return -1;
  		
  	}	
  	
    
     
		  

	
}

function CheckData( FieldData , Riferimento , msgVuoto , msgMinoreRif )
{
    if( getObjValue( FieldData ) == '' )
    {
 	    DocShowFolder( 'FLD_COPERTINA' );	   
  		tdoc();
        try{ getObj( FieldData + '_V' ).focus(); }catch( e ) {};
        DMessageBox( '../' , msgVuoto , 'Attenzione' , 1 , 400 , 300 );
        return -1;       
	}

    if( getObjValue( FieldData ) <= Riferimento )
    {
 	    DocShowFolder( 'FLD_COPERTINA' );	   
  		tdoc();
        try{ getObj( FieldData + '_V' ).focus(); }catch( e ){};
        DMessageBox( '../' , msgMinoreRif , 'Attenzione' , 1 , 400 , 300 );
        return -1;       
    }
    
    return 0;
}








function PrintAndSend(param)
{

	
	
    if( ControlliSend( param ) == -1 ) return -1;

	ShowWorkInProgress(true);
	
	ToPrint(param);
}









//-- funzioni per il template

function move( field , row , verso ) 
{
    try
    {
        var f1 = getObj( 'RVALORIGrid_' + row + '_' + field );
        var f2 = getObj( 'RVALORIGrid_' + ( row + verso ) + '_' + field ) ;
        var app;
        app = f1.value;
        f1.value = f2.value;
        f2.value = app
    
    }catch(e){}

}

function ClickDown( grid , r , c )
{
    MoveCols(  r  , 1 );
}

function ClickUp( grid , r , c )
{
    MoveCols(  r  , -1 );
}

function MoveCols( r  , Verso)
{
	move( 'Domanda_Sezione' , r  , Verso );
	move( 'Domanda_Elenco' , r  , Verso );
	move( 'Descrizione' , r  , Verso );
	
	move( 'Domanda_Elenco_edit' , r  , Verso );
	move( 'Domanda_Elenco_edit_new' , r  , Verso );

	RicalcolaIndice();
	ShowAttriutoPerRiga();
}

function ascii (a) { return a.charCodeAt(0); }

function RicalcolaIndice()
{
	try
	{
		var Obj;
		var Row = 0;
		var ixCapitolo = 0;
		var Capitolo = 'A'
		var ixParagrafo = 0;
		var Paragrafo = '';
		var Modulo = 26;
		
		while( getObj( 'RVALORIGrid_' + Row + '_KeyRiga' ) != undefined )
		{
			if ( getObjValue( 'RVALORIGrid_' + Row + '_Domanda_Sezione' ) == 'sezione' )
			{
				if ( ixCapitolo >= Modulo )
				{
					Capitolo = String.fromCharCode( ascii('A') + ( ixCapitolo / Modulo ) - 1) + String.fromCharCode( ascii('A') + ( ixCapitolo % Modulo ));
				}
				else
					Capitolo = String.fromCharCode( ascii('A') + ( ixCapitolo  ));
				
				ixCapitolo += 1;
				ixParagrafo = 0;
				Paragrafo = '';
			}
			else
			{
				ixParagrafo = ixParagrafo + 1;
				Paragrafo = ' - ' + ixParagrafo
			}
			
			SetTextValue( 'RVALORIGrid_' + Row + '_KeyRiga' , Capitolo + Paragrafo );
			Row += 1;
		}
	
	}
	catch(e){};
	
}


function OnChangeTipo( obj )
{
	RicalcolaIndice();
	ShowAttriutoPerRiga();
}


function ShowAttriutoPerRiga()
{
	try
	{
		var Obj;
		var Row = 0;
		var ixCapitolo = 0;
		var Capitolo = 'A'
		var ixParagrafo = 0;
		var Paragrafo = '';
		var Modulo = 26;
		if( getObjValue( 'StatoFunzionale') == 'InLavorazione' )
		{
			while( getObj( 'RVALORIGrid_' + Row + '_KeyRiga' ) != undefined )
			{
				if ( getObjValue( 'RVALORIGrid_' + Row + '_Domanda_Sezione' ) == 'sezione' )
				{
					getObj( 'RVALORIGrid_' + Row + '_Domanda_Elenco_edit' ).parentElement.parentElement.style.display = 'none';
					getObj( 'RVALORIGrid_' + Row + '_Descrizione' ).style.display = '';
				}
				else if ( getObjValue( 'RVALORIGrid_' + Row + '_Domanda_Sezione' ) == 'domanda' )
				{
					getObj( 'RVALORIGrid_' + Row + '_Domanda_Elenco_edit' ).parentElement.parentElement.style.display = '';
					getObj( 'RVALORIGrid_' + Row + '_Descrizione' ).style.display = 'none';
				}
				else
				{
					getObj( 'RVALORIGrid_' + Row + '_Domanda_Elenco_edit' ).parentElement.parentElement.style.display = 'none';
					getObj( 'RVALORIGrid_' + Row + '_Descrizione' ).style.display = 'none';
				}
				
				Row += 1;
			}
		}
	}
	catch(e){};
	
}




function afterProcess( param )
{

	if ( param == 'ANTEPRIMA' )
	{
		var DocName = 'QUESTIONARIO_' + getObjValue( 'guid' ).replace(/-/g, '_');
		ShowDocument( DocName  , getObjValue( 'idTemplate' ) )
		
	}
	
}