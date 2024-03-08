window.onload = Onload_Process;

function getQSParam(ParamName)
{
	// Memorizzo tutta la QueryString in una variabile
	QS=window.location.toString(); 
	// Posizione di inizio della variabile richiesta
	var indSta=QS.indexOf(ParamName); 
	// Se la variabile passata non esiste o il parametro è vuoto, restituisco null
	if (indSta==-1 || ParamName=="") return null; 
	// Posizione finale, determinata da una eventuale &amp; che serve per concatenare più variabili
	var indEnd=QS.indexOf('&',indSta); 
	// Se non c'è una &amp;, il punto di fine è la fine della QueryString
	if (indEnd==-1) indEnd=QS.length; 
	// Ottengo il solore valore del parametro, ripulito dalle sequenze di escape
	var valore = unescape(QS.substring(indSta+ParamName.length+1,indEnd)); 
	// Restituisco il valore associato al parametro 'ParamName'
	return valore; 
}
function OnChangeMacroAreaMerc()
{
	if ( getObj( "MacroAreaMerc" ).value == '' )
	{
		DisableObj( 'Modelli_di_acquisto' , true );	
	}
	else
	{
		DisableObj( 'Modelli_di_acquisto' , false );
		try{filtraDominiModelli_di_acquisto();}catch(e){}
	}
}


function filtraDominiModelli_di_acquisto()
{
	var filtro = '';
	var Ambito =  getObj( "MacroAreaMerc" ).value; 
	var Modelli_di_acquisto_button= GetProperty(getObj('Modelli_di_acquisto_button'),'onclick');
	
	var old_filter=getQSParamFromString(Modelli_di_acquisto_button,'Filter', true);
	//aggiungo questo filtro dinamicamente in sostituzione a quello sul modello
	filtro =  'SQL_WHERE= DMV_Father  <> \'1\' and DMV_Cod in ( select codice  from View_Modelli_Lotti where Complex=0 and Monolotto=0 and Ambito = ' + Ambito + '  )';
	filtro= escape(filtro);
	Modelli_di_acquisto_button = Modelli_di_acquisto_button.replace('Filter='+old_filter,'Filter=' + filtro);
	SetProperty(getObj('Modelli_di_acquisto_button'),'onclick',Modelli_di_acquisto_button);	

}

function Onload_Process() 
{
	//Filtro i domini di quantità e prezzo rispetto agli attributi scelti nella griglia	
	//try{filtraDominiPrz_qty();}catch(e){}
	if( getObjValue(   'StatoFunzionale' ) == 'InLavorazione' || getObjValue(   'StatoFunzionale' ) == 'In Modifica' ) 
    {
		try
		{
			//filtro il dominio dei Modelli di Acquisto
			if ( getObj( "MacroAreaMerc" ).value == '' )
			{
				DisableObj( 'Modelli_di_acquisto' , true );
			}
			else
			{
				DisableObj( 'Modelli_di_acquisto' , false );
				try{filtraDominiModelli_di_acquisto();}catch(e){}
			}
		}
		catch(e)
		{
		}
	}

   
	var Command=getQSParam('COMMAND');
	var Process_Param=getQSParam('PROCESS_PARAM');
	var nocache = new Date().getTime();
	
	ajax = GetXMLHttpRequest();

	if (Command == 'PROCESS' && Process_Param == 'SEND:-1:CHECKOBBLIG,CONFIG_MODELLI_FABBISOGNI')
	{
		
		/* 
		
		***	LA REFRESH DEL MULTILINGUISMO NON DEVE PIU' ESSERE FATTA DOPO L'INTRODUZIONE DELLA CTL_MULTILINGUISMO ***
		
		var	cod = getObj( "IDDOC" ).value;
		var Stored='SP_RECUPERO_KEY_MLG';
		var param='IDDOC='+cod+'&'+'STORED='+Stored;
		
	    ajax.open("GET",   '../../ctl_library/functions/Update_Key_Multilinguismo.asp?' + param + '&nocache=' + nocache , false);
		ajax.send(null);
		
		if(ajax.readyState == 4) 
		{
			if(ajax.status == 404 || ajax.status == 500)
			{
				alert('Errore invocazione Refresh Multilinguismo.');
			}
		}
		
		*/
		
		ajax.open("GET",   '../../ctl_library/REFRESH.ASP?COSA=MODEL&nocache=' + nocache , false);
		ajax.send(null);
		
		if(ajax.readyState == 4) 
		{
			if(ajax.status == 404 || ajax.status == 500)
			{
			  alert('Errore invocazione Refresh Modelli.');
			}
		}
		
		try
		{
			//ricarico la sezione PRODOTTI del documento chiamante. La matrice in memoria della griglia deve essere aggiornata rispetto alle modifiche effettuate
			ExecDocCommandInMem(  'PRODOTTI#RELOAD', getObjValue('LinkedDoc') , getObjValue('VersioneLinkedDoc'));
		}
		catch(e)
		{}
	}
	
	
	try{getObj('Titolo').onkeyup=OnKeyUpTitolo;}catch(e){}
	
	ControlloDescrizione();
	
	if ( getObj('LinkedDoc').value != '0' && getObj('LinkedDoc').value != '' )
	{
	//nascondo la colonna presenza Obbligatoria per i modelli custom 
	ShowCol( 'MODELLI' , 'Presenza_Obbligatoria' , 'none' );
	//funzione per rendere la riga non modificabile se presenza_obbligatoria=1 (si)
	Riga_not_edit();
	}
	

	
}

