

/* INIZIO FUNZIONI PER IL NUOVO GERARCHICO */

var oldValueHierarchy=new Object();
var HierarchyInLoading=new Object();
var HierarchyInTab=new Object();

function openHierarchyPopup( nomeCampo, srcIframe, idDiv  )
{
	var val = document.getElementById(nomeCampo).value;
	var fieldVisual = document.getElementById(nomeCampo + '_edit_new');
	var descValue = '';
	var idBottone = '';
	
	var old_filter='';
	var newFilter = '';
	
	var old_format='';
	var newFormat = '';
	
	var doc = SearchDocumentForExtendeAttrib();

	var strPath = '';

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
	
	if (fieldVisual)
		descValue = fieldVisual.value;
		
	//Recupero il parametro filter senza decodificarlo (terzo parametro a true)
	old_filter = getQSParamFromString(srcIframe,'Filter', true);
	
	if ( old_filter==null )
		old_filter='';
	
	newFilter = GetProperty(getObj(nomeCampo),'filter');
	
	if ( newFilter == null || newFilter == undefined )
		newFilter = '';

	//srcIframe = strPath + srcIframe.replace('Filter='+old_filter,'Filter=' + encodeURIComponent(newFilter));
	srcIframe = strPath + srcIframe.replace('Filter='+old_filter,'Filter_X=');

	old_format = getQSParamFromString(srcIframe,'Format', true);
	
	if ( old_format == null )
		old_format = '';
	
	newFormat = GetProperty(getObj(nomeCampo),'strformat');
	
	if ( newFormat == null || newFormat == undefined )
		newFormat = '';
	
	//AGGIUNGO SEMPRE LA J per caricamento lazy se non presente
	if ( newFormat == '' || newFormat.indexOf('J') < 0 )
		newFormat = newFormat + 'J';
	
	if ( newFormat != old_format)
		srcIframe = srcIframe.replace('Format=' + old_format,'Format=' + encodeURIComponent(newFormat));
	
	if (typeof pathRoot != 'undefined')
	{
		var oldPathImage = getQSParamFromString(srcIframe,'PathImage', true);
		var pathImage = pathRoot + 'CTL_Library/images/Domain/';
		
		
		srcIframe = srcIframe.replace('PathImage='+oldPathImage,'PathImage=' + encodeURIComponent(pathImage));
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
	}
	catch(e) {}

	if (typeof isFaseII !== 'undefined' && isFaseII) {

		closeDrawer();
		openDrawer(`<div class="iframeRightAreaContain">
						<iframe
							class="iframeRightArea"
							name='popUpHierarchy'>
						</iframe>
					</div>`,
			1200, "", "", true, true, true, false, true);

		var campi = { value: val, Filter: newFilter };

		/* REQUISITO MINIMO CTLDB 4.2.0.29 + getObj.js con metodo generaFormCollectionAndSubmit */

		generaFormCollectionAndSubmit(campi, srcIframe, 'popUpHierarchy');
		return;
	}


	//var res = window.open( srcIframe ,'popUpHierarchy','toolbar=no,location=no,directories=no,status=no,title=Gerarchico,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,height=690,width=800');
	var res = window.open('about:blank','popUpHierarchy','toolbar=no,location=no,directories=no,status=no,title=Gerarchico,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,height=690,width=800');
	
	try
	{
		res.focus();
		
		
		var campi = {value:val, Filter: newFilter };
		
		/* REQUISITO MINIMO CTLDB 4.2.0.29 + getObj.js con metodo generaFormCollectionAndSubmit */
		
		generaFormCollectionAndSubmit( campi, srcIframe, 'popUpHierarchy' );
		//generaFormValueAndSubmit(value, srcIframe, 'popUpHierarchy');
	}
	catch(e)
	{
	}
}

function hierarchy_onChangeBase( nomeCampo, src )
{
	return;
}

