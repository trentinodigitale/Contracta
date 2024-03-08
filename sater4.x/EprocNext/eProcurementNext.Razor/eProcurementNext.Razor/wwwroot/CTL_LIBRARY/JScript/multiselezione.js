//var selectedDiTreeSelezionati = new Array(); //Array dei nodi selezionati dall'albero dei nodi scelti
//var selectedDiTree = new Array();			//Array dei nodi selezionati dall'albero principale

var readonly = '0';

function chiama_onLoad(albero, selezionati)
{

	try
	{
		document.getElementById('tree').style.display = 'block';
		//Tolgo la div per far vedere il caricamento in corso
		$('#loading').fadeOut(500);
		document.getElementById("selezionati").style.pointerEvents = "auto";
	}
	catch(e) {}
	
	
	
	document.getElementById('text-cerca').value = '';

	var value = document.getElementById('value').value;
	var multiSel = document.getElementById('multivalue').value;
	var editable = document.getElementById('editable').value;
	var isLazy = 'false';
	
	var lazyInit = 'NO';
	var objLazyInit = document.getElementById('lazy_init');
	
	if ( objLazyInit )
		lazyInit = objLazyInit.value;
	
	try
	{
		isLazy = document.getElementById('lazy').value;
	}catch(e)
	{
	}
	
	var txtRicerca = getQueryStringParam('ricerca');
	readonly = getQueryStringParam('readonly');
	
	/* Se è attiva la modalità lazy nascondo l'area di ricerca */
	if ( isLazy == 'true' ) 
	{
	
		/* 	SE E' ATTIVO IL GERARCHICO LAZY CAMBIO LA FUNZIONE DI RICERCA, DA QUELLA CLIENT A QUELLA SERVER	*/
		
		var tmpJS = "searchEXT();";
		var newclick = new Function(tmpJS);
		$("#cerca-button").attr('onclick', '').click(newclick);

	}
	
	if (!(value === undefined) && value != '')
	{
		if ( isLazy == 'true' )
		{
			$('#selezionati').dynatree({
								checkbox: true
								,onDblClick: function(node, event) { removeToSelezionati(node,'selezionati'); }
								,initAjax: { 
										type: 'POST',
										url  : '../ctl_library/GetDomValue.asp',
										data : { 
												'DESC': document.getElementById('text-cerca').value,
												'GET_DESCS' : 'YES',
												'VALUES' : document.getElementById('value').value,
												'dominio': document.getElementById('id_domain').value,
												'mode': 'all',
												'filter': document.getElementById('filter').value,
												'SEARCH_EXT': 'YES'
											  },
										cache: false ,
										dataType: 'json'
						           }
							});
							
			$("#selezionati").dynatree("getTree").reload();							
			
		}
		else
		{
		
			if (multiSel == "1" && editable != 'False' )
			{
				var lista = value.split('###');
				var key;
				
				for (var i=0,len=lista.length; i<len; i++)
				{ 
					key  = lista[i];
					
					if ( key != '')
					{
					
						if ( $('#tree').dynatree("getTree").getNodeByKey(key)  !== null)
						{
							addToSelezionati( $('#tree').dynatree("getTree").getNodeByKey(key), selezionati);
						}
					}
				}
			}
			else
			{
				if ( $('#tree').dynatree("getTree").getNodeByKey(value)  !== null )
				{
					$('#tree').dynatree("getTree").getNodeByKey(value).activate();
				}
			}
			
		}
	}
	
	if (readonly == '1')
	{
	
		//Faccio i bottoni 'svuota' ed 'elimina' 
		$(".div_pulsanti_finestra").hide();

	}
	
	if (editable == 'False')
	{
		//Per il div padre con classe main.div su tutti i figli con tag INPUT applico l'attributo disabled
		$(".main-div :input").attr("disabled", true);
		
		$("#tree").dynatree("disable");
		$("#tree-find").dynatree("disable");
		$("#selezionati").dynatree("disable");
		
		//Faccio i bottoni 'svuota' ed 'elimina' 
		$("#button_elimina").hide();
		$("#button_svuota").hide();

		if ( document.getElementById('tree_div_sx') )
			document.getElementById('tree_div_sx').style.display = 'none';
		
		if ( document.getElementById('tree_div_dx') )
			document.getElementById('tree_div_dx').style.width='98%';
		
	}
	else
	{
		
		if ( lazyInit == 'NO' )
		{
			/* Se è stata richiesta una ricerca da avviare all'apertura della finestra in automatico */
			if (!(txtRicerca === undefined) && txtRicerca != '')
			{
				document.getElementById('text-cerca').value = txtRicerca;
				search();
			}
		}
		else
		{
			recursiveLazyInit('1', document.getElementById('id_domain').value, document.getElementById('format').value, null);
		}

	}
	
	
	

	
}

