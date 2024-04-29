/* Funzioni per la nuova gestione tramite modale */

var oldValueDomainExt=new Object();
var DomainExtInLoading=new Object();
var DomainExtInTab=new Object();
var DomainExtRefPopup=new Object();

function openExtDomPopup( nomeCampo, srcIframe, idDiv )
{
	//Funzione invocata all'evento onmousedown per far si che la funzione venga invocata
	//prima che il fuoco si sposti sul bottone
	
	/* Il parametro idDiv è composto da : 'dialog-iframe-" & Domain.Id & "' e quindi lo sfrutto
		per recuperare l'id del dominio togilendo la parte 'dialog-iframe-' */
	
	var nomeCampo_Appoggio = nomeCampo.toLowerCase() + '_appoggio';
	
	if ( ! getObj(nomeCampo_Appoggio) ){
		
		var newElement = document.createElement("input");
		newElement.style.display = 'none';
		newElement.type = 'text' ;
		newElement.name = nomeCampo_Appoggio ;
		newElement.id = nomeCampo_Appoggio ;
		newElement.value = nomeCampo;
		document.body.appendChild(newElement);
	}
	
	var value = document.getElementById(nomeCampo).value;
	var fieldVisual = document.getElementById(nomeCampo + '_edit_new');
	var descValue = '';
	var idBottone = '';
	var doc = SearchDocumentForExtendeAttrib();
	
	var strPath = '';
	
	var old_filter='';
	var newFilter = '';	
	
	if (typeof pathRoot != 'undefined')
	{
		strPath = pathRoot + 'CTL_LIBRARY/';
	}
	else
	{
		if ( doc == null )
			strPath = '/Application/CTL_LIBRARY/';
		else
			strPath = doc.strPathExtObj;
	}
	
	//var idDomain = idDiv.repalce('dialog-iframe-', '');
	
	//-- se è configurato il formato search apre un viewer
	var search = '';
	
	try { search = GetProperty(getObj( nomeCampo ),'search'); }catch( e ) {};
	
	if (fieldVisual)
		descValue = fieldVisual.value;

	//Recupero il parametro filter senza decodificarlo (terzo parametro a true)
	old_filter=getQSParamFromString(srcIframe,'Filter', true);
		
	if ( old_filter==null )
		old_filter='';
	
	newFilter = GetProperty(getObj(nomeCampo),'filter');
	
	if ( newFilter == null || newFilter == undefined )
		newFilter = '';		
	
	var dimensioni = '';
	
	if( search == '' )
	{
		
		srcIframe = srcIframe.replace('Filter='+old_filter,'Filter=' + encodeURIComponent(newFilter));
		
		//srcIframe = strPath + srcIframe + '&Value=' + encodeURIComponent(value);
		srcIframe = strPath + srcIframe;
		
		
		if (typeof pathRoot != 'undefined')
		{
			var oldPathImage = getQSParamFromString(srcIframe,'PathImage', true);
			var pathImage = pathRoot + 'CTL_Library/images/Domain/';
			
			srcIframe = srcIframe.replace('PathImage='+oldPathImage,'PathImage=' + encodeURIComponent(pathImage))		
		}		
		
		if (fieldVisual)
		{
			if (fieldVisual.style.color == 'red')
			{
				if (descValue != undefined && descValue != '')
					srcIframe = srcIframe + '&ricerca=' + encodeURIComponent(descValue);
			}
		}
	
		try
		{
			// Metto il focus sul bottone (sia se clicco sul bottone stesso o sulla text)
			idBottone = nomeCampo + '_button';
			//document.getElementById(idBottone).focus();
			//window.focus();
		}
		catch(e) {}
		
		dimensioni = 'height=690,width=800';
	
	}
	else
	{
		var FilterHide = GetProperty(getObj( nomeCampo ),'filter');

		srcIframe = strPath + 'functions/field/FldExtViewer.asp?Table=ExtendedDomain_' + search + '&IDENTITY=ID&TOOLBAR=&PATHTOOLBAR=../CTL_Library/&JSCRIPT=FldExtSelRow&Caption=ExtendedDomain_' + search + '&Height=130,100*,210';
		srcIframe = srcIframe + '&DOCUMENT=' + escape(  nomeCampo );
		//srcIframe = srcIframe + '&OWNER=idPfu';
		srcIframe = srcIframe + '&OWNER=';
		srcIframe = srcIframe + '&Filter=' + encodeURIComponent(newFilter);
		srcIframe = srcIframe + '&FilterHide=' + FilterHide;
		srcIframe = srcIframe + '&L_F=&Exit=si&AreaInfo=no&AreaFiltro=&AreaAdd=no&numRowForPag=25&Sort=DMV_DescML&FilteredOnly=yes';
		
		dimensioni = 'height=690,width=800';
	}

	if (typeof isFaseII !== 'undefined' && isFaseII) {

		closeDrawer();
		openDrawer(`<div class="iframeRightAreaContain">
						<iframe
							class="iframeRightArea"
							name='popUpFLDEXT'>
						</iframe>
					</div>`,
			false, "", "", true, true, true);

		generaFormValueAndSubmit(value, srcIframe, 'popUpFLDEXT');
		return;
	}


	
	//var res = window.open( srcIframe ,'popUpFLDEXT','toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=yes,scrollbars=yes,left=50,top=50,' + dimensioni);
	var res = window.open('about:blank' ,'popUpFLDEXT','toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=yes,scrollbars=yes,left=50,top=50,' + dimensioni);
	
	try
	{
		DomainExtRefPopup[nomeCampo] = res;
	}
	catch(e){}
	
	generaFormValueAndSubmit(value, srcIframe, 'popUpFLDEXT');
	
	var timer = setInterval(function(){try	{res.focus();clearTimeout(timer); }catch(e){}},500);

}

