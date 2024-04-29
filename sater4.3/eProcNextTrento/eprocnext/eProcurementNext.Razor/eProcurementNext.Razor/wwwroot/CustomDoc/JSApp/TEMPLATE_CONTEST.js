window.onload = Onload_Page;

function Onload_Page()
{

	//nascondo sempre la colonna TEMPLATE_REQUEST_GROUP che contiene identificativo del criterio
	ShowCol( 'VALORI' , 'TEMPLATE_REQUEST_GROUP' , 'none' );
	
	//-- nel caso in cui la versione del template sia inferiore a due nascondiamo le colonne per aprire la sezione
	if( getObj( 'Versione' ).value < '2' )
	{
		ShowCol( 'VALORI' , 'FNZ_OPEN' , 'none' );
		ShowCol( 'VALORI' , 'EsitoRiga' , 'none' );
	}
	
	HideOpenModulo();

}


function HideOpenModulo()
{
	try
	{
		var i = 0 ;
		var Sel = 0;
		var Request_part = '';
		
		obj = getObj( 'RVALORIGrid_' + i + '_FNZ_OPEN' );
		while ( obj )
		{   
			try{
				Request_part = getObjValue( 'RVALORIGrid_' + i + '_REQUEST_PART' );
			}catch(e)
			{
				Request_part = getObjValue( 'RVALORIGrid ' + i + ' REQUEST_PART' );
			}
			
			if ( Request_part != 'Modulo' )
			{
				obj.innerHTML = '';
			}
			else
			{
				Sel = 0;
				if ( getObj( 'RVALORIGrid_' + i + '_SelRow' ).type == 'checkbox' )
				{
					if ( getObj( 'RVALORIGrid_' + i + '_SelRow' ).checked == true ) 
					{
						Sel = '1'
					}
				}
				else
				{
					Sel = getObj( 'RVALORIGrid_' + i + '_SelRow' ).value;
				}
					
				//if( getObj( 'RVALORIGrid_' + i + '_SelRow' ).checked == true )
				if( Sel == '1' )
				{
					getObj( 'RVALORIGrid_' + i + '_FNZ_OPEN' ).style.display = '';
					getObj( 'RVALORIGrid_' + i + '_EsitoRiga_V' ).style.display = '';
				}
				else
				{
					getObj( 'RVALORIGrid_' + i + '_FNZ_OPEN' ).style.display = 'none'; 
					getObj( 'RVALORIGrid_' + i + '_EsitoRiga_V' ).style.display = 'none'; 
				}
			}
			
			i++;
			obj = getObj( 'RVALORIGrid_' + i + '_FNZ_OPEN' );
		}
	}catch(e){}
		
	
}


function afterProcess(param) {

	if (param == 'ADD_EXCEL') 
	{
        CalcPath();
	}
	
	if (param == 'MODULO_TEMPLATE_REQUEST') 
	{
		ShowWorkInProgress();
		setTimeout(function()
		{ 
		
			var nocache = new Date().getTime();

			SUB_AJAX( '../../ctl_library/REFRESH.ASP?COSA=MODEL&nocache=' + nocache );
			
			MakeDocFrom( 'MODULO_TEMPLATE_REQUEST##TEMPLATE' ); 
			
		}, 1 );
	}
	
	if (param == 'FITTIZIO') 
	{
		//-- recupero l'id modulo scelto se presente
		var IDDOC = getObj( 'IDDOC' ).value;

		//-- recupero il codice della riga passata
		var idModulo;
		try{ idModulo = getObj( 'VersioneLinkedDoc' ).value ; }catch(e){}

		
		
		MakeDocFrom( 'MODULO_TEMPLATE_REQUEST##TEMPLATE#' + IDDOC + '#../####URL=' + encodeURIComponent( '../../CustomDoc/TEMPLATE_REQUEST.ASP?CRITERION=' + idModulo + '&VER=2&JSCRIPT=MODULO_TEMPLATE_REQUEST_VER2' ) ,'','');
  		
	}
	
	
}



