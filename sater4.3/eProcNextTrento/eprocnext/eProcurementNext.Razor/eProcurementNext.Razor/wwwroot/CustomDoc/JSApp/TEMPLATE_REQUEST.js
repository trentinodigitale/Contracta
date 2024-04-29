window.onload = Onload_Page;

function Onload_Page()
{
	//ActiveGridDrag (  'VALORIGrid' , MoveRow );
	ActiveGridDrag (  'VALORIGrid' , MoveAll );
	ShowHideCell();

}

function MoveRow( S , E)
{
	//return true;
	var verso = 1;
	var C = S;
	if( E < VALORIGrid_StartRow ) E=VALORIGrid_StartRow;
	if ( E > VALORIGrid_EndRow ) E = VALORIGrid_EndRow;
	
	
	if ( E < S ) verso = -1;
	
	
	while ( C != E )
	{
		MoveAll(  C , verso )
		
		C = C + verso;
	}
	
}

function AggiustaGriglia()
{
	CalcPath();
	ShowHideCell();
	
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

			if ( isSingleWin() == true )
				ShowWorkInProgress();

			SUB_AJAX( '../../ctl_library/REFRESH.ASP?COSA=MODEL&nocache=' + nocache );
			
			MakeDocFrom( 'MODULO_TEMPLATE_REQUEST##TEMPLATE' ,false, 'no' ); 
		}, 1 );
	}
}

function ClickDown( grid , r , c )
{
	MoveAll(  r , 1 )
	
	/*
	move( 'REQUEST_PART' , r  , 1 );
	move( 'DescrizioneEstesa' , r  , 1 );
	move( 'DescrizioneEstesaUK' , r  , 1 );
	move( 'TEMPLATE_REQUEST_GROUP' , r  , 1 );
	move( 'Obbligatorio' , r  , 1 );
	move( 'Removibile' , r  , 1 );
	move( 'UUID' , r  , 1 );
	
	CalcPath();
	ShowHideCell();
*/
}


function ClickUp( grid , r , c )
{
	MoveAll(  r , -1 )
	/*
	move( 'REQUEST_PART' , r  , -1 );
	move( 'DescrizioneEstesa' , r  , -1 );
	move( 'DescrizioneEstesaUK' , r  , -1 );
	move( 'TEMPLATE_REQUEST_GROUP' , r  , -1 );
	move( 'Obbligatorio' , r  , -1 );
	move( 'Removibile' , r  , -1 );
	move( 'UUID' , r  , -1 );

	CalcPath();
	ShowHideCell();
*/
}

function MoveAll(  r , verso )
{

	move( 'REQUEST_PART' , r  , verso );
	move( 'DescrizioneEstesa' , r  , verso );
	move( 'DescrizioneEstesaUK' , r  , verso );
	move( 'TEMPLATE_REQUEST_GROUP' , r  , verso );
	move( 'Obbligatorio' , r  , verso );
	move( 'Removibile' , r  , verso );
	move( 'UUID' , r  , verso );
	move( 'CampiInteressati' , r  , verso );
	
	CalcPath();
	ShowHideCell();

}

function VALORI_AFTER_COMMAND( param )
{
    CalcPath();
	ShowHideCell();
}