function hierarchy_focus( nomeCampo, src )
{
	var visualField = document.getElementById(nomeCampo + '_edit_new');

	//Salvo il precedente valore
	oldValueHierarchy[nomeCampo] = visualField.value;

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

function hierarchy_keyDown ( e ,nomeCampo )
{
	//L'evento di tab deve essere catturato dal keydown per il keyup lo recepisce quando si arriva sul controllo da un tab
	//non quando si fa tab per uscirne
	if(e.keyCode == '9')
	{
		HierarchyInTab[nomeCampo] = 'tab';
		//alert('tab keydown');
	}
}

function hierarchy_keyUp( nomeCampo, src, e,  nomeDominio, filter )
{
	//effettuo la ricerca per la descrizione inserita
	
	var campoAvideo = document.getElementById(nomeCampo + '_edit_new');
	var bottone = document.getElementById(nomeCampo + '_button');
	
	var DESC = campoAvideo.value;
	var ret;
	
	//Se il testo non è cambiato rispetto al precedente non faccio niente
	try
	{
		if ( oldValueHierarchy[nomeCampo].toUpperCase() == DESC.toUpperCase() )
		{
			return;
		}
	}
	catch(e){}	
	
	var newFilter;
	newFilter = filter;
	
	if (DESC != '')
	{
		//Se c'è qualcosa nella text
		var ajaxTemp = GetXMLHttpRequest(); //Creo l'oggetto xmlhttp
		var objHide;
		var multiValue = '0';
		
		if(ajaxTemp)
		{
			objHide = getObj( nomeCampo ); // Campo tecnico


			try
			{
				newFilter= GetProperty(objHide,'filter');
				
				if (!newFilter || newFilter == '' )
					newFilter = filter;					
				
			}
			catch(e)
			{
				newFilter=filter;
			}
			
			var doc = SearchDocumentForExtendeAttrib();
			var strPath = pathRoot + 'CTL_LIBRARY/';
			
			try
			{
				multiValue = GetProperty(objHide,'multivalue');
				
				if ( multiValue == '' ) 
					multiValue = '0';
			}
			catch(e)
			{
			}
			
			/*
			if ( doc == null )
				strPath = '/application/CTL_LIBRARY/';
			else
				strPath = doc.strPathExtObj;
			*/
			
			DESC = DESC.toUpperCase();
			
			if (HierarchyInLoading[nomeCampo] == undefined)
				HierarchyInLoading[nomeCampo] = 1; //Segnalo che il campo sta facendo una ricerca
			else
				HierarchyInLoading[nomeCampo] = HierarchyInLoading[nomeCampo] + 1;
				
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

					HierarchyInLoading[nomeCampo] = HierarchyInLoading[nomeCampo] - 1; //Segnalo che il campo ha finito la ricerca

					if (HierarchyInLoading[nomeCampo] == 0)
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
							
							oldValueHierarchy[nomeCampo] = resSplit[1];
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
							
							oldValueHierarchy[nomeCampo] = resSplit[1];
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
							campoAvideo.value = oldValueHierarchy[nomeCampo];
							campoAvideo.style.color = 'black';
							campoAvideo.style.background = '';
							oldValueHierarchy[nomeCampo] = '';
						}

					}
				}
			}
			
			//invocazione asincrona
			ajaxTemp.open("GET", strPath + 'GetDomValue.asp?FIND_DESC=YES&FIELD=' + encodeURIComponent( nomeCampo ) + '&FILTER=' + encodeURIComponent( newFilter ) + '&DESC=' + encodeURIComponent( DESC )  + '&DOMAIN=' + encodeURIComponent( nomeDominio) , true);
			ajaxTemp.send(null);

		}
	

		
	}
	else
	{
		getObj( nomeCampo ).value = '';
		campoAvideo.style.color = 'black';
		campoAvideo.style.background = '';
		oldValueDomainExt[nomeCampo] = '';
	}
}

function hierarchy_lostFocus( nomeCampo, src , isButton)
{

	if ( isButton )
	{
		//Se abbiamo perso il fuoco dal bottone togliamo il focus dalla coppia
		HierarchyInTab[nomeCampo] = '';
	}

	var visualField = document.getElementById(nomeCampo + '_edit_new');
	var elementoColFuoco = '';
					
	if (document.activeElement)
		elementoColFuoco = document.activeElement.name;
	
	//Se non c'è una ricerca in corso
	if (HierarchyInLoading[nomeCampo] == 0)
	{
		if (visualField.style.color == 'red')
		{
			//console.log('elemento col fuoco : ' + elementoColFuoco);
		
			//Se siamo usciti dal fuoco sul contesto bottone + text
			if (elementoColFuoco != (nomeCampo + '_button') && elementoColFuoco != (nomeCampo + '_edit_new') && HierarchyInTab[nomeCampo] == '')
			{
				//Ripristiniamo il vecchio valore
				visualField.value = oldValueHierarchy[nomeCampo];
				visualField.style.color = 'black';
				oldValueHierarchy[nomeCampo] = '';
			}
		}
		
	}
}

