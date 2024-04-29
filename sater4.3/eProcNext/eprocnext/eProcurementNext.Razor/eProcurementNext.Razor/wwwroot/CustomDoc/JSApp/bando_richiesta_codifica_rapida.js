 window.onload = onloadpage;  
 
 function onloadpage()
 {
	
	
	
	if ( getObj('Complex').value == '0' )
	{
		ShowCol( 'PRODOTTI' , 'Variante' , 'none' );
	}
	if ( getObj('Divisione_lotti').value == '0' )
	{
		ShowCol( 'PRODOTTI' , 'NumeroLotto' , 'none' );
		ShowCol( 'PRODOTTI' , 'Voce' , 'none' );
	}
		if ( getObj('Divisione_lotti').value != '0' )
	{
		ShowCol( 'PRODOTTI' , 'NumeroRiga' , 'none' );
		
	}
	
	//PER OGNI RIGA VERIFICO SE SVUOTARE LE CELLE NON UTILI IN BASE ALL'AMBITO
	colonne_valide();
	
		
}

function onchange_ambito(grid,riga,colonna)
{
	ambito=getObjValue('R' + riga + '_MacroAreaMerc');
	elabora_riga(grid,ambito,riga);
	hidecolonne();
	
}
 
function elabora_riga(grid,ambito,row)
{
	try
	{
		//NELLA COLONNA TECNICA SONO PRESENTI LE COLONNE CHIAVI COLLEZIONATE PER AMBITO 
		var str=getObj('colonnatecnica').value.split('@@@');
		
		elenco_key_per_ambito=str[ambito-1].split('###');
		
		colonne_di_lavoro=',NumeroLotto,Voce,NumeroRiga,Variante,MacroAreaMerc,Descrizione,DESCRIZIONE_CODICE_REGIONALE,TipoDoc,CODICE_REGIONALE,';
		
		COL_NAME='';
		
		for( k = 0 ; k <= 100 && COL_NAME != undefined ; k++ )
		{	
			COL_NAME = GetColName( grid,k,'');
			//alert(COL_NAME);
			//if ( COL_NAME != undefined && COL_NAME != 'EsitoRiga' && COL_NAME != 'FNZ_DEL')
			if ( COL_NAME != undefined )
			{
				
				if (COL_NAME.toUpperCase() != 'ESITORIGA' && COL_NAME.toUpperCase() != 'FNZ_DEL') 
				{
					if ( colonne_di_lavoro.indexOf(','+ COL_NAME +',') < 0 && elenco_key_per_ambito[1].indexOf(','+ COL_NAME +',') < 0 )
					{					
														
						//getObj( 'PRODOTTIGrid_r' + row + '_c' + k  ).style.visibility='hidden';
						
						//PARTE DALLA CELLA PADRE E CICLA SU TUTTI I FIGLI
						c = getObj( 'PRODOTTIGrid_r' + row + '_c' + k  ).children;					
						
						for (v = 0; v < c.length; v++) 
						{
							c[v].style.visibility='hidden';
						}					
						
					}
					else
					{
						if (colonne_di_lavoro.indexOf(','+ COL_NAME +',') < 0)
						{
							//PARTE DALLA CELLA PADRE E CICLA SU TUTTI I FIGLI
							c = getObj( 'PRODOTTIGrid_r' + row + '_c' + k  ).children;		
						
							for (v = 0; v < c.length; v++) 
							{
								c[v].style.visibility='';
							}		
						}
							
					}
				}
			}
			
		}
	}catch(e){};	
	
	return;
	
}

function colonne_valide()
{
	try
	{
		//PER OGNI RIGA DELLA PAGINA VERIFICO SE NASCONDERE INFORMAZIONI IN BASE ALL'AMBITO	
		var curpage=getObjValue('PRODOTTIGrid_CurPage');	
		
		nEndRow = ( curpage )  * SP_NumRowForPage_SP_PRODOTTI;		
		nstartrow= nEndRow - SP_NumRowForPage_SP_PRODOTTI;
		
		
		//alert(PRODOTTIGrid_StartRow);
		if(  Number( nEndRow ) > 0 )
		{
			for( i = nstartrow ; i <= nEndRow ; i++ )
			{
				ambito=getObjValue('R' + i + '_MacroAreaMerc');
				elabora_riga('PRODOTTIGrid',ambito,i);				
			}		
			
		}
	}catch(e){};
	
	hidecolonne();
}

function hidecolonne()
{
	//PER OGNI RIGA DELLA PAGINA VERIFICO SE NASCONDERE INFORMAZIONI IN BASE ALL'AMBITO	
	var curpage=getObjValue('PRODOTTIGrid_CurPage');	
	colonne_di_lavoro=',NumeroLotto,Voce,NumeroRiga,Variante,MacroAreaMerc,Descrizione,DESCRIZIONE_CODICE_REGIONALE,TipoDoc,CODICE_REGIONALE,';
	COL_NAME='';
	colonne_da_nascondere='';
	colonne_da_vedere='';
	nEndRow = ( curpage ) * SP_NumRowForPage_SP_PRODOTTI;		
	nstartrow=nEndRow-SP_NumRowForPage_SP_PRODOTTI;
	
	COL_NAME='';
	for( k = 0 ; k <= 100 && COL_NAME != undefined ; k++ )
	{
		COL_NAME=GetColName( 'PRODOTTIGrid',k,'');
		nascondere='si';
		
		if ( COL_NAME != undefined )
		//if ( COL_NAME != undefined && COL_NAME != 'EsitoRiga' && COL_NAME != 'FNZ_DEL')
		{
			if (COL_NAME.toUpperCase() != 'ESITORIGA' && COL_NAME.toUpperCase() != 'FNZ_DEL') 
			{
				try
				{
					 for( i = nstartrow ; i < nEndRow && nascondere == 'si' ; i++ )
					 {
						if ( getObj( 'PRODOTTIGrid_r' + i + '_c' + k  ).children[0].style.visibility == '' )
						{
							nascondere='no';
						}
					 }
				}catch(e){}
			
				if ( nascondere == 'si' )
				{
					if (colonne_di_lavoro.indexOf(','+ COL_NAME +',') < 0)
					{
						colonne_da_nascondere=colonne_da_nascondere + ','+ COL_NAME + ',';
					}
				}
				else
				{
					if (colonne_di_lavoro.indexOf(','+ COL_NAME +',') < 0)
					{
						colonne_da_vedere=colonne_da_vedere + ','+ COL_NAME + ',';
					}
					
				}
				
			}else
				colonne_da_vedere=colonne_da_vedere + ','+ COL_NAME + ',';
		
		}
	}
	
	
	//alert('vedere=' + colonne_da_vedere);
	//alert('nascosto=' + colonne_da_nascondere);
	
	hide_col=colonne_da_nascondere.split(',');	
	
	for( k = 0 ; k <= hide_col.length  ; k++ )
	{
		if ( hide_col[k] != '' )
		{
			ShowCol( 'PRODOTTI' , hide_col[k] , 'none' );
		}
	}
	
	
	view_col=colonne_da_vedere.split(',');	
	
	for( k = 0 ; k <= view_col.length  ; k++ )
	{
		if ( view_col[k] != '' )
		{
			ShowCol( 'PRODOTTI' , view_col[k] , '' );
		}
	}
	
	
}


function PRODOTTI_AFTER_COMMAND()
{
	onloadpage();
}

function afterProcess(param) 
{
    
	
	
}






