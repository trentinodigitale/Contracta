window.onload = Onload_Process;

function GetXMLHttpRequest() 
{
	var	XHR = null,
		browserUtente = navigator.userAgent.toUpperCase();

	if(typeof(XMLHttpRequest) === "function" || typeof(XMLHttpRequest) === "object")
		XHR = new XMLHttpRequest();
		else if(window.ActiveXObject && browserUtente.indexOf("MSIE 4") < 0) {
			if(browserUtente.indexOf("MSIE 5") < 0)
				XHR = new ActiveXObject("Msxml2.XMLHTTP");
			else
				XHR = new ActiveXObject("Microsoft.XMLHTTP");
		}
		return XHR;
};

ajax = GetXMLHttpRequest();   

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

function Onload_Process () 
{
	
	var DOCUMENT_READONLY = '0';	
	try
	{
		if ( typeof InToPrintDocument !== 'undefined' )
		{
			DOCUMENT_READONLY='1';
		}
		else
		{
			DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
		}	
	}
	catch(e)
	{
	}

	
 	var Command=getQSParam('COMMAND');
	var Process_Param=getQSParam('PROCESS_PARAM');

	if (Command == 'PROCESS' && Process_Param == 'SEND:-1:CHECKOBBLIG,CONFIG_MODELLI_MERC_ADDITIONAL_INFO')
	{
		var nocache = new Date().getTime();
		var	cod = getObj( "IDDOC" ).value;
		
		ajax.open("GET",   '../../ctl_library/REFRESH.ASP?COSA=MODEL&nocache=' + nocache , false);
		ajax.send(null);

		if(ajax.readyState == 4) 
		{
			if(ajax.status != 200)
			{
				alert('Ripetere l\'operazione. Errore invocazione Refresh Modelli.Status ' + ajax.status);
			}
		}
		else
		{
			alert('Errore chiamata a Refresh Modelli. Ripetere l\'operazione');
		}
		
		
	}

	/*
	try
	{
		CALCOLI_AFTER_COMMAND();
	}
	catch(e)
	{
	}
	*/
	
	getObj('Titolo').onkeyup=OnKeyUpTitolo;

	if (Command == 'PRINT')
	{
		ControlloDescrizionePrint()
	}
	else
	{
		ControlloDescrizione();
	}

	
	if ( getObj( 'livelloBloccato' ) )
	{
		var livelloBloccato = getObjValue( 'livelloBloccato' );
		
		if( livelloBloccato != '-1' )
		{
			var filter = 'SQL_WHERE= dmv_cod in ( select dmv_cod from ClasseIscriz where dmv_level <= ' + livelloBloccato + ' )';
			SetProperty( getObj('ClasseIscriz'),'filter', filter);
			SetProperty( getObj('ClasseIscriz'),'strformat', 'J'); // non permetto la selezione di tutti nodi ma solo delle foglie
		}
	}



	//attivazione meccanismo DRAG&DROP sulla griglia degli ATTI
	if (DOCUMENT_READONLY == '0' ) 
	{			
		ActiveDrag();	
		
	}else
	{
		HideColDrag();
	}
			
}

function ActiveDrag ()
{	
	ActiveGridDrag (  'MODELLIGrid' , MoveAllRow );
	ActiveGridDrag (  'CALCOLIGrid' , MoveAllRowCalcolo );
}

