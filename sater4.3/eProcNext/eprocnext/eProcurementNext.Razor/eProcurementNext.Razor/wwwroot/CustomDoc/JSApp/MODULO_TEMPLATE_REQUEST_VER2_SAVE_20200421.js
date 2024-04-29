
window.onload = OpenModuli; 


function OpenModuli()
{
	
	controlli('');
	

	
	//-- cerco di riposizionare la pagina dpo un comando
	try{ 
		if( getObj( 'Note' ).value != '' )
		{
			var v = getObj( 'Note' ).value.split( '@@@' );
			
			//document.body.scrollTop =  v[4];
			document.documentElement.scrollTop =  v[4];
			getObj( 'Note' ).value = '';
		}
	}catch(e){}

	
	try{
		$('#Toolbar_stampa ul').style.display = 'none';
	}catch(e){};
	
	/*
	
	$('.FldDomainValue_OptionTAB input').mouseup( function ()
		{   
			return false;
		} );
	$('.FldDomainValue_OptionTAB input').click( function ()
		{   
			return false;
		} );
	$('.FldDomainValue_OptionTAB input').mousedown( function ()
		{ 
			if ( this.checked == true ) 
				this.checked = false;
			else
				this.checked = true;

			OnChangeScelta(  this );
			return true;
			
		} );
	*/
	
	//-- aggiusta il tooltip
	$( function() {
		//$( document ).tooltip
		$('[data-toggle="tooltip"]').tooltip({
			items: "img, [data-toggle], [title]",
			content: function() {
				var element = $( this );
				if ( element.is( "[data-geo]" ) ) {
					var text = element.title();
					return '<div  class="TTBS" >' + unescape( text ) + '</div>';
				}
				if ( element.is( "[title]" ) ) {
					var text = element.attr( "title" );
					return '<div  class="TTBS" >' + unescape( text ) + '</div>';					
					//return element.attr( "title" );
				}
				if ( element.is( "img" ) ) {
					return element.attr( "alt" );
				}
			}
		});
	} );

	
	//-- predispongo le parti relazionate aperte o chiuse in funzione delle scelte effettuate solamente per gli OE
	if ( getObjValue( 'INCARICOA' ) == 'OE' )
	{
		var GRP = document.getElementsByName("GRP_Related");
		var i;
		for ( i = 0 ; i < GRP.length ; i++ )
		{
			
			try{ OpenCloseGroup( GRP[i] ); }catch(e){};
		}
	}
	
	
	//-- allineo i bottoni per la gestione del PDF
	try
	{
		StatoDocRiferimento = getObj('StatoDocRiferimento').value;
		
		
	
		if ((getObjValue('SIGN_LOCK') =='0' || getObjValue('SIGN_LOCK') =='') &&  StatoDocRiferimento == 'InLavorazione' )
		{
			document.getElementById('generapdf').disabled = false; 
			document.getElementById('generapdf').className ="generapdf";
		}
		else
		{
			document.getElementById('generapdf').disabled = true; 
			document.getElementById('generapdf').className ="generapdfdisabled";
		}
		
		if ( getObjValue('SIGN_LOCK') != '0'    &&  StatoDocRiferimento == 'InLavorazione')
		{
			document.getElementById('editistanza').disabled = false; 
			document.getElementById('editistanza').className ="attachpdf";
		}
		else
		{
			document.getElementById('editistanza').disabled = true; 
			document.getElementById('editistanza').className ="attachpdfdisabled";
		}
		
		if ( (getObjValue('SIGN_ATTACH') ==''   && getObjValue('SIGN_LOCK') != '0' ) &&   StatoDocRiferimento == 'InLavorazione' )
		{
			document.getElementById('attachpdf').disabled = false; 
			document.getElementById('attachpdf').className ="editistanza";
		}
		else
		{
			document.getElementById('attachpdf').disabled = true; 
			document.getElementById('attachpdf').className ="editistanzadisabled";
		}
	}
	catch(e)
	{
	}
	
		
		
		
		
}


