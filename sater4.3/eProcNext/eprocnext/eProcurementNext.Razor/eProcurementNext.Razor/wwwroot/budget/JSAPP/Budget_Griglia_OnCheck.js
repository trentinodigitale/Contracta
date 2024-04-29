
function Budget_Griglia_OnCheck( strNameGrid,nInd,nIndCol )
{
	var nIdDett;
	var query;
	var sel;
    var FilterHide  = getObj( 'FILTERHIDE' ).value;

	//debugger;	
	//nIdDett=GetIdRow( strNameGrid , nIndRow , '')
	try {
		//nIdDett = getObj( strNameGrid + '_idRow_' + nInd ).value;
		//alert( strNameGrid + '_idRow_' + nInd  );
		nIdDett = GetIdRow( strNameGrid , nInd , '' )
		//nIdDett = VetIndexBudget[ nInd ];
		//alert( nIdDett );
		try {
			
			sel = getObj( 'R'+ nInd + '_BDU_Check' )[0].checked;
			var x;
			var s = 0;
			var t;
			for ( x = 0 ; x < 4 ; x++ )
			{
				try{
					if( getObj( 'R'+ nInd + '_BDU_Check' )[x].checked )
					{
						s++;
					}
				}catch( e ){};
			}

			if ( s == 1 )
				t = true;
			else
				t = false;			

			for ( x = 0 ; x < 4 ; x++ )
			{
				try{
					getObj( 'R'+ nInd + '_BDU_Check' )[x].checked = t;
				}catch( e ){};
			}
			sel = t;

		}catch( e ) 
		{
			sel = getObj( 'R'+ nInd + '_BDU_Check' ).checked;
		}

		//alert( sel );

		
		if( sel == true ) 
		{
			sel = '1';
		}else{
			sel = '0';
		}

		ExecFunction( 'Budget_Command.asp?FilterHide=' + FilterHide + '&COMMAND=CHECK&IDROW=' + nInd  + '&SELECTED=' + sel +'&ID_R_TABLE=' + nIdDett, 'Budget_Command' , '' );
	}
	catch( e ) {};
	

}

