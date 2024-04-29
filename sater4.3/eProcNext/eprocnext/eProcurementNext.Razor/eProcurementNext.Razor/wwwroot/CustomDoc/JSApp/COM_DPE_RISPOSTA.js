window.onload = OnLoadPage; 

function OnLoadPage()
{
var onclick='';
// rimuove la funzione di onclick quando non esiste il questionario
  var numeroRighe0 = GetProperty( getObj('GridViewer') , 'numrow');
	if(  Number( numeroRighe0 ) > 0 )
	{
		for( i = 0 ; i <= numeroRighe0 ; i++ )
		{
		 if( getObjValue('R' + i + '_Fascicolo') == '' )
		 {
			obj=getObj('val_R' + i + '_OpenCollegati' ).parentElement;
			onclick='';			
			obj.innerHTML = onclick;
		 }
		}
	}
}