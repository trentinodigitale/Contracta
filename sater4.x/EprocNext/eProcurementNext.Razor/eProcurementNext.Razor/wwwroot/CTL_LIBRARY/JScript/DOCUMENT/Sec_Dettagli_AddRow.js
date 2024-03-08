function Sec_Dettagli_AddRow(objGrid, Row, c) {
	var cod;
	var nq;
	var strCommand;
	var testo;

	//-- recupero il codice della riga passata
	cod = GetIdRow(objGrid, Row, 'self');

	try {
		//testo = getObj('R' + Row + '_FNZ_ADD')[0].innerHTML;

		//alert( getObj('R' + Row + '_FNZ_ADD')[0].innerText );
		//alert( testo );

		//testo = testo.replace( 'carrello.GIF' , 'carrellook.GIF');
		//alert( testo );

		//testo = '<table  class="FLbl_Tab" ><tr><td ><img border="0" src="../CTL_Library/images/Domain/../toolbar/carrellook.GIF" ></td><td nowrap class="FLbl_label"  id="R0_FNZ_ADD_label" ></td></tr></table>';
		getObj('R' + Row + '_FNZ_ADD')[0].style.border = "solid 1px black"
	} catch (e) {
	}

	var strDoc;
	strDoc = getObj('DOCUMENT').value;
	v = strDoc.split('.');

	//-- compone il comando per aggiungere la riga
	strCommand = v[0] + '#' + v[1] + '#' + 'IDROW=' + cod + '&TABLEFROMADD=' + v[2];

	//alert( strCommand );

	var obj = parent.opener;

	//-- invoca sulla pagina chiamante l'aggiunta della riga
	if (typeof isFaseII !== 'undefined' && isFaseII)
	{
		if (obj != null && typeof obj !== 'undefined')
		{
			parent.opener.ExecDocCommand(strCommand);
		}
		else
		{
			parent.ExecDocCommand(strCommand);
		}
	}
	else
	{
		parent.opener.ExecDocCommand(strCommand);
	}

	try {
		if (typeof isFaseII !== 'undefined' && isFaseII)
		{
			if (obj != null && typeof obj !== 'undefined')
			{
				var sec = parent.opener.getObj('SECTION_DETTAGLI_NAME').value;
				parent.opener.ShowLoading(sec);
			}
			else
			{
				var sec = parent.getObj('SECTION_DETTAGLI_NAME').value;
				parent.ShowLoading(sec);
			}
		}
		else
		{
			var sec = parent.opener.getObj('SECTION_DETTAGLI_NAME').value;
			parent.opener.ShowLoading(sec);
		}
	} catch (e) { };
}

function Sec_Dettagli_AddSel(objGrid) {
	var cod;
	var nq;
	var strCommand;
	var testo;

	//-- recupero il codice della riga passata
	cod = Grid_GetIdSelectedRow(objGrid);


	var strDoc;
	strDoc = getObj('DOCUMENT').value;
	v = strDoc.split('.');

	//-- compone il comando per aggiungere la riga
	strCommand = v[0] + '#' + v[1] + '#' + 'IDROW=' + cod + '&TABLEFROMADD=' + v[2];

	//alert( strCommand );

	//-- invoca sulla pagina chiamante l'aggiunta della riga
	if (typeof isFaseII !== 'undefined' && isFaseII) {
		parent.ExecDocCommand(strCommand);
	} else {
		parent.opener.ExecDocCommand(strCommand);
	}

	var obj = parent.opener;

	try {
		//var sec = parent.opener.getObj( 'SECTION_DETTAGLI_NAME' ).value;
		if (typeof isFaseII !== 'undefined' && isFaseII)
		{
			if (obj != null && typeof obj !== 'undefined')
			{
				var sec = parent.opener.getObj(v[0].toUpperCase() + 'Grid_SECTION_DETTAGLI_NAME').value;
				parent.opener.ShowLoading(sec);
			}
			else
			{
				var sec = parent.getObj(v[0].toUpperCase() + 'Grid_SECTION_DETTAGLI_NAME').value;
				parent.ShowLoading(sec);
			}
		}
		else
		{
			var sec = parent.opener.getObj(v[0].toUpperCase() + 'Grid_SECTION_DETTAGLI_NAME').value;
			parent.opener.ShowLoading(sec);
		}
	} catch (e) { };
}

//aggiunge le righe risultanti di un viewer con un filtro applicato
function Sec_Dettagli_AddFromFilter(objGrid) {
	var Filter;

	var nq;
	var strCommand;
	var testo;
	var strDoc;


	//-- recupero il codice della riga passata
	//cod = Grid_GetIdSelectedRow( objGrid  );

	//recupero il filtro applicato al viewer
	Filter = getObj('CurFilter').value;


	strDoc = getObj('DOCUMENT').value;
	v = strDoc.split('.');
	//encodeURIComponent
	//-- compone il comando per aggiungere la riga
	strCommand = v[0] + '#' + v[1] + '#' + 'IDROW=&TABLEFROMADD=' + v[2] + '&Filter=' + encodeURIComponent(Filter);

	var obj = parent.opener;

	//-- invoca sulla pagina chiamante l'aggiunta delle righe
	if (typeof isFaseII !== 'undefined' && isFaseII)
	{
		if (obj != null && typeof obj !== 'undefined')
		{
			parent.opener.ExecDocCommand(strCommand);
		}
		else
		{
			parent.ExecDocCommand(strCommand);
		}
	}
	else
	{
		parent.opener.ExecDocCommand(strCommand);
	}

	//abilito il loading sulla sezione destinazione del chiamante
	try {
		if (typeof isFaseII !== 'undefined' && isFaseII)
		{
			if (obj != null && typeof obj !== 'undefined')
			{
				var sec = parent.opener.getObj(v[0].toUpperCase() + 'Grid_SECTION_DETTAGLI_NAME').value;
				parent.opener.ShowLoading(sec);
			}
			else
			{
				var sec = parent.getObj(v[0].toUpperCase() + 'Grid_SECTION_DETTAGLI_NAME').value;
				parent.ShowLoading(sec);
			}
		}
		else
		{
			var sec = parent.opener.getObj(v[0].toUpperCase() + 'Grid_SECTION_DETTAGLI_NAME').value;
			parent.opener.ShowLoading(sec);
		}
	} catch (e) { };
}

