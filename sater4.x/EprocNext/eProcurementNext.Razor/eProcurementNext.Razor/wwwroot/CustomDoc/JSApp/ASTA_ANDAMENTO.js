
window.onload = ON_Load;

var myInterval;

function ON_Load(obj) 
{

  
  
	//-- avvia l'aggiornamento dell'asta
	myInterval = setInterval( DisplayAvanzamentoAsta , 1000);
	 
	DisplayAvanzamentoAsta();
	 
	
	//SE NON OEPV e non costofisso NASCONDO PUNT TECNICO,PUNT ECONOMICO
	if ( getObj('CriterioAggiudicazioneGara').value != '15532' &&  getObj('CriterioAggiudicazioneGara').value != '25532' )
	{
    ShowCol( 'RIEPILOGO_FINALE' , 'PunteggioTecnico' , 'none' );
    ShowCol( 'RIEPILOGO_FINALE' , 'PunteggioEconomico' , 'none' );
    ShowCol( 'RIEPILOGO_FINALE' , 'ValoreOfferta' , 'none' );
  }
	
	if ( getObj('TipoAsta').value != 'TA_Sconto')
	{
    ShowCol( 'RIEPILOGO_FINALE' , 'ValoreOffertaSconto' , 'none' );
  }
  
  //per i fornitori che non hanno presentato rilanci tolgo la lente per il dettaglio e il rank
  var num_row = GetProperty( getObj('RIEPILOGO_FINALEGrid') , 'numrow') ;
  
  
  for ( t=0; t< num_row+1; t++ )
	{
  	 
  	 if ( getObjValue('RIEPILOGO_FINALEGrid_idRow_' + t) == '0' ){ 
  	   getObj('RIEPILOGO_FINALEGrid_r' + t + '_c0').innerHTML='';
  	   getObj('RIEPILOGO_FINALEGrid_r' + t + '_c2').innerHTML='';
  	 }
  }
  
  
}

function DisplayAvanzamentoAsta()
{
	//-- invoca la pagina che restituisce l'avanzamento

	var nocache = new Date().getTime();
	ajax = GetXMLHttpRequest();

	if(ajax)
	{
			ajax.open("GET", 'ElencoRilanci.asp?DOCUMENT=BANDO_ASTA&IDDOC=' + getObjValue('IDDOC') + '&nocache=' + nocache, true);
			ajax.onreadystatechange = function() 
			{
				if(ajax.readyState == 4) {
					if(ajax.status == 200)
					{
						DisplayRilanci(   ajax.responseText  );
					}
				}
			}
			ajax.send(null);
		return true;
	}
	return false;
	
	
}