function afterProcess(param) {
/*
	if (param == 'EXEC_COMMAND') 
	{
		setTimeout(function(){ 
				try{ document.body.scrollTop =  getObj( 'Note' ).value; }catch(e){}
		}, 10 );
	}
	if ( param == 'FITTIZIO' )
    {
       OpenViewer('Viewer.asp?JSIN=yes&ShowExit=0&OWNER=OWNER&Table=View_Elenco_DGUE_Compilati&&ModGriglia=&IDENTITY=ID&lo=base&HIDE_COL=FNZ_OPEN,&DOCUMENT=MODULO_TEMPLATE_REQUEST&PATHTOOLBAR=../CustomDoc/&JSCRIPT=ELENCO_DGUE_COMPILATI&AreaAdd=no&Caption=Elenco DGUE Compilati&Height=200,100*,210&numRowForPag=20&Sort=Id&SortOrder=asc&Exit=si&AreaFiltro=&AreaFiltroWin=hide&TOOLBAR=TOOLBAR_VIEW_LISTA_DGUE_COMPILATI&ACTIVESEL=1&FILTERCOLUMNFROMMODEL=yes&FilterHide=&doc_to_upd='+ getObj('IDDOC').value + '&a=');
    }
	*/
}


function OpenCloseGroup( obj )
{
		var id = obj.id;
		
		//-- leggere la caratteristica per decidere se visualizzare o nascondere
		var l = id.length;
		
		var idRadio = id  //--.substring(4 );; //--GRP_
		
		if ( idRadio.indexOf( '_ON_TRUE' ) > -1 )
			idRadio = id.substring(4 , l - 8);; //--GRP_
		
		if ( idRadio.indexOf( '_ON_FALSE' ) > -1 )
			idRadio = id.substring(4 , l - 9);; //--GRP_
				
		
		var idValore = 'H_' + id;
		
		//-- per prima cosa si nasconde il gruppo
		obj.style.display = 'none';
		
		//var selectedOption = $("input:radio[id='idRadio']:checked").val()
		
		//-- si riattiva se il radio è selezionato quello giusto
		if 	(
				( getObjValue( idValore ) == 'GROUP_FULFILLED.ON_TRUE' && getObjValue( idRadio ) ==  'si' ) 
				|| 
				( getObjValue( idValore ) == 'GROUP_FULFILLED.ON_FALSE' && getObjValue( idRadio ) ==  'no' ) 
			)
		{
			obj.style.display = '';
		}
			
	
		var next = obj.nextElementSibling;
		
		if ( next.id == obj.id )
		{
			OpenCloseGroup( next );
		}
	
}



function OnChangeScelta( obj )
{
	try{ OpenCloseGroup( getObj( 'GRP_' + obj.id + '_ON_TRUE' ) ); }catch(e) {}
	try{ OpenCloseGroup( getObj( 'GRP_' + obj.id + '_ON_FALSE' ) ); }catch(e) {}
}


function AddItem( Item  )
{
	getObj( 'Note' ).value = 'ADDITEM@@@' + Item + '@@@' + document.documentElement.scrollTop;
	//getObj( 'Note' ).value = document.body.scrollTop;
	Command( 'ADDITEM' , Item);
}