function selezionaNodo( nodo, destinazione,flag )
{
	//alert(nodo);
	
	if ( readonly == '1'  )
		return;
	
	if (flag)
		addToSelezionati( nodo, destinazione );
	else
		removeToSelezionati( nodo, destinazione );
	
}

function callBackOnActivate( nodo )
{
	var incrementale = document.getElementById('incrementale').value;
	
	if ( incrementale == 'SI' )
	{
		//alert('testfede:' + unescape(nodo.data.title));
		document.getElementById('text-incrementale').value = htmlDecode(nodo.data.title);
	}
}

function htmlEncode(value){
    if (value) {
        return jQuery('<div />').text(value).html();
    } else {
        return '';
    }
}
 
function htmlDecode(value) {
    if (value) {
        return $('<div />').html(value).text();
    } else {
        return '';
    }
}


function selezionaNodoDaSelezionati( nodo, destinazione,flag )
{
	/* Metodo invocato alla selezione di un elemento dall'albero degli elementi selezionati
	if (flag)
		addToCollection( selectedDiTreeSelezionati, nodo );
	else
		DelToCollection( selectedDiTreeSelezionati, nodo );
	*/
}

function addToCollection( collezione, nodo )
{
	/* Funzione per aggiungere a un array associativo js una chiave */

	var key;
	var value;
	
	if (nodo instanceof DynaTreeNode)
	{
		key = nodo.data.key;
		value = nodo.data.key;
	}
	else
	{
		//Il parametro nodo è proprio la chiave.
		key = nodo;
		value = nodo;
	}
	
	if(collezione.contains(key))
	{
		collezione[key] = value;
	}
	else
	{
		collezione.push(key);
		collezione[key] = value;
	}
}

function DelToCollection( collezione, nodo )
{
	/* Funzione per rimuovere da un array associativo js una chiave */
	
	var key;
	var value;
	
	if (nodo instanceof DynaTreeNode)
	{
		key = nodo.data.key;
		value = nodo.data.key;
	}
	else
	{
		//Il parametro nodo è proprio la chiave.
		key = nodo;
		value = nodo;
	}
	
	if(collezione.contains(key))
	{
		delete collezione[key];
	}

}

function addToSelezionati(nodo, destinazione)
{
	/* aggiunge un nodo dall'albero dei selezionati */
	
	if ( readonly == '1'  )
		return;

	var multiSel = document.getElementById('multivalue').value;
	var isLazy = 'false';
	
	try
	{
		isLazy = document.getElementById('lazy').value;
	}catch(e)
	{
	}

	//Se il nodo è selezionabile
	//if ( isLazy == 'true' || $('#tree').dynatree("getTree").getNodeByKey(nodo.data.key).data.unselectable == false)
	if ( nodo.data.unselectable == false )
	{
	
		if ( multiSel == "1")
		{
			try
			{
				$('#tree').dynatree("getTree").getNodeByKey(nodo.data.key).select(true);
			}
			catch(e){}
		}
		else
		{
			
			var incrementale = document.getElementById('incrementale').value;
			
			callBackOnActivate( nodo );
			
			//Se è una selezione singola.. al doppio click diamo una conferma della selezione
			conferma();
		}

	
		//Impedisco duplicati
		if (!$("#" + destinazione).dynatree("getTree").getNodeByKey(nodo.data.key))
		{
		
			var rootNode = $("#" + destinazione).dynatree("getRoot");
			
			var childNode = rootNode.addChild({
				title: nodo.data.title,
				key: nodo.data.key,
				isFolder: false
			 });
			 
		}
	}
	else
	{
		try
		{
			//Se il nodo non è selezionabile provo ad aprirlo
			nodo.toggleExpand();
		}
		catch(e)
		{
		}
	}
}

