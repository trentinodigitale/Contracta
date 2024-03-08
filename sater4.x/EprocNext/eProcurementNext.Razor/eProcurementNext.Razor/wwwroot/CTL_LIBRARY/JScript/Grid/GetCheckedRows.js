//-- ritorna le righe con il check box selezionato
function GetCheckedRows( gridName , columnName, Page )
{
	var objGrid;
	var numRow;
	var objInd;
	var objSel;
	var vSel; 
	var nInd;
	var IsCollection;
	var IsChecked;
	var valore;
	
	//debugger;

	try
	{
		vSel='';
		IsCollection=0;
		
		objGrid = getObj(gridName);
		
		numRow = objGrid.numrow;

		if (numRow==undefined)
		{
			numRow = objGrid(0).numrow;
			IsCollection=1;
		}
		
		for (nInd=0;nInd<=numRow;nInd++)
		{
			//-- prelevo il valore dell'identificativo			
			objSel = getObjPage( 'R' + nInd + '_' + columnName  , Page);
			
			if (IsCollection==1)
				IsChecked=objSel(0).checked;
			else
				IsChecked=objSel.checked;
				
			if ( IsChecked == 1 )
			{
				objInd = getObjPage( gridName + '_idRow_' + nInd , Page);
				
				//if (IsCollection==1)
				//	valore=objInd(0).value;
				//else
				
				valore=objInd.value;
				
				if (vSel=='')
					vSel=valore;
				else
					vSel=vSel + ',' + valore;
			}
		}
		
		return vSel;
	}
	catch(  e ){ ; 	};

}


//-- ritorna le righe con il check box selezionato
function GetCheckedRows2( gridName , columnName, Page )
{
	var objGrid;
	var numRow;
	var objInd;
	var objSel;
	var vSel; 
	var nInd;
	var IsCollection;
	var IsChecked;
	var valore;
	
	//debugger;

	try
	{
		vSel='';
		IsCollection=0;
		
		objGrid = getObj(gridName);
		
		numRow = objGrid.numrow;

		if (numRow==undefined)
		{
			numRow = objGrid(0).numrow;
			IsCollection=1;
		}
		
		objSel = getObjPage( columnName  , Page);
		
		for (nInd=0;nInd<=numRow;nInd++)
		{
					
			
			

			if (objSel.length!=null)
				IsChecked=objSel(nInd).checked;
			else
				IsChecked=objSel.checked;
				
			if ( IsChecked == 1 )
			{
				objInd = getObjPage( gridName + '_idRow_' + nInd , Page);
				
				//if (IsCollection==1)
				//	valore=objInd(0).value;
				//else
				
				valore=objInd.value;
				
				if (vSel=='')
					vSel=valore;
				else
					vSel=vSel + ',' + valore;
			}
		}
		
		return vSel;
	}
	catch(  e ){ ; 	};

}

//-- ritorna le righe con il check box selezionato
function GetPosCheckedRows( gridName , columnName, Page )
{
	var objGrid;
	var numRow;
	var objInd;
	var objSel;
	var vSel; 
	var nInd;
	var IsCollection;
	var IsChecked;
	var valore;
	
	//debugger;

	try
	{
		vSel='';
		IsCollection=0;
		
		objGrid = getObj(gridName);
		
		numRow = objGrid.numrow;

		if (numRow==undefined)
		{
			numRow = objGrid(0).numrow;
			IsCollection=1;
		}
		
		for (nInd=0;nInd<=numRow;nInd++)
		{
			//-- prelevo il valore dell'identificativo			
			objSel = getObjPage( 'R' + nInd + '_' + columnName  , Page);
			
			if (IsCollection==1)
				IsChecked=objSel(0).checked;
			else
				IsChecked=objSel.checked;
				
			if ( IsChecked == 1 )
			{
				
				if (vSel=='')
					vSel=nInd;
				else
					vSel=vSel + ',' + nInd;
			}
		}
		
		return vSel;
	}
	catch(  e ){ ; 	};

}
