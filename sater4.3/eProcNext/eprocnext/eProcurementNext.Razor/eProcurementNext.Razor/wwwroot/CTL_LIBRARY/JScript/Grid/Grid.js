
//-- setta la classe ad una riga della griglia
function G_SetRC( id , clsName ,indRow )
{

	var  index = indRow - eval( id + '_StartRow;' );

	var obj = getObj( id + 'R' + indRow );
	var i;
	var styleName;
	
	styleName = clsName;
	
	//-- conservo lo style della riga
	//eval( id + '_StyleRow[ ' + indRow + '] = \'' + clsName + '\';' );
	
	//-- verifica se la riga è selezionata
	var sel = eval( id + '_SelectedRow[ ' + index + '];' );
	
	if( sel == 1 ) 
	{
		styleName = styleName + '_Sel';
	}
	
	//debugger;
	try{
		if ( obj.length == undefined )
		{
		
			setClassName( obj , styleName);
		} 
		else
		{
			for ( i = 0; i < obj.length ; i++ )
			{
				setClassName( obj[i] , styleName);
			}
		}
	}catch( e ){

		try {setClassName( obj , styleName); } catch( e ) {};
	
	};

}


//-- effettua la selezione di una riga
function G_ClickRow( id , indRow )
{
	
	var clsName;
	var nStartRow=eval( id + '_StartRow;' );

	//objcheck= eval( 'document.FormViewerGriglia.' + id + '_SEL' ) ;
	objcheck = document.getElementsByName(id + '_SEL');


	//-- sulla selezione singola si toglie prima la selezione a tutto
	if( eval( id + '_ActiveSelection;' ) == 3 )
	{
		Grid_DeselectAll( id );
	}

	
	//-- verifica se la riga è selezionata
	var sel = eval( id + '_SelectedRow[ ' + ( indRow - nStartRow ) + '];' );
	
	if( sel == 1 ) 
	{
		eval( id + '_SelectedRow[ ' + ( indRow - nStartRow ) + '] = 0;' );
		//-- imposto il check
		try{ objcheck[( indRow - nStartRow )].checked = false }catch(e){};
	}
	else
	{
		bCanCheck=true;
		//se actveSel=3 seleziono la riga solo se clicco sulla prima colonna
		if ( eval( id + '_ActiveSelection') == '3' ){
			
			//recupero larghezza prima colonna
			objTable=eval( id );
			if (event.x > objTable[0].cells[0].offsetWidth )
				bCanCheck=false;
		
		}
		
		if (bCanCheck){
		
			eval( id + '_SelectedRow[ ' + ( indRow - nStartRow ) + '] = 1;' );
			//-- imposto il check
			try{ objcheck[( indRow - nStartRow )].checked = true }catch(e){};
		
		}
	}
	
	//-- recupero lo style della riga ed invoco il cambio di style
	if ( indRow % 2 ) 
	{
		clsName = eval( id + '_StyleRow1;' );
	}
	else
	{
		clsName = eval( id + '_StyleRow0;' );
	}
	
	//var clsName = eval( id + '_StyleRow[ ' + indRow + ']' );
	G_SetRC( id , clsName ,indRow );
	
	
	//-- invoca un evento custom sul cambio di selezione
	try
	{
		eval( id + '_ChangeSel();' );
	}
	catch( e ) {};

}


//-- ritorna gli indici delle righe selezionate in una stringa concatenandoli
//-- separati da ~~~
function Grid_GetIndSelectedRow( id )
{
	var i;
	var result = '';
	var NumRow = eval( id + '_EndRow;' );
	var nStartRow=eval( id + '_StartRow;' );
	
	for ( i = nStartRow ; i <= NumRow ; i++ )
	{
		try {
			if( eval( id + '_SelectedRow[ ' + ( i - nStartRow ) + '];' ) == 1 )
			{
				if ( result != '' ) result = result +  '~~~';
				result = result +  i;
			}
		}catch(e){
		}
	}
	
	return result;

}