function addToTree(nodo, destinazione)
{
	/* aggiunge un nodo dall'albero dei selezionati */

	var multivalue = document.getElementById('multivalue').value;

	//Se il nodo è selezionabile oppure l'albero non prevede checkbox
	if ( multivalue != 1 || $('#tree').dynatree("getTree").getNodeByKey(nodo.data.key).data.unselectable == false)
	{	
		
		var strFormat = '';
		try
		{
			strFormat = document.getElementById('format').value;
		}catch(e) { strFormat = ''; }
		//Impedisco duplicati lo consento se ci sta la format Y che mostra anche i cancellati, in quel caso si rischia di non mostrare valori presenti nel dominio kpf 435928 
		if (!$("#" + destinazione).dynatree("getTree").getNodeByKey(nodo.data.key) || (strFormat.indexOf('Y') !== -1) )
		{
		
			var rootNode = $("#" + destinazione).dynatree("getRoot");
			
			var childNode = rootNode.addChild({
				title: nodo.data.title,
				key: nodo.data.key,
				isFolder: false
			 });
			 
			 if (nodo.isSelected() && multivalue == "1")
			 {
				childNode.select(true);
			 }
			 
		}
	}
	else
	{

	}
}

function removeToSelezionati(nodo, destinazione)
{
	/* rimuove un nodo dall'albero dei selezionati */

	var nod = $("#" + destinazione).dynatree("getTree").getNodeByKey(nodo.data.key);
	
	try
	{	
		$('#tree').dynatree("getTree").getNodeByKey(nodo.data.key).select(false);
	}
	catch(e)
	{
	}
	
	/*
	DelToCollection( selectedDiTreeSelezionati, nod );
	DelToCollection( selectedDiTree, nod );
	*/
	
	try
	{
		nod.remove();
	}
	catch(e) {}

}

function clickDel(tree)
{
	var key;
	var nod;
	
	var selezionati = $("#" + tree).dynatree("getTree").getSelectedNodes();
	
	for (var i = 0; i < selezionati.length; i++)
	{
		nod = selezionati[i];

		removeToSelezionati( nod, tree);
	}

}

function clickClear(tree)
{
	var key;
	var nod;
	
	var selezionati = $("#tree").dynatree("getTree").getSelectedNodes();
	
	for (var i = 0; i < selezionati.length; i++)
	{
		nod = selezionati[i];
		removeToSelezionati( nod, tree);
	}
	
	//mi assicuro di cancellare tutti i nodi dell'albero
	try
	{
		$("#" + tree).dynatree("getRoot").removeChildren();
	}
	catch(e){}
}

function clickAdd(tree)
{
}

function keyPressOnTree(node, e)
{

	// Se ha fatto 'invio' o 'barra spaziatrice' (con firefox il codice della barraspaziatrice è 0 perchè non è supportato)
    if (e.keyCode == 13 || e.keyCode == 32) 
	{
		if (node.isSelected())
			node.select(false);
		else
			node.select(true);
    }

}

function search(e)
{
	var isLazy = 'false';
	var nTrovato = 0;
	
	
	var arearicerca = document.getElementById('area-ricerca');
	var objEsito = document.getElementById('msg_esito');
	
	//se non esiste creo div per messaggio di esito non ci sono elementi
	if ( objEsito == undefined)
	{	
		var div_esito = document.createElement("div");                 // Create a <div> element
		div_esito.id = 'msg_esito';
		div_esito.className  = 'p-esito';
		document.getElementById("area-ricerca").appendChild(div_esito);
		objEsito = document.getElementById('msg_esito');		
	}
	//svuoto il div di esito
	objEsito.innerHTML = "";
	
	
	try
	{
		isLazy = document.getElementById('lazy').value;
	}catch(e)
	{
	}
	
	/* Se è attiva la modalità lazy faccio utilizzare la ricerca estesa server */
	if ( isLazy == 'true' ) 
	{
		return searchEXT(e);
	}
	
	var destinazione = 'tree-find';
	var cerca = document.getElementById('text-cerca').value;

	if (e == undefined || e.keyCode == 13) 
	{
		if (cerca !== '')
		{

			try
			{
				$("#" + destinazione).dynatree("getRoot").removeChildren();
			}
			catch(e){}
			
			$("#" + destinazione).show();
			$("#tree").hide();
			
	
			$("#tree").dynatree("getRoot").visit(function(node)
			{
				//node.expand(true);
				try
				{
					//Se il nodo ha il title ed è tra i nodi selezionabili (quindi non mostro quelli non-selezionabili)
					if (node.data.title != undefined && node.data.unselectable == false )
					{
						var title = node.data.title.toUpperCase();

						if (title.indexOf(cerca.toUpperCase()) !== -1)
						{
							addToTree( node, destinazione);
							nTrovato = 1 ;
						}
					}
				}
				catch(e) 
				{
					alert(e.message);
				}
			}, true  );
			
			if ( nTrovato == 0 )
			{
				objEsito.innerHTML = msgEsito_Vuoto;                // Insert text
				
			}
		}
		else
		{
			$("#" + destinazione).hide();
			$("#tree").show();
		}
	
	}
	
}

