function CreaPreventivo( strparam )
{

	idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	
	if( idRow == '' )
	{
		DMessageBox( '../CTL_Library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
		return;
	}
	
	idRow = idRow.replace( '~~~' , ',')
	
	/*var w;
	var h;
	var Left;
	var Top;
    
	w = 800; 
	h = 600; 
	Left= (screen.availWidth - 800) / 2;
	Top= (screen.availHeight - 600) / 2;
	
	strSql='select * from VIEW_PRODOTTI_PREVENTIVO where IDDOC in (' + idRow + ')';
	strUrl='NewGenDoc.asp?SQLPRODOTTI=' + strSql + '&PARAM=68;4492;2;1;ECONOMICA;SHOW;'
	*/
	
	INSERTARTICLE_FROMCATALOGUE('hide','C','351','357','1','55','68','','ECONOMICA_griglia','',idRow)
	
	//ExecFunction(  strUrl , 'NEWGENDOC' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
  

}

function INSERTARTICLE_FROMCATALOGUE(ShowDialog,TypeCatalogo,lIdModFilter,lIdModVisual,IDMP,iTypeMes,iSubTypeMes,strIdTidDominiEstesi, strAreaName,strKeyCaptionForm,idRowMessage)
{
	
		const_width=500;
		const_height=500;
		sinistra=(screen.width-const_width)/2;
		alto=(screen.height-const_height)/2;
		
		strUrl='../aflcommon/foldergeneric/FrameFormRicercaAvanzata.asp?ListMsg='+idRowMessage+'&strKeyCaptionForm='+strKeyCaptionForm+'&ShowDialog='+ShowDialog+'&TypeCatalogo='+TypeCatalogo+'&lIdModFilter='+lIdModFilter+'&lIdModVisual='+lIdModVisual+'&iTypeMes='+iTypeMes+'&strAreaName='+strAreaName+'&iSubTypeMes='+iSubTypeMes+'&IdMsg=&IDMP='+IDMP+'&strIdTidDominiEstesi='+strIdTidDominiEstesi;
		window.open(strUrl,'MotoreRicAva','toolbar=no,location=no,directories=no,status=<%=CONST_STATUS%>,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');

}
