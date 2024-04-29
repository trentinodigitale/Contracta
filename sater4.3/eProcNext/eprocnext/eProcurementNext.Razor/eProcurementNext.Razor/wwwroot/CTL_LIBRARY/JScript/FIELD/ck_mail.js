
function InfoMailPec( path , cod )
{
  
  //apro il documento INFOPEC
  //ShowDocument( 'INFOPEC' , cod );
  var param='';
  var strDoc='INFOMAIL_PEC';

	if( isSingleWin() == true )
	{
		param = 'ctl_library/document/document.asp?JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=SHOW&lo=base&IDDOC=' + cod ;
		param= pathRoot + 'ctl_library/path.asp?url=' + encodeURIComponent(param) + '&KEY=document';
		ExecFunctionSelf(param,'','');
		
	}
	else
	{
		param = path + '../ctl_library/document/document.asp?JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=SHOW&IDDOC=' + cod ;
	
		param = param + '#DefinizioneIntevallo#800,600#,menubar=yes';
    
		ExecFunctionCenter( param )
	}
}