function HideColDrag ()
{	
	ShowCol( 'MODELLI' , 'FNZ_DRAG' , 'none' );	
	ShowCol( 'CALCOLI' , 'FNZ_DRAG' , 'none' );	
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

    }
	catch(e)
	{
	}
	
	
    try
    {
        var f1 = getObj( 'RMODELLIGrid_' + row + '_' + field + '_edit');
        var f2 = getObj( 'RMODELLIGrid_' + ( row + verso ) + '_' + field + '_edit') ;
        var app;

        app = f1.value;

        f1.value = f2.value;
  
        f2.value = app

    }
	catch(e)
	{
	}	
	
    try
    {
        var f1 = getObj( 'RMODELLIGrid_' + row + '_' + field + '_edit_new');
        var f2 = getObj( 'RMODELLIGrid_' + ( row + verso ) + '_' + field + '_edit_new') ;
        var app;

        app = f1.value;

        f1.value = f2.value;
  
        f2.value = app

    }
	catch(e)
	{
	}	
	
	try
	{
        var f1 = getObj( 'RMODELLIGrid_' + row + '_' + field + '_extraAttrib');
        var f2 = getObj( 'RMODELLIGrid_' + ( row + verso ) + '_' + field + '_extraAttrib') ;
        var app;

        app = f1.value;

        f1.value = f2.value;
  
        f2.value = app

    }
	catch(e)
	{
	}	
		
	try
    {
		
		var onclickFunction = 'openExtDomPopup(\'##ID##\',\'./LoadExtendedAttrib.asp?MultiValue=1&titoloFinestra=Dominio&TypeAttrib=8&IdDomain=##Dominio##&Attrib=RMODELLIGrid%5F##row##%5FDZT%5FFiltro&Format=JAM&Editable=True&Suffix=&Filter=\', \'dialog-iframe-sino\');'
		
        var f1 = getObj('RMODELLIGrid_' + row + '_' + field + '_button');
		var id1 = 'RMODELLIGrid_' + row + '_' + field + ''
		var d1 = getObj('RMODELLIGrid_' + row + '_PresenzaDominio').value;
		
        var f2 = getObj('RMODELLIGrid_' + ( row + verso ) + '_' + field + '_button') ;
		var id2 = 'RMODELLIGrid_' + ( row + verso ) + '_' + field + ''
		var d2 = getObj('RMODELLIGrid_' + ( row + verso ) + '_PresenzaDominio').value;
		
        var app1 = onclickFunction.replace('##ID##', id1).replace('##Dominio##', d1).replace('##row##', row);
		var app2 = onclickFunction.replace('##ID##', id2).replace('##Dominio##', d2).replace('##row##', row + verso);
		
		var tmp; 
		
		f1.setAttribute("onclick", app1);
		
		f2.setAttribute("onclick", app2);
    }
	catch(e)
	{
	}		
	
	try
	{
        var f1 = getObj( 'val_RMODELLIGrid_' + row + '_' + field + '_extraAttrib');
        var f2 = getObj( 'val_RMODELLIGrid_' + ( row + verso ) + '_' + field + '_extraAttrib') ;
        var app;

        app = f1.value;

        f1.value = f2.value;
  
        f2.value = app

    }
	catch(e)
	{
	}	
}

function moveCalcoli( field , row , verso ) 
{
    try
    {
        var f1 = getObj( 'RCALCOLIGrid_' + row + '_' + field );
        var f2 = getObj( 'RCALCOLIGrid_' + ( row + verso ) + '_' + field ) ;
        var app;
        app = f1.value;
        f1.value = f2.value;
        f2.value = app
    }catch(e){}

}

//-- sposta per una riga tutti gli attributi nel verso indicato
function MoveAllRow( r , v)
{
	
	move( 'DZT_Name' , r  , v );
	move( 'Descrizione' , r  , v );
	move( 'TipoFile' , r  , v );
	move( 'MOD_Modello' , r  , v );
	move( 'NonEditabili' , r  , v );
	move( 'Numero_Decimali' , r  , v );
	move( 'NumeroDec' , r  , v );
	move( 'TOOLTIP_ORDER' , r  , v );
	move( 'Obbligatorio', r, v);
	move( 'FNZ_DEL', r, v);
	move( 'PresenzaDominio', r, v);
	move( 'DZT_Filtro', r, v);
	move( 'Elemento_Dominio', r, v);
		
	ControlloDescrizione();

	//ControlloDescrizioneafterupdown(); --> non va bene fare N chiamate ajax al server ogni volta che facciamo uno spostamento di riga
	Riga_not_edit();
}

