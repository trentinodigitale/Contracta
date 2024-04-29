function RefreshContent()
{
    RefreshDocument('');
}



function My_Doc_DettagliDel( grid , r , c )
{
	var v = '';
	try
	{
		v = getObj( 'RDETTAGLIGrid_' + i + '_StatoFunzionale' ).value;
	}catch(e){};
	
    if( v == 'In Lavorazione' )
    {
        //DMessageBox( '../' , 'La documentazione è obbligatoria' , 'Attenzione' , 1 , 400 , 300 );
    }
    else
    {
        DettagliDel( grid , r , c );
    }
}



function HideCestinodoc()
{
    try{
        var i = 0;
		
		if (getObj('StatoDoc').value== 'Saved' )
		{
			for( i=0; i < DETTAGLIGrid_EndRow+1 ; i++ )
			{
				if( getObj( 'RDETTAGLIGrid_' + i + '_StatoFunzionale' ).value != 'In Lavorazione' )
				{
					getObj( 'DETTAGLIGrid_r' + i + '_c0' ).innerHTML = '&nbsp;';
				}
			}
		}
    }catch(e){}

}


window.onload = InitComunicazione;


function InitComunicazione(){
  
  //cambio titolo secondo il valore di JumpCheck
  var strJumpCheck=getObj('JumpCheck').value;
  
  //recupero tabella caption
  var ainfo=strJumpCheck.split('-');
  var strTipoComumnicazione = ainfo[1];
  
  switch (strTipoComumnicazione){
		
    case 'ESCLUSIONE':
            $(".Caption tr td:eq(1)").text(CNV ('../../' , 'Ditte Escluse' ));          	
            break;
			
	 case 'ESCLUSIONE_MANIFESTAZIONE':
            $(".Caption tr td:eq(1)").text(CNV ('../../' , 'Ditte Escluse' ));          	
            break;
                    
		case 'CHIARIMENTI','GENERICA':	
		        $(".Caption tr td:eq(1)").text(getObj('Titolo_V').innerHTML);    
            break;
    
    case 'SORTEGGIO':
            $(".Caption tr td:eq(1)").text(CNV ('../../' , 'Ditte Sorteggiate' ));          	
		        break;
	case 'VERIFICA_AMMINISTRATIVA':
				$( "#cap_RichiestaRisposta").parents("table:first").css({"display":"none"})
				$( "#cap_DataScadenza").parents("table:first").css({"display":"none"})
				break;
	case 'OFFERTA' :
				$( "#cap_DataDocumento").parents("table:first").css({"display":"none"})
				$( "#cap_CanaleNotifica").parents("table:first").css({"display":"none"})
				break;
  }
  
  HideCestinodoc;
}


/*
commentato perchè tolto &JSOnLoad=yes dalla sezione
function DETTAGLI_OnLoad()
{
  
  if (getObj('JumpCheck').value=='1-OFFERTA' || getObj('StatoDoc').value != 'Saved'){
    DETTAGLI.location ='../../DASHBOARD/Viewer.asp?ModGriglia=&Table=VIEW_PDA_COMUNICAZIONE_DETTAGLI&OWNER=&IDENTITY=ID&TOOLBAR=&PATHTOOLBAR=../customdoc/&JSCRIPT=LISTA_PDA_COMUNICAZIONE&AreaFiltro=no&HEIGHT=300,300*,300&FilteredOnly=no&Sort=&SortOrder=&DOCUMENT=PDA_COMUNICAZIONE&FilterHide=statodoc <> \'invalidate\' and LinkedDoc=' + getObj('IDDOC').value + '&AreaAdd=no&ACTIVESEL=1&numRowForPag=20' ;
  }
  else{
    DETTAGLI.location ='../../DASHBOARD/Viewer.asp?ModGriglia=&Table=VIEW_PDA_COMUNICAZIONE_DETTAGLI&OWNER=&IDENTITY=ID&TOOLBAR=PDA_COMUNICAZIONE_DETTAGLI_TOOLBAR&PATHTOOLBAR=../customdoc/&JSCRIPT=LISTA_PDA_COMUNICAZIONE&AreaFiltro=no&HEIGHT=300,300*,300&FilteredOnly=no&Sort=&SortOrder=&DOCUMENT=PDA_COMUNICAZIONE&FilterHide=statodoc <> \'invalidate\' and LinkedDoc=' + getObj('IDDOC').value + '&AreaAdd=no&ACTIVESEL=2&numRowForPag=20' ;
  }
	
}
*/
