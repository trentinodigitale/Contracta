//-- ritorna il numero della colonna indicando il nome del campo
//-- -1 = colonna non presente  non presente
function GetColName( grid , indexCol , Page )
{

	var objInd;
	var nInd; 
	var obj;
	var numRow;
	var name;
	
	
	try
	{
		
		obj = getObjPage( grid  , Page);

		try
		{
			name =  obj.cells[ indexCol ].id;
		}
		catch(  e ){
			name =  obj[0].cells[ indexCol ].id;
	  	};

		//toglgie dal nome della colonna il nome della griglia
		return name.substr( grid.length + 1 );
	}
	catch(  e ){  	};
	
	
	
	

}
