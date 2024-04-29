

//InsertAzi          ('1','1214','55','170','CompanyDes_GridDest','4256');
//function InsertAzi(IdMp,IdMsg,IType,ISubType,strFullAreaName,IdModello)
function InsertAzi()
{
	
	
	var IDDOC;
	
	idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	
	if( idRow == '' )
	{
		DMessageBox( '../CTL_Library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
		return;
	}
	
	var strSelected = ReplaceExtended(idRow, '~~~' , ',');
	
	
	
	var IdMsg= parent.opener.getObj( 'lIdMsgPar' ).value;
	var strFullAreaName='CompanyDes_GridDest';
	var IdModello = 4256;

	var IdMp = '1';
	var IType = '55';
	var ISubType = '170';
	
	 
	 
	 
	parent.Viewer_Command.location = '../AFLCommon/FolderGeneric/Command/CompanyDes/UpdateSearch.asp?TypeOperation=I&IDMP='+IdMp+'&IdMsg='+IdMsg+'&IdAziendaSelNavigazione='+escape(strSelected)+'&strFullAreaName='+strFullAreaName+'&ISubType='+ISubType+'&IType='+IType+'&IdModello='+IdModello;
	
}

function ReplaceExtended(strExpression,strFind,strReplace){

  while (strExpression.indexOf(strFind)>=0)
  	strExpression=strExpression.replace(strFind,strReplace);
		
  return strExpression;
}

function Run_UPDAZI() {
	
	var strelemento;
	var strmod;
	var ILoop;
	var IdAzi;

	var IDDOC;
	
	idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	
	if( idRow == '' )
	{
		DMessageBox( '../CTL_Library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
		return;
	}
	if( idRow.indexOf( '~~~' , 0 ) > 0 )
	{
		DMessageBox( '../CTL_Library/' , 'E\' necessario selezionare solo una riga' , 'Attenzione' , 2 , 400 , 300 );
		return;
	}
	
	var  strIdAziSel = idRow;
	var w = 400;
	var h = 350; 
	var Left= (screen.availWidth - w) / 2;
	var Top= (screen.availHeight - h ) / 2; 
		
	window.open( '../DASHBOARD/Viewer.asp?OWNER=idpfu&Table=DASHBOARD_VIEW_UPDAZI&IDENTITY=PARAM&DOCUMENT=,' + strIdAziSel + '&PATHTOOLBAR=../CustomDoc/&JSCRIPT=anagrafica&AreaAdd=no&Caption=Modifica anagrafica&Height=0,100*,210&numRowForPag=20&Sort=&SortOrder=&Exit=si&AreaFiltro=no&FilterHide=idazi = ' + strIdAziSel , 'UPDAZI' , 'toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=yes,scrollbars=yes,height=' + h + ',width=' + w + ',left=' + Left + ',top=' + Top);
	
}


function ReplaceAzi(){
	
	var IDDOC;
	
	idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	
	if( idRow == '' )
	{
		DMessageBox( '../CTL_Library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
		return;
	}
	
	var strSelected = ReplaceExtended(idRow, '~~~' , ',');
	
	var IdMsg= parent.opener.getObj( 'lIdMsgPar' ).value;
	var strFullAreaName='CompanyDes_GridDest';
	var IdModello = 4256;

	var IdMp = '1';
	var IType = '55';
	var ISubType = '170';
	var strIdAziSel
	strIdAziSel = '';

	
	strCeck= eval('parent.opener.document.new_document.CompanyDes_GridDest_seleziona_articoli');
	if (strCeck != null){
	        len=strCeck.length;
		
		if (len != null){

			indexText=1;

			for (iLoop=0;iLoop<len;iLoop++, indexText++){

				TextHidden = eval('parent.opener.document.new_document.CompanyDes_GridDest_'+ indexText + '_0');
				
				if (strCeck[iLoop].checked)
				{
					if (strIdAziSel=='')
						strIdAziSel=strIdAziSel + TextHidden.value;
					else
						strIdAziSel=strIdAziSel + ',' + TextHidden.value;
				}		
			}
		}
		else{
		    
		    if (len == null)
			{
			  //ci troviamo nel caso di una sola azienda
			  TextHidden = eval('parent.opener.document.new_document.CompanyDes_GridDest_1_0');
			  
			  strIdAziSel=TextHidden.value;
			
			}
		}
	} 
	 
	IdAziReplace=strIdAziSel;
	if (IdAziReplace=='')
		alert('selezionare l\'azienda da sostituire nel tabulato');
	else
	parent.Viewer_Command.location = '../AFLCommon/FolderGeneric/Command/CompanyDes/UpdateSearch.asp?IdAziReplace=' + IdAziReplace + '&TypeOperation=R&IDMP='+IdMp+'&IdMsg='+IdMsg+'&IdAziendaSelNavigazione='+escape(strSelected)+'&strFullAreaName='+strFullAreaName+'&ISubType='+ISubType+'&IType='+IType+'&IdModello='+IdModello;
	
}


//per aggiugnere le aziende da un tabulato
function ImportaDaTabulato()
{
	
	
	var IDDOC;
	
	idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	
	if( idRow == '' )
	{
		DMessageBox( '../CTL_Library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
		return;
	}
	
	var strSelected = ReplaceExtended(idRow, '~~~' , ',');
	
	
	
	var IdMsg= parent.opener.getObj( 'lIdMsgPar' ).value;
	var strFullAreaName='CompanyDes_GridDest';
	var IdModello = 4256;

	var IdMp = '1';
	var IType = '55';
	var ISubType = '170';
	
	 
	 
	//alert(idRow); 
	//parent.Viewer_Command.location = '../AFLCommon/FolderGeneric/Command/CompanyDes/InsertAziFromTabulato.asp?IDMP='+IdMp+'&IdMsg='+IdMsg+'&strFullAreaName='+strFullAreaName+'&ISubType='+ISubType+'&IType='+IType+'&IdModello='+IdModello;
	//parent.Viewer_Command.location = '../AFLCommon/FolderGeneric/Command/CompanyDes/InsertAziFromTabulato.asp?lIdMsgDest='+IdMsg+'&IDMP='+IdMp+'&lIdMsgPar='+idRow+'&strFullAreaName='+strFullAreaName+'&ISubType='+ISubType+'&IType='+IType+'&IdModello='+IdModello;
	
	var strUrl = '../AFLCommon/FolderGeneric/Command/CompanyDes/InsertAziFromTabulato.asp?lIdMsgDest='+IdMsg+'&IDMP='+IdMp+'&lIdMsgPar='+idRow+'&strFullAreaName='+strFullAreaName+'&ISubType='+ISubType+'&IType='+IType+'&IdModello='+IdModello;
	
	const_width=300;
	const_height=120;
	sinistra=(screen.width-const_width)/2;
	alto=(screen.height-const_height)/2;
	
	me=winPrint=window.open('','ImportaDaTabulato','toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
	me.document.write('<html><head><title>Elaborazione In Corso</title></head><center><font Arial size=2>Elaborazione In Corso</font></center></html>');
	me.location= strUrl ;
	//document.new_document.target='ImportaDaTabulato';
	//document.new_document.submit();
	
}


//per fare il merge tra il tabulato ed un altro tabulato
function MergeDaTabulato()
{
	
	
	var IDDOC;
	
	idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	
	if( idRow == '' )
	{
		DMessageBox( '../CTL_Library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
		return;
	}
	
	var strSelected = ReplaceExtended(idRow, '~~~' , ',');
	
	
	
	var IdMsg= parent.opener.getObj( 'lIdMsgPar' ).value;
	var strFullAreaName='CompanyDes_GridDest';
	var IdModello = 4256;

	var IdMp = '1';
	var IType = '55';
	var ISubType = '170';
	
	 
	 
	//alert(idRow); 
	//parent.Viewer_Command.location = '../AFLCommon/FolderGeneric/Command/CompanyDes/InsertAziFromTabulato.asp?IDMP='+IdMp+'&IdMsg='+IdMsg+'&strFullAreaName='+strFullAreaName+'&ISubType='+ISubType+'&IType='+IType+'&IdModello='+IdModello;
	//parent.Viewer_Command.location = '../AFLCommon/FolderGeneric/Command/CompanyDes/InsertAziFromTabulato.asp?lIdMsgDest='+IdMsg+'&IDMP='+IdMp+'&lIdMsgPar='+idRow+'&strFullAreaName='+strFullAreaName+'&ISubType='+ISubType+'&IType='+IType+'&IdModello='+IdModello;
	
	var strUrl = '../AFLCommon/FolderGeneric/Command/CompanyDes/MergeFromTabulato.asp?lIdMsgDest='+IdMsg+'&IDMP='+IdMp+'&lIdMsgPar='+idRow+'&strFullAreaName='+strFullAreaName+'&ISubType='+ISubType+'&IType='+IType+'&IdModello='+IdModello;
	
	const_width=300;
	const_height=120;
	sinistra=(screen.width-const_width)/2;
	alto=(screen.height-const_height)/2;
	
	me=winPrint=window.open('','MergeFromTabulato','toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
	me.document.write('<html><head><title>Elaborazione In Corso</title></head><center><font Arial size=2>Elaborazione In Corso</font></center></html>');
	me.location= strUrl ;
	//document.new_document.target='ImportaDaTabulato';
	//document.new_document.submit();
	
}