//--Versione=2&data=2012-06-28&Attivita=38848&Nominativo=Sabato

//-- chiamata sul form di add per aggiornare automaticamente il form 
function OnChangeClassDettagli()
{
	//-- prende la nuova merceologia ed invoca il ricaricamento della pagina
	
	self.location = 'sec_Dettagli.asp?' + getObj( 'RQS' ).value + '&' + getObj('FIELD_CLASS').value + '=' + getObj( getObj('FIELD_CLASS').value ).value;


}

//-- invocata dalla griglia per portare un articolo nell'area di update
function DettagliUpd( grid , r , c )
{
	//debugger;
	
	var AddName = getObj( 'DETTAGLI_AREA_ADD' ).value;
	var URL = getObj( 'DETTAGLI_AREA_ADD_URL_UPD' ).value;
	/*
	var iframeAdd = getObj( AddName );
	
	iframeAdd.location = 'sec_Dettagli.asp?IDROW=' + r + '&' + getObjPage( 'RQS', AddName ).value + '&' + getObjPage('FIELD_CLASS',AddName).value + '=' + getObjPage( getObjPage('FIELD_CLASS',AddName).value ,AddName).value;
	*/
	
	ExecFunction( URL + '&IDROW=' + r  ,AddName , '' );

}

//-- invocata dalla griglia per la paginazione
//-- questa funzione è stata spostata nella classe che disegna la sezionem qui è rimasta solo per tamponare un problema senza reinstallare

function DettagliGoPage( strPage , target )
{
	var sec = getObj( 'PRODOTTIGrid' + '_SECTION_DETTAGLI_NAME' ).value;
	
	ExecDocCommand( sec + '#PAGINAZIONE#saltopagina=ok' + strPage);

	ShowLoading( sec );
}

function ShowLoading( sec )
{
	getObj( 'div_' + sec + 'Grid' ).innerHTML = '<table class="Grid" width="100%" ><tr><td  class="Grid_RowCaption">Loading ...</td></tr></table>';
	//getObj( 'div_' + sec + 'Grid' ).innerHTML = 'Loading ...';
}

//-- invocata dalla griglia per rimuovere un articolo
function DettagliDel( grid , r , c )
{
	var sec = getObj( grid + '_SECTION_DETTAGLI_NAME' ).value;
	ExecDocCommand( sec + '#DELETE_ROW#' + 'IDROW=' + r );
	ShowLoading( sec );
}


//-- invocata dalla griglia per copiare un riga di articolo
function DettagliCopy( grid , r , c )
{
	var sec = getObj( grid + '_SECTION_DETTAGLI_NAME' ).value;
	ExecDocCommand( sec + '#COPY_ROW#' + 'IDROW=' + r );
	ShowLoading( sec );
}


