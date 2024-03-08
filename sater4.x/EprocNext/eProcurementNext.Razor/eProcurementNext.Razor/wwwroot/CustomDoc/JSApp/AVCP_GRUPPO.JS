function RefreshContent()
{
    parent.parent.RefreshDocument('');      
	RefreshDocument('');      
}
function FldExtSelRow  ( objGrid , Row , c )
 {
	var cod;
	var nq;
	var strCommand;
	var testo;	
	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
	try{
		//testo = getObj('R' + Row + '_FNZ_ADD')[0].innerHTML;

		//alert( getObj('R' + Row + '_FNZ_ADD')[0].innerText );
		//alert( testo );

		//testo = testo.replace( 'carrello.GIF' , 'carrellook.GIF');
		//alert( testo );
	
		//testo = '<table  class="FLbl_Tab" ><tr><td ><img border="0" src="../CTL_Library/images/Domain/../toolbar/carrellook.GIF" ></td><td nowrap class="FLbl_label"  id="R0_FNZ_ADD_label" ></td></tr></table>';
		getObj('R' + Row + '_FNZ_ADD')[0].style.border = "solid 1px black"
  	}catch(e){
	}
	
	var strDoc;
	strDoc = getObj('DOCUMENT').value;
	v = strDoc.split('.');
	
	//-- compone il comando per aggiungere la riga
	strCommand = v[0] + '#' + v[1] + '#' + 'IDROW=' + cod + '&TABLEFROMADD=' + v[2];
	
	//alert( strCommand );
	
	//-- invoca sulla pagina chiamante l'aggiunta della riga
	
	parent.opener.ExecDocCommand( strCommand );

	try{ 
		var sec = parent.opener.getObj( 'SECTION_DETTAGLI_NAME' ).value;
		parent.opener.ShowLoading( sec ); 
	}catch( e ){};
	
	

}

 function MyCheckCF (obj)
 {
	
	var row = obj.id.split('_')[1];
	if ( getObj('ROPERATORIGrid_' + row + '_Estero').checked == false )
	{
	   CheckCF( getObj('ROPERATORIGrid_' + row + '_codicefiscale') );
	}
    
 }
function MyExecDocProcess(param)
{
var numeroRighe = GetProperty( getObj('OPERATORIGrid') , 'numrow');

var value ='';
	 for( i = 0 ; i <= numeroRighe ; i++ )
		{
			try
			{
				MyCheckCF (getObj('ROPERATORIGrid_' + i + '_codicefiscale'));
				if( getObj('ROPERATORIGrid_' + i + '_codicefiscale').value == '' )
					{
						value='error';
					}
				
			}
			catch(e){}
		}
	
	if ( value == '' )
	{ 
		ExecDocProcess( param );
	}
	else
	return false; 

}


 