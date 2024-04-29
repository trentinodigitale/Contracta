

window.onload = Onload_Function;

function Onload_Function()
{
	ShowField();
	
}
/*
function afterProcess( param )
{

	if ( param == 'PUBBLICA' )
	{
		ajax = GetXMLHttpRequest();

		ajax.open("GET",   '../../ctl_library/REFRESH.ASP?COSA=MODEL' , false);
		ajax.send(null);
		
		if(ajax.readyState == 4) 
		{
			if(ajax.status == 404 || ajax.status == 500)
			{
			  alert('Errore invocazione Refresh Modelli.');
			}
		}
	}
	
	
}
*/

function ShowField()
{
	var Domanda_Tipologia = getObjValue( 'RTIPOLOGIA_MODEL_Domanda_Tipologia' );
	
	if ( Domanda_Tipologia == 'Singola' )
	{
		getObj( 'RIGHE' ).style.display = 'none';
	}
	else
	{
		getObj( 'RIGHE' ).style.display = '';
	}
	
	var Domanda_Natura = getObjValue( 'RATTRIBUTO_MODEL_Domanda_Natura' );
	if ( Domanda_Natura != 'Dominio' )
	{
		getObj( 'VALORI' ).style.display = 'none';
		getObj( 'cap_Dominio_Elenco' ).parentElement.parentElement.parentElement.style.display = 'none';
		getObj( 'cap_Dominio_Altro' ).parentElement.parentElement.parentElement.style.display = 'none';
		getObj( 'cap_Domanda_Dom_Visual' ).parentElement.parentElement.parentElement.style.display = 'none';

		getObj( 'cap_NumCaratteri' ).parentElement.parentElement.parentElement.style.display = '';
		getObj( 'cap_NumCaratteri' ).parentElement.parentElement.parentElement.style.display = 'none';
		
		
		if ( Domanda_Natura == 'Numero' )
		{
			getObj( 'cap_Fabb_Operazioni' ).parentElement.parentElement.parentElement.style.display = '';
			getObj( 'cap_NumDec' ).parentElement.parentElement.parentElement.style.display = '';
			getObj( 'cap_NumCaratteri' ).parentElement.parentElement.parentElement.style.display = '';
		}
		else
		{
			getObj( 'cap_Fabb_Operazioni' ).parentElement.parentElement.parentElement.style.display = 'none';
			getObj( 'cap_NumDec' ).parentElement.parentElement.parentElement.style.display = 'none';
		}	
		if ( Domanda_Natura == 'Testo' )
		{
			getObj( 'cap_NumCaratteri' ).parentElement.parentElement.parentElement.style.display = '';
		}
	}
	else
	{
		getObj( 'VALORI' ).style.display = '';
		getObj( 'cap_Dominio_Elenco' ).parentElement.parentElement.parentElement.style.display = '';
		getObj( 'cap_Dominio_Altro' ).parentElement.parentElement.parentElement.style.display = '';
		getObj( 'cap_Domanda_Dom_Visual' ).parentElement.parentElement.parentElement.style.display = '';
		getObj( 'cap_Fabb_Operazioni' ).parentElement.parentElement.parentElement.style.display = 'none';

		getObj( 'cap_NumCaratteri' ).parentElement.parentElement.parentElement.style.display = 'none';
		getObj( 'cap_NumDec' ).parentElement.parentElement.parentElement.style.display = 'none';

	}
	
}



function move( Grid , field , row , verso ) 
{
    try
    {
        var f1 = getObj( 'R' +Grid +'_' + row + '_' + field );
        var f2 = getObj( 'R' +Grid +'_'  + ( row + verso ) + '_' + field ) ;
        var app;
        app = f1.value;
        f1.value = f2.value;
        f2.value = app
    
    }catch(e){}

}

function ClickDown( grid , r , c )
{
	move( grid ,'Descrizione' , r  , 1 );
}


function ClickUp( grid , r , c )
{
	move( grid , 'Descrizione' , r  , -1 );
}


function OnChangeDominio( obj )
{
	try{
		if( getObjValue( 'RATTRIBUTO_MODEL_Dominio_Elenco') != '')
		{
			ExecDocProcess( 'LOAD_DOMINIO,QUESTIONARIO_DOMANDA,,NO_MSG');
		}
	}catch(e){};

	
}