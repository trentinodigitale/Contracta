

function Budget_VerificaFE()
{
    //alert(getObj('PERIODO').options[getObj('PERIODO').selectedIndex].value);
    //controllo che impegno  valorizzato
    /*
    numRow = Budget_Griglia.GridCatalogo_NumRow ;
    columnName = 'BDU_Check';
    Page='Budget_Griglia';
    var strListValoriImpegno=",";
    
  	for (nInd=0;nInd<=numRow;nInd++)
		{
			//-- prelevo il valore dell'identificativo			
			objSel = Budget_Griglia.getObj( 'R' + nInd + '_' + columnName  );
			
			//recupero valore riga
  		strCurrentValore=Budget_Griglia.getObj( 'R' + nInd + '_BDD_KeyProgetto').value ;
  		if ( strCurrentValore == undefined )
  		  strCurrentValore=Budget_Griglia.getObj( 'R' + nInd + '_BDD_KeyProgetto')(0).value ;
			
			
		  if (objSel != null){
      	
  			IsChecked=objSel.checked;
  			if  ( IsChecked == undefined )
  			   IsChecked=objSel(0).checked;	
  			
        if ( IsChecked == 1 )
  			{
  				strValueImpegno=Budget_Griglia.getObj( 'R' + nInd + '_BDD_KeyProgetto').value ;
  				if (strValueImpegno==undefined)
  				  strValueImpegno=Budget_Griglia.getObj( 'R' + nInd + '_BDD_KeyProgetto')(0).value ;
  				  
  				//controllo se impegno  valorizzato
  				if (strValueImpegno == ''){
            DMessageBox( '../CTL_LIBRARY/' , 'Impegno non valorizzato per le righe selezionate' , 'Attenzione' , 2 , 400 , 300 );
            return;
          }
             
  			}
  		}
  		
  		//controllo se il valore corrente presente sulle altre righe
      if ( strListValoriImpegno.indexOf(',' + strCurrentValore + ',') == -1 ){
			   strListValoriImpegno = strListValoriImpegno +  strCurrentValore + ',';
			}else{
          DMessageBox( '../CTL_LIBRARY/' , 'Lo stesso impegno  sulle  righe' , 'Attenzione' , 2 , 400 , 300 );
          return;
      }
		}
		

  
  
    
	try {
	
		ExecFunction( 'Budget_Command.asp?COMMAND=UP_LEVEL' , 'Budget_Command' , '' );
	}
	catch( e ) {};
      */
      
  var Ret = "0" ;
  
  ajax = GetXMLHttpRequest(); 
	if(ajax){

			var tmpVirtualDir;
			tmpVirtualDir = '/Application';

			if ( isSingleWin() )
				tmpVirtualDir = urlPortale;
	
			ajax.open("GET", tmpVirtualDir + '/Budget/BudgetCheckImpegno.asp' , false);
			ajax.send(null);
			//alert(ajax.readyState); 
			if(ajax.readyState == 4) {
			  //alert(ajax.status); 
				if(ajax.status == 200)
				{
				  //alert(ajax.responseText);
					Ret = ajax.responseText;
				}
			}

	}
 
	if ( Ret == '1' ){
  	try {
  	 //alert('ok');
  	 ExecFunction( 'Budget_Command.asp?COMMAND=UP_LEVEL' , 'Budget_Command' , '' );
  	}
  	catch( e ) {};
  }else{
     
     ainfo=Ret.split(';');
      
     if ( ainfo[0] == '0' )
        DMessageBox( '../CTL_LIBRARY/' , ainfo[1] , 'Attenzione' , 1 , 400 , 300 );
     
     if  ( ainfo[0] == '3' )
        DMessageBox1( '../CTL_LIBRARY/' , 'Impegno non valorizzato per le righe selezionate' , 'Attenzione' , 1 , 400 , 300 );
  } 
 
}
function DMessageBox( path , Text , Title , ICO , w , h)
{



	var Left = (screen.availWidth-w)/2;
	var Top  = (screen.availHeight-h)/2;
	var strPosition = ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h ;
		

	ExecFunction( path + 'MessageBoxWin.asp?ML=no&MSG=' + Text +'&CAPTION=' + Title + '&ICO=' + ICO , 'MSGBOX' , strPosition );


}

function DMessageBox1( path , Text , Title , ICO , w , h)
{



	var Left = (screen.availWidth-w)/2;
	var Top  = (screen.availHeight-h)/2;
	var strPosition = ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h ;
		

	ExecFunction( path + 'MessageBoxWin.asp?ML=yes&MSG=' + Text +'&CAPTION=' + Title + '&ICO=' + ICO , 'MSGBOX' , strPosition );


}