function DisplayRilanci(  dati  )
{
	
	eval( dati );
	
	
  if ( VarStatoAsta == 'Chiusa' || VarStatoAsta == 'AggiudicazioneDef'  || VarStatoAsta == 'AggiudicazioneProvv' || VarStatoAsta == 'AggiudicazioneCond' )
	{
		clearInterval( myInterval );
	}
	
	var TabRilanci = '<table class="Grid"  id="RilanciGrid"  width="300"  cellspacing="0" cellpadding="0" >';
	TabRilanci += '<tr><th class=" nowrap  access_width_10 Grid_RowCaption" >Data Ricezione</th><th class=" nowrap  access_width_10 Grid_RowCaption" >Fornitore</th><th class=" nowrap  access_width_10 Grid_RowCaption" >Valore Offerta</th></tr>';

	var r = 1;
	for ( i = 0 ; i < NumeroRilanci ; i++ )
	{
		if ( r == 0 ) 
			r = 1;
		else
			r = 0;
		
		var sel = '';
		if ( VarRilanci[i][2] == 'BLUE' )
			sel = '_Sel'
		
		TabRilanci += '<tr id="PRODOTTIGridR0" class="GR' + r + sel + '"  ><td id="PRODOTTIGrid_r0_c0"  class="GR0_Text nowrap"  >' + VarRilanci[i][0] + '</td><td id="PRODOTTIGrid_r0_c0"  class="GR0_Text nowrap"  >' + VarRilanci[i][2] + '</td><td id="PRODOTTIGrid_r0_c0"  class="GR0_Text nowrap"  >' + VarRilanci[i][1] + '</td>';
	}
	
	TabRilanci += '</tr></table>';
	
	getObj( 'RilanciGrid').outerHTML = TabRilanci;
	
	if ( VarResiduo > 60  )
	{
		varSecondi = VarResiduo - (Math.floor( VarResiduo / 60 ) * 60 );
		VarResiduo = Math.floor( VarResiduo / 60 );
		getObj( 'Cell_Residuo' ).innerHTML = '<span style="font-size:2em" class="nowrap" >' + VarResiduo + ' Minuti ' + varSecondi + ' Secondi</span>';
	}
	else
	if ( VarResiduo < 0  || VarStatoAsta == 'Chiusa' || VarStatoAsta == 'AggiudicazioneDef' || VarStatoAsta == 'AggiudicazioneProvv' || VarStatoAsta == 'AggiudicazioneCond' )
	{
		getObj( 'Cell_Residuo' ).innerHTML = '<span style="font-size:2em ;color:black" class="nowrap">Tempo terminato</span>'
		getObj('val_StatoAsta').innerHTML = VarStatoAstaCNV  + '<input type="hidden" name="StatoAsta" id="StatoAsta" value="' + VarStatoAsta + '" >';
		getObj('StatoAsta').value = 'Chiusa';

	}
	else
	{
		getObj( 'Cell_Residuo' ).innerHTML = '<span style="font-size:2em ;color:red" class="nowrap" >' + VarResiduo + ' Secondi</span>'
	}
	
	getObj( 'DataScadenzaAsta_L').innerHTML = VarDataScadenzaAsta ;
	
	
	//-- disegno il grafico
	var div = document.getElementById('GRAFICO');
	var container =  document.getElementById('GraphArea');
	var ctx = container.getContext("2d");
	
	
	var W , H ;
	
	W = container.offsetWidth;
	H = container.offsetHeight;
	ctx.save();
//	ctx.scale(1,1);
	ctx.clearRect(0, 0, container.offsetWidth, container.offsetHeight);
	
	DrawGrafico( ctx , W , H );
	
	ctx.restore();
	
	
}
	var SX;
	var SY;
	var PX;
	var PY;

