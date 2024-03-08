function controlli(param) {
	if (getObj('DOCUMENT_READONLY').value != '1') {
		var err = 0;
		var cod = getObj("IDDOC").value;


		if (getObj('check_criterio_a').checked == false && getObj('check_criterio_b').checked == false) {
			err = 1;
			TxtErr('check_criterio_a');
			TxtErr('check_criterio_b');
		}
		else {
			TxtOK('check_criterio_a');
			TxtOK('check_criterio_b');
		}

		if (err > 0) {

			//DMessageBox( '../' , 'Per proseguire e\' necessaria la compilazione di tutti i campi evidenziati' , 'Attenzione' , 1 , 400 , 300 );
			DMessageBox('../', 'Per proseguire e necessario inserire la motivazione e procedere con la scelta del metodo di calcolo', 'Attenzione', 1, 400, 300);

			return -1;
		}
		else {
			ExecDocProcess(param);
		}
	}
}

// window.onload = campo_not_edit;

function campo_not_edit() {
	// if (getObj('DOCUMENT_READONLY').value != '1' )
	// {
	// if ( getObj( 'check_criterio_e' ).checked == false)
	// {
	// SelectreadOnly( 'Coefficiente_Scelta_Criterio' ,true);
	// }
	// }
	// else
	// {

	// //Se esiste l'input hidden CRITERI_DAL_22_05_2017 nascondo i valori non pertinenti del dominio dei coefficienti
	// //	(questo perchè essendo il modello readonly non filtriamo più i domini e con la format del dominio a radio button escono tutti i valori)

	// if ( getObj('CRITERI_DAL_22_05_2017') )
	// {
	// var criteri = document.getElementsByClassName('DOM_OPT');

	// for (var i = 0; i < criteri.length; i++) 
	// {
	// var innerhtml = criteri[i].innerHTML;

	// if ( innerhtml.indexOf('0,6') == -1 && innerhtml.indexOf('0,7') == -1 && innerhtml.indexOf('0,8') == -1 && innerhtml.indexOf('0,9') == -1 )
	// {
	// criteri[i].style.display = 'none';
	// }
	// }

	// }


	// }

	//ricarica il chiamante dal DB per fargli capire al primo giro che esiste il documento di criterio
	//var linkedDoc = getObjValue('LinkedDoc');
	//var tipoDocChiamante = 'PDA_MICROLOTTI';

	//ReloadDocFromDB( linkedDoc , tipoDocChiamante ) ;	
	//removeDocFromMem(linkedDoc , tipoDocChiamante ) ;	

}

function controlliSorteggioAutomatico(param) {
	if (getObj('DOCUMENT_READONLY').value != '1') {
		if (getObj('check_criterio_a').checked == true || getObj('check_criterio_b').checked == true) {
			DMessageBox('../', 'Nel caso di Sorteggio Automatico non deve essere selezionato alcun metodo di calcolo', 'Attenzione', 1, 400, 300);
		} else {
			ExecDocProcess(param);
		}
	}
}

function ExecDocProcessSorteggioConSceltaUtente(param) {
	controlli(param);
}

function OnChangeMutuamenteEsclusiCheck(obj) {
	var name = obj.name;
	var valore = obj.value;

	if (name == 'check_criterio_a' && valore == '1') {
		getObj('check_criterio_b').checked = false;
	} else if (name == 'check_criterio_b' && valore == '1') {
		getObj('check_criterio_a').checked = false;
	}
	else {
		getObj('check_criterio_a').checked = false;
		getObj('check_criterio_b').checked = false;
	}
}

function ExecDocProcessSorteggioAutomatico(param) {
	controlliSorteggioAutomatico(param);
}