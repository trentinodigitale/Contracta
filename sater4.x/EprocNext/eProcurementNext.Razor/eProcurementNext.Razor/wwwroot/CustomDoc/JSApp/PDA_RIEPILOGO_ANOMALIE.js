window.onload=ReportIntersezioneHTML;
 /*function INTERSEZIONE_OnLoad()
 {
	 
	 ReportIntersezioneHTML();
	 
 }
 */
 
 function ReportIntersezioneHTML(  ){
	
	rimuovilente();
	ajax = GetXMLHttpRequest(); //Creo l'oggetto xmlhttp

	if(ajax){
				 
		
			var idRow = getObjValue( 'IDDOC' )
			prendiElementoDaId( 'INTERSEZIONE' ).innerHTML =  CNV('../../', 'Caricamento in corso...' );
			
			
			ajax.open("GET", '../../Report/PDA_OFFERTA_INTERSEZIONE_LOTTI.asp?IDDOC=' + escape( idRow ) , true);

			ajax.onreadystatechange = function() {
			if(ajax.readyState == 4) {
				if(ajax.status == 200)
				{
					prendiElementoDaId( 'INTERSEZIONE' ).innerHTML =  ajax.responseText;
				}
			}
			}
			ajax.send(null);
		return true;
	}
	return false;
	
	
}

function MyOpenDocumentColumn( objGrid , row , c )
{
	var iddoc = '';
	var tipodoc='';
	
	try	{ 	iddoc = getObj( 'R' + row + '_IdDocOff').value;	}catch( e ) {};
	
	if ( iddoc == '' || iddoc == undefined )
	{
		try	{ 	iddoc = getObj( 'R' + row + '_IdDocOff')[0].value; }catch( e ) {};
	}
	
	try	{ 	tipodoc = getObj( 'R' + row + '_TipoAnomalia').value;	}catch( e ) {};
	
	if ( tipodoc == '' || tipodoc == undefined )
	{
		try	{ 	tipodoc = getObj( 'R' + row + '_TipoAnomalia')[0].value; }catch( e ) {};
	}
	
	
	ShowDocument( tipodoc, iddoc );
	
	
}

function rimuovilente()
{
  // rimuove la funzione di onclick quando non esiste il questionario
  var onclick = '';
  var numeroRighe0 = GetProperty( getObj('ANOMALIEGrid') , 'numrow');
	if(  Number( numeroRighe0 ) >= 0 )
	{
		for( i = 0 ; i <= numeroRighe0 ; i++ )
		{
		 try{
				if( getObjValue('R' + i + '_TipoAnomalia') != 'OFFERTA_ANOMALIE_AMMINISTRATIVA' && getObjValue('R' + i + '_TipoAnomalia') != 'RIAMMISSIONE_OFFERTA' )
				{
					getObj( 'ANOMALIEGrid_r' + i + '_c0' ).innerHTML = '';
					
				}
			}
		  catch(e){};
		}
	}
}
