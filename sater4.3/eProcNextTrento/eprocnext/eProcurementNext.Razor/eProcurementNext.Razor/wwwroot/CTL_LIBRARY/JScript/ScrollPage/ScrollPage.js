

function DrawScrollPage(  Id , NumTotRow , NumRowForPage , CurRow, URL, Target , numPagToShow ,Style ,pathImg )
{
	var numPag;  //-- numero di pagine
	var html;    //-- TABELLA html che contiene la barra di paginazione
	var curPag;  //-- pagina corrente
	var startPag;  //-- pagina corrente
	var i;
	var html;
	var incP;
	var incC;
	
	var Type = '';
	
	try
	{
		Type = SP_Type;
	}catch( e ) {};
	//debugger;
	
	var appUrl;
	appUrl =  URL;

	while( appUrl.search( '\'' ) != -1 )
		appUrl = appUrl.replace( '\'' , '--appice--speronon-esista-uguguale--' );
	

	while( appUrl.search( '--appice--speronon-esista-uguguale--' ) != -1 )
		appUrl = appUrl.replace( '--appice--speronon-esista-uguguale--' , '\\\'' );
	
	//Vado ad aggiornare il valore di lo= dinamicamente con quello presente sulla QS kpf 518815	
	appUrl = appUrl.replace( 'lo=content' , 'lo=' + getQSParam('lo') );

	//alert( appUrl );
	
	//-- determina un limite sul numero di righe che possono essere visualizzate nella pagina
	if( NumRowForPage < 1 ){NumRowForPage = 1;}
	if( NumRowForPage > 1000 ){	NumRowForPage = 1000;}
	
	if (NumTotRow % NumRowForPage > 0 ){ incP = 1; }else{ incP = 0;}
	if (CurRow % NumRowForPage > 0 ) {incC = 1; }else {incC = 0;}
	
	numPag = (NumTotRow -(NumTotRow % NumRowForPage)) / NumRowForPage + incP;
	curPag = (CurRow - (CurRow % NumRowForPage)) / NumRowForPage + incC;
	
	if( numPag < 1 ){ numPag = 1;}
	if( curPag < 1 ){ curPag = 1;}
	
	//-- determina il numero di link diretti da visualizzare
	if( numPagToShow > numPag )
	{
		numPagToShow = numPag;
	}	
	
	
	//-- apro la tabella della barra di paginazione
	html =  '<table class=\"' + Style + '_Bar\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" ><tr>\n';

	if( Type == '' )
	{
		//-- disegno indicazione della pagina corrente sul totale delle pagine
		html = html + '<td class=\"' + Style + '_Pag\" nowrap >  Pag. ' + curPag + ' / ' + numPag + '</td>\n';
		//-- metto una cella vuota come separazione
		html = html + '<td>&nbsp;</td>\n';
		
	
		//-- disegno il bottone per tutto a sinistra
		if( curPag > 1 )
		{
			if ( isSingleWin() )
			{
				html = html + '<td class=\"' + Style + '_Button\"><button class=\"scroll_page_button\" onclick=\"javascript:GotoPage( \'' + appUrl + '\' ,\'' + Target + '\' ,\'' + Id + '\' , 1 , ' + NumRowForPage + ' , ' + NumTotRow + ' , ' + numPagToShow + ' ,  \'' + Style + '\' , \'' + pathImg + '\'  );\"><img src=\"' + pathImg + 'AllRewind.gif\"/></button></td>\n';
			}
			else
			{
				html = html + '<td class=\"' + Style + '_Button\" onclick=\"javascript:GotoPage( \'' + appUrl + '\' ,\'' + Target + '\' ,\'' + Id + '\' , 1 , ' + NumRowForPage + ' , ' + NumTotRow + ' , ' + numPagToShow + ' ,  \'' + Style + '\' , \'' + pathImg + '\'  );\"><img border=\"0\" src=\"' + pathImg + 'AllRewind.gif\"></td>\n';
			}
			
		}else{
			html = html + '<td class=\"' + Style + '_Button\" ><img border=\"0\" src=\"' + pathImg + 'DisableAllRewind.gif\"></td>\n';
		}

		if ( isSingleWin() )
		{
			//-- disegno il bottone per -1
			if( curPag > 1 )
			{
				html = html + '<td class=\"' + Style + '_Button\"><button class=\"scroll_page_button\" onclick=\"javascript:GotoPage( \'' + appUrl + '\' ,\'' + Target + '\' ,\'' + Id + '\' , ' + (curPag - 1) + ' , ' + NumRowForPage + ' , ' + NumTotRow + ' , ' + numPagToShow + ' ,  \'' + Style + '\' , \'' + pathImg + '\'  );\"><img src=\"' + pathImg + 'Rewind.gif\"/></button></td>\n';
			}else{	
				html = html + '<td class=\"' + Style + '_Button\"><img src=\"' + pathImg + 'DisableRewind.gif\"/></td>\n';
			}
		}
		else
		{
			//-- disegno il bottone per -1
			if( curPag > 1 )
			{
				html = html + '<td class=\"' + Style + '_Button\" onclick=\"javascript:GotoPage( \'' + appUrl + '\' ,\'' + Target + '\' ,\'' + Id + '\' , ' + (curPag - 1) + ' , ' + NumRowForPage + ' , ' + NumTotRow + ' , ' + numPagToShow + ' ,  \'' + Style + '\' , \'' + pathImg + '\'  );\"><img border=\"0\" src=\"' + pathImg + 'Rewind.gif\"></td>\n';
			}else{	
				html = html + '<td class=\"' + Style + '_Button\" ><img border=\"0\" src=\"' + pathImg + 'DisableRewind.gif\"></td>\n';
			}			
		}
	}
	else
	{
		//-- disegno il bottone per -1
		if( curPag > 1 )
		{
			html = html + '<td class=\"' + Style + '_Button\" onclick=\"javascript:GotoPage( \'' + appUrl + '\' ,\'' + Target + '\' ,\'' + Id + '\' , ' + (curPag - 1) + ' , ' + NumRowForPage + ' , ' + NumTotRow + ' , ' + numPagToShow + ' ,  \'' + Style + '\' , \'' + pathImg + '\'  );\">Precedente</td>\n';
		}else{	
			html = html + '<td class=\"' + Style + '_Button_Dis\" >Precedente</td>\n';
		}
	}
	
	//-- metto una cella vuota come separazione
	html = html + '<td>&nbsp;</td>\n';
	

	//-- disegno i link diretti alle pagine
	startPag = parseInt( curPag - ( numPagToShow / 2 ));
	if( startPag < 1 ){ startPag = 1;}
	
	for( i = startPag ; i < startPag + numPagToShow && i <= numPag; i++ )
	{
		html = html + '<td>&nbsp;</td>\n';

		if ( i == curPag )
			html = html + '<td class=\"' + Style + '_Cur\" >[' +  i  + ']</td>\n';
		else
		{
			if ( isSingleWin() )
			{
				html = html + '<td class=\"' + Style + '_Direct\" ><input class=\"scroll_page_button\" type=\"button\" value=\"' +  i  + '\" onclick=\"javascript: GotoPage( \'' + appUrl + '\' ,\'' + Target + '\' ,\'' + Id + '\' , ' +i + ' , ' + NumRowForPage + ' , ' + NumTotRow + ' , ' + numPagToShow + ' , \'' + Style + '\' , \'' + pathImg + '\'  );\"/></td>\n';
			}
			else
			{
				html = html + '<td class=\"' + Style + '_Direct\" onclick=\"javascript: GotoPage( \'' + appUrl + '\' ,\'' + Target + '\' ,\'' + Id + '\' , ' +i + ' , ' + NumRowForPage + ' , ' + NumTotRow + ' , ' + numPagToShow + ' , \'' + Style + '\' , \'' + pathImg + '\'  );\">' +  i  + '</td>\n';
			}
		}
		
		html = html + '<td>&nbsp;</td>\n';
	}
	

	//-- metto una cella vuota come separazione
	html = html + '<td>&nbsp;</td>\n';


	if( Type == '' )
	{
	
		//-- disegno il bottone per più uno
		if ( curPag < numPag )
		{
			if ( isSingleWin() )
			{
				html = html + '<td class=\"' + Style + '_Button\" ><button class=\"scroll_page_button\" onclick=\"javascript:GotoPage( \'' + appUrl + '\' ,\'' + Target + '\' ,\'' + Id + '\' , ' + (curPag + 1) + ' , ' + NumRowForPage + ' , ' + NumTotRow + ' , ' + numPagToShow + ' , \'' + Style + '\' , \'' + pathImg + '\'  );\"><img border=\"0\" src=\"' + pathImg + 'Forward.gif\"/></button></td>\n';
			}
			else
			{
				html = html + '<td class=\"' + Style + '_Button\" onclick=\"javascript:GotoPage( \'' + appUrl + '\' ,\'' + Target + '\' ,\'' + Id + '\' , ' + (curPag + 1) + ' , ' + NumRowForPage + ' , ' + NumTotRow + ' , ' + numPagToShow + ' , \'' + Style + '\' , \'' + pathImg + '\'  );\"><img border=\"0\" src=\"' + pathImg + 'Forward.gif\"></td>\n';
			}
			
		}else{
			html = html + '<td class=\"' + Style + '_Button\" ><img border=\"0\" src=\"' + pathImg + 'DisableForward.gif\"></td>\n';
		}
	
		//-- disegno il bottone per tutto a desta
		if ( curPag < numPag )
		{
			if ( isSingleWin() )
			{
				html = html + '<td class=\"' + Style + '_Button\" ><button class=\"scroll_page_button\" onclick=\"javascript:GotoPage(  \'' + appUrl + '\' ,\'' + Target + '\' ,\'' + Id + '\' , ' + (numPag ) + ' , ' + NumRowForPage + ' , ' + NumTotRow + ' , ' + numPagToShow + ' ,  \'' + Style + '\' , \'' + pathImg + '\'   );\"><img src=\"' + pathImg + 'AllForward.gif\"/></button></td>\n';
			}
			else
			{
				html = html + '<td class=\"' + Style + '_Button\" onclick=\"javascript:GotoPage(  \'' + appUrl + '\' ,\'' + Target + '\' ,\'' + Id + '\' , ' + (numPag ) + ' , ' + NumRowForPage + ' , ' + NumTotRow + ' , ' + numPagToShow + ' ,  \'' + Style + '\' , \'' + pathImg + '\'   );\"><img border=\"0\" src=\"' + pathImg + 'AllForward.gif\"></td>\n';
			}
			
		}else{
			html = html + '<td class=\"' + Style + '_Button\" ><img border=\"0\" src=\"' + pathImg + 'DisableAllForward.gif\"></td>\n';
		}
	}
	else
	{
		//-- disegno il bottone per più uno
		if ( curPag < numPag )
		{
			html = html + '<td class=\"' + Style + '_Button\" onclick=\"javascript:GotoPage( \'' + appUrl + '\' ,\'' + Target + '\' ,\'' + Id + '\' , ' + (curPag + 1) + ' , ' + NumRowForPage + ' , ' + NumTotRow + ' , ' + numPagToShow + ' , \'' + Style + '\' , \'' + pathImg + '\'  );\">Successivo</td>\n';
		}else{
			html = html + '<td class=\"' + Style + '_Button_Dis\" >Successivo</td>\n';
		}
	}	


	//-- disegno cella per salto diretto
	
	
	
	//-- disegno cella per numero di righe nella pagina
	/*
	html = html + '<td> num rows';
	html = html + '<input type=\"text\" Id=\"NumRow_' + Id + '\"  name=\"NumRow_' + Id + '\" size=\"4\" value=\"' + NumRowForPage + '\" ';
	html = html + 'onchange=\"javascript:DrawScrollPage(  \'' + Id + '\' , ' + NumTotRow + ' , ' + Number( this.value ) + ' , ' + CurRow + ' , \'' +  appUrl + '\' , \'' + Target + '\' , ' + numPagToShow + '  , \'' + Style + '\' , \'' + pathImg + '\' );\"  >';
	html = html + '</td>';
	*/
	

	//-- disegno la combo per il salto pagina
	//debugger;
	if( numPag > numPagToShow &&  Type == '' ) 
	{
		html = html + '<td>'
		html = html + '<select value=\"' + curPag + '\" ';
		//html = html + 'onchange=\"javascript:DrawScrollPage(  \'' + Id + '\' , ' + NumTotRow + ' , ' + NumRowForPage + ' , ' + Number( this.value ) + ' , \'' +  appUrl + '\' , \'' + Target + '\' , ' + numPagToShow + '  , \'' + Style + '\' , \'' + pathImg + '\' );\"  >';
		html = html + ' onchange=\"javascript:  var p; p = new Number( this.value ); GotoPage( \'' + appUrl + '\' ,\'' + Target + '\' ,\'' + Id + '\' ,  p , ' + NumRowForPage + ' , ' + NumTotRow + ' , ' + numPagToShow + ' , \'' + Style + '\' , \'' + pathImg + '\'  );\">';

		for( i = 1 ; i <= numPag; i++ )
		{
		
			html = html + '<option value=\"' + i + '\" ';
			if( i == curPag ) html = html + ' selected ';
			html = html + ' >' +  i  + '</option>\n';
		}

		html = html + '</select></td>';
	}
	


	//-- chiusura della tabella
	html =  html + '</tr></table>\n';
	
	//alert( html );

	//-- sostituzione della tabella nella div
	getObj( Id ).innerHTML = html;

}

