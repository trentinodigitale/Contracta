
function addButtonAdInfoFilterDossier() {
	var objClasseIscriz = document.getElementById('ClasseIscriz');
	console.log("addButtonAdInfoFilterDossier - objClasseIscriz: " + objClasseIscriz);

	createButtonAdInfoFilterDossier('ClasseIscriz', 'Filtro_ClasseIscriz', 'false', 'Scegli prima le Classi');
	const hiddenInput = document.getElementById(objClasseIscriz.id);
	let previousValue = hiddenInput.value;
	setInterval(function () {
		if (hiddenInput.value !== previousValue) {
			previousValue = hiddenInput.value;
			changeStatusButtonAdInfoFilter(hiddenInput.value, 'Filtro_ClasseIscriz', 'Filtro_ClasseIscriz_button');
		}
	}, 500);
}

function addButtonAdInfoFilterRicercaOE() {
	var arrClassiIscriz = document.querySelectorAll("input[id$=ClasseIscriz]:not([id*=Filtro_])");
	console.log("addButtonAdInfoFilterRicercaOE - arrClassiIscriz: " + arrClassiIscriz);

	for (let objClassiIscriz of arrClassiIscriz) {
		console.log("addButtonAdInfoFilterRicercaOE - objClassiIscriz: " + objClassiIscriz.id);
		if (document.getElementById(objClassiIscriz.id + '_button')) {
			let valFiltroClasseIscrizId = getFiltroClasseIscrizId(objClassiIscriz.id);
			console.log("addButtonAdInfoFilterRicercaOE - valFiltroClasseIscrizId: " + valFiltroClasseIscrizId);
			createButtonAdInfoFilterRicercaOE(objClassiIscriz.id, valFiltroClasseIscrizId, 'false', 'Scegli prima le Classi');
			const hiddenInput = document.getElementById(objClassiIscriz.id);
			let previousValue = hiddenInput.value;
			setInterval(function () {
				if (hiddenInput.value !== previousValue) {
					previousValue = hiddenInput.value;
					changeStatusButtonAdInfoFilter(hiddenInput.value, valFiltroClasseIscrizId, valFiltroClasseIscrizId + '_button');
					setColonnaFiltri();
				}
			}, 500);
		}
	}
}

const constModelliHost = "/application/ctl_library/functions";
const constClassiSeparator = "###";
const constModelliSeparator = "|||";
const constValoriModelliSeparator = "~~~";
const classiModelliIscrizButtonStatus = new Map();

// FIXME Eventualmente da modificare per cambiare icone del button
//classiModelliIscrizButtonStatus.set('disabled', "url('https://img.icons8.com/?size=32&id=9LlU9WeVdCoa&format=png')");
//classiModelliIscrizButtonStatus.set('enabled', "url('https://img.icons8.com/?size=50&id=3004&format=png')");
//classiModelliIscrizButtonStatus.set('active', "url('https://img.icons8.com/?size=50&id=3720&format=png')");
classiModelliIscrizButtonStatus.set('disabled', "none");
classiModelliIscrizButtonStatus.set('enabled', "../../CTL_LIBRARY/images/PROPERTYSELECTOR/filter_disabled.png");
classiModelliIscrizButtonStatus.set('active', "../../CTL_LIBRARY/images/PROPERTYSELECTOR/filter_enabled.png");

function getFiltroClasseIscrizId(classeIscrizId) {
	console.log("getFiltroClasseIscrizId - classeIscrizId: " + classeIscrizId);
	if (classeIscrizId.indexOf("_") > 0) {
		return classeIscrizId.substring(0, classeIscrizId.indexOf("_") + 1) + 'Filtro_ClasseIscriz';
	}
	return 'Filtro_ClasseIscriz';
}