function DelItem(  Item  )
{
	getObj( 'Note' ).value = 'DELITEM@@@' + Item + '@@@' + document.documentElement.scrollTop;
	var v = Item.split( '@@@');
	
	
	var objName  =  "MOD_" + v[0] + "_FLD_N" + v[2] + v[1]; 
	var objNameCUR  =  "MOD_" + v[0] + "_FLD_CUR_N" + v[2] + v[1]; 
	var objNameTo;
	var objNameFrom;
	
	var arr =[];
	$( "input,select" ).each( function(){
		
		try{ 
			if( this.id.indexOf(  objName ) > -1 && this.id.indexOf( 'extraAttrib' ) == -1 )
			{
				arr.push( this.id.substring( objName.length ) );
			}
			/*
			if( this.id.includes(  objNameCUR ) )
			{
			arr.push( this.id.substring( ) );
			}
			*/
		 }catch(e){};
	});
	
	//-- per ogni attributo presente nel gruppo iterabile si spostano i campi
	try
	{
		var r = Number( v[2] );
		while( r < 1000 ) //-- 1000 è per evitare un loop infinito
		{
			objNameTo  =  "MOD_" + v[0] + "_FLD_N" + r + v[1]; 
			objNameCurTo  =  "MOD_" + v[0] + "_FLD_CUR_N" + r + v[1]; 
			r++;
			objNameFrom  =  "MOD_" + v[0] + "_FLD_N" + r + v[1]; 
			objNameCurFrom  =  "MOD_" + v[0] + "_FLD_CUR_N" + r + v[1]; 
			
			//-- muove tutti gli attributi presenti nel gruppo
			for( i = 0 ; i < arr.length ; i++ )
			{
				if( getObj( objNameTo + arr[i] ).type == 'select' )
				{
					getObj( objNameTo + arr[i] ).selectedIndex = getObj( objNameFrom + arr[i]).selectedIndex;
				}
				else
				{
					getObj( objNameTo + arr[i] ).value = getObj( objNameFrom + arr[i]).value;
				
					//-- prova a spostare anche un eventuale currency
					try{ getObj( objNameCurTo + arr[i] ).selectedIndex  = getObj( objNameCurFrom + arr[i]).selectedIndex ; } catch(e){}
				}
			}
		}
	}
	catch(e){}
	
	
	
	//getObj( 'Note' ).value = document.body.scrollTop;
	Command( 'DELITEM', Item);
}

function DelItemVer2(  Item  )
{
	getObj( 'Note' ).value = 'DELITEM@@@' + Item + '@@@' + document.documentElement.scrollTop;
	Command( 'DELITEM', Item);
}


function Command( cmd , Item )
{
	var statoDoc;
	statoDoc = getObj('DOCUMENT_READONLY').value;

    if( statoDoc == '1' ) 
    {
        return;
    }
	
	var nocache = new Date().getTime();
	var c = Item.split('@@@');

	ShowWorkInProgress();
	
	
	
	ExecDocCommand( '#' + cmd + '.' + Item + '#' );
	
	//-- ottimizzare passando il nome del modello da ripulire
	//--SUB_AJAX( '../../ctl_library/REFRESH.ASP?COSA=MODEL&nocache=' + nocache );
	/*
	setTimeout(function()
		{ 

			SUB_AJAX( '../../CustomDoc/TEMPLATE_REQUEST_COMMAND.ASP?IDDOC=' + getObjValue('IDDOC') + '&COMANDO=' + cmd + '&Modulo=' + c[0] + '&Gruppo=' + c[1] + '&Indice=' + c[2] + '&nocache=' + nocache );
			
			ExecDocProcess( 'EXEC_COMMAND,MODULO_TEMPLATE_REQUEST,,NO_MSG');

			}, 1 );
	*/
}
function SaveDoc()
{
    ShowWorkInProgress();

	ExecDocCommand( '#SAVE#' );
}

function ExecDocCommand( parametri )
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
	
	var CommandQueryString = getObj('CommandQueryString').value;
	
	var IDDOC = getObj( 'IDDOC' ).value;
	var TYPEDOC = getObj( 'TYPEDOC' ).value;
	
	var objForm=getObj('FORMDOCUMENT');

	objForm.action='TEMPLATE_REQUEST.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=' + command + param;
	objForm.target='';
	
	try{  CloseRTE() }catch(e){};
	objForm.submit();
	

}

