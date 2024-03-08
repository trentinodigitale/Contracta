
    
function LISTA_OnLoad()
{
    var NomeModello = getObj( 'ModelloOfferta_Drill' ).value;
    LISTA.location = '../../DASHBOARD/Viewer.asp?TOOLBAR=&Table=PDA_DRILL_MICROLOTTO_OFFERTA_ROW_VIEW&ModGriglia=' + NomeModello + '&JSCRIPT=PDA_MICROLOTTI&IDENTITY=Id&DOCUMENT=ESITO&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=&Height=0,100*,0&numRowForPag=15&Sort=Graduatoria&SortOrder=asc&Exit=no&ShowExit=0&FilterHide=IdRow = ' + getObj('IDDOC').value ;

}

