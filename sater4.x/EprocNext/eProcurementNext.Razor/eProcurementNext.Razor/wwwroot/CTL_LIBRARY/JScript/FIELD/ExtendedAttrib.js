
//-- opsiziona il controllo
function SetExtPosition( objExt , objRef , width , height)
{
	



}

//-- HideExt( objExt )



//-- variabile per fare da semaforo nel caso in cui la funzione possa essere utilizzata in contemporanea da piu processi
//var inLoad = 0;

function LoadAttrib( Attrib , suffix , filter , user , param , IdDomain , TypeAttrib ,nMultiValue,strValue)
{
	
	//alert(nMultiValue);
	
	var i;
	var c = 0;
	//var objName = Attrib + suffix + filter + user;
	var objName = IdDomain + '_' + TypeAttrib + '_' + suffix + filter + user;
	
	
	//-- aspetta che la pagina si sia caricata
	//if( Loaded == 0 )return; 
	
	//-- loop infinito nel caso in cui è già in corso di caricamento un attributo
	
	/*while( inLoad == 1 && c < 100000 ) {
		c++;
	}
	if ( c == 100000 )
	{	
		alert( 'Attesa prima del caricamento per -> ' + objName );
		//inLoad = 0;
		//return;
	}
	*/
	
	try
	{
		inLoad = 1;
		//objName = Attrib + suffix + filter + user;
		objName = IdDomain + '_' + TypeAttrib + '_' + suffix + filter + user;
	
	
		if( numObjAttrib == 20 )
		{
			inLoad = 0;
			alert( 'Raggiunto numero massimo di attributi estesi' );
			return;
		}
				
		//-- verifica se l'attributo risulta caricato
		//for ( i = 1 ; i <= numObjAttrib ; i++ )
		for ( i = 1 ; i <= 20 ; i++ )
		{
			if ( vetObjAttrib[i] == objName )
			{
				//memorizzo il controllo corrente che sta usando il dominio
				vetObjControlName[i] = Attrib;
				inLoad = 0;
				return;
			}
		}
		var indFree = -1;
		//alert( 'numero di domini ' + numObjAttrib );
		try
		{
			//-- cerca la prima posizione libera
			for ( i = 1 ; i <= 20 ; i++ )
			{
				//alert( 'posizione ' + i + ' valore = ' + vetObjAttrib[i] );
				if ( vetObjAttrib[i] == '' || vetObjAttrib[i] == undefined )
				{
					indFree = i;
					//alert( 'posizione trovata ' + i );
					break;
				}
			}	
		}catch( e ){};
		
		if ( indFree == -1 ) indFree = 1;
		//alert( indFree );
		
		//-- carica il nuovo attributo
		numObjAttrib++; 
		//vetObjAttrib[numObjAttrib] = objName;
		vetObjAttrib[indFree] = objName;
		
		//memorizzo il nome del controllo che sta usando e ha caricato il dominio la chiamata
		//vetObjControlName[numObjAttrib] = Attrib;
		vetObjControlName[indFree] = Attrib;
		
		
		//objFrame=getObj('ExtAttrib_' + numObjAttrib);
		objFrame=getObj('ExtAttrib_' + indFree);
		//objFrame.src=strPathExtObj + 'LoadExtendedAttrib.asp?TypeAttrib=' + TypeAttrib +'&IdDomain=' + IdDomain +'&Attrib=' + Attrib + '&Suffix=' + suffix + '&Filter=' + filter + '&User=' + user + '&Num=' + numObjAttrib + '&' + param;
		
		objFrame.src=strPathExtObj + 'LoadExtendedAttrib.asp?Value=' + escape(strValue) + '&MultiValue=' + nMultiValue +'&TypeAttrib=' + TypeAttrib +'&IdDomain=' + IdDomain +'&Attrib=' + Attrib + '&Suffix=' + suffix + '&Filter=' + filter + '&User=' + user + '&Num=' + indFree + '&' + param;
		
					
	}catch( e ){
	alert('LoadAttrib errore='+e);
	};
			
	//-- tolgo il semaforo
	inLoad = 0;

}

//-- recupera la div che contiene l'attributo che ci serve
function GetAttrib( Attrib , suffix , filter , user, IdDomain , TypeAttrib)
{
	//var objName = Attrib + suffix + filter + user;
	var objName = IdDomain + '_' + TypeAttrib + '_' + suffix + filter + user;
	var i;
	//debugger;

	try
	{

		//-- verifica se l'attributo risulta caricato
		//for ( i = 1 ; i <= numObjAttrib ; i++ )
		for ( i = 1 ; i <= 20 ; i++ )
		{
			if ( vetObjAttrib[i] == objName )
			{
				return getObj( 'ExtAttrib_' + i  );
			}
		}

		
	}catch ( e ) 
	{;}
	
	//LoadAttrib( Attrib , suffix , filter , user);
	alert( 'Oggetto ' + objName + ' non trovato' );
	
	return null;
}




//-- rimuove dai domini estesi un particolare dominio 
function RemoveAttrib( Attrib , suffix , filter , user , param , IdDomain , TypeAttrib )
{
	var objName = IdDomain + '_' + TypeAttrib + '_' + suffix + filter + user;

	try
	{
		inLoad = 1;
		objName = IdDomain + '_' + TypeAttrib + '_' + suffix + filter + user;
	
	
		//-- verifica se l'attributo risulta caricato
		for ( i = 1 ; i <= 20 ; i++ )
		{
			if ( vetObjAttrib[i] == objName )
			{
				//-- decremento il numero di domini estesi caricati
				numObjAttrib--;
				
				//-- svuoto il dominio
				vetObjAttrib[i] = '';
				vetObjControlName[i] = '';
				objFrame=getObj('ExtAttrib_' + i );
				objFrame.src=strPathExtObj + 'loading.html';
				inLoad = 0;
				return;
			}
		}
					
	}catch( e ){};
			
	//-- tolgo il semaforo
	inLoad = 0;

}