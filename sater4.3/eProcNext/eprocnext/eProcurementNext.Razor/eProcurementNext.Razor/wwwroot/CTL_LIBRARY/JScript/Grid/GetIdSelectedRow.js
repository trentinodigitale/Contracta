//-- ritorna l'identificativo della prima riga selezionata
function GetIdSelectedRow( grid , columnName , Page )
{
	var objSelection;
	var objInd;
	var iNumCeck;
	var indSel;
	var nInd; 
	var idRow;
	var objGrid;
	
	indSel = -1;
	
	try
	{
		objSelection  = getObjPage( columnName , Page);

		//-- prelevo l'indice dell'elemento selezionato
		iNumCeck=objSelection.length;
		if (iNumCeck!=null){
			for (nInd=0;nInd<iNumCeck;nInd++){
				if (objSelection(nInd).checked) {
					indSel = nInd;
					break;
				}		
			}
		}else {
			if (objSelection.checked)
				indSel = 0;
		}
		
		//-- nel caso che la griglia contenga i riquadri bloccati( quindi ci sono più griglie) fa il modulo sulle righe 
		objGrid = getObjPage( grid  , Page)
		iNumCeck=objGrid.length
		if (iNumCeck!=null){
			indSel = indSel % (parseInt(objGrid[0].numrow) + 1);
		}
		
		
		//-- è selezionato un elemento
		if( indSel >= 0 )
		{
			//-- prelevo il valore dell'identificativo
			objInd = getObjPage( grid + '_idRow_' + indSel , Page);
			return objInd.value;
		
		}
		else
			return '';
		
	}
	catch(  e ){ return ''; 	};

}
