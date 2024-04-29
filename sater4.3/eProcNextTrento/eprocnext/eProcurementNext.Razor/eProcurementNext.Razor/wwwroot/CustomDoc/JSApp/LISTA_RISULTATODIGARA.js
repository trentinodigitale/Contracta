window.onload = onloadFunc;

function MyDelete(grid,riga,colonna)
{

	if (confirm(CNV('../../', 'Sei sicuro di voler eliminare') + ' ? ') == true) 
	{
		//documenti creati con la nuova gestion, presenti sulla CTL_DOC anche
		if( getObj('PRODOTTIGrid_idRow_' + riga).value != '0')
		{
			var idRiga = getObjValue(grid + '_idRow_' + riga );

			//alert(idRiga);
			Dash_ExecProcessID('ANNULLA,RISULTATODIGARA&TABLE=CTL_DOC&key=id&field=protocollo&SHOW_MSG_INFO=yes' ,idRiga);
		}
		else
		{
			var idRiga = getObjValue('R'+ riga+'_idRowPrincipale');
			Dash_ExecProcessID('ANNULLA_PRE,RISULTATODIGARA&TABLE=Document_RisultatoDiGara_Row&key=idRow&field=Precisazione&SHOW_MSG_INFO=yes' ,idRiga);
		}
	}
	
}

function onloadFunc()
{

	try
	{
		var i;
		var numrrowdoc = Number(GetProperty( getObj('PRODOTTIGrid') , 'numrow') );
		for( i = 0 ; i <= numrrowdoc ; i++ )
		{
			//Se il documento è annullato cancello il cestino
			if( getObjValue('R' + i + '_StatoFunzionale') == 'Annullato' )
			{
				getObj( 'PRODOTTIGrid_r' + i + '_c12' ).innerHTML = '';
				getObj( 'PRODOTTIGrid_r' + i + '_c12' ).removeAttribute('class');
				/* Itero su tutte le colonne della riga cancellata per aggiungere la classe di stile per le cancellate */
				for( k = 1 ; k < 20 ; k++ )
				{
					if ( getObj('PRODOTTIGrid_r' + i + '_c' + k ) )
					{
						var oldClass = getObj('PRODOTTIGrid_r' + i + '_c' + k ).getAttribute('class');
						getObj('PRODOTTIGrid_r' + i + '_c' + k ).setAttribute('class',oldClass + ' riga_cancellata');
					}
				}
				
				
				
				
			}
			//Se il documento è vecchio annullo la lentina
			if( getObj('PRODOTTIGrid_idRow_' + i).value=='0')
			{
				getObj( 'PRODOTTIGrid_r' + i + '_c0' ).innerHTML = '';
				getObj( 'PRODOTTIGrid_r' + i + '_c0' ).removeAttribute('class');
			}

		}

	}
	catch(e){}
}

