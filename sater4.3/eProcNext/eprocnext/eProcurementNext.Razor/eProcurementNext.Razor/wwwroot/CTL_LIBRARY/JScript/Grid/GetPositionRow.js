//-- ritorna il numero della riga dove si trova l'idRow richiesto
//-- -1 = riga non presente
function GetPositionRow( grid , idRow , Page )
{

	var objInd;
	var nInd; 
	var objGrid;
	var numRow;
	
	
	try
	{
		objGrid = getObjPage( grid , Page);
		numRow = objGrid.numrow;
		if(  numRow == undefined ) numRow = objGrid[0].numrow;
		
		for (nInd=0;nInd<=numRow;nInd++)
		{
			//-- prelevo il valore dell'identificativo
			objInd = getObjPage( grid + '_idRow_' + nInd , Page);
			
			if (objInd)
			{
				if ( objInd.value == idRow )
				{
					return nInd;
				}
			}
			
		}
		
		return -1;
	}
	catch(  e ){ return -1; 	};

}
