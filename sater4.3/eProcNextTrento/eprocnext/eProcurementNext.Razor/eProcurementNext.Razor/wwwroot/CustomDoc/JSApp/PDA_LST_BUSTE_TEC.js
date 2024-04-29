function OpenOfferta( objGrid , Row , c )
{
	//-- mette la spunta sulla riga dell'offerta che si sta aprendo
    try
    {
		var Sel = document.getElementsByName('Selezione');
		Sel[Row].checked = true;
		StoreSelection();
    }catch(e){};		
    


    var TipoDoc =  'OFFERTA_BUSTA_TEC'
    ShowDocumentFromAttrib( TipoDoc + ',' +  'R' + Row  + '_idHeaderLotto' );
        
        
    //-- imposta come aperta la busta del documento
    getObj( 'val_R' + Row + '_bReadDocumentazione' ).innerHTML = '<img border="0" src="../images/Domain/bread0.gif" >';
	
	
		

}



function Esito( stato )
{


    var Selezione = document.getElementsByName('Selezione');
    
    //-- recupera la riga selezionata
    var indRow = getCheckedValue( Selezione );   
    if( indRow  == '' ) 
    {
        alert(  CNV( '../../' ,  'E\' necessario selezionare prima una riga' ));
        return; 
    }
    
    //-- verifica se lo stato richiesto è ammissibile
    var StatoPDA = getObjValue( 'val_R' + indRow +  '_StatoRiga' );
    var idRow = getObjValue( 'R' + indRow +  '_idRow' );
    
    //-- se viene richiesta l'esclusione lo stato di partenza puo essere:in verifica o davalutare
    if( stato == 'escluso' && ( StatoPDA == 'daValutare' || StatoPDA == 'inVerifica' ) )
    {
        DOC_NewDocumentFrom( 'ESITO_LOTTO_ESCLUSA#LOTTO,' + idRow + '#800,600##&UpdateParentX=no' );
        return;
    }

    //-- se viene richiesta la verifica lo stato di partenza puo essere:daValutare
    if( stato == 'inVerifica' && ( StatoPDA == 'daValutare'  ) )
    {
        DOC_NewDocumentFrom( 'ESITO_LOTTO_VERIFICA#LOTTO,' + idRow + '#800,600##&UpdateParentX=no' );
        return;
    }
  

    //-- se viene richiesta l'annullamento lo stato di partenza non puo essere da valutare
    if( stato == 'annulla' && ( StatoPDA != 'daValutare' ) )
    {
        DOC_NewDocumentFrom( 'ESITO_LOTTO_ANNULLA#LOTTO,' + idRow + '#800,600##&UpdateParentX=no' );
        return;
    }

     //-- se viene richiesta l'ammissione / conformità lo stato puo essere : daValutare o in verifica
    if( stato == 'Conforme' && ( StatoPDA == 'daValutare'  || StatoPDA == 'inVerifica' ) )
    {
    
        DOC_NewDocumentFrom( 'ESITO_LOTTO_AMMESSA#LOTTO,' + idRow + '#800,600##&UpdateParentX=no' );
        return;
    }

 
    alert(  CNV( '../../' ,  'Il cambiamento richiesto non e coerente con lo stato del documento' ));
	
}


function OpenScheda( objGrid , Row , c )
{

    MakeDocFrom( 'PDA_VALUTA_LOTTO_TEC#900,800#LOTTO#' + getObjValue( 'R' + Row  + '_idRow' ) );


}