function evidenzia(e)
{
	var cerca = document.getElementById('text-incrementale').value;

	if (e !== undefined) 
	{
		$("#tree-find").hide();
		$("#tree").show();
		
		//Rendo inattivo un eventuale nodo selezionato o uno reso attivo da una precedente scrittura nella text incrementale
		annullaSelezione(true);

	
		if (cerca !== '')
		{

			$("#tree").dynatree("getRoot").visit(function(node)
			{

				try
				{
					if (node.data.title != undefined)
					{
						var title = node.data.title.toUpperCase();
					
						if (title.indexOf(cerca.toUpperCase()) === 0)
						{
							//TROVATO
							//node.activate();
							node.activateSilently() //Come activate() ma non fa eseguire la funzione sull'evento sull'onActivate
							node.focus();
							document.getElementById('text-incrementale').focus();
							return false;
						}
					}
				}
				catch(e) 
				{
					//alert(e.message);
				}
			}, true  );
		}

	
	}
}


function getSelectedItemes()
{
	var listValue = "";
	var multivalue = document.getElementById('multivalue').value;
	var editable = document.getElementById('editable').value;
	var incrementale = document.getElementById('incrementale').value;
	
	if (editable == 'False')
	{
		return "";
	}
	else
	{
		if ( incrementale == 'NO' )
		{
			if ( multivalue == "1")
			{

				$("#selezionati").dynatree("getRoot").visit(function(node)
				{
					try
					{
						listValue = listValue + node.data.key + "###";
					
					}
					catch(e) 
					{
						alert(e.message);
					}
				}, false  );
				
				if ( listValue == '' )
					return "";
				else
					return "###" + listValue;

			}
			else
			{
				try
				{
					var nodo;
					
					if ( $("#tree").is(":visible") ) 
						nodo = $("#tree").dynatree("getActiveNode");
					else
						nodo = $("#tree-find").dynatree("getActiveNode");
					
					if( nodo )
					{
						if ( nodo.data.unselectable == false )
							listValue = nodo.data.key;
						else
							alert('Nodo scelto non selezionabile');
					}
					else
					{
						//alert('Nessun nodo selezionato');
					}
				
				}
				catch(e)
				{
					alert('Errore nella selezione a valore singolo: ' + e.message);
				}
				
				return listValue;
			}
		}
		else
		{
			return document.getElementById('text-incrementale').value.toUpperCase();
		}

	}
	
}

function old_getSelectedItemesHTML()
{
	var listValue = "";
	var multivalue = document.getElementById('multivalue').value;
	
	if ( multivalue == "1")
	{
		$("#selezionati").dynatree("getRoot").visit(function(node)
		{
			try
			{
				listValue = listValue + '<option value="' + node.data.key + '">' + node.data.title + '</option>\n';
			
			}
			catch(e) 
			{
				alert(e.message);
			}
		}, false  );

	}
	else
	{
		try
		{
			var nodo = $("#tree").dynatree("getActiveNode");
			listValue = '<option value="' + nodo.data.key + '">' + nodo.data.title + '</option>\n'
		}
		catch(e)
		{
		}
	}	
	
	if (listValue == "")
	{
		listValue = '<option value="">-- Effettuare una selezione --</option>\n'
	}
	
	return listValue;
}

