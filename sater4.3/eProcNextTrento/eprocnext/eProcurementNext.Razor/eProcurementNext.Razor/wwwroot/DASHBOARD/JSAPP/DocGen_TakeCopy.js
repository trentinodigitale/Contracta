
//Take_Copy(parent.Tabella.document.deleteform.cont,'Bandi di gara','','167','1','','','1','55','ProtocolBG%3B%23%7EProtocolloOfferta%3B%23%7EIdDoc%3B%23%7EDataAperturaOfferte%3B%23%7EDataPubblicazioneBando%3B%23%7EExpiryDate%3B%23%7EReceivedOff%3B%23%7EAdvancedState%3B0%23%7EStato%3B1')
function DocGen_TakeCopy(descrizione,paginadacaricare,isubtype,npaginarichiesta,campodaord,tipodiord,idmp,itype,strParam)
{
	var altro;

	var cod;
	var nq;





	var idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	var v = idRow.split(  ',' );

	if( idRow == '' )
	{
        alert(CNV('../' ,'Selezionare un elemento'));

		//DMessageBox( '../CTL_Library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
		return;
	}
	
	if( v.length > 1 )
	{
        alert(CNV('../' ,'Selezionare solo un elemento'));
		//DMessageBox( '../CTL_Library/' , 'E\' necessario selezionare solo una riga' , 'Attenzione' , 2 , 400 , 300 );
		return;
	}
	var idmsg = idRow
	
    var const_width=300;
    var const_height=150;
    var sinistra=(screen.width-const_width)/2;
    var alto=(screen.height-const_height)/2;
    //alert('../Functions/CopiaDocumento.asp?IdMsg='+idmsg+'&PaginaDaCaricare='+paginadacaricare+'&Descrizione='+descrizione+'&iSubType='+isubtype+'&nPaginaRichiesta='+npaginarichiesta+'&CampoDaOrd='+campodaord+'&TipoDiOrd='+tipodiord+'&IDMP='+idmp+'&iType='+itype+'&strParam='+strParam,'take_copy','toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=no,copyhistory=no,scrollbars=no,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');			
    var winTake=window.open('../Functions/CopiaDocumento.asp?IdMsg='+idmsg+'&PaginaDaCaricare='+paginadacaricare+'&Descrizione='+descrizione+'&iSubType='+isubtype+'&nPaginaRichiesta='+npaginarichiesta+'&CampoDaOrd='+campodaord+'&TipoDiOrd='+tipodiord+'&IDMP='+idmp+'&iType='+itype+'&strParam='+escape( strParam ) ,'take_copy','toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=no,copyhistory=no,scrollbars=no,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');			
  
	//var strDoc;
	//strDoc = getObj('DOCUMENT').value;
	
	//ExecFunction(  '../CTL_Library/Document/document.asp?JScript=' + documento + '&DOCUMENT=' + documento + '&MODE=CREATEFROM&PARAM=' + docfrom + ',' + idRow , documento + '_DOC_createfrom' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
	
}

/*
function DocGen_TakeCopy(strCeck,descrizione,paginadacaricare,isubtype,npaginarichiesta,campodaord,tipodiord,idmp,itype,strParam)
{
 
	var iNumCeck;
	var iLoop;
	var ContatoreCeck;
	var ContatoreLoop;
	
	if (strCeck != null)
	{
		iNumCeck=strCeck.length;
		ContatoreCeck=0;
		ContatoreLoop=-1;
		if (iNumCeck!=null)
		{
			for (iLoop=0;iLoop<iNumCeck;iLoop++)
			{
				if (strCeck[iLoop].checked)
				{
					ContatoreCeck=ContatoreCeck+1;
					ContatoreLoop=iLoop;
				}
					
			
			}
		}
		else
		{
			if (strCeck.checked)
			{
				ContatoreCeck=ContatoreCeck+1;	
			}
 
		}
	
	
		if (ContatoreCeck==0)
		{
			alert('Selezionare almeno un elemento');
		}
		else
		{
			if (ContatoreCeck>1)
			{
				alert('Selezionare un solo elemento');
			}
			else
			{	
				if (ContatoreLoop != -1)
					idmsg=strCeck[ContatoreLoop].value;
				else
					idmsg=strCeck.value;
	
				//parent.frames[1].location="../../Functions/CopiaDocumento.asp?IdMsg="+idmsg+"&PaginaDaCaricare="+paginadacaricare+"&Descrizione="+descrizione+"&iSubType="+isubtype+"&nPaginaRichiesta="+npaginarichiesta+"&CampoDaOrd="+campodaord+"&TipoDiOrd="+tipodiord+"&IDMP="+idmp+"&iType="+itype;
				const_width=300;
				const_height=150;
				sinistra=(screen.width-const_width)/2;
				alto=(screen.height-const_height)/2;
				winTake=window.open('../../Functions/CopiaDocumento.asp?IdMsg='+idmsg+'&PaginaDaCaricare='+paginadacaricare+'&Descrizione='+descrizione+'&iSubType='+isubtype+'&nPaginaRichiesta='+npaginarichiesta+'&CampoDaOrd='+campodaord+'&TipoDiOrd='+tipodiord+'&IDMP='+idmp+'&iType='+itype+'&strParam='+strParam,'take_copy','toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=no,copyhistory=no,scrollbars=no,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');			
			}		
		}
		
	}		
}
*/