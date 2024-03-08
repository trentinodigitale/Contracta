function TEST_PATH_RETE()
{
	var param=getObj('PercorsoDiRete').value;
	
	if ( param == '' )
	{
		DMessageBox( '../../ctl_library/' , 'Inserire un percorso di rete prima di fare il test' , 'Attenzione' , 1 , 400 , 300 ); 
		return false;
	}

	
	objForm = getObj('FORMDOCUMENT');
	var oldAction = objForm.action;
	var oldtarget = objForm.target;
	
	objForm.action='../../FASCICOLO_GARA/PathStatus.asp?VERIFY=EXISTS';
	//objForm.target='_top';
	// open a new window with proper size    
	window.open("", "MySubWindow", "height=480,width=640");
	objForm.target = "MySubWindow";
	
	objForm.submit();
	
	objForm.action=oldAction; 
	objForm.target=oldtarget;

}




