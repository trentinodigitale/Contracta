
function RDA_ChangeValuta( objPlantName , AttValutaName )
{
	try
	{
		objPlant = getObj( objPlantName );

		//-- nel caso non ci sia una plant selezionata svuoto il campo valuta
		if ( objPlant.value == '' ) 
		{
			objValuta = getObj( AttValutaName );
			objValuta.selectIndex = -1;
		}
		else
		{
			//-- altrimenti seleziono la valuta associata alla societ
			var soc = objPlant.value;//.split('#')[0];
			
			//-- ricopio il valore della plant CDC nella Plant CDC richiedente
			getObj( 'RDA_PlantRic' ).value = objPlant.value;
			getObj( 'RDA_PlantRic_edit' ).value = getObj( objPlantName + '_edit' ).value;
			
			ExecDocCommand2( 'CUSTOMSECTION' , 'SEL_VALUTA' , 'Plant=' + escape( soc ) + '&AttValutaName=' + AttValutaName   );
			return;
			
		}
		
		
	}
	catch( e ) {
	
		objValuta = getObj( AttValutaName);
		objValuta.selectIndex = -1;
	};
	

}


//-- invocato dalla toolbar per prendere un articolo ad un'altra tabella attraverso una pagina di selezione
function RDA_Detail_AddFrom( param )
{

	//-- i parametri sono separati da # e sono in quest'ordine
	//-- 1° - URL da invocare
	//-- 2° - target dell'output
	//-- 3° - Attributi filtro 
	//-- 4° - dimensioni della finestra
	//-- 5° - parametri aggiuntivi da passare alla nuova finestra per una corretta visualizzazione

	var idRow;
	var vet;
	var altro;
	var i;
	
	//debugger;
	
	vet = param.split( '#' );


	//-- recupera le dimensioni della finestra di output
	var w;
	var h;
	var Left;
	var Top;
    
    if( vet.length < 4  )
    {
		w = screen.availWidth;
		h = screen.availHeight;
		Left=0;
		Top=0;
	}
	else    
	{
		var d;
		d = vet[3].split( ',' );
		w = d[0];
		h = d[1];
		Left = (screen.availWidth-w)/2;
		Top  = (screen.availHeight-h)/2;
		
		if( vet.length > 3 )
		{
			altro = vet[4];
		}
	}
	
	//-- prende i campi che compongono il filtro , nel caso manchino blocca l'inserimento
	var strFilter= '';
	var strAttrib;
	var bOR = false;
	var valore;
	try
	{
		d = JSTrim(vet[2]).split( ',' );
		if ( d.length > 0 )
		{
			for( i = 0 ; i < d.length ; i++ )
			{

				strAttrib = d[i];
				bOR = false;
				if( strAttrib.substr(0,3) == 'or-' ) 
				{
					bOR = true;
					strAttrib = strAttrib.substring(3 , strAttrib.length );
					
				}
				
				valore = JSTrim( getObj( strAttrib ).value );
				if ( strAttrib == 'RDA_PlantRic' )
				{
					var g = valore.split( '#~#' );
					valore = g[0];
				
				}
					
				if ( ( JSTrim( getObj( strAttrib ).value ) == '' ) && ( bOR == false ) )
				//if (  JSTrim( getObj( strAttrib ).value ) == '' ) 
				{
					alert( getObj( 'MSG_OBBLIG_FOR_ADD' ).value );
					return;
				}
				else
				{
					if( bOR == true ) 
					{
						strFilter = strFilter + ' ( ' + strAttrib + ' = \'\' or '
					
						strFilter = strFilter + ' ' + strAttrib + ' = \'' + valore +  '\' ) ';
					}
					else
					{
						strFilter = strFilter + ' ' + strAttrib + ' = \'' + valore +  '\'';
					}
					if(  i < d.length -1 )
					{
						strFilter = strFilter + ' and ' ;
					}
				
				}
			
			}
		}
	} catch( e ){};	
	
  
	
	ExecFunction(  vet[0] + '&FilterHide=' + escape( strFilter )  , vet[1] , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
	


}




//-- ricarica il dominio degli articoli al cambiamento della merceologia
function OnChangeMerc_ReloadArticle( obj )
{
	try 
	{
	
		
	
		var indRow = -1;
		var strNameAttrib = '';
		var vPartName;
		var numRow = 0;
		var Filter = '';
	
	
		//-- recupera la riga dove si trova l'attributo
		strNameAttrib = obj.name;
		vPartName=strNameAttrib.split('_');
		indRow = parseInt(vPartName[1]);
		
		
	
	
		//-- recupero il numero delle righe presenti sulla griglia
		//numRow = eval( strSection + 'Grid_NumRow' );
		//var Grid = getObj( strSection + 'Grid');
		//numRow=parseInt( Grid.numrow );	


		var Filter = getObj(  vPartName[0] + '_RDP_CodArtProd' ).filter;
		
	
		//-- in tal caso rimuove il dominio precedentemente associato agli articoli
		RemoveAttrib( 'RDP_CodArtProd' , '' , Filter , '' , '' , 'BDG_CODART' , '8' );


		//-- svuoto il valore selezionato
		FldExtDomResetValue(  vPartName[0] + '_RDP_CodArtProd' );

	
		//-- imposto il nuovo filtro sul campo 
		var v = getObj( strNameAttrib ).value;
		
		//alert( 'valore selezionato per la merceologia ' + v );
		var strSqlFilter = 'SQL_WHERE=substring( artCode , 7 ,2 ) = \'' + v.substring( 0, 2) + '\' ';
		
		//alert( 'imposto il dominio]->' + strSqlFilter );
		getObj( vPartName[0] + '_RDP_CodArtProd' ).filter = strSqlFilter;
	

	}catch( e ) { };
	

}

function OnChangeArticle( obj )
{
	try
	{
		if( obj.value == '' ) return;
		
		var strNameAttrib = '';
		var vPartName;
		var Filter = '';
		//var valMerc = '';
		var valArt = obj.value;
	
		//-- recupera la riga dove si trova l'attributo
		strNameAttrib = obj.name;
		vPartName=strNameAttrib.split('_');
		
		

		//-- verifica che sulla merceologia relativa ci sia una selezione
		valMerc =  getObj(  vPartName[0] + '_RDP_Merceologia_edit' ).value;

		
		if ( valMerc == '' )
		{
			//-- svuoto il campo ed avviso l'utente
			FldExtDomResetValue(  vPartName[0] + '_RDP_CodArtProd' );
			MessageBox( 'Prima di selezionare un articolo occorre selezionare la merceologia' , 'ATTENZIONE' , 4 , 400 , 250 );
			return;
		}
	
		//-- verifica che il valore selezionato sia coerente
		if( valMerc.substring( 0, 2) != valArt.substr( 6, 2) )
		{

			//-- in tal caso rimuove il dominio precedentemente associato agli articoli
			var Filter = getObj( vPartName[0] + '_RDP_CodArtProd' ).filter;
			RemoveAttrib( 'RDP_CodArtProd' , '' , Filter , '' , '' , 'BDG_CODART' , '8' );

			//-- associo il nuovo filtro
			var strSqlFilter = 'SQL_WHERE=substring( artCode , 7 ,2 ) = \'' + valMerc.substring( 0, 2) + '\' ';
			getObj( vPartName[0] + '_RDP_CodArtProd' ).filter = strSqlFilter;


			//-- svuoto il campo ed avviso l'utente
			FldExtDomResetValue(  vPartName[0] + '_RDP_CodArtProd' );
			MessageBox( 'La selezione effettuata non e\' coerente con la merceologia, selezionare nuovamente l\'articolo' , 'ATTENZIONE' , 4 , 400 , 250 );
			
			return;
		}


		//-- se il valore è corretto cerco di liberare tutti i domini filtrati per gli articoli
		var Grid = getObj( 'PRODOTTIGrid');
		numRow=parseInt( Grid.numrow );	
		var i;
		for( i = 0 ; i < numRow ; i++ )
		{
			
			if( 'R' + i != vPartName[0] )
			{
				try{
					var Filter = getObj( 'R' + i + '_RDP_CodArtProd' ).filter;
					if ( Filter != '' )
					{
						
						RemoveAttrib( 'RDP_CodArtProd' , '' , Filter , '' , '' , 'BDG_CODART' , '8' );
					}
				}catch( e ){};
			}
		}
		
	}catch( e ) {};
		

}




function MessageBox( Text , Title , ICO , w , h)
{


	var path = document.location.pathname.toUpperCase();
	
	var vp = path.split('/');
	

	for( i = 0 ; i < vp.length ; i++ )
	{
		if( vp[i] == 'CTL_LIBRARY' )
		{
			path = '/' + vp[ i - 1 ] + '/' + vp[i] + '/';
		
			break;
		}
	
	}


	//var w = 400;
	//var h = 250;
	var Left = (screen.availWidth-w)/2;
	var Top  = (screen.availHeight-h)/2;
	var strPosition = ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h ;
		

	ExecFunction( path + 'MessageBoxWin.asp?ML=yes&MSG=' + Text +'&CAPTION=' + Title + '&ICO=' + ICO , 'MSGBOX' , strPosition );


}