function setModelliButtonStyleByStatus(classiModelliIscrizButton, buttonStatus) {
	console.log("setModelliButtonStyleByStatus - classiModelliIscrizButton: " + classiModelliIscrizButton);
	console.log("setModelliButtonStyleByStatus - buttonStatus: " + buttonStatus);
	document.getElementById(classiModelliIscrizButton).style.background = "white no-repeat 30px center;";
	if (buttonStatus == 'disabled')
		document.getElementById(classiModelliIscrizButton).style.display = classiModelliIscrizButtonStatus.get(buttonStatus);
	else
		document.getElementById(classiModelliIscrizButton).style.display = "flex";

	if (buttonStatus == 'enabled')
		document.getElementById(classiModelliIscrizButton).innerHTML = '<img src="' + classiModelliIscrizButtonStatus.get(buttonStatus) + '" title="Filtra per classi di iscrizioni" alt="Filtra per classi di iscrizioni" width="25" height="25" >'
	else
		document.getElementById(classiModelliIscrizButton).innerHTML = '<img src="' + classiModelliIscrizButtonStatus.get(buttonStatus) + '" title="Filtro per classi di iscrizioni attivato" alt="Filtro per classi di iscrizioni attivato" width="25" height="25" >'

}

function changeStatusButtonAdInfoFilter(classeIscrizValue, classiModelliIscrizHidden, classiModelliIscrizButton) {
	console.log("changeStatusButtonAdInfoFilter - classeIscrizValue: " + classeIscrizValue);
	console.log("changeStatusButtonAdInfoFilter - classiModelliIscrizHidden: " + classiModelliIscrizHidden);
	console.log("changeStatusButtonAdInfoFilter - classiModelliIscrizButton: " + classiModelliIscrizButton);
	if (!classeIscrizValue) {
		document.getElementById(classiModelliIscrizHidden).value = "";
		setModelliButtonStyleByStatus(classiModelliIscrizButton, 'disabled');
	}
	else {
		var objClassiModelli = getClassiModelli(classeIscrizValue);
		if (Array.isArray(objClassiModelli) && objClassiModelli.length) {
			console.log("changeStatusButtonAdInfoFilter - classiModelliIscrizButton: getClassiModelli non vuoto");
			setModelliButtonStyleByStatus(classiModelliIscrizButton, 'enabled');
		}
		else {
			console.log("changeStatusButtonAdInfoFilter - classiModelliIscrizButton: getClassiModelli vuoto");
			setModelliButtonStyleByStatus(classiModelliIscrizButton, 'disabled');
		}
	}

	console.log("setModelliButtonStyleByStatus - document.getElementById(classiModelliIscrizHidden).value: " + document.getElementById(classiModelliIscrizHidden).value);
	if (document.getElementById(classiModelliIscrizHidden).value)
		setModelliButtonStyleByStatus(classiModelliIscrizButton, 'active');
}

function setColonnaFiltri() {
	var toDisplay = "none";
	for (i = 0; document.getElementById('R' + i + '_Filtro_ClasseIscriz_button') != undefined && i < 1000; i++) {
		if (document.getElementById('R' + i + '_Filtro_ClasseIscriz_button').style.display !== "none")
			toDisplay = "";
	}

	var colsFiltriClasseIscriz = document.querySelectorAll("#CRITERIGrid td[id$=_c4]");
	for (let colFiltriClasseIscriz of colsFiltriClasseIscriz) {
		colFiltriClasseIscriz.style.display = toDisplay;
	}
	document.getElementById('CRITERIGrid_FNZ_UPD').style.display = toDisplay;
}

