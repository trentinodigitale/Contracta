function Budget_SetFixCol(  numcol  )
{
	try{
		var Grid_LockedCol;
	
		Grid_LockedCol = Budget_Griglia.getObj( 'GridCatalogo' + '_LockedCol' );
		Grid_LockedCol.cols = parseInt( numcol );

		Budget_Griglia.StartScrolledGrid(  'GridCatalogo'  );
	}catch(e){}; 
}