function fireOnChangeAndClose( FieldForOnChange, FieldForClose )
{
	
	try
	{
		DomainExtRefPopup[FieldForClose].close();
	}catch(e){}
	
	var tmpTimer = setInterval(function(){try	{clearTimeout(tmpTimer);FieldForOnChange.onchange(); }catch(e){}},100);
	
	try
	{
		//FieldForOnChange.onchange();
	}catch(e){}

}

function extDom_onChangeBase( nomeCampo, src, nomeDominio, filter )
{
	//return;
	
	var campoAvideo = document.getElementById(nomeCampo + '_edit_new');
	var DESC = campoAvideo.value;
		
	//Se il testo è cambiato rispetto al precedente faccio scattare la ricerca
	// (questo per intercettare anche un testo inserito con copia incolla tramite
	// il tasto destro del mouse)
	try
	{
		if ( oldValueDomainExt[nomeCampo].toUpperCase() !== DESC.toUpperCase() )
		{
			extDom_keyUp(nomeCampo,src,window.event,nomeDominio,filter)
		}
	}
	catch(e){}	
	
}

function extDom_focus( nomeCampo, src )
{
	//console.log('focus');

	var visualField = document.getElementById(nomeCampo + '_edit_new');

	//Salvo il precedente valore
	oldValueDomainExt[nomeCampo] = visualField.value;

	try
	{
		//Se portandomi sulla text non trovo niente nel campo hidden tecnico
		//cancello il contenuto della text (vedi ad es. il testo 'selezionare un elemento')
		
		if ( document.getElementById(nomeCampo).value == '')
			visualField.value = '';
		else	
			//L'evento onFocus combinato al .select() non funziona con chrome (e forse safari)
			visualField.select();
	}
	catch(e) {}
	
}

function extDom_keyDown ( e ,nomeCampo )
{
	//L'evento di tab deve essere catturato dal keydown per il keyup lo recepisce quando si arriva sul controllo da un tab
	//non quando si fa tab per uscirne
	if(e.keyCode == '9')
	{
		DomainExtInTab[nomeCampo] = 'tab';
		//alert('tab keydown');
	}
}

function extDom_keyUp( nomeCampo, src, e,  nomeDominio, filter )
{
	
	//effettuo la ricerca per la descrizione inserita

	var campoAvideo = document.getElementById(nomeCampo + '_edit_new');
	var bottone = document.getElementById(nomeCampo + '_button');
	
	var DESC = campoAvideo.value;
	var ret;
	
	//Se il testo non è cambiato rispetto al precedente non faccio niente
	try
	{
		if ( oldValueDomainExt[nomeCampo].toUpperCase() == DESC.toUpperCase() )
		{
			return;
		}
	}
	catch(e){}	
	
	if (DESC != '')
	{
		//Se c'è qualcosa nella text
		var ajaxTemp = GetXMLHttpRequest(); //Creo l'oggetto xmlhttp
		var objHide;
		var multiValue = '0';
		var strformat = '';
		
		if(ajaxTemp)
		{
			objHide = getObj( nomeCampo ); // Campo tecnico
			//var FILTER = GetProperty(objHide,'filter');
			var doc = SearchDocumentForExtendeAttrib();
			var strPath = '';
			
			try
			{
				multiValue = GetProperty(objHide,'multivalue');
				
				if ( multiValue == '' ) 
					multiValue = '0';
			}
			catch(e)
			{
			}	


			try
			{								
				strformat = GetProperty(objHide,'strformat');	

				if ( strformat.toUpperCase().indexOf('M') >= 0 )
					multiValue = '1';
			}
			catch(e)
			{
			}	

			
			
			if ( isApplicationAccessible() )
			{
				strPath = pathRoot + 'CTL_LIBRARY/';
			}
			else
			{
			
				if ( doc == null )
					strPath = '/application/CTL_LIBRARY/';
				else
					strPath = doc.strPathExtObj;
			}
			
			DESC = DESC.toUpperCase();
			
			if (DomainExtInLoading[nomeCampo] == undefined)
				DomainExtInLoading[nomeCampo] = 1; //Segnalo che il campo sta facendo una ricerca
			else
				DomainExtInLoading[nomeCampo] = DomainExtInLoading[nomeCampo] + 1;
				
			//di base lo metto rosso fino a che la ricerca asincrona non finisce
			campoAvideo.style.color='red';
			campoAvideo.style.background = '#FFFFFF url(' + strPath + 'images/ajax-loading.gif) no-repeat 1px 1px';
			campoAvideo.style.backgroundPosition = 'right';
			campoAvideo.style.backgroundSize = '15px 15px';
			
			ajaxTemp.onreadystatechange=function()
			{
				if (ajaxTemp.readyState==4 && ajaxTemp.status==200)
				{
					ret =  ajaxTemp.responseText;

					DomainExtInLoading[nomeCampo] = DomainExtInLoading[nomeCampo] - 1; //Segnalo che il campo ha finito la ricerca

					if (DomainExtInLoading[nomeCampo] == 0)
						campoAvideo.style.background = '';
					else
						return;

					var elementoColFuoco = '';
					
					if (document.activeElement)
					{
						elementoColFuoco = document.activeElement.name;
						 
						if (elementoColFuoco == '' || elementoColFuoco == undefined)
							elementoColFuoco = document.activeElement.id;
					}
					
					//console.log('fine ricerca asincrona!');
			
					if (elementoColFuoco == (nomeCampo + '_edit_new') || elementoColFuoco == (nomeCampo + '_button') )
					{
			
						if (ret != '' )
						{
							var objT = document.getElementById(nomeCampo + '_edit');			
							var resSplit = ret.split( '###' );
							
							oldValueDomainExt[nomeCampo] = resSplit[1];
							objT.value=resSplit[1];
														
							if ( multiValue == '0' )
								objHide.value=resSplit[0];
							else
								objHide.value='###' + resSplit[0] + '###';

							campoAvideo.style.color='black';
							campoAvideo.style.background = '';
							
							//Se dobbiamo completare il campo a video con l'unico match possibile
							//nel dominio						
							if ( resSplit[1].toUpperCase() != DESC.toUpperCase() )
							{
								campoAvideo.value = resSplit[1];
								bottone.focus();
							}

							//-- eseguo una eventuale funzione di onChange configurata
							try
							{
								objT.onchange();
							}
							catch( e ){};

						}
						else
						{
							campoAvideo.style.color = 'red';
						}
						
					}
					else
					{
						if (ret != '' )
						{
							var objT = document.getElementById(nomeCampo + '_edit');			
							var resSplit = ret.split( '###' );
							
							oldValueDomainExt[nomeCampo] = resSplit[1];
							objT.value=resSplit[1];
							objHide.value=resSplit[0];

							campoAvideo.style.color='black';
							campoAvideo.style.background = '';
							
							//Se dobbiamo completare il campo a video con l'unico match possibile
							//nel dominio						
							if ( resSplit[1].toUpperCase() != DESC.toUpperCase() )
							{
								campoAvideo.value = resSplit[1];
							}

							//-- eseguo una eventuale funzione di onChange configurata
							try
							{
								objT.onchange();
							}
							catch( e ){};
						}
						else
						{
							//Se il fuoco non è ne sulla text ne sul bottone ripristiniamo il vecchio valore
							campoAvideo.value = oldValueDomainExt[nomeCampo];
							campoAvideo.style.color = 'black';
							campoAvideo.style.background = '';
							oldValueDomainExt[nomeCampo] = '';
						}
					}
				}
			}
			
			//invocazione asincrona
			ajaxTemp.open("GET", strPath + 'GetDomValue.asp?FIND_DESC=YES&FIELD=' + escape( nomeCampo ) + '&FILTER=' + escape( filter ) + '&DESC=' + escape( DESC )  + '&DOMAIN=' + escape( nomeDominio) + '&FORMAT=' + escape(strformat) , true);
			ajaxTemp.send(null);

		}
	

		
	}
	else
	{
		getObj( nomeCampo ).value= '';
		campoAvideo.style.color = 'black';
		campoAvideo.style.background = '';
		oldValueDomainExt[nomeCampo] = '';
		
		try
		{
			var objT = document.getElementById(nomeCampo + '_edit');	
			objT.onchange();
		}
		catch( e ){};
		
	}
	
}

