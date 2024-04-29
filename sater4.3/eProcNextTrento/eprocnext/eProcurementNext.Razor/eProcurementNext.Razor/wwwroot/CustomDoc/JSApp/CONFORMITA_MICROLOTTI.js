function LISTA_MICROLOTTI_OnLoad()
{

    var NomeModelloPDA = getObj( 'ModelloConformitaTestata' ).value;

    var StatoDoc = getObjValue( 'StatoDoc' );
    
    if ( StatoDoc == 'Saved' || StatoDoc == '' )
    {
        LISTA_MICROLOTTI.location = '../../DASHBOARD/Viewer.asp?TOOLBAR=CONFORMITA_LISTA_MICROLOTTI_TOOLBAR&Table=CONFORMITA_LISTA_MICROLOTTI_VIEW&ModGriglia=' + NomeModelloPDA + '&JSCRIPT=PDA_MICROLOTTI&IDENTITY=IdDettaglio&ACTIVESEL=2&DOCUMENT=CONFORMITA_MICROLOTTI_OFF&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=&Height=0,100*,0&numRowForPag=15&Sort=Ordinamento&SortOrder=asc&Exit=no&ShowExit=0&ROWCONDITION=BLACK,bRead=1~&FilterHide=idDoc = ' + getObj('IDDOC').value ;
    }
    else
    {
        LISTA_MICROLOTTI.location = '../../DASHBOARD/Viewer.asp?TOOLBAR=&Table=CONFORMITA_LISTA_MICROLOTTI_VIEW&ModGriglia=' + NomeModelloPDA + '&JSCRIPT=PDA_MICROLOTTI&IDENTITY=IdDettaglio&ACTIVESEL=1&DOCUMENT=CONFORMITA_MICROLOTTI_OFF&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=&Height=0,100*,0&numRowForPag=15&Sort=Ordinamento&SortOrder=asc&Exit=no&ShowExit=0&ROWCONDITION=BLACK,bRead=1~&FilterHide=idDoc = ' + getObj('IDDOC').value ;
    }

}