function move( field , row , verso ) 
{
    try
    {
        var f1 = getObj( 'RMODELLIGrid_' + row + '_' + field );
        var f2 = getObj( 'RMODELLIGrid_' + ( row + verso ) + '_' + field ) ;
        var app;
        app = f1.value;
        f1.value = f2.value;
        f2.value = app
    
    }catch(e){}

}

function ClickDown( grid , r , c )
{

    move( 'DZT_Name' , r  , 1 );
    move( 'Descrizione' , r  , 1 );	
	move( 'Fabb_Richiesta' , r  , 1 );
	move( 'Fabb_Questionario' , r  , 1 );
	move( 'Fabb_Operazioni' , r  , 1 );	 
	move( 'Presenza_Obbligatoria' , r  , 1 );
	move( 'Numero_Decimali' , r  , 1 );
	move( 'NumeroDec' , r  , 1 );
	
	ControlloDescrizioneafterupdown();
	
	Riga_not_edit();

}


function ClickUp( grid , r , c )
{
	move( 'DZT_Name' , r  , -1 );
    move( 'Descrizione' , r  , -1 );
	move( 'Fabb_Richiesta' , r  , -1 );
	move( 'Fabb_Questionario' , r  , -1 );
	move( 'Fabb_Operazioni' , r  , -1 );	
	move( 'Presenza_Obbligatoria' , r  , -1 );
	move( 'Numero_Decimali' , r  , -1 );
	move( 'NumeroDec' , r  , -1 );
	ControlloDescrizioneafterupdown();
	Riga_not_edit();
}


function OnKeyUpTitolo()
{

	try
    {
		//recupero il titolo
		var titolo=this.value;
		var test;
		var titoloripulito='';

		//toglie gli spazi
		titolo=titolo.split(' ').join('');
		
		//ciclo per togliere i caratteri non validi solo numeri e lettere e _
		for(var i=0;i<titolo.length;i++)
		{
			test=titolo.charAt(i);
			if ( test.match("[a-zA-Z_]+") ) 
			{
				titoloripulito=titoloripulito+test;
			}
		}		
		//alert(titoloripulito);
		this.value=titoloripulito;
		
	}catch(e){}
	
}



