function AggiungiProdotti()
{
  
	var idRow;
	var DOC_TO_UPD=getQSParam('doc_to_upd');
	var DOC_FROM  =getQSParam('doc_from');
	

	idRow = Grid_GetIdSelectedRow( 'GridViewer' );

	//alert(idRow);
	
	if( idRow == '' )
	{
		DMessageBox( '../' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );  
	}
	else
	{
		var parametri =  '';
		
		if ( DOC_FROM == 'NOTIER_INVOICE' )
		{
			parametri = 'INVOICELINE#ADDFROM#IDROW=' + idRow + '&IDDOC='+ DOC_TO_UPD +'&RESPONSE_ESITO=YES&NODUPLICATI=OrderLine_id&TABLEFROMADD=view_addfrom_Document_NoTIER_Prodotti&DOCUMENT=NOTIER_INVOICE';
		}
		else if ( DOC_FROM == 'NOTIER_CREDIT_NOTE' )
		{
			parametri = 'INVOICELINE#ADDFROM#IDROW=' + idRow + '&IDDOC='+ DOC_TO_UPD +'&RESPONSE_ESITO=YES&NODUPLICATI=&TABLEFROMADD=view_addfrom_Document_NoTIER_Prodotti&DOCUMENT=NOTIER_CREDIT_NOTE';
		}
		else
		{
			parametri = 'DESPATCHLINE#ADDFROM#IDROW=' + idRow + '&IDDOC='+ DOC_TO_UPD +'&RESPONSE_ESITO=YES&NODUPLICATI=OrderLine_id&TABLEFROMADD=view_addfrom_Document_NoTIER_Prodotti&DOCUMENT=NOTIER_DDT';
		}

		Viewer_Dettagli_AddSel( parametri);
	}  
}

function DESPATCHLINE_AFTER_COMMAND()
{
	//breadCrumbPop('');
}