function extDom_lostFocus( nomeCampo, src, isButton )
{
	//console.log('lostFocus');
	
	if ( isButton )
	{
		//Se abbiamo perso il fuoco dal bottone togliamo il focus dalla coppia
		DomainExtInTab[nomeCampo] = '';
	}

	var visualField = document.getElementById(nomeCampo + '_edit_new');
	var elementoColFuoco = '';
					
	if (document.activeElement)
		elementoColFuoco = document.activeElement.name;
	
	//Se non c'è una ricerca in corso
	if (DomainExtInLoading[nomeCampo] == 0)
	{
		if (visualField.style.color == 'red')
		{
			//console.log('elemento col fuoco : ' + elementoColFuoco);
		
			//Se siamo usciti dal fuoco sul contesto bottone + text
			if (elementoColFuoco != (nomeCampo + '_button') && elementoColFuoco != (nomeCampo + '_edit_new') && DomainExtInTab[nomeCampo] == '')
			{
				//Ripristiniamo il vecchio valore
				visualField.value = oldValueDomainExt[nomeCampo];
				visualField.style.color = 'black';
				oldValueDomainExt[nomeCampo] = '';
			}
		}
		
	}
}

function extDom_openDocModal( nomeCampo, srcIframe, idDiv )
{
	/*
		 nomeCampo : ID del campo hidden per inserirci i valori selezionati
		 srcIframe : url da inserire come src dell'iframe per visualizzare il dominio gerarchico. deve finire
					 con il parametro Value= così da poterlo passare facilmente da js
		 idDiv	   : iframe + idDiv =  ID dell'iframe
	 */

	var nomeDivPerModale = 'dialog-iframe-modale';
	var value = document.getElementById(nomeCampo).value;
	var path = '';
	var idBottone = '';
	
	try
	{
		// Metto il focus sul bottone (sia se clicco sul bottone stesso o sulla text)
		idBottone = nomeCampo + "_button";
		//document.getElementById(idBottone).focus();
		window.focus();
	}
	catch(e) {}

	
	var i = 1;
	var percorso = '';
	var posizioneUltimaDivBuona = 'document'; //Il documento corrente è il default per trovare la div della modale
	var result;
	
	/* 
		Per i contesti in cui il campo che apre la modale è contenuto in un iframe (quindi la modale non riesce ad espandersi correttamente)
		risaliamo i parent fino ad arrivare all'ultimo punto disponibile che contiene la DIV della modale, così da mettergli a disposizione
		il maggiore spazio disponibile nel browser
	*/	

	while (i < 5) // Risalgo fino a 4 livelli. inception!
	{
		try
		{
			percorso = percorso + '.parent';

			result = '';
			result = eval('window' + percorso).testActiveExtendedAttrib();
			
			//Se trovo la funzione 'testActiveExtendedAttrib' ci sarà in quel parent anche la DIV che sto cercando per aprire la modale
			if ( result == 'OK' )
			{
				posizioneUltimaDivBuona = 'window' + percorso + '.document';
			}
		}
		catch(e)
		{
		}
		
		i++;
	}
	
	path = eval( posizioneUltimaDivBuona + ".getElementById('path_x_extended').value;");
	
	srcIframe = path + srcIframe + encodeURIComponent(value);
	
	//$("#dialog-iframe-modale", eval(posizioneUltimaDivBuona) ).html($("<iframe scrolling='no' id='iframe" + idDiv + "' frameborder='no' height='650px' width='850px' border='0' />").attr("src", srcIframe)).dialog(
	//eval('$("#dialog-iframe-modale", ' + posizioneUltimaDivBuona + ' )').html($("<iframe scrolling='no' id='iframe" + idDiv + "' frameborder='no' height='100%' width='850px' border='0' />").attr("src", srcIframe)).dialog(
	
	eval('$("#dialog-iframe-modale", ' + posizioneUltimaDivBuona + ' )').load(srcIframe).dialog(
	{
	
      modal: true,
      height: 750,
      width: 870,
      buttons: {
        Conferma: function() 
        {
		
			//Se il field è editabile
			if (getIFrameDom(posizioneUltimaDivBuona, 'iframe' + idDiv).isEditable() == 1)
			{
				var val = getIFrameDom(posizioneUltimaDivBuona, 'iframe' + idDiv).getSelectedItemes();
				var desc = getIFrameDom(posizioneUltimaDivBuona, 'iframe' + idDiv).getSelectedItemesHTML();				
				var oldVal = document.getElementById(nomeCampo).value;
				
				document.getElementById(nomeCampo).value = val;
				
				if ( oldVal != val )
				{
					//Se c'è stato un cambio di valori faccio scattare l'evento onchange
					try
					{
						document.getElementById(nomeCampo).onchange();
					}
					catch(e)
					{
						//alert('Errore nella funzione all\'onchange.Messaggio:' + e.message);
					}
				}

				
				var obj = document.getElementById(nomeCampo + '_edit_new');
				
				if ( obj.tagName == 'input' )
					obj.value = desc;
				else //Per le label
					document.getElementById(nomeCampo + '_edit_new').innerHTML = desc;
			}
			
			$( this ).dialog( "close" );
        },
		Annulla: function() {
          $( this ).dialog( "close" );
        }
      }
    });
}

