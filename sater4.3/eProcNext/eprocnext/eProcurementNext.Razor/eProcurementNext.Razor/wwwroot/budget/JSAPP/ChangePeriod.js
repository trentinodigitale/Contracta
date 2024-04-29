function ChangePeriod( obj )
{

	if ( obj.value == '' )
	{
	
		obj.value = getObj( 'PERIOD' ).value;
		return;
	}
	
	var PERIODO = getObj( 'PERIOD' ).value;
  
  //alert ( obj.value ) ;
	var v = parent.frames['intestazione'].getObj('DescFolder').innerText;

	//parent.frames['intestazione'].getObj('DescFolder').innerText = v.substring( 0,v.lenght - 4) + obj.value ;


	//Budget_Griglia.location = 'Budget_Griglia.asp?PERIOD=' + obj.value + '&' + getObj( 'QS' ).value;

	var f = frames['Budget_Filtro'].getObj( 'FormFiltro');
	f.action= f.action.replace( 'PERIOD=' + PERIODO , 'PERIOD=' + obj.value );
	

	f = frames['Budget_Property'].getObj( 'FormProperty');
	f.action= f.action.replace( 'PERIOD=' + PERIODO , 'PERIOD=' + obj.value );
	
	getObj( 'PERIOD' ).value = obj.value;
	
	//ExecNewQuery();

}

function TitleFolder()
{
	
	
	//-- scrivo che il caricamento è in corso
	Budget_Griglia.document.body.innerHTML = '<table class="Loading" width="100%" height="100%" ><tr><td width="100%" height="100%" align="center" valign="center" >Loading ...</td></tr></table>';

	try
	{
		var PERIODO = getObj( 'PERIODO' ).value;

		var cap = parent.frames['intestazione'].getObj('DescFolder').innerText;
	
		parent.frames['intestazione'].getObj('DescFolder').innerText = cap.substr( 0, cap.length - 4 ) + PERIODO.substr( 0 , 4);


	}catch( e ) 
	{
	}

}



function ExecNewQuery()
{

	
	//-- recupero il periodo
	try
	{
		var PERIODO = getObj( 'PERIODO' ).value;
	}catch( e ) 
	{
		var PERIODO = getObj( 'PERIOD' ).value;
	}
	/*
	var cap = parent.frames['intestazione'].getObj('DescFolder').innerText;
	
	parent.frames['intestazione'].getObj('DescFolder').innerText = cap.substr( 0, cap.length - 4 ) + PERIODO.substr( 0 , 4);
	*/
	getObj('Property').value = frames['Budget_Property'].getObj('Property').value;
	
	
	TitleFolder();
	
	//-- recupera tutti i campi dei nmodelli dal filtro e dale property
	var i;
	var v;
	for( i = 0 ; i < NumFldMod ; i++ )
	{
		try{
			v = frames['Budget_Filtro'].getObj(VetFldMod[i]).value;
		}catch( e ){
			v = '';
		}	
		getObj( VetFldMod[i] ).value = v;
	}
	
	var f = getObj( 'FormFiltro');
	var query = getObj( 'QS' ).value;
	
	f.action= 'Budget_Griglia.asp?MODE=FiltraEProperty&PERIOD=' + PERIODO + '&' + query ;
	
	f.submit();

}

function Salta(){
	
	var STRURLPARTECIPA=getObjPage( "STRURLPARTECIPA", "parent").value ;
	
	if ( GridViewer_NumRow == -1 )
	{
		Provenienza='LISTA'
		self.location='../checkattivita.asp?STRURLPARTECIPA=' + escape( STRURLPARTECIPA ) +  '&OpenApplication=1&Provenienza=' + Provenienza + '&lScreen=' + window.screen.availWidth;
	}
}

function BloccaPeriodo(){
 getObj('PERIODO').disabled=true;
}

window.onload = BloccaPeriodo ;