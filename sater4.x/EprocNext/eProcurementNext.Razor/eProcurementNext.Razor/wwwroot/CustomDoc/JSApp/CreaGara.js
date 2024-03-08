function CreaGara( strparam )
{
	var IDDOC;
	
	idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	
	if( idRow == '' )
	{
		DMessageBox( '../CTL_Library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
		return;
	}
	
	idRow = idRow.replace( '~~~' , ',')
	
	
	var h;
	var Left;
	var Top;
    
	w = 800; 
	h = 600; 
	Left= (screen.availWidth - 800) / 2;
	Top= (screen.availHeight - 600) / 2;
	
	//recupero iddoc del documento dalla querystring
	var CurQueryString = getObj( 'QueryString' ).value;
	
	vet = CurQueryString.split( '&' );
	
	for (i=0; i < vet.length; i++ ){
		
		vet1=vet[i].split( '=' );
		
		if ( vet1[0] == 'IDDOC') {
			
			IDDOC=vet1[1];
			break;
			
		}
			
	}
	
	strSql='select * from  view_progetti_attidigara where iddoc = ' + IDDOC ;
	//strUrl='NewGenDoc.asp?SQLPRODOTTI=' + strSql + '&PARAM=' + idRow + ';4275;1;1;BANDO;SHOW;'
	//strUrl='NewGenDoc.asp?SQLPRODOTTI=' + strSql + '&PARAM=' + idRow + ';SHOW;'
	//alert(strUrl);
	
	strSqltestata='select oggetto as Object,IdProgetto,ProtocolloBando,case criterioaggiudicazione when 1 then 15531 else 15532 end as CriterioAggiudicazioneGara,importo as ImportoBaseAsta, case tipologia when 1 then 15495 when 3 then 15494 end  as tipoappalto from  document_progetti where idprogetto =' + IDDOC ;

	//strUrl='NewGenDoc.asp?SQLPRODOTTI=' + strSql + '&PARAM=' + idRow + ';4275;1;1;BANDO;SHOW;'
	strUrl='NewGenDoc.asp?FieldForNameDoc=ProtocolloBando;bando n.&SQLTESTATA=' + strSqltestata + '&SQLPRODOTTI=' + strSql + '&PARAM=' + idRow + ';SHOW;'

	ExecFunction(  strUrl , 'NEWGENDOC' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
	
 	top.close();
}


