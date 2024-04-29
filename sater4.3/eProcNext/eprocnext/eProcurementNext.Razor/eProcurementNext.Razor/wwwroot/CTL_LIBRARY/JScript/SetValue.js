//-- inserisce un valore in una determinata cella di una griglia
function SetValue( id , Value , Page )
{
	var objCell;
	
	
	try
	{
		
		//-- sostituisco il contenuto
		objCell = getObjPage( id , Page);
		objCell.innerHTML = Value;
		
	}
	catch(  e ){ return ''; 	};

}