function MoveAllRowCalcolo(r , v)
{
	moveCalcoli( 'EsitoRiga' , r  , v );
	moveCalcoli( 'Descrizione' , r  , v );
	moveCalcoli( 'DZT_Name' , r  , v );
	moveCalcoli( 'MOD_PDA' , r  ,v );
	moveCalcoli( 'PDADrillTestata' , r  , v );
	moveCalcoli( 'MOD_PDADrillLista' , r  , v );
	moveCalcoli( 'NonEditabili' , r  , v );
	moveCalcoli( 'Formula' , r  , v );
	moveCalcoli( 'Aggregazione' , r  , v );
}

function ClickDown( grid , r , c )
{

	if ( grid == 'MODELLIGrid' )
	{
		MoveAllRow( r , 1);
		/*
		move( 'DZT_Name' , r  , 1 );
		move( 'Descrizione' , r  , 1 );
		move( 'TipoFile' , r  , 1 );
		move( 'MOD_Modello' , r  , 1 );
		move( 'NonEditabili' , r  , 1 );
		move( 'Numero_Decimali' , r  , 1 );
		move( 'NumeroDec' , r  , 1 );
		move( 'TOOLTIP_ORDER' , r  , 1 );
		
		
		ControlloDescrizione();
		//ControlloDescrizioneafterupdown(); --> non va bene fare N chiamate ajax al server ogni volta che facciamo uno spostamento di riga
		Riga_not_edit();
		*/
	}
	else if ( grid == 'CALCOLIGrid' )
	{
		MoveAllRowCalcolo(r, 1);
		// moveCalcoli( 'EsitoRiga' , r  , 1 );
		// moveCalcoli( 'Descrizione' , r  , 1 );
		// moveCalcoli( 'DZT_Name' , r  , 1 );
		// moveCalcoli( 'MOD_PDA' , r  , 1 );
		// moveCalcoli( 'PDADrillTestata' , r  , 1 );
		// moveCalcoli( 'MOD_PDADrillLista' , r  , 1 );
		// moveCalcoli( 'NonEditabili' , r  , 1 );
		// moveCalcoli( 'Formula' , r  , 1 );
		// moveCalcoli( 'Aggregazione' , r  , 1 );
	}

}

