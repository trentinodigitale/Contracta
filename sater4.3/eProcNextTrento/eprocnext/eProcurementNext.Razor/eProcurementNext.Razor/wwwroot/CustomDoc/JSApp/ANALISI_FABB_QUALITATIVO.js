window.onload = OnLoadPage; 


function OnLoadPage()
{


	rimuovilente();



}


function rimuovilente()
{
  // rimuove la funzione di onclick quando non esiste il questionario
  var onclick = '';
  var numeroRighe0 = GetProperty( getObj('VALORIGrid') , 'numrow');
	if(  Number( numeroRighe0 ) > 0 )
	{
		for( i = 0 ; i <= numeroRighe0 ; i++ )
		{
		 try{
				if( getObjValue('R' + i + '_Domanda_Sezione') == 'sezione' )
				{
					obj=getObj('R' + i + '_FNZ_OPEN' ).parentElement;
					onclick='';			
					obj.innerHTML = onclick;
				}
			}
		  catch(e){};
		}
	}
}


function OpnAnalisi( objGrid , Row , c )
{

	var cod;
	var strDoc;

	//-- recupero il codice della riga passata
	{
		cod = getObj( 'R' + Row + '_' + objGrid + '_ID_DOC').value;
	} 

	{
		strDoc = 'ANALISI_DOMANDA'
	}
	

    ShowDocument(strDoc , cod )	;

}



