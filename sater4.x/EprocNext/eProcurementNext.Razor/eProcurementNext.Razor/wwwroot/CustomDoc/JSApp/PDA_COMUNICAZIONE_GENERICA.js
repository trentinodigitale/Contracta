
function RefreshContent()
{
    RefreshDocument('');
}






function DETTAGLI_OnLoad()
{
  
  /* commentato perchè tolto &JSOnLoad=yes dalla sezione
  if (getObj('StatoDoc').value == 'Saved' ){
    
    //DETTAGLI.location ='../../DASHBOARD/Viewer.asp?ModGriglia=PDA_COMUNICAZIONE_GENERICA_DETTAGLIGriglia&Table=VIEW_PDA_COMUNICAZIONE_DETTAGLI&OWNER=&IDENTITY=ID&TOOLBAR=PDA_COMUNICAZIONE_DETTAGLI_TOOLBAR&PATHTOOLBAR=../customdoc/&JSCRIPT=&AreaFiltro=no&HEIGHT=300,300*,300&FilteredOnly=no&Sort=&SortOrder=&DOCUMENT=PDA_COMUNICAZIONE_GENERICA&FilterHide=statodoc <> \'invalidate\' and LinkedDoc=' + getObj('IDDOC').value + '&AreaAdd=no&ACTIVESEL=2&numRowForPag=20' ; 
    
    //se si tratta di REVOCA nascondo i destinatari
    if ( getObj('JumpCheck').value == '0-REVOCA' || getObj('JumpCheck').value == '0-REVOCA_BANDO' )
      getObj('DivDETTAGLI').style.display='none';
        
  }else{
    //DETTAGLI.location ='../../DASHBOARD/Viewer.asp?ModGriglia=PDA_COMUNICAZIONE_GENERICA_DETTAGLIGriglia&Table=VIEW_PDA_COMUNICAZIONE_DETTAGLI&OWNER=&IDENTITY=ID&TOOLBAR=&PATHTOOLBAR=../customdoc/&JSCRIPT=&AreaFiltro=no&HEIGHT=300,300*,300&FilteredOnly=no&Sort=&CAPTION= Lista Operatori Economici&SortOrder=&DOCUMENT=PDA_COMUNICAZIONE_GENERICA&FilterHide=statodoc <> \'invalidate\' and LinkedDoc=' + getObj('IDDOC').value + '&AreaAdd=no&ACTIVESEL=1&numRowForPag=20' ;
  }
 */
 
	
}

window.onload = InitComunicazione;
SetPositionRecursive( getObj( 'Cell_Note' ) , 'relative' );