function ClickUp( grid , r , c )
{
	if ( grid == 'MODELLIGrid' )
	{
		MoveAllRow( r , -1 );
	/*
		move( 'DZT_Name' , r  , -1 );
		move( 'Descrizione' , r  , -1 );
		move( 'TipoFile' , r  , -1 );
		move( 'MOD_Modello' , r  , -1 );
		move( 'NonEditabili' , r  , -1 );
		move( 'Numero_Decimali' , r  , -1 );
		move( 'NumeroDec' , r  , -1 );
		move( 'TOOLTIP_ORDER' , r  , -1 );

		ControlloDescrizione();
		//ControlloDescrizioneafterupdown(); --> non va bene fare N chiamate ajax al server ogni volta che facciamo uno spostamento di riga
		Riga_not_edit();
	*/
	
	
	}
	else if ( grid == 'CALCOLIGrid' )
	{
		MoveAllRowControlli(r, -1);
		// moveCalcoli( 'EsitoRiga' , r  , -1 );
		// moveCalcoli( 'Descrizione' , r  , -1 );
		// moveCalcoli( 'DZT_Name' , r  , -1 );
		// moveCalcoli( 'MOD_PDA' , r  , -1 );
		// moveCalcoli( 'PDADrillTestata' , r  , -1 );
		// moveCalcoli( 'MOD_PDADrillLista' , r  , -1 );
		// moveCalcoli( 'NonEditabili' , r  , -1 );
		// moveCalcoli( 'Formula' , r  , -1 );
		// moveCalcoli( 'Aggregazione' , r  , -1 );
	}
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

function CALCOLI_AFTER_COMMAND ()
{
	var numrow = GetProperty( getObj('CALCOLIGrid') , 'numrow');

	for( i = 0 ; i <= numrow ; i++ )
	{
		getObj('RCALCOLIGrid_' + i + '_Formula').onchange=OnChangeFormula;
	}
}

function OnChangeAttributo(obj)
{
	var i = obj.id.split('_');
	var row =  i[1];
	var param;
	var nocache = new Date().getTime();

	try
	{
		hideTipoFile(row);
	}
	catch(e)
	{
	}

	param='ID='+ obj.value;

	ajax.open("GET",   '../../customDoc/CONFIG_MODELLI_LOTTI.asp?' + param + '&nocache=' + nocache, false);
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
		
		var Dominio = ainfo[2]; 
		getObj('RMODELLIGrid_' + row + '_PresenzaDominio').value = Dominio
		
		
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
			getObj('RMODELLIGrid_' + row + '_NonEditabili').value='';
			TextreadOnly( 'RMODELLIGrid_' + row + '_Descrizione' , false );
			getObj('RMODELLIGrid_' + row + '_Descrizione').value='';
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
		
		viewHelpDominio(obj, Dominio);
		
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

			try
			{
				hideTipoFile(k);
			}
			catch(e)
			{
			}

			var i = getObj('RMODELLIGrid_' + k +'_DZT_Name').id.split('_');
			var row =  i[1];
			var param;
			var nocache = new Date().getTime();

			param='ID=' + getObj('RMODELLIGrid_' + k +'_DZT_Name').value;

			ajax.open("GET",   '../../customDoc/CONFIG_MODELLI_LOTTI.asp?' + param + '&nocache=' + nocache, false);
			ajax.send(null);

			if(ajax.readyState == 4) 
			{

				if(ajax.status != 200)
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
				}
				else
				{	
					TextreadOnly( 'RMODELLIGrid_' + row + '_Descrizione' , false );
					getObj('RMODELLIGrid_' + row + '_NumeroDec').value=NumeroDec;	
				}
			}
			
			try{hideNumeroDecimali(k);}catch(e){}

		 }
		 
	}catch( e ) { };
	
	//ControlloDescrizione();

}

function ControlloDescrizione()
{	
	try 
	{
		 var statoDocumento = getObj('val_StatoFunzionale').innerHTML;
		 var numrow = GetProperty( getObj('MODELLIGrid') , 'numrow');
		 for( i = 0 ; i <= numrow ; i++ )
		 {

			try
			{
				hideTipoFile(i);
			}
			catch(e)
			{
			}
			
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
			else
			{
				TextreadOnly( 'RMODELLIGrid_' + i + '_Descrizione' ,false);
			}
		 
			if(getObj('RMODELLIGrid_' + i + '_Obbligatorio').value == 1)
			{	
				if (statoDocumento != "Pubblicato")
				{
					document.getElementById('RMODELLIGrid_' + i + '_FNZ_DEL').style.display = 'none';	
				}
							
				TextreadOnly( 'RMODELLIGrid_' + i + '_Descrizione' , true );					
				document.getElementById('RMODELLIGrid_' + i + '_DZT_Name').disabled = true;

				var attributo = getObj('val_RMODELLIGrid_' + i + '_DZT_Name_extraAttrib').value
				var attDescrizione = attributo.replace('value#=#', "")
				if (attDescrizione == "Descrizione" || attDescrizione == "PREZZO_OFFERTO_PER_UM")
				{
					document.getElementById('RMODELLIGrid_' + i + '_MOD_Modello').disabled = true;	
				}
				else
				{
					document.getElementById('RMODELLIGrid_' + i + '_MOD_Modello').disabled = false;	
				}
				
			}
			else
			{
				if (statoDocumento != "Pubblicato")
				{
					document.getElementById('RMODELLIGrid_' + i + '_FNZ_DEL').style.display = '';
				}
				
				TextreadOnly( 'RMODELLIGrid_' + i + '_Descrizione' , false );									
				document.getElementById('RMODELLIGrid_' + i + '_DZT_Name').disabled = false;
				document.getElementById('RMODELLIGrid_' + i + '_MOD_Modello').disabled = false;	
									
			}
			
			try
			{
				var elementoDominio = getObj('RMODELLIGrid_' + i + '_Elemento_Dominio').value
				var numeroSelezionati = elementoDominio.split('###').length - 2;
				
				if (elementoDominio != "")
				{
					getObj('RMODELLIGrid_' + i + '_DZT_Filtro').value = elementoDominio
					if (statoDocumento == "Pubblicato")
					{
						
						getObj('RMODELLIGrid_' + i + '_DZT_Filtro_edit').value = numeroSelezionati + ' Selezionati'			
						getObj('RMODELLIGrid_' + i + '_DZT_Filtro_label').innerHTML = numeroSelezionati + ' Selezionati'		 
					}
					else
					{
						getObj('RMODELLIGrid_' + i + '_DZT_Filtro_edit_new').value = numeroSelezionati + ' Selezionati'		
					}
						
						console.log('ok');					
				}
			}
			catch{}
		
		 }
		 
	}catch( e ) { };
	
}

