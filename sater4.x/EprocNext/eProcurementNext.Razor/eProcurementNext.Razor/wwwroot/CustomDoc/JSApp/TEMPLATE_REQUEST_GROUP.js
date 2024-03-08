window.onload = Onload_Page;

function Onload_Page()
{
	ActiveGridDrag (  'RIGHEGrid' , MoveRow );
	ShowHideCell();
}

function MoveRow( S , E)
{
	//return true;
	var verso = 1;
	var C = S;
	if( E < RIGHEGrid_StartRow ) E=RIGHEGrid_StartRow;
	if ( E > RIGHEGrid_EndRow ) E = RIGHEGrid_EndRow;
	
	
	if ( E < S ) verso = -1;
	
	
	while ( C != E )
	{
		MoveAll(  C , verso )
		
		C = C + verso;
	}
	
}

function afterProcess(param) {

	if (param == 'ADD_EXCEL' || param == 'ADD_EXCEL_2_0_2') 
	{
        CalcPath();
	}
}

function ClickDown( grid , r , c )
{
	MoveAll(  r , 1 );
}


function ClickUp( grid , r , c )
{
	MoveAll(  r , -1 );
}

function MoveAll(  r , verso )
{
	move( 'ItemLevel' , r  , verso );
	move( 'ItemPath' , r  , verso );
	move( 'NotEditable' , r  , verso );
	move( 'Related' , r  , verso );
	move( 'RG_FLD_TYPE' , r  , verso );
	move( 'TipoEstensione' , r  , verso );
	move( 'TypeRequest' , r  , verso );
	move( 'UUID' , r  , verso );
	move( 'AnagDoc' , r  , verso );
	move( 'DescrizioneEstesa' , r  , verso );
	move( 'DescrizioneEstesaUK' , r  , verso );
	move( 'Iterabile' , r  , verso );
	
	move( 'SorgenteCampo' , r  , verso );
	move( 'RegExp' , r  , verso );
	move( 'InCaricoA' , r  , verso );
	move( 'Obbligatorio' , r  , verso );
	
	
	move( 'Note' , r  , verso );
	move( 'Note_UK' , r  , verso );
	
	CalcPath();
	ShowHideCell();

}



/*
function move( field , row , verso ) 
{
    try
    {
        var f1 = getObj( 'RRIGHEGrid_' + row + '_' + field );
        var f2 = getObj( 'RRIGHEGrid_' + ( row + verso ) + '_' + field ) ;
        var app;

        app = f1.value;

        f1.value = f2.value;
        f2.value = app

		
        f1 = getObj( 'RRIGHEGrid_' + row + '_' + field + '_V');
        f2 = getObj( 'RRIGHEGrid_' + ( row + verso ) + '_' + field + '_V') ;


        app = f1.value;
		
        f1.value = f2.value;
        f2.value = app
		
		if ( app == undefined )
		{
			app = f1.innerHTML;
			
			f1.innerHTML = f2.innerHTML;
			f2.innerHTML = app
		}
		
		
    }
	catch(e)
	{
	}
}
*/		

function move( field , row , verso ) 
{
		
	
    try
    {
        var f1 = getObj( 'RRIGHEGrid_' + row + '_' + field );
        var f2 = getObj( 'RRIGHEGrid_' + ( row + verso ) + '_' + field ) ;
        var app;
		
		try
		{
			app = f1.value;

			f1.value = f2.value;
			f2.value = app
			
			
			f1 = getObj( 'RRIGHEGrid_' + row + '_' + field + '_V');
			f2 = getObj( 'RRIGHEGrid_' + ( row + verso ) + '_' + field + '_V') ;


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
			
			f1 = getObj( 'RRIGHEGrid_' + row + '_' + field + '_edit');
			f2 = getObj( 'RRIGHEGrid_' + ( row + verso ) + '_' + field + '_edit') ;

			app = f1.value;
			
			f1.value = f2.value;
			f2.value = app
		}catch(e){}
		
		try{
			
			f1 = getObj( 'RRIGHEGrid_' + row + '_' + field + '_edit_new');
			f2 = getObj( 'RRIGHEGrid_' + ( row + verso ) + '_' + field + '_edit_new') ;

			app = f1.value;
			
			f1.value = f2.value;
			f2.value = app
		}catch(e){}
				
		try{
			
			f1 = getObj( 'RRIGHEGrid_' + row + '_' + field + '_extraAttrib');
			f2 = getObj( 'RRIGHEGrid_' + ( row + verso ) + '_' + field + '_extraAttrib') ;

			app = f1.value;
			
			f1.value = f2.value;
			f2.value = app
		}catch(e){}
		
		try{
			if ( getObj( 'RRIGHEGrid_' + row + '_' + field ).type == 'checkbox' )
			{
				 f1 = getObj( 'RRIGHEGrid_' + row + '_' + field );
				 f2 = getObj( 'RRIGHEGrid_' + ( row + verso ) + '_' + field ) ;
				

				app = f1.checked;

				f1.checked = f2.checked;
				f2.checked = app
				
				
			}
			
		}catch(e){}
		
		
		//provo a cambiare il contenuto dei frame dei campi se sono RTE
		try{
			
			var Framef1 = getObj( 'FRM_RRIGHEGrid_' + row + '_' + field );
			var Framef2 = getObj( 'FRM_RRIGHEGrid_' + ( row + verso ) + '_' + field );
			
			var content = Framef1.contentWindow.document.getElementsByTagName("body")[0].innerHTML;
			
			Framef1.contentWindow.document.getElementsByTagName("body")[0].innerHTML = 	Framef2.contentWindow.document.getElementsByTagName("body")[0].innerHTML ;
			Framef2.contentWindow.document.getElementsByTagName("body")[0].innerHTML = 	content;
		
		}catch(e){}
		
		
    }
	catch(e)
	{
	}
	
	
	
}		



