//-- ritorna il numero della colonna indicando il nome del campo
//-- -1 = colonna non presente  non presente
function GetPositionCol( grid , idCol , Page )
{

	var objInd;
	var nInd; 
	var obj;
	var numRow;
	var attr;
	
	
	try
	{
	
		obj = getObjPage( grid + '_' + idCol , Page);
	
		attr = GetProperty(obj,'column');
	
		return attr;
	}
	catch(  e ){ return -1; 	};

}