function ControlloDescrizionePrint()
{
	var numrow = GetProperty( getObj('MODELLIGrid') , 'numrow');
	for( i = 0 ; i <= numrow ; i++ )
	{
		var Dominio = document.getElementById('RMODELLIGrid_' + i + '_PresenzaDominio').value;
		var ElementoDominio = document.getElementById('RMODELLIGrid_' + i + '_Elemento_Dominio').value;
		
		if (Dominio != "" && ElementoDominio != "")
		{
			
			ajax = GetXMLHttpRequest(); 
			if(ajax)
			{
				var nocache = new Date().getTime();	
				// var strParam = 'Dominio='+ encodeURIComponent(Dominio) +'&ElemDominio=' + encodeURIComponent(ElementoDominio);			
				 var strUrlOperation = '../functions/FIELD/Get_Desc_Dom.asp?Dominio='+ encodeURIComponent(Dominio) +'&ElemDominio='+ encodeURIComponent(ElementoDominio) +'&nocache=' + nocache;
				
				ajax.open("GET", strUrlOperation, false);
				
				ajax.send(null);
				
				if(ajax.readyState == 4) 
				{
					if(ajax.status == 200)
					{
						result =  ajax.responseText;
						if (result != '')
						{   
							var table_dom = document.getElementById('MODELLIGrid_r' + i + '_c5')
							table_dom.innerHTML = result
						}					
					}
				}
			}
		}
		
	}
}


function MODELLI_AFTER_COMMAND ()
{
	ControlloDescrizione();
	
	try
	{
		Onload_Process();
	}
	catch(e){}
}

function OnChangeAttributoCalcolo( obj )
{
	
}

function OnChangeFormula()
{
	var obj = this;
	var riga =  obj.id.replace('RCALCOLIGrid_','').replace('_Formula','');
	CheckFormula( '', riga , '');
}

function CheckFormula( G , R , C )
{
	var docReadonly = getObjValue('DOCUMENT_READONLY');
	
	if ( docReadonly != '1' )
	{
		var strFormula = getObj('RCALCOLIGrid_' + R + '_Formula').value;
		var esito = verificaFormula( strFormula, 'no' );
		
		getObj('RCALCOLIGrid_' + R + '_EsitoRiga_V').innerHTML = esito;

		if ( esito == '' )
		{
			alert('La formula e\' valida');
		}
		
	}
}

function ROUND( v , d )
{
	return 1.0
}