function InitComunicazione()
{
  
	var strJumpCheck = getObj('JumpCheck').value;

	var ainfo=strJumpCheck.split('-');
	var strTipoComumnicazione = ainfo[1];

	//nascondo data seduta in caso di revoca
	if ( strTipoComumnicazione == 'SOSPENSIONE_GARA' || strTipoComumnicazione == 'REVOCA' || strTipoComumnicazione == 'GARA_COMUNICAZIONE_GENERICA' || strTipoComumnicazione == 'CONCORSO_COMUNICAZIONE_GENERICA')
	{
		//alert('nascondo data seduta');
		$( "#cap_DataDocumento" ).parent().parent().parent().hide();

	}
	
	if (getObj('VersioneLinkedDoc').value == 'BANDO_GARA-RDO')
	{
		$( "#cap_DataDocumento" ).parents("table:first").css({"display":"none"})
	}
  
	if ( strTipoComumnicazione != 'ESITO_DEFINITIVO_MICROLOTTI' )
	{
		
		try
		{
			$( "#cap_AggiudicazioneCondizionata" ).parent().parent().parent().hide();
	
		}catch( e ){};
	}
	
	try
	{
		HideCestinodoc();
	}
	catch(e)
	{
	}
	
	
  //se jumpcheck diverso da GENERICA 
  if	( strTipoComumnicazione != 'GENERICA' && strTipoComumnicazione != 'BANDO_CONSULTAZIONE_GENERICA'  && strTipoComumnicazione != 'GARA_COMUNICAZIONE_GENERICA' && strTipoComumnicazione != 'PROSSIMA_SEDUTA' && strTipoComumnicazione != 'ESITO_DEFINITIVO_MICROLOTTI'  && strTipoComumnicazione != 'FABBISOGNI_COMUNICAZIONE_GENERICA' && strTipoComumnicazione != 'CONCORSO_COMUNICAZIONE_GENERICA' )
  {    
    //nascondo colonna "Seleziona"
    ShowCol( 'DETTAGLI' , 'Seleziona_Deleted' , 'none' );
    
	//if (strJumpCheck != '1-VERIFICA_REQUISITI' )
	//{
		//nascondo richiesta risposta e data rispondere entro il
		//$( "#cap_RichiestaRisposta").parents("table:first").css({"display":"none"})
		//$( "#cap_DataScadenza").parents("table:first").css({"display":"none"}) 
	//}
	
  }
  
  //se jumpcheck diverso da GENERICA 
  if	( strTipoComumnicazione != 'GENERICA' && strTipoComumnicazione != 'BANDO_CONSULTAZIONE_GENERICA'  && strTipoComumnicazione != 'GARA_COMUNICAZIONE_GENERICA' && strTipoComumnicazione != 'FABBISOGNI_COMUNICAZIONE_GENERICA'  && strTipoComumnicazione != 'CONCORSO_COMUNICAZIONE_GENERICA' )
  {    
    
	if (strJumpCheck != '1-VERIFICA_REQUISITI' )
	{
		//nascondo richiesta risposta e data rispondere entro il
		$( "#cap_RichiestaRisposta").parents("table:first").css({"display":"none"})
		$( "#cap_DataScadenza").parents("table:first").css({"display":"none"}) 
	}
	
  }
  
  if ( strTipoComumnicazione == 'FABBISOGNI_COMUNICAZIONE_GENERICA' )
  {
	try
	{
		$( "#cap_CIG" ).parents("table:first").css({"display":"none"}); 
		$( "#cap_CUP" ).parents("table:first").css({"display":"none"}); 
	}
	catch(e){}
  }
  
  
  
   //se jumpcheck diverso da 1-VERIFICA_REQUISITI nascondo il campo numero aziende da sort
   if	( strJumpCheck != '1-VERIFICA_REQUISITI' )
	{
		try{
			$( "#cap_NumeroAziendeSort").parents("table:first").css({"display":"none"}) 
		}catch(e){}
		
	}
    
	//se documento editabile
   if ( getObj('DOCUMENT_READONLY').value == '0' )
   {
		try
		{
			//IMPOSTO UN EVENTO DI ONCHANGESULLEDATE PER LE QUALI E' RICHIESTO UN CONTROLLO CHE NON RICADONO IN UN FERMO SISTEMA
			//CONSERVANDO UNO PRECEDENTE SE LO TROVA	
			onchangepresente = GetProperty(getObj('DataScadenza_V'),'onchange');		
			if ( onchangepresente == null )
			{
				onchangepresente='';
			}
			if (  onchangepresente != '' && onchangepresente.indexOf(";",onchangepresente.length-1) < 0 )
			{
				onchangepresente=onchangepresente + ';';
			}	
			onchangepresente=onchangepresente + 'onChangeCheckFermoSistema(this);';
			getObj('DataScadenza_V' ).setAttribute('onchange', onchangepresente);		
			getObj('DataScadenza_HH_V' ).setAttribute('onchange', 'onChangeCheckFermoSistema(this);');		
			getObj('DataScadenza_MM_V' ).setAttribute('onchange', 'onChangeCheckFermoSistema(this);');		
		}catch(e){}	
   }
   
   //se richiesto ATTIVO_VIS_DEST = no nascondo la tabella dei destinatari
    if ( getObj('ATTIVO_VIS_DEST').value == 'no' )
	{
		getObj('div_DETTAGLIGrid').style.display='none';
	}
  
}

function InverteSelezione( param ){
  
  //alert(DETTAGLIGrid_EndRow);
  for( i = DETTAGLIGrid_StartRow ; i <= DETTAGLIGrid_EndRow ; i++ )
    {
        //-- se trovo almeno una busta non letta devo controllare sulla busta documentazione
        if ( getObjValue( 'R' +  i  + '_Seleziona_Deleted' ) == '1' )
          getObj( 'R' +  i  + '_Seleziona_Deleted' ).value = '0';
        else
          getObj( 'R' +  i  + '_Seleziona_Deleted' ).value = '1';
            
        
    }
  

}  

function includiTutti()
{
	setAll('0');
}
function escludiTutti()
{
	setAll('1');
}