function getSelectedItemesHTML()
{
	var listValue = "0 Selezionati";
	var multivalue = document.getElementById('multivalue').value;
	var editable = document.getElementById('editable').value;
	var incrementale = document.getElementById('incrementale').value;
	
 	if (editable == 'False')
	{
		return "";
	}
	else
	{

		if ( incrementale == 'NO' )
		{

			if ( multivalue == "1")
			{
				var totSel = $("#selezionati").dynatree("getTree").count();
				
				if (totSel == 0)
					return listValue;
				
				if (totSel == 1)
				{
						$("#selezionati").dynatree("getRoot").visit(function(node)
						{
							try
							{
								listValue = node.data.title;
							
							}
							catch(e) 
							{
								alert(e.message);
							}
						}, false  );

					//listValue = $("#selezionati").dynatree("getRoot").data.title;
				}
				else
				{
					var strFormat = '';
					try
					{
						strFormat = document.getElementById('format').value;
					}catch(e) { strFormat = ''; }
					
					//Se è presente la format ad L, cioè che vuole la lista dei valori e non 'N selezionati'
					if (strFormat.indexOf('L') !== -1)
					{
						listValue = '';
						
						$("#selezionati").dynatree("getRoot").visit(function(node)
						{
							try
							{
								listValue = listValue + node.data.title + ";";
							}
							catch(e) 
							{

							}
						}, false  );

					}
					else
					{
						listValue = totSel + " Selezionati";
					}
					
					
				}

			}
			else
			{
				try
				{
					var nodo;
					
					if ( $("#tree").is(":visible") ) 
						nodo = $("#tree").dynatree("getActiveNode");
					else
						nodo = $("#tree-find").dynatree("getActiveNode");
					
					if( nodo )
					{
						if ( nodo.data.unselectable == false )
							listValue = nodo.data.title;
						else
							listValue = "";
							//alert('Nodo scelto non selezionabile');
							
					}
					else
					{
						listValue = "";
						//alert('Nessun nodo selezionato');
					}
				
				}
				catch(e)
				{
					alert('Errore nella selezione a valore singolo: ' + e.message);
				}
			}
		}
		else
		{
			return document.getElementById('text-incrementale').value.toUpperCase();
		}		
	
	}
	
	return listValue;
}

function isEditable()
{
	var editable = document.getElementById('editable').value;
	
	if (editable == 'False' || readonly == '1')
		return 0;
	else
		return 1;

}

function annullaSelezione(notClear)
{
	var incrementale = document.getElementById('incrementale').value;
	
	if ( $("#tree").dynatree("getActiveNode") ) 
	{
		$("#tree").dynatree("getActiveNode").deactivate();
	}

	if ( $("#tree-find").dynatree("getActiveNode") ) 
	{
		$("#tree-find").dynatree("getActiveNode").deactivate();
	}
	
	if ( notClear !== true)
	{
		if (incrementale == 'SI')
			document.getElementById('text-incrementale').value = '';
	}
}

function svuota_chiudi()
{
	var multivalue = document.getElementById('multivalue').value;
	
	if ( multivalue == "1")
	{
		try
		{
			clickClear('selezionati'); //Per la selezione multipla
		} catch(e) {}
	}
	else
	{
		try
		{
			annullaSelezione(false); //Per la selezione singola
		} catch(e) {}	
	}

	conferma(); //Chiude la finestra

}