function createButtonAdInfoFilterDossier(classeIscriz, classiModelliIscrizHidden, flagEditable, msgEmptyClassiIscriz) {
	var valClasseIscriz = document.getElementById(classeIscriz);
	var valClasseIscrizButton = document.getElementById(classeIscriz + '_button');

	var objModelliIscrizButton = document.createElement('div');

	objModelliIscrizButton.setAttribute('name', classiModelliIscrizHidden + '_button');
	objModelliIscrizButton.setAttribute('id', classiModelliIscrizHidden + '_button');
	objModelliIscrizButton.setAttribute('class', 'FldExtDom_button');
	var objModelliIscrizButtonTop = PosTop(valClasseIscrizButton.parentElement.parentElement.parentElement.parentElement) + 10;
	var objModelliIscrizButtonLeft = PosLeft(valClasseIscrizButton.parentElement.parentElement.parentElement.parentElement) - 60;
	console.log("createButtonAdInfoFilter - PosTop: " + PosTop(valClasseIscrizButton.parentElement.parentElement.parentElement.parentElement));
	console.log("createButtonAdInfoFilter - PosLeft: " + PosLeft(valClasseIscrizButton.parentElement.parentElement.parentElement.parentElement));
	objModelliIscrizButton.setAttribute('style', 'width: 40px; height: 40px; display: flex; justify-content: center; align-items: center; position: absolute; top: ' + objModelliIscrizButtonTop + 'px; left: ' + objModelliIscrizButtonLeft + 'px');
	objModelliIscrizButton.setAttribute('alt', 'Filtri modelli');
	objModelliIscrizButton.setAttribute("onclick", "openClassiModelliPopup('" + classeIscriz + "', '" + classiModelliIscrizHidden + "', '" + flagEditable + "', '" + msgEmptyClassiIscriz + "', this.id);");
	valClasseIscrizButton.insertAdjacentElement("afterend", objModelliIscrizButton);

	changeStatusButtonAdInfoFilter(valClasseIscriz.value, classiModelliIscrizHidden, objModelliIscrizButton.id);
}

function createButtonAdInfoFilterRicercaOE(classeIscriz, classiModelliIscrizHidden, flagEditable, msgEmptyClassiIscriz) {
	var valClasseIscriz = document.getElementById(classeIscriz);
	console.log("createButtonAdInfoFilterRicercaOE - tdFiltroClasseIscrizButton: " + 'CRITERIGrid_' + classeIscriz.substring(0, classeIscriz.indexOf("_") + 1).toLowerCase() + 'c4');
	var tdFiltroClasseIscrizButton = document.getElementById('CRITERIGrid_' + classeIscriz.substring(0, classeIscriz.indexOf("_") + 1).toLowerCase() + 'c4');
	var valClasseIscrizButton = document.getElementById(classeIscriz + '_button');

	var objModelliIscrizButton = document.createElement('div');

	objModelliIscrizButton.setAttribute('name', classiModelliIscrizHidden + '_button');
	objModelliIscrizButton.setAttribute('id', classiModelliIscrizHidden + '_button');
	objModelliIscrizButton.setAttribute('class', 'FldExtDom_button');
	objModelliIscrizButton.setAttribute('style', 'width: 40px; height: 40px; display: flex; justify-content: center; align-items: center; padding: 0px 0px 10px 10px');
	objModelliIscrizButton.setAttribute('alt', 'Filtri modelli');
	objModelliIscrizButton.setAttribute("onclick", "openClassiModelliPopup('" + classeIscriz + "', '" + classiModelliIscrizHidden + "', '" + flagEditable + "', '" + msgEmptyClassiIscriz + "', this.id);");

	tdFiltroClasseIscrizButton.innerHTML = '';
	tdFiltroClasseIscrizButton.appendChild(objModelliIscrizButton);

	changeStatusButtonAdInfoFilter(valClasseIscriz.value, classiModelliIscrizHidden, objModelliIscrizButton.id);
	setColonnaFiltri();
}

