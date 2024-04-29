function OpenDocSingleViewer( cod , strDoc )
{

	//ShowDocument( strDoc , cod );
	self.location='../ctl_library/document/document.asp?JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + cod + '&lo=base' ;

}