function conferma()
{
	try {
		if (window.parent.isFaseII) {
			confermaFaseII();
			window.parent.closeDrawer();
			return;
		}
	} catch {

	}
	//Se il field è editabile
	if ( isEditable() == 1 )
	{
		var nomeCampo = document.getElementById('nome_campo').value;

		var val = getSelectedItemes();
		var desc = getSelectedItemesHTML();
		var oldVal = window.opener.document.getElementById(nomeCampo).value;
		
		window.opener.document.getElementById(nomeCampo).value = val;
		
		var typeAttrib = '';
		
		try
		{
			typeAttrib = getQueryStringParam('TypeAttrib');
		}
		catch(e)
		{
		}
		
		if ( oldVal != val )
		{
			try
			{
				window.opener.document.getElementById(nomeCampo + '_edit').value = desc;
				//Faccio fare l'onchange al chiamante
				//window.opener.document.getElementById(nomeCampo + '_edit').onchange();
			}
			catch(e) 
			{
			}
			
			try
			{
				//Mettiamo come ultimo valore valido del dominio questo appena scelto (nell'array oldvaluedomainExt)
				window.opener.window.oldValueDomainExt[nomeCampo]=val;
			}
			catch(e){}
			
			//Se c'è stato un cambio di valori faccio scattare l'evento onchange
			try
			{
				//Se è un dominio chiuso con format a M faccio qui l'onChange sul campo hidden.
				if ( typeAttrib == '4')
				{
					window.opener.document.getElementById(nomeCampo).onchange();
				}
				//window.opener.document.getElementById(nomeCampo).onchange();
				//$("#" + nomeCampo).change();
			}
			catch(e)
			{
			}
			
			try
			{
				window.opener.document.getElementById(nomeCampo + '_edit_new').value = desc;
				//aggiorno il tooltip del campo visuale
				$( window.opener.document.getElementById(nomeCampo + '_edit_new') ).attr('title', LocReplaceExtended(desc,';','\n') );
				//$( window.opener.document.getElementById(nomeCampo + '_edit_new') ).attr('title', desc );
				
				
				window.opener.document.getElementById(nomeCampo + '_edit_new').style.color = 'black';
			}
			catch(e) {}
			
			try
			{
				window.opener.fireOnChangeAndClose( window.opener.document.getElementById(nomeCampo + '_edit'), nomeCampo );
			}
			catch(e)
			{
			
				if ( oldVal != val && typeAttrib != '4' )
				{
					try {
						window.opener.document.getElementById(nomeCampo + '_edit').onchange();
					} catch (e) {
						
					}
				}
			}
			
			
			
		}
		else
		{
			try
			{
				window.opener.document.getElementById(nomeCampo + '_edit_new').value = desc;
				window.opener.document.getElementById(nomeCampo + '_edit_new').style.color = 'black';
			}
			catch(e) {}
		}

		annulla();


	}
}

function confermaFaseII() {
	//Se il field è editabile
	if (isEditable() == 1) {
		var nomeCampo = document.getElementById('nome_campo').value;

		var val = getSelectedItemes();
		var desc = getSelectedItemesHTML();
		var oldVal = window.parent.document.getElementById(nomeCampo).value;

		window.parent.document.getElementById(nomeCampo).value = val;

		var typeAttrib = '';

		try {
			typeAttrib = getQueryStringParam('TypeAttrib');
		}
		catch (e) {
		}

		if (oldVal != val) {
			try {
				window.parent.document.getElementById(nomeCampo + '_edit').value = desc;
				//Faccio fare l'onchange al chiamante
				//window.opener.document.getElementById(nomeCampo + '_edit').onchange();
			}
			catch (e) {
			}

			try {
				//Mettiamo come ultimo valore valido del dominio questo appena scelto (nell'array oldvaluedomainExt)
				window.parent.window.oldValueDomainExt[nomeCampo] = val;
			}
			catch (e) { }

			//Se c'è stato un cambio di valori faccio scattare l'evento onchange
			try {
				//Se è un dominio chiuso con format a M faccio qui l'onChange sul campo hidden.
				if (typeAttrib == '4') {
					window.parent.document.getElementById(nomeCampo).onchange();
				}
				//window.opener.document.getElementById(nomeCampo).onchange()
				//$("#" + nomeCampo).change()
			}
			catch (e) {
			}

			try {
				window.parent.document.getElementById(nomeCampo + '_edit_new').value = desc;
				//aggiorno il tooltip del campo visuale
				$(window.parent.document.getElementById(nomeCampo + '_edit_new')).attr('title', LocReplaceExtended(desc, ';', '\n'));
				//$( window.opener.document.getElementById(nomeCampo + '_edit_new') ).attr('title', desc );
				window.parent.document.getElementById(nomeCampo + '_edit_new').style.color = 'black';
			}
			catch (e) { }

			try {
				window.parent.fireOnChangeAndClose(window.parent.document.getElementById(nomeCampo + '_edit'), nomeCampo);
			}
			catch (e) {

				if (oldVal != val && typeAttrib != '4') {
					window.parent.document.getElementById(nomeCampo + '_edit').onchange();
				}
			}



		}
		else {
			try {
				window.parent.document.getElementById(nomeCampo + '_edit_new').value = desc;
				window.parent.document.getElementById(nomeCampo + '_edit_new').style.color = 'black';
			}
			catch (e) { }
		}

		annulla();


	}
}

function annulla()
{
	
	try {
		if (window.parent.isFaseII) {
			window.parent.closeDrawer();
			return;
		}
	} catch {

	}

	try
	{
		window.close();
	}
	catch(e){}
}