function openClassiModelliPopup(objClasseIscriz, objClassiModelliIscrizHidden, flagEditable, msgEmptyClassiIscriz, objClassiModelliIscrizButton) {
	var valClasseIscriz = document.getElementById(objClasseIscriz).value;

	console.log("openClassiModelliPopup - valClasseIscriz: " + valClasseIscriz);
	if (!valClasseIscriz) {
		alert(msgEmptyClassiIscriz);
		return;
	}

	if (typeof isFaseII !== 'undefined' && isFaseII) {

		closeDrawer();
		openDrawer(`<div class="iframeRightAreaContain" style="background-color: white;"><div class="iframeRightArea" style="background-color: white;" name="popUpClassiModelli" id="popUpClassiModelli"></div></div>`,
			1200, "", "", true, true, true, false, true);

		var objModelliHiddenId = document.createElement('input');
		objModelliHiddenId.setAttribute('type', 'hidden');
		objModelliHiddenId.setAttribute('name', 'objModelliHiddenId');
		objModelliHiddenId.setAttribute('id', 'objModelliHiddenId');
		objModelliHiddenId.setAttribute('value', document.getElementById(objClassiModelliIscrizHidden).id);
		document.getElementById("popUpClassiModelli").appendChild(objModelliHiddenId);

		var node = document.createElement('div');
		node.setAttribute('id', 'modelliNodes');
		node.setAttribute('class', 'main-div');
		node.style.backgroundColor = "white";
		document.getElementById("popUpClassiModelli").appendChild(node);

		var objClassiModelli = getClassiModelli(valClasseIscriz);

		console.log("openClassiModelliPopup - objClassiModelli: " + objClassiModelli);
		if (Array.isArray(objClassiModelli) && objClassiModelli.length) {
			for (let modello of objClassiModelli) {
				console.log("openClassiModelliPopup - modello: " + modello);
				getDomClassiModelli(modello, flagEditable);
			}

			addClassiModelliButtons(flagEditable, objClassiModelliIscrizButton);
		}
		else {
			alert("Non ci sono modelli per le classi selezionate");
			closeDrawer();
		}

		return;
	}

	var res = window.open('about:blank', 'popUpClassiModelli', 'toolbar=no,location=no,directories=no,status=no,title=Gerarchico,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,height=690,width=800');

	try {
		res.document.write(`<div class="iframeRightAreaContain"><div class="iframeRightArea" name="popUpClassiModelli" id="popUpClassiModelli"></div></div>`);

		// FIXME Funziona fino al focus, ma le function richiamate al loro interno fanno riferimento alla finestra sbagliata
		// Da rifattorizzare riportando in finestra informazione se si è in modale o nuova finestra
		// Inoltre, mancano css e script

		var objModelliHiddenId = res.document.createElement('input');
		objModelliHiddenId.setAttribute('type', 'hidden');
		objModelliHiddenId.setAttribute('name', 'objModelliHiddenId');
		objModelliHiddenId.setAttribute('id', 'objModelliHiddenId');
		objModelliHiddenId.setAttribute('value', res.opener.document.getElementById(objClassiModelliIscrizHidden).id);
		res.document.getElementById("popUpClassiModelli").appendChild(objModelliHiddenId);

		var node = res.document.createElement('div');
		node.setAttribute('id', 'modelliNodes');
		node.setAttribute('class', 'main-div');
		res.document.getElementById("popUpClassiModelli").appendChild(node);

		res.focus();

		var objClassiModelli = getClassiModelli(valClasseIscriz);

		if (objClassiModelli) {
			for (let modello of objClassiModelli) {
				getDomClassiModelli(modello, flagEditable);
			}

			addClassiModelliButtons(flagEditable, objClassiModelliIscrizButton);
		}
		else {
			alert("Non ci sono modelli per le classi selezionate");
			res.close();
		}
	}
	catch (e) {
	}
}

function getClassiModelli(valClasseIscriz) {
	var retVal = "";
	console.log(constModelliHost + "/GetDBContent.asp?Stored_SQL=SP_GET_MODELLI&Parametro=" + encodeURIComponent(valClasseIscriz));
	try {
		var xhttp = new XMLHttpRequest();
		xhttp.open("GET", constModelliHost + "/GetDBContent.asp?Stored_SQL=SP_GET_MODELLI&Parametro=" + encodeURIComponent(valClasseIscriz), false);
		xhttp.send();
		if (xhttp.readyState == 4 && xhttp.status == 200) {
			var response = JSON.parse(xhttp.responseText);
			console.log("getClassiModelli - response: " + response);
			if (response) {
				if (response[0].id === 'Errore') {
					retVal = [];
				}
				else {
					retVal = response[0].elenco_modelli.split(constClassiSeparator).slice(1, -1);
				}
			}
		}
	} catch (err) {
		console.log("getClassiModelli - ERRORE: " + err.message);
	}
	console.log("getClassiModelli - retVal: " + retVal);
	return retVal;
}