function getIFrameDom(context, idIFrame)
{
	try
	{
		var inside =  eval(context + '.getElementById(idIFrame).contentWindow');
		return inside;
	}
	catch(e)
	{
		alert('errore nel recupero elementi selezionati: ' + e.message);
		return "";
	}

}


//-- quando si preme il bottone si apre o si chiude la select
function FEXTF5(  name, IdDomain , TypeAttrib )
{
	//-- se è configurato il formato search apre un viewer
	var search = '';
	
	try { search = GetProperty(getObj( name ),'search'); }catch( e ) {};
	
	if( search == '' )
	{
		return FldExtDomOnButton(  name, IdDomain , TypeAttrib);
	}
	else
	{
		var FilterHide = GetProperty(getObj( name ),'filter');
		var doc = SearchDocumentForExtendeAttrib();

		var URL = doc.strPathExtObj + 'functions/field/FldExtViewer.asp?Table=ExtendedDomain_' + search + '&IDENTITY=ID&TOOLBAR=&PATHTOOLBAR=../CTL_Library/&JSCRIPT=FldExtSelRow&Caption=ExtendedDomain_' + search + '&Height=130,100*,210';
		URL = URL + '&DOCUMENT=' + escape(  name );
		URL = URL + '&OWNER=idPfu';
		URL = URL + '&Filter=' + escape(  '' );
		URL = URL + '&FilterHide=' + FilterHide //+ '&HIDEBUTTON=yes';
		URL = URL + '&L_F=&Exit=si&AreaInfo=no&AreaFiltro=&AreaAdd=no&numRowForPag=25&Sort=DMV_DescML&FilteredOnly=yes';
	
		
	
		LocExecFunctionCenter( URL + '#' + search + '#800,600' );

	}
}	 