//-- ritorna gli identificativi delle righe selezionate in una stringa concatenandoli
//-- separati da ~~~
function Grid_GetIdSelectedRow( id )
{
	var i;
	var result = '';
	var NumRow = eval( id + '_EndRow;' );
	var nStartRow=eval( id + '_StartRow;' );
	var app = '';
	
	for ( i = nStartRow ; i <= NumRow ; i++ )
	{
		try {
			if( eval( id + '_SelectedRow[ ' + ( i - nStartRow ) + '];' ) == 1 )
			{
				
				app = GetIdRow( id , i , '' );
				if ( app != '' )
				{
					if ( result != '' ) result = result +  '~~~';
					result = result + app;
				}
			}
		}catch(e){
		}
	}
	
	return result;

}


function Grid_SelectAll( id )
{
	var i;
	var result = '';
	var NumRow = eval( id + '_EndRow;' );
	var nStartRow=eval( id + '_StartRow;' );
	var clsName;
	
	//objcheck= eval( 'document.FormViewerGriglia.' + id + '_SEL' ) ;
	objcheck = document.getElementsByName(id + '_SEL');

	for ( i = nStartRow ; i <= NumRow ; i++ )
	{
		try {
			eval( id + '_SelectedRow[ ' + ( i - nStartRow) + '] = 1;' );
			//-- imposto il check	
			
			//try{ getObj( id + '_SEL' )[i-nStartRow].checked = true }catch(e){};
			try{ objcheck[i-nStartRow].checked = true }catch(e){};
			
			//-- recupero lo style della riga ed invoco il cambio di style
			if ( i % 2 ) 
			{
				clsName = eval( id + '_StyleRow1;' );
			}
			else
			{
				clsName = eval( id + '_StyleRow0;' );
			}
	
			G_SetRC( id , clsName ,i );
		}catch(e){
		}
	}

}


function Grid_DeselectAll( id )
{
	var i;
	var result = '';
	var NumRow = eval( id + '_EndRow;' );
	var nStartRow=eval( id + '_StartRow;' );
	var clsName;

	//objcheck= eval( 'document.FormViewerGriglia.' + id + '_SEL' ) ;
	objcheck = document.getElementsByName(id + '_SEL');

	for ( i = nStartRow ; i <= NumRow ; i++ )
	{
		try {
			eval( id + '_SelectedRow[ ' + ( i - nStartRow) + '] = 0;' );
			//-- imposto il check	
			//try{ getObj( id + '_SEL' )[( i - nStartRow)].checked = false }catch(e){};
			try{ objcheck[i-nStartRow].checked = false }catch(e){};

			//-- recupero lo style della riga ed invoco il cambio di style
			if ( i % 2 ) 
			{
				clsName = eval( id + '_StyleRow1;' );
			}
			else
			{
				clsName = eval( id + '_StyleRow0;' );
			}
	
			G_SetRC( id , clsName ,i );
		}catch(e){
		}
	}

}


function Grid_InvertSelection( id )
{
	var i;
	var result = '';
	var NumRow = eval( id + '_EndRow;' );
	var nStartRow=eval( id + '_StartRow;' );
	var clsName;
	
	for ( i = nStartRow ; i <= NumRow ; i++ )
	{
		try {
			G_ClickRow( id , i )
		}catch(e){
		}
	}

}


function G_SetRHTML( id , indRow , txt  )
{
	var obj = getObj( id + 'R' + indRow );
	alert( txt );
	alert( obj.innerHTML );
	alert( obj.innerTEXT );
	obj.innerHTML = txt;
	
}



/*
-- ESEMPIO uso del DRAG and drop sulle griglie
-- la funzione passata in inputriceve la posizione della riga trascinata ed in che posizione è stata posizionata
function OnLOAD()
{
	ActiveGridDrag (  'GridViewer' , MoveAttivita );
}

function MoveAttivita( S , E)
{
	IdStart =  getObjValue( 'GridViewer_idRow_' + S );
	
	if( E < 0 )
	{
		Before_ROW = 'PRIMA';
	}
	else
	{
		try{
			 Before_ROW = getObjValue( 'GridViewer_idRow_' + E );
		}
		catch(e){
			Before_ROW = 'ULTIMA';
		}
		
	}
	alert( Before_ROW ) ;
}
*/