function openDocModal( nomeCampo, srcIframe, idDiv  )
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
	path = '../';
	
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
				
				
				//document.getElementById(nomeCampo + '_edit_new').value = desc;
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
/* FINE FUNZIONI PER IL NUOVO GERARCHICO */


//-- quando si preme il bottone si apre o si chiude la select
function FldHierarchyOnButton( name , IdDomain , TypeAttrib)
{
	
	try{
	
		
		//-- cerco il documento dove si trova la finestra
		var doc = SearchDocumentForExtendeAttrib();
		var bOpenCtl = false;
		
		var objT = getObj( name + '_edit'  );
		var objHide = getObj( name  );
		var filter = GetProperty(objHide,'filter');

		//- prendo l'iframe relativo al controllo che mi interessa
		var objCtl = doc.GetAttrib( name , '' , filter , '' , IdDomain , TypeAttrib);
		
		//var identity = objCtl.identity;
		var identity = GetProperty(objCtl,'identity'); 
		
		
		//var objSel = doc.frames[identity - 1].document.all( name + '_sel' );
		

		//-- recupero la div dove si trova il controllo
		var objDiv = doc.getObj( 'ExtAttrib_' + identity + '_div' );

		
		//-- verifica se chi sta utilizzando il controllo è lui
		//if( doc.vetObjExtUser[identity] != document ) 
		//{
		//	bOpenCtl = true;
		//}
		//else
		{
			//-- verifica se la finestra è aperta o chiusa
			if( objDiv.visible == undefined )
			{
				objDiv.visible = '0';
				bOpenCtl = true;
			}
			else
			{
			
				if( objDiv.visible == '1' )
				{
					//-- chiude il controllo
					bOpenCtl = false;
					//alert( 'visible = 1' );
				}
				else
				{
					//-- apre il controllo
					bOpenCtl = true;
					//alert( 'visible = 0' );
				}
			}
		}

		
		if ( bOpenCtl == true )
		{
						
			//-- determina la nuova posizione e dimensione
			//objDiv.style.top = PosTopExt( objT )+ objT.offsetHeight; 
			//objDiv.style.left = PosLeftExt( objT );
			
			var objButt = getObj( name + '_button' );
				
			objDiv.style.width = objT.offsetWidth + objButt.offsetWidth;
			objDiv.style.height = objT.offsetHeight * 10;

			//-- determina la nuova posizione e dimensione
			SetExtFldPositionXY( objT , objDiv );
			
			objDiv.visible = '1';
			setVisibility( objDiv , '' );
			
			
						
			/*
			//-- posiziono la gerarchia in alto
			nameSel= IdDomain + '_' + TypeAttrib
			
			nameFrame= 'ExtAttrib_'+ identity ;
			
			var objSel = doc.frames[nameFrame].document.all( nameSel + '_sel_' );
			
			objSel.scrollTop = 0;
			objSel.scrollLeft = 0;
				
			//-- visualizza il controllo 
			//objDiv.visible = '1';
			//setVisibility( objDiv , '' );

			
			//-- setta se stesso come utilizzatore
			doc.vetObjExtUser[identity] = document;
			//alert( 'metto il riferimento' );
			doc.frames[nameFrame].document.DocUser = document;
			*/
		}
		else
		{
			//-- nascondo il controllo 		
			objDiv.visible = '0';
			setVisibility( objDiv , 'none' );
		
		}

		nameSel= IdDomain + '_' + TypeAttrib
		nameFrame= 'ExtAttrib_'+ identity ;
			
		try {
			var objSel = doc.frames[nameFrame].document.all( nameSel + '_sel_' );
			
			objSel.scrollTop = 0;
			objSel.scrollLeft = 0;
		
		} catch( e ){};
				
		//-- setta se stesso come utilizzatore
		doc.vetObjExtUser[identity] = document;
		doc.frames[nameFrame].document.DocUser = document;
		
		
		try{
			//se è multivalore ricostruisco sempre la lista di elementi selezionati
			//a partire dai valori tecnici e visuali dell'attributo
			nMultivalue=GetProperty(objHide,'multivalue');
			if (nMultivalue == '1'){
				
				HierarchyFillListMultiValue(doc,identity,IdDomain,TypeAttrib,objHide,objT);
			}
		}catch( e ){
		
		}
		
		
	}catch( e ){
		alert('FldHierarchyOnButton errore='+e)
	};
	
}
/*{
	try{
		//debugger;
		//var objDivContent = getObj( name + '_divContent' );
		var objDiv = getObj( name + '_div' );
		var objWin = getObj( name + '_win' );
		
		if ( objDiv.load == '0' )
		{
			objWin.src =  objWin.sorgente;
			objDiv.load = '1';
		}
		
	
		//-- verifica se l area è nascosta la rendo visibile
		if ( objDiv.visible == '0' )
		{
		
			var objEdit;
			var objButt;
			objEdit = getObj( name + '_edit' );
			objButt = getObj( name + '_button' );
		        
			objDiv.style.top = PosTop( objEdit ) + objEdit.offsetHeight;
			objDiv.style.left = PosLeft( objEdit );
			objDiv.style.width = objEdit.offsetWidth +objButt.offsetWidth ;

		
			objDiv.visible = '1';
			setVisibility( objDiv , '' );
	
		}
		else
		{
			objDiv.visible = '0';
			setVisibility( objDiv , 'none' );
		}
	
	}catch( e ){};
	
}
*/