function FldExtDomOnButton( name, IdDomain , TypeAttrib )
{
	try{
		//debugger;
		
		var nameFrame;
		var objT =  getObj( name + '_edit'); 
		var objT1 =  getObj( name + '_edit1'); 

		objT1.style.top = PosTop( objT ); 
		objT1.style.left = PosLeft( objT );
		objT1.style.width = objT.offsetWidth;
		//objT1.offsetHeight = objT.offsetHeight;
		
		setVisibility( objT1 , '' );

		
		//-- cerco il documento dove si trova la finestra
		var doc = SearchDocumentForExtendeAttrib();
		var bOpenCtl = false;
		
		var objT = getObj( name + '_edit'  );
		var objHide = getObj( name  );
		
		//var filter = objHide.filter;
		var filter = GetProperty(objHide,'filter');

		//- prendo l'iframe relativo al controllo che mi interessa
		var objCtl = doc.GetAttrib( name , '' , filter , '', IdDomain , TypeAttrib );
		
		//var identity = objCtl.identity;
		var identity = GetProperty(objCtl,'identity'); 
		
		nameFrame= 'ExtAttrib_'+ identity ;
		
		//recupero nome della select che contiene il dominio caricato
		nameSel= IdDomain + '_' + TypeAttrib
		
		var objSel = doc.frames[nameFrame].document.all( nameSel + '_sel' );
				
		//-- recupero la div dove si trova il controllo
		var objDiv = doc.getObj( 'ExtAttrib_' + identity + '_div' );

		
		//-- verifica se la finestra è aperta o chiusa
		if( objDiv.visible == '1' )
		{
			//-- chiude il controllo
			bOpenCtl = false;
			objDiv.visible = '1';
		}
		else
		{
			//-- apre il controllo
			bOpenCtl = true;
			objDiv.visible = '0';
		}

		
		if ( bOpenCtl == true )
		{
			
			//-- determina la nuova posizione e dimensione
			SetExtFldPositionXY( objT , objDiv );

			//-- setta il valore corrente
			if( objSel != null )
			{
				objSel.value = objHide.value;
				
				objDiv.visible = '1';
				setVisibility( objDiv , '' );

				//-- aggiusto le dimensioni della lista
				var ObjB = doc.getObj( 'ExtAttrib_' + identity  );
				var ObjA = doc.frames[nameFrame].document.all( 'ObjectAttrib' );
				
				if ( ObjA.offsetWidth == 0 || ObjA.offsetHeight == 0) 
				{
					objDiv.style.width = 200;
					objDiv.style.height = 100;
					ObjB.width = 200;
					ObjB.height = 100;
				
				}
				else
				{
					objDiv.style.width = ObjA.offsetWidth;
					objDiv.style.height = ObjA.offsetHeight;
					ObjB.width = ObjA.offsetWidth;
					ObjB.height = ObjA.offsetHeight;
				}
			}
			

			

			//-- visualizza il controllo 
			objDiv.visible = '1';
			setVisibility( objDiv , '' );

			if( objSel != null )
			{
				objSel.focus();
			}

			
			//-- setta se stesso come utilizzatore
			doc.vetObjExtUser[identity] = document;
			doc.frames[nameFrame].document.DocUser = document;

		}
		else
		{
			//-- nascondo il controllo 		
			objDiv.visible = '0';
			setVisibility( objDiv , 'none' );
		
		}
		
		
	}catch( e ){};
	
}

//-- quando si scrive nel controllo
function FEXTF4(  objEdit,  name , IdDomain , TypeAttrib )
{
	//-- se è configurato il formato search apre un viewer
	var search = '';
	try { search = GetProperty(getObj( name ),'search'); }catch( e ) {search = '';};
	
	if( search == '' )
	{

		return FldExtDomOnKeyUp(  objEdit,  name , IdDomain , TypeAttrib);
	}
	else
	{
		//effettuo la ricerca sul server
		return SrvFldExtDomOnKeyUp(  objEdit,  name , IdDomain , TypeAttrib);
	}
}	 



function SrvFldExtDomOnKeyUp( objEdit,  name , IdDomain , TypeAttrib)
{
	var objHide;
	var objT; 
	var objT1; 
	var ret = '';

	var FieldName = name;


	try
	{	
		//-- determina il nome del campo cercando di togliere il numero di riga
		var NRow = name.split( '_' )[0].substring( 1 , 10 );

		var str = Number( NRow );

		if( name.substr( 0 , 1 ) == 'R' )
		{
			FieldName = name.substr( NRow.length + 2 , 100 );
		}

	}catch(e){};


	objHide = getObj( name );
	objT =  getObj( name + '_edit'); 
	objT1 =  objEdit ;

	var AutoIncrement = '';
	try {
		AutoIncrement  = GetProperty(objHide,'AutoIncrement'); 
	}catch(e){ AutoIncrement = ''; };
	
	//-- effettua la chiamata server

	var ajaxTemp = GetXMLHttpRequest(); //Creo l'oggetto xmlhttp

	if(ajaxTemp){

		var FILTER = GetProperty(objHide,'filter');

		var DESC = objT1.value.toUpperCase();
		
		var doc = SearchDocumentForExtendeAttrib();

		ajaxTemp.open("GET", doc.strPathExtObj + 'GetDomValue.asp?FIELD=' + escape( FieldName ) + '&FILTER=' + escape( FILTER ) + '&DESC=' + escape( DESC )  , false);
			 
		ajaxTemp.send(null);


		if(ajaxTemp.readyState == 4) {
			if(ajaxTemp.status == 200)
			{
				ret =  ajaxTemp.responseText;
				
			}
		}

	}
	
	if (ret != '' )
	{
		//objT.value="";

		objT.value=ret.split( '###' )[1]; // objSel.options[index].text;
		objHide.value=ret.split( '###' )[0]; //objSel.options[index].value;

		objT1.style.color='black';
		//objSel.selectedIndex=index;

		//-- eseguo una eventuale funzione di onChange configurata
		try{ 
			objT.onchange();
		} catch( e ){};
				
	}
	else
	{
		
		if ( AutoIncrement != '' )
		{
				objHide.value = objT1.value ;
				objT.value = '';
				//-- eseguo una eventuale funzione di onChange configurata
				try{ 
					objT.onchange();
				} catch( e ){};

		}
		else
		{

			if ( objHide.value != '' )
			{
				objHide.value = '';
				objT.value = '';
				//-- eseguo una eventuale funzione di onChange configurata
				try{ 
					objT.onchange();
				} catch( e ){};
			}

			objT.value='';
			objHide.value='';

		}
		objT1.style.color='red';
		//objSel.selectedIndex=-1;

	}
	
	

}