function verificaFormula( strFormula, output )
{
	var esitoFormula = '';
	var imgEsito = '<img src="../images/Domain/State_ERR.gif"/>';
	var continueCheck = true;
	
	try 
	{
	
		if ( strFormula != '')
		{
			 var numrow = GetProperty( getObj('MODELLIGrid') , 'numrow');
			 
			 for( k = 0 ; k <= numrow ; k++ )
			 {

				var campo = getObj('RMODELLIGrid_' + k +'_DZT_Name');

				var indexSel = campo.selectedIndex;
				var lista = campo.options;
				var valueCampo = campo.value;
				var testoSelezionato = lista[indexSel].text;

				if (testoSelezionato.substring(0, 8) == 'Number -')
				{
					var descSelezionato = getObj('RMODELLIGrid_' + k + '_Descrizione').value;
					
					try
					{
						//alert(descSelezionato);
						//strFormula = strFormula.replace('[' + descSelezionato + ']', '1');	
						strFormula = ReplaceExtended(strFormula, '[' + descSelezionato + ']', '1');	
					}
					catch(e){}

				}

			 }
			 
			 try
			 {
				/* Se nella formula sono ancora presenti delle parentesi quadre vuol dire che sono stati utilizzati attributi non numerici */
				if ( strFormula.indexOf('[') >= 0 || strFormula.indexOf(']') >= 0 )
				{
					if ( output != 'no' )
					{
						alert('La formula non e\' sintatticamente corretta');
					}
					else
					{
						esitoFormula = esitoFormula + imgEsito + 'La formula contiene attributi non numerici' + '<br/>';
					}

					continueCheck = false;

				}

			 }
			 catch(e)
			 {
			 }
			 
			 
			var t = document.getElementById('DZT_Name');
			var selectedText = t.options[t.selectedIndex].text;
			if ( getObjValue('Formula').indexOf(selectedText) >= 0 )
			{
				alert('In una formula non deve comparire l\'attributo utilizzato come risultato calcolato');
				esitoFormula = esitoFormula + imgEsito + 'In una formula non deve comparire l\'attributo utilizzato come risultato calcolato' + '<br/>';
				continueCheck = false;
				
			}
			
			 

			if ( continueCheck )
			{

				try
				{
					//alert(strFormula);
					var a = eval(strFormula);

					if ( output != 'no' )
					{
						alert('La formula e\' sintatticamente corretta');
					}

				}
				catch(e)
				{
					if ( output != 'no' )
					{
						alert('La formula non e\' formalmente valida');
					}
					else
					{
						esitoFormula = esitoFormula + imgEsito + 'La formula non e\' sintatticamente corretta' + '<br/>';
					}
				}
				
			}

		}
		else
		{
			if ( output != 'no' )
			{
				alert('La formula non \' sintatticamente corretta');
			}
			else
			{
				esitoFormula = esitoFormula + imgEsito + 'La formula non e\' sintatticamente corretta' + '<br/>';
			}
		}

	}
	catch( e )
	{
	}
	
	
	return esitoFormula;
	
}

function openWinModale( page , height, width )
{
  
  var pathRadice;
  
  if ( isSingleWin() )
    pathRadice = pathRoot;
  else
    pathRadice = '../../';

	if (height == undefined) 
	{
		height = 650;
	}
	
	if (width == undefined) 
	{
		width = 800;
	}

	try
	{
		$(function() 
		{
			$( "#finestra_modale" ).load(pathRadice + page).dialog({
			  resizable: true,
			  height:height,
			  width:width,
			  modal: true,
			  buttons: {
				"OK": function()
					{
						var rowCalcolo = getObj('riga_wizard_formula').value;
						
						/* Travaso i dati dalla modale al documento */
						getObj( 'RCALCOLIGrid_' + rowCalcolo + '_Formula' ).value = getObj('Formula').value;
						getObj( 'RCALCOLIGrid_' + rowCalcolo + '_Descrizione' ).value = getObj('Descrizione').value;
						getObj( 'RCALCOLIGrid_' + rowCalcolo + '_DZT_Name' ).value = getObj('DZT_Name').value;

						$( this ).dialog( "close" );
					}
				,"Verifica formula": function() 
					{
						verificaFormula( getObj('Formula').value );
					}
				,"Annulla": function() 
					{
						$( this ).dialog( "close" );
					}
				}
			});
		});
	}
	catch(e)
	{
	 
	}
}

