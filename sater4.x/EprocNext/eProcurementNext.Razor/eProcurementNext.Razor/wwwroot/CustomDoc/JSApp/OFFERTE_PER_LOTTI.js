window.onload = OnLoadPage;

function MyOpenViewer(objGrid , Row , c)
{
	var cod;
	var idGara;
	
	//Recupero il numero del lotto
	cod = GetIdRow( objGrid , Row , 'self' );
	
	idGara = getObjValue('R' + Row + '_idHeader');
	
	OpenViewer('Viewer.asp?Table=LISTA_OFFERTE_PER_LOTTO&ModelloFiltro=&ModGriglia=BANDO_GARA_LISTA_OFFERTE_LOTTOGriglia&Filter=LinkedDoc%3D' + idGara + '%20and%20NumeroLotto%20%3D%20' + cod + '&IDENTITY=ID&lo=base&HIDE_COL=lottiOfferti&DOCUMENT=&PATHTOOLBAR=../CustomDoc/&JSCRIPT=OFFERTE_PER_LOTTI&AreaAdd=no&Caption=Offerte per Lotto&Height=180,100*,210&numRowForPag=20&Sort=Id&SortOrder=asc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_OFFERTE_PER_LOTTO&ACTIVESEL=&FilterHide=&FILTER_BUTTON=');
}

function EsportaOfferteInXLSX()
{
	alert(1);
}

function OnLoadPage() 
{
	//document.getElementsByClassName('SinteticHelp_Tab')[0].style.display = 'none';
}