function FldExtDomOnKeyUp( objEdit,  name , IdDomain , TypeAttrib)
{
	var nameFrame;
	//debugger;
	var objHide;
	var objT; 
	var objT1; 


	try{
		//-- cerco il documento dove si trova la finestra
		var doc = SearchDocumentForExtendeAttrib();
		
				
		objHide = getObj( name );
		objT =  getObj( name + '_edit'); 
		objT1 =  objEdit ; //getObj( name + '_edit1'); 

		//-- variabile per stabilire se il dominio esteso è auto incrementante
		var AutoIncrement = '';
		try {
			AutoIncrement  = GetProperty(objHide,'AutoIncrement'); 
		}catch(e){ AutoIncrement = ''; };


		//- prendo l'iframe relativo al controllo che mi interessa
		//var filter = objHide.filter;
		var filter = GetProperty(objHide,'filter'); 
		var objCtl = doc.GetAttrib( name , '' , filter , '', IdDomain , TypeAttrib);
		//var identity = objCtl.identity;
		var identity = GetProperty(objCtl,'identity'); 
		var objDiv = doc.getObj( 'ExtAttrib_' + identity + '_div' );
		


		//-- nasconde la div della selezione
		//-- determina la nuova posizione e dimensione
		//SetExtFldPositionXY( objT , objDiv );
		//objDiv.visible = '1';
		//setVisibility( objDiv , '' );
		objDiv.visible = '0';
		setVisibility( objDiv , 'none' );
		
		

		nameFrame= 'ExtAttrib_'+ identity ;
		
		//recupero nome della select che contiene il dominio caricato
		nameSel= IdDomain + '_' + TypeAttrib
		
		var objSel = doc.frames[nameFrame].document.all( nameSel + '_sel' );
		var index = objSel.selectedIndex;

		
		var l = objT1.value.length;
		var v = objT1.value.toUpperCase();
		objT1.value = v;
		
		//alert( l );
		
		if( l == 0 )
		{
			objSel.selectedIndex=-1;
			//alert( objHide.value );
			if ( objHide.value != '' )
			{
				objHide.value = '';
				objT.value = '';
				//-- eseguo una eventuale funzione di onChange configurata
				try{ 
					objT.onchange();
				} catch( e ){};
			}
			objHide.value = '';
			objT.value = '';
			return;
		}
		
		var i;
		

		//-- cerca nella select la prima occorrenza che soddisfa la ricerca
		var nInitPos=0;
		var nLastPos=objSel.length-1;
		var nIndexLastElements=objSel.length-1;
		var nIndexStartElements=0;
		var index=new Number();
	
		index=parseInt((nInitPos+nLastPos)/2);

			while (objSel.options[index].text.substr(0,l).toUpperCase() != v && nInitPos <= nLastPos)
			{
				if (objSel.options[index].text.substr(0,l).toUpperCase() < v )
				{
					nInitPos=index+1
					nIndexStartElements=nInitPos
					nLastPos=nIndexLastElements;
				}
				else
				{
					nInitPos=nIndexStartElements;
					nLastPos=index-1;
					nIndexLastElements=nLastPos;
				}
				index=parseInt((nInitPos+nLastPos)/2);
			}

            				
            //-- cerca di risalire al primo utile
            var continua = 1;
            if( objSel.options[index].text.substr(0,l).toUpperCase() == v )
            {
                var Lastindex = index;
                nLastPos = index;
                nIndexLastElements = index;
                
			    while ( nInitPos < nLastPos)
			    {
				    if (objSel.options[index].text.substr(0,l).toUpperCase() == v )
					    nLastPos=index;
				    else
					    nInitPos=index+1;

				    index=parseInt((nInitPos+nLastPos)/2);
			    }

                if( objSel.options[index].text.substr(0,l).toUpperCase() != v )
                    index = Lastindex;
            
            }
            

				
			if (objSel.options[index].innerHTML.substr(0,l).toUpperCase() == v )
			{
			    if ( index  > 0  ) 
			    {
    		        while (index  > 0 && objSel.options[index -1].innerHTML.substr(0,l).toUpperCase() == v)
    		        {
    		            index--;
    		         }
                }
                
				objT.value="";

				objT.value=objSel.options[index].text;
				objHide.value=objSel.options[index].value;

				objT1.style.color='black';
				objSel.selectedIndex=index;

				//-- eseguo una eventuale funzione di onChange configurata
				try{ 
					objT.onchange();
				} catch( e ){};
				
			}
			else
			{
		
				if ( AutoIncrement != '' )
				{
						objHide.value = objT1.value ;
						objT.value = '';
						//-- eseguo una eventuale funzione di onChange configurata
						try{ 
							objT.onchange();
						} catch( e ){};

				}
				else
				{

					if ( objHide.value != '' )
					{
						objHide.value = '';
						objT.value = '';
						//-- eseguo una eventuale funzione di onChange configurata
						try{ 
							objT.onchange();
						} catch( e ){};
					}

					objT.value='';
					objHide.value='';

				}
				objT1.style.color='red';
				objSel.selectedIndex=-1;

			}

		//-- eseguo una eventuale funzione di onChange configurata
		try{ 
			FldExtDomOnChange( name );
		} catch( e ){};

	}catch( e ) {

		objHide = getObj( name );
		objT =  getObj( name + '_edit'); 
		objT1 =  objEdit ; //getObj( name + '_edit1'); 

		//objT.value='';
		//objHide.value='';

		if ( AutoIncrement != '' )
		{
				objHide.value = objT1.value ;
				objT.value = '';
				//-- eseguo una eventuale funzione di onChange configurata
				try{ 
					objT.onchange();
				} catch( e ){};

		}

		objT1.style.color='red';
	
	};

}

