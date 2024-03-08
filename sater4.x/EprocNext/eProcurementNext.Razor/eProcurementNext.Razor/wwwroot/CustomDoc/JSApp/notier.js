window.onload = viewBustaZip;

function DettNOTIER(strNameGrid,riga, nIndCell )
{
	var urn = getObjValue('R' + riga + '_URN');

	sganciaNotRead(riga);

	PrintPdf('/notier/dettaglio.asp&PDF_NAME=dettaglio&backoffice=yes&urn=' + encodeURI(urn) + '&pfu=' + encodeURI(idpfuUtenteCollegato));

}

function selOrdineNoTIER(strNameGrid,riga, nIndCell )
{
	var urnOrdine = getObjValue('R' + riga + '_URN');
	var DOC_TO_UPD=getQSParam('doc_to_upd');

	var tipoDocumento = getObjValue('R' + riga + '_CHIAVE_TIPODOCUMENTO');
	
	if ( tipoDocumento == 'ORDINE' )
	{
		ExecFunctionSelf(pathRoot + 'notier/associaOrdine.aspx?pfu=' + encodeURI(idpfuUtenteCollegato) + '&ddt=' + encodeURI(DOC_TO_UPD) + '&urn=' + encodeURI(urnOrdine));
	}
	else if( tipoDocumento == 'FATTURA' )
	{
		var idDocSelezionato = getObjValue('R' + riga + '_id');
		ExecFunctionSelf(pathRoot + 'notier/associaDDT.asp?tipodoc=FATTURA&doc_collegato=' + encodeURI(DOC_TO_UPD) + '&doc_selezionato=' + encodeURI(idDocSelezionato));
	}
	else
	{
		var idDocSelezionato = getObjValue('R' + riga + '_id');
		ExecFunctionSelf(pathRoot + 'notier/associaDDT.asp?doc_collegato=' + encodeURI(DOC_TO_UPD) + '&doc_selezionato=' + encodeURI(idDocSelezionato));
	}
}

function DettXmlNOTIER(strNameGrid,riga, nIndCell )
{
	var urn = getObjValue('R' + riga + '_URN');
	sganciaNotRead(riga);
	
	ExecDownloadSelf(pathRoot + 'notier/dettaglio.asp?pfu=' + encodeURI(idpfuUtenteCollegato) + '&raw=1&urn=' + encodeURI(urn));
}

function DettZipNOTIER(strNameGrid,riga, nIndCell )
{
	var urn = getObjValue('R' + riga + '_URN');
	ExecDownloadSelf(pathRoot + 'notier/dettaglio.asp?pfu=' + encodeURI(idpfuUtenteCollegato) + '&zip=1&raw=1&urn=' + encodeURI(urn));
}

function sganciaNotRead(riga)
{
	try
	{
		$( '#GridViewerR' + riga ).find( "td" ).removeClass( "NOTREAD_Text" ).removeClass( "NOTREAD_Date" ).removeClass( "NOTREAD_FldDomainValue" ).removeClass( "NOTREAD_GridCol_Link" );
		$( '#GridViewerR' + riga ).find( "td" ).removeClass("notread_Text").removeClass( "notread_Date" ).removeClass( "notread_FldDomainValue" ).removeClass( "notread_gridcol_link" )
		
		checkDownloadZip(riga);
	}
	catch(e)
	{
	}
}

function checkDownloadZip(riga)
{
	/* PER POTER RICHIEDERE IL DOWNLOAD DELLO ZIP LA RIGA DEVE FAR RIFERIMENTO AD UN ORDINE E DEVE ESSERE LETTA */
	var bloccaZip;
	
	bloccaZip = false;
	
	if ( getObjValue('val_R' + riga + '_CHIAVE_TIPODOCUMENTO') != 'ORDINE')
	{
		bloccaZip = true;
	}
	
	if ( $( '#GridViewerR' + riga ).find( "td" ).hasClass( "NOTREAD_Text" ) )
	{
		bloccaZip = true;
	}
	
	if ( bloccaZip )
	{
		getObj('R' + riga + '_FNZ_DEL').style.display = 'none';
		getObj('R' + riga + '_FNZ_DEL').parentNode.parentNode.className = '';
	}
	else
	{
		getObj('R' + riga + '_FNZ_DEL').style.display = '';
	}
	
}

function viewBustaZip()
{
	// SE ESISTE LA COLONNA PER IL DOWNLOAD DELLO ZIP
	if ( GridViewer_NumRow > 0 && getObj('R' + GridViewer_StartRow + '_FNZ_DEL') )
	{
		for (var i = GridViewer_StartRow; i <= GridViewer_EndRow; i++) 
		{
			try
			{
				checkDownloadZip(i);
			}
			catch(e)
			{
			}
		}
	}
}

function downloadZipDocumenti()
{
	var anno = getObjValue('CHIAVE_ANNO');
	var tipiDoc = getObjValue('CHIAVE_TIPODOCUMENTO');
	
	if ( anno == '' || tipiDoc == '' )
	{
		DMessageBox( '../' , 'Selezionare anno e tipo documento' , 'Attenzione' , 1 , 400 , 300 );	
	}
	else
	{
		var tipiDocNotier = tipiDoc;
		
		if ( tipiDoc.indexOf('###') >= 0 )
		{
			tipiDoc = tipiDoc.substring(3, tipiDoc.length-3); //togliamo i 3 cancelletti prima e dopo
			tipiDocNotier = tipiDoc.split('###').join(",");
		}
		
		//alert(tipiDocNotier);
		
		ExecDownloadSelf(pathRoot + 'notier/downloadZip.asp?anno=' + encodeURI(anno) + '&tipiDoc=' + encodeURI(tipiDocNotier));
	}
	
}