function openWizardFormula( G , R , C )
{
	var docReadonly = getObjValue('DOCUMENT_READONLY');

	if ( docReadonly != '1' )
	{
		openWinModale( 'ctl_library/functions/FIELD/wizardFormula.asp?riga=' + R);
	}
}

function hideTipoFile(riga)
{
	var docReadonly = getObjValue('DOCUMENT_READONLY');
	var campo;
	var txtTipoFileRiga;
	var btnTipoFileRiga;
	var indexSel;
	var lista;
	var testoSelezionato;
	
	if ( docReadonly != '1' )
	{
		campo = getObj('RMODELLIGrid_' + riga +'_DZT_Name');

		indexSel = campo.selectedIndex;
		lista = campo.options;
		testoSelezionato = lista[indexSel].text;
	}
	else
	{
		testoSelezionato = getObj('val_RMODELLIGrid_' + riga +'_DZT_Name').innerHTML;
	}
	
	txtTipoFileRiga = getObj('RMODELLIGrid_' + riga +'_TipoFile_edit_new');
	btnTipoFileRiga = getObj('RMODELLIGrid_' + riga +'_TipoFile_button');
	
	if (testoSelezionato.substring(0, 8) != 'Attach -')
	{
		txtTipoFileRiga.style.display = 'none';
		btnTipoFileRiga.style.display = 'none';
		document.getElementById('RMODELLIGrid_' + riga + '_TOOLTIP_ORDER').style.display = '';   
		//SetDomValue('RMODELLIGrid_' + riga + '_TipoFile','','');//se non è un allegato settiamo i tipifile a vuoto
	}
	else
	{		
		txtTipoFileRiga.style.display = '';		
		btnTipoFileRiga.style.display = '';	
		document.getElementById('RMODELLIGrid_' + riga + '_TOOLTIP_ORDER').style.display = 'none';
		
	}	
	
}

