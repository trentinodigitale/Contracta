//-- ritorna l'identificativo della prima riga selezionata
function GetPosSelectedRow( columnName , Page )
{
	var objSelection;
	var objInd;
	var iNumCeck;
	var indSel;
	var nInd; 
	var idRow;
	
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
		
		
	}
	catch(  e ){ ; 	};

	return indSel;


}
