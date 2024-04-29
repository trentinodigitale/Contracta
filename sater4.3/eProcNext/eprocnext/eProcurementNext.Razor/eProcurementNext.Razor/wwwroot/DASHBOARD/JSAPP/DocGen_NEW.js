function DocGen_NEW(Itype,Isubtype,IDMP,StrCommand)
{
	const_width=690;
	const_height=500;
	sinistra=(screen.width-const_width)/2;
	//creo una variabile e mi ricavo il valore della posizione della finestra a sinistra dello schermo
	alto=(screen.height-const_height)/2;
	window.open('../AFLCommon/FolderGeneric/NewDoc.asp?lItypePar='+Itype+'&lISubTypePar='+Isubtype+'&lIdmpPar='+IDMP+'&StrCommandPar='+StrCommand,'NewDoc','toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
}
 