function getQueryStringParam(ParamName) 
{

	// Memorizzo tutta la QueryString in una variabile
	QS=window.location.toString(); 
	// Posizione di inizio della variabile richiesta
	var indSta=QS.indexOf(ParamName); 
	// Se la variabile passata non esiste o il parametro è vuoto, restituisco null
	if (indSta==-1 || ParamName=="") return ''; 
	// Posizione finale, determinata da una eventuale &amp; che serve per concatenare più variabili
	var indEnd=QS.indexOf('&',indSta); 
	// Se non c'è una &amp;, il punto di fine è la fine della QueryString
	if (indEnd==-1) indEnd=QS.length; 
	// Ottengo il solore valore del parametro, ripulito dalle sequenze di escape
	var valore = unescape(QS.substring(indSta+ParamName.length+1,indEnd)); 
	// Restituisco il valore associato al parametro 'ParamName'
	return valore; 
  
}

function searchEXT(e)
{
	var destinazione = 'tree-find';
	var cerca = document.getElementById('text-cerca').value;

	if (e == undefined || e.keyCode == 13) 
	{
		if (cerca !== '')
		{

			try
			{
				$("#" + destinazione).dynatree("getRoot").removeChildren();
			}
			catch(e){}
			
			$("#" + destinazione).show();
			$("#tree").hide();
			
			//Se è stata richiesta la modalità 'lazy'
			

			var multiSel = document.getElementById('multivalue').value;
					
			if ( multiSel == '1' )
			{
				$("#tree-find").dynatree({
						checkbox: true,
						onDblClick: function(node, event) { addToSelezionati(node,'selezionati'); },
						onActivate: function(node, event) { callBackOnActivate(node); },
						onKeypress: function(node, event) { keyPressOnTree(node,event); },
						onSelect: function(flag, node) { selezionaNodo(node,'selezionati',flag); },
						initAjax: { 
												url  : '../ctl_library/GetDomValue.asp',
												data : { 
														'DESC': document.getElementById('text-cerca').value,
														'dominio': document.getElementById('id_domain').value,
														'mode': 'all',
														'filter': document.getElementById('filter').value,
														'format': document.getElementById('format').value,
														'SEARCH_EXT': 'YES'
													  },
												cache: false ,
												dataType: 'json'
										   },
					   onKeypress: function(node, event) { keyPressOnTree(node,event); },
					   onSelect: function(flag, node) { selezionaNodo(node,'selezionati',flag); } 
					});
			}
			else
			{
				$("#tree-find").dynatree({
									checkbox: false,
									onDblClick: function(node, event) { addToSelezionati(node,'selezionati'); },
									onActivate: function(node, event) { callBackOnActivate(node); },
									onKeypress: function(node, event) { keyPressOnTree(node,event); },
									onSelect: function(flag, node) { selezionaNodo(node,'selezionati',flag); } 
									
									,initAjax: { 
												url  : '../ctl_library/GetDomValue.asp',
												data : { 
														'DESC': document.getElementById('text-cerca').value,
														'dominio': document.getElementById('id_domain').value,
														'mode': 'all',
														'filter': document.getElementById('filter').value,
														'format': document.getElementById('format').value,
														'SEARCH_EXT': 'YES'
													  },
												cache: false ,
												dataType: 'json'
												}
						           
										});													  
				
			}
					
			//Il ricarico dell'albero di ricerca farà scattare la chiamata ajax
			$("#tree-find").dynatree("getTree").reload();


		}
		else
		{
			$("#" + destinazione).hide();
			$("#tree").show();
		}
	}
}

/*
	' OUTPUT JSON RESTITUITO
	'		{
	'			"percentage":10,		// numerico da 0 a 100
	'			"currentStatus":"OK",	// OK or ERROR
	'			"output":[
	'				{
	'					"key":"123",		//dmv_cod
	'					"desc":"elemento"	//Descrizione già composta secondo format
	'				},
	'				{"key":"456","desc":"elem2"},
	'				{"key":"789","desc":"elem3"}
	'			]
	'			,"error":{
	'				"description":null
	'			}
	'		}
	*/