function viewHelpDominio(obj)
{
	var statoDocumento = getObj('val_StatoFunzionale').innerHTML;
	
	var arr = obj.id.split('_');
	var row =  arr[1];

	var selezione = obj.value;
	var typeAttrib = -1;
	
	var txtAttRiga = getObj('RMODELLIGrid_' + row +'_DZT_Filtro_edit_new');
	var btnAttRiga = getObj('RMODELLIGrid_' + row +'_DZT_Filtro_button');
	
	var Editable;
	
	if (statoDocumento == 'Pubblicato')
	{
		var objprov = getObj('val_RMODELLIGrid_' + row +'_DZT_Name').innerHTML;
		if (objprov.substring(0, 12) == 'Gerarchico -'){
			typeAttrib = 5;
		}else{
			typeAttrib = 8;
		}
		
		Editable = "False"
	}
	else
	{
		if ( obj.options[obj.selectedIndex].text.substring(0, 12) == 'Domain Ext -' || obj.options[obj.selectedIndex].text.substring(0, 8) == 'Domain -' )
			typeAttrib = 8;

		if ( obj.options[obj.selectedIndex].text.substring(0, 12) == 'Gerarchico -' )
			typeAttrib = 5;
		
		Editable = "True"
	}
	
	
	//provvisorio
	// try{
		// if ( obj.options[obj.selectedIndex].text.substring(0, 12) == 'Domain Ext -' || obj.options[obj.selectedIndex].text.substring(0, 8) == 'Domain -' )
			// typeAttrib = 8;

		// if ( obj.options[obj.selectedIndex].text.substring(0, 12) == 'Gerarchico -' )
			// typeAttrib = 5;

	// }catch{
		// var objprov = getObj('val_RMODELLIGrid_' + row +'_DZT_Name').innerHTML;
		// if (objprov.substring(0, 12) == 'Gerarchico -'){
			// typeAttrib = 5;
		// }else{
			// typeAttrib = 8;
		// }
	// }
	
	if ( typeAttrib == -1 )
	{
		//removeNode('help_dom_' + row);
		txtAttRiga.style.display = 'none';
		btnAttRiga.style.display = 'none';
	}
	else
	{
		var nomeAttributo = 'IdDomain=' + getObj('RMODELLIGrid_' + row + '_PresenzaDominio').value;
		
		try
		{
			txtAttRiga.style.display = '';		
			btnAttRiga.style.display = '';
		}	
		catch{}
							
		var onclickFunction = 'openExtDomPopup(\'##ID##\',\'./LoadExtendedAttrib.asp?MultiValue=1&titoloFinestra=Dominio&TypeAttrib=##Tipo##&##Dominio##&Attrib=RMODELLIGrid%5F##row##%5FDZT%5FFiltro&Format=JAM&Editable=##Editable##&Suffix=&Filter=\', \'dialog-iframe-sino\');'
		var id = 'RMODELLIGrid_' + row + '_DZT_Filtro'		
		var onclickElemReplace = onclickFunction.replace('##ID##', id).replace('##Dominio##', nomeAttributo).replace('##row##', row).replace('##Tipo##', typeAttrib).replace('##Editable##', Editable);
		btnAttRiga.setAttribute("onclick", onclickElemReplace);
	
		//var onclickElem = document.getElementById('RMODELLIGrid_' + row +'_DZT_Filtro_button').getAttribute('onclick');
		//var onclickElemReplace = onclickElem.replace("IdDomain=sino", nomeAttributo);
	
		//btnAttRiga.onclick.value = onclickElemReplace
		
		 // var span = document.createElement("span");
		 // var link = document.createElement("a");
		 // var img = document.createElement("img");
		
		 // img.setAttribute("alt", 'img_label_alt');
		 // img.setAttribute("class", 'Apri dettaglio');
		 // img.setAttribute("src", pathRoot + 'CTL_Library/images/Domain/Lente.gif');

		 // var urlHelp = pathRoot + 'CTL_LIBRARY/dztToDom.asp?DZT=' + encodeURIComponent(nomeAttributo);

		 // span.setAttribute("id", "help_dom_" + row);
		 // link.setAttribute("href", '#');
		 // link.setAttribute("onclick", 'ExecFunctionCenter(\'' + urlHelp + '#new#800,600\');return false;');
		
		 // removeNode('help_dom_' + row);
		
		 // link.appendChild(img);
		 // span.appendChild(link);
		
		 // getObj('val_RMODELLIGrid_' + row + '_DZT_Name').appendChild(span); 

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

function onChangeDescAttrib(obj)
{
	try
	{
		//Applico una trim sulla descrizione dell'attributo
		obj.value = obj.value.trim();
		//tolgo i doppi spazi e ne lascio sempre uno
		obj.value = ReplaceExtended (obj.value, '  ',' ');
	}
	catch(e)
	{
	}
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

function Riga_not_edit()
{
}

function MySaveDoc()
{
	SetDisableColumn()
	SaveDoc();
}

function MyPublicDoc(param){
	
	SetDisableColumn()
	ExecDocProcess(param);
}

function SetDisableColumn()
{
	var numrow = GetProperty( getObj('MODELLIGrid') , 'numrow');
	 for( i = 0 ; i <= numrow ; i++ )
	 {
		 document.getElementById('RMODELLIGrid_' + i + '_DZT_Name').disabled = false;
		 document.getElementById('RMODELLIGrid_' + i + '_MOD_Modello').disabled = false;	
		 document.getElementById('RMODELLIGrid_' + i + '_TOOLTIP_ORDER').disabled = false;
	 }	 
}

function onChangeDominio(obj)
{
	var arr = obj.id.split('_');
	var row =  arr[1];
	
	var FileValue = getObj('RMODELLIGrid_' + row + '_DZT_Filtro').value
	getObj('RMODELLIGrid_' + row + '_Elemento_Dominio').value = FileValue
}

function MyExecDocCommand(param)
{
	SetDisableColumn()
	ExecDocCommand(param)
}



