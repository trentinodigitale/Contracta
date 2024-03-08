
window.onload=Onchange_Selezione;
function afterProcess( Proc )
{
        if ( Proc == 'CREA_RILANCIO' ) 
        {
            NuovoRilancio();
        }

}

function NuovoRilancio()
{

    try
    {
        if( isSingleWin() == true )
        {
            LoadDocument('BANDO_GARA' , getObjValue('idDoc') );
        }
        else
        {
			ShowDocumentPath( 'BANDO_GARA' , getObjValue('idDoc') , '../');
        }
    }
    catch( e ) {};
    
      
    
}
//per consentire solo selezioni coerenti: alla selezione della prima riga,
//si disattivano tutte quelle che hanno un valore differente nella composizione degli idonei
//controllo fatto per aziragionesociale
function Onchange_Selezione(obj)
{
	aziragionesociale_sel='';
	if ( typeof obj.value !== 'undefined' )
	{
		k = obj.id.split('_');
		Seleziona = obj.value;
		
		if ( Seleziona == 'Inserito')
			aziragionesociale_sel=getObjValue( k[0] +'_aziRagioneSociale');
	}
	
	
	numrighe=GetProperty(getObj('LOTTIGrid'), 'numrow');
	
	for (i = 0; i <= numrighe; i++) 
	{
		if (getObjValue('R' + i +'_NotEditable').indexOf(' StatoRiga ') < 0) 
		{
			if ( getObjValue('R' + i +'_StatoRiga') == 'Inserito' && aziragionesociale_sel=='' )
				aziragionesociale_sel=getObjValue('R' + i +'_aziRagioneSociale')
			
			if ( getObjValue('R' + i +'_aziRagioneSociale') != aziragionesociale_sel )
				SelectreadOnly('R' + i + '_StatoRiga',true);
		}
	}
	//CASO IN CUI HO DESELEZIONATO TUTTO, QUINDI RIATTIVO QUELLE CHE INIZIALMENTE LO ERANO
	if ( aziragionesociale_sel == '' )
	{
		for (i = 0; i <= numrighe; i++) 
		{
			if (getObjValue('R' + i +'_NotEditable').indexOf(' StatoRiga ') < 0) 
			{
				SelectreadOnly('R' + i + '_StatoRiga',false);
			}
		}
	}
	
}