function CalcPath()
{
	var Path = '';
	var SubLivelli = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0, 0, 0, 0, 0, 0,0, 0, 0, 0, 0, 0];  
	var SubType = ['', '', '', '', '', '', '', '', '', '', '', '','', '', '', '', '', '','', '', '', '', '', ''];  
	var row = 0;
	var livello;
	var Prevlivello;
	var i,j;
	try
	{
		Prevlivello = 0;
		while ( getObj( 'RRIGHEGrid_' + row + '_ItemLevel'  ) != undefined )
		{
			livello = getObjValue( 'RRIGHEGrid_' + row + '_ItemLevel' );
			if( livello == '' || livello == 0 )
				livello = 1;
			
			if( livello > Prevlivello)
			{
				SubLivelli[livello] = 1
			}
			else
			{
				SubLivelli[livello]++;
			}

			SubType[livello] = 	getObjValue( 'RRIGHEGrid_' + row + '_TypeRequest' );
			
			//-- costruisco il path
			Path = '';
			for( i = 1 ; i <= livello ; i++ )
			{
				Path = Path + SubType[i] 
				if( SubType[i] == 'G' || SubType[i] == 'K' || SubType[i] == 'T' || SubType[i] == 'Q')
				{
					for( j = 1 ; j <= i  ; j++ )
					{
						Path = Path + SubLivelli[j];
						if ( j < i) Path = Path + '.';
					}
				}
				else
				{
					Path = Path + SubLivelli[i];
				}
				if ( i < livello) Path = Path + '/';
			}

			//getObj( 'RRIGHEGrid_' + row + '_ItemPath'  ).value = Path; 
			SetTextValue( 'RRIGHEGrid_' + row + '_ItemPath' , Path );
			
			Prevlivello = livello; 
			row++;
		}
	}catch(e)
	{}
	ShowHideCell();
}
	
	

function ShowHideCell()
{
	var Path = '';
	var SubType ;  
	var row = 0;
	var i,j;
	try
	{
		Prevlivello = 0;
		while ( getObj( 'RRIGHEGrid_' + row + '_ItemLevel'  ) != undefined )
		{
			SubType = 	getObjValue( 'RRIGHEGrid_' + row + '_TypeRequest' );
			if ( SubType == 'G' )
			{
				setVisibility( getObj( 'val_RRIGHEGrid_' + row + '_RG_FLD_TYPE') , 'none' );
				setVisibility( getObj( 'val_RRIGHEGrid_' + row + '_Related') , '' );
				setVisibility( getObj( 'RRIGHEGrid_' + row + '_Iterabile') , '' );

				setVisibility( getObj( 'RRIGHEGrid_' + row + '_SorgenteCampo') , 'none' );
				setVisibility( getObj( 'RRIGHEGrid_' + row + '_RegExp') , 'none' );
				
				if( getObj( 'RRIGHEGrid_' + row + '_Iterabile' ).checked )
					setVisibility( getObj( 'RRIGHEGrid_' + row + '_InCaricoA') , '' );
				else
					setVisibility( getObj( 'RRIGHEGrid_' + row + '_InCaricoA') , 'none' );
				
				
				setVisibility( getObj( 'RRIGHEGrid_' + row + '_Obbligatorio') , 'none' );

				setVisibility( getObj( 'RRIGHEGrid_' + row + '_Edit') , 'none' );
				setVisibility( getObj( 'RRIGHEGrid_' + row + '_Condizione') , 'none' );
				
			}
			else // -R
			{
				setVisibility( getObj( 'val_RRIGHEGrid_' + row + '_RG_FLD_TYPE') , '' );
				setVisibility( getObj( 'val_RRIGHEGrid_' + row + '_Related') , 'none' );

				setVisibility( getObj( 'RRIGHEGrid_' + row + '_Iterabile') , 'none' );

				setVisibility( getObj( 'RRIGHEGrid_' + row + '_SorgenteCampo') , '' );
				setVisibility( getObj( 'RRIGHEGrid_' + row + '_RegExp') , '' );
				setVisibility( getObj( 'RRIGHEGrid_' + row + '_InCaricoA') , '' );
				setVisibility( getObj( 'RRIGHEGrid_' + row + '_Obbligatorio') , '' );

				if ( getObjValue( 'RRIGHEGrid_' + row + '_SorgenteCampo') != '' )
					setVisibility( getObj( 'RRIGHEGrid_' + row + '_Edit') , '' );					
				else
					setVisibility( getObj( 'RRIGHEGrid_' + row + '_Edit') , 'none' );
				
				if ( ( getObjValue( 'RRIGHEGrid_' + row + '_RG_FLD_TYPE') == 'Number_I' || getObjValue( 'RRIGHEGrid_' + row + '_RG_FLD_TYPE') == 'Number_F' ) && ( getObjValue( 'RRIGHEGrid_' + row + '_InCaricoA') == 'OE' )  )
					setVisibility( getObj( 'RRIGHEGrid_' + row + '_Condizione') , '' );	
				else
					setVisibility( getObj( 'RRIGHEGrid_' + row + '_Condizione') , 'none' );	


			}			

			row++;
		}
	}catch(e)
	{}
	
}
	
	
	
function ChangeSel( obj )
{
	
		ShowHideCell();
	
}



function RIGHE_AFTER_COMMAND(param) {
	try{
		$('.RTE').rte("", "../images/toolbar/");
	}catch(e){};
}