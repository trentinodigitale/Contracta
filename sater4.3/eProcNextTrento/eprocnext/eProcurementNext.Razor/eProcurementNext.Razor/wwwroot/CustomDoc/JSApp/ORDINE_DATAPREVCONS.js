function MyExecDocProcess( param ) 
{
    ck_VD( getObj('RDP_DataPrevCons_V') );
    if( getObj('RDP_DataPrevCons').value == '' )
    {
        alert( 'Verificare il contenuto del campo data, non puo\' essere vuoto' );
        return;
    }
    ExecDocProcess( param );
}
