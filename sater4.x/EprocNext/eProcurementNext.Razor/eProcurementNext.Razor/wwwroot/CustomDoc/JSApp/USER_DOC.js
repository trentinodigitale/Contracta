function MySend(param)
{
	//if ( checkCoerenzaCF() == 1 )
	var nRet = 	checkCoerenzaCF( 0 );
	
	if ( nRet == 0 ){
		
		//alert( CNV( '../../' , 'Codice fiscale non coerente con nome e cognome' ) );
		
		//chiedo de voglio continuare oppure no nonostante controllo cf non superato
		var Title = 'Attenzione';
		var ML_text = 'Codice fiscale non coerente con nome e cognome. Vuoi Proseguire ?';
		var ICO = 3;
		var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);
		
		ExecFunctionModaleConfirm( page, null , 200 , 420 , null , 'ExecDocProcess@@@@' + param );
		
	}else{
		ExecDocProcess( param );
	}	
		
	
}


function User_DOC(objGrid , Row , c)
{
	
	var url;
	var idRow;
	var parametri;
	try 
	{
		idRow = getObj( 'R' + Row + '_id').value;
	}
	catch(e){}
	if(idRow == undefined)
	idRow = getObj( 'R' + Row + '_id')[0].value;
	
	parametri='USER_DOC_READONLY#UTENTI#800,600'
	
	var altro;
	
	var cod;
	var nq;
	var idRow;
	
	
	
	var vet;
	var documento;
	var docfrom;
	var only_doc;
	
	vet = parametri.split( '#' );
	documento = vet[0];
	docfrom = vet[1];
	
	
	
	
	if( idRow == '' )
	{
		DMessageBox( '../ctl_library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
		//alert( "E' necessario selezionare prima una riga" );
		return;
	}
	
	var nq;
	
	
	var w;
	var h;
	var Left;
	var Top;
    
	w = screen.availWidth * 0.9;
	h = screen.availHeight  * 0.9;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
	
	if( vet.length < 3  )
    {
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
	
	
	if ( isSingleWin() )
	{
		url = encodeURIComponent('ctl_library/document/document.asp?JScript=' + documento + '&lo=base&DOCUMENT=' + documento + '&MODE=CREATEFROM&PARAM=' + docfrom + ',' + idRow  );
		return ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
	}
	else
	{
		ExecFunction(  '../ctl_library/document/document.asp?JScript=' + documento + '&DOCUMENT=' + documento + '&MODE=CREATEFROM&PARAM=' + docfrom + ',' + idRow , documento + '_DOC_createfrom' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
	}
	
	
	

	
	
}


function OnChange_Default(obj) 
{
	
	var numeroRighe = GetProperty( getObj('RUOLIGrid') , 'numrow');
	
	for( i = 0 ; i <= numeroRighe ; i++ )
	{
		try
		{
			document.getElementsByName( 'RRUOLIGrid_' + i + '_Obbligatorio' )[0].checked=false 
		}
		catch(e)	  {	  }
	}
	
	obj.checked=true;
}

function Onchange_Nome_Cognome ( obj )
{
	var value=obj.value;
    value=value.substring(0,3).toUpperCase();	
	
	SetTextValue('PfuPrefissoProt',value);
	return;
}

//applico il filtro al dominio del responsabile Utente
function filtroResponsabile()
{
		var filter = '';
		var pfulogin='';
		var idpfuInMod = '';
		var i;
		
		var numrighe=GetProperty( getObj('RESPONSABILEGrid') , 'numrow');
		
		try
		{ 
			/*
			pfulogin=getObj('Fascicolo').value   JumpCheck
			if ( pfulogin != '' )
			{
				
				filter = 'SQL_WHERE= pfuidazi = ' + getObj('Azienda').value +' and idpfu<>( Select IdPfu from ProfiliUtente where pfuLogin=\''+ pfulogin +'\' and pfuidazi='+getObj('Azienda').value+ ')';
				
			}
			else
			{
				filter = 'SQL_WHERE= pfuidazi = ' + getObj('Azienda').value;
			}
			
			*/
			
			idpfuInMod = getObjValue('Destinatario_User');
			
			//PER LE MODIFICHE
			if( idpfuInMod != '' && idpfuInMod != '0' )
			{
				filter = 'SQL_WHERE=  idpfu in ( select idpfu from MY_USER_RESPONSABILI where idFrom = ' + idpfuInMod + ' )';
			}
			//SE NUOVO METTO GLI UTENTI DELL'ENTE CHE STO MODIFICANDO
			else if ( getObjValue('JumpCheck') == 'NEW' )
			{
				filter = 'SQL_WHERE=  idpfu in ( select p.idpfu from ProfiliUtente p inner join profiliutenteattrib a on p.idpfu = a.idpfu and dztnome = \'UserRole\' and attvalue in ( \'PO\' , \'RUP\' , \'RUP_PDG\' ) where p.pfudeleted=0 and p.pfuidazi = ' + getObj('Azienda').value + ' )';
			}
				
			if (filter != '')
			{
			//FilterDom(  'pfuResponsabileUtente', 'pfuResponsabileUtente' , getObjValue( 'pfuResponsabileUtente' ), filter , '' , '' );
				
				try
				{
					
					//for( i = 0 ; i < numrighe+1 ; i++ )
					for( i = 0 ; i < 1 ; i++ )
					{
						
						try
						{
							FilterDomFirstRowCol(  'RRESPONSABILEGrid_' + i + '_pfuResponsabileUtente' , 'pfuResponsabileUtente' , getObjValue( 'RRESPONSABILEGrid_' + i + '_pfuResponsabileUtente' ), filter , 'RESPONSABILEGrid_' + i  , '');
						}
						catch(e)
						{
						}

					}
					
				}catch(e){};
				
			}
			
			
		}
		catch(e){};
}



function PROFILI_AFTER_COMMAND ()
{
	Hidecestino();

}

function RESPONSABILE_AFTER_COMMAND ( param )
{
	
	filtroResponsabile();
}

window.onload = ONLoad;

function ONLoad()
{
	//-- nascondo i tab non necessari
	var aziProfili = getObjValue( 'aziProfili' );
	
	try
	{
		if ( getObj('DOCUMENT_READONLY').value != '1' )
			filtroResponsabile();
	}
	catch(e)
	{
	}
	
	if ( aziProfili.indexOf( 'P' ) == -1 )
	{
		DocDisplayFolder(  'RUOLI'   ,'none' );
		DocDisplayFolder(  'RESPONSABILE'   ,'none' );
	}
	
	//-- setto il filtro per i ruoli utente coerente se possibile
	if( getObjValue('Destinatario_User') != '' && getObjValue('Destinatario_User') != '0' )
	{
		if ( getObj( 'pfuRuoloAziendale'  ) )
			FilterDom(  'pfuRuoloAziendale', 'pfuRuoloAziendale' , getObjValue( 'pfuRuoloAziendale'  ), 'SQL_WHERE= DMV_Cod in ( select DMV_Cod from [QualificaPerUtenza] where idpfu = ' + getObjValue('Destinatario_User') + '  ) ' , '', '' );
		
	}
	
	//-- mettoi filtri al tab dei profili
	Hidecestino();

	
		
}


function Hidecestino()
{
	try{
		var aziProfili = getObjValue( 'aziProfili' );
		
		var filter = 'SQL_WHERE= codice in ( select Codice from Profili_Funzionalita where \'' + aziProfili + '\' like \'%\' + aziProfilo + \'%\'  ) '
        var i = 0;
		
			
				for( i=0; i < PROFILIGrid_EndRow+100 ; i++ )
				{
				  try
                                  {
					if( getObj( 'RPROFILIGrid_' + i + '_NotEditable' ).value == ' profilo ' &&  getObj('DOCUMENT_READONLY').value != '1' )
					{
						
						getObj( 'PROFILIGrid_r' + i + '_c0' ).innerHTML = '&nbsp;';
					}
					
					FilterDom(  'RPROFILIGrid_' + i + '_Profilo', 'Profilo' , getObjValue( 'RPROFILIGrid_' + i + '_Profilo' ), filter , 'PROFILIGrid_' + i , '' );
                                  }
                                   catch(e){}
				}
			
		}catch(e){}
  
}

function checkCoerenzaCF( nMakeAlert )
{
	var nome = getObjValue('Nome').replace(/^\s+|\s+$/gm,'');
	var cognome = getObjValue('Cognome').replace(/^\s+|\s+$/gm,'');
	var cf = getObjValue('codicefiscale').replace(/^\s+|\s+$/gm,'');
	
	
	
	var resFunct = 1;
	
	/* Se sono avvalorati tutti i campi utili */
	if ( nome !== '' && cognome !== '' && cf !== '')
	{

		n_Made_Check_CF = '1';
		
		if ( !isMyCF('../../', nome , cognome, cf) )
		{
			resFunct = 0;
			
			if ( nMakeAlert != 0 )
				DMessageBox( '../' , 'Codice fiscale non coerente con nome e cognome' , 'Attenzione' , 1 , 400 , 300 );
			
			TxtErr( 'Nome' );
			TxtErr( 'Cognome' );
			TxtErr( 'codicefiscale' );
		}
		else
		{
			resFunct = 1;
			
			TxtOK( 'Nome' );
			TxtOK( 'Cognome' );
			TxtOK( 'codicefiscale' );
		}

	}
	
	return resFunct;
	
	
	//isMyCF
}
