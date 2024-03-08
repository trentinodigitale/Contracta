
window.onload=LFN_CONDITION_VIEWER;



function LFN_CONDITION_VIEWER()
{
	//se esiste una riga in uno stato non definitivo attivo il refresh ogni 10 secondi
	//alert(GridViewer_NumRow );
	var numrighe = GridViewer_NumRow ;
	var StatoRow = '';
	
	for (i = 0; i <= numrighe; i++) 
	{
	   
	   //recupero valore per lo statofunzinale della riga del fascicolo
	   //alert ( getObj('R'+ i +'_StatoFunzionale').value ) ;
	   StatoRow = getObj('R'+ i +'_StatoFunzionale').value;
	   
	   if ( StatoRow != 'Completo' && StatoRow != 'Invio_con_errori' && StatoRow != 'Annullato' )
		{
			setTimeout(function(){ RefreshContent(); }, 10000);
			return;
			
		}
		
	}

}


function RefreshContent()
{
	if ( isSingleWin() == false)
	{
		parent.ViewerFiltro.getObj('FormViewerFiltro').submit();
	}
	else
	{
		getObj('FormViewerFiltro').submit();
	}
	
}