function OnChangeAttributo(obj)
{
	var i = obj.id.split('_');
	var row =  i[1];
	var param;
	var nocache = new Date().getTime();
	
	//filtraDominiPrz_qty();
	
	param='ID='+ obj.value;
	    
	ajax.open("GET",   '../../customDoc/CONFIG_MODELLI_LOTTI.asp?' + param + '&nocache=' + nocache , false);
	ajax.send(null);
	if(ajax.readyState == 4) 
	{
		
		if(ajax.status == 404 || ajax.status == 500)
		{
		  alert('Errore invocazione pagina');
		  
		}
		var ainfo = ajax.responseText.split('#@#');
		var editabile = ainfo[0]; 	
		var NumeroDec = ainfo[1]; 	
		
		if ( editabile != 'EDITABLE' ) 
		{
			 getObj('RMODELLIGrid_' + row + '_NonEditabili').value='fissa';
			 TextreadOnly( 'RMODELLIGrid_' + row + '_Descrizione' , true );
			 getObj('RMODELLIGrid_' + row + '_Descrizione').value=editabile;
			 getObj('RMODELLIGrid_' + row + '_NumeroDec').value=NumeroDec;
			if( NumeroDec == 0 )
			{
				getObj('RMODELLIGrid_' + row + '_Numero_Decimali').value='';
			}
			 
		}
		else
		{
			TextreadOnly( 'RMODELLIGrid_' + row + '_Descrizione' , false );
			getObj('RMODELLIGrid_' + row + '_Descrizione').value='';
			getObj('RMODELLIGrid_' + row + '_NonEditabili').value='';
			getObj('RMODELLIGrid_' + row + '_NumeroDec').value=NumeroDec;
			if( NumeroDec == 0 )
			{
				getObj('RMODELLIGrid_' + row + '_Numero_Decimali').value='';
			}
		}
	}
	
	try
	{
		//Se ho selezionato un attributo di tipo Domain Ext o Gerarchico visualizzo accando alla combo attributo un icona che permette all'utente di aprire il dominio
		//E consultarne in sola lettura i valori in esso contenuti
		
		viewHelpDominio(obj);
		
	}
	catch(e)
	{
	}
	try
	{
		hideNumeroDecimali(row);
	}
	catch(e)
	{
	}
	
}


function ControlloDescrizioneafterupdown()
{	
	try 
	{

		 var numrow = GetProperty( getObj('MODELLIGrid') , 'numrow');
		 for( k = 0 ; k <= numrow ; k++ )
		 {
			
			
			
			
			var i = getObj('RMODELLIGrid_' + k +'_DZT_Name').id.split('_');
			var row =  i[1];
			var param;
			param='ID=' + getObj('RMODELLIGrid_' + k +'_DZT_Name').value;
			var nocache = new Date().getTime();
			
			ajax.open("GET",   '../../customDoc/CONFIG_MODELLI_LOTTI.asp?' + param + '&nocache=' + nocache , false);
			ajax.send(null);
			
			//console.log('../../customDoc/CONFIG_MODELLI_LOTTI.asp?' + param + '&nocache=' + nocache);
			
			if(ajax.readyState == 4) 
			{
			
				if(ajax.status == 404 || ajax.status == 500)
				{
				  alert('Errore invocazione pagina');				  
				}
					
				var ainfo = ajax.responseText.split('#@#');
				var editabile = ainfo[0]; 	
				var NumeroDec = ainfo[1]; 		
				//console.log(ajax.responseText);				
				//alert(ajax.responseText);  
				if ( editabile != 'EDITABLE' ) 
				{					 
					 //getObj('RMODELLIGrid_' + row + '_Descrizione').readOnly=true;
					 getObj('RMODELLIGrid_' + row + '_NonEditabili').value='fissa';	
					 TextreadOnly( 'RMODELLIGrid_' + row + '_Descrizione' , true );
					 getObj('RMODELLIGrid_' + row + '_Descrizione').value=editabile;	
					getObj('RMODELLIGrid_' + row + '_NumeroDec').value=NumeroDec;					 
				}
				else
				{
					//getObj('RMODELLIGrid_' + row + '_Descrizione').value='';
					//getObj('RMODELLIGrid_' + row + '_Descrizione').readOnly=false;				
					TextreadOnly( 'RMODELLIGrid_' + row + '_Descrizione' , false );
					getObj('RMODELLIGrid_' + row + '_NonEditabili').value='';	
					//getObj('RMODELLIGrid_' + row + '_Descrizione').value='';
					getObj('RMODELLIGrid_' + row + '_NumeroDec').value=NumeroDec;
				}
			}
			
			
			try{hideNumeroDecimali(k);}catch(e){}
			
		 
		 }
		 
	}catch( e ) { };
	
	
}

