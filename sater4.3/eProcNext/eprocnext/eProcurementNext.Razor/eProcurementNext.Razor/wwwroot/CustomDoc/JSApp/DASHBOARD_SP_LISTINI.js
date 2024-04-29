
/*
function ExcelListini()
{
	var nocache = new Date().getTime();
	 
	 //generaFormValueAndSubmit('CurFilter' , '../Report/DASHBOARD_SP_LISTINI.ASPX?nocache=' + nocache, 'newPage' );
	 
	 var campi = { CurFilter:'', UFP:''  };
	 
	 campi.CurFilter = getObjValue( 'CurFilter' );
	 campi.UFP = idpfuUtenteCollegato ;
	 
	 generaFormCollectionAndSubmit( campi, '../Report/DASHBOARD_SP_LISTINI.ASPX?nocache=' + nocache, 'newPage' );

}
*/

function ExcelListini() {
	//var nocache = new Date().getTime();

	//generaFormValueAndSubmit('CurFilter' , '../Report/DASHBOARD_SP_LISTINI.ASPX?nocache=' + nocache, 'newPage' );
	//var campi = { CurFilter:'', UFP:''  };
	//campi.CurFilter = getObjValue( 'CurFilter' );
	//campi.UFP = idpfuUtenteCollegato ;

	//generaFormCollectionAndSubmit( campi, '../Report/DASHBOARD_SP_LISTINI.ASPX?nocache=' + nocache, 'newPage' );

	ExecFunction(pathRoot + 'CTL_Library/accessBarrier.asp?goto=../Report/DASHBOARD_SP_LISTINI.ASPX&filter=' + encodeURIComponent(getObjValue('CurFilter')));

}

