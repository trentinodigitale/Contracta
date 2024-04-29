function OpenCollegati( )
{
  
	var Fascicolo = '';
	try	{ 	Fascicolo = getObjValue( 'Fascicolo')	}catch( e ) {};

	
	var URL = '../dashboard/mainView.asp?A=A&FOLDER_GROUP=LINKED_ISCRIZIONE_ALBO&FilterHide= Fascicolo = \'' + Fascicolo + '\' ';
	
	
	parent.parent.parent.DocumentiCollegati( URL );

}