function setAll(val)
{
	for( i = DETTAGLIGrid_StartRow ; i <= DETTAGLIGrid_EndRow ; i++ )
	{
		getObj( 'R' +  i  + '_Seleziona_Deleted' ).value = val;
	}

}

function MyOpenDocumentColumn( objGrid , Row , c ){
	
	//aggiorno documento in meoria
	UpdateDocInMem( getObj( 'IDDOC' ).value, getObj( 'TYPEDOC' ).value );
	
	//apro il dettaglio
	OpenDocumentColumn( objGrid , Row , c );
	
}

function MyOpenViewer(param)
{	
	ExecDocProcess( 'FITTIZIO,DOCUMENT,,NO_MSG');
}


function afterProcess( param )
{
	if ( param == 'FITTIZIO' )
    {
		if ( getObj('VersioneLinkedDoc').value == 'BANDO_SDA' )
		{
			OpenViewer('Viewer.asp?STORED_SQL=yes&OWNER=&Table=DASHBOARD_SP_DASHBOARD_VIEW_OE_ALBO&ModelloFiltro=DASHBOARD_VIEW_OE_ALBOFiltro&ModGriglia=DASHBOARD_VIEW_OE_ALBOGriglia&IDENTITY=idrow&lo=base&HIDE_COL=classeiscriz,&DOCUMENT=PDA_COMUNICAZIONE_GENERICA&PATHTOOLBAR=../CustomDoc/&JSCRIPT=PDA_COMUNICAZIONE_GENERICA&AreaAdd=no&Caption=Ricerca destinatari comunicazione&Height=180,100*,210&numRowForPag=20&Sort=idrow&SortOrder=asc&Exit=si&AreaFiltro=&FilteredOnly=yes&ONSUBMIT=WiewLoading()&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_RICERCA_DESTINATARI_COMUNICAZIONE&ACTIVESEL=1&FilterHide=IdHeader='+ getObj('LinkedDoc').value + '&doc_to_upd='+ getObj('IDDOC').value);
		}
		else
		{
			OpenViewer('Viewer.asp?STORED_SQL=yes&OWNER=&Table=DASHBOARD_SP_DASHBOARD_VIEW_OE_ALBO&ModelloFiltro=DASHBOARD_VIEW_OE_ALBOFiltro&ModGriglia=DASHBOARD_VIEW_OE_ALBOGriglia&IDENTITY=idrow&lo=base&HIDE_COL=&DOCUMENT=PDA_COMUNICAZIONE_GENERICA&PATHTOOLBAR=../CustomDoc/&JSCRIPT=PDA_COMUNICAZIONE_GENERICA&AreaAdd=no&Caption=Ricerca destinatari comunicazione&Height=180,100*,210&numRowForPag=20&Sort=idrow&SortOrder=asc&Exit=si&AreaFiltro=&FilteredOnly=yes&ONSUBMIT=WiewLoading()&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_RICERCA_DESTINATARI_COMUNICAZIONE&ACTIVESEL=1&FilterHide=IdHeader='+ getObj('LinkedDoc').value + '&doc_to_upd='+ getObj('IDDOC').value);
		}
    }
	
	if ( param == 'XML_CHANGE_NOTICE' )
	{
		execDownloadXmlChangeNotice();
	}
	
}

function AggiungiDestinatari()
{
	var FilterHide=getQSParam('filterhide');
	var doc_to_upd=getQSParam('doc_to_upd');
	var hiddenViewerCurFilter = getObj('hiddenViewerCurFilter').value;
	//alert(hiddenViewerCurFilter);
	
	ajax = GetXMLHttpRequest();
	      
    var nocache = new Date().getTime();
	      
    if (ajax) 
	{
		ajax.open("GET", '../customdoc/DASHBOARD_VIEW_OE_ALBO.asp?FilterHide=' + encodeURIComponent(FilterHide) + '&doc_to_upd=' + encodeURIComponent(doc_to_upd) + '&filtro=' + encodeURIComponent(hiddenViewerCurFilter) + '&nocache=' + nocache  , false);

            ajax.send(null);
			
            if (ajax.readyState == 4) 
			{
                //alert(ajax.status);
                if (ajax.status == 200) 
				{
                    //alert(ajax.responseText);
                    if (ajax.responseText == 'OK' ) 
					{
                        
                        ReloadDocFromDB( doc_to_upd , 'PDA_COMUNICAZIONE_GENERICA' ) ;
						//breadCrumbPop('');  
						ShowWorkInProgress(false);	
						DMessageBox( '../' , 'Operazione eseguita correttamente' , '' , 1 , 400 , 300 );

                    } 
					else 
					{
						
						return;
                       
                    }
                }
            }

        }	
	
}