function ChangeSel( obj )
{
	//-- ciclo su tutti i record allinenado le selezioni
	var v = obj.id.split( '_' );
	var c = obj.checked;
	var selected = false; 
	var ix;
	var e;
	var sez;
	
	//-- recupero la tipologia dell'elemento selezionato 
	var Tipo = getObjValue( 'RVALORIGrid_' + v[1] + '_REQUEST_PART') ;
	var p = getObjValue( 'RVALORIGrid_' + v[1] + '_KeyRiga');
	
	if( Tipo  == 'Parti' || Tipo  == 'Gruppo')
	{
		
		try 
		{
			var ix = v[1];
			ix++;
			//-- finche l'elemento sottostante è nello stesso ramo se è selezionabile applico la stessa selezione della radice
			while( getObj('RVALORIGrid_' + ix + '_KeyRiga' ) != undefined && getObjValue( 'RVALORIGrid_' + ix + '_KeyRiga').substring( 0, p.length ) == p )
			{
				if( getObj('RVALORIGrid_' + ix + '_SelRow' ).type == 'checkbox' )
					getObj('RVALORIGrid_' + ix + '_SelRow' ).checked = c;
				
				ix++;
			}

		
		}
		catch( e ){}
		
		
	}
	
	if( Tipo  == 'Modulo' ||  Tipo  == 'Commenti'  || Tipo  == 'Gruppo' )
	{
		//--verifica se tutti gli elementi  nella sezione  sono deslezionati, in tal caso toglie la spunta anche da sezione 
		ix = v[1];
		ix++;
		e = p.split( '.' );
		sez = e[0] + '.' + e[1];

		//-- mi posiziono sull'ultimo elemento della sezione
		while( getObj('RVALORIGrid_' + ix + '_KeyRiga' ) != undefined && getObjValue( 'RVALORIGrid_' + ix + '_KeyRiga').substring( 0, sez.length ) == sez )
			ix++;
		ix--;
		selected = false; 
		while( ix >= 0 && getObjValue( 'RVALORIGrid_' + ix + '_KeyRiga').substring( 0, sez.length ) == sez && getObjValue( 'RVALORIGrid_' + ix + '_REQUEST_PART') != 'Gruppo' )
		{
			if( getObj('RVALORIGrid_' + ix + '_SelRow' ).type != 'checkbox' )
				selected = true;
			else
				if( getObj('RVALORIGrid_' + ix + '_SelRow' ).checked == true)
					selected = true;
			
			ix--;
		}
		//-- riposiziono l'indice ed aggiorno la sezione
		//ix++;
		getObj('RVALORIGrid_' + ix + '_SelRow' ).checked = selected;
		
	}	

	//--verifica se tutti gli elementi  nella Parte  sono deselezionati, in tal caso toglie la spunta anche dalla parte o la ripristina
	e = p.split( '.' );
	sez = e[0];
	ix = v[1];
	ix++;

	//-- mi posiziono sull'ultimo elemento della parte
	while( getObj('RVALORIGrid_' + ix + '_KeyRiga' ) != undefined && getObjValue( 'RVALORIGrid_' + ix + '_KeyRiga').substring( 0, sez.length ) == sez )
		ix++;
	ix--;
	selected = false; 
	while( ix >= 0 && getObjValue( 'RVALORIGrid_' + ix + '_KeyRiga').substring( 0, sez.length ) == sez  && getObjValue( 'RVALORIGrid_' + ix + '_REQUEST_PART') != 'Parti' )
	{
		if( getObj('RVALORIGrid_' + ix + '_SelRow' ).type != 'checkbox' )
			selected = true;
		else
			if( getObj('RVALORIGrid_' + ix + '_SelRow' ).checked == true)
				selected = true;
		
		ix--;
	}
	//-- riposiziono l'indice ed aggiorno la sezione
	//ix++;
	getObj('RVALORIGrid_' + ix + '_SelRow' ).checked = selected;		
	
	//-- correggo la visualizzazione dei comandi per aprire i moduli
	HideOpenModulo();
}


function OpenModulo( objGrid , Row , c )
{
	var cod;
	var nq;
	var strDoc='';
	var IDDOC = getObj( 'IDDOC' ).value;

	//-- recupero il codice della riga passata
	idModulo = getObj( 'RVALORIGrid_' + Row + '_idModulo' ).value;
	try{ getObj( 'VersioneLinkedDoc' ).value = idModulo; }catch(e){}

	
	//se esiste la varibile globale che indica cambiamenti la testo
	if ( typeof (FLAG_CHANGE_DOCUMENT) != "undefined")
	{
		if ( FLAG_CHANGE_DOCUMENT == 1)
		{

			//DMessageBox( '../' , 'Prima di proseguire è necessario salvare le modifiche' , 'Attenzione' , 1 , 400 , 300 );
			ExecDocProcess('FITTIZIO,DOCUMENT,,NO_MSG');
			return;
		}
	}

	
	
	MakeDocFrom( 'MODULO_TEMPLATE_REQUEST##TEMPLATE#' + IDDOC + '#../####URL=' + encodeURIComponent( '../../CustomDoc/TEMPLATE_REQUEST.ASP?CRITERION=' + idModulo + '&VER=2&JSCRIPT=MODULO_TEMPLATE_REQUEST_VER2' ) ,'','');
   
}	