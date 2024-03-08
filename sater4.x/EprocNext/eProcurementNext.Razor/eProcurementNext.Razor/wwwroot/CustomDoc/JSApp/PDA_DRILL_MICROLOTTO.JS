
    
function LISTA_OnLoad()
{
    var NomeModello = getObj( 'ModelloPDA_DrillLista' ).value;
    LISTA.location = '../../DASHBOARD/Viewer.asp?TOOLBAR=&Table=PDA_DRILL_MICROLOTTO_LISTA_VIEW&ModGriglia=' + NomeModello + '&JSCRIPT=PDA_MICROLOTTI&IDENTITY=Id&DOCUMENT=ESITO&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=Lista partecipanti&Height=0,100*,0&numRowForPag=15&Sort=Graduatoria&SortOrder=asc&Exit=no&ShowExit=0&FilterHide=IdRowLottoBando = ' + getObj('IDDOC').value ;

}


function INFO_OnLoad()
{
    var NomeModello = getObj( 'ModelloPDA_DrillTestata' ).value;
    INFO.location = '../../DASHBOARD/ViewerInfo.asp?TOOLBAR=&Table=PDA_DRILL_MICROLOTTO_TESTATA_VIEW&MODELLO=' + NomeModello + '&JSCRIPT=&IDENTITY=Id&DOCUMENT=&Sort=Ordinamento&SortOrder=asc&Exit=no&ShowExit=0&FilterHide=id = ' + getObj('IDDOC').value ;

}

