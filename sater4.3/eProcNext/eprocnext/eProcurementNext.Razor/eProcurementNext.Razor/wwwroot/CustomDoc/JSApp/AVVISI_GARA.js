window.onload = onloadFunc;

function MyDelete(grid,riga,colonna)
{

	if (confirm(CNV('../../', 'Sei sicuro di voler eliminare') + ' ? ') == true) 
	{
		var idRiga = getObjValue(grid + '_idRow_' + riga );

		//alert(idRiga);
		Dash_ExecProcessID('ANNULLA,AVVISO_GARA&TABLE=CTL_DOC&key=id&field=protocollo&SHOW_MSG_INFO=yes' ,idRiga);
	}
	
}

function onloadFunc()
{

	try
	{
		var i;
		var k;
		
		for( i = 0 ; getObj( 'R' + i + '_StatoFunzionale') != undefined || i > 200 ; i++ )
		{
			//Se l'avviso è annullato cancello il cestino
			if( getObjValue('R' + i + '_StatoFunzionale') == 'Annullato' )
			{
				getObj( 'LISTA_DOCUMENTIGrid_r' + i + '_c8' ).innerHTML = '';
				getObj( 'LISTA_DOCUMENTIGrid_r' + i + '_c8' ).removeAttribute('class');
				
				/* Itero su tutte le colonne della riga cancellata per aggiungere la classe di stile per le cancellate */
				for( k = 2 ; k < 20 ; k++ )
				{
					if ( getObj('LISTA_DOCUMENTIGrid_r' + i + '_c' + k ) )
					{
						var oldClass = getObj('LISTA_DOCUMENTIGrid_r' + i + '_c' + k ).getAttribute('class');
						getObj('LISTA_DOCUMENTIGrid_r' + i + '_c' + k ).setAttribute('class',oldClass + ' riga_cancellata');
					}
				}
				
			}

		}

	}
	catch(e){}
}