function SetInitField()
{
    
	var i = 0;
	for( i = 0 ; i < NumControlli ; i++ )
	{
		//if ( getObjValue('Not_Editable').indexOf( LstAttrib[i] + ' ,') < 0 )
		if ( getObj(LstAttrib[i] ) )
		{
			TxtOK( LstAttrib[i] );
		}
	}

    
    
    
} 
var NumControlli;
var LstAttrib;
function GeneraPDFOLD()
{
	
	


	var statoDoc;
	statoDoc = getObj('DOCUMENT_READONLY').value;

    if( statoDoc == '1' ) 
    {
        return;
    }

	
	
 /*  
    if( controlli('') == 1) 
    {
		DMessageBox( '../' , 'Compilare il DGUE in tutti i suoi campi obbligatori, successivamente effettuare nuovamente il comando genera pdf.' , 'Attenzione' , 1 , 400 , 300 );
        //SaveDoc();
        return;
    }
*/    	
	
    scroll(0,0);  
	alert( 'URL=/customdoc/TEMPLATE_REQUEST.ASP?' + getObjValue( 'PrintQueryString' ) );

    PrintPdfSign('URL=/customdoc/TEMPLATE_REQUEST.ASP?' + getObjValue( 'PrintQueryString' ) + '&SIGN=YES&PROCESS=');	
	
    //PrintPdfSign('URL=/report/prn_' + getObj('TYPEDOC').value + '.ASP?SIGN=YES&PROCESS=ISTANZA@@@VERIFICHE_PRE_PDF');	
	
	//ToPrintPdfSign('TABLE_SIGN=CTL_DOC&PDF_NAME=Documento_' + getObjValue( 'JumpCheck' ) + '&lo=print&NO_SECTION_PRINT=DISPLAY_FIRMA&ML_FOOTER=ML_FOOTER_PAGING_PDF&JSCRIPT_STAMPA=YES&JSCRIPT_STAMPA_NAME=MODULO_TEMPLATE_REQUEST&PROCESS=MODULO_TEMPLATE_REQUEST@@@VERIFICA_CAMPI_OBBLI');

}

function GeneraPDF ()
{

/*
	var value2=controlli('');
	var EsitoRiga=controlloEsitoRiga();
	if (value2 == -1)
	return;
    Stato = getObjValue('StatoDoc');
    
    if( Stato == '' ) 
    {
        alert( 'Per effettuare il \"Genera PDF\" si richiede prima un salvataggio. Verra\' effettuato in automatico, successivamente effettuare nuovamente il comando di \"Genera PDF\"');
	//	DMessageBox( '../' , 'Per procedere si richiede prima un salvataggio, successivamente effettuare nuovamente il comando genera pdf.' , 'Attenzione' , 1 , 400 , 300 );
        MySaveDoc();
        return;
	}
	if ( EsitoRiga == -1 )
	{
		return;
	}
*/
    scroll(0,0);    
	
    PrintPdfSign('URL=/customdoc/TEMPLATE_REQUEST.ASP?' + getObjValue( 'PrintQueryString' ) + '&SIGN=YES&PROCESS=&PDF_NAME=ESPD_RESPONSE&lo=none');	
	

	
}
function ShowPDF()
{
	
	
/*

	var statoDoc;
	statoDoc = getObj('DOCUMENT_READONLY').value;

    if( statoDoc == '1' ) 
    {
        return;
    }

	

    if( controlli('') == 1) 
    {
		DMessageBox( '../' , 'Compilare il DGUE in tutti i suoi campi obbligatori, successivamente effettuare nuovamente il comando genera pdf.' , 'Attenzione' , 1 , 400 , 300 );
        //SaveDoc();
        return;
    }
*/    	
	
    scroll(0,0);  
	
	//alert( 'URL=/customdoc/TEMPLATE_REQUEST.ASP?' + getObjValue( 'PrintQueryString' ) );
	PrintPdf( '/customdoc/TEMPLATE_REQUEST.ASP?' + getObjValue( 'PrintQueryString' ) + '&PDF_NAME=ESPD_REQUEST&lo=none' );


	//ToPrintPdfSign('TABLE_SIGN=CTL_DOC&PDF_NAME=Documento_' + getObjValue( 'JumpCheck' ) + '&lo=print&NO_SECTION_PRINT=DISPLAY_FIRMA&ML_FOOTER=ML_FOOTER_PAGING_PDF&JSCRIPT_STAMPA=YES&JSCRIPT_STAMPA_NAME=MODULO_TEMPLATE_REQUEST&PROCESS=MODULO_TEMPLATE_REQUEST@@@VERIFICA_CAMPI_OBBLI');

}



