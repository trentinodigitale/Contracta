function DMessageBox( path , Text , Title , ICO , w , h)
{



	var Left = (screen.availWidth-w)/2;
	var Top  = (screen.availHeight-h)/2;
	var strPosition = ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h ;
		

	ExecFunction( path + 'MessageBoxWin.asp?ML=yes&MSG=' + Text +'&CAPTION=' + Title + '&ICO=' + ICO , 'MSGBOX' , strPosition );


}

function DrillReport4( strNameGrid,nameField, nIndCell )
{
	
	var VetPos = GetPositionDimensionOfCell( strNameGrid, nIndCell);
	
	if ( Grid_vetDimElem[1][VetPos[2]] == 'Percentuale su Totale Bandi' )
	{
		DMessageBox( '../ctl_library/' , 'selezione non valida' , 'Attenzione' , 1 , 400 , 300 );
		return;
	}
		
	
	var URL = 'Viewer.asp?Table=REPORT_4_DRILL_DOWN&IDENTITY=IdRow&DOCUMENT=SCHEDA_PROGETTO&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=Dettaglio schede gara&Height=0,100*,210&numRowForPag=20&Sort=ProtocolloBando&SortOrder=&Exit=si';


	//-- filtro per il periodo
	URL = URL + '&FilterHide=Descrizione=\'' + Grid_vetDimElem[0][VetPos[1]] + '\' ';
	
	//-- filtro sul tipo gara
	if ( VetPos[2] < 2   )
	{
		URL = URL + ' and TipoGara = \'' + Grid_vetDimElem[1][VetPos[2]] + '\' ';
	}
	
	//-- filtro sull'attributo
	URL = URL + ' and ' + nameField + ' = 1 ';
	
	
	
	var w;
	var h;
	var Left;
	var Top;

	w = 900;
	h = 600;
	Left = (screen.availWidth-w)/2;
	Top  = (screen.availHeight-h)/2;



	
	var w = ExecFunction( URL  , 'DrillREP4' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
	w.focus();
	

}

function DrillReport8( strNameGrid,nameField, nIndCell )
{
	var VetPos = GetPositionDimensionOfCell( strNameGrid, nIndCell);
	
	if ( Grid_vetDimElem[1][VetPos[2]] == 'Durata Media' )
	{
		DMessageBox( '../ctl_library/' , 'selezione non valida' , 'Attenzione' , 1 , 400 , 300 );
		return;
	}
	var idDoc = Grid_vetDimElem[1][VetPos[2]].replace( '  ' , '' );
	idDoc = idDoc.replace( '/' , '_' );
	
	ShowDocument( 'SCHEDA_PROGETTO' , idDoc );

}


function ShowDocument( strDoc , cod )
{
	var nq;

	
	var w;
	var h;
	var Left;
	var Top;
    
	w = screen.availWidth * 0.9;
	h = screen.availHeight  * 0.9;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
  
	
	//ExecFunction(  '../CTL_Library/Document/document.asp?JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + cod  , strDoc + '_DOC_' + cod , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
	ExecFunction(  '../customdoc/ReportDocument.asp?JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + cod  , strDoc + '_DOC_' + cod , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );

}




function DrillRep6( strNameGrid,nameField, nIndCell )
{

	var VetPos = GetPositionDimensionOfCell( strNameGrid, nIndCell);
	var sqlWhere =  GetSQLFilter( strNameGrid, nIndCell);

	/*	
	if ( Grid_vetDimElem[1][VetPos[2]] == 'Percentuale su Totale Bandi' )
	{
		DMessageBox( '../ctl_library/' , 'selezione non valida' , 'Attenzione' , 1 , 400 , 300 );
		return;
	}
	*/	
	
	var URL = 'Viewer.asp?URLDECODE=yes&ModGriglia=REPORT_4_DRILL_DOWNGriglia&ModelloFiltro=REPORT_4_DRILL_DOWNFiltro&Table=REPORT_6_DRILL_DOWN&IDENTITY=IdRow&DOCUMENT=SCHEDA_PROGETTO&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=Dettaglio schede gara&Height=0,100*,210&numRowForPag=20&Sort=ProtocolloBando&SortOrder=&Exit=si';


	//-- filtro per il periodo
	/*
	URL = URL + '&FilterHide=Descrizione=\'' + Grid_vetDimElem[0][VetPos[1]] + '\' ';
	
	//-- filtro sul tipo gara
	if ( VetPos[2] < 2   )
	{
		URL = URL + ' and TipoGara = \'' + Grid_vetDimElem[1][VetPos[2]] + '\' ';
	}
	*/
	//-- filtro sull'attributo
	
	URL = URL +  '&FilterHide=' +  escape( sqlWhere ) + ' and ' + nameField + ' = 1 ';
	
	
	var w;
	var h;
	var Left;
	var Top;

	w = 900;
	h = 600;
	Left = (screen.availWidth-w)/2;
	Top  = (screen.availHeight-h)/2;



	
	var w = ExecFunction( URL  , 'DrillREP6' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
	w.focus();
	
}