function getDomClassiModelli(modello, flagEditable) {
	if (modello) {
		console.log(constModelliHost + "/GetDBContent.asp?Stored_SQL=ADD_INFO_DESCRIZIONE_MODELLO&Parametro=" + encodeURIComponent(modello));
		try {
			var xhttp = new XMLHttpRequest();
			xhttp.open("GET", constModelliHost + "/GetDBContent.asp?Stored_SQL=ADD_INFO_DESCRIZIONE_MODELLO&Parametro=" + encodeURIComponent(modello), false);
			xhttp.send();
			if (xhttp.readyState == 4 && xhttp.status == 200) {
				let nodeModelloDesc = document.createElement('div');
				nodeModelloDesc.setAttribute('class', 'main-div');
				var responseDesc = xhttp.responseText;
				console.log("getDomClassiModelli - responseDesc: " + responseDesc);
				if (responseDesc) {
					responseDesc = JSON.parse(responseDesc);
					console.log("getDomClassiModelli - responseDesc: " + responseDesc);
					if (responseDesc) {
						for (let desc of responseDesc) {
							console.log("getDomClassiModelli - desc.DMV_DescML: " + desc.DMV_DescML);
							nodeModelloDesc.innerHTML = nodeModelloDesc.innerHTML + "<p>" + desc.DMV_DescML + "</p>";
						}
						document.getElementById("modelliNodes").appendChild(nodeModelloDesc);
					}
				}
			}
		} catch (err) {
			console.log("getDomClassiModelli - ERRORE: " + err.message);
		}

		var valModelloHidden = getModelloHidden(modello);

		console.log(constModelliHost + "/GetHtmlModello.asp?NomeModello=INFO_ADD_" + encodeURIComponent(modello) + "_MOD_Modello&VALORI=" + encodeURIComponent(valModelloHidden) + "&READONLY=" + flagEditable + "&SEC_FIELD=YES");
		try {
			var xhttp = new XMLHttpRequest();
			xhttp = new XMLHttpRequest();
			xhttp.open("GET", constModelliHost + "/GetHtmlModello.asp?NomeModello=INFO_ADD_" + encodeURIComponent(modello) + "_MOD_Modello&VALORI=" + encodeURIComponent(valModelloHidden) + "&READONLY=" + flagEditable + "&SEC_FIELD=YES", false);
			xhttp.send();
			if (xhttp.readyState == 4 && xhttp.status == 200) {
				var nodeModello = document.createElement('div');
				nodeModello.setAttribute('id', modello);
				nodeModello.setAttribute('name', 'div-modello');
				nodeModello.innerHTML = ReplaceExtended(xhttp.responseText, 'openHierarchyPopup(', 'openHierarchyPopupWin(');
				document.getElementById("modelliNodes").appendChild(nodeModello);
			}

			let nodeHr = document.createElement('div');
			nodeHr.setAttribute('class', 'main-div');
			nodeHr.innerHTML = "<hr>";
			document.getElementById("modelliNodes").appendChild(nodeHr);
		} catch (err) {
			console.log("getDomClassiModelli - ERRORE: " + err.message);
		}
	}
}

function getModelloHidden(modello) {
	var valClassiModelliIscrizHidden = document.getElementById(document.getElementById('objModelliHiddenId').value).value;
	console.log("getModelloHidden - valClassiModelliIscrizHidden: " + valClassiModelliIscrizHidden);

	// var valClassiModelliIscrizHidden = "Modello1~~~nomeInput1=valoreInput1~~~nomeinput2=nomeinput2|||Modello7~~~nomeInput4=valoreInput4~~~nomeinput5=nomeinput5";

	valModelliSaved = valClassiModelliIscrizHidden.split(constModelliSeparator);
	for (let valModelloSaved of valModelliSaved) {
		if (valModelloSaved.startsWith(modello)) {
			return valModelloSaved.substring(modello.length + constValoriModelliSeparator.length);
		}
	}
	return "";
}

