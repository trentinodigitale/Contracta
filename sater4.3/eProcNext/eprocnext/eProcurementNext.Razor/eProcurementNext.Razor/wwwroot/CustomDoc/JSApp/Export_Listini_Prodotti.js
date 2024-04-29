function MyExcelDestinatari (param)
{
	var QS = getObj('QueryString').value;
	
	if ( QS.toUpperCase().indexOf("FILTER") >= 0 )
	{	
		var filtri = QS.slice(QS.indexOf('&Filter=') + 1);
		
		param = param + "&" + filtri
	}
	
	var idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	var lottoTemp = Grid_GetElementSelectedRow( 'GridViewer', 'NumeroLotto', false )
	var pivaTemp = Grid_GetElementSelectedRow( 'GridViewer', 'PIvaOperatoreEconomico', true )
	var rowID = idRow.replaceAll('~~~', ',');
	var lotto = lottoTemp.replaceAll('~~~', ',');
	var piva = pivaTemp.replaceAll('~~~', ',');
	
	var filterId = 'filterhide='
	
	if (rowID != "")
	{
		filterId = filterId + 'id in ('+ rowID +')'
		param = param.replaceAll('FilterHide=&', '') + "&" + filterId
	
		if (lotto != "")
		{
			filterId = filterId + ' and NumeroLotto in ('+ lotto +')'			
		}
		
		if (piva != "")
		{
			filterId = filterId + ' and PIvaOperatoreEconomico in ('+ piva +')'		
		}
		
		win = ExecFunction( 'viewerExcel_x.asp?OPERATION=EXCEL' +  '&'  + param  , '' , '' );
	}
	else
	{
		DMessageBox('../', 'E\' necessario selezionare almeno una riga', 'Attenzione', 1, 400, 300);
	}
	
	
	
	
}

function openRiepilogo(a, row, b)
{
	var id = getObj('R'+ row +'_id').value
	var lotto = getObj('R'+ row +'_NumeroLotto').value
	var piva = getObj('R'+ row +'_PIvaOperatoreEconomico').value
	var filter = "id = "+ id +" and NumeroLotto = "+ lotto +" and PIvaOperatoreEconomico = '"+ piva +"'"
	
	OpenViewer('Viewer.asp?STORED_SQL=yes&ModGriglia=Export_Listini_Prodotti_Stmp&Table=DASHBOARD_SP_VIEW_Export_Listini_Prodotti&OWNER=&IDENTITY=id&TOOLBAR=toolbar_Export_Listini_Prodotto&DOCUMENT=REPORT&PATHTOOLBAR=./&AreaAdd=no&Height=160,100*,210&numRowForPag=25&Sort=&SortOrder=&ACTIVESEL=1&FilterHide='+filter+'&FILTERCOLUMNFROMMODEL=yes&AreaFiltroWin=open&PropHide=&CAPTION=Report | Export listini prodotti&ShowExit=0&JSCRIPT=../../customdoc/jsapp/Export_Listini_Prodotti&lo=base')

}

function Grid_GetElementSelectedRow( id, elementName, isString )
{
	var i;
	var result = '';
	var NumRow = eval( id + '_EndRow;' );
	var nStartRow=eval( id + '_StartRow;' );
	var app = '';
	
	for ( i = nStartRow ; i <= NumRow ; i++ )
	{
		try {
			if( eval( id + '_SelectedRow[ ' + ( i - nStartRow ) + '];' ) == 1 )
			{
				
				app = GetElementRow( id , i , '', elementName, isString );
				if ( app != '' )
				{
					if ( result != '' ) result = result +  '~~~';
					result = result + app;
				}
			}
		}catch(e){
		}
	}
	
	return result;

}

function GetElementRow( grid , numRow , Page, elementName, isString )
{
	var objInd;
	var valueret;
	
	indSel = -1;
	
	try
	{
		//-- Prendo l'identificativo della riga passato l'indice della riga
		if( numRow >= 0 )
		{
			//-- prelevo il valore dell'identificativo
			
			objInd = getObj( 'R' + numRow + '_' + elementName +'' );
			
			
			try
			{
				if (isString == true)
				{
					valueret = "'"+ objInd.value + "'"
				}
				else
				{
					valueret= objInd.value;
				}
			}
			catch(e)
			{
				
			}

			return valueret

		}
		else
			return '';
		
	}
	catch(  e ){ return ''; 	};

}




