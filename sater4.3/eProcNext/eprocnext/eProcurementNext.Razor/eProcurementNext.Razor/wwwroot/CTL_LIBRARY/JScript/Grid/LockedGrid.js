
//-- ridimensiona le finestre associate alla griglia locked
function ResizeGrid(  idObj  )
{
	var Grid;
	var GridShowed;
	var GridContent;
	var Grid_LockedRow;
	var Grid_LockedCol;
	var GridCaption;
	var Grid_LockedCorner;
 	var rctsObj;
 	var rctsDocument;
 	var nNumRows;
	var nNumCols;
	
	if ( idObj === undefined )
	{
		idObj = 'Grid';
	}

	try
	{
		var W;
		var H;
		var i;
		var wS;
		var hS;
		wS = 16; /*-- dimensione della scroolbar -- */
		hS = 16;
		
		//-- recupero gli oggetti legati alla griglia
		Grid  = getObj( idObj );
		GridShowed  = getObj( idObj + '_ShowedDiv' );
		GridContent = getObj( idObj + '_Content' );
		Grid_LockedRow = getObj( idObj + '_LockedRow' );
		GridCaption = getObj( idObj + '_LockedRow' );
		Grid_LockedCol = getObj( idObj + '_LockedCol' );
		Grid_LockedCorner = getObj( idObj + '_LockedCorner' );

		//-- recupero la posizione della griglia
		//rctsObj = GridShowed.getBoundingClientRect();
		//rctsDocument = document.getBoundingClientRect();

		//-- Sposto il contenuto nella posizione 

		//GridContent.style.top = GridShowed.offsetParent.offsetTop + GridShowed.offsetTop + document.body.clientTop;
		//GridContent.style.left = GridShowed.offsetParent.offsetLeft + GridShowed.offsetLeft + document.body.clientLeft;

		GridContent.style.top = PosTop( GridShowed ) + 'px';
		GridContent.style.left = PosLeft( GridShowed ) + 'px';

		GridContent.style.height = 'auto';

		//GridContent.style.height = '68%';
		GridContent.style.width = GridShowed.offsetWidth + 'px';

		//-- rendo visibili le griglie
		GridContent.style.display = '';
		GridContent.style.display = 'block';

		nNumRows=GetProperty(Grid_LockedRow, "rows");

		//return ;

		if (browserName=='Microsoft Internet Explorer')
		{
			Grid=Grid[0];
		}

		if( nNumRows > 0 ) 
		{
			Grid_LockedRow.style.top = PosTop( GridContent ) + 'px';
			Grid_LockedRow.style.left = PosLeft( GridContent ) + 'px';
			
			H = 0

			i = nNumRows -1;

			//solo nel caso di IE ho una collezione di griglie

			H = Grid.rows[i].offsetHeight + Grid.rows[i].offsetTop;

			// verifico se la griglia non ha la scroll verticale
			if( Grid.offsetHeight <= GridShowed.offsetHeight ) 
			{
				wS = 0;
				Grid_LockedRow.style.display =  'none';
			}
			else
			{

				Grid_LockedRow.style.height = H + 'px';
				//Grid_LockedRow.style.width = (GridShowed.offsetWidth - wS) + 'px';
				Grid_LockedRow.style.width = GridShowed.offsetWidth + 'px';

				Grid_LockedRow.style.display =  '';
				Grid_LockedRow.style.display =  'block';
			}
		}

		nNumCols=GetProperty(Grid_LockedCol, "cols");

		if( nNumCols > 0 ) 
		{
			//Grid_LockedCol.innerHTML = GridContent.innerHTML;

			//-- sposto la caption sopra la griglia
			//Grid_LockedCol.style.top = GridContent.style.top;
			//Grid_LockedCol.style.left = GridContent.style.left;
		
			Grid_LockedCol.style.top = PosTop( GridContent ) + 'px';
			Grid_LockedCol.style.left = PosLeft( GridContent ) + 'px';
		
			W = 0
			//debugger;
			//for( i= 0 ; i < Grid_LockedCol.cols ; i++ )
			i = nNumCols -1;
			//W = Grid(0).cells.item(i).offsetWidth + Grid(0).cells.item(i).offsetLeft;
			
			
			W = Grid.rows[0].cells[i].offsetWidth + Grid.rows[0].cells[i].offsetLeft;
			
			//debugger;
			//if( Grid[0].offsetWidth <= GridShowed.offsetWidth )
			if( Grid.offsetWidth <= GridShowed.offsetWidth )  
			{
				hS = 0
				Grid_LockedCol.style.display =  'none';
			
			}
			else
			{
				
				Grid_LockedCol.style.width = W + 'px';
				//Grid_LockedCol.style.height = (GridShowed.offsetHeight - hS) + 'px';

				Grid_LockedCol.style.display =  '';
				Grid_LockedCol.style.display =  'block';
			}
		
		}

		if( nNumCols > 0 && nNumRows > 0 ) 
		{
			if ( hS == 0 || wS == 0 )
			{
				Grid_LockedCorner.style.display =  'none';
			}
			else
			{
			
				//Grid_LockedCorner.innerHTML = GridContent.innerHTML;

				//-- sposto la caption sopra la griglia
				Grid_LockedCorner.style.top = PosTop(GridContent) + 'px';
				Grid_LockedCorner.style.left = PosLeft(GridContent) + 'px';
			
				//Grid_LockedCorner.style.height = Grid_LockedCol.offsetHeight + 'px';
				Grid_LockedCorner.style.width = Grid_LockedCol.offsetWidth + 'px';

				Grid_LockedCorner.style.display =  '';
				Grid_LockedCorner.style.display =  'block';
			}		
		}
		
	}	catch(  e ){  
		//alert('ResizeGrid:'+e);
	 };

}