function ActiveGridDrag( GridName , OnMoveRow )
{
	
	
	$(document.getElementById(GridName).tBodies ).sortable({
		  
		 
		
		  stop: function(event, ui) {
			
			var bFound = false;
			G = getObj( GridName );
			
			nr = G.rows.length;
			
			for( i = 0 ; i < nr && bFound == false; i++ ) 
			{
				if(  G.rows[i].id == ui.item[0].id )
				{
					bFound = true;
					
					PosStart = parseInt( ui.item[0].id.replace( GridName + 'R' , '' ));
					PosEnd = i-1;
					
					//alert(PosStart);
					//alert(PosEnd);
					
					PosStart++;
					PosEnd++;
					
					//-- riposiziono la riga
					/*
					if ( PosStart > PosEnd )
					{
						NR = G.insertRow( PosStart + 1);
						NR.outerHTML = G.rows[PosEnd].outerHTML ;
						G.deleteRow( PosEnd );
					}
					
					if ( PosStart < PosEnd )
					{
						A = G.rows[PosEnd].outerHTML ;
						G.deleteRow( PosEnd );
						NR = G.insertRow( PosStart );
						NR.outerHTML = A;
						PosEnd++;
					}
					
					if ( PosStart != PosEnd)
					{
						PosStart--;
						PosEnd--;
						
						OnMoveRow( PosStart , PosEnd )
						
					}
					*/
					
					
				
				
					
					
					if ( PosStart != PosEnd)
					{
						
						SwapRows( GridName , PosStart , PosEnd ); 
						
						PosStart--;
						PosEnd--;
						
						//OnMoveRow( PosStart , PosEnd )
						GridMoveRow( GridName , OnMoveRow , PosStart , PosEnd );
						
					}
					
					
				}
				
				//InitDrag_Drop ( GridName );
				
				
			}
			
		  }
		  
		  
		  
		  
		 
	  });
	  
	 //sulla colonna 0 (mouseover) della griglia abilito il drag&drop sulle altre no
	 InitDrag_Drop ( GridName );
	 
}


function DisableGridDrag( GridName )
{
 
  $(document.getElementById(GridName).tBodies ).sortable( "disable" );
  
}

function EnableGridDrag( GridName )
{
 
  $(document.getElementById(GridName).tBodies ).sortable( "enable" );
  
}



function InitDrag_Drop( GridName ){
	
	var bfound = true;
	//per tutte le righe sulla prima colonna su mouseover aggiungo l'attivazione
	//mentre sulle altre disattivo
	
	G = getObj( GridName );
			
	nr = G.rows.length;
	
	for( i = 1 ; i < nr ; i++ ) 
	{
		
		//bfound = true;
		//&& bfound == true
		for ( j = 0 ; j < 100  ; j++ ) 
		{
			
			bfound = true;
			
			try
			{
				if (j == 0 )
				{
					getObj( GridName + '_r' + i + '_c' + j ).addEventListener("mouseover", function (e) {
																		
																		EnableGridDrag (  GridName  );
				
																			});
		
				}
				else
				{
		
					getObj( GridName + '_r' + i + '_c' + j ).addEventListener("mouseover", function (e) {
																		
																		DisableGridDrag ( GridName ) ;
				
																			});
				}
			
			}
			catch(e)
			{ 
				bfound = false ;
			}
			
		}
		//alert('colonna=' + j);
		
	}
	
	//alert('riga=' + i);
	
	
	
}



 function SwapRows (GridName , S , E ) 
 {
	var table = document.getElementById (GridName);
	if (table.moveRow) {        // Internet Explorer
		table.moveRow (S, E);
	} 
	else {        // Cross browser
		var Spostata = table.rows[E];
		
		if ( S < E )
		{
			var Posizione = table.rows[S];
			
			Spostata.parentNode.insertBefore (Spostata, Posizione);
		}
		else 
		{
			var Posizione = table.rows[S+1];
			Spostata.parentNode.insertBefore (Spostata, Posizione);
		}
	}
}

//funzione che sposta le righe per il drag and drop
function GridMoveRow( GridName , OnMoveRow , S , E)
{
	//return true;
	var verso = 1;
	var C = S;
	if( E < eval( GridName + '_StartRow' ) )  E=eval( GridName + '_StartRow' );
	//if ( E > eval( GridName + '_EndRow' ) ) E = eval( GridName + '_EndRow' );
	
	//numero righe della tabella 
	var G = getObj( GridName );
	//tolgo 2 righe per la caption e perchè la numerazione è 1 based
	//la patch non considera la paginazione della griglia
	var nr = G.rows.length - 2;
	
	if ( E > nr ) E = nr ;
		
	
	if ( E < S ) verso = -1;
	
	
	while ( C != E )
	{
		OnMoveRow(  C , verso );
		
		C = C + verso;
	}
	
}