function HierarchyOpenNode( name  , idNodo )
{
	
	
	
	try{
		//debugger;
							
		var obj = getObjPage( name + '_sel_' , '' );
		var objDiv = getObj( name + '_sel_' + idNodo );
		var objImg = getObj( name + '_img_' + idNodo );
		var strPath = GetProperty(obj,'path');
		var strVisible=objDiv.visible;
		
		if (strVisible == undefined)
			strVisible=GetProperty(objDiv,'visible');	
		
		//-- verifica se l area è nascosta la rendo visibile
		if ( strVisible == '0' )
		{
			objDiv.visible = '1';
			setVisibility( objDiv , '' );
			objImg.src = strPath + 'Hminus.gif';
	
		}
		else
		{
			objDiv.visible = '0';
			setVisibility( objDiv , 'none' );
			objImg.src = strPath + 'Hplus.gif';
		}
	
	}catch( e ){};
}


function HierarchySelectNode( name  , idNodo )
{

	
	try{
		
		//debugger;
		var doc = SearchDocumentForExtendeAttrib();
		if( doc == null ) 
		{
			alert( 'errore nella ricerca delle aree di lavoro, verificare il caricamento delle aree per i domini estesi' );
			return;
		}
		
		//recupero il nome del controllo da aggiornare
		nameControl=doc.vetObjControlName[ identity ];
		
		if( doc.vetObjExtUser[ identity ] == null ) 
		{
			alert( 'riferimento non trovato' );
			return;
		}
		var docSrc = doc.vetObjExtUser[ identity ];
	
		//alert( docSrc.document.name );
		//-- prendo il valore selezionato e lo riporto nei campi visibili
		
		var objTd = getObj( name + '_' + idNodo );
		var objHide = getObjFromDoc( nameControl ,docSrc);
		var objT =  getObjFromDoc( nameControl + '_edit' ,docSrc); 

		//controllo se attributo multivalore		
		var strMultiValue = GetProperty(objHide,'multivalue');
		if (strMultiValue == '1'){

			HierarchySelectNodeMultiValue(name,idNodo,objTd,objHide,objT);
			
		}else{

			
				
			objHide.value = idNodo;
			//alert(objTd.innerHTML);
			//objT.value = objTd.innerText;
			objT.value = objTd.innerHTML;
		
		
			//-- nasconde la div della selezione
		 
			var objDiv = doc.getObj( 'ExtAttrib_' + identity + '_div' );
			objDiv.visible = '0';
			setVisibility( objDiv , 'none' );

			try {
				var func =  objT.onchange();
				//docSrc.eval( func + '();' );
			}catch(e){
				//alert('objT.onchange errore='+e)
			}
		}
	
	}catch( e ){
		//alert('HierarchySelectNode errore='+e)
	};
	
}
/*

{
	try{
		//debugger;
	
		//-- copio i valori nei campi 
		var objTd = getObj( name + '_' + idNodo );
	

		var objHide = getObjPage( name , 'parent');
		var objT =  getObjPage( name + '_edit' , 'parent' ); 
	
		objHide.value = idNodo;
		objT.value = objTd.innerText;

	
		//-- nascondo l area
		var objDiv = getObjPage( name + '_div' , 'parent');
		objDiv.visible = '0';
		setVisibility( objDiv , 'none' );
		
		
		var func =  objT.onchangefunc;
		eval( 'parent.' + func + '();' );

	}catch( e ){};

}


*/

