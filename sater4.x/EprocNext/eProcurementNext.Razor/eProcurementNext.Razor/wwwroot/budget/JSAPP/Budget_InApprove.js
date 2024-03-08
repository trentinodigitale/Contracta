


function Budget_InApprove()
{

 
 var Periodo = getObj('PERIODO').options[getObj('PERIODO').selectedIndex].value;
 var Ret = "0" ;
 
 ajax = GetXMLHttpRequest(); 
	if(ajax){
	     
			ajax.open("GET", '/application/Budget/BudgetCheckRange.asp?PERIODO=' + Periodo , false);
			ajax.send(null);
			if(ajax.readyState == 4) {
				if(ajax.status == 200)
				{
					Ret = ajax.responseText;
				}
			}

	}
 
	if ( Ret == '1' ){
  	try {
  	
  		ExecFunction( 'Budget_Command.asp?COMMAND=UP_LEVEL' , 'Budget_Command' , '' );
  	}
  	catch( e ) {};
  }else
     DMessageBox( '../CTL_LIBRARY/' , 'Non posso inviare budget' , 'Attenzione' , 2 , 400 , 300 );
}


function DMessageBox( path , Text , Title , ICO , w , h)
{



	var Left = (screen.availWidth-w)/2;
	var Top  = (screen.availHeight-h)/2;
	var strPosition = ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h ;
		

	ExecFunction( path + 'MessageBoxWin.asp?ML=yes&MSG=' + Text +'&CAPTION=' + Title + '&ICO=' + ICO , 'MSGBOX' , strPosition );


}