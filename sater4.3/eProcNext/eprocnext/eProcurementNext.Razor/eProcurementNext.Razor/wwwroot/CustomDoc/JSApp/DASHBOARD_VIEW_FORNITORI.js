window.onload = Onload_Page;

function Onload_Page()
{
	
	// try{
		// NascondiPulsanteGrigliaVerificato()
	// }catch{
	// }

}


function NascondiPulsanteGrigliaVerificato()
{
	var numrow = GetProperty( getObj('PRODOTTIGrid') , 'numrow');
	for( i = 0 ; i <= numrow ; i++ )
	{
		// var idAziToDelate = document.getElementById('R'+ i +'_ID_AZI_TO_DELETE_VERIFICATO')
		// if (idAziToDelate) = 'null'
		// {
			// console.log('bho');
		// }
	}
	
}

function OpenDocumentVerificato(objGrid , Row , c)
{
	// var idAziToDelate = document.getElementById('R'+ Row +'_ID_AZI_TO_DELETE_VERIFICATO').value
	var idAziToDelate = getObj('R'+ Row +'_ID_AZI_TO_DELETE_VERIFICATO').value
		 if (idAziToDelate != "")
		 {
			 var cod;
			 var nq;

			 //-- recupero il codice della riga passata
			 cod = GetIdRow( objGrid , Row , 'self' );
 
			 var strDoc;
			 strDoc = 'AZI_TO_DELETE_VERIFICATO';
	
			 ShowDocument( strDoc , idAziToDelate );
		 }
	
}