function move( field , row , verso ) 
{
    try
    {
        var f1 = getObj( 'RVALORIGrid_' + row + '_' + field );
        var f2 = getObj( 'RVALORIGrid_' + ( row + verso ) + '_' + field ) ;
        var app;

		try
		{
			app = f1.value;

			f1.value = f2.value;
			f2.value = app

			
			f1 = getObj( 'RVALORIGrid_' + row + '_' + field + '_V');
			f2 = getObj( 'RVALORIGrid_' + ( row + verso ) + '_' + field + '_V') ;


			app = f1.value;
			
			f1.value = f2.value;
			f2.value = app
			
			if ( app == undefined )
			{
				try{
					app = f1.innerHTML;
					
					f1.innerHTML = f2.innerHTML;
					f2.innerHTML = app
				}catch(e){}
			}
		}catch(e){}
		

		try{
			
			f1 = getObj( 'RVALORIGrid_' + row + '_' + field + '_edit');
			f2 = getObj( 'RVALORIGrid_' + ( row + verso ) + '_' + field + '_edit') ;

			app = f1.value;
			
			f1.value = f2.value;
			f2.value = app
		}catch(e){}
		
		try{
			
			f1 = getObj( 'RVALORIGrid_' + row + '_' + field + '_edit_new');
			f2 = getObj( 'RVALORIGrid_' + ( row + verso ) + '_' + field + '_edit_new') ;

			app = f1.value;
			
			f1.value = f2.value;
			f2.value = app
		}catch(e){}
				
		try{
			
			f1 = getObj( 'RVALORIGrid_' + row + '_' + field + '_extraAttrib');
			f2 = getObj( 'RVALORIGrid_' + ( row + verso ) + '_' + field + '_extraAttrib') ;

			app = f1.value;
			
			f1.value = f2.value;
			f2.value = app
		}catch(e){}
		
		try{
			if ( getObj( 'RVALORIGrid_' + row + '_' + field ).type == 'checkbox' )
			{
				 f1 = getObj( 'RVALORIGrid_' + row + '_' + field );
				 f2 = getObj( 'RVALORIGrid_' + ( row + verso ) + '_' + field ) ;
				

				app = f1.checked;

				f1.checked = f2.checked;
				f2.checked = app
				
				
			}
			
		}catch(e){}
		
    }
	catch(e)
	{
	}
}		



function CalcPath()
{
	var Path = '';
	var row = 0;
	var i,j;
	var Tipologia = ''
	var iParte = 0;
	var iSezione = 1;
	var iModulo = 1;
	var KeyRiga = '';
	var iSelVeloce = 0 ;
	
	try
	{
	
		while ( getObj( 'RVALORIGrid_' + row + '_REQUEST_PART'  ) != undefined )
		{
			
			//KeyRiga
			Tipologia = getObjValue( 'RVALORIGrid_' + row + '_REQUEST_PART' );

			if (  Tipologia == 'Parti' )
			{
				iParte++;
				iSezione = 0;
				iModulo = 0;
				iCommento = 0;
				iSelVeloce = 0 ;
				
				KeyRiga = String.fromCharCode(64 + iParte );
			}

			if (  Tipologia == 'Gruppo' )
			{
				iSezione++;
				iModulo = 0;
				iCommento = 0;

				KeyRiga = String.fromCharCode(64 + iParte ) + '.' + iSezione;
			}

			if (  Tipologia == 'Modulo' )
			{
				iModulo++;

				KeyRiga = String.fromCharCode(64 + iParte ) + '.' + iSezione + '.' + iModulo;
			}
			
			if (  Tipologia == 'Commenti' )
			{
				iCommento++;
				KeyRiga = String.fromCharCode(64 + iParte ) + '.' + iSezione + '.C' + iCommento;
			}
			
			if (  Tipologia == 'Titolo' )
			{
				iCommento++;
				KeyRiga = String.fromCharCode(64 + iParte ) + '.' + iSezione + '.T' + iCommento;
			}
			
			if (  Tipologia == 'SelezioneVeloce' )
			{
				iSelVeloce++;
				KeyRiga = String.fromCharCode(64 + iParte ) + '.' + iSezione + '.SV' + iSelVeloce;
			}

			SetTextValue( 'RVALORIGrid_' + row + '_KeyRiga' , KeyRiga );
			
			row++;
		}
	}catch(e)
	{}
	
}
	
	

function ShowHideCell()
{
	var Path = '';
	var SubType ;  
	var row = 0;
	var i,j;
	var Tipologia = '';
	var objCampiInteressati;
	
	try
	{
		//scorro la griglia
		//se la colonna Tipoloigia=SelezioneVeloce (RVALORIGrid_0_REQUEST_PART) visualizzo la cella per i Campi Interessati (RVALORIGrid_0_CampiInteressati) altrimenti la nascondo
		while ( getObj( 'RVALORIGrid_' + row + '_REQUEST_PART'  ) != undefined )
		{
			Tipologia = getObjValue( 'RVALORIGrid_' + row + '_REQUEST_PART' );
			objCampiInteressati = getObj( 'RVALORIGrid_' + row + '_CampiInteressati'  ) ;
			
			//alert(Tipologia);
			if (  Tipologia == 'SelezioneVeloce' )
				
				setVisibility( objCampiInteressati , '' );
				
			else
				
				setVisibility( objCampiInteressati , 'none' );		
			
			
			row++;
		}
	}catch(e)
	{}
	
}
	