
window.onload = OnLoadPage; 

function OnLoadPage()
{	
	if ( getObj('StatoFunzionale').value == 'InLavorazione' )
	{
		Onchange_Nuova_Convenzione();
		filtro_convenzione();
	}
}
   
function Onchange_Nuova_Convenzione()
{
	if( getObj('Nuova_Convenzione').checked == true)
	{
		
		try{
			getObj('Convenzione').value='';
			getObj('Convenzione_edit_new').value='';
			}catch(e){}
		
		$( "#cap_Convenzione" ).parents("table:first").css({"display":"none"});
	}
	else
	{
		$( "#cap_Convenzione" ).parents("table:first").css({"display":""});
	}	

}

function filtro_convenzione()
{
	
	var identificativo_iniziativa=getObj('IdentificativoIniziativa').value;
	var id_convenzione=getObj('LinkedDoc').value;
	
	
	var filter = '';
	filter =  GetProperty ( getObj('Convenzione'),'filter') ;	
		
	if ( filter == '' || filter == undefined || filter == null )
	{
		SetProperty( getObj('Convenzione'),'filter','SQL_WHERE= DC.id in  ( select distinct id from document_convenzione where identificativoiniziativa=\''+ identificativo_iniziativa +'\' and id <> ' + id_convenzione + ' )' );
	}
	else
	{
		SetProperty( getObj('Convenzione'),'filter',filter + ' and DC.id in  ( select distinct id from document_convenzione where identificativoiniziativa=\''+ identificativo_iniziativa +'\' and id <> ' + id_convenzione + ' )' );
	}
}

function MySend(param)
{
	if( getObj('Nuova_Convenzione').checked == false && getObj('Convenzione').value == '' )
	{
		 TxtErr( 'Nuova_Convenzione' );
		 TxtErr( 'Convenzione' );
		 DMessageBox( '../' , 'Prima di Inviare il documento compilare i campi obbligatori' , 'Attenzione' , 1 , 400 , 300 );
		 return;		 
	}
	  
	TxtOK( 'Nuova_Convenzione' );
	TxtOK( 'Convenzione' );	
	
	ExecDocProcess( param );


}

function afterProcess( param )
{
	
	if ( param == 'SEND' && getObj('APRI_DOCUMENTO').value == 'SI' )
    {
      ShowDocumentFromAttrib('CONVENZIONE,Id_Doc_New');
    }
	
}