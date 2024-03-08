window.onload = OnLoadPage; 
window.onchange = OnChangeField;
function OnLoadPage()
{


	DisableField();
	
	FIRMA_OnLoad();

}

//-- disabilita i campi per Altro se non c'è la spunta sul field Altro coerente
function DisableField()
{
	
	//-- cerca tutti i campi 999 e se li trova con la spunta abilta altrimenti disattiva e svuota
	
	$("textarea").each(
		function ( i , e ) 
		{
			var id = this.id; 
			var v = id.split( '_' );
			if ( v[5] == 'ALTRO' )
			{
				var Field = v[0] + '_' + v[1] + '_' + v[2] + '_' + v[3] + '_' + v[4] + '_Radio_999';
				if( getObj( Field ) == undefined )
					Field = v[0] + '_' + v[1] + '_' + v[2] + '_' + v[3] + '_' + v[4] + '_Check_999';

				if( getObj( Field ) == undefined )
				{
					Field = v[0] + '_' + v[1] + '_' + v[2] + '_' + v[3] + '_' + v[4] + '_Dominio_1';
					var c = getObjValue( Field );
					if( c.substring( c.length - 3  ) == '999'  ) //-- per il campo ALTRO è obbligatorio se il dominio ha selezionato altro
					{
						this.disabled = false;
					}
					else
					{
						this.value = '';
						this.disabled = true;
					}
				}
				else
				{
				
					try
					{
						if( getObj( Field ).checked == true )
						{
							this.disabled = false;
						}
						else
						{
							this.value = '';
							this.disabled = true;
							
						}
					}catch(e){};
				}
			}
			
		}
	);
}

//-- applica il concetto dei radio 
function OnChangeField( obj )
{
	// -- 0 , 1 sez 
	// -- 2 Riga
	// -- 3 , 4 Campo
	// -- 5 Tipo 
	// -- 6 Colonna
	
	var v = obj.target.name.split( '_' );
	
	
	if( v[5] == 'Radio' )
	{
		var i = 1
		var Field = v[0] + '_' + v[1] + '_' + v[2] + '_' + v[3] + '_' + v[4] + '_' + v[5] + '_' + i
		while( getObj( Field ) != undefined )
		{
			if( Field == obj.target.name)
				getObj( Field ).checked = true;
			else
				getObj( Field ).checked = false;
			
			i++;
			Field = v[0] + '_' + v[1] + '_' + v[2] + '_' + v[3] + '_' + v[4] + '_' + v[5] + '_' + i
		}

		Field = v[0] + '_' + v[1] + '_' + v[2] + '_' + v[3] + '_' + v[4] + '_' + v[5] + '_999' 
		if( Field == obj.target.name)
			getObj( Field ).checked = true;
		else
			getObj( Field ).checked = false;
		
		
	}
	
	DisableField();
	
	
}

function MySend( param ) 
{
	CheckObblig();
	if ( FlagError == true )
		DMessageBox( '../' , 'Per proseguire e\' necessaria la compilazione di tutti i campi evidenziati' , 'Attenzione' , 1 , 400 , 300 );
	else
		ExecDocProcess( param );
}

var FlagError = false;
function CheckObblig()
{
	
	//-- setto OK  ovunque
	$(":input").each( function ( ) { 
				var id = this.id; 
				var V = id.split( '_' );
				if ( V[0] == 'RSEZ' 
					&& ( V[5] == 'Dominio' || V[5] == 'Check' || V[5] == 'Radio' || V[5] == 'TextArea' || V[5] == 'Testo' ||  V[5] == 'Numero'  ||  V[5] == 'ALTRO' )
					&& V.length == 7
					) 
					TxtOK	( this  );
			}	);	

	FlagError = false;
	
	//-- tutte le aree di testo fatta eccezione altro se non è spuntato altro
	CheckObbligNote();
	
	//-- tutti i numeri
	CheckObbligNumber();
	
	//-- tutti i testi
	CheckObbligText();
	
	//-- i check e i radio devono avere la spunta su almeno uno sulla riga
	CheckObbligCheck();
	
	//-- tutte le liste
	CheckObbligList();
	

	
}

function CheckObbligNote()
{
	$("textarea").each(
		function ( i , e ) 
		{
			var id = this.id; 
			var v = id.split( '_' );
			
			var t = this.value;
			if ( t.trim() == '' && v.length == 7 )
			{
				if ( v[5] == 'ALTRO' )
				{
					var Field = v[0] + '_' + v[1] + '_' + v[2] + '_' + v[3] + '_' + v[4] + '_Radio_999';
					if( getObj( Field ) == undefined )
						Field = v[0] + '_' + v[1] + '_' + v[2] + '_' + v[3] + '_' + v[4] + '_Check_999';
					
					if( getObj( Field ) == undefined )
					{
						Field = v[0] + '_' + v[1] + '_' + v[2] + '_' + v[3] + '_' + v[4] + '_Dominio_1';
						var c = getObjValue( Field );
						if( c.substring( c.length - 3  ) == '999'  ) //-- per il campo ALTRO è obbligatorio se il dominio ha selezionato altro
						{
							TxtErr	( this );
						}
					}
					else
					{
						try
						{
							if( getObj( Field ).checked == true ) //-- per il campo ALTRO è obbligatorio se è spuntato il campo 
							{
								TxtErr	( this );
							}
						}catch(e){};
					}
				}
				else
				{
					TxtErr	( this );
				}
			}
		}
	);	
	
	
}


