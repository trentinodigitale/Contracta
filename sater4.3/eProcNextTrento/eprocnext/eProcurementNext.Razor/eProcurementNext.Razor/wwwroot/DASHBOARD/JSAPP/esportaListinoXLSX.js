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

function EsportaXLSX()
{
	var strSort='';
	
	//-- recupero i Query string per passarla alla stampa
	var QS = getObj('QueryString').value;
	
	//-- tolgo eventuali parametri di caption
	//QS=QS.replace('Caption','OldCaption');
	//QS=QS.replace('caption','OldCaption');
	
	
	//se sul viewer viene usata una stored allora aggiungo alla filterhide opzione per fargli decodificare le colonne dominio
	if ( QS.toUpperCase().indexOf("STORED_SQL=YES") >= 0 )
	{
		var strFilterHide = getQSParamFromString(QS,'FilterHide',true);
		
		//strFilterHide = strFilterHide + '~XLSX' ; 
		QS = QS.replace(strFilterHide, strFilterHide + '~XLSX' );
		
	}
	
	var win;
	win = ExecFunction( 'viewerExcel_x.asp?OPERATION=EXCEL' +  '&'  + QS  , '' , '' );
	
}	