function DrawGrafico( ctx , W , H )
{
	val_TipoAsta = getObjValue( 'val_TipoAsta' );
	if ( val_TipoAsta == 'TA_Prezzo' )
		MaxY =  getObjValue( 'importoBaseAsta' );
	else
		MaxY =  100.0;

	//-------------------------------------------
	//-- Inizializzo le coordinate
	//-------------------------------------------
	SX = 60;
	SY = H - 40;
	PX = ( ( W -SX -20 ) / SecDurataAsta  ) ; // coefficiente di moltiplicazione per le X
	PY = ( ( H - 80 ) / MaxY  ) ;			  // coefficiente di moltiplicazione per le Y
		
	
	
	ctx.globalAlpha = 1;
	ctx.lineWidth = 1;
	


	
	//-------------------------------------------
	//-- disegna un contorno al grafico
	//-------------------------------------------
	ctx.beginPath();
    ctx.strokeStyle = "#000000";
	ctx.strokeRect(1, 1, W-1, H-1);
	ctx.closePath();
	
	
	//-------------------------------------------
	//-- disegno la linea orizzontale per l'andamento tempo
	//-------------------------------------------
	ctx.beginPath();
	ctx.fillStyle = "#CCCCCC";
	ctx.fillRect(1,  SY + 5 , W-1 ,H);
	ctx.closePath();
	

	//-------------------------------------------
	//-- disegno la lineetta della data inizio
	//-------------------------------------------
	ctx.beginPath();
	ctx.strokeStyle = '#000000';
	ctx.moveTo(SX, SY + 5);
	ctx.lineTo(SX , SY + 15 );

	ctx.fillStyle = "#000000";
	ctx.font = "10px Arial";
	ctx.fillText( getObj('DataInizio_L').innerHTML ,SX ,SY  + 25 );


	ctx.stroke();
	ctx.closePath();
	
	
	//-------------------------------------------
	//-- disegno la lineetta della data fine prevista
	//-------------------------------------------
	
	DrawLine( ctx , SecDurataAsta * PX + SX, 40, SecDurataAsta * PX + SX, SY + 15, '#ff0000' , 0 )
	ctx.beginPath();
	//ctx.moveTo(SecDurataAsta * PX + SX, SY + 5);
	//ctx.lineTo(SecDurataAsta * PX + SX, SY + 15 );

	ctx.fillStyle = "#000000";
	ctx.font = "10px Arial";
	ctx.fillText( VarDataScadenzaAsta ,SecDurataAsta * PX  + SX - 100 ,SY + 25);

	ctx.stroke();
	ctx.closePath();
	
	
	
	//-------------------------------------------
	//-- disegno la lineetta della scadenza attuale se diversa dalla iniziale
	//-------------------------------------------
	if( SecDurataAsta != SecDurataOrig )
	{
		//ctx.beginPath();
		//ctx.moveTo(SecDurataOrig * PX + SX, SY + 5);
		//ctx.lineTo(SecDurataOrig * PX + SX, SY + 15 );
		//ctx.stroke();
		//ctx.closePath();
		
		DrawLine( ctx , SecDurataOrig * PX + SX, 40, SecDurataOrig * PX + SX, SY + 15, '#00cccc' , 0 )
	}
	
	
	//-- disegno la linea veriticale dei valori 
	//ctx.moveTo( SX, SY );
	//ctx.lineTo( SX,  10 );
	//ctx.stroke();
	
	
	//-------------------------------------------
	//-- disegno i 10 segmenti discriminando dal minimo al massimo nell'elenco dei valori presenti
	//-------------------------------------------
	
	for ( y = 0 ; y <= MaxY ; y += ( MaxY / 10 ) )
	{
		DrawLine( ctx , SX, SY - (y * PY) , SX + SecDurataAsta * PX, SY -  (y * PY), '#cccccc' , 0 )
		ctx.fillStyle = "#000000";
		ctx.font = "10px Arial";
		ctx.fillText(y,5,SY - (y * PY));
	}
	
	
	//-------------------------------------------
	//-- disegna la base asta
	//-------------------------------------------
	var BY = getObjValue( 'BaseCalcolo' );

	DrawLine( ctx , SX, SY - (BY * PY) , SX + SecDurataAsta * PX , SY -  (BY * PY), '#0000FF' , 3 )
	
	//-------------------------------------------
	//-- disegno il primo punto del grafo
	//-------------------------------------------
	if ( NumeroRilanci > 0 )
		DrawOfferta( ctx , NumeroRilanci -1 );
	

	//-------------------------------------------
	//-- ciclo per tutti i punti del grafo
	//-------------------------------------------
	for( i = NumeroRilanci - 2 ; i >= 0 ; i-- )
	{

		//-- disegno linea di collegamento fra il punto precedente e quello nuovo
		DrawLine( ctx , SX + (VarRilanci[i+1][3] * PX)  , SY - (VarRilanci[i+1][1] * PY ),  SX + (VarRilanci[i][3] * PX)  , SY - (VarRilanci[i][1] * PY) , '#FF0000' , 0 );
		
		//-- disegno il nuovo punto del grafo
		DrawOfferta( ctx , i );
		
	}

		
	//-------------------------------------------
	//-- evidenzio l'offerta migliore
	//-------------------------------------------


	//-------------------------------------------
	//-- disegno la legenda
	//-------------------------------------------
	
	

	
}

function DrawLine( ctx , sx , sy , ex , ey , color , dash )
{
	ctx.beginPath();
	ctx.strokeStyle = color;
	if ( dash > 0 )
	{
		ctx.setLineDash([dash, dash]);
		ctx.lineDashOffset = dash;
	}
	ctx.moveTo( sx, sy );
	ctx.lineTo( ex , ey  );
	ctx.stroke();
	ctx.closePath();
	
}

function DrawOfferta( ctx , i )
{
	var w = 5;
	ctx.beginPath();
    ctx.strokeStyle = "#000000";

	ctx.fillStyle = "#00ff00";
	ctx.fillRect( SX + (VarRilanci[i][3] * PX) -w , SY - (VarRilanci[i][1] * PY) -w  ,    w*2 , w*2 );
	ctx.stroke();
	
	ctx.closePath();
	
	
	
}


function OpenOffertaRilancio( objGrid , Row , c ){
  var cod;
  cod = GetIdRow( objGrid , Row , 'self' );

  if ( cod != 0 )
    OpenDocumentColumn( objGrid , Row , c );
  

}
