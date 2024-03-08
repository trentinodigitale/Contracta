

function CreaGaraDGC( strparam )
{
	var IDDOC;
	var Parm;
	
	Parm = '167;4784;1;1;BANDO';
	
	
	var h;
	var Left;
	var Top;
    
	w = 800; 
	h = 600; 
	Left= (screen.availWidth - 800) / 2;
	Top= (screen.availHeight - 600) / 2;
	
	IDDOC = getObj( 'IDDOC' ).value;
	
	strSql='select * from  view_progetti_attidigara_dgc where iddoc = ' + IDDOC ;
	
	strSqltestata='select oggetto as Object,IdProgetto,ProtocolloBando,case criterioaggiudicazione when 1 then 15531 else 15532 end as CriterioAggiudicazioneGara,importo as ImportoBaseAsta, 15496  as tipoappalto, numdetermina as NumeroIndizione,  convert(varchar(10), datadetermina, 121) as DataIndizione , ReferenteUffAppalti as UtenteIncaricato,left(peg,charindex(\'%23~%23\', peg)-1 ) as DirezioneProponente ' ;
    
	
	//recupero tipoprocedura
    var TipoProcedura='';
    TipoProcedura = GetProperty(getObj('val_TipoProcedura'),'value') ;
	
	switch ( TipoProcedura ){ 
		case '2':	
				 //asta telematica (55,78)
				break;
		case '4':	
				 //telematica aperta (55,24)
				 strSqltestata= strSqltestata + ', 2 as TipoBando, 15476 as ProceduraGara  ';
				 break;
		case '5':
				 //telematica in economica (55,48)	
				 strSqltestata= strSqltestata + ', 1 as TipoBando , 15475 as ProceduraGara  ';
				 break;
		case '6':	
				 //telematica ristretta (55,34)
				 strSqltestata= strSqltestata + ', 2 as TipoBando, 15477 as ProceduraGara   ' ;
				 idRow='167;4784;1;1;BANDO;SHOW;';
				 break;
		case '8':	
				 //richeista preventivi (55,68)
				 break;
		case '10':	
				 //telematica negoziata (55,48)
				strSqltestata= strSqltestata + ', 1 as TipoBando, 15478 as ProceduraGara   ';
                     
    } 

	strSqltestata = strSqltestata + ' from  document_progetti where idprogetto =' + IDDOC ;	
	
	
	strUrl='/Application/dashboard/NewGenDoc.asp?FieldForNameDoc=ProtocolloBando;bando n.&SQLTESTATA=' + strSqltestata + '&SQLPRODOTTI=' + strSql + '&PARAM=' + Parm + ';SHOW;'

	ExecFunction(  strUrl , 'NEWGENDOC' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
	
 	top.close();
}

function ApriBando (param){
	var idRow;
	var vet;
	var altro;
	
		
	//debugger;
	vet = param.split( '#' );

	var w;
	var h;
	var Left;
	var Top;
    
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
	var ProtocolloBando = getObj( 'ProtocolloBando' ).value;
	strUrl=vet[0] + 'ProtocolloBando=' + ProtocolloBando ;
	ExecFunction(  strUrl  , vet[1] , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
}

function PopolaLottiProgetto()
{
		ExecDocProcess( 'POPOLALOTTIPROGETTO,PROGETTO_COMP_DGC,,NO_MSG' );
}
