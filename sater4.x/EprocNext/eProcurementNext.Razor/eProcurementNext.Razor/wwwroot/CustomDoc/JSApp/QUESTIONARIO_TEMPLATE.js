


window.onload = Onload_Function;

function Onload_Function()
{
	ShowAttriutoPerRiga();	
}



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

function VALORI_AFTER_COMMAND( param )
{
	ShowAttriutoPerRiga();	
}