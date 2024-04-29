window.onload=MESSAGGIO_VIEWER;

function MESSAGGIO_VIEWER()
{
	var numRow;
	try{numRow = GridViewer_NumRow}catch(e){}
	//SE ENTRA SIGNIFICA CHE NON TROVA LA GRIGLIA, ALLORA INSERISCO UNA KEY DI MLNG SPECIFICA
	if ( numRow == undefined )
	{		
				
		$('#Div_ViewerGriglia').find('#FormViewerGriglia #_label').html(CNV( '../' ,  'MESSAGGIO_VIEWER_FILTEREDONLY_Gestione_Convenzioni_Creazione_Convenzioni' ));
		
		
	}
		
		
}



function EsportaListiniXLSX()
{
	var ambito = getObjValue('Ambito');
	
	if ( ambito == '' )
	{
		AF_Alert( 'Selezionare prima l\'ambito desiderato' );
	}
	else
	{
		var filtroEffettuato = getObjValue('hiddenViewerCurFilter');
        var stored = 0 ;
        
        if ( getObjValue('QueryString' ).toLowerCase().indexOf("stored_sql=yes") > -1 )
            stored = 1;
        
        
	
		if (filtroEffettuato.indexOf('Ambito') >= 0 ) //|| filtroEffettuato.indexOf('+ Ambito +') >= 0  )
		{
			//ExecDownloadSelf( pathRoot + 'report/esporta_xlsx_listini.aspx?STORED=' + stored + '&filter=' + encodeURIComponent( filtroEffettuato ) ); 	
			ExecDownloadSelf(pathRoot + 'CTL_Library/accessBarrier.asp?goto=../report/esporta_xlsx_listini.aspx&STORED=' + stored + '&filter=' + encodeURIComponent( filtroEffettuato ), '_blank', '');
		}
		else
		{
			AF_Alert( 'Per esportazione dei listini necessario effettuare una ricerca' );
		}
	
	}
	

}
