
/*
Model=modello attributi da aggiornare
Table=tabella o vista da cui prendere le info
FilterUser=(yes/no)
SqlOperator= like,likeR,likeL,<,>,=,....
js_func_after=se avvalorato al termine chiama questa funzione
*/
function UpdateFieldVisual( objField ,Model, Table , FilterUser , SqlOperator,strDocument,js_func_after )
{ 
	
	var indFree = -1;
	
	//carico nel frame nascosto
	try
	{
		//-- cerca la prima posizione libera
		for ( i = 1 ; i <= 20 ; i++ )
		{
			if ( vetObjAttrib[i] == '' || vetObjAttrib[i] == undefined )
			{
				indFree = i;
				break;
			}
		}	
	}catch( e ){};
	if ( js_func_after == '' || js_func_after == undefined )
	{
		js_func_after='';
	}
	
	if ( indFree == -1 ) indFree = 1;
	
	objFrame=getObj('ExtAttrib_' + indFree);
	objFrame.src='../UpdateFieldVisual.asp?strDocument=' +  encodeURIComponent(strDocument) + '&AttribSource=' + encodeURIComponent(objField.name) + '&SqlOperator=' + encodeURIComponent(SqlOperator) + '&Value=' + encodeURIComponent(objField.value) + '&Model=' + encodeURIComponent(Model) +'&Table=' + encodeURIComponent(Table) +'&Row=-1&FilterUser=' + encodeURIComponent(FilterUser) +'&js_func_after=' + encodeURIComponent(js_func_after) ;
}

function UpdateFieldVisualGrid( objField ,Model, Table , FilterUser , SqlOperator,strDocument )
{ 
	//( recupera l'indice di riga dal attributo
	var v = objField.name.split('_');
	var ind = v[0].substr(1);
	
	var indFree = -1;
	
	//carico nel frame nascosto
	try
	{
		//-- cerca la prima posizione libera
		for ( i = 1 ; i <= 20 ; i++ )
		{
			if ( vetObjAttrib[i] == '' || vetObjAttrib[i] == undefined )
			{
				indFree = i;
				break;
			}
		}	
	}catch( e ){};
	
	if ( indFree == -1 ) indFree = 1;
	
	objFrame=getObj('ExtAttrib_' + indFree);
	
	
	objFrame.src='../UpdateFieldVisual.asp?strDocument=' +  strDocument + '&AttribSource=' + objField.name + '&SqlOperator=' + SqlOperator + '&Value=' + escape(objField.value) + '&Model=' + escape(Model) +'&Table=' + escape(Table) +'&Row=' + ind + '&FilterUser=' + FilterUser  ;
	
	
}
