window.onload = Resize_Plus;


function Resize_Plus(){
	try{ ResizeGrid( 'Grid' ); }catch(e){}
}



function PrintPdf_Tabella( strUrlPage )
{
	var w;
	var h;
	
	
	
	//CheckFirmaEBlocco( strUrlPage );

	try 
	{

		

		if ( getObj( 'WHERE_SQL' ) )
			WHERE_SQL = getObj( 'WHERE_SQL' ).value;
		
		
		
		strUrlPage = strUrlPage + 'WHERE_SQL=' + escape( WHERE_SQL ) +'&';
		
		
		//determino se sto lavorando con idheader oppure con idlottopda
		WHERE_SQL = WHERE_SQL.toUpperCase();
		//WHERE_SQL = WHERE_SQL.replace(' ','');
		WHERE_SQL = ReplaceExtended(WHERE_SQL,' ','');
		//alert(WHERE_SQL);
		vet = WHERE_SQL.split( '=' );
		
		strColIdentity = vet[0];
		
		IDDOC=vet[1];
		IDDOC = ReplaceExtended(IDDOC,'\'','');
		
		//cambiamo vista per il footer a seconda di come entro sulla vista
		strViewHeader_Footer = 'DASHBOARD_VIEW_LOTTO_PUNTEGGI_ESPRESSI_HF_Stampe';
		
		if ( strColIdentity == 'IDLOTTOPDA' ) 
			strViewHeader_Footer = 'DASHBOARD_VIEW_LOTTO_PUNTEGGI_ESPRESSI_LOTTO_HF_Stampe';
		
		//alert(strViewHeader_Footer);
		
		w = screen.availWidth-100;
		h = screen.availHeight-100;

		var pathToRoot = '../../';

		if ( isSingleWin() )
			pathToRoot = pathRoot;

		TYPEDOC='';
			
		ExecFunction( pathToRoot + 'ctl_library/pdf/pdf.asp?PDF_NAME=TabellaPunteggi&URL=' +  encodeURIComponent ( strUrlPage ) + '&VIEW_FOOTER_HEADER=' + strViewHeader_Footer + '&IDDOC=' + IDDOC + '&TYPEDOC=' + TYPEDOC , 'PrintDocument' , ',menubar=yes,left=0,top=0,width=950,height=900');	
		
		
		//ExecFunction( '../' + strUrlPage , 'PrintDocument' , ',menubar=yes,left=0,top=0,width=950,height=900');	

	}
	catch(e)
	{
	}

}




function PrintPdf_Tabella_Tecnici( strUrlPage )
{
	var w;
	var h;
	
	
	
	//CheckFirmaEBlocco( strUrlPage );

	try 
	{

		

		if ( getObj( 'WHERE_SQL' ) )
			WHERE_SQL = getObj( 'WHERE_SQL' ).value;
		
		
		
		strUrlPage = strUrlPage + 'WHERE_SQL=' + escape( WHERE_SQL ) +'&';
		
		
		//determino se sto lavorando con idheader oppure con idlottopda
		WHERE_SQL = WHERE_SQL.toUpperCase();
		//WHERE_SQL = WHERE_SQL.replace(' ','');
		WHERE_SQL = ReplaceExtended(WHERE_SQL,' ','');
		//alert(WHERE_SQL);
		vet = WHERE_SQL.split( '=' );
		
		strColIdentity = vet[0];
		
		IDDOC=vet[1];
		IDDOC = ReplaceExtended(IDDOC,'\'','');
		
		//cambiamo vista per il footer a seconda di come entro sulla vista
		strViewHeader_Footer = 'DASHBOARD_VIEW_LOTTO_GIUDIZI_ESPRESSI_HF_Stampe';
		
		if ( strColIdentity == 'IDLOTTOPDA' ) 
			strViewHeader_Footer = 'DASHBOARD_VIEW_LOTTO_GIUDIZI_ESPRESSI_LOTTO_HF_Stampe';
		
		
		//alert(strViewHeader_Footer);
		
		w = screen.availWidth-100;
		h = screen.availHeight-100;

		var pathToRoot = '../../';

		if ( isSingleWin() )
			pathToRoot = pathRoot;

		TYPEDOC='';
			
		ExecFunction( pathToRoot + 'ctl_library/pdf/pdf.asp?PDF_NAME=TabellaPunteggi&URL=' +  encodeURIComponent ( strUrlPage ) + '&VIEW_FOOTER_HEADER=' + strViewHeader_Footer + '&IDDOC=' + IDDOC + '&TYPEDOC=' + TYPEDOC , 'PrintDocument' , ',menubar=yes,left=0,top=0,width=950,height=900');	
		
		//alert(strViewHeader_Footer);
	
		
		//ExecFunction( '..' + strUrlPage , 'PrintDocument' , ',menubar=no,left=0,top=0,width=950,height=900');	

	}
	catch(e)
	{
	}

}