function recursiveLazyInit(init, id_domain, format, result)
{
	
	var rootNode = $("#tree").dynatree("getRoot");
	
	if ( init == '1' || ( result && result.percentage < 100 ) )
	{
		var nocache = new Date().getTime();
		
		$.ajax({
			url: "getDomExtLazy.asp?INIT=" + init + "&DOMAIN=" + encodeURIComponent(id_domain) + "&FORMAT=" + encodeURIComponent(format) + "&nocache=" + nocache,
			contentType: "application/json",
			type: "GET",
			dataType: 'json',
			async:true,
			cache: false,
			success: function(ajaxRes)
			{
				if ( ajaxRes.currentStatus == 'OK' )
				{
					
					setTimeout(function(){  lazyLoading( 'Caricamento...', ajaxRes.percentage); }, 10 );
					
					//Aggiungiamo tutti gli elementi ritornati all'area di lavoro finale
					//ajaxRes.output.forEach(addLazyElemToArea);
					//COMMENTATO PER MANCANZA DI COMPATIBILITA' CON IE
					/*for (let lazyElem of ajaxRes.output)
					{
						rootNode.addChild({
								title: lazyElem.desc,
								key: lazyElem.key,
								isFolder: false
						 });
					}
					*/
					setTimeout(function(){  recursiveLazyInit('0', id_domain, format, ajaxRes); }, 10 );
					
				}
				else
					lazyLoadingError(ajaxRes.error.description);	
			},
			error: function(richiesta,stato,errori)
			{
				lazyLoadingError('Errore nel recupero dei dati. Stato: ' + stato + '; Errori: ' + errori);
			}
		})
	}
	else
		finalizeLazyInit();
}

function addLazyElemToArea(lazyElem)
{
	var rootNode = $("#tree").dynatree("getRoot");
	//console.log(lazyElem.desc);
	var childNode = rootNode.addChild({
			title: lazyElem.desc,
			key: lazyElem.key,
			isFolder: false
	 });	

	/*
	if ( !document.getElementById('tree_ul_main') )
	{
		document.getElementById('tree').innerHTML = '<ul id="tree_ul_main"></ul>';
	}
	//fare encode dei dati inseriti nell'html
	document.getElementById('tree_ul_main').innerHTML = document.getElementById('tree_ul_main').innerHTML + '<li id="' + lazyElem.key + '" title="' + lazyElem.desc + '" Data=" key: \'' + lazyElem.key + '\', unselectable:false ">' + lazyElem.desc;
	*/
}

function lazyLoading(caption, percentage)
{
	var strHtmlLoading = '';
	
	$('#lazy_loading').show();
	
	//strHtmlLoading = '<div class="af_loader_div"><span class="af_loader_caption">' + caption + '</span><br/><br/><div class="progress"><div class="progress-bar progress-bar-success active progress-bar-striped" role="progressbar" aria-valuenow="40" aria-valuemin="0" aria-valuemax="100" style="width:' + percentage + '%">' + percentage + '% Completata </div></div></div>';
	strHtmlLoading = '<div class="progress"><div class="progress-bar progress-bar-success active progress-bar-striped" role="progressbar" aria-valuenow="40" aria-valuemin="0" aria-valuemax="100" style="width:' + percentage + '%">' + percentage + '% Completata </div></div>';
	
	$('#lazy_loading').html(strHtmlLoading);

	
	
}

function lazyLoadingError(msgError)
{
	window.location = 'MessageBoxWin.asp?MSG=' + encodeURIComponent( msgError ) +'&CAPTION=Errore&ICO=';
}

function finalizeLazyInit()
{
	try
	{
		$('#lazy_loading').fadeOut(500);
	}
	catch(e) {}

	/*
	$('#tree').dynatree({
        imagePath: '../CTL_Library/images/Domain/'  
        ,onDblClick: function(node, event) { addToSelezionati(node,'selezionati'); }
		,OnClick: function(node, event) { callBackOnActivate(node); }
		,onKeypress: function(node, event) { keyPressOnTree(node,event); }
		,onSelect: function(flag, node) {
            selezionaNodo(node,'selezionati',flag);
        }, 
        onActivate: function(node) {
            callBackOnActivate(node);
        }
    });
	*/
	
	var txtRicerca = getQueryStringParam('ricerca');

	/* Se è stata richiesta una ricerca da avviare all'apertura della finestra in automatico */
	if (!(txtRicerca === undefined) && txtRicerca != '')
	{
		document.getElementById('text-cerca').value = txtRicerca;
		search();
	}

}

function LocReplaceExtended(strExpression,strFind,strReplace){

  while (strExpression.indexOf(strFind)>=0)
  	strExpression=strExpression.replace(strFind,strReplace);
		
  return strExpression;
}