function ControlloDescrizione()
{
	try 
	{
		 var numrow = GetProperty( getObj('MODELLIGrid') , 'numrow');

		 for( i = 0 ; i <= numrow ; i++ )
		 {

			
			try
			{
				hideNumeroDecimali(i);
			}
			catch(e)
			{
			}
			
			
			try
			{
				viewHelpDominio( getObj('RMODELLIGrid_' + i + '_DZT_Name') );
			}
			catch(e)
			{
			}

			if( getObj('RMODELLIGrid_' + i + '_NonEditabili').value == 'fissa' )
			{
			     //getObj('RMODELLIGrid_' + i + '_Descrizione').readOnly=true;					
				 TextreadOnly( 'RMODELLIGrid_' + i + '_Descrizione' , true );
				
			}
			if( getObj('RMODELLIGrid_' + i + '_NonEditabili').value != 'fissa' )
			{
			     //getObj('RMODELLIGrid_' + i + '_Descrizione').readOnly=true;					
				 TextreadOnly( 'RMODELLIGrid_' + i + '_Descrizione' , false );
				
			}
		 
		 }
		 
	}catch( e ) { };
	

}

function MODELLI_AFTER_COMMAND ()
{
	ControlloDescrizione();
	
	if ( getObj('LinkedDoc').value != '0' && getObj('LinkedDoc').value != '' )
	{
	//nascondo la colonna presenza Obbligatoria per i modelli custom 
	ShowCol( 'MODELLI' , 'Presenza_Obbligatoria' , 'none' );
	//funzione per rendere la riga non modificabile se presenza_obbligatoria=1 (si)
	Riga_not_edit();
	}
  
	
}

function viewHelpDominio(obj)
{
	var arr = obj.id.split('_');
	var row =  arr[1];

	var selezione = obj.value;
	var typeAttrib = -1;

	if ( obj.options[obj.selectedIndex].text.substring(0, 12) == 'Domain Ext -' || obj.options[obj.selectedIndex].text.substring(0, 8) == 'Domain -' )
		typeAttrib = 8;

	if ( obj.options[obj.selectedIndex].text.substring(0, 12) == 'Gerarchico -' )
		typeAttrib = 5;

	if ( typeAttrib == -1 )
	{
		removeNode('help_dom_' + row);
	}
	else
	{
		var nomeAttributo = obj.value.replace('RMODELLIGrid_' + row + '_DZT_Name_','');
		
		var span = document.createElement("span");
		var link = document.createElement("a");
		var img = document.createElement("img");
		
		img.setAttribute("alt", 'img_label_alt');
		img.setAttribute("class", 'Apri dettaglio');
		img.setAttribute("src", pathRoot + 'CTL_Library/images/Domain/Lente.gif');

		var urlHelp = pathRoot + 'CTL_LIBRARY/dztToDom.asp?DZT=' + encodeURIComponent(nomeAttributo);

		span.setAttribute("id", "help_dom_" + row);
		link.setAttribute("href", '#');
		link.setAttribute("onclick", 'ExecFunctionCenter(\'' + urlHelp + '#new#800,600\');return false;');
		
		removeNode('help_dom_' + row);
		
		link.appendChild(img);
		span.appendChild(link);
		
		getObj('val_RMODELLIGrid_' + row + '_DZT_Name').appendChild(span); 

	}
	
}

