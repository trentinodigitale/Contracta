function MyDettagliDel ( grid , r , c )
{
    if( r == 0 )
    {
        alert( 'La cancellazione non e\' possibile' );
        return;
    }
    DettagliDel ( grid , r , c );
}