function controlli (param)
{
	if (getObj('DOCUMENT_READONLY').value != '1' )
	{
		var err = 0;
		var	cod = getObj( "IDDOC" ).value;
		var campiObblig = getObjValue('ElencoFieldObblig');
		 
		campiObblig = campiObblig.replace( /~~~/g, '\"')
		LstAttrib = JSON.parse(campiObblig);
		NumControlli = LstAttrib.length ;
		 
		
		SetInitField();
		
		//-- controllo i dati della richiesta
		var i = 0;
		var err = 0;
		
		var bFirst = 0;
		var obj;

		for( i = 0 ; i < NumControlli ; i++ )
		{
	  
			try
			{
				//if ( getObjValue('Not_Editable').indexOf( LstAttrib[i] + ' ,') < 0 )
				if(  getObj(LstAttrib[i]) )
				{
					
					obj = getObj(LstAttrib[i]);
					if( obj.type == undefined && obj.length > 1 )
						obj = obj[0];
						
			
					if ( 
						obj.type == 'text' || obj.type == 'hidden' ||
						obj.type == 'select-one' ||  obj.type == 'textarea' ||
						obj.type == 'radio' 
					)
					{
						if( trim(getObjValue( LstAttrib[i] )) == '' )
						{
							err = 1;
							TxtErr( LstAttrib[i] );
						}
					}

					if ( obj.type == 'checkbox' )
					{
						if( obj.checked == false )
						{
							err = 1;
							TxtErr( LstAttrib[i] );
						}
					}

					if ( bFirst == 0 && err == 1 )
					{
						try{
							obj.focus();
							bFirst = 1;
						}catch(e) {}
					}

				}
			}catch(e) { alert( i + ' - ' +  LstAttrib[i] ); }
		  
		  
		}
		return err;
	}
}

function GeneraPDF_E()
{
	ToPrintPdf('PDF_NAME=Documento_' + getObjValue( 'JumpCheck' ) + '&lo=print&NO_SECTION_PRINT=DISPLAY_FIRMA&PROCESS=&ML_FOOTER=ML_FOOTER_PAGING_PDF&JSCRIPT_STAMPA=YES&JSCRIPT_STAMPA_NAME=MODULO_TEMPLATE_REQUEST');
}



function TogliFirma() 
{
	//ExecDocProcess( 'SIGN_ERASE,FirmaDigitale');

    ShowWorkInProgress();

	ExecDocCommand( '#SIGN_ERASE#' );
	
}


function AllegaDOCFirmato()
{
	
	
	var idDoc;
	var CF='';
	idDoc = getObjValue('IDDOC');
	CF = getObjValue('codicefiscale');
	
	if ( CF != '' && CF != undefined )
	{
		ExecFunctionCenterDoc('../CTL_Library/functions/field/uploadattachsigned.asp?TABLE=ctl_doc&amp;IDDOC=' + idDoc + '&amp;CF='+ CF +'&amp;OPERATION=INSERTSIGN&amp;IDENTITY=Id&amp;AREA=&amp;DOMAIN=FileExtention&amp;FORMAT=#AllegaFirma#600,400')
	}
	else
	{
		ExecFunctionCenterDoc('../CTL_Library/functions/field/uploadattachsigned.asp?TABLE=ctl_doc&amp;IDDOC=' + idDoc + '&amp;OPERATION=INSERTSIGN&amp;IDENTITY=Id&amp;AREA=&amp;DOMAIN=FileExtention&amp;FORMAT=#AllegaFirma#600,400')
	}
	
    
}

function trim(str){
    return str.replace(/^\s+|\s+$/g,"");
}



function MyOpenViewer(param)
{	
	ExecDocProcess( 'FITTIZIO,DOCUMENT,,NO_MSG');
}



	


