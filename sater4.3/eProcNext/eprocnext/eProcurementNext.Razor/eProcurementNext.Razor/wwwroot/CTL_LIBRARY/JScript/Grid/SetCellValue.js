//-- inserisce un valore in una determinata cella di una griglia
function SetCellValue( grid , idRow , idCol , Value , Page )
{
	var indCol;
	var indRow;
	var objCell;
	
	
	try
	{
		
		//-- cerco la cella 
		indCol = GetPositionCol( grid , idCol , Page );
		indRow = GetPositionRow( grid , idRow , Page );
		
		if ( indCol == -1 || indRow == -1 ) 
		{
			return '';
		}
		
		//-- sostituisco il contenuto
		objCell = getObjPage( grid + '_r' + indRow + '_c' + indCol , Page);
		objCell.innerHTML = Value;
		
	}
	catch(  e ){ return ''; 	};

}
