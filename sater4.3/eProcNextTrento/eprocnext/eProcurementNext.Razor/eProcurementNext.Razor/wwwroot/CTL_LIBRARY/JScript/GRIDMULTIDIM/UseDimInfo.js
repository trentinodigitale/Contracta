//-- ritorna un vettore dove per ogni dimensione troviamo l'indice dell'elemento riferito alla cella indicata
function GetPositionDimensionOfCell( grid , cell )
{
	var i;
	var numDim = eval( grid + '_numDim' );
	var vetDimScost = eval( grid + '_vetDimScost' );
	
	var posDim = new Array( numDim + 1);

	//-- azzero il vettore delle posizioni
	for ( i = numDim  ; i >= 0 ; i-- )
		posDim[i] = 0;

	//debugger;
	//-- ciclo su ogni dimensione per determina l'indice
	for ( i = numDim - 1 ; i >= 0 ; i-- )
	{
		while (  cell >= vetDimScost[i] ) 
		{
			posDim[i + 1] = posDim[i + 1] + 1;
			cell = cell - vetDimScost[i];
		}	
	
	}
	
	posDim[0] = cell;
	
	return posDim;

}


function GetSQLFilter( grid , cell )
{

	var posDim = GetPositionDimensionOfCell( grid , cell )
	var numDim = eval( grid + '_numDim' );
	var vetDimName = eval( grid + '_vetDimName' );
	var vetDimElem = eval( grid + '_vetDimElem' );
	var i;
	var SQL = '';
	
	for ( i = numDim - 1 ; i >= 0 ; i-- )
	{
			if ( SQL != '' ) 
			{
				SQL = SQL + ' and ';
			}
			
			SQL = SQL + vetDimName[i] + ' = \'' +  LReplaceExtended( vetDimElem[i][posDim[i+1]], '\'' , '\'\'')  + '\'';
	}
	
	return SQL;
}

function LReplaceExtended(strExpression,strFind,strReplace){

  //while (strExpression.indexOf(strFind)>=0)
  	strExpression=strExpression.replace(strFind,strReplace);
		
  return strExpression;
}