function CheckObbligText()
{

	
	$(":input").each(
		function ( i , e ) 
		{
			var id = this.id; 
			var v = id.split( '_' );
			var t = this.value;
			if ( t.trim() == '' && v.length == 7  &&  v[5] == 'Testo' )
			{
				
				TxtErr	( this );
			}
		}
	);	
		
}


function CheckObbligNumber()
{
	$(":input").each(
		function ( i , e ) 
		{
			var id = this.id; 
			var v = id.split( '_' );
			var t = this.value;
			if ( t.trim() == '' && v.length == 7  &&  v[5] == 'Numero' )
			{
				
				TxtErr	( this );
			}
		}
	);	
	
}


function CheckObbligList()
{
	$(":input").each(
		function ( i , e ) 
		{
			var id = this.id; 
			var v = id.split( '_' );
			var t = this.value;
			if ( t.trim() == '' && v.length == 7  &&  v[5] == 'Dominio' )
			{
				TxtErr	( this );
			}
		}
	);	
}

function CheckObbligCheck()
{

	$(":input").each(
		function ( i , e ) 
		{
			var id = this.id; 
			var V = id.split( '_' );
			if ( V[0] == 'RSEZ' 
				&& ( V[5] == 'Check' || V[5] == 'Radio' )
				&& V.length == 7
				) 
			{
				if ( CheckRowSelected( this ) == false )
				{
					TxtErr	( this );
				}
			}
		}
	);	
	
}



function CheckRowSelected( obj )
{
	// -- 0 , 1 sez 
	// -- 2 Riga
	// -- 3 , 4 Campo
	// -- 5 Tipo 
	// -- 6 Colonna
	var id = obj.id; 
	var v = id.split( '_' );
	
	
	
	if( v[5] == 'Radio' || v[5] == 'Check' )
	{
		var i = 1
		var Field = v[0] + '_' + v[1] + '_' + v[2] + '_' + v[3] + '_' + v[4] + '_' + v[5] + '_' + i
		while( getObj( Field ) != undefined )
		{
			if( getObj( Field ).checked == true )
				return true;
			
			i++;
			Field = v[0] + '_' + v[1] + '_' + v[2] + '_' + v[3] + '_' + v[4] + '_' + v[5] + '_' + i
		}

		Field = v[0] + '_' + v[1] + '_' + v[2] + '_' + v[3] + '_' + v[4] + '_' + v[5] + '_999' 
		if( getObj( Field ).checked == true )
			return true;
		
		return false;
	}
	
	return true;
	
}

function FIRMA_OnLoad() 
{
    
	try {
			FieldToSign();
		} catch (e) {};

}


function FieldToSign() {

    var Stato = '';
    Stato = getObjValue('StatoFunzionale');

    if ( getObjValue('RichiestaFirma') == 'si' )
	{
		if ((getObjValue('SIGN_LOCK') == '0' || getObjValue('SIGN_LOCK') == '') && (Stato == 'InLavorazione' || Stato == 'Sub-Questionari Completati' || Stato == "")) {
			document.getElementById('generapdf').disabled = false;
			document.getElementById('generapdf').className = "generapdf";
		} else {
			document.getElementById('generapdf').disabled = true;
			document.getElementById('generapdf').className = "generapdfdisabled";
		}


		if ((getObjValue('SIGN_LOCK') != '0' && getObjValue('SIGN_LOCK') != '') && (Stato == 'InLavorazione' || Stato == 'Sub-Questionari Completati')) {
			document.getElementById('editistanza').disabled = false;
			document.getElementById('editistanza').className = "attachpdf";
		} else {
			document.getElementById('editistanza').disabled = true;
			document.getElementById('editistanza').className = "attachpdfdisabled";
		}

		if (getObjValue('SIGN_ATTACH') == '' && (Stato == 'InLavorazione' || Stato == 'Sub-Questionari Completati') && (getObjValue('SIGN_LOCK') != '0' && getObjValue('SIGN_LOCK') != '')) {
			document.getElementById('attachpdf').disabled = false;
			document.getElementById('attachpdf').className = "editistanza";
		} else {
			document.getElementById('attachpdf').disabled = true;
			document.getElementById('attachpdf').className = "editistanzadisabled";
		}
	}
}


function TogliFirma () 
{
	//DMessageBox( '../' , 'Si sta per eliminare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );
	ExecDocProcess( 'SIGN_ERASE,FirmaDigitale');
	
	
}




function GeneraPDF() {
   
	/*
		var EsitoRiga=controlloEsitoRiga();
		if (EsitoRiga == -1)
			return;
		scroll(0, 0);
		
		if ( trim(getObj('Titolo').value) == '' )
		{
			DMessageBox( '../' , 'Prima di Generare il Pdf Compilare il campo Titolo' , 'Attenzione' , 1 , 400 , 300 );
			return;
		}		
		

		PrintPdfSign('URL=/report/QUESTIONARIO_FABBISOGNI.ASP?SIGN=YES');
	*/
}