//funzioone che sposta un campo di una riga verso il basso oppure verso l'alto (a seconda del valore del parametro verso)
function Move_Abstract( GridName, field , row , verso ) 
{
	var f1;
	var f2;
	
	try
    {	
		if ( GridName == '')
		{
			f1 = getObj( 'R' + row + '_' + field );
			f2 = getObj( 'R' + ( row + verso ) + '_' + field ) ;	
		}
		else
		{
			f1 = getObj( 'R' + GridName + '_' + row + '_' + field );
			f2 = getObj( 'R' + GridName + '_' + ( row + verso ) + '_' + field ) ;
		}	
        
        var app;

		try
		{
			app = f1.value;
			f1.value = f2.value;
			f2.value = app ;
			

			//per gli attributi a dominio non editabili devo scambiare il valore della DIV con nome "val_....."
			//provo sempre tranne quando f1 non è una combo
			//se f1 null provo a gestire il valore a video contenuto in una DIV con nome "val_....."
			if ( f1.type != 'select-one'  )
			{	
				if ( GridName == '')
				{
					f1 = getObj( 'val_R' + row + '_' + field );
					f2 = getObj( 'val_R' +  ( row + verso ) + '_' + field ) ;
				}
				else
				{
					f1 = getObj( 'val_R' + GridName + '_' + row + '_' + field );
					f2 = getObj( 'val_R' + GridName + '_' + ( row + verso ) + '_' + field ) ;
				}	
				
				//EP: se ci sono le DIV faccio lo scambio
				//aggiunto controllo per evitare che se f1 non presente vada nel catch e non esegue 
				//le istruzioni successive che mi fanno gestire i campi testo visuali(editabili/non editabili)
				if ( f1 && f2 )				
				{
					app = f1.innerHTML;
						
					f1.innerHTML = f2.innerHTML;
					f2.innerHTML = app;
				}
				
			}
			
			
			if ( GridName == '')
			{
				f1 = getObj( 'R' + row + '_' + field + '_V');
				f2 = getObj( 'R' + ( row + verso ) + '_' + field + '_V') ;
			}
			else
			{
				f1 = getObj( 'R' + GridName + '_' + row + '_' + field + '_V');
				f2 = getObj( 'R' + GridName + '_' + ( row + verso ) + '_' + field + '_V') ;
			}
			
			
			
			app = f1.value;
			
			f1.value = f2.value;
			f2.value = app
			
			if ( app == undefined )
			{
				try{
					app = f1.innerHTML;
					
					f1.innerHTML = f2.innerHTML;
					f2.innerHTML = app;
					
				}catch(e){}
			}
				
			
		}catch(e){}
		

		try{
			
			f1 = getObj( 'R' + GridName + '_' + row + '_' + field + '_edit');
			f2 = getObj( 'R' + GridName + '_' + ( row + verso ) + '_' + field + '_edit') ;

			app = f1.value;
			
			f1.value = f2.value;
			f2.value = app
		}catch(e){}
		
		try{
			
			f1 = getObj( 'R' + GridName + '_' + row + '_' + field + '_edit_new');
			f2 = getObj( 'R' + GridName + '_' + ( row + verso ) + '_' + field + '_edit_new') ;

			app = f1.value;
			
			f1.value = f2.value;
			f2.value = app
		}catch(e){}
				
		try{
			
			f1 = getObj( 'R' + GridName + '_' + row + '_' + field + '_extraAttrib');
			f2 = getObj( 'R' + GridName + '_' + ( row + verso ) + '_' + field + '_extraAttrib') ;

			app = f1.value;
			
			f1.value = f2.value;
			f2.value = app
		}catch(e){}
		
		
		try{
			if ( getObj( 'R' + GridName + '_' + row + '_' + field ).type == 'checkbox' )
			{
				 f1 = getObj( 'R' + GridName + '_' + row + '_' + field );
				 f2 = getObj( 'R' + GridName + '_' + ( row + verso ) + '_' + field ) ;
				

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
