//-- ritorna l'identificativo della prima riga selezionata
function SetPosSelectedRow(  columnName , Page , indSel)
{
	var objSelection;
	var objInd;
	var iNumCeck;
	var nInd; 
	var idRow;
	
	
	
	try
	{
		objSelection  = getObjPage( columnName , Page);

		//-- prelevo l'indice dell'elemento selezionato
		iNumCeck=objSelection.length;
		if (iNumCeck!=null){
			objSelection(indSel).checked = true;
		}else {
			objSelection.checked = true;
		}
		
		return '';
		
	}
	catch(  e ){ return ''; 	};

}
