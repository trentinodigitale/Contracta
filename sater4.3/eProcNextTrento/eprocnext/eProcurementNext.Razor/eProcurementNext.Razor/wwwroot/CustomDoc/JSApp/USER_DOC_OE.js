
/*
function MySend(param)
{
	if ( checkCoerenzaCF() == 1 )
	{
		ExecDocProcess( param );
	}
}
*/


function MySend(param)
{
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
		try{ 
			pfulogin=getObj('Fascicolo').value
			if ( pfulogin != '' )
			{
				
				filter = 'SQL_WHERE= pfuidazi = ' + getObj('Azienda').value +' and idpfu<>( Select IdPfu from ProfiliUtente where pfuLogin=\''+ pfulogin +'\' and pfuidazi='+getObj('Azienda').value+ ')';
				
			}
			else
			{
				filter = 'SQL_WHERE= pfuidazi = ' + getObj('Azienda').value;
			}
			
			FilterDom(  'pfuResponsabileUtente', 'pfuResponsabileUtente' , getObjValue( 'pfuResponsabileUtente' ), filter , '' , '' );
		}
		catch(e){};
}

function checkCoerenzaCF()
{
	var nome = getObjValue('Nome').replace(/^\s+|\s+$/gm,'');
	var cognome = getObjValue('Cognome').replace(/^\s+|\s+$/gm,'');
	var cf = getObjValue('codicefiscale').replace(/^\s+|\s+$/gm,'');
	
	var resFunct = 1;
	
	/* Se sono avvalorati tutti i campi utili */
	if ( nome !== '' && cognome !== '' && cf !== '' )
	{
		if ( !isMyCF('../../', nome , cognome, cf) )
		{
			resFunct = 0;
			
			//if ( nMakeAlert != 0 )
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
}