//-- invocato dalla toolbar per prendere un articolo ad un'altra tabella attraverso una pagina di selezione
function Detail_AddFrom( param )
{

	//-- i parametri sono separati da # e sono in quest'ordine
	//-- 1° - URL da invocare
	//-- 2° - target dell'output
	//-- 3° - Attributi filtro 
	//-- 4° - dimensioni della finestra
	//-- 5° - parametri aggiuntivi da passare alla nuova finestra per una corretta visualizzazione

	var idRow;
	var vet;
	var altro;
	var i;
	
	//debugger;
	
	vet = param.split( '#' );


	//-- recupera le dimensioni della finestra di output
	var w;
	var h;
	var Left;
	var Top;
    
    if( vet.length < 4  )
    {
		w = screen.availWidth;
		h = screen.availHeight;
		Left=0;
		Top=0;
	}
	else    
	{
		var d;
		d = vet[3].split( ',' );
		w = d[0];
		h = d[1];
		Left = (screen.availWidth-w)/2;
		Top  = (screen.availHeight-h)/2;
		
		if( vet.length > 3 )
		{
			altro = vet[4];
		}
	}
	
	//-- prende i campi che compongono il filtro , nel caso manchino blocca l'inserimento
	var strFilter= '';
	var strAttrib;
	var bOR = false;
	try
	{
		//d = JSTrim(vet[2]).split( ',' );
		d = vet[2].trim().split( ',' );
		if ( d.length > 0 )
		{
			for( i = 0 ; i < d.length ; i++ )
			{

				strAttrib = d[i];
				bOR = false;
				if( strAttrib.substr(0,3) == 'or-' ) 
				{
					bOR = true;
					strAttrib = strAttrib.substring(3 , strAttrib.length );
				}
					
				if (  ( getObj( strAttrib ).value.trim()  == '' ) && ( bOR == false ) )
				//if ( ( JSTrim( getObj( strAttrib ).value ) == '' ) && ( bOR == false ) )
				//if (  JSTrim( getObj( strAttrib ).value ) == '' ) 
				{
					//MyAlert( getObj( 'MSG_OBBLIG_FOR_ADD' ).value );
					DMessageBox( '../' , 'E\' necessario selezionare ' + strAttrib  , 'Attenzione' , 2 , 400 , 300 );

					return;
				}
				else
				{
					if( bOR == true ) 
					{
						strFilter = strFilter + ' ( ' + strAttrib + ' = \'\' or '
					
						strFilter = strFilter + ' ' + strAttrib + ' = \'' + getObj( strAttrib ).value +  '\' ) ';
					}
					else
					{
						strFilter = strFilter + ' ' + strAttrib + ' = \'' + getObj( strAttrib ).value +  '\'';
					}
					if(  i < d.length -1 )
					{
						strFilter = strFilter + ' and ' ;
					}
				
				}
			
			}
		}
	} catch( e ){};	
	
  
	
	ExecFunction(  vet[0] + '&FilterHide=' + escape( strFilter )  , vet[1] , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
	


}


function DetailMakeTotal( strSection , objField )
{
	var Totale = 0;
	var i;
	var r;
	var nameField='';
	//debugger;
	
	var numRow = 0;
	
	//-- recupero il numero delle righe presenti sulla griglia
	var Grid = getObj( strSection + 'Grid');
	numRow=Number( GetProperty(Grid,'numrow') );
	
	
	//-- recupera la formula di valutazione
	var strExpression = getObj( strSection + '_TOTAL_EXPRESSION').value;

	
	//-- identifico il numero di riga per cui ricalcolare il totale
	try{ nameField = objField.name; } catch( e ) {
	
		nameField ='';
	}
	
	if ( nameField != '' )
	{
		var riga = nameField.split('_')[0];
		
		riga = riga.replace('R','');
		
		r = Number( riga );

		
		if( r >= 0 && r <= numRow )
		{
			
			//-- effettuo il calcolo del totale sulla riga e lo rimpiazzo nel vettore
			tot = MakeTotalRow( strExpression , r );
			eval(  strSection + '_TotRow[' + riga + '] = ' + tot + ';' );
			
		}
	}
	else
	{
		aler( 'errore nel nome del field???' );
	}
	
	
	//-- sommo tutte le righe
	try
	{ 
		for( i = 0; i <= numRow ; i++ )
		{
			Totale +=  eval(  strSection + '_TotRow[' + i + ']' );
		}
	} catch( e ) {}; 
	
	
	
	//-- aggiorna il campo con il totale
	try
	{  
		
		SetNumericValue( getObj( strSection + '_TOTAL_FIELD').value ,Totale );
	} catch( e ) {}; 

	//-- provo ad eseguire una azione custom di aggiornamenti correlati
	try
	{  
		eval( strSection + '_MakeTotal();' );
	} catch( e ) {}; 
	
}


function MakeTotalRow( strExpression , riga ){
	
	var strMsgErr;
	//debugger;
	var nValueTotal = 0;
	//MyAlert ( strExpression );
	try {	

		//strSECTION_DETAIL = getObj(strNameControl + '_SECTION_DETAIL').value;
		
		//Grid = getObj( strSECTION_DETAIL + 'Grid');
		//nNumRow=parseInt( Grid.numrow );
		
		//if (nNumRow >= 0)
		{
		
			//recupero gli operandi dalla formula
			strTempExpression=strExpression
			
			strTempExpression=LocReplaceExtended(strTempExpression,'(',',');
			strTempExpression=LocReplaceExtended(strTempExpression,')',',');
			strTempExpression=LocReplaceExtended(strTempExpression,'*',',');
			strTempExpression=LocReplaceExtended(strTempExpression,'/',',');
			strTempExpression=LocReplaceExtended(strTempExpression,'+',',');
			strTempExpression=LocReplaceExtended(strTempExpression,'-',',');
			
			aOperandi=strTempExpression.split(',');
			nNumAttrib=aOperandi.length;
			
			//MyAlert( 'numero operandi ' + nNumAttrib );
			
			//recupero la valuta della prima riga della griglia
			nValueTotal=0;
			strMsgErr='';
				
			
			//ciclo sulle righe della griglia
			//for (nIndRrow=0;nIndRrow<=nNumRow;nIndRrow++)
			nIndRrow = riga;
			{
					
				strExpressionRow=strExpression
				nValueTotalRow=0
				
				for (nIndAttrib=0;nIndAttrib<nNumAttrib;nIndAttrib++){
				
					if( aOperandi[nIndAttrib] != '' )
					{
					
						//MyAlert( aOperandi[nIndAttrib] );
						
						//strValueAttrib=GetValueAttrib(nTipoMemAttrib,strNameControl,nPosCol,nIndRrow)
						try
						{
						    strValueAttrib = getObj( 'R' + nIndRrow + '_' + aOperandi[nIndAttrib] ).value;
						    strValueAttrib = strValueAttrib.replace( ',' , '.' );
						    //MyAlert( strValueAttrib );
    						
						    if (strValueAttrib!='')
							    strExpressionRow=LocReplaceExtended(strExpressionRow, aOperandi[nIndAttrib] ,parseFloat(strValueAttrib));
							    
					    } catch (e) {};

					}
				}
					
				strMsgErr = '';			
				try {
					nValueTotalRow=eval(strExpressionRow);
				} catch (e) {
					strMsgErr='errore';
						
				}
				if (strMsgErr=='')	
					nValueTotal=nValueTotal+parseFloat(nValueTotalRow);
				//else
				//	nValueTotal='';

			}
				
			
		}
		/*
		else
		{
			nValueTotal = 0;
		}
		*/
		
		
		
	}
	catch (e){
	}
	
	return nValueTotal;
}

/*-----------------ReplaceExtended---------------------------------------------
DESCRIZIONE: effettua la replace di tutte le occorrenze di una stringa
input:
  strExpression= la stringa in vui fare la replace
  strFind=la stringa da cercare
  strReplace=la stringa da sostituire
		
output: la nuova stringa
*/
function LocReplaceExtended(strExpression,strFind,strReplace){

  while (strExpression.indexOf(strFind)>=0)
  	strExpression=strExpression.replace(strFind,strReplace);
		
  return strExpression;
}


function MyAlert( str )
{
	//alert( str );
}



function  MostraEvidenza( Sez , field )
{
	try
	{
		
		var y;
		var x;
		//var PRODOTTIGrid_StartRow = 0 ;
		//var PRODOTTIGrid_EndRow = 0 ;
		//debugger;
		var Grid = getObj( Sez + 'Grid' );
		var nCol = Grid.rows[0].cells.length;
		
		var Grid_StartRow = eval( Sez + 'Grid_StartRow' );
		var Grid_EndRow = eval( Sez + 'Grid_EndRow' );
		var mod = '';
		var name = '';
		
		for (  y = Grid_StartRow ; y <= Grid_EndRow ; y++ )
		{
			mod = getObj('R' + y + '_' + field ).value;
			
			if( mod != '' )
			{
				for( x = 0 ; x < nCol ; x++ )
				{
					//name = ' ' + getObj( Sez + 'Grid' ).cells[ x ].id.substr( Sez.length + 5 ) + ' ';
					name = ' ' + GetProperty( Grid.rows[0].cells[x] , 'id').substr( Sez.length + 5 ) + ' ';

					if(  mod.indexOf( name ) > -1 )
					{
						Grid.rows[y + 1].cells[x].style.border = "solid 2px red";
					}
					
					//Grid.rows[y + 1].cells[x].style.bordercolor = '#FF0000';
				}
			}
	
		}
	}catch( e ) {};
}