function addClassiModelliButtons(flagEditable, objClassiModelliIscrizButton) {
	var node = document.createElement('div');
	node.setAttribute('class', 'div_pulsanti_finestra');

	if (flagEditable) {
		var objConfermaButton = document.createElement('input');
		objConfermaButton.setAttribute('type', 'button');
		objConfermaButton.setAttribute('value', 'Conferma');
		objConfermaButton.setAttribute('class', 'button-grafica');
		objConfermaButton.setAttribute('alt', 'Conferma');
		objConfermaButton.setAttribute('onclick', 'confermaPopUpClassiModelli("' + objClassiModelliIscrizButton + '");');
		node.appendChild(objConfermaButton);

		var objSvuotaButton = document.createElement('input');
		objSvuotaButton.setAttribute('type', 'button');
		objSvuotaButton.setAttribute('value', 'Svuota');
		objSvuotaButton.setAttribute('class', 'button-grafica');
		objSvuotaButton.setAttribute('alt', 'Svuota');
		objSvuotaButton.setAttribute('onclick', 'svuotaPopUpClassiModelli("' + objClassiModelliIscrizButton + '");');
		node.appendChild(objSvuotaButton);
	}

	var objAnnullaButton = document.createElement('input');
	objAnnullaButton.setAttribute('type', 'button');
	objAnnullaButton.setAttribute('value', 'Annulla');
	objAnnullaButton.setAttribute('class', 'button-grafica');
	objAnnullaButton.setAttribute('alt', 'Annulla');
	objAnnullaButton.setAttribute('onclick', 'annullaPopUpClassiModelli();');
	node.appendChild(objAnnullaButton);

	document.getElementById("popUpClassiModelli").appendChild(node);
}

function annullaPopUpClassiModelli() {
	try {
		if (typeof window.parent.isFaseII !== 'undefined' && window.parent.isFaseII) {
			window.parent.closeDrawer();
			return;
		}
	} catch (e) { }

	try {
		window.close();
	}
	catch (e) { }
}

function confermaPopUpClassiModelli(objClassiModelliIscrizButton) {
	var valModelliHidden = "";

	const valModelliForm = document.getElementById("modelliNodes").querySelectorAll('[name="div-modello"]');

	for (let valModelloForm of valModelliForm) {
		valModelliHidden = valModelliHidden + constModelliSeparator + valModelloForm.id;
		var valModelloChildren = valModelloForm.querySelectorAll("input:not([id*=_extraAttrib]):not([id*=_edit]):not([id*=_new]):not([id*=_button]), select:not([id*=_extraAttrib]):not([id*=_edit]):not([id*=_new]):not([id*=_button]), textarea:not([id*=_extraAttrib]):not([id*=_edit]):not([id*=_new]):not([id*=_button])");
		for (let valModelloChild of valModelloChildren) {
			if (valModelloChild.value) {
				valModelliHidden = valModelliHidden + constValoriModelliSeparator + ReplaceExtended(valModelloChild.id, 'RINFO_ADD_' + valModelloForm.id + '_MOD_Modello_MODEL_', '') + "=" + valModelloChild.value;
			}
		}
	}

	document.getElementById(document.getElementById('objModelliHiddenId').value).value = valModelliHidden.substring(constModelliSeparator.length);
	setModelliButtonStyleByStatus(objClassiModelliIscrizButton, 'active');
	annullaPopUpClassiModelli();
}

function svuotaPopUpClassiModelli(objClassiModelliIscrizButton) {
	document.getElementById(document.getElementById('objModelliHiddenId').value).value = "";
	setModelliButtonStyleByStatus(objClassiModelliIscrizButton, 'enabled');
	annullaPopUpClassiModelli();
}