//-- quando si preme si cambia selezione nella select si cambia il valore
function FldExtDomChangeSelect( objSel,  name )
{
	
	try{
	
		
		//debugger;
		if( parent.vetObjExtUser[ identity ] == null ) return;
	
		//recupero il nome del controllo da aggioranre
		name=parent.vetObjControlName[ identity ];
			
		
		var docSrc = parent.vetObjExtUser[ identity ];
		
		//-- prendo il valore selezionato e lo riporto nei campi visibili
		var index = objSel.selectedIndex;
		
		var objHide = getObjFromDoc( name ,docSrc);
		var objT =  getObjFromDoc( name + '_edit' ,docSrc); 
		var objT1 =  getObjFromDoc( name + '_edit1' ,docSrc); 
		
		objHide.value = objSel.options[index].value;
		objT.value = objSel.options[index].text; 
		objT1.value = objSel.options[index].text; 
		
		
		//-- nasconde la div della selezione
		 
		var objDiv = parent.getObj( 'ExtAttrib_' + identity + '_div' );
		objDiv.visible = '0';
		setVisibility( objDiv , 'none' );

		//-- eseguo una eventuale funzione di onChange configurata
		try{ 
			//debugger;
			//var my = docSrc;
			//parent.FldExtDomOnChange( name );
			
			objT1.style.color='black';
			
			objT.onchange();
		} catch( e ){};

	
	}catch( e ){};
	
}


//-- quando perde il fuoco chiude la finestra
function FldExtDomOnResize( objSel,  name )
{

	try{
		//debugger;
		
		//-- nasconde la div della selezione
		 
		var objDiv = parent.getObj( 'ExtAttrib_' + identity + '_div' );

		if ( objSel.offsetWidth > 100 )
			objDiv.style.width = objSel.offsetWidth;
		else
			objDiv.style.width = 100;
					
		if ( objSel.offsetHeight > 100 )
			objDiv.style.height = objSel.offsetHeight;
		else
			objDiv.style.height = 100;


	}catch( e ){};

}


//-- quando perde il fuoco chiude la finestra
function FldExtDomOnBlur( objSel,  name )
{

	try{
	
		
		//-- nasconde la div della selezione
		 
		var objDiv = parent.getObj( 'ExtAttrib_' + identity + '_div' );
		objDiv.visible = '0';
		setVisibility( objDiv , 'none' );
		

	}catch( e ){};

}

//-- quando perde il fuoco chiude la finestra
function FEXTF2(  objSel,  name )
{
	var search = '';
	try { search = GetProperty(getObj( Name ),'search'); }catch( e ) {};
	
	if( search == '' )
		return FldExtDomEditOnBlur(  objSel,  name );
}	 

function FldExtDomEditOnBlur( objSel,  name )
{

	try{

		
		var doc = SearchDocumentForExtendeAttrib();
		var objCtl = doc.GetAttrib( name , '' , filter , '', IdDomain , TypeAttrib);
		var identity = objCtl.identity;
		var objDiv = doc.getObj( 'ExtAttrib_' + identity + '_div' );
		
		
		//-- nasconde la div della selezione
		objDiv.visible = '0';
		setVisibility( objDiv , 'none' );

		
		
	}catch( e ){};


}


function FEXTF1( name )
{
	return FldExtDomOnFocusT( name );
}	 

function FldExtDomOnFocusT( name )
{
	try{
		
		var objT =  getObj( name + '_edit'); 
		var objT1 =  getObj( name + '_edit1'); 
		
		
		objT1.style.top = PosTop( objT ); 
		objT1.style.left = PosLeft( objT );
		
		
		objT1.style.width = objT.offsetWidth;
		
		setVisibility( objT1 , '' );
		
		objT1.focus();
		
	
	}catch( e ){};

}



function FldExtDomLoadDiv( objDiv , name )
{

	try
	{
		
		var objEdit;
		var objButt;
		//var filter = objDiv.filter;

		//-- se l'area non è caricata la carico e la posiziono
		if( objDiv.load == '0' )
		{

			//-- posiziono il controllo di edit
			var objT =  getObj( name + '_edit'); 
			var objT1 =  getObj( name + '_edit1'); 

			objT1.style.top = PosTop( objT ); 
			objT1.style.left = PosLeft( objT );
			objT1.style.width = objT.offsetWidth;

			objDiv.load  = '1';
			/*		
			//-- recupero il contenuto da visualizzare
			var objWin = SearchDocumentForExtendeAttrib( );
			//debugger;
			var objContent = objWin.GetAttrib( name , '' , filter , '' );
					
			if ( objContent.load == '0' )
			{
				objDiv.load  ='0';
				objDiv.visible = '0';
				setVisibility( objDiv , 'none' );
				alert( 'The Attribute isn\'t loaded, please retray' );
				var objWin = SearchDocumentForExtendeAttrib();
				objWin.LoadAttrib( name , '' , filter , '');
				return;
					
			}
					
			objDiv.innerHTML = objContent.innerHTML;
			*/		
			//-- posiziono il controllo sotto larea delledit
			
			objEdit = getObj( name + '_edit' );
			objButt = getObj( name + '_button' );
		        
			objDiv.style.top = PosTop( objEdit ) + objEdit.offsetHeight;
			objDiv.style.left = PosLeft( objEdit );
			//objDiv.style.width = objEdit.offsetWidth + objButt.offsetWidth;
					
			//objDiv.style.height = objContent.offsetHeight;
 					
		}

	}catch( e ){alert('errore');};

}

function FldExtDomOnChange(  name )
{
	//-- eseguo una eventuale funzione di onChange configurata
	try{ 
		//debugger;
		var onchange = eval( name + '_strTextOnChange' );
		if ( onchange != '' )
		{
			eval( onchange ); 
		}
	} catch( e ){};

}