//-- invoco il caricamento del dominio esteso nella pagina nascosta
function LoadDomainExtendedHierarchy(Name,Filter,ParamEventChange,IdDomain,TypeAttrib,nMultivalue,value) 
{
	try{
		
		var objWin = SearchDocumentForExtendeAttrib();
		
			if ( objWin != null ){
				
				try{ ParamEventChange= ParamEventChange + '&STRFORMAT=' + GetProperty(getObj( Name ),'strformat') ; }catch( e ) {}
				
				objWin.LoadAttrib( Name , '' , Filter, '' ,ParamEventChange,IdDomain,TypeAttrib ,nMultivalue,value);
			}
        
    }catch( e ) { alert( 'Errore in caricamento controllo esteso FldExtendedDomain' ); }
        
}


//-- quando perde il fuoco chiude la finestra
function FldExtHierarchyOnBlur( objSel,  name )
{

	try{
	
		
		//-- nasconde la div della selezione
		 
		var objDiv = parent.getObj( 'ExtAttrib_' + identity + '_div' );
		objDiv.visible = '0';
		setVisibility( objDiv , 'none' );
		

	}catch( e ){};

}

function RemoveElementMultiValueHierarchy( name ){
	
	var objSel;
	var codElem='';
	var descElem='';
	var indSelected='';	
	var objtempSelect; 
	
	//recupero elementi selezionati dalla lista da eliminare
	objSel=	getObj('Sel_'+ name);
	
	if (objSel.selectedIndex != -1) {
		
		try{
			for (i=objSel.length-1; i >= 0; i--)
	    		{
				if (objSel.options[i].selected){

					objSel.remove(i);
					
				}else{
			    		
					if (codElem== '' ){
						codElem = objSel.options[i].value;
						descElem = objSel.options[i].text

					}else{
						codElem = codElem + '###' +objSel.options[i].value;
						descElem = descElem + ';' +objSel.options[i].text;
					}
				
				}	

	    		}
		} catch(e){
		}
		
		var doc = SearchDocumentForExtendeAttrib();
		if( doc == null ) 
		{
			alert( 'errore nella ricerca delle aree di lavoro, verificare il caricamento delle aree per i domini estesi' );
			return;
		}
		
		//recupero il nome del controllo da aggiornare
		nameControl=doc.vetObjControlName[ identity ];
		
		if( doc.vetObjExtUser[ identity ] == null ) 
		{
			alert( 'riferimento non trovato' );
			return;
		}
		var docSrc = doc.vetObjExtUser[ identity ];
	
		
		var objHide = getObjFromDoc( nameControl ,docSrc);
		var objT =  getObjFromDoc( nameControl + '_edit' ,docSrc); 
		
		//aggiorno il campo tecnico dell'attributo
		if (codElem=='')
			objHide.value = codElem ;
		else
			objHide.value = '###' + codElem + '###';

		//aggiorno il campo visuale dell'attributo
		objT.value = descElem;
		
		//setto il tooltip sul campo di visualizzazione
		objT.title=ReplaceExtended(objT.value,';','\n\r') ;		
		
		
	}
	
	
}


