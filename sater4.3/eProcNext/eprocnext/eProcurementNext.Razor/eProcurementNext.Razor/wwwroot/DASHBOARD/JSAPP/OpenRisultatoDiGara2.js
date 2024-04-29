//per aprire i risultati di gara lato bandocentrico
function OpenRisultatoDiGara2( objGrid , Row , c )
{
	var cod;
	var nq;
	var protbando;
	
	//-- recupero il codice della riga passata
	cod = prendiElementoDaId('R'+ Row + '_idDocR').value;		
	
	protbando = prendiElementoDaId('R'+ Row + '_ProtocolloBando').value;		
	
	var w;
	var h;
	var Left;
	var Top;
    
	w = screen.availWidth;
	h = screen.availHeight;
	Left=0;
	Top=0;
  
	//var strDoc;
	//strDoc = getObj('DOCUMENT').value;
	if (cod != '0')	
		parent.parent.location='../report/light_RisultatoDiGara_int.asp?PROTOCOLLOBANDO='+ escape(protbando) +'&TYPEDOC=RISULTATODIGARA&MODE=OPEN&IDDOC=' + cod ;
	
}
