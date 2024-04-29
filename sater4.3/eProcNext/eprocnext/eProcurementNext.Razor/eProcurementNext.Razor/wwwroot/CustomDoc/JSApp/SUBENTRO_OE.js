window.onload=jsOnLoad;

function jsOnLoad()
{
	var idpfuCessato = getObj('Utente').value;
	var filter =  'SQL_WHERE= idpfu in ( select idpfu from profiliutente where pfudeleted=0 and pfuidazi = ( select pfuidazi from profiliUtente where idpfu = ' + idpfuCessato + ' ))';
	 var DOCUMENT_READONLY = getObjValue('DOCUMENT_READONLY');
	try
	{
		
		//if( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' || iddoc.substr(0,3) == 'new' )
		if ( DOCUMENT_READONLY == "0"  )
			
		{
			FilterDom( 'IdPfuSubentro' , 'IdPfuSubentro' , getExtraAttrib('val_IdPfuSubentro' , 'value' ) , filter ,'', '');
				
		}
	

	
	}
	catch(e)
	{
		
	}
}

function ListaGareExcel(QS)
{
	var win;

	win = ExecFunction( '../../dashboard/viewerExcel.asp?OPERATION=EXCEL' +  '&'  + QS + '&'  , '' , '' );
}

function MyGrid_SelectAll(id)
{
	var i;
	var result = '';
	var NumRow = eval( id + '_EndRow;' );
	var nStartRow=eval( id + '_StartRow;' );
	var clsName;
	
	for ( i = nStartRow ; i <= NumRow ; i++ )
	{
		try 
		{
			//-- imposto il check	
			eval( id + '_SelectedRow[ ' + ( i - nStartRow) + '] = 1;' );
			
			try{ getObj('R' + (i-nStartRow) + '_Checkcessati').checked = true; }catch(e){};
			
		
			//-- recupero lo style della riga ed invoco il cambio di style
			if ( i % 2 ) 
			{
				clsName = eval( id + '_StyleRow1;' );
			}
			else
			{
				clsName = eval( id + '_StyleRow0;' );
			}
	
			G_SetRC( id , clsName ,i );
			
		}
		catch(e)
		{
		}
	}
}

function MyGrid_DeselectAll(id)
{
	var i;
	var result = '';
	var NumRow = eval( id + '_EndRow;' );
	var nStartRow=eval( id + '_StartRow;' );
	var clsName;

	//objcheck= eval( 'document.FormViewerGriglia.' + id + '_SEL' ) ;
	objcheck = document.getElementsByName(id + '_SEL');

	for ( i = nStartRow ; i <= NumRow ; i++ )
	{
		try {
			eval( id + '_SelectedRow[ ' + ( i - nStartRow) + '] = 0;' );
			
			try{ getObj('R' + (i-nStartRow) + '_Checkcessati').checked = false; }catch(e){};

			//-- recupero lo style della riga ed invoco il cambio di style
			if ( i % 2 ) 
			{
				clsName = eval( id + '_StyleRow1;' );
			}
			else
			{
				clsName = eval( id + '_StyleRow0;' );
			}
	
			G_SetRC( id , clsName ,i );
		}catch(e){
		}
	}
}

function MyGrid_InvertSelection(id)
{
	var i;
	var result = '';
	var NumRow = eval( id + '_EndRow;' );
	var nStartRow=eval( id + '_StartRow;' );
	var clsName;

	//objcheck= eval( 'document.FormViewerGriglia.' + id + '_SEL' ) ;
	objcheck = document.getElementsByName(id + '_SEL');

	for ( i = nStartRow ; i <= NumRow ; i++ )
	{
		try {
			
			
			try
			{ 
			
				if ( getObj('R' + (i-nStartRow) + '_Checkcessati').checked == false )
				{
					getObj('R' + (i-nStartRow) + '_Checkcessati').checked = true;
					eval( id + '_SelectedRow[ ' + ( i - nStartRow) + '] = 1;' );
				}
				else
				{
					getObj('R' + (i-nStartRow) + '_Checkcessati').checked = false; 	
					eval( id + '_SelectedRow[ ' + ( i - nStartRow) + '] = 0;' );
				}
				
				
				
			}catch(e){};

			//-- recupero lo style della riga ed invoco il cambio di style
			if ( i % 2 ) 
			{
				clsName = eval( id + '_StyleRow1;' );
			}
			else
			{
				clsName = eval( id + '_StyleRow0;' );
			}
	
			G_SetRC( id , clsName ,i );
		}catch(e){
		}
	}
}


function DownLoadXLSX()
{
   ExecFunction('../../CTL_Library/accessBarrier.asp?goto=xlsx.aspx&TitoloFile=Subentro_oe_Lista_Documenti_Competenza&FILTER=&TIPODOC=SUBENTRO_OE&MODEL=SUBENTRO_OE_LISTA_XLSX&VIEW=SUBENTRO_OE_LISTA_VIEW_XLSX&HIDECOL=&Sort=DataCreazione desc&IDDOC=' + getObjValue('IDDOC'), '_blank', '');
}