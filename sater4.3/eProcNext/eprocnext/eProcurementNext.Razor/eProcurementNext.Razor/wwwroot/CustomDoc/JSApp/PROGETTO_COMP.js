function TipoGara (param){
	
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
  

	if (getObj( 'ProtocolloBando' ).value==''){
		alert('inserire Ufficio Appalti Referente')
		return false;
	}
		
	
	
	var IDDOC = getObj( 'IDDOC' ).value;
	
	strUrl=vet[0] + '&IDDOC='+IDDOC;
	
	
	ExecFunction(  strUrl  , vet[1] , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
	
	
}





function GetProtocolloBando()
{

	if (getObj('protocollobando').value=='')	
		//-- richiama il processo del burc per evitare che si generino incoerenze
		ExecDocProcess( 'GETPROTOCOLLO,PROGETTO_COMP,,NO_MSG' );

}


function NewDocFromTipoProcedura(param)
{
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
  
	if (getObj( 'ProtocolloBando' ).value==''){
		alert('inserire Ufficio Appalti Referente')
		return false;
	}

	//se tipo procedura=ristretta apro un documento altrimenti un altro

	if (getObj('val_TipoProcedura').value=='3')
		vet[0]=vet[0] + '&DOCUMENT=PROGETTO_COMP_DATE' ;
	else
		vet[0]=vet[0] + '&DOCUMENT=PROGETTO_COMP_DATE1' ;	
	
	vet[0]=vet[0] + '&IDDOC=' + getObj( 'IDDOC' ).value;		


	ExecFunction(  vet[0]  , vet[1] , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );

}


function CreaBandoTradizionale(param){

   var idRow;
   var vet;
   var altro;
   var strUrl;	
		
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
  
	
   var IDDOC = getObj( 'IDDOC' ).value;
	
   
   strSql='select iddoc,Attach from  view_progetti_attidigara where iddoc = ' + IDDOC ;
	
   strSqltestata='select left(peg,charindex(\'%23~%23\', peg)-1 ) as DirezioneProponente, numdetermina as NumeroIndizione,  convert(varchar(10), datadetermina, 121) as DataIndizione, oggetto as Object,IdProgetto,ProtocolloBando,case criterioaggiudicazione when 1 then 15531 else 15532 end as CriterioAggiudicazioneGara,importo as ImportoBaseAsta, case tipologia when 1 then 15495 when 3 then 15494 end  as tipoappalto,TipoProcedura as ProceduraGaraTradizionale, 16307 as ModalitadiPartecipazione ' ;
   

	//strUrl='NewGenDoc.asp?SQLPRODOTTI=' + strSql + '&PARAM=' + idRow + ';4275;1;1;BANDO;SHOW;'
   
   //recupero campo per discriminare tra vecchie procedure e nuove procedure
   var ProceduraScelta='1';
   ProceduraScelta = GetProperty(getObj('val_ProceduraScelta'),'value') ;
   
   //recupero tipoprocedura
   var TipoProcedura='';
   TipoProcedura = GetProperty(getObj('val_TipoProcedura'),'value') ;
   
   if (ProceduraScelta == '1'){
   
      idRow= '179;4842;1;1;BANDO;SHOW;';
      
      //aggiungo anche la descrizione per gli allegati
      strSql='select iddoc,DescrAttach,Attach from  view_progetti_attidigara where iddoc = ' + IDDOC ;
      
   }else{
     
     idRow= '167;4784;1;1;BANDO;SHOW;';
    
     switch ( TipoProcedura ){
            
            case '1':	
                     //aperta tradizionale 
                      strSqltestata= strSqltestata + ', 2 as TipoBando, 15476 as ProceduraGara , ReferenteUffAppalti as UtenteIncaricato ';
                      break;
            case '3':	
                     //ristretta tradizionale
                     strSqltestata= strSqltestata + ', 2 as TipoBando, 15477 as ProceduraGara , ReferenteUffAppalti as UtenteIncaricato ';
                     break;
                     
            case '7':
                     //in economia tradizionale
                     strSqltestata= strSqltestata + ', 1 as TipoBando , 15475 as ProceduraGara , ReferenteUffAppalti as UtenteIncaricato ';
                     break;
            case '9':	
                     //negoziata tradizionale
                     strSqltestata= strSqltestata + ', 1 as TipoBando, 15478 as ProceduraGara  , ReferenteUffAppalti as UtenteIncaricato ';

                     
      }
    
   }
   
   strSqltestata= strSqltestata + ' from  document_progetti where idprogetto =' + IDDOC ;
   
   strUrl='../../dashboard/NewGenDoc.asp?FieldForNameDoc=ProtocolloBando;bando n.&SQLTESTATA=' + strSqltestata + '&SQLPRODOTTI=' + strSql + '&PARAM=' + idRow ;
   
  
   ExecFunction(  strUrl , 'NEWGENDOC' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );

}


function CreaBandoTelematico(param){

   var idRow;
   var vet;
   var altro;
   var strUrl;	
		
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
  
	
    var IDDOC = getObj( 'IDDOC' ).value;
	
	
	 	if (getObj( 'ProtocolloBando' ).value==''){
		  alert('inserire Ufficio Appalti Referente')
		  return false;
	  }
   
   strSql='select iddoc,Attach from  view_progetti_attidigara where iddoc = ' + IDDOC ;
	
   strSqltestata='select left(peg,charindex(\'%23~%23\', peg)-1 ) as DirezioneProponente, numdetermina as NumeroIndizione,  convert(varchar(10), datadetermina, 121) as DataIndizione,  oggetto as Object,IdProgetto,ProtocolloBando,case criterioaggiudicazione when 1 then 15531 else 15532 end as CriterioAggiudicazioneGara,importo as ImportoBaseAsta, case tipologia when 1 then 15495 when 3 then 15494 end  as tipoappalto,TipoProcedura as ProceduraGaraTradizionale';
  
   //recupero tipoprocedura
   var TipoProcedura='';
   TipoProcedura = GetProperty(getObj('val_TipoProcedura'),'value') ;

	 //recupero campo per discriminare tra vecchie procedure e nuove procedure
   var ProceduraScelta='1';
   ProceduraScelta = GetProperty(getObj('val_ProceduraScelta'),'value') ;
   
   //alert('TipoProcedura=' + TipoProcedura + ' - ProceduraScelta=' + ProceduraScelta );
   
   if (ProceduraScelta == '1'){
      
      //vecchie procedure
      
      //recupero anche la descrizione per gli allegati
      strSql='select iddoc,DescrAttach,Attach from  view_progetti_attidigara where iddoc = ' + IDDOC ;
      
         
      switch ( TipoProcedura ){
            
            case '2':	
                     //asta telematica (55,78)
                    idRow='78;4303;2;0;BANDO;SHOW;';
                    break;
                    
            case '4':	
                     //telematica aperta (55,24)
                     idRow='24;4275;1;1;BANDO;SHOW;';
                     break;
                     
            case '5':
                     //telematica in economica (55,48)	
                     idRow='48;4405;1;1;PRODUCTS3;SHOW;';
                     break;
            case '6':	
                     //telematica ristretta (55,34)
                     idRow='34;4303;1;1;BANDO;SHOW;';
                     break;
            case '8':	
                     //richeista preventivi (55,68)
                     idRow='68;4303;3;0;BANDO;SHOW;';
                     break;
            case '10':	
                     //telematica negoziata (55,48)
                     idRow='48;4405;1;1;PRODUCTS3;SHOW;';
                     
      }
        
   }else{
      
      strSqltestata= strSqltestata + ', 16308 as ModalitadiPartecipazione '; 
      
      switch ( TipoProcedura ){ 
            case '2':	
                     //asta telematica (55,78)
                    idRow='78;4303;2;0;BANDO;SHOW;';
                    break;
            case '4':	
                     //telematica aperta (55,24)
                     idRow='167;4784;1;1;BANDO;SHOW;';
                     strSqltestata= strSqltestata + ', 2 as TipoBando, 15476 as ProceduraGara , ReferenteUffAppalti as UtenteIncaricato ';
                     break;
            case '5':
                     //telematica in economica (55,48)	
                     idRow='167;4784;1;1;BANDO;SHOW;';
                     strSqltestata= strSqltestata + ', 1 as TipoBando , 15475 as ProceduraGara , ReferenteUffAppalti as UtenteIncaricato ';
                     break;
            case '6':	
                     //telematica ristretta (55,34)
					 strSqltestata= strSqltestata + ', 2 as TipoBando, 15477 as ProceduraGara  , ReferenteUffAppalti as UtenteIncaricato ' ;
                     idRow='167;4784;1;1;BANDO;SHOW;';
                     break;
            case '8':	
                     //richeista preventivi (55,68)
                     idRow='68;4303;3;0;BANDO;SHOW;';
                     break;
            case '10':	
                     //telematica negoziata (55,48)
                     idRow='167;4784;1;1;BANDO;SHOW;';
                     strSqltestata= strSqltestata + ', 1 as TipoBando, 15478 as ProceduraGara  , ReferenteUffAppalti as UtenteIncaricato ';
                     
      }   
   }
   
   
   
   //completo la query per la testata
   strSqltestata= strSqltestata +  ' from  document_progetti where idprogetto =' + IDDOC ;
   
   //alert (strSqltestata);
   strUrl='../../dashboard/NewGenDoc.asp?FieldForNameDoc=ProtocolloBando;bando n.&SQLTESTATA=' + strSqltestata + '&SQLPRODOTTI=' + strSql + '&PARAM=' + idRow ;

   ExecFunction(  strUrl , 'NEWGENDOC' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );

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

function ApriInvito (param){
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