function Budget_ExecProcess( param )
{
	var idRow;
	var vet;
	var altro;
	
	//debugger;
  
	var p = getObj('PERIOD').value;
	
	Budget_Command.location =  '../dashboard/ViewerCommand.asp?REFRESH_OBJ=parent&IDLISTA=' + p + '&PROCESS_PARAM=' + param ;

}

