/* Funzioni per la nuova gestione tramite modale */

function openDomPopup( nomeCampo, srcIframe, idDiv )
{
	var value = document.getElementById(nomeCampo).value;
	
	var tmpVirtualDir;
	//tmpVirtualDir = '/Application';
	tmpVirtualDir = urlPortale;

	//if ( isSingleWin() )
		//tmpVirtualDir = urlPortale;
	if ( tmpVirtualDir == '')
		tmpVirtualDir = '/Application';
	
	srcIframe = tmpVirtualDir + '/ctl_library/' + srcIframe + encodeURIComponent(value);

	if (typeof isFaseII !== 'undefined' && isFaseII) {

		closeDrawer();
		openDrawer(`<div class="iframeRightAreaContain">
							<iframe
								class="iframeRightArea"
								src="${srcIframe}">
							</iframe>
						</div>`, "500px", "", "", false, true, true)

		return;
	}
	
	window.open( srcIframe ,'popUpHierarchy','toolbar=no,location=no,directories=no,status=no,title=Dominio,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,height=690,width=800');

}

function dom_openDocModal( nomeCampo, srcIframe, idDiv )
{
	/*
		 nomeCampo : ID del campo hidden per inserirci i valori selezionati
		 srcIframe : url da inserire come src dell'iframe per visualizzare il dominio gerarchico. deve finire
					 con il parametro Value= così da poterlo passare facilmente da js
		 idDiv	   : iframe + idDiv =  ID dell'iframe
	 */

	var nomeDivPerModale = 'dialog-iframe-modale';
	//var value = document.getElementById(nomeCampo).value;
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
	
	srcIframe = path + srcIframe;
	
	//$("#dialog-iframe-modale", eval(posizioneUltimaDivBuona) ).html($("<iframe scrolling='no' id='iframe" + idDiv + "' frameborder='no' height='650px' width='850px' border='0' />").attr("src", srcIframe)).dialog(
	eval('$("#dialog-iframe-modale", ' + posizioneUltimaDivBuona + ' )').html($("<iframe scrolling='no' id='iframe" + idDiv + "' frameborder='no' height='100%' width='850px' border='0' />").attr("src", srcIframe)).dialog(
	{
	
      modal: true,
      height: 700,
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



//-- la funzione aggiorna un campo list box ed il suo corrispettivo visuale
function SetDomValue( objName, codice, desc, cod_ext, img_name )
{
	var val;
	var Field;
	var Field_V;
	
	//solo se passato parametro desc vado a gestire il campo non editabile
	//per settare la descrizione
	if ( desc != undefined )
	{	
		try 
		{
			var extraAttrib;
			
			extraAttrib = document.getElementById(objName + '_extraAttrib');
			Field_V = getObjGrid( 'val_' + objName );
		
			SetProperty( Field_V , 'value' , codice );

			//se la classe è fld_Evidence la cambio
			if ( Field_V.className=='fld_Evidence' )
				Field_V.className='Text';
			
			//--aggiorno parte visuale se non editabile 
			if ( desc == '' )
				Field_V.innerHTML = ' ';
			else
				Field_V.innerHTML = desc;

			
		}
		catch ( e ) 
		{
		}	
	}
	
	
	//-- aggiorno campo tecnico se editabile
	try 
	{
		Field = getObjGrid( objName );
		Field.value = codice;
		
		//se la classe è fld_Evidence la cambio
		if (Field.className=='fld_Evidence')
			Field.className='Text';
			
	}
	catch ( e ) 
	{
		
	}
	
}


//queste 2 funzioni servono per bloccare la select di un dominio per renderlo readonly
function SelectreadOnly(objName,b)
{
	if ( b == true )
	{
		getObj(objName).setAttribute('onmousedown','blocca_controllo(event)');
		getObj(objName).className =  getObj(objName).className + ' readonly';
	}
	if ( b == false )
	{
		getObj(objName).setAttribute('onmousedown','');
		getObj(objName).className = ReplaceExtended(getObj(objName).className,' readonly','')
	}
}

function blocca_controllo(e)
{

	e = e || window.event;
	  
	try
	{
		e.preventDefault();
        this.blur();
        window.focus();
	}
	catch(e){}
	
	return false;
	
}


//Viene manipolato obj, trasformando in dominio chiuso se non lo è con i valori passati alla funzione
function CRITERIO_Domain (obj,valori)
{
	
	//valori mi arriva del valore@@@descrizione separati da #~#
	
	
	var newElement;
	var obj_parent;		
	var k;
	var ainfo 
	
	
	
	//SALVO UN EVENTUALE VALOR SELEZIONATO
	var oldSelected = obj.value;	
	
	if ( obj.type == 'text' )
	{
		
		newElement=document.createElement("SELECT");
		newElement.id=obj.id;
		newElement.name=obj.name;
		newElement.value=obj.value;
		obj_parent=obj.parentNode;
		obj.parentNode.removeChild(obj.parentNode.lastChild);			
		obj=obj_parent.appendChild(newElement);
	}
		
	//RIMUOVE EVENTUALI CHILD SE PRESENTI
	while(obj.firstChild) obj.removeChild(obj.lastChild);
	
	//AGGIUNGO IL SELEZIONA
	newElement = document.createElement("option");
	newElement.type = 'select-one' ;	
	newElement.name = obj.name ;
	newElement.value = '' ;	
	newElement.innerHTML = 'Seleziona';

	obj.appendChild(newElement);

	
	ainfo = valori.split('#~#');	
	
	//CICLA SU TUTTI I VALORI	
	for ( k = 0 ; k < ainfo.length ;  k++ )
	{
		newElement = document.createElement("option");
		newElement.type = 'select-one' ;
		newElement.value = ainfo[k].split('@@@')[0]
		newElement.name = obj.name ;
		newElement.id = obj.id +'_' + ainfo[k].split('@@@')[0] ;
		newElement.innerHTML = ainfo[k].split('@@@')[1];
	
		obj.appendChild(newElement);
	}
	
	//RIMETTE UN EVENTUALE VALORE SELEZIONATO
	if ( oldSelected != '' )
	{
		obj.value=oldSelected;	
	}
	
	
}

//objName = strName=nome del campo nascosto in cui inserire i valori dei checkbox checkati
function OnChangeDom_CheckMultiValue ( objName )
{
	//recupero obj del campo tecnico
	var ObjTeck = getObj(objName);
	
	var Cur = 1;
	var TeckValue = "###";
	
	//ciclo sui campi visuali (sono checkbox il cui nome/id è <objName>_<Indice>_V )
	//per settare il nuovo valore del campo tecnico
	var strNameVis = objName + '_' + Cur + '_V';
	var ObjVis = getObj(strNameVis);
	
	//ciclo fino a quando trovo campi visuali
	while( ObjVis )
	{
		if ( ObjVis.checked == 1 ) 
			TeckValue = TeckValue + ObjVis.value + '###';		
		
		Cur = Cur + 1 ;
		strNameVis = objName + '_' + Cur + '_V';
		ObjVis = getObj(strNameVis) ;
		
	}
	
	//se non ho trovato elementi chekkati svuoto il valore tecnico
	if ( TeckValue == '###' )
		TeckValue = '';
	
	//aggiorno il campo tecnico
	ObjTeck.value = TeckValue ;
	
}	
