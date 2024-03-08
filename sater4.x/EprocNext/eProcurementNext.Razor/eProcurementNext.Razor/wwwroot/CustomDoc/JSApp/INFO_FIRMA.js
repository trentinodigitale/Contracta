
function DownloadFile()
{
	var hash;
	var idMsg;
	var orderFile;
	var url;
	var nomeFile;
	var ext;
	var tmpVirtualDir;
	
	hash = document.getElementById('ATT_Hash').value;
	idMsg = document.getElementById('attIdMsg').value;
	orderFile = document.getElementById('attOrderFile').value;

	nomeFile  = document.getElementById('nomeFile_V').innerHTML;
	ext = nomeFile.split('.').pop();
	
	tmpVirtualDir = '/Application';

	if ( isSingleWin() )
		tmpVirtualDir = urlPortale;
	
	//Se stiamo nella scheda di un allegato del vecchio documento
	if ( hash == '' || hash == 'NULL')
	{
		url = tmpVirtualDir + '/AFLSupplier/FolderRdoArrivo/Attach.asp?Nf=' + nomeFile + '&fd=' + orderFile + '&id=' + idMsg;
	}
	else
	{
		url = tmpVirtualDir + '/CTL_Library/functions/field/DisplayAttach.ASP?OPERATION=DISPLAY&FIELD=&PATH=&TECHVALUE=' + nomeFile + '*' + ext + '*0*' + hash + '&FORMAT=INT';
	}
	
	ExecFunction( url , 'DownloadAttach' , ',height=200,width=500' );	
}

function VerificaRevoca()
{
	ExecDocProcess( 'VERIFICA_REVOCA,SIGN_VERIFY');
}

function TestRevoca()
{
	try
	{
		//Se non siamo nella versione accessibile
		if ( !isSingleWin() )
		{
			window.resizeTo(850, 750);
			window.focus();
		}
	}
	catch(e)
	{
	}

	var statoFirma = '';

	if ( getObj('statoFirma') )
	{
		statoFirma = getObjValue('statoFirma');
	}
	
	try
	{
		/* Se il dettaglio del certificato fa riferimento ad un importazione massiva di allegati (area note contenente 'Verificato d'ufficio'),
			quindi con record relativo nella tabella certificati fittizio,
			nascondo i bottoni per scaricare i contenuti altrimenti andrebbero in errore 
			oppure se lo stato della firma è PENDING, quindi i controlli sul file non sono ancora avvenuti */
		if ( getObj('Note_V').innerHTML == 'Verificato d\'ufficio' || statoFirma == 'SIGN_PENDING' )
		{
			getObj('cap_downloadBusta').style.display = 'none';
			getObj('downloadBusta_link').style.display = 'none';
			getObj('cap_downloadCertificato').style.display = 'none';
			getObj('downloadCertificato_link').style.display = 'none';
			getObj('cap_downloadSenzaBusta').style.display = 'none';
			getObj('downloadSenzaBusta_link').style.display = 'none';
		}
	}
	catch(e){}

	try
	{
		/* Nascondo il comando di verifica revoca se il file è gia stato controllato con successo */
		/* var rev = document.getElementById('val_isRevoked');
		var val = rev.getAttribute('value'); */

		var val = GetProperty( getObj('val_isRevoked'),'value');
		
		if ( val == '-2' || val == '-1' )
		{
			document.getElementById('verificaRevoca').style.display = 'block';
			document.getElementById('cap_verificaRevoca').style.display = 'block';
		}
		else
		{
			document.getElementById('verificaRevoca').style.display = 'none';
			document.getElementById('cap_verificaRevoca').style.display = 'none';
		}
		
		//Se esiste l'attributo
		if (document.getElementById('val_statoFirma'))
		{
			var statoFirma = GetProperty( getObj('val_statoFirma'), 'value');
			
			if (statoFirma == 'SIGN_NOT_OK')
			{
				document.getElementById('cap_downloadCertificato').style.display = 'none';
				document.getElementById('downloadCertificato').style.display = 'none';
			}
		}

	}
	catch(e)
	{
		alert(e.message);
	}

}

function verificaHashFile()
{
	var fileHash = '';
	var alg = '';
	
	if ( getObj('ATT_FileHash') )
	{
		fileHash = getObjValue('ATT_FileHash');
	}
	
	if ( getObj('ATT_AlgoritmoHash') )
	{
		alg = getObjValue('ATT_AlgoritmoHash');
	}
	
	
	
	
	ExecFunctionCenter('../../filehash.aspx?hash_check=' + fileHash + '&alg=' + alg + '##650,350');
}

function ricaricaFirme()
{
	var fileHash = '';
	
	if ( getObj('ATT_Hash') )
	{
		fileHash = getObjValue('ATT_Hash');
		
		var statoFirma = '';

		if ( getObj('statoFirma') )
		{
			statoFirma = getObjValue('statoFirma');
		}
		
		if ( statoFirma == 'SIGN_PENDING' )
		{
			//Nel caso di sing pending con verifica firme effettuata ( al completamento della verifica postificata viene sganciato l'hash sul record, così da non cancellarlo e di far vincere i nuovi record di verifica )
			if ( fileHash.substring(0, 2) == '--' )
				InfoSignCert( '', fileHash.replace('--','') ,'','','', 'YES');
				//InfoSignCert( path, hash, attIdMsg, attOrderFile, attIdObj, noPath)

		}

	}
	
	
}

function afterProcess( param )
{
    
	if ( param == 'SIGN_PENDING' )
	{
		ricaricaFirme();
	}
}


window.onload=TestRevoca;