
function OpenCollegati( )
{
  
	var Fascicolo = '';
	try	{ 	Fascicolo = getObjValue( 'Fascicolo')	}catch( e ) {};

	
	var URL = '../dashboard/mainView.asp?A=A&FOLDER_GROUP=LINKED_ISCRIZIONE_ALBO&FilterHide= Fascicolo = \'' + Fascicolo + '\' ';
	
	
	parent.parent.parent.DocumentiCollegati( URL );

}

function OFFERTA_OnLoad()
{
    ShowCol( 'OFFERTA' , 'EsitoRiga' , 'none' );
    ShowCol( 'OFFERTA' , 'ValoreOfferta' , 'none' );
	
}

function ShowCol( Section , idCol , Show )
{
    var ColName = Section  + 'Grid_' + idCol ;
    var objGrid = getObj( Section  + 'Grid' );
    
    var h = objGrid.rows.length;
    var w = objGrid.rows[0].cells.length;
    var x,y;

    for( x = 0 ; x < w ; x++ )
    {
    
        if ( objGrid.rows[0].cells[x].id == ColName ) 
        {
            for( y = 0 ; y < h ; y++ )
            {
                objGrid.rows[y].cells[x].style.display = Show ;
            }
            break; 
        }
    }
}