function Mysavedoc()
{
	ExecDocProcess( 'SAVE,PDA_COMUNICAZIONE_GENERICA');
}


function MyExecDocProcess(param) 
{
    //alert(param);
    var str=getObj('JumpCheck').value;

	var arr=str.split('-');
	var ammetterisposta = arr[0];
	if ( ammetterisposta == '1' )
	{
		try
		{
			if ( getObjValue('DataScadenza') == '' )
			{
				DMessageBox('../', 'Compilare il campo Rispondere Entro il', 'Attenzione', 1, 400, 300);
				return -1;
			}
			
			if ( getObjValue('DataScadenza') !='')
			{
				if (CheckDataOrarioOK('DataScadenza', 'Indicare un orario per il campo "Rispondere Entro il" diverso da zero') == -1) return -1;
			}
			
			
		}catch (e){}
	}
	
	ExecDocProcess(param);

}


function CheckDataOrarioOK(FieldData, msgVuoto) 
{
   var ORE=0;
   try
	{
		var ORARIO = getObjValue(FieldData).split('T')[1];
		var ORE = ORARIO.split(':')[0];
	}
	catch(e){}
	
	if ( ORE > 0 ) 
	{
		return 0;
	}
	else
	{
      
        try 
		{
          getObj(FieldData + '_V').focus();
        } catch (e) {};
        DMessageBox('../', msgVuoto, 'Attenzione', 1, 400, 300);
        return -1;
    }

    

    
}

function onChangeCheckFermoSistema(obj)
{
	
	
	
	//INVOCAZIONE SU ONCHANGE DEL CAMPO
	try
	{
		if ( obj.name != '' && obj.name != null )
		{
			
			var NameControlloData = obj.id;
			
			NameControlloData = NameControlloData.replace('_HH_V','_V');
			NameControlloData = NameControlloData.replace('_MM_V','_V');  
			var objFieldData = getObj(NameControlloData);
			//SOLO SE DATA E ORA E MIN SONO VALORIZZATI FACCIO IL CONTROLLO DEL FERMO SISTEMA ALTRIMENTI LO FARA' IL PROCESSO DI INVIO
			//SE LO AVREI FATTO SOLO CON LA DATA RISCHIAMO DI NON CONSENTIRE AGLI UTENTI DI METTERE UN ORARIO OLTRE IL FERMO SISTEMA
			NameControlloORA = NameControlloData.replace('_V','_HH_V');  	
			NameControlloMIN = NameControlloData.replace('_V','_MM_V');  				
			if (  getObj(NameControlloData).value != '' && getObj(NameControlloORA).value != '' && getObj(NameControlloMIN).value != '' )
			{
				Get_CheckFermoSistema ( '../../', objFieldData );					
				
			}
			
		}
		
	}catch(e){}
}

function HideCestinodoc()
{
	try
	{
		
		if ( getObjValue('JumpCheck') == '0-ESITO_DEFINITIVO_MICROLOTTI' )
		{
			var i = 0;
			
			var documentReadonly = getObjValue('DOCUMENT_READONLY');
			
			if (documentReadonly !== '1')
			{
				
				for( i=0; i < ALLEGATIGrid_EndRow + 1 ; i++ )
				{
								   
					
					if( getObj( 'RALLEGATIGrid_' + i + '_Descrizione' ).value == 'Determina' )
					{
						getObj( 'ALLEGATIGrid_r' + i + '_c0' ).innerHTML = '&nbsp;';
						getObj( 'ALLEGATIGrid_r' + i + '_c0' ).removeAttribute('class');
					}
				}
			}
		}
		
	}catch(e){}
	
}

function ALLEGATI_AFTER_COMMAND ()
{
	HideCestinodoc();
}

function execDownloadXmlChangeNotice()
{
	ExecFunction('../../eforms/changeNotice.asp?id=' + getObjValue('IDDOC') + '&idpfu=' + idpfuUtenteCollegato + '&operation=download', '_blank', '');
}