function RefreshSP( URL , Target , Id , curPag , NumRowForPage   , NumTotRow , numPagToShow  , Style ,pathImg )
{
	
	CurRow = ((curPag -1) * NumRowForPage) + 1 ;
	//-- ridisegna la barra di paginazione
	DrawScrollPage(  Id , NumTotRow , NumRowForPage , CurRow, URL, Target , numPagToShow ,Style ,pathImg )
}


//-- Chiama la pagina da ricaricare passandogli il numero  
function GotoPage( URL , Target , Id , curPag , NumRowForPage   , NumTotRow , numPagToShow  , Style ,pathImg )
{
	var LOC_strGotoPageFunc = ''

	CurRow = ((curPag -1) * NumRowForPage) + 1 ;
	//debugger;
	//-- ridisegna la barra di paginazione
	DrawScrollPage(  Id , NumTotRow , NumRowForPage , CurRow, URL, Target , numPagToShow ,Style ,pathImg )
	if ( Target == 'self' )
	{
		this.location = URL + '&nPag=' + curPag + '&numRowForPag='+ NumRowForPage ;
	}
	else
	{

		try{
			eval( 'LOC_strGotoPageFunc = SP_strGotoPageFunc_' + Id + ';' );
		}catch(e ){}
		
		//-- se è stata indicata una funzione particolare per il salto pagina viene invocata
		if( LOC_strGotoPageFunc != ''  ) 
		{
			SP_strGotoPageFunc  = LOC_strGotoPageFunc;
		}

		//-- se è stata indicata una funzione particolare per il salto pagina viene invocata
		
		
		if ( SP_strGotoPageFunc == '' )
		{
			try{
				getObj( Target ).location = URL + '&nPag=' + curPag + '&numRowForPag='+ NumRowForPage ;
			}catch( e )
			{
				ExecFunction( URL + '&nPag=' + curPag + '&numRowForPag='+ NumRowForPage  , Target , '' );
			}
		}else{
		
			eval( SP_strGotoPageFunc + '(\'' + '&nPag=' + curPag + '&numRowForPag='+ NumRowForPage + '\' , \'' + Target + '\');' );
		
		}
		
	}
}