function OpenCloseGroup2( ID , H )
{
	
	var objOpen  = getObj( 'Group_' + ID );

	var cls = objOpen.getAttribute('class');
	
	if( objOpen.style.display == 'none' || cls.indexOf('display_none') > -1 )
	{
		setVisibility( objOpen , '' );
	}
	else
	{
		setVisibility( objOpen , 'none' );
	}
}


//---- IDENTIFIER OPERATOR

function AddIdentifier( ObjName )
{
	
	AddItemIdentifier( ObjName + '_ALL_DOMAIN' , ObjName + '_SELECTED_ITEM' );
	
	document.getElementById(ObjName).value =  GetSelectedItemIdentifier( ObjName );
}

function DelIdentifier( ObjName )
{
	
	RemoveItemIdentifier( ObjName + '_SELECTED_ITEM' );

	document.getElementById(ObjName).value =  GetSelectedItemIdentifier( ObjName );
}


function AddItemIdentifier( source , dest )
{

	Sel_Dest = document.getElementById(dest);
	Sel_Source = document.getElementById(source);

	num_option_dest=document.getElementById(dest).options.length; 
	num_option_source=document.getElementById(source).options.length; 

	//indice_selezionato = document.getElementById(source).selectedIndex;
	var indice_selezionato = 0 ;
	while(  indice_selezionato < num_option_source )
	{
		
		//if(indice_selezionato>=0){
		if ( Sel_Source.options[indice_selezionato].selected )
		{
			value_selezionato = document.getElementById(source).options[indice_selezionato].value;
			testo_selezionato = document.getElementById(source).options[indice_selezionato].innerHTML;
			duplicato=0;
			for(a=0;a<num_option_dest;a++){
				if(document.getElementById(dest).options[a].value==value_selezionato){
					duplicato=1;
				}
			}
			if(duplicato==0){
				document.getElementById(dest).options[num_option_dest]=new Option(testo_selezionato,escape(value_selezionato),false,false);
				num_option_dest++;
				//document.getElementById(dest).options[num_option_dest].innerHTML = testo_selezionato;
			}
		}
		indice_selezionato++;
	}
}


function RemoveItemIdentifier( dest )
{

	Sel_Dest = document.getElementById(dest);

	num_option_dest=Sel_Dest.options.length; 

	var indice_selezionato = 0 ;
	while(  indice_selezionato < num_option_dest )
	{
		
		//if(indice_selezionato>=0){
		if ( Sel_Dest.options[indice_selezionato].selected )
		{
			try 
			{
				Sel_Dest.remove(indice_selezionato, null);
			} 
			catch(error) 
			{
				Sel_Dest.remove(indice_selezionato);
			}		
			num_option_dest--;
		}
		else
			indice_selezionato++;
	}
}



function GetSelectedItemIdentifier( ObjName )
{
	var ret = '';
	Sel_Dest = document.getElementById( ObjName + '_SELECTED_ITEM');

	num_option_dest=Sel_Dest.options.length; 

	for( var indice_selezionato = 0 ; indice_selezionato < num_option_dest ; indice_selezionato++)
	{
		ret = '###' + Sel_Dest.options[indice_selezionato].value;
	}
	
	if ( ret.length > 0 )
		ret += '###';
	
	return ret;
}



function ImportESPD_Response( parametri )
{
	ExecFunctionCenter( '../Ctl_library/functions/FIELD/UploadAttach.asp?PAGE=../../../ESPD/importResponse.aspx&IDDOC=' + getObjValue( 'IDDOC' ) + '&IDPFU=' + idpfuUtenteCollegato + '&' + parametri + '##400,400' );
}



function RefreshDocument( path )
{
	
	var CommandQueryString = getObj('CommandQueryString').value;
	
	if ( path.toLowerCase().indexOf('document') > 0 )
		URL = '../../Customdoc/TEMPLATE_REQUEST.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=RELOAD' ;
	else
		URL = path + 'Customdoc/TEMPLATE_REQUEST.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=RELOAD' ;
	
	
   	try{
		self.location =   URL ;
	}	catch(e){		}
}
