window.onload = rimuovilente;

function rimuovilente()
{
  // rimuove la funzione di onclick quando non esiste il OPEN_DOC_NAME  
  var onclick = '';
  var numeroRighe0 = GetProperty( getObj('LISTA_DOCUMENTIGrid') , 'numrow');
	
		for( i = 0 ; i <= numeroRighe0 ; i++ )
		{
		 try{
				if( getObjValue('R' + i + '_OPEN_DOC_NAME') == '' )
				{
					getObj( 'LISTA_DOCUMENTIGrid_r' + i + '_c1' ).innerHTML = '';
				}
			}
		  catch(e){};
		}
	
}