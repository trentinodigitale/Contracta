
function Budget_OpenMovement( strNameGrid,nIndRow,nIndCol )
{
	var period;
	var sel;
	var nIdDett;
	
	nIdDett=GetIdRow( strNameGrid , nIndRow , '')
	
	try {

		ExecFunction( 'Budget_Command.asp?COMMAND=OPEN_MOVEMENT&IDROW=' + nIdDett  , 'Budget_Command' , '' );
		
	}
	catch( e ) {};

}

function Budget_OpenMovement2( strNameGrid,nIndRow,nIndCol )
{
	var period;
	var sel;
	var nIdDett;
	
	nIdDett=GetIdRow( strNameGrid , nIndRow , '')
	
	try {

		//ExecFunction( '../budget/Budget_Command.asp?COMMAND=OPEN_MOVEMENT&IDROW=' + nIdDett  , 'Viewer_Command' , '' );
		ExecFunction( '../AFLBuyer/FolderOrdine/FormOrdine.asp?Identificativo=' + nIdDett + '&IDMP=1&OnlyRead=1&IdPfuDossier=1' , '' , '' );	
	
	}
	catch( e ) {};

}