function DrillMotivazioni( objGrid , Row , c )
{
    var idRow = getObjValue( 'R' + Row +  '_idRow' );
    var w;
    var h;
    var Left;
    var Top;
    var altro;

    w = screen.availWidth * 0.5;
    h = screen.availHeight  * 0.4;
    Left= (screen.availWidth - w) / 2;
    Top= (screen.availHeight - h ) / 2;


    //apro la lista  delle motivazioni
    var strURL='Viewer.asp?lo=base&TOOLBAR=PDA_LISTA_MOTIVAZIONE_ESITI_TOOLBAR&Table=PDA_LISTA_MOTIVAZIONE_ESITI_LOTTO&ModGriglia=PDA_LISTA_MOTIVAZIONE_ESITIGriglia&JSCRIPT=&IDENTITY=Id&DOCUMENT=ESITO&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=Lista Motivazioni di Esito&Height=0,100*,0&numRowForPag=20&Sort=DataInvio&SortOrder=desc&Exit=si&FilterHide=LinkedDoc=' + idRow  ;
	
    //ExecFunction(  strURL , 'ListaEsito'  , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
    OpenViewer( strURL );  
}


function OFFERTE_OnLoad()
{

	var PUNTEGGI_ORIGINALI = ''
    var conf = getObjValue( 'val_Conformita' );
	try{ PUNTEGGI_ORIGINALI = getObjValue( 'PUNTEGGI_ORIGINALI' ); }catch(e){ PUNTEGGI_ORIGINALI = ''; };

    //-- se è privista la conformita Ex-Ante oppure è economicamente più vantaggiosa
    if( conf == 'Ex-Ante'  )
    {
        ShowCol( 'OFFERTE' , 'FNZ_CONTROLLI' , 'none' );
        ShowCol( 'OFFERTE' , 'PunteggioTecnico' , 'none' );

        ShowCol( 'OFFERTE' , 'PunteggioTecnicoAssegnato' , 'none' );
        ShowCol( 'OFFERTE' , 'PunteggioTecnicoRiparCriterio' , 'none' );
        ShowCol( 'OFFERTE' , 'PunteggioTecnicoRiparTotale' , 'none' );
    }
    

	//-- nascondo le colonne dei punteggi riparametrati in coerenza con il criterio scelto
	var PunteggioTEC_TipoRip = getObjValue( 'PunteggioTEC_TipoRip' );
	var PunteggioTEC_100 = getObjValue( 'PunteggioTEC_100' );
    //alert(PunteggioTEC_TipoRip);
    if( PunteggioTEC_100 == '0'  )
    {
        //ShowCol( 'OFFERTE' , 'PunteggioTecnicoAssegnato' , 'none' );
        ShowCol( 'OFFERTE' , 'PunteggioTecnicoRiparCriterio' , 'none' );
        ShowCol( 'OFFERTE' , 'PunteggioTecnicoRiparTotale' , 'none' );
    }
	else
    {
		
		if ( PUNTEGGI_ORIGINALI != 'YES' )
		{
			ShowCol( 'OFFERTE' , 'PunteggioTecnicoAssegnato' , 'none' );
		}
		if ( PunteggioTEC_TipoRip == '1' ) //-- solo lotto
		{
			ShowCol( 'OFFERTE' , 'PunteggioTecnicoRiparCriterio' , 'none' );	
		}
		if ( PunteggioTEC_TipoRip == '2' ) //-- solo criterio
		{
			ShowCol( 'OFFERTE' , 'PunteggioTecnicoRiparTotale' , 'none' );
		}
	}
	
    //-- se il documento è stato chiuso aggiorno il chiamante e chiudo 
    var val_StatoRiga = getObjValue( 'val_StatoRiga' );
    var idRow;
    
    if ( val_StatoRiga  == 'Valutato' || val_StatoRiga  == 'NonGiudicabile' || val_StatoRiga  == 'Completo' )
    {
    
        ShowCol( 'OFFERTE' , 'Selezione'  , 'none' )
    
        val_StatoRiga = document.location.toString();
        
        if (val_StatoRiga.indexOf( 'CHIUDI_VAL_TEC_LOTTO' ) > -1  )
        {
    
            ExecDocCommandParent( 'LST_LOTTI_TEC#Reload##PDA_MICROLOTTI' );
            ExecDocCommandParent( 'RIEPILOGO_FINALE#Reload##NOTE' );
            //-- self.close();
        } 
    }
	
	//-- cerco di ripristinare una selezione precedente
	try{
		if ( getCookie('PDA_MICROLOTTI_IDDOC_TEC') == getObj( 'IDDOC' ).value )
		{
			var Sel = document.getElementsByName('Selezione');//getObj( 'Selezione');
			var idx = getCookie('PDA_MICROLOTTI_SELEZIONE_TEC');
			Sel[idx].checked = true;


			}
		
	}catch(e){}
	
	//-- associo la funzione di onchange per conservare la selezione del radio button
	$('input[type="radio"]').on('change',OnChangeSelezione );	
	
	var AttivaFilePending = getObj('AttivaFilePending');
	
	/* SE IL CAMPO ESISTE */
	if ( AttivaFilePending )
	{
		//Se non è richiesta la verifica pending dei file nascondiamo la colonna statoFirma
		if (AttivaFilePending.value != 'si' )
		{
			try
			{
				ShowCol('OFFERTE', 'Stato_Firma_PDA_AMM', 'none');
			}
			catch(e){}
		}
	}
	
}

