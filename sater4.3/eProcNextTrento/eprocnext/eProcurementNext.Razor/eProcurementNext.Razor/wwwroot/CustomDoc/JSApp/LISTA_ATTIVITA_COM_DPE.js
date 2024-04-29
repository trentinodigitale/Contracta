
function Prosegui(){

		
	
	var STRURLPARTECIPA=getObjPage( "STRURLPARTECIPA", "parent").value ;
	
	if ( (GridViewer_NumRow == 0 && getObj('GridViewer_idRow_0').value == -1 ) )	
	{
		Provenienza='LISTA'
		self.location='../checkattivita.asp?STRURLPARTECIPA=' + escape( STRURLPARTECIPA ) +  '&OpenApplication=1&Provenienza=' + Provenienza + '&lScreen=' + window.screen.availWidth;
	}else{
		parent.ViewerGriglia.location = parent.ViewerGriglia.location + '&FilterHide= id <> -1' ;
		parent.Viewer_Command.location =  'ViewerCommand.asp?IDLISTA=1&PROCESS_PARAM=PROSEGUI,COM_DPE_FORNITORE';
	}
}


function Salta(){
	
	var STRURLPARTECIPA=getObjPage( "STRURLPARTECIPA", "parent").value ;
	
	if ( GridViewer_NumRow == -1 )
	{
		Provenienza='LISTA'
		self.location='../checkattivita.asp?STRURLPARTECIPA=' + escape( STRURLPARTECIPA ) +  '&OpenApplication=1&Provenienza=' + Provenienza + '&lScreen=' + window.screen.availWidth;
	}
}

window.onload = Salta ;

