
function move( field , row , verso ) 
{
    try
    {
        var f1 = getObj( 'RVALORIGrid_' + row + '_' + field );
        var f2 = getObj( 'RVALORIGrid_' + ( row + verso ) + '_' + field ) ;
        var app;
        app = f1.value;
        f1.value = f2.value;
        f2.value = app
    
    }catch(e){}

}

function ClickDown( grid , r , c )
{
    move( 'Descrizione' , r  , 1 );
}


function ClickUp( grid , r , c )
{
    move( 'Descrizione' , r  , -1 );
}