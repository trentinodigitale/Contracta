window.onload = OnLoadPage;

function OnLoadPage() 
{
	try 
	{	
		
		var DOC_TO_UPD=getQSParam('filterhide');	
		var v = DOC_TO_UPD.split( '=' );	
		var ID = v[1];		
		
		var s = 'SQL_WHERE= idazi in (select distinct idaziesecutrice  from dashboard_view_bando_conversazione where idpda = ' + ID + ' )';
		
		var filter =  GetProperty ( getObj('idAziEsecutrice'),'filter') ;
		
		if ( filter == '' || filter == undefined || filter == null )
		{
			SetProperty( getObj('idAziEsecutrice'),'filter', s);
		}
		/*
		else
		{
			if ( filter.indexOf('LEFT(DMV_CodExt,1) like \'[^a-z]\'') < 0 )
				SetProperty( getObj('idAziEsecutrice'),'filter',filter + ' and LEFT(DMV_CodExt,1) like \'[^a-z]\'');
		}
		*/
		
		//var s1 = 'SQL_WHERE= dmv_cod in (select distinct TipologiaComunicazione  from dashboard_view_pda_elenco_comunicazioni where idpda = ' + ID + ' )';
		
		//FilterDom('TipologiaComunicazione', 'TipologiaComunicazione', getObjValue('TipologiaComunicazione'), s1, '', '','', '../');
		
	} catch (e) {};
}