function HierarchySelectNodeMultiValue(name,idNodo,objTd,objHide,objT){
	
	var objSel;

	//controllo che il nodo non è già selezionato
	
	objSel=	getObj('Sel_'+ name);
	objSel.style.display='';
	for (i=0; i< objSel.length; i++){
		if (objSel.options[i].value == idNodo){
			//alert('nodo già selezioanto');
			return false;
		}
	}

	//aggiungo la selezione alla lista
	var aggiunto=new Option('a');
	aggiunto.text=objTd.innerHTML;
	aggiunto.value=idNodo;
	objSel.options[objSel.length]=aggiunto;
	
	//aggiorno campo tecnico
	if (objHide.value ==''){
		objHide.value='###' + idNodo + '###';
		objT.value = '';
	}else
		objHide.value=objHide.value + idNodo + '###';	  

	//aggiorno campo visuale
	if (objT.value =='')
		objT.value=objTd.innerHTML;
	else
		objT.value=objT.value + ';' + objTd.innerHTML;	  
	
	//setto il tooltip sul campo di visualizzazione
	//SetProperty(objT, 'title', objT.value);
	objT.title=ReplaceExtended(objT.value,';','\n\r') ;	

}

//ricostruisce la lista degli elelmenti selezionati per un gerarchico multivalore
function HierarchyFillListMultiValue(doc,identity,IdDomain,TypeAttrib,objHide,objT){
	
	
	try{
		var nameSel= IdDomain + '_' + TypeAttrib ;
		var nameFrame= 'ExtAttrib_'+ identity ;
		var objLista = doc.frames[nameFrame].document.all( 'Sel_' + nameSel  );
	
		objLista.length=0;
		TechValue=objHide.value;
		VisualValue=objT.value;
		
		if (TechValue != ''){
			aInfo=TechValue.split('###');
			aInfo1=VisualValue.split(';');
			for (i=1; i < aInfo.length-1 ; i++){
				var aggiunto=new Option('a');
				aggiunto.value=aInfo[i];
				aggiunto.text=aInfo1[i-1];
				objLista.options[objLista.length]=aggiunto;
			}
		}
	}catch(e){
		//alert('HierarchyFillListMultiValue errore='+e)
	}				
}


function CloseHierarchy()
{

		var doc = SearchDocumentForExtendeAttrib();
		if( doc == null ) 
		{
			alert( 'errore nella ricerca delle aree di lavoro, verificare il caricamento delle aree per i domini estesi' );
			return;
		}
		
	
		if( doc.vetObjExtUser[ identity ] == null ) 
		{
			alert( 'riferimento non trovato' );
			return;
		}
	
		//-- recupero la div dove si trova il controllo
		var objDiv = doc.getObj( 'ExtAttrib_' + identity + '_div' );

		
		//-- nascondo il controllo 		
		objDiv.visible = '0';
		setVisibility( objDiv , 'none' );

}




//-- 
function FirstLoad( name , IdDomain , TypeAttrib , identity )
{
	try{
		//-- cerco il documento dove si trova la finestra
		var doc = SearchDocumentForExtendeAttrib();
		doc.FirstLoadMultiValue( name , IdDomain , TypeAttrib , identity);
		
	}catch( e ){
		
	}
	
}

function FirstLoadMultiValue( name , IdDomain , TypeAttrib , identity)
{
	
	try{
		
		//-- cerco il documento dove si trova la finestra
		var doc = SearchDocumentForExtendeAttrib();
		var bOpenCtl = false;
		
		var objT = getObj( name + '_edit'  );
		var objHide = getObj( name  );
		var filter = GetProperty(objHide,'filter');

		//- prendo l'iframe relativo al controllo che mi interessa
		//var objCtl = doc.GetAttrib( name , '' , filter , '' , IdDomain , TypeAttrib);
		
		//var identity = GetProperty(objCtl,'identity'); 
		
		
		
		try{
			//se è multivalore ricostruisco sempre la lista di elementi selezionati
			//a partire dai valori tecnici e visuali dell'attributo
			nMultivalue=GetProperty(objHide,'multivalue');
			if (nMultivalue == '1'){
				
				HierarchyFillListMultiValue(doc,identity,IdDomain,TypeAttrib,objHide,objT);
			}
		}catch( e ){
		
		}
		
	}catch( e ){
		
	}
	
}