function StoreSelection()
{
	try{
		var Selezione = document.getElementsByName('Selezione');
		
		//-- recupera la riga selezionata
		//var indRow = getCheckedValueRow( Selezione ); 	
		var indRow = getIdRowChecked( Selezione ); 	
		
		//-- la memorizzo nel cooky
		setCookie2('PDA_MICROLOTTI_IDDOC_TEC', getObj( 'IDDOC' ).value  );
		setCookie2('PDA_MICROLOTTI_SELEZIONE_TEC', indRow );
		
	}catch(e){}
}

function OnChangeSelezione ( e ) 
{
	if ( e.type == 'change' && ( e.target.id == 'Selezione' || e.target.id == 'Selezione2' ) )
		StoreSelection();
	else 
		return false;	
}

function getIdRowChecked(radioObj) 
{
	if(!radioObj)
		return "";
	var radioLength = radioObj.length;
	if(radioLength == undefined)
		return -1;
	for(var i = 0; i < radioLength; i++) {
		if(radioObj[i].checked) {
			return i;
		}
	}
	return -1;
}

    

function ExecDocCommandParent( parametri )
{
//	debugger;
	var section;
	var command;
	var param;
	var vet;
	
	
	vet = parametri.split( '#' );
	section = vet[0];
	command = vet[1];
	param = vet[2];

	var CommandQueryString = opener.getObj('CommandQueryString').value;
	var IDDOC = opener.getObj( 'IDDOC' ).value;
	var TYPEDOC = opener.getObj( 'TYPEDOC' ).value;
			
	var objForm=opener.getObj('FORMDOCUMENT');

	objForm.action='document.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=' + section + '.' + command + '&' + param;

	objForm.target=vet[3] + '_Command_' + IDDOC;
	
	objForm.submit();
	

}    



function getCheckedValue(radioObj) {
	if(!radioObj)
		return "";
	var radioLength = radioObj.length;
	if(radioLength == undefined)
		if(radioObj.checked)
			return radioObj.value;
		else
			return "";
	for(var i = 0; i < radioLength; i++) {
		if(radioObj[i].checked) {
			return radioObj[i].value;
		}
	}
	return "";
}

function My_Dash_ExecProcessDoc( param , ID_Griglia)
{
		
	var w;
	var h;
	var Left;
	var Top;
	var parametri;

	w = 800;
	h = 600;	
	Left = (screen.availWidth-w)/2;
	Top  = (screen.availHeight-h)/2;	
		
	
	parametri='CONTESTO=' + getObj( 'TYPEDOC' ).value  + '&IDDOC=' + getObj('IDDOC').value + '&PROCESS_PARAM=' + encodeURIComponent(param);
	
	ExecFunction(  pathRoot + 'customDoc/Apri_Buste_Offerte.asp?' + parametri,  '_blank',  ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h );
	
	
}

function RefreshContent()
{
		
	if ( singleWin != 'YES' )
	{	
		if ( opener != null )
			opener.RefreshContent();
	}	
	
	//RefreshDocument( pathRoot + 'application/ctl_library/document/');
	RefreshDocument(urlPortale + '/ctl_library/document/');
}