//-- invoco il caricamento del dominio esteso nella pagina nascosta
function FEXTF3( Name,ParamEventChange,IdDomain,TypeAttrib )
{
	var search = '';
	try { search = GetProperty(getObj( Name ),'search'); }catch( e ) {};
	
	if( search == '' )
	{	
		//var Filter = getObj( Name ).filter;
		var Filter = GetProperty(getObj( Name ),'filter');
	
		return LoadDomainExtended( Name,Filter,ParamEventChange,IdDomain,TypeAttrib );
	}
}	 

function LoadDomainExtended(Name,Filter,ParamEventChange,IdDomain,TypeAttrib) 
{
	
	try{
	    //debugger;
        var objWin = SearchDocumentForExtendeAttrib();
        if ( objWin != null )
        {
			//alert(objWin.name);
			strParam= 'ONCHANGE=' + ParamEventChange;
			try{ strParam= strParam + '&STRFORMAT=' + GetProperty(getObj( Name ),'strformat') ; }catch( e ) {}
			
			objWin.LoadAttrib( Name , '' , Filter, '' ,strParam,IdDomain,TypeAttrib );
		}
    }catch( e ) { alert( 'Errore in caricamento controllo esteso FldExtendedDomain' ); }
    
     
}





//-- consente di svuotare  il valore per un dominio esteso , 
function FldExtDomResetValue( name )
{
	
	try{
	
	
		
		//debugger;
		var objHide = getObj( name );
		var objT =  getObj( name + '_edit' ); 
		var fieldVisual = getObj(name + '_edit_new');
		
		var oldValue = objHide.value;
		objHide.value = '';
		objT.value = ''; 
		fieldVisual.value = ''; 
		
		
		//-- eseguo una eventuale funzione di onChange configurata
		try{ 
			
			fieldVisual.style.color='black';
			
			if( oldValue != objHide.value )
			{
				objT.onchange();
			}
			
		} catch( e ){};
	
	}catch( e ){};
	
}


function FldExtSetValue( name , txt , cod)
{
	
	try{
	
		var objHide = getObj( name );
		var objT =  getObj( name + '_edit' ); 
		var fieldVisual = getObj(name + '_edit_new');
		
		var oldValue = objHide.value;
		
		objHide.value = cod;
		objT.value = txt; 
		fieldVisual.value = txt; 
		
		//objT1.value = txt; 
		
		
		
		//-- eseguo una eventuale funzione di onChange configurata
		try{ 
			
			try{objT1.style.color='black'}catch(e){};
			
			if( oldValue != objHide.value )
			{
				objT.onchange();
			}
			
		} catch( e ){};
	
	}catch( e ){};
	
}

/*
function FldExtSelRow( grid , r , c )
{
	try { 
		
		var name = getObj( 'DOCUMENT' ).value; 
		var txt = getObj( 'R' + r + '_DMV_DescML' ).value; 
		var cod = getObj( 'R' + r + '_DMV_Cod' ).value;
		
		//se esiste sul parent il campo name_appoggio recupero dal suo valore il nome del campo da aggiornare 
		//var nomeCampo_Appoggio = name.toLowerCase() + '_appoggio';
		
		//if ( ! parent.opener.getObj(nomeCampo_Appoggio)) 
		//	name = 	parent.opener.getObj(nomeCampo_Appoggio).value;
		
		parent.opener.FldExtSetValue( name , txt , cod);
		
	}catch(e){
		alert( 'errore nel recupero e selezione dell\'elemento' );
	};
}
*/

function FldExtSelRow( grid , r , c )
{
	try { 
		
		var name = getObj( 'DOCUMENT' ).value; 


		var txt = getObj( 'R' + r + '_DMV_DescML' ).value; 
		var cod = getObj( 'R' + r + '_DMV_Cod' ).value;
		
		if ( txt == undefined || cod == undefined )
		{
			txt = getObj( 'R' + r + '_DMV_DescML' )[0].value; 
			cod = getObj( 'R' + r + '_DMV_Cod' )[0].value;
		}
		
		//se esiste sul parent il campo name_appoggio recupero dal suo valore il nome del campo da aggiornare 
		var nomeCampo_Appoggio = name.toLowerCase() + '_appoggio';
		
		var btrovato = false ;
		
		if ( ! parent.opener.getObj(name) )
		{
			
			if ( parent.opener.getObj(nomeCampo_Appoggio) ) 
			{
				btrovato = true ;
				name = 	parent.opener.getObj(nomeCampo_Appoggio).value;
			}
		}
		else
		{	
			btrovato = true ;
		}
		
			
		if ( btrovato )	
			parent.opener.FldExtSetValue( name ,   txt , cod );
		else
			alert( 'errore nel recupero e selezione dell\'elemento' );
		
		parent.close();
		
	}catch(e){
		alert( 'errore nel recupero e selezione dell\'elemento' );
	};
}




function LocExecFunctionCenter( param )
{
	vet = param.split( '#' );

	var w;
	var h;
	var Left;
	var Top;
	var altro;

	if( vet.length < 3  )
    	{
		w = screen.availWidth;
		h = screen.availHeight;
		Left=0;
		Top=0;
	}
	else    
	{
		var d;
		d = vet[2].split( ',' );
		w = d[0];
		h = d[1];
		Left = (screen.availWidth-w)/2;
		Top  = (screen.availHeight-h)/2;
		
		if( vet.length > 3 )
		{
			altro = vet[3];
		}
	}
	
	
	return window.open(  vet[0] ,vet[1],'toolbar=no,location=no,directories=no,status=no,menubar=no,resizable=yes,copyhistory=yes,scrollbars=yes,left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );

}