//-- sincronizza visivamente le varie aree della griglia
function ScrollLockedInfo(  idObj  )
{

	var GridContent;
	var Grid_LockedRow;
	var Grid_LockedCol;
	var nNumRows;
	var nNumCols;
	
	//debugger;
	try
	{
	
		//-- recupero gli oggetti legati alla griglia
		GridContent = getObj( idObj + '_Content' );
		Grid_LockedRow = getObj( idObj + '_LockedRow' );
		Grid_LockedCol = getObj( idObj + '_LockedCol' );
		
		nNumRows=GetProperty(Grid_LockedRow, "rows");
		nNumCols=GetProperty(Grid_LockedCol, "cols");
		
		if( nNumRows > 0 ) Grid_LockedRow.scrollLeft = GridContent.scrollLeft;
		if( nNumCols > 0 ) Grid_LockedCol.scrollTop = GridContent.scrollTop;

	}
	catch(  e ){ return ''; 	};

}

//- avvia il meccanismo di scroll riempiendo le aree laterali della griglia
function StartScrolledGrid(  idObj  )
{

	var GridContent;
	var Grid_LockedRow;
	var Grid_LockedCol;
	var Grid_LockedCorner;
	var nNumRows;
	var nNumCols;
	
	var i = 0;
	var d = 0;
	//debugger;
	
	try
	{
	
		//-- recupero gli oggetti legati alla griglia
		GridContent = getObj( idObj + '_Content' );
		Grid_LockedRow = getObj( idObj + '_LockedRow' );
		Grid_LockedCol = getObj( idObj + '_LockedCol' );
		Grid_LockedCorner = getObj( idObj + '_LockedCorner' );

		GridContent.style.backgroundColor ='white';
		
		nNumRows=GetProperty(Grid_LockedRow, "rows")		
				
		//-- copio il contenuto della griglia nella caption
		if( nNumRows > 0 ) 
		{
			Grid_LockedRow.innerHTML = GridContent.innerHTML;
			Grid_LockedRow.style.backgroundColor ='white';

			/*
			d++;
			for( i= 0 ; i < nNumRows ; i++ )
			{
				Grid(d).rows.item(i).style.height = Grid(0).rows.item(i).offsetHeight;
			}			
			for( i= 0 ; i < Grid_LockedCol.cols  ; i++ )
			{
				Grid(d).cells.item(i).style.width = Grid(0).cells.item(i).offsetWidth;
			}
			*/			

			
		}
		
		nNumCols=GetProperty(Grid_LockedCol, "cols")		
		
		if( nNumCols > 0 ) 
		{
			Grid_LockedCol.innerHTML = GridContent.innerHTML;
			Grid_LockedCol.style.backgroundColor ='LightGoldenrodYellow';


		}
		
		if( nNumCols > 0 && nNumRows > 0 )
		{ 
			Grid_LockedCorner.innerHTML = GridContent.innerHTML;
			Grid_LockedCorner.style.backgroundColor ='white';

		}


		
		//-- POSIZIONO LE AREE
		ResizeGrid(  idObj  );
	
		
	}
	catch(  e ){ return ''; 	};



		//ResizeGrid(  idObj  );

}

function MoveGrid( idObj )
{

	var rcts;
	var GridContent;
	var GridShowed;
	var GridCaption;
	var Grid;

	Grid  = getObj( idObj );
	GridShowed  = getObj( idObj + '_ShowedDiv' );
	GridContent = getObj( idObj + '_Content' );
	GridCaption = getObj( idObj + '_LockedRow' );

	
	alert('movegrid');
	
	rcts = GridShowed.getClientRects();
	
	//debugger;
	//-- prendo le posizioni della griglia
	//GridContent.style.top = GridShowed.clientTop +  GridShowed.offsetTop;
	//GridContent.style.left = GridShowed.clientLeft +  GridShowed.offsetLeft;
	
	//GridContent.style.height = GridShowed.offsetHeight;
	GridContent.style.width = GridShowed.offsetWidth;

	GridContent.style.top = rcts[0].top;
	GridContent.style.left = rcts[0].left;

	
	//-- rendo visibili le griglie
	GridContent.style.display = '';
	GridContent.style.display = 'block';
	GridCaption.style.display = '';
	GridCaption.style.display = 'block';
	
	//-- copio il contenuto della griglia nella caption
	GridCaption.innerHTML = GridContent.innerHTML;
	
	
	//-- sposto la caption sopra la griglia
	GridCaption.style.top = rcts[0].top;
	GridCaption.style.left = rcts[0].left;

	//GridCaption.style.height = RowCaption(0).offsetHeight;
	GridCaption.style.height = Grid.rows.item(0).offsetHeight;
	
	GridCaption.style.width = GridShowed.offsetWidth - 16;
	
	//-- la evidenzio
	GridCaption.style.backgroundColor = "blue";

}

function ScrollCaption( idObj )
{

	var GridContent;
	var GridShowed;
	var GridCaption;
	var Grid;

	Grid  = getObj( idObj );
	GridShowed  = getObj( idObj + '_Showed' );
	GridContent = getObj( idObj + '_Content' );
	GridCaption = getObj( idObj + '_LockedRow' );

	GridCaption.scrollLeft = GridContent.scrollLeft;
	//GridCaption.scrollWidth
}
