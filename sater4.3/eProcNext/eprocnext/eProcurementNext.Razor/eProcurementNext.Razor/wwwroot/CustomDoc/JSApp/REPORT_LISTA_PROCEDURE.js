window.onload = onLoadFunc;

function onLoadFunc()
{
	var numrrowdoc = 0
	try{ numrrowdoc = Number(GetProperty( getObj('GridViewer') , 'numrow') );}catch(e){numrrowdoc=0}
	
	if(  numrrowdoc  >= 0 )
	{		 
		 for (t=GridViewer_StartRow ; t < GridViewer_EndRow ; t++)
		 {
			 try
			 {
				if(getObjValue('R' + t + '_idPdA') == '' || getObjValue('R' + t + '_idRowLotto') == '')
				{
					getObj('R' + t + '_FNZ_OPEN').style.display = 'none';
				}
			 }
			 catch(e)
			 {
			 }
		 }

	}
}

function openRiepilogo(objGrid , Row , c )
{
	
	if ( getObj('R' + Row + '_idRowLotto') && getObj('R' + Row + '_idRowLotto').value != '' )
	{
		ShowDocument( 'BANDO_GARA_RIEPILOGO_LOTTO' , getObjValue('R' + Row + '_idRowLotto') );
	}
	else
	{
		//alert('Apertura non possibile per ID lotto mancante');
		alert('La procedura di aggiudicazione è ancora nella fase amministrativa');
	}
}

function EsportaOfferteXLSX()
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
			ExecDownloadSelf(pathRoot + 'CTL_Library/accessBarrier.asp?goto=../report/esporta_xlsx_offerte.aspx&STORED=' + stored + '&filter=' + encodeURIComponent( filtroEffettuato ), '_blank', '');
		}
		else
		{
			AF_Alert( 'Per esportazione delle offerte è necessario effettuare una ricerca' );
		}
	
	}
	

}