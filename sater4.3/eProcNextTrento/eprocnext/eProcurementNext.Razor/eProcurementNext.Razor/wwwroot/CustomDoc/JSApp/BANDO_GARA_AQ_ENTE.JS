
function EsportaOfferteInXLSX() 
{
	var extraHideCol = '';
	
	if (getObjValue('Divisione_lotti') == '0') 
	{
		extraHideCol = ',lottiOfferti';		
	}
	
    ExecFunction('../../CTL_Library/accessBarrier.asp?goto=xlsx.aspx&TitoloFile=offerte&FILTER=linkeddoc%3D' + getObjValue('IDDOC') + '&TIPODOC=OFFERTA&MODEL=BANDO_SDA_LISTA_OFFERTEGriglia&VIEW=BANDO_SDA_LISTA_OFFERTE&HIDECOL=FNZ_OPEN,Name' + extraHideCol + '&Sort=DataInvio%20asc&IDDOC=' + getObjValue('IDDOC'), '_blank', '');
}
