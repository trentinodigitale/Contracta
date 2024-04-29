

//per fare la copia dei documenti (generici e non ) da un viewer
//strParam=lista filed da svuotare per i documenti generici
//strParamProcess=processo da invocare per i nuovi doc ctl
function Dash_DocCopy(strParam,strParamProcess)
{
	var altro;

	var cod;
	var nq;
  
  var idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	var v = idRow.split(  '~~~' );

	if( idRow == '' )
	{
    alert(CNV('../' ,'E\' necessario selezionare prima una riga'));
    //DMessageBox( '../CTL_Library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
		return;
	}
	
	if( v.length > 1 )
	{
    alert(CNV('../' ,'E\' necessario selezionare una sola riga'));
		//DMessageBox( '../CTL_Library/' , 'E\' necessario selezionare solo una riga' , 'Attenzione' , 2 , 400 , 300 );
		return;
	}
  
  var ListDoc = Grid_GetDOCSelectedRow( 'GridViewer' );
  
  if (ListDoc == 'DOCUMENTO_GENERICO'){
    
    
    //COPIA DOCUMENTO GENERICO  
  	var idmsg = idRow
  	var itype='55';
    var isubtype;
    var Row = Grid_GetIndSelectedRow('GridViewer');
    
    try { 
      isubtype = getObjGrid( 'R' + Row + '_msgISubType').value ; 
    }catch(e){
      isubtype=167;
    }
    
    var const_width=300;
    var const_height=150;
    var sinistra=(screen.width-const_width)/2;
    var alto=(screen.height-const_height)/2;
    var winTake=window.open('../Functions/CopiaDocumento.asp?IdMsg=' + idRow + '&iSubType=' + isubtype + '&iType=' + itype + '&strParam=' + escape( strParam ) ,'take_copy','toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=no,copyhistory=no,scrollbars=no,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');			
    
  }else{
    
    
    //COPIA DOCUMENTO CTL TRAMITE PROCESSO
    parent.Viewer_Command.location =  'ViewerCommand.asp?IDLISTA=' + idRow +'&PROCESS_PARAM=' + strParamProcess + '&DOCLISTA=' + ListDoc;
    
  }
 	
}