function removeNode(id)
{
	try
	{
		//Se c'era l'help lo tolgo
		var objHelp = getObj(id);
		objHelp.parentNode.removeChild(objHelp);
	}
	catch(e)
	{
	}
}

function Riga_not_edit()
{

try 
	{
	if ( getObj('LinkedDoc').value != '0' && getObj('LinkedDoc').value != '' )
	{	

		 var numrow = GetProperty( getObj('MODELLIGrid') , 'numrow');

		 for( k = 0 ; k <= numrow ; k++ )
		 {
			//se richiesta la non editable la riga allora imposto il campo non editabili
			if( getObj('RMODELLIGrid_' + k +'_Presenza_Obbligatoria').value =='1')
			{
				try{SelectreadOnly( 'RMODELLIGrid_' + k + '_DZT_Name' , true );}catch(e){}
				try{TextreadOnly( 'RMODELLIGrid_' + k + '_Descrizione' , true );}catch(e){}				
				try{SelectreadOnly( 'RMODELLIGrid_' + k + '_Fabb_Richiesta' , true );}catch(e){}
				try{SelectreadOnly( 'RMODELLIGrid_' + k + '_Fabb_Questionario' , true );}catch(e){} 
				try{SelectreadOnly( 'RMODELLIGrid_' + k + '_Fabb_Operazioni' , true );}catch(e){}
				//try{SelectreadOnly( 'RMODELLIGrid_' + k + '_Numero_Decimali' , true );}catch(e){}
				//rimuovo il cestino se non modificabile
				try{getObj( 'MODELLIGrid_r' + k + '_c0' ).innerHTML = ReplaceExtended(getObj( 'MODELLIGrid_r' + k + '_c0' ).innerHTML,'DettagliDel(','DettagliDel_OLD(');}catch(e){}
				
			}
			else
			{
				try{SelectreadOnly( 'RMODELLIGrid_' + k + '_DZT_Name' , false );}catch(e){}
				if( getObj('RMODELLIGrid_' + k + '_NonEditabili').value == 'fissa' )
				{				
					 TextreadOnly( 'RMODELLIGrid_' + k + '_Descrizione' , true );
				}
				else
				{
					try{TextreadOnly( 'RMODELLIGrid_' + k + '_Descrizione' , false );}catch(e){}
				}
				try{SelectreadOnly( 'RMODELLIGrid_' + k + '_Fabb_Richiesta' , false );}catch(e){}
				try{SelectreadOnly( 'RMODELLIGrid_' + k + '_Fabb_Questionario' , false );}catch(e){} 
				try{SelectreadOnly( 'RMODELLIGrid_' + k + '_Fabb_Operazioni' , false );}catch(e){}
				try{SelectreadOnly( 'RMODELLIGrid_' + k + '_Numero_Decimali' , false );}catch(e){}
				try{getObj( 'MODELLIGrid_r' + k + '_c0' ).innerHTML = ReplaceExtended(getObj( 'MODELLIGrid_r' + k + '_c0' ).innerHTML,'DettagliDel_OLD(','DettagliDel(');}catch(e){}
	
			}
		 
		 }
	}
	}catch(e){}
}

function DettagliDel_OLD( grid , r , c )
{
	DMessageBox( '../' , 'Operazione non consentita' , 'Attenzione' , 1 , 400 , 300 );
	return;
}


function hideNumeroDecimali(riga)
{
	var num = Number(getObj('RMODELLIGrid_' + riga +'_NumeroDec').value);
	var NumeroDecimali = getObj('RMODELLIGrid_' + riga +'_Numero_Decimali');

	if (num == 0 )
	{
		NumeroDecimali.style.display = 'none';
	}
	else
	{
		NumeroDecimali.style.display = '';

	}
	
	
}
