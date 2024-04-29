
window.onload = OnLoadPage;

function OnLoadPage() 
{
	 if ( getObjValue( 'StatoPDA' ) == '222' )
	 {
		 var numrow = GetProperty( getObj('LOTTIGrid') , 'numrow');
				 
		 for( k = 0 ; k <= numrow ; k++ )
		 {
			FilterDom('RLOTTIGrid_' + k + '_StatoLotto', 'StatoLotto', getObj('RLOTTIGrid_' + k + '_StatoLotto').value, 'SQL_WHERE=  dmv_cod  <> \'AmmessoRiserva\' ', 'LOTTIGrid_' + k , '');
		 }
	 }
}


function Esegue_azione( operazione )
{
	 var valore='';
	 
	if ( operazione == 'Ammettitutti' )
		valore='ammesso';
	if ( operazione == 'Escluditutti' )
		valore='escluso';
	if ( operazione == 'Ammetticonriservatutti' )
		valore='AmmessoRiserva';
	 
	 
	 var numrow = GetProperty( getObj('LOTTIGrid') , 'numrow');
			 
	 for( k = 0 ; k <= numrow ; k++ )
	 {
		getObj('RLOTTIGrid_' + k + '_StatoLotto').value=valore;
	 }
}