//'--Versione=1&data=2014-06-18&Attvita=57459&Nominativo=Leone
var IdmsgPrivato = -1;

//va inserito idpfu dell'utente che si vuole monitorare, con scrittura nella ctl_log_utente
var utente_verifica = -1;

function ShowGroup(IdGruppo, OpenClose) {
    var objOpen;
    var objClose;
    var PropPosition;

    try {
        objOpen = getObj('Group_Open_' + IdGruppo);
        objClose = getObj('Group_Close_' + IdGruppo);



        scrollTop = document.documentElement ? document.documentElement.scrollTop : document.body.scrollTop;

        //alert (scrollTop);
        if (OpenClose == 1) {
            setVisibility(objOpen, 'none');
            setVisibility(objClose, '');


            if (scrollTop > 0) {
                getObj('button_' + IdGruppo + '_Group_Close').focus();
            }
        }
        else {
            try {
                CloseAllGroup();
            }
            catch (e) {
            }

            PropPosition = GetProperty(objOpen, 'position');

            if (PropPosition == 'absolute') {
                objOpen.style.left = PosLeft(objClose);
            }

            setVisibility(objOpen, '');

            if (PropPosition != 'absolute') {
                setVisibility(objClose, 'none');
            }


            if (scrollTop > 0) {
                getObj('button_' + IdGruppo + '_Group_Open').focus();
            }


        }
    } catch (e) {
        //alert(e);
    }

}

function ShowCloseGroup(IdGruppo) {
    try {
        objOpen = getObj('Group_Open_' + IdGruppo);
        objClose = getObj('Group_Close_' + IdGruppo);

        //Se il gruppo � chiuso lo apro
        if (objOpen.style.display == 'none') {
            ShowGroup(IdGruppo, 0);
        }
        else {
            ShowGroup(IdGruppo, 1);
        }
    }
    catch (e) {
    }
}


function OpenCloseGroup(ID, H) {

    var objOpen = getObj('Group_' + ID);

    var cls = objOpen.getAttribute('class');

    if (objOpen.style.display == 'none' || cls.indexOf('display_none') > -1) {
        setVisibility(objOpen, '');
    }
    else {
        setVisibility(objOpen, 'none');
    }
}

function AnimOpenGroup(ID, S_H, E_H) {
    try {
        var objOpen = getObj('Group_' + ID);

        objOpen.offsetParent.style.display = '';
        objOpen.style.display = '';

    }
    catch (e) { };
}

function AnimCloseGroup(ID, S_H, E_H) {
    var objOpen = getObj('Group_' + ID);

    objOpen.offsetParent.style.display = 'none';
    objOpen.style.display == 'none';
}

function DashBoardOpenFunc(param) {
    ExecFunctionSelf(param, 'DASHBOARDAreaFunz', '');
}




function DashBoardOpenFuncMain(param, voceMenu) {

    FLAG_CHANGE_NAVIGATION = 0;

    //nel param proviamo a rimpiazzare <ID_AZI> con la variabile client idaziAziendaCollegata
    param = param.replace('<ID_AZI>', idaziAziendaCollegata);


    //se esiste la varibile globale che indica cambiamenti la testo
    if (typeof (FLAG_CHANGE_DOCUMENT) != "undefined") {
        if (FLAG_CHANGE_DOCUMENT == 1) {

            //if( ! confirm( CNV( pathRoot,'Le modifiche non sono state salvate. Si vuole proseguire senza salvare ?')) )
            var Title = 'Attenzione';
            var ML_text = 'Le modifiche non sono state salvate. Si vuole proseguire senza salvare ?';

            //se presente una frase specializzata la uso
            if (typeof (ML_CHANGE_DOCUMENT) != "undefined") {
                if (ML_CHANGE_DOCUMENT != '')
                    ML_text = ML_CHANGE_DOCUMENT;
            }


            var ICO = 3;
            var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent(ML_text) + '&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);

            var gruppoIn = '';
            try {
                gruppoIn = voceMenu.parentNode.parentNode.parentNode.firstChild.id;
            } catch (e) { }


            ExecFunctionModaleConfirm(page, null, 200, 400, null, 'DashBoardOpenFuncMain_wrap@@@@' + param + ';;;' + gruppoIn);

        }
        else {
            DashBoardOpenFuncMain_Sub(param, voceMenu);
        }
    }
    else {
        DashBoardOpenFuncMain_Sub(param, voceMenu);
    }



}

//chiamata dalla ModaleConfirm sul pulsante OK
function DashBoardOpenFuncMain_wrap(param) {

    var v = param.split(';;;');

    //strDoc = v[0];
    var strParam = v[0];
    var gruppoIn = v[1];

    DashBoardOpenFuncMain_Sub(strParam, null, gruppoIn);


}


function DashBoardOpenFuncMain_Sub(param, voceMenu, gruppoIn) {

    /* Al click su una voce di menu ,nel gruppo di funzioni di SX dell'applicazione,
    vado a mettere in sessione l'id del gruppo su cui sto cliccando per poterlo riaprire
    all'onLoad della pagina */
    var gruppo;

    try {
        if (typeof (gruppoIn) != "undefined")
            gruppo = gruppoIn;
        else
            gruppo = voceMenu.parentNode.parentNode.parentNode.firstChild.id;

        setCookie2('openGroup', gruppo);

        ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?RESET=YES&url=' + encodeURIComponent(param + '&lo=base') + '&KEY=viewer', 'DASHBOARDAreaFunz', '');

        /*
        ajax = GetXMLHttpRequest(); 	
      	
        if(ajax)
        {
          var nocache = new Date().getTime();
          ajax.open("GET", '../ctl_library/functions/saveOpenMenu.asp?menu=' + encodeURIComponent(gruppo) + '&nocache=' + nocache , true);
          ajax.send(null);		
    
          ajax.onreadystatechange=function()
          {
            ExecFunctionSelf( pathRoot + 'ctl_library/path.asp?RESET=YES&url=' + encodeURIComponent(param  + '&lo=base') + '&KEY=viewer'  , 'DASHBOARDAreaFunz' , '' );
          }
        }
        */

    }
    catch (e) {
        //alert( 'errore nella chiamata , messaggio solo per capire un problema tecnico');
        ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?RESET=YES&url=' + encodeURIComponent(param + '&lo=base') + '&KEY=viewer', 'DASHBOARDAreaFunz', '');
    }


}


function DashBoardOpenFuncMain_old(param, voceMenu) {

    /* Al click su una voce di menu ,nel gruppo di funzioni di SX dell'applicazione,
    vado a mettere in sessione l'id del gruppo su cui sto cliccando per poterlo riaprire
    all'onLoad della pagina */
    var gruppo;

    try {
        gruppo = voceMenu.parentNode.parentNode.parentNode.firstChild.id;

        setCookie2('openGroup', gruppo);

        ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?RESET=YES&url=' + encodeURIComponent(param + '&lo=base') + '&KEY=viewer', 'DASHBOARDAreaFunz', '');

        /*
        ajax = GetXMLHttpRequest(); 	
      	
        if(ajax)
        {
          var nocache = new Date().getTime();
          ajax.open("GET", '../ctl_library/functions/saveOpenMenu.asp?menu=' + encodeURIComponent(gruppo) + '&nocache=' + nocache , true);
          ajax.send(null);		
    
          ajax.onreadystatechange=function()
          {
            ExecFunctionSelf( pathRoot + 'ctl_library/path.asp?RESET=YES&url=' + encodeURIComponent(param  + '&lo=base') + '&KEY=viewer'  , 'DASHBOARDAreaFunz' , '' );
          }
        }
        */

    }
    catch (e) {
        //alert( 'errore nella chiamata , messaggio solo per capire un problema tecnico');
        ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?RESET=YES&url=' + encodeURIComponent(param + '&lo=base') + '&KEY=viewer', 'DASHBOARDAreaFunz', '');
    }


}


function DashBoardOpenViewer_OLD(param, voceMenu) {
    var url;


    try {
        url = encodeURIComponent('dashboard/' + param + '&lo=base');
        gruppo = voceMenu.parentNode.parentNode.parentNode.firstChild.id;

        setCookie2('openGroup', gruppo);

        ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?reset=YES&url=' + url + '&KEY=viewer', '', '');

        /*
        ajax = GetXMLHttpRequest(); 	
      	
        if(ajax)
        {
          var nocache = new Date().getTime();
          ajax.open("GET", '../ctl_library/functions/saveOpenMenu.asp?menu=' + encodeURIComponent(gruppo) + '&nocache=' + nocache , true);
                //mettendo il terzo parametro (async=true),  specifichiamo anche una funzione che deve essere eseguita quando la response � pronta. nell'evento onreadystatechange
    
          ajax.send(null);
    
          ajax.onreadystatechange=function()
          {
            url = encodeURIComponent('dashboard/' + param  + '&lo=base');
            ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?reset=YES&url=' + url + '&KEY=viewer' , '' , '' );
          }
        }
        */
    }
    catch (e) {
        //alert( 'errore nella chiamata , messaggio solo per capire un problema tecnico');
        url = encodeURIComponent('dashboard/' + param + '&lo=base');
        ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?reset=YES&url=' + url + '&KEY=viewer', '', '');
    }

}

function DashBoardOpenViewer(param, voceMenu) {

    FLAG_CHANGE_NAVIGATION = 0;

    var url;

    url = encodeURIComponent('dashboard/' + param + '&lo=base');

    try {
        gruppo = voceMenu.parentNode.parentNode.parentNode.firstChild.id;
        setCookie2('openGroup', gruppo);

    }
    catch (e) { }

    //se esiste la varibile globale che indica cambiamenti la testo
    if (typeof (FLAG_CHANGE_DOCUMENT) != "undefined") {
        if (FLAG_CHANGE_DOCUMENT == 1) {

            //if( ! confirm( CNV( pathRoot,'Le modifiche non sono state salvate. Si vuole proseguire senza salvare ?')) )
            var Title = 'Attenzione';
            var ML_text = 'Le modifiche non sono state salvate. Si vuole proseguire senza salvare ?';

            //se presente una frase specializzata la uso
            if (typeof (ML_CHANGE_DOCUMENT) != "undefined") {
                if (ML_CHANGE_DOCUMENT != '')
                    ML_text = ML_CHANGE_DOCUMENT;
            }

            var ICO = 3;
            var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent(ML_text) + '&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);

            var gruppoIn = '';
            try {
                gruppoIn = voceMenu.parentNode.parentNode.parentNode.firstChild.id;

            } catch (e) { }

            //alert(param + ';;;' + gruppoIn);
            ExecFunctionModaleConfirm(page, null, 200, 400, null, 'DashBoardOpenFuncMain_wrap@@@@' + 'dashboard/' + param + ';;;' + gruppoIn);

        }
        else {
            ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?reset=YES&url=' + url + '&KEY=viewer', '', '');
        }
    }
    else {
        ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?reset=YES&url=' + url + '&KEY=viewer', '', '');
    }

}

function ExecFunctionSelf(Url, target, param) {
    ShowWorkInProgress(); //faccio uscire il loading su qualsiasi cambio di pagina
    return window.location = Url;
}

function ExecDownloadSelf(Url, target, param) {
    return window.location = Url;
}

function ExecFunctionCenterSelf(Url, target, param) {
    ShowWorkInProgress(); //faccio uscire il loading su qualsiasi cambio di pagina
    return window.location = Url;
}

function ExecFunctionCenterPath(Url) {
    ShowWorkInProgress(); //faccio uscire il loading su qualsiasi cambio di pagina

    return window.location = pathRoot + 'ctl_library/path.asp?url=' + encodeURIComponent(Url + '&lo=base') + '&KEY=document';
}

function CloseAllGroup() {
}

function OpenGenericDocumentW(objGrid, Row, c) {
    OpenDocumentColumn(objGrid, Row, c)
}

function OpenDocumentColumn(objGrid, Row, c) {
    var cod;
    var nq;

    //-- recupero il codice della riga passata
    cod = GetIdRow(objGrid, Row, 'self');

    var strDoc = '';

    try { strDoc = getObj('R' + objGrid + '_' + Row + '_OPEN_DOC_NAME').value; } catch (e) { };

    if (strDoc == '' || strDoc == undefined) {
        try { strDoc = getObj('R' + Row + '_OPEN_DOC_NAME').value; } catch (e) { };
    }

    if (strDoc == '' || strDoc == undefined) {
        try { strDoc = getObj('R' + Row + '_OPEN_DOC_NAME')[0].value; } catch (e) { };
    }

    if (strDoc == '' || strDoc == undefined) {
        alert('Errore tecnico - ' + 'R' + Row + '_OPEN_DOC_NAME - non trovato');
        return;
    }

    //se strDoc contiene CheckTypeViewer.asp? allora redirect alla pagina per controllare
    //se aprire una lista oppure 1 doc altrimenti come adesso
    if (strDoc.indexOf('CheckTypeViewer.asp?') >= 0) {

        var Target = 'CheckTypeViewer_DOC_' + cod;

        try {
            if (eval('BrowseInPage') == 1)
                Target = 'Content';
        }
        catch (e) { }

        //alert(strDoc);

        //apro pagina per capire se aprire una lista oppure un documento
        ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?RESET=YES&url=' + encodeURIComponent('dashboard/' + strDoc + '&lo=base') + '&KEY=document', '', '');




    }
    else {
        if (strDoc == 'DOCUMENTO_GENERICO')
            alert('Il documento generico � stato dismesso');
        //GridSecOpenDocGen( objGrid , Row , c );
        else
            ShowDocument(strDoc, cod);
    }
}

function OpenDocument(objGrid, Row, c) {
    var cod;
    var nq;

    //-- recupero il codice della riga passata
    cod = GetIdRow(objGrid, Row, 'self');

    var strDoc;
    strDoc = getObj('DOCUMENT').value;

    ShowDocument(strDoc, cod);
}

function MakeWinDoc(strDoc, cod) {
    return window;
}

function removeElement(id) {
    var elem = document.getElementById(id);
    elem.parentNode.removeChild(elem);
}

//function OpenAnyDoc( idMsg , TypeDoc , path )
//{
//    if( TypeDoc == '' )
//        alert( 'Documento non definito - ' + idMsg );
//    else
//        ShowDocument(TypeDoc , idMsg );
//}

function ShowDocument(strDoc, cod, Reload) {
    var v = strDoc.split('.');
    if (v.length > 1) {
        strDoc = v[0];
    }
    var url;
    if (isSingleWin()) {
        if (Reload == 'YES')
            url = encodeURIComponent('ctl_library/document/userdocument.asp?lo=base&JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=SHOW&COMMAND=RELOAD&IDDOC=' + encodeURIComponent(cod));
        else
            url = encodeURIComponent('ctl_library/document/userdocument.asp?lo=base&JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + encodeURIComponent(cod));

        return ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document', '', '');
    }
    else {

        var NewWin = MakeWinDoc(strDoc, cod);
        NewWin = LoadDocPath(strDoc, cod, pathRoot);
        NewWin.focus();
        return NewWin;
    }

}

function ShowDocumentPath(strDoc, cod, path) {
    ShowDocument(strDoc, cod);
}

function OpenViewer(URL) {

    URL = encodeURIComponent('dashboard/' + URL);
    ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + URL + '&KEY=viewer', '', '');
}

//per aprire i documenti dalla lista ATV
function OpenDocFromListaATV(objGrid, Row, c) {
    var cod;
    var nq;

    //-- recupero il codice della riga passata
    cod = GetIdRow(objGrid, Row, 'self');



    var strDoc = 'DOCUMENTO_GENERICO';

    try { strDoc = getObjValue('R' + Row + '_OPEN_DOC_NAME'); } catch (e) { };

    if (strDoc == undefined) {
        strDoc = 'DOCUMENTO_GENERICO';
    }



    var strStatoDoc = 'Sended';

    try {
        strStatoDoc = getObjGrid('val_R' + Row + '_StatoDoc').value;
    } catch (e) {
        strStatoDoc = getObjGrid('R' + Row + '_StatoDoc').value;
    }


    if (strDoc != 'DOCUMENTO_GENERICO') {

        //NUOVI DOCUMENTI
        if (strStatoDoc == 'Saved')
            //apertura in mod. editabile 
            LoadDoc(strDoc, cod);

        else {

            var v = strDoc.split('.');
            if (v.length > 1) {
                strDoc = v[0];
            }

            //apertura in mod. stampa
            //ExecFunction('PrnDocPortale.asp?Provenienza=LISTA_ATV&COD=' + cod + '&DOCUMENT=' + strDoc , 'Content' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );	

            url = pathRoot + 'ctl_library/path.asp?url=' + encodeURIComponent('dashboard/reportDocument.asp?lo=lista_attivita&Provenienza=LISTA_ATV&IDDOC=' + encodeURIComponent(cod) + '&DOCUMENT=' + strDoc);
            url = url + '&KEY=DOCUMENT';
            ExecFunctionSelf(url, '', '');
        }

    }

}



function ShowDocumentFromAttrib(param) {
    /*
    1- nome documento
    2- attributo dove recuperare l'id
    3- larghezza
    4- altezza
    */
    var s = param.split(',')
    var strDoc = s[0];
    var cod = getObj(s[1]).value;
    var altro = '';

    var v = strDoc.split('#');
    if (v.length > 1) {
        strDoc = v[0];
        altro = v[1];
    }

    var nq;
    var url;


    var Target = strDoc + '_DOC_' + cod;

    try {
        if (eval('BrowseInPage') == 1) {
            Target = 'Content';
        }
    } catch (e) { }

    //ExecFunction(  'document.asp?JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + cod + altro ,  Target , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );

    //url = encodeURIComponent('ctl_library/document/document.asp?lo=base&JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + encodeURIComponent(cod) + altro);

    //return ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?reset=&url=' + url + '&KEY=document'   ,  '' , '');
    if (isSingleWin()) {
        url = encodeURIComponent('ctl_library/document/document.asp?lo=base&JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + encodeURIComponent(cod) + altro);

        return ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?reset=&url=' + url + '&KEY=document', '', '');
    }
    else {
        url = 'ctl_library/document/document.asp?lo=DOCUMENT&JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + encodeURIComponent(cod) + altro;


        var NewWin = MakeWinDoc(strDoc, cod);
        //NewWin = LoadDocPath( strDoc , cod , pathRoot );
        ExecFunction(pathRoot + url, GetTargetDoc(strDoc, cod), GetDimDoc(strDoc, cod));
        //NewWin.focus();
        return NewWin;
    }

}

function ShowDocumentAndReset(strDoc, cod) {
    var url;
    var gruppo;

    if (isSingleWin()) {
        url = encodeURIComponent('ctl_library/document/userdocument.asp?lo=base&JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + encodeURIComponent(cod));
        return ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?reset=YES&url=' + url + '&KEY=document', '', '');

    }
    else {

        url = 'ctl_library/document/userdocument.asp?lo=DOCUMENT&JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + encodeURIComponent(cod);

        var NewWin = MakeWinDoc(strDoc, cod);
        //NewWin = LoadDocPath( strDoc , cod , pathRoot );
        ExecFunction(pathRoot + url, GetTargetDoc(strDoc, cod), GetDimDoc(strDoc, cod));
        NewWin.focus();
        return NewWin;

    }
}

function LoadDocument(strDoc, cod) {

    var url;
    url = 'ctl_library/document/userdocument.asp?lo=base&JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + encodeURIComponent(cod);
    return ExecFunctionSelf(pathRoot + url, '', '');
}

function LoadDoc(strDoc, cod) {

    var url;
    url = 'ctl_library/document/userdocument.asp?lo=lista_attivita&JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + encodeURIComponent(cod);
    return ExecFunctionSelf(pathRoot + url, '', '');
}

function NewDocument(strDoc) {
    var url;
    //url = encodeURIComponent('ctl_library/document/document.asp?lo=base&JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=NEW' );

    vet = strDoc.split('#');

    var documento;
    var cod;

    // elimina il '../' se gi� presente per non concatenere due volte in seguito
    if (vet[0].substring(0, 3) == '../')
        url = vet[0].substring(3);
    else
        url = vet[0];

    if (isSingleWin()) {
        url = url + '&lo=base';
        url = encodeURIComponent(url);
        return ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document', '', '');
    }
    else {
        cod = 0;
        //documento = getQSParamNew(url, 'DOCUMENT') ;
        documento = getQSParam('DOCUMENT');

        url = url + '&lo=DOCUMENT';
        NewWin = MakeWinDoc(documento, cod);
        ExecFunction(pathRoot + url, GetTargetDoc(documento, cod), GetDimDoc(documento, cod));
        //NewWin.focus();
        return NewWin;
    }

}

function NewDocumentAndReset(strDoc) {
    var url;

    if (isSingleWin()) {
        url = encodeURIComponent('ctl_library/document/document.asp?lo=base&JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=NEW');
        return ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?reset=YES&url=' + url + '&KEY=document', '', '');
    }
    else {
        var cod = 0;

        url = 'ctl_library/document/document.asp?lo=DOCUMENT&JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=NEW';

        var NewWin = MakeWinDoc(strDoc, cod);
        //NewWin = LoadDocPath( strDoc , cod , pathRoot );
        ExecFunction(pathRoot + url, GetTargetDoc(strDoc, cod), GetDimDoc(strDoc, cod));
        NewWin.focus();
        return NewWin;

    }
}

function RefreshDocument(path) {
    var cod = getObj('IDDOC').value;
    var strDoc = getObj('TYPEDOC').value;
    var lo;
    var loFind;

    // imposta il default del layout
    if (isSingleWin())
        lo = 'base';
    else
        lo = 'DOCUMENT';

    // cerca il layout nella location (url) e se lo trova usa quello
    var urlOpener = document.location.toString();

    loFind = getQSParamNew(urlOpener, 'lo');

    if (loFind != '')
        lo = loFind;

    //URL =   path + 'document.asp?JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=SHOW&IDDOC=' + encodeURIComponent(cod) + '&COMMAND=RELOAD&lo=base' ;
    URL = path + 'document.asp?JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=SHOW&IDDOC=' + encodeURIComponent(cod) + '&COMMAND=RELOAD&lo=' + lo;

    return ExecFunctionSelf(URL, '', '');

}

function DASH_NewDocumentFrom(parametri, legacy) {
    var altro = '';

    var cod;
    var nq;
    var idRow;
    var strURL = 'ctl_library/document/document.asp?';

    var vet;
    var documento;
    var docfrom;
    var only_doc;
    var sezione;

    vet = parametri.split('#');
    documento = vet[0];
    docfrom = vet[1];
    only_doc = vet[3];

    sezione = '';

    //if( vet.length >= 5  )
    if (vet.length > 5)
        sezione = vet[5];

    if (sezione != '')
        idRow = Grid_GetIdSelectedRow(sezione + 'Grid');
    else
        idRow = Grid_GetIdSelectedRow('GridViewer');


    idRow = idRow.replace(/~~~/g, ',')

    try {
        if (only_doc != '') {
            z = idRow.split(',');
            if (z.length > 1) {
                DMessageBox('../ctl_library/', 'E\' necessario selezionare una sola riga', 'Attenzione', 2, 400, 300);
                return;
            }
        }


    }
    catch (e) {


    }

    try {
        s = docfrom.split(',');
        if (s.length > 1) {
            docfrom = s[0];
            idRow = s[1];

        }
    }
    catch (e) {


    }

    if (idRow == '') {
        DMessageBox('../ctl_library/', 'E\' necessario selezionare prima una riga', 'Attenzione', 2, 400, 300);
        //alert( "E' necessario selezionare prima una riga" );
        return;
    }

    //var nq;

    cod = 0;
    var NewWin;

    if (legacy == 'yes') {
        if (vet.length < 4) {
        }
        else {
            var d;
            var w;
            var h;
            var Left;
            var Top;

            if (vet[2] != '') {
                d = vet[2].split(',');
                w = d[0];
                h = d[1];
                Left = (screen.availWidth - w) / 2;
                Top = (screen.availHeight - h) / 2;
            }
            if (vet.length > 3) {
                altro = vet[4];
            }
        }

        if (isSingleWin()) {
            url = encodeURIComponent(strURL + 'JScript=' + documento + '&lo=&DOCUMENT=' + documento + '&MODE=CREATEFROM&PARAM=' + docfrom + ',' + idRow, documento + '_DOC_createfrom' + idRow + docfrom + altro);
            return ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document', '', '');
        }
        else {
            url = strURL + 'JScript=' + documento + '&lo=&DOCUMENT=' + documento + '&MODE=CREATEFROM&PARAM=' + docfrom + ',' + idRow, documento + '_DOC_createfrom' + idRow + docfrom + altro;
            //return ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
            NewWin = MakeWinDoc(documento, cod);
            //NewWin = LoadDocPath( strDoc , cod , pathRoot );
            ExecFunction(pathRoot + url, GetTargetDoc(documento, cod), GetDimDoc(documento, cod));
            //NewWin.focus();
            return NewWin;
        }

        //ExecFunction(  '../ctl_library/document/document.asp?JScript=' + documento + '&DOCUMENT=' + documento + '&MODE=CREATEFROM&PARAM=' + docfrom + ',' + idRow , documento + '_DOC_createfrom' + idRow + docfrom , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
    }
    else {

        if (isSingleWin()) {
            url = encodeURIComponent(strURL + 'JScript=' + documento + '&lo=base&DOCUMENT=' + documento + '&MODE=CREATEFROM&PARAM=' + docfrom + ',' + idRow, documento + '_DOC_createfrom' + idRow + docfrom + altro);
            return ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document', '', '');
        }
        else {
            url = strURL + 'JScript=' + documento + '&lo=DOCUMENT&DOCUMENT=' + documento + '&MODE=CREATEFROM&PARAM=' + docfrom + ',' + idRow, documento + '_DOC_createfrom' + idRow + docfrom + altro;
            //return ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
            NewWin = MakeWinDoc(documento, cod);
            //NewWin = LoadDocPath( strDoc , cod , pathRoot );
            ExecFunction(pathRoot + url, GetTargetDoc(documento, cod), GetDimDoc(documento, cod));
            //NewWin.focus();
            return NewWin;
        }
    }

}

function DASH_NewDocumentFromLegacy(parametri) {
    return DASH_NewDocumentFrom(parametri, 'yes');
}


function DOC_NewDocumentFrom(parametri) {
    var idRow;
    var cod;
    var nq;
    var altro;
    var altroDOC = '';
    var s;
    var strURL = 'ctl_library/document/document.asp?';

    var vet;
    var documento;
    var docfrom;

    vet = parametri.split('#');
    documento = vet[0];
    docfrom = vet[1];

    try {
        idRow = getObj('IDDOC').value;
    }
    catch (e) {
    }

    try {
        s = docfrom.split(',');
        if (s.length > 1) {
            docfrom = s[0];
            idRow = s[1];
        }
    }
    catch (e) {
    }

    if (idRow == '') {
        DMessageBox('../', 'E\' necessario prima il documento', 'Attenzione', 1, 400, 300);
        return;
    }

    var nq;

    if (vet.length < 3) {
    }
    else {
        var d;
        d = vet[2].split(',');

        if (vet.length > 3) {
            altro = vet[3];
        }

        if (vet.length > 4) {
            altroDOC = vet[4];
        }

        if (vet.length > 5) {
            //strURL = vet[5];
        }
    }
    // vede se il chiamante � la lista attivit�
    var U = decodeURIComponent(document.location.toString().toLowerCase());

    var indice = U.indexOf('lo=lista_attivita');

    //Codice Refactoring FASE II
    var indice2 = U.indexOf('lo=drawer');

    var layout = 'base';

    if (isSingleWin() || indice > -1) {
        if (indice > -1)
            layout = 'lista_attivita';

        //Codice Refactoring FASE II
        if (indice2 > -1)
            layout = 'drawer';

        url = encodeURIComponent(strURL + 'JScript=' + documento + '&lo=' + layout + '&DOCUMENT=' + documento + '&MODE=CREATEFROM&PARAM=' + docfrom + ',' + idRow + altroDOC);

        return ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document', '', '');
    }
    else {
        url = strURL + 'JScript=' + documento + '&lo=DOCUMENT&DOCUMENT=' + documento + '&MODE=CREATEFROM&PARAM=' + docfrom + ',' + idRow + altroDOC;


        var NewWin = MakeWinDoc(documento, cod);

        ExecFunction(pathRoot + url, '', GetDimDoc(documento, cod));
        //NewWin.focus();
        return NewWin;
    }


}

function OpenCollegati(objGrid, Row, c) {
    var srcPage;

    var Fascicolo = '';
    var url = '';

    if (Row === '' || Row === undefined) {
        Fascicolo = objGrid;

    }
    else
        try { Fascicolo = getObjValue('R' + Row + '_Fascicolo') } catch (e) { };



    url = pathRoot + 'ctl_library/path.asp?url=' + encodeURIComponent('dashboard/groupsView.asp?lo=base&FOLDER_GROUP=LINKED_ISCRIZIONE_ALBO&FilterHide= Fascicolo = \'' + Fascicolo + '\'');

    url = url + '&KEY=GROUP_VIEW';

    ExecFunctionSelf(url, '', '');

}

function OpenCollegati_NEW(objGrid, Row, c) {
    var srcPage;

    var Fascicolo = '';
    var url = '';

    if (Row === '' || Row === undefined) {
        Fascicolo = objGrid;

    }
    else
        try { Fascicolo = getObjValue('R' + Row + '_Fascicolo') } catch (e) { };



    url = pathRoot + 'ctl_library/path.asp?url=' + encodeURIComponent('dashboard/groupsView.asp?lo=base&FOLDER_GROUP=LINKED_CONSULTAZIONE_BANDO&FilterHide= Fascicolo = \'' + Fascicolo + '\'');

    url = url + '&KEY=GROUP_VIEW';

    ExecFunctionSelf(url, '', '');

}


function OpenCollegatiIndiretti(objGrid, Row, c) {
    var srcPage;

    var Fascicolo = '';
    var url = '';

    if (Row === '' || Row === undefined) {
        Fascicolo = objGrid;

    }
    else
        try { Fascicolo = getObjValue('R' + Row + '_Fascicolo') } catch (e) { };



    url = pathRoot + 'ctl_library/path.asp?url=' + encodeURIComponent('dashboard/groupsView.asp?lo=base&FOLDER_GROUP=LINKED_DOCUMENTI_INDIRETTI&FilterHide= Fascicolo = \'' + Fascicolo + '\'');

    url = url + '&KEY=GROUP_VIEW';

    ExecFunctionSelf(url, '', '');

}

function DocumentiCollegati(param) {

    param = param.replace('../dashboard/mainView.asp?', 'dashboard/groupsView.asp?');

    url = pathRoot + 'ctl_library/path.asp?url=' + encodeURIComponent(param + '&lo=base');

    url = url + '&KEY=GROUP_VIEW';

    ExecFunctionSelf(url, '', '');

}

function LinkedPrnDocPortale(objGrid, Row, c) {
    var cod;
    var strDoc = '';
    var url = '';

    //-- recupero il codice della riga passata
    cod = GetIdRow(objGrid, Row, 'self');


    try { strDoc = getObj('R' + Row + '_OPEN_DOC_NAME').value; } catch (e) { };


    if (strDoc == '' || strDoc == undefined) {
        try { strDoc = getObj('R' + Row + '_OPEN_DOC_NAME')[0].value; } catch (e) { };
    }


    if (strDoc == '' || strDoc == undefined) {
        alert('Errore tecnico - ' + 'R' + Row + '_OPEN_DOC_NAME - non trovato');
        return;
    }


    //	url = pathRoot + 'ctl_library/path.asp?url=' + encodeURIComponent('dashboard/reportDocument.asp?IDDOC=' + cod + '&DOCUMENT=' + strDoc);
    //	url = url + '&KEY=DOCUMENT';
    url = pathRoot + 'dashboard/reportDocument.asp?IDDOC=' + encodeURIComponent(cod) + '&DOCUMENT=' + strDoc;

    ExecFunctionSelf(url, '', '');
}
function PrnDocPortale(objGrid, Row, c) {

    var cod;
    var strDoc = '';
    var url = '';

    //-- recupero il codice della riga passata
    cod = GetIdRow(objGrid, Row, 'self');


    try { strDoc = getObj('R' + Row + '_OPEN_DOC_NAME').value; } catch (e) { };


    if (strDoc == '' || strDoc == undefined) {
        try { strDoc = getObj('R' + Row + '_OPEN_DOC_NAME')[0].value; } catch (e) { };
    }


    if (strDoc == '' || strDoc == undefined) {
        alert('Errore tecnico - ' + 'R' + Row + '_OPEN_DOC_NAME - non trovato');
        return;
    }



    url = pathRoot + 'ctl_library/path.asp?url=' + encodeURIComponent('dashboard/reportDocument.asp?lo=base&IDDOC=' + encodeURIComponent(cod) + '&DOCUMENT=' + strDoc);
    //url = pathRoot + 'ctl_library/path.asp?url=' + encodeURIComponent('dashboard/PrnDocPortale.asp?lo=base&COD=' + cod + '&DOCUMENT=' + strDoc);
    url = url + '&KEY=REPORT';
    //url = pathRoot + 'dashboard/reportDocument.asp?IDDOC=' + cod + '&DOCUMENT=' + strDoc;

    ExecFunctionSelf(url, '', '');
}

function ExecFunctionModaleConfirm(page, titolo, height, width, params, on_ok, on_ko) {
    try {
        getObj('finestra_modale_confirm').innerHTML = ''; // Empty the innerHtml for the div of the dialog so that height:'auto' centers the dialog based on the new content

        //$( "#finestra_modale_confirm" ).load(pathRoot + page).dialog({
        if (page && page !== '')
            $("#finestra_modale_confirm").load(pathRoot + page);

        $("#finestra_modale_confirm").dialog({
            title: titolo,
            resizable: false,
            //height:140,
            height: 'auto', // Per far adeguare sempre l'altezza della modale al contenuto; senza, la modale, non si ridimensiona in modo corretto anche se 'auto' doverbbe essere il default.
            width: 450,
            minHeight: 'auto',
            minWidth: 450,
            position: { my: "center", at: "center", of: window },
            modal: true,
            buttons: {
                "OK": function () {
                    if (on_ok !== undefined && on_ok !== '') {
                        var funcName;
                        var parametro;
                        var s;

                        if (on_ok.indexOf('@@@@') > -1) {
                            s = on_ok.split('@@@@');
                            funcName = s[0];
                            parametro = s[1];
                        }
                        else {
                            funcName = on_ok;
                            parametro = '';
                        }

                        window[funcName](parametro);
                        $(this).dialog("close");

                    }
                    else {
                        $(this).dialog("close");
                    }

                }
                , Cancel: function () {
                    if (on_ko !== undefined && on_ko !== '') {
                        var funcName;
                        var parametro;
                        var s;

                        if (on_ko.indexOf('@@@@') > -1) {
                            s = on_ko.split('@@@@');
                            funcName = s[0];
                            parametro = s[1];
                        }
                        else {
                            funcName = on_ko;
                            parametro = '';
                        }

                        window[funcName](parametro);
                        $(this).dialog("close");

                    }
                    else {
                        $(this).dialog("close");

                    }

                }
            },
            open: function () {
                // //getter
                // var height = $('#finestra_modale_confirm').dialog('option', 'height');
                // var width = $('#finestra_modale_confirm').dialog('option', 'width');

                //setter
                // $('#finestra_modale_confirm').dialog('option', 'width', 200);
                // $('#finestra_modale_confirm').dialog('option', 'height', height); // Setting the height (again) so the dialog is centered based on the new content
                // which isn't loaded yet though, so the developer has to pass the right height

                document.getElementsByClassName("ui-dialog-buttonset")[0].childNodes[1].focus();
                if (typeof isFaseII !== 'undefined' && isFaseII) {
                    $('.ui-button:contains(Cancel)').addClass('secondaryButtonVapor');
                    $('.ui-button:contains(OK)').addClass('primaryButtonVapor');
                    $('.ui-button:contains(Cancel)').text('Annulla');
                }
            }
        });
    }
    catch (e) {
    }
}

function ExecFunctionModaleWithAction(page, titolo, height, width, params, on_ok) {
    try {
        $(function () {
            $("#finestra_modale").load(pathRoot + page).dialog({
                resizable: false,
                //height:140,
                width: '450',
                modal: true,
                buttons: {
                    "OK": function () {
                        if (on_ok !== undefined && on_ok !== '') {
                            var funcName;
                            var parametro;
                            var s;

                            if (on_ok.indexOf('@@@@') > -1) {
                                s = on_ok.split('@@@@');
                                funcName = s[0];
                                parametro = s[1];
                            }
                            else {
                                funcName = on_ok;
                                parametro = '';
                            }

                            window[funcName](parametro);

                        }
                        else {
                            $(this).dialog("close");
                        }
                    }

                }
            });
        });
    }
    catch (e) {
    }
}

function ExecFunctionModaleFaseII(page, titolo, height, width, params, on_ok, on_ko) {
    if (typeof isFaseII !== 'undefined' && isFaseII) {
        const urlParams = new URLSearchParams(page);
        const CAPTION = urlParams.get('CAPTION');
        const ICO = urlParams.get('ICO');
        const MSG = urlParams.get('MSG');
        switch (ICO) {

            case (2):
                $('.toast').addClass("active");
                $('.toast').addClass("toastError");
                $('.toastTitle').html(`<span class="spanTitle">${CAPTION}:</span><p class="toastMessage">${MSG}</p>`);
                $('.toast-body').text();
                break;
                break;
            case (3):
                $('.toast').addClass("active");
                $('.toast').addClass("toastCheck");
                $('.toastTitle').html(`<span class="spanTitle">${CAPTION}:</span><p class="toastMessage">${MSG}</p>`);
                $('.toast-body').text();
                break;
                break;
            case (4):
                $('.toast').addClass("active");
                $('.toast').addClass("toastWarning");
                $('.toastTitle').html(`<span class="spanTitle">${CAPTION}:</span><p class="toastMessage">${MSG}</p>`);
                $('.toast-body').text();
                break;
                break;
            //case (1):
            default:
                //ICO = 1
                $('.toast').addClass("active");
                $('.toast').addClass("toastInformative");
                $('.toastTitle').html(`<span class="spanTitle">${CAPTION}:</span><p class="toastMessage">${MSG}</p>`);
                $('.toast-body').text();
                break;
        }

        let baseSeconds;
        if (typeof baseSecondsToasts !== 'undefined') {
            baseSeconds = baseSecondsToasts;
        } else {
            baseSeconds = 3000;
        }
        let moreSeconds = 0;
        let numberOfWords = MSG.split(" ").length;
        //0.5s each word
        moreSeconds = parseInt(numberOfWords * 500);

        let idTimeout = setTimeout(() => {
            $('.toast').removeClass("active");
        }, baseSeconds + moreSeconds)
        $('.toast').off("mouseenter").on("mouseenter", () => {
            clearTimeout(idTimeout);
        })

        return;
    }
}

function ExecFunctionModale(page, titolo, height, width, params) {
    try {
        //$(function() 
        //{
        $("#finestra_modale").load(pathRoot + page).dialog({
            resizable: false,
            //height:140,
            modal: true,
            width: '450',
            buttons: {
                "OK": function () {
                    $(this).dialog("close");
                }
            }
        });
        //});
    }
    catch (e) {
    }
}



function ExecFunctionModaleConfirmWithDinamicHeightAndWidth(page, titolo, params, on_ok, on_ko, height = 450, width = 675) {
    try {
        // getObj('finestra_modale_confirm').innerHTML = ''; // Empty the innerHtml for the div of the dialog so that height:'auto' centers the dialog based on the new content

        if (page && page !== '')
            $("#finestra_modale_confirm").load(pathRoot + page);

        $("#finestra_modale_confirm").dialog({
            title: titolo,
            resizable: true,
            minHeight: height,
            minWidth: width,
            height: height,
            width: width,
            position: { my: "center", at: "center", of: window },
            modal: true,
            buttons: {
                "OK": function () {
                    if (on_ok !== undefined && on_ok !== '') {
                        var funcName;
                        var parametro;
                        var s;

                        if (on_ok.indexOf('@@@@') > -1) {
                            s = on_ok.split('@@@@');
                            funcName = s[0];
                            parametro = s[1];
                        }
                        else {
                            funcName = on_ok;
                            parametro = '';
                        }

                        var isDialogToBeClosed = window[funcName](parametro);
                        // Keep the dialog open only if false is return that is only if isDialogToBeClosed===false
                        if (isDialogToBeClosed !== false) {
                            $(this).dialog("close");
                        }
                    }
                    else {
                        $(this).dialog("close");
                    }
                },
                Cancel: function () {
                    if (on_ko && on_ko !== '') {
                        var funcName;
                        var parametro;
                        var s;

                        if (on_ko.indexOf('@@@@') > -1) {
                            s = on_ko.split('@@@@');
                            funcName = s[0];
                            parametro = s[1];
                        }
                        else {
                            funcName = on_ko;
                            parametro = '';
                        }

                        window[funcName](parametro);
                        $(this).dialog("close");
                    }
                    else {
                        $(this).dialog("close");
                    }
                }
            },
            open: function () {
                document.getElementsByClassName("ui-dialog-buttonset")[0].childNodes[1].focus();
                if (typeof isFaseII !== 'undefined' && isFaseII) {
                    $('.ui-button:contains(Cancel)').addClass('secondaryButtonVapor');
                    $('.ui-button:contains(OK)').addClass('primaryButtonVapor');
                    $('.ui-button:contains(Cancel)').text('Annulla');
                }
            }
        });
    }
    catch (e) { }
}

function ExecFunctionModaleClose(page, titolo, params, height = 450, width = 675) {
    try {
        strMsg = CNV(pathRoot, "Chiudi");

        if (page && page !== '')
            $("#finestra_modale_confirm").load(pathRoot + page);

        let btns = {}; // Contians the buttons of the dialog
        btns[strMsg] = function () { $(this).dialog("close"); } // Button to close the dialog

        $("#finestra_modale_confirm").dialog({
            resizable: false,
            title: titolo,
            height: height,
            modal: true,
            width: width,
            buttons: btns, // Add the buttons
            open: function () {
                document.getElementsByClassName("ui-dialog-buttonset")[0].childNodes[1].focus();
                if (typeof isFaseII !== 'undefined' && isFaseII) {
                    $('.ui-button:contains(Cancel)').addClass('secondaryButtonVapor');
                    $('.ui-button:contains(OK)').addClass('primaryButtonVapor');
                    $('.ui-button:contains(Cancel)').text('Annulla');


                }
            }
        });
    }
    catch (e) {
    }
}


function apriDettaglioStampa(idmsg_privato) {
    if (typeof (idmsg_privato) != "undefined") {
        IdmsgPrivato = idmsg_privato;
    }
    else {
        trace_in_log_client('PRE_GetMessaggioPrivato()');

        GetMessaggioPrivato();

        trace_in_log_client('POST_GetMessaggioPrivato()');
    }




    //nascondo le area che di solito sono solo lato portale
    try {
        //nascondo area dei path
        try {
            getObj('breadcrumb').style.display = 'none';
        }
        catch (e) { }

        //nascondo area suggerimenti
        try {
            getObj('contenitoresuggerimento').style.display = 'none';
        }
        catch (e) { }

        //nascondo toolbar di testa visualizzata lato portale
        try {
            getObj('paginazione').style.display = 'none';
        }
        catch (e) { }

        //nascondo toolbar di coda visualizzata lato portale
        try {
            getObj('toolbarportale').style.display = 'none';
        }
        catch (e) { }


        //nascondo le div di loading grigliate
        getObj('INFO_PROCESS').style.display = 'none';
        getObj('INFO_PROCESS2').style.display = 'none';


        //visualizzo la toolbar giusta
        try {
            document.getElementById('toolbarpublic').style.display = 'none';
        }
        catch (e) { }

        try {
            document.getElementById('toolbarprivate').style.display = 'none';
        }
        catch (e) { }

        //alert(IdmsgPrivato);
        try {
            if (IdmsgPrivato == -1)
                document.getElementById('toolbarpublic').style.display = 'block';
            else
                document.getElementById('toolbarprivate').style.display = 'block';
        }
        catch (e) { }


    }
    catch (e) {
        //vuol dire che ho caricato una stampa base
    }
    trace_in_log_client('PRE_InsertQuesiti()');

    InsertQuesiti();

    trace_in_log_client('POST_InsertQuesiti()');
    trace_in_log_client('PRE_ApriQuesiti()');

    ApriQuesiti();

    trace_in_log_client('POST_ApriQuesiti()');

    //nel form di invio quesito se presente setto le mie info e blocco i campi
    try {
        SetUserCurrentInvioQuesito();
    }
    catch (e) {
    }

}

function ApriQuesiti(OPEN_INSERT_QUESITI) {
    //if ('<%=request.querystring("OPEN_INSERT_QUESITI")%>' == 'YES')
    if (OPEN_INSERT_QUESITI == 'YES') {
        //setto il path sui bandi pubblicati
        parent.SetTitle('Dettaglio', 'PUBBLICI', -1);

        //apro il form per inserire i quesiti
        getObj('h3insertquesito').click();
    }
}

//recupera il messaggio scaricato se essite
function GetMessaggioPrivato() {

    try {
        var nocache = new Date().getTime();
        $.ajax({
            type: "GET", url: pathRoot + 'ctl_library/functions/getMessaggioScaricato.asp?IDMSG=' + getObj('IDDOC_GUID').value + '&DOCUMENT=' + getObj('DOCUMENT').value + '&nocache=' + nocache
            , async: false,
            success: function (ajaxRes) {
                if (ajaxRes != "-1") {
                    IdmsgPrivato = ajaxRes;
                    //alert(IdmsgPrivato);
                }
            },
            error: function (ajaxRes) {
                trace_in_log_client('FUNCT_GetMessaggioPrivato()--errore chiamata ajax=' + ajaxRes);
            }


        })




        /*var ajax_Mess_privato = GetXMLHttpRequest(); 	
        if(ajax_Mess_privato)
        {
          var nocache = new Date().getTime();
          ajax_Mess_privato.open("GET", '../ctl_library/functions/getMessaggioScaricato.asp?IDMSG=' + getObj('IDDOC_GUID').value + '&DOCUMENT=' + getObj('DOCUMENT').value + '&nocache=' + nocache , false);
          ajax_Mess_privato.send(null);
          //alert(ajax.status);	    
          if(ajax_Mess_privato.readyState == 4) {
          	
            if(ajax_Mess_privato.status == 200 )
            {
            	
              if (ajax_Mess_privato.responseText != "-1" ){
              	
              	
                IdmsgPrivato=ajax_Mess_privato.responseText;
                    	
              }				
                        	
            }
          }			
        }*/
    }
    catch (e) {
        trace_in_log_client('FUNCT_GetMessaggioPrivato()--errore=' + e.message);
    }

}

function GetXMLHttpRequest() {
    var
        XHR = null,
        browserUtente = navigator.userAgent.toUpperCase();

    if (typeof (XMLHttpRequest) === "function" || typeof (XMLHttpRequest) === "object")
        XHR = new XMLHttpRequest();
    else if (window.ActiveXObject && browserUtente.indexOf("MSIE 4") < 0) {
        if (browserUtente.indexOf("MSIE 5") < 0)
            XHR = new ActiveXObject("Msxml2.XMLHTTP");
        else
            XHR = new ActiveXObject("Microsoft.XMLHTTP");
    }
    return XHR;
};




//crea un documento di rispota per i nuovi documenti
function CREATE_ANSWER_NEW(strUrl) {
    try {
        //parent.getObj('INFO_PROCESS').style.display='';
        //parent.getObj('INFO_PROCESS2').style.display='';
    } catch (e) {
        alert('errore vis loading');
    };

    //execfunction(strUrl, 'Content','toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
    ExecFunctionSelf(strUrl, '', '');


}

function DMessageBox(path, Text, Title, ICO, w, h) {
    var MakeML = 'yes';

    if (Text.length > 8) {
        if (Text.substring(0, 8) == 'NO_ML###') {
            Text = Text.substring(8, Text.length);
            MakeML = 'no';
        }
    }

    try {
        //-- provo a togliere il blocco dello schermo che interaggisce con il messaggio
        ShowWorkInProgress(false);
    } catch (e) { }




    ExecFunctionModale('ctl_library/MessageBoxWin.asp?MODALE=YES&ML=' + MakeML + '&MSG=' + encodeURIComponent(Text) + '&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO) + '&PATH=' + encodeURIComponent(pathRoot));
}


//simile a DMessageBox con in più la possibilità di eseguire una azione sull'ok
function DMessageBoxWithAction(path, Text, Title, ICO, w, h, on_ok) {
    var MakeML = 'yes';
    var params;
    if (Text.length > 8) {
        if (Text.substring(0, 8) == 'NO_ML###') {
            Text = Text.substring(8, Text.length);
            MakeML = 'no';
        }
    }

    try {
        //-- provo a togliere il blocco dello schermo che interaggisce con il messaggio
        ShowWorkInProgress(false);
    } catch (e) { }



    //ExecFunctionModaleWithAction(page, titolo, height, width, params, on_ok)
    ExecFunctionModaleWithAction('ctl_library/MessageBoxWin.asp?MODALE=YES&ML=' + MakeML + '&MSG=' + encodeURIComponent(Text) + '&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO) + '&PATH=' + encodeURIComponent(pathRoot), Title, h, w, params, on_ok);

}


function MakeDocFromAndReset(param, voceMenu) {
    var gruppo;

    try {
        gruppo = voceMenu.parentNode.parentNode.parentNode.firstChild.id;
        setCookie2('openGroup', gruppo);
    }
    catch (e) {
    }

    return MakeDocFrom(param, true);
}

var G_MDF_Param;
var G_MDF_ResetBC;

function UpdateForMakeDocFrom() {

    UpdateDocInMem(getObj('IDDOC').value, getObj('TYPEDOC').value);

    MakeDocFrom(G_MDF_Param, G_MDF_ResetBC, 'no')

}

function MakeDocFrom(param, resetBreadCrumb, UpdateCur) {

    //se editabile effettuo il salva in memoria del documento corrente
    try {
        var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
        if (UpdateCur != 'no')
            if (DOCUMENT_READONLY != "1")
                if (typeof (FLAG_CHANGE_DOCUMENT) != "undefined")
                    if (FLAG_CHANGE_DOCUMENT == 1) {
                        G_MDF_Param = param;
                        G_MDF_ResetBC = resetBreadCrumb;

                        ShowWorkInProgress(); //faccio uscire il loading su qualsiasi cambio di pagina
                        setTimeout(UpdateForMakeDocFrom, 1);	//-- richiamo immediatamente la funzione per aggiornare il documento in memoria e richiamare la makedocfrom				
                        return;

                    }

    } catch (e) { }

    var nq;
    var V = param.split('#');
    var strDoc = V[0]; // param.split( '#' )[0];
    var w;
    var h;
    var Left;
    var Top;
    var Param = '';
    var cod = 0;
    var idRow;
    var BUFFER = '';
    var Altro = '';

    try {
        Param = V[1]; // param.split( '#' )[1];
    } catch (a) { Param = '' };



    try { var IDDOC = getObj('IDDOC').value; } catch (a) { };
    try { var TYPEDOC = getObj('TYPEDOC').value; } catch (a) { };

    //-- verifico la presenza di un from specifico
    try {
        if (V.length > 2) {
            TYPEDOC = V[2]; // param.split( '#' )[2];
        }
    } catch (a) { };

    //-- verifico la presenza di un IDDOC specifico
    try {
        if (V.length > 3) {
            IDDOC = V[3]; // param.split( '#' )[2];
        }
    } catch (a) { };

    //verifico presenza path
    var strPath = '../';
    try {
        if (V.length > 4) {
            strPath = V[4]; // param.split( '#' )[2];
        }
    } catch (a) { };

    //verifico presenza selezione da viewer
    try {
        if (V.length > 5) {
            if (V[5] == 'VIEWER') {
                idRow = Grid_GetIdSelectedRow('GridViewer');
                idRow = idRow.replace(/~~~/g, ',');
                z = idRow.split(',');

                if (z.length != 1 || z == '') {
                    DMessageBox('../ctl_library/', 'E\' necessario selezionare una sola riga', 'Attenzione', 2, 400, 300);
                    return;
                }

                IDDOC = idRow;
            }
        }
    } catch (a) { };

    try {
        if (V.length > 6) {
            if (V[6] == 'BUFFER') {
                idRow = Grid_GetIdSelectedRow('GridViewer');

                if (idRow == '') {
                    DMessageBox('../ctl_library/', 'E\' necessario selezionare prima una riga', 'Attenzione', 2, 400, 300);
                    return;
                }

                BUFFER = idRow.replace(/~~~/g, ',');
            }
            else {
                if (V[6] != '') {
                    BUFFER = V[6];
                }

            }
        }

    }
    catch (a) { }

    //-- ulteriori elementi da aggiungere alla chiamata
    try {
        if (V.length > 8) {
            //Altro = '&' + encodeURIComponent( V[8] )
            Altro = '&' + V[8];
        }

    }
    catch (a) { }


    var NewWin;

    var Target = strDoc + '_DOC_' + cod;
    try {
        if (eval('BrowseInPage') == 1) {
            Target = 'Content';
        }
    } catch (e) { }

    var url;
    var lo = '';
    var extraPath;

    extraPath = '';

    //nella posizione 9 vedo se devo saltare lo stack se vale YES
    //per default come prima
    var SaltaStack = 'NO';
    try {
        if (V.length > 9) {
            SaltaStack = V[9];
        }

    }
    catch (a) { }



    //if ( layout.toLowerCase() == 'lista_attivita')
    lo = layout;
    //else
    //	lo='base';

    if (isSingleWin()) {

        //url = encodeURIComponent('ctl_Library/document/MakeDocFrom.asp?lo=' + lo + '&TYPE_TO=' + strDoc + '&IDDOC='+ encodeURIComponent(IDDOC) + '&TYPEDOC='+ TYPEDOC + '&BUFFER=' + encodeURIComponent(BUFFER) +  Altro);	
        url = 'ctl_Library/document/MakeDocFrom.asp?lo=' + lo + '&TYPE_TO=' + strDoc + '&IDDOC=' + encodeURIComponent(IDDOC) + '&TYPEDOC=' + TYPEDOC + '&BUFFER=' + encodeURIComponent(BUFFER) + Altro;

        if (resetBreadCrumb !== undefined) {
            if (resetBreadCrumb == true)
                extraPath = '&RESET=yes';
        }

        if (SaltaStack.toUpperCase() != 'YES') {
            url = encodeURIComponent(url);
            return ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document' + extraPath, '', '');
        }
        else {
            return ExecFunctionSelf(pathRoot + url, '', '');
        }
    }
    else {
        url = 'ctl_Library/document/MakeDocFrom.asp?UPD_STACK=NO&lo=DOCUMENT&TYPE_TO=' + strDoc + '&IDDOC=' + encodeURIComponent(IDDOC) + '&TYPEDOC=' + TYPEDOC + '&BUFFER=' + encodeURIComponent(BUFFER) + Altro;


        var NewWin = MakeWinDoc(strDoc, cod);
        //NewWin = LoadDocPath( strDoc , cod , pathRoot );
        ExecFunction(pathRoot + url, GetTargetDoc(strDoc, cod), GetDimDoc(strDoc, cod));
        //NewWin.focus();
        return NewWin;
    }

    if (resetBreadCrumb !== undefined) {
        if (resetBreadCrumb == true)
            extraPath = '&RESET=yes';
    }

    return ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document' + extraPath, '', '');


}



function LoadDocPath(strDoc, cod, path) {
    var nq;

    Target = GetTargetDoc(strDoc, cod)

    v = strDoc.split('.');
    if (v.length > 1) {
        strDoc = v[0];
    }
    /*
    var w ;
    var h ;
  	
    try{
      if (v.length > 2)
      {
        w = v[2];
        h = v[3];
      }
      else
      {
  
        w = screen.availWidth * 0.9;
        h = screen.availHeight  * 0.9;
  
      }
    }catch(e){
      w = screen.availWidth * 0.9;
      h = screen.availHeight  * 0.9;
  
    };
    var Left;
    var Top;
      
    Left= (screen.availWidth - w) / 2;
    Top= (screen.availHeight - h ) / 2;
    */
    /*
    Target = strDoc + '_DOC_' + cod ;
  
    Target = Target.replace( ';' , '_' );
    Target = Target.replace( '-' , '_' );
    */

    try {
        if (eval('BrowseInPage') == 1) {
            //Target = 'Content';
        }
    } catch (e) { }

    NewWin = ExecFunction(path + 'ctl_library/document/document.asp?UPD_STACK=NO&lo=DOCUMENT&JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + cod, Target, /*',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h */ GetDimDoc(strDoc, cod));
    return NewWin;
}

function GetDimDoc(strDoc, cod) {
    var nq;

    v = strDoc.split('.');
    if (v.length > 1) {
        strDoc = v[0];
    }

    var w;
    var h;
    try {
        if (v.length > 2) {
            w = v[2];
            h = v[3];
        }
        else {

            w = screen.availWidth * 0.9;
            h = screen.availHeight * 0.9;

        }
    } catch (e) {
        w = screen.availWidth * 0.9;
        h = screen.availHeight * 0.9;

    };
    var Left;
    var Top;

    Left = (screen.availWidth - w) / 2;
    Top = (screen.availHeight - h) / 2;


    return ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h;

}

function GetTargetDoc(strDoc, cod) {
    var nq;

    v = strDoc.split('.');
    if (v.length > 1) {
        strDoc = v[0];

    }


    var Target = strDoc + '_DOC_' + cod;

    Target = Target.replace(';', '_');
    Target = Target.replace('-', '_');

    try {
        if (eval('BrowseInPage') == 1) {
            //Target = 'Content';
        }
    } catch (e) { }


    return Target;
}


function NascondiMenu() {
    var gruppi;
    var content;
    var span_mostra;
    var span_nascondi;

    gruppi = getObj('main_middle_left_div');
    span_mostra = getObj('mostra_menu');
    span_nascondi = getObj('nascondi_menu');
    content = getObj('contenutopagina');


    if (gruppi.style.display == 'none') {
        gruppi.style.display = 'block';
        span_mostra.style.display = 'none';
        span_nascondi.style.display = 'block';
        content.style.width = '';

        try {
            content.style.paddingLeft = '';
        } catch (e) { }

        try {
            getObj('td_content_right').className = getObj('td_content_right').className.replace(' td_content_open', '');
        } catch (e) { }


    }
    else {
        span_mostra.style.display = 'block';
        span_nascondi.style.display = 'none';
        gruppi.style.display = 'none';
        content.style.width = '99.5%';

        try {
            content.style.paddingLeft = '0em';
        }
        catch (e) { }

        try {
            getObj('td_content_right').className += " td_content_open";
        } catch (e) { }

    }

}

function OpenViewerBandocentrico(Param, URL) {

    //URL = encodeURIComponent('dashboard/' + URL + '&lo=base');
    //return ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + URL + '&KEY=viewer'   ,  '' , '');

    if (isSingleWin()) {
        URL = encodeURIComponent('dashboard/' + URL + '&lo=base');
        return ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + URL + '&KEY=viewer', '', '');
    }
    else {

        var strDoc = '';
        var cod = 0;


        URL = pathRoot + 'dashboard/' + URL + '&lo=DOCUMENT';
        //URL = pathRoot + 'ctl_library/path.asp?url=' + URL + '&KEY=viewer';

        var NewWin = MakeWinDoc(strDoc, cod);

        ExecFunction(URL, GetTargetDoc(strDoc, cod), GetDimDoc(strDoc, cod));
        NewWin.focus();
        return NewWin;
    }

}



//-- apre un documento partendo da una colonna di una sezione del documetno
//-- Il presupposto � una colonna nascosta che contiene l'id del documento da aprire , ed una che contiene il tipo di documento
//-- le colonne nascoste devono cominciare con il nome della sezione seguite da Grid , '_ID_DOC' e '_OPEN_DOC_NAME
function GridSecOpenDoc(objGrid, Row, c) {

    var cod;
    var strDoc;

    //-- recupero il codice della riga passata
    {
        cod = getObj('R' + Row + '_' + objGrid + '_ID_DOC').value;
    }

    //-- recupero il documento da aprire
    {
        strDoc = getObj('R' + Row + '_' + objGrid + '_OPEN_DOC_NAME').value;
    }


    ShowDocument(strDoc, cod)

}




function AF_Alert(msg) {
    //DMessageBox( '../ctl_library/' , msg , 'Attenzione' , 2 , 400 , 300 );

    DMessageBox(pathRoot + 'ctl_library/', msg, 'Attenzione', 2, 400, 300);

}


function breadCrumbPop() {
    // vede se il chiamante � la lista attivit�
    var U = decodeURIComponent(document.location.toString().toLowerCase());

    var indice = U.indexOf('lo=lista_attivita');

    if (isSingleWin() || indice > -1) {

        //se esiste la varibile globale che indica cambiamenti la testo
        if (typeof (FLAG_CHANGE_DOCUMENT) != "undefined") {
            if (FLAG_CHANGE_DOCUMENT == 1) {

                //if( ! confirm( CNV( pathRoot,'Le modifiche non sono state salvate. Si vuole proseguire senza salvare ?')) )
                var Title = 'Attenzione';
                var ML_text = 'Le modifiche non sono state salvate. Si vuole proseguire senza salvare ?';

                //se presente una frase specializzata la uso
                if (typeof (ML_CHANGE_DOCUMENT) != "undefined") {
                    if (ML_CHANGE_DOCUMENT != '')
                        ML_text = ML_CHANGE_DOCUMENT;
                }

                var ICO = 3;
                var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent(ML_text) + '&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);
                ExecFunctionModaleConfirm(page, null, 200, 400, null, 'breadCrumbPop_Sub');

            } else {
                breadCrumbPop_Sub();
            }
        } else {
            breadCrumbPop_Sub();
        }

    }
    else {
        try { parent.LoadFolder(); } catch (e) { self.close(); }
    }
}


function breadCrumbPop_Sub() {
    if (document.getElementById('last_breadcrumb')) {
        try {
            document.getElementById('last_breadcrumb').click();
        }
        catch (e) {
            alert('errore nel pop dalle molliche di pane');
        }
    }
    else {
        try {
            var lastElement = $('a.breadcrumb_element:last')[0].click();
        }
        catch (e) { }
    }
}

function ScaricaAllegati(param) {
    var strUrl = '';

    if (param == undefined)
        param = '';


    //Se nel parametro alla funzione non sono passati iddoc e document
    //if ( param != '' && param.indexOf('IDDOC') == -1 && param.indexOf('DOCUMENT') == -1 )
    if (param.indexOf('IDDOC=') == -1 && param.indexOf('DOCUMENT=') == -1) {


        var IDDOC = getObj('IDDOC').value;
        var TYPEDOC = getObj('TYPEDOC').value;

        //Se param non finisce per '&'
        if (param != '' && param.substring(param.length, param.length - 1) != '&')
            param = param + '&';

        strUrl = 'DownloadAttach.asp?IDDOC=' + IDDOC + '&DOCUMENT=' + TYPEDOC + '&' + param;
    }
    else
        strUrl = 'DownloadAttach.asp?' + param;


    ExecFunction(pathRoot + 'ctl_library/document/' + strUrl, 'ScaricaAllegati', '');

}




//inserisce i quesiti sul dettaglio del documento
function InsertQuesiti() {


    var RichiestaQuesito = 'YES';
    var CodificaRichiestaQuesito;
    var MessaggioPrivato = -1;
    var EXPIRYDATE;
    var IDDOC_GUID;
    var DOCUMENT;
    var PROTOCOLLOBANDO;
    var SUBTYPE_ORIGIN;
    var strQuesitoAnonimo;
    var ContestoPrivato = 1;
    var strInfoOeAnonime = 'NO'; // Aggiunto per gestire il tipoDoc RISPOSTA_CONCORSO

    trace_in_log_client('FUNCT_InsertQuesiti()--IdmsgPrivato=' + IdmsgPrivato);

    //IdmsgPrivato viene valorizatto solo all'interno quando il messaggio � privato
    try {
        MessaggioPrivato = IdmsgPrivato;
    }
    catch (e) {
        ContestoPrivato = 0;
    }

    try {

        CodificaRichiestaQuesito = getObj('RichiestaQuesito').value;
        //1=SI,2=NO,3=solo per invitati
        //if (CodificaRichiestaQuesito == '2' || CodificaRichiestaQuesito == '3' )
        //	RichiestaQuesito='NO';
        if (CodificaRichiestaQuesito == '3')
            RichiestaQuesito = 'NO';

        //se stiamo su un messaggio invito e RichiestaQuesito= solo per invitati allora visualizzo solo dall'interno i quesiti sugli inviti
        if (CodificaRichiestaQuesito == '3' && Number(MessaggioPrivato) > 0)
            RichiestaQuesito = 'YES';


        trace_in_log_client('FUNCT_InsertQuesiti()--RichiestaQuesito=' + RichiestaQuesito);

    }
    catch (e) {
        trace_in_log_client('FUNCT_InsertQuesiti()--RichiestaQuesitotest_err=' + e.message);
    }


    if (RichiestaQuesito == 'YES') {

        //recupero html dei quesiti
        try {

            //recupero scadenza per inserire quesiti
            try {
                EXPIRYDATE = getObj('TermineRichiestaQuesiti').value;

                if (EXPIRYDATE == '')
                    EXPIRYDATE = getObj('EXPIRYDATE').value;
            }
            catch (e) {
                EXPIRYDATE = getObj('EXPIRYDATE').value;
            }


            //� valorizzato solo in caso di nuovo documento
            try {
                DOCUMENT = getObj('DOCUMENT')[0].value;
            }
            catch (e) {

                try {
                    DOCUMENT = getObj('DOCUMENT').value;
                }
                catch (e) {
                    DOCUMENT = '';
                }

            }


            if (DOCUMENT == '' || DOCUMENT == undefined)
                DOCUMENT = getObj('TIPODOC').value;

            //identificativo del documento 
            try {
                IDDOC_GUID = getObj('IDDOC_GUID').value;
            }
            catch (e) {
                IDDOC_GUID = '';
            }

            try {
                PROTOCOLLOBANDO = getObj('PROTOCOLLOBANDO').value;
            }
            catch (e) {
                PROTOCOLLOBANDO = '';
            }

            try {
                SUBTYPE_ORIGIN = getObj('SUBTYPE_ORIGIN').value;
            }
            catch (e) {
                SUBTYPE_ORIGIN = '';
            }

            try {
                strQuesitoAnonimo = getObj('QuesitoAnonimo').value;
            }
            catch (e) {
                strQuesitoAnonimo = '1';
            }

            // Aggiunto per gestire il tipoDoc RISPOSTA_CONCORSO

            try {
                strInfoOeAnonime = getObj('INFO_OE_ANONIME').value;
            }
            catch (e) {
                strInfoOeAnonime = 'NO';
            }

            trace_in_log_client('FUNCT_InsertQuesiti()--GetHtmlQuesiti=PRE_CHIAMATA_GetHtmlQuesiti.asp');

            //se sono lato interno metto sempre l'area per inserire il quesito
            if (ContestoPrivato == 1)
                strQuesitoAnonimo = '1';

            var FASCICOLO = getObj('FASCICOLO').value;
            var nocache = new Date().getTime();
            var strURL = pathRoot + 'quesiti/GetHtmlQuesiti.asp?EXPIRYDATE=' + EXPIRYDATE + '&CODIFICARICHIESTAQUESITO=' + CodificaRichiestaQuesito + '&DOCUMENT=' + DOCUMENT + '&IDDOC_GUID=' + IDDOC_GUID + '&PROTOCOLLOBANDO=' + PROTOCOLLOBANDO + '&SUBTYPE_ORIGIN=' + SUBTYPE_ORIGIN + '&FASCICOLO=' + FASCICOLO + '&QUESITOANONIMO=' + strQuesitoAnonimo + '&INFO_OE_ANONIME=' + strInfoOeAnonime + '&nocache=' + nocache;
            var ajax = GetXMLHttpRequest();
            ajax.open("GET", strURL, false);
            ajax.send(null);

            if (ajax.readyState == 4) {
                if (ajax.status == 200 || ajax.status == 404 || ajax.status == 500) {
                    getObj('CHIARIMENTI').innerHTML = ajax.responseText;
                }
            }
            trace_in_log_client('FUNCT_InsertQuesiti()--GetHtmlQuesiti=FINE CHIAMATA');

            //visualizzo l'area di inserimento quesito se rischiesto
            var insertQuesito;
            insertQuesito = 'YES';

            try {
                insertQuesito = getObj('SYS_INSERISCIQUESITIDALPORTALE').value;
            }
            catch (e) {
            }

            if (insertQuesito == 'NO') {
                try {
                    getObj('AreaInsertQuesito').style.display = 'none';
                } catch (e) { }
            }

            //provo a recuperare la griglia dei quesiti con le risposte se esistono
            try {
                CercaQuesito();
                HideFormInvioQuesito();

            } catch (e) { }

        } catch (e) {
            trace_in_log_client('FUNCT_InsertQuesiti()--errore_blocco_chiamata_ajax=' + e.message);
        }



    }
    else {
        //nascondo area di cerca e area lista quesiti
        //document.getElementById( 'CHIARIMENTI' ).style.display='none';
        getObj('CHIARIMENTI').style.display = 'none';
    }
}

function CercaQuesito() {

    var PARAM = getObj('PARAM_QUESITINEW').value;
    var ainfo = PARAM.split('@');

    var GUID_DOC = ainfo[0];
    var SUBTYPE_ORIGIN;

    try {
        SUBTYPE_ORIGIN = ainfo[1];
    }
    catch (e) {
        SUBTYPE_ORIGIN = '';
    }




    var Filtro = getObj('FiltroQuesito').value;


    //var backoffice='YES';
    var backoffice = 'NO';

    /*
    adesso viene chiamata solo dall'interno quindi sempre backoffice = 'NO';
    try
    {
      backoffice=getObj('backoffice').value;
    }catch(e){}
    */


    var DOCUMENT;

    //� valorizzato solo in caso di nuovo documento
    try {
        DOCUMENT = getObj('DOCUMENT')[0].value;
    }
    catch (e) {

        try {
            DOCUMENT = getObj('DOCUMENT').value;
        } catch (e) {

            DOCUMENT = '';
        }

    }

    var nocache = new Date().getTime();
    var strURL = pathRoot + 'quesiti/grigliaquesiti.asp?backoffice=' + backoffice + '&Filtro=' + escape(Filtro) + '&GUID_DOC=' + GUID_DOC + '&SUBTYPE_ORIGIN=' + SUBTYPE_ORIGIN + '&DOCUMENT=' + DOCUMENT + '&nocache=' + nocache;

    //impostare CONTESTO=S dall'interno

    ajax = GetXMLHttpRequest();
    if (ajax) {
        ajax.open("GET", strURL, false);
        ajax.send(null);

        if (ajax.readyState == 4) {
            //alert(strURL);
            //alert(ajax.status);
            if (ajax.status == 200 || ajax.status == 404 || ajax.status == 500) {
                var strTemp = ajax.responseText;

                var ainfo = strTemp.split('###');
                document.getElementById('grigliaquesiti').innerHTML = ainfo[1];
            }

            //se nn ci sono chiarimenti nascondo area di ricerca
            if (ainfo[0] == 0) {
                document.getElementById('arearicercaquesiti').style.display = 'none';
                document.getElementById('areapdfquesiti').style.display = 'none';

            }
        }
    }
}


function SetUserCurrentInvioQuesito() {

    ajax = GetXMLHttpRequest();

    if (ajax) {
        var nocache = new Date().getTime();

        ajax.open("GET", pathRoot + 'ctl_library/functions/infoCurrentUser.asp?nocache=' + nocache, false);
        ajax.send(null);

        if (ajax.readyState == 4) {

            if (ajax.status == 200 || ajax.status == 404 || ajax.status == 500) {
                var Infouser = ajax.responseText;
                var ainfo = Infouser.split('#');

                try {
                    getObj('OperatoreEconomico').value = ainfo[0];

                    if (getObj('OperatoreEconomico').value != '')
                        TextreadOnly('OperatoreEconomico', true);

                    getObj('Telefono').value = ainfo[1];
                    getObj('Fax').value = ainfo[2];
                    getObj('EMail').value = ainfo[3];

                    if (getObj('EMail').value != '')
                        TextreadOnly('EMail', true);

                    getObj('backoffice').value = 'no';

                } catch (e) {
                    //il form nn � presente ma soloil campo backoffice per fare correttamente le query diricerca e visualizzazione dei quesiti
                    getObj('backoffice').value = 'no';
                }
            }

            //ricarico i quesiti per prendere anche i miei evasi
            //commentata perch� adesso SetUserCurrentInvioQuesito � chiamata dopo l'inserimento dei quesiti
            //CercaQuesito();
        }

    }
}


//effettua la chiamta ajax inviando i dati di un form
function xmlhttpPost(strURL, formname, responsediv, responsemsg) {
    var xmlHttpReq = false;
    var self = this;

    // Xhr per Mozilla/Safari/Ie7

    if (window.XMLHttpRequest) {

        self.xmlHttpReq = new XMLHttpRequest();

    }

    // per tutte le altre versioni di IE

    else if (window.ActiveXObject) {

        self.xmlHttpReq = new ActiveXObject("Microsoft.XMLHTTP");

    }

    self.xmlHttpReq.open('POST', strURL, true);

    self.xmlHttpReq.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

    self.xmlHttpReq.onreadystatechange = function () {

        if (self.xmlHttpReq.readyState == 4) {

            // Quando pronta, visualizzo la risposta del form

            updatepage(self.xmlHttpReq.responseText, responsediv);

        }

        else {

            // In attesa della risposta del form visualizzo il msg di attesa
            if (responsemsg != '')
                updatepage(responsemsg, responsediv);



        }

    }


    self.xmlHttpReq.send(getquerystring(formname));

}


function getquerystring(formname) {

    var form = document.forms[formname];

    if (form == undefined) {
        form = getObj(formname);
    }


    var qstr = "";



    function GetElemValue(name, value) {

        value = replace_special_charset(value);

        qstr += (qstr.length > 0 ? "&" : "")

            //+ escape(name).replace(/\+/g, "%2B") + "="			
            + encodeURIComponent(name).replace(/\+/g, "%2B") + "="
            //+ escape(value ? value : "");
            + encodeURIComponent(value ? value : "");

        //+ escape(value ? value : "").replace(/\+/g, "%2B");
        //+ escape(value ? value : "").replace(/\n/g, "%0D");

    }



    var elemArray = form.elements;
    if (elemArray == undefined) {
        elemArray = form.children;
    }

    for (var i = 0; i < elemArray.length; i++) {

        var element = elemArray[i];

        try {
            var elemType = element.type.toUpperCase();

            var elemName = element.name;

            if (elemName) {

                if (elemType == "TEXT"

                    || elemType == "TEXTAREA"

                    || elemType == "PASSWORD"

                    || elemType == "BUTTON"

                    || elemType == "RESET"

                    || elemType == "SUBMIT"

                    || elemType == "FILE"

                    || elemType == "IMAGE"

                    || elemType == "HIDDEN")

                    GetElemValue(elemName, element.value);

                else if (elemType == "CHECKBOX" && element.checked)

                    GetElemValue(elemName,

                        element.value ? element.value : "On");

                else if (elemType == "RADIO" && element.checked)

                    GetElemValue(elemName, element.value);

                else if (elemType.indexOf("SELECT") != -1)

                    for (var j = 0; j < element.options.length; j++) {

                        var option = element.options[j];

                        if (option.selected)

                            GetElemValue(elemName,

                                option.value ? option.value : option.text);

                    }

            }
        } catch (e) {
        }
    }

    return qstr;

}

function HideFormInvioQuesito() {

    if (getObj('statoform_invioquesito').value == '0') {
        document.getElementById('campi_invio_quesito').style.display = '';
        document.getElementById('statoform_invioquesito').value = '1';
    }
    else {
        document.getElementById('campi_invio_quesito').style.display = 'none';
        document.getElementById('statoform_invioquesito').value = '0';
    }

    try {
        document.getElementById('errormsg').style.display = 'none';
    }
    catch (e) {
        //alert('diverrore');
    }
}


function updatepage(str, responsediv) {

    document.getElementById(responsediv).innerHTML = str;

}

function replace_special_charset(testo) {

    //@comm questa funzione provvede a rimpiazzare i caratteri speciali che presentano
    //@comm problemi nel recupero mediante il request form da una pagina creata dinamicamente
    //@comm in javascript.
    //@comm Prende in input il testo da pulire e restituisce il testo pulito.

    //@comm creo l'array dei caratteri speciali:
    //@comm array[0][x] --> carattere speciale
    //@comm array[1][x] --> carattere sostitutivo
    //effettuo il cast sul testo; conversione a string
    testo = testo.toString();
    var check = false; //@comm indica se � stato effettuato un rinmpiazzo.
    var array_charset = new Array(2);
    var lunghezza = testo.length;
    var nuovo_testo = '';
    for (r = 0; r < 2; r++) {
        array_charset[r] = new Array(10);
    }

    array_charset[0][0] = "�";
    array_charset[1][0] = "e'";
    array_charset[0][1] = "�";
    array_charset[1][1] = "e'";
    array_charset[0][2] = "�";
    array_charset[1][2] = "L";
    array_charset[0][3] = "�";
    array_charset[1][3] = "i'";
    array_charset[0][4] = "�";
    array_charset[1][4] = "o'";
    array_charset[0][5] = "�";
    array_charset[1][5] = "c";
    array_charset[0][6] = "�";
    array_charset[1][6] = "a'";
    array_charset[0][7] = "�";
    array_charset[1][7] = "^";
    array_charset[0][8] = "�";
    array_charset[1][8] = "u'";
    array_charset[0][9] = "�";
    array_charset[1][9] = "$";


    //@comm comincio il replace.
    for (rt = 0; rt <= lunghezza; rt++) {
        for (pu = 0; pu <= array_charset[0].length; pu++) {
            if (unescape(testo.charAt(rt)) == unescape(array_charset[0][pu])) {

                nuovo_testo = nuovo_testo + array_charset[1][pu];
                check = true;
                break;
            }

        }
        if (check == false) {
            nuovo_testo = nuovo_testo + unescape(testo.charAt(rt));
        }
        check = false;
    }

    return nuovo_testo;

}

function validateForm(idForm) {

    /* Funzione che valida un form in mootols style, itero sui field che trovo nel form
      e per quelli che hanno tra le classi la classe 'required' ne verico la presenza del valore */

    var retVal = true;

    $('#' + idForm + ' input[type=text], #' + idForm + ' textarea').each(function () {

        try {
            if ($("#" + this.id).hasClass("required") && $.trim(getObj(this.id).value) == '') {
                TxtErr(this.id);
                retVal = false;
            }
            else {
                TxtOK(this.id);
            }
        }
        catch (e) {
        }

    });

    return retVal;

}
/*
function TxtErr( field )
{
  try{ getObj(field).style.backgroundColor='#FFBE7D'; }catch(e){};
  try{ getObj(field + '_V' ).style.backgroundColor='#FFBE7D'; }catch(e){};
  try{ getObj(field + '_edit' ).style.backgroundColor='#FFBE7D'; }catch(e){};
  try{ getObj(field + '_edit' ).style.backgroundColor='#FFBE7D'; }catch(e){};
  try{ getObj( field  + '_edit_new' ).style.borderColor='#FFBE7D'; }catch(e){};
  try{ getObj(field + '_edit_new' ).style.backgroundColor='#FFBE7D'; }catch(e){};
	
  if ( getObj(field  ).type == 'checkbox' )
  {
    try{ getObj(field  ).offsetParent.style.backgroundColor='#FFBE7D'; }catch(e){};
  }
}

function TxtOK( field )
{
	
  try{ getObj( field ).style.backgroundColor='#FFF'; }catch(e){};
  try{ getObj( field  + '_V' ).style.backgroundColor='#FFF'; }catch(e){};
  try{ getObj( field  + '_edit' ).style.backgroundColor='#FFF'; }catch(e){};
  try{ getObj( field  + '_edit_new' ).style.borderColor='#FFF'; }catch(e){};
  try{ getObj(field + '_edit_new' ).style.backgroundColor='#FFF'; }catch(e){};
	
  try
  {
    if ( getObj(field).type == 'checkbox' )
    {
      try{ getObj(field  ).offsetParent.style.backgroundColor='#F4F4F4'; }catch(e){};
    }
  }
  catch( e ) 
  {
  }

}
*/
function Viewer_Dettagli_AddSel(parametri) {
    var cod;
    var param;
    var vet;
    var section;
    var command;
    var param;

    vet = parametri.split('#');
    section = vet[0];
    command = vet[1];
    param = vet[2];

    getObj('Viewer_Command').src = pathRoot + 'ctl_library/document/document.asp?MODE=SHOW&COMMAND=' + section + '.' + command + '&' + param;


}

function getCookie(cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');

    for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') c = c.substring(1);
        if (c.indexOf(name) == 0) return c.substring(name.length, c.length);
    }
    return "";
}

function setCookie(cname, cvalue, exdays) {
    var d = new Date();
    d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
    var expires = "expires=" + d.toUTCString();
    document.cookie = cname + "=" + cvalue + "; " + expires;
}

function setCookie2(cname, cvalue) {
    document.cookie = cname + "=" + cvalue + '; path=/';
}

function avvisaScadenzaSessione() {
    try {
        $(function () {
            //document.getElementById('finestra_modale').innerHTML='La sessione di lavoro sta per scadere. <br/> Rinnovarla?';

            $("#finestra_modale_sessione").dialog({
                resizable: false,
                //height:140,
                modal: true,
                buttons: {
                    "OK": function () {
                        avvisaSessione = true; // Ripristino il semaforo per avvisare l'utente all'approssimarsi della scadenza della sessione

                        //Chiamo in ajax una pagina che non produce output soltanto per rinnovare la sessione utente
                        $.ajax({ url: pathRoot + 'CTL_LIBRARY/DOCUMENT/none.asp' }).done(function () {
                            resetSessionTimer(); //Dopo aver rinnovato la sessione di lavoro resetto il timer javascript
                        });

                        resetSessionTimer();

                        $(this).dialog("close");
                    }
                    , Cancel: function () {
                        $(this).dialog("close");
                    }
                },
                open: function () {
                    // //getter
                    // var height = $('#finestra_modale_confirm').dialog('option', 'height');
                    // var width = $('#finestra_modale_confirm').dialog('option', 'width');

                    //setter
                    // $('#finestra_modale_confirm').dialog('option', 'width', 200);
                    // $('#finestra_modale_confirm').dialog('option', 'height', height); // Setting the height (again) so the dialog is centered based on the new content
                    // which isn't loaded yet though, so the developer has to pass the right height

                    document.getElementsByClassName("ui-dialog-buttonset")[0].childNodes[1].focus();
                    if (typeof isFaseII !== 'undefined' && isFaseII) {
                        $('.ui-button:contains(Cancel)').addClass('secondaryButtonVapor');
                        $('.ui-button:contains(OK)').addClass('primaryButtonVapor');
                        $('.ui-button:contains(Cancel)').text('Annulla');
                    }
                }
            });
        });
    }
    catch (e) {
    }
}

function avvisaSessioneScaduta() {
    try {
        var gotoToUrl = pathRoot;

        //Se esiste la variabile urlLogoutIAM ed � diversa da ''
        if (typeof urlLogoutIAM !== 'undefined') {
            if (urlLogoutIAM != '')
                gotoToUrl = urlLogoutIAM;
        }

        $(function () {
            document.getElementById('finestra_modale_sessione').innerHTML = 'Sessione di lavoro scaduta. Accedere di nuovo';

            $("#finestra_modale_sessione").dialog({
                resizable: false,
                modal: true,
                buttons: {
                    "OK": function () {
                        window.location.href = gotoToUrl; //Ritorno alla pagina di login
                        $(this).dialog("close"); //Chiudo la modale. non dovrebbe servire avendo fatto prima la redirect
                    }
                },
                open: function () {
                    // //getter
                    // var height = $('#finestra_modale_confirm').dialog('option', 'height');
                    // var width = $('#finestra_modale_confirm').dialog('option', 'width');

                    //setter
                    // $('#finestra_modale_confirm').dialog('option', 'width', 200);
                    // $('#finestra_modale_confirm').dialog('option', 'height', height); // Setting the height (again) so the dialog is centered based on the new content
                    // which isn't loaded yet though, so the developer has to pass the right height

                    document.getElementsByClassName("ui-dialog-buttonset")[0].childNodes[1].focus();
                    if (typeof isFaseII !== 'undefined' && isFaseII) {
                        $('.ui-button:contains(Cancel)').addClass('secondaryButtonVapor');
                        $('.ui-button:contains(OK)').addClass('primaryButtonVapor');
                        $('.ui-button:contains(Cancel)').text('Annulla');
                    }
                }
            });
        });
    }
    catch (e) {
    }
}

//per aprire i risultati di gara lato bandocentrico
function OpenRisultatoDiGara2(objGrid, Row, c) {
    var cod;
    var protbando;
    var url;

    cod = '0';

    //-- recupero il codice della riga passata
    if (getObj('R' + Row + '_idDocR')) {
        cod = GetIdRow(objGrid, Row, 'self');
        //cod = prendiElementoDaId('R'+ Row + '_idDoc').value;	
        protbando = getObjValue('R' + Row + '_ProtocolloBando');
        precisazioni = getObjValue('val_R' + Row + '_precisazioni');
        if (precisazioni == 0)
            return;
        //alert(precisazioni);
        if (cod != '0') {
            url = 'report/light_RisultatoDiGara_int.asp?PROTOCOLLOBANDO=' + encodeURIComponent(protbando) + '&TYPEDOC=LISTA_RISULTATODIGARA&LO=base&MODE=OPEN&IDDOC=' + encodeURIComponent(cod);
            ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?reset=NO&url=' + encodeURIComponent(url) + '&KEY=document', '', '');
        }

    }



}

function getQSParamNew(QS, ParamName) {

    //VERSIONE PRE ATT 399717, IN URL del cliente ci sta lo. e quando cerca lo va in crisi
    /*
    // Posizione di inizio della variabile richiesta
    var indSta=QS.indexOf(ParamName); 
  	
    // Se la variabile passata non esiste o il parametro � vuoto, restituisco null
    if (indSta==-1 || ParamName=="") return ''; 
  	
    // Posizione finale, determinata da una eventuale &amp; che serve per concatenare pi� variabili
    var indEnd=QS.indexOf('&',indSta); 
  	
    // Se non c'� una &amp;, il punto di fine � la fine della QueryString
    if (indEnd==-1) indEnd=QS.length; 
  	
    // Ottengo il solore valore del parametro, ripulito dalle sequenze di escape
    var valore = unescape(QS.substring(indSta+ParamName.length+1,indEnd)); 
  	
    // Restituisco il valore associato al parametro 'ParamName'
    return valore; 
    */

    // Posizione di inizio della variabile richiesta
    var indSta = QS.indexOf(ParamName);

    // Se la variabile passata non esiste o il parametro � vuoto, restituisco null
    if (indSta == -1 || ParamName == "") return '';

    //Mettiam la QS in URL object e poi su questo oggetto viene fatta la search
    const url = new URL(QS);

    const params = new URLSearchParams(url.search);

    //params = new URLSearchParams(QS);	

    var valore = unescape(params.get(ParamName));

    return valore;


}

function showSysMessage(msg, titolo) {
    try {
        $(function () {
            $('<div title="' + titolo + '"><p>' + msg + '</p></div>').dialog({
                resizable: false,
                modal: true,
                maxWidth: 700,
                minWidth: 400,
                buttons: {
                    "OK": function () {
                        $(this).dialog("close");

                        var U = decodeURIComponent(document.location.toString().toLowerCase());
                        //--kpf 506686 con messaggio di sistema quando sono in lista attivit� non faccio scattare il refresh
                        if (U.indexOf('process') < 0 && U.indexOf('command') < 0 && U.indexOf('lo=lista_attivita') == -1) {
                            document.location = document.location;
                        }


                    }
                }
            });
        });
    }
    catch (e) {
    }
}


function GoTop(name) {
    if (typeof (name) == "undefined") {
        var scrollTop = 0
    } else {
        var scrollTop = $(name)[0].offsetTop
    }
    var nowDistance = document.documentElement.scrollTop || document.body.scrollTop;
    var disTime = 10;
    var speed = 600;
    var timing = 0;
    var oncesDistance = (scrollTop - nowDistance) * disTime / speed;
    function TopMove() {
        if (timing < speed) {
            document.documentElement.scrollTop += oncesDistance;
            document.body.scrollTop += oncesDistance;
            timing += disTime;
            setTimeout(TopMove, disTime)
        } else {
            document.documentElement.scrollTop = scrollTop;
            document.body.scrollTop = scrollTop
        }
    } +
        TopMove()
}
var SetLastScrollWindowOnLoad_OLD_ONLOAD;
function SetLastScrollWindowOnLoad() {
    try {
        SetLastScrollWindowOnLoad_OLD_ONLOAD = window.onload;
        window.onload = SetLastScrollWindow;
    } catch (e) { }

}

//-- recupera dal cookie l'ultima posizione della scroll e la ripristina
function SetLastScrollWindow() {
    try {
        var str = document.location.pathname;

        //-- prendo il livello corrente
        var PATH_LEVEL_NAVIGATION = getObjValue('PATH_LEVEL_NAVIGATION')


        var X = getCookie('PATH_LEVEL_X_' + PATH_LEVEL_NAVIGATION);
        var Y = getCookie('PATH_LEVEL_Y_' + PATH_LEVEL_NAVIGATION);

        if (Y != '0') {
            if (str.toLowerCase().indexOf('document.asp') >= 0) {
                try { document.documentElement.scrollTop = Y; document.body.scrollTop = Y; } catch (e) { }
            }
        }

        //-- svuoto quello successivo per evitar che aprendo un documento differente mi posiziono erroneamente
        PATH_LEVEL_NAVIGATION = parseInt(PATH_LEVEL_NAVIGATION) + 1;
        setCookie2('PATH_LEVEL_X_' + PATH_LEVEL_NAVIGATION, '0');
        setCookie2('PATH_LEVEL_Y_' + PATH_LEVEL_NAVIGATION, '0');


    } catch (e) { }

    //-- invoco la precedente funzione di onload se presente
    try { SetLastScrollWindowOnLoad_OLD_ONLOAD(); } catch (e) { }



}

function OnBodyScroll(e) {

    var scrollTop = 0;

    scrollTop = document.documentElement ? document.documentElement.scrollTop : document.body.scrollTop;


    if (scrollTop == 0) {
        getObj("GOTOP").style.display = 'none';
    }
    else {
        getObj("GOTOP").style.display = '';
    }

    //-- invia al server la posizione corrente per ripristinarla quando si ritorna sulla pagina
    //-- conservo nel cookie la posizione corrente
    try {
        var Y = '0';
        var X = '0';
        var str = document.location.pathname;
        var PATH_LEVEL_NAVIGATION = getObjValue('PATH_LEVEL_NAVIGATION');

        if (str.toLowerCase().indexOf('document.asp') >= 0) {
            var Y = document.documentElement.scrollTop || document.body.scrollTop;
            var X = document.documentElement.scrollLeft || document.body.scrollLeft;
        }

        setCookie2('PATH_LEVEL_X_' + PATH_LEVEL_NAVIGATION, X);
        setCookie2('PATH_LEVEL_Y_' + PATH_LEVEL_NAVIGATION, Y);

        //-- svuota il livello successivo per evitare un effetto collaterale
        PATH_LEVEL_NAVIGATION = parseInt(PATH_LEVEL_NAVIGATION) + 1;
        setCookie2('PATH_LEVEL_X_' + PATH_LEVEL_NAVIGATION, '0');
        setCookie2('PATH_LEVEL_Y_' + PATH_LEVEL_NAVIGATION, '0');

    } catch (e) { };



}
//-- ritorna il numero della colonna indicando il nome del campo
//-- -1 = colonna non presente  non presente
function GetColName(grid, indexCol, Page) {

    var objInd;
    var nInd;
    var obj;
    var numRow;
    var name;


    try {

        obj = getObjPage(grid, Page);
        try {
            name = obj.rows[0].cells[indexCol].id;
        }
        catch (e) {
            //  alert( '2' );
            name = obj[0].rows[0].cells[indexCol].id;
        };

        //toglgie dal nome della colonna il nome della griglia
        return name.substr(grid.length + 1);
    }
    catch (e) { };

}



//recupera il valore del parametro
function Get_CTL_PARAMETRI(Contesto, Oggetto, Prop, DefValue, Idpfu) {

    var value = DefValue;

    ajax = GetXMLHttpRequest();
    if (ajax) {
        var nocache = new Date().getTime();
        ajax.open("GET", '../../ctl_library/functions/Get_CTL_PARAMETRI.asp?Contesto=' + encodeURIComponent(Contesto) + '&Oggetto=' + encodeURIComponent(Oggetto) + '&Prop=' + encodeURIComponent(Prop) + '&DefValue=' + encodeURIComponent(DefValue) + '&Idpfu=' + encodeURIComponent(Idpfu) + '&nocache=' + nocache, false);
        ajax.send(null);
        //alert(ajax.status);	    
        if (ajax.readyState == 4) {

            if (ajax.status == 200 && ajax.responseText.substring(0, 2) == '1#') {

                value = ajax.responseText.substring(2);

            }
            else {
                var value = '';
                alert("ERRORE INVOCAZIONE PAGINA");

            }
        }
    }

    return value;

}

/* SPOSTATA NEL FILE GETOBJ.JS 

function ExecFunctionAttach( Url  , target , param_legacy )
*/

function ExecFunctionCenterAttachDoc(param) {

    param = param.replace('<ID_DOC>', getObj('IDDOC').value);
    vet = param.split('#');

    var w;
    var h;
    var Left;
    var Top;
    var altro;

    if (vet.length < 3) {
        w = screen.availWidth;
        h = screen.availHeight;
        Left = 0;
        Top = 0;
    }
    else {
        var d;
        d = vet[2].split(',');
        w = d[0];
        h = d[1];
        Left = (screen.availWidth - w) / 2;
        Top = (screen.availHeight - h) / 2;

        if (vet.length > 3) {
            altro = vet[3];
        }
    }


    return window.open(vet[0], vet[1], 'toolbar=no,location=no,directories=no,status=no,menubar=no,resizable=yes,copyhistory=yes,scrollbars=yes,left=' + Left + ',top=' + Top + ',height=450,width=600' + altro);

}

/* 
  objCIG 		: oggetto textbox contenente il cig da validare OPPURE direttamente la stringa del cigVal
  withMsgBox  : (opz.) parametro booleano, indica se si vuole dare all'interno di questa funzione la msgbox o lasciare che sia il chiamante a gestirla ( tramite la return )
*/
function validateExtCig(objCIG, withMsgBox) {

    var cigVal = '';
    var isObj = true;
    var esito = false;
    var txtMsg = '';

    //il parametro withMsgBox indica se si vuole dare all'interno di questa funzione la msgbox o lasciare che sia il chiamante a gestirla ( tramite la return )
    //	in assenza di questo parametro lasciamo che il default sia true
    if (withMsgBox === undefined) {
        withMsgBox = true;
    }

    //Se il parametro passato � gi� la stringa contenente il CIG
    if (typeof objCIG === 'string' || objCIG instanceof String) {
        cigVal = objCIG;
        isObj = false
    }
    else
        cigVal = objCIG.value;	//Se invece si sta passando l'oggetto che contiene il cig ( ad es. il campo textbox )

    if (cigVal != '') {

        ajax = GetXMLHttpRequest();

        if (ajax) {
            var nocache = new Date().getTime();
            ajax.open("GET", pathRoot + 'ctl_library/functions/verificacig.asp?cig=' + encodeURIComponent(cigVal) + '&nocache=' + nocache, false);
            ajax.send(null);

            if (ajax.readyState == 4) {

                if (ajax.status == 200) {

                    var outAjax = ajax.responseText;

                    if (outAjax != '1#OK') {
                        //Se c'� un msg di errore gestito lo diamo in output
                        //if ( outAjax.startsWith("0#") ) -- la startsWith non ha una buona retrocompatibilit�
                        if (outAjax.lastIndexOf("0#") === 0) {
                            outAjax = outAjax.replace("0#", "");
                            txtMsg = outAjax;
                        }
                        else
                            txtMsg = 'CIG non valido';
                    }
                    else {
                        esito = true;
                    }

                }
                else {
                    txtMsg = 'Non e\' stato possibile verificare la correttezza del CIG';
                }

            }
            else {
                txtMsg = 'Non e\' stato possibile verificare la correttezza del CIG';
            }

        }

        if (withMsgBox && txtMsg != '') {
            DMessageBox('../ctl_library/', txtMsg, 'Attenzione', 2, 400, 300);
        }

        if (isObj && !esito) {
            objCIG.value = '';
        }

    }

    return esito;

}

/*
  AF_Loader	( funzione generica per creare un avanzamento percentuale gestito invocando ricorsivamente, tramite ajax, una pagina che governer� le logiche. l'output di questa pagina deve corrispondere con il json atteso
    - paramUrl 		( pagina da invocare, comprensiva dei parametri utili a lavorare )
    - modalTitle 	( opz. titolo che si vuole dare alla finestra modale )
    - options		( opz. lasciare stringa vuota per il momento. utile per estensioni future )
    - mode			( Invocare questa funzione con il parametro mode vuoto. sar� poi il codice ad iterare cambiandone i valori in : 'START', 'STEPS', 'END' )
  	
    STRUTTURA JSON ATTESA DALLA PAGINA INVOCATA
  	
      {
        "TotElements":1000,
        "CurrentElement":1,
        "NextElement":100,
        "percentage":10,
        "captionCurrentOperation":"Generazione pdf...",
        "finalResponseType":"text",	// text or file
        "currentStatus":"OK",	// OK or ERROR
        "output":null,	//ritornato nella fase di 'END' e con finalResponseType a "text"
        "buttons":null,  // es. { "ON_OK":"metodoOnOK", "ON_CANCEL":"metodoOnCancel" }  ( al momento non usato )
        "error":{
          "source":null,
          "description":null
        }
      }
  	
*/
var loaderInUse = false; //Variabile/semaforo che blocca il loader se viene chiusa la modale

function AF_Loader(loaderUrl, modalTitle, options, mode, modalWidth, modalHeight) {

    var runTimeError = false;
    var attivaDebug = false;
    var tmpPath = '../';

    if (isSingleWin()) {
        tmpPath = pathRoot;
    }


    try {
        var idFinestraModale = 'finestra_modale';

        if (modalTitle == '' || modalTitle == undefined)
            modalTitle = '';
        else
            modalTitle = CNV(pathRoot, modalTitle);

        if (modalWidth == '' || modalWidth == undefined)
            modalWidth = '500';

        if (modalHeight == '' || modalHeight == undefined)
            modalHeight = '270';



        //Apriamo la nuova modale solo se siamo sulla prima richiesta di apertura e non nell'iterazione di avanzamento 
        if (mode == '' || mode == undefined) {
            /*	INIT DELL'INTERFACCIA */

            if (attivaDebug) alert('init interfaccia');

            getObj(idFinestraModale).innerHTML = '';

            $("#" + idFinestraModale).load(pathRoot + 'CTL_LIBRARY/blank.html').dialog({
                resizable: false,
                modal: true,
                width: modalWidth,
                height: modalHeight,
                title: modalTitle,
                buttons: {},
                close: function (event, ui) { loaderInUse = false; }
            });

            loaderInUse = true;

            getObj(idFinestraModale).innerHTML = AF_Loader_html(modalTitle, '0');

            try {
                //Per non far uscire il focus sulla 'X' della modale ( va in automatico quando la modale non ha bottoni )
                $(':focus').blur()
            }
            catch (e) { }

            mode = 'START';
            setTimeout(function () { AF_Loader(loaderUrl, modalTitle, options, mode); }, 10);

            //dalla successiva chiamata inizier� il caricamento con 'mode' a START. i successi saranno STEPS e per finire END

        }
        else {

            if (attivaDebug) alert('init ajaxLoader');

            var ajaxLoader = GetXMLHttpRequest();

            if (ajaxLoader) {
                var nocache = new Date().getTime();

                //ajaxLoader.open("GET", pathRoot + loaderUrl + '&progress_mode=' + mode + '&nocache=' + nocache , true);
                ajaxLoader.open("GET", pathRoot + loaderUrl + '&progress_mode=' + mode + '&nocache=' + nocache, false);
                ajaxLoader.send(null);

                //ajaxLoader.onreadystatechange=function()
                if (ajaxLoader.readyState == 4 && loaderInUse) {
                    if (ajaxLoader.status == 200) {
                        var loader_outAjax = ajaxLoader.responseText;

                        if (attivaDebug) alert(loader_outAjax);

                        var objAFProgress = JSON.parse(loader_outAjax);

                        //alert(outAjax);

                        //Se non c'� stato un errore
                        if (objAFProgress.currentStatus.toLowerCase() == 'ok') {

                            if (mode != 'END') {

                                //Se siamo arrivati alla fine del caricamento
                                if (objAFProgress.percentage == 100) {
                                    if (attivaDebug) alert('Caricamento al 100%');

                                    mode = 'END';

                                    //L'ultimo step successivo al completamento ( quello di END ), nel caso di response finale di tipo FILE, non invochiamo nuovamente la pagina via ajax ma 
                                    //	lasciamo che sia il browser ad effettuare il download
                                    if (objAFProgress.finalResponseType.toLowerCase() == 'file') {
                                        $("#" + idFinestraModale).dialog("close");
                                        ExecDownloadSelf(pathRoot + loaderUrl + '&progress_mode=' + mode + '&nocache=' + nocache);
                                        // ( non continuiamo la ricorsione )
                                    }
                                    else
                                        setTimeout(function () { AF_Loader(loaderUrl, modalTitle, options, mode); }, 10);

                                }
                                else {
                                    mode = 'STEPS';


                                    var caption = objAFProgress.captionCurrentOperation; //non facciamo la cnv ne l'htmlencode. � il server che deve decidere cosa dare in output
                                    var outputAFLoader = AF_Loader_html(caption, objAFProgress.percentage);

                                    if (attivaDebug) alert('Aggiornamento output da step : ' + outputAFLoader);

                                    getObj(idFinestraModale).innerHTML = outputAFLoader;

                                    setTimeout(function () { AF_Loader(loaderUrl, modalTitle, options, mode); }, 10);
                                    //Chiamata ricorsiva per continuare l'avanzamento
                                    //AF_Loader(loaderUrl, modalTitle, options, mode);

                                }
                            }
                            else {
                                if (attivaDebug) alert('Aggiornamento output con mode ' + mode);

                                loaderInUse = false;

                                if (objAFProgress.finalResponseType.toLowerCase() == 'text')
                                    //alert(objAFProgress.output);
                                    getObj(idFinestraModale).innerHTML = objAFProgress.output;
                            }

                        }
                        else {
                            if (attivaDebug) alert('Risposta con errore:' + objAFProgress.error.description);

                            getObj(idFinestraModale).innerHTML = '';
                            loaderInUse = false;
                            DMessageBox('../ctl_library/', objAFProgress.error.description, 'Attenzione', 2, 400, 300);
                        }


                    }
                    else {

                        if (attivaDebug) alert('Risposta con errore di runtime' + ajaxLoader.responseText);

                        getObj(idFinestraModale).innerHTML = ajaxLoader.responseText;
                        loaderInUse = false;

                        //costruisco data attuale
                        var today = new Date();
                        var date = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
                        var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
                        var dateTime = date + ' ' + time;

                        //messaggio applicativo errore per utente generico
                        var strMsg = 'NO_ML###' + CNV(tmpPath, 'INFO_UTENTE_ERRORE_PROCESSO') + dateTime;

                        //DMessageBox( '../ctl_library/' , 'Errore di elaborazione. Riprovare a breve' , 'Attenzione' , 2 , 400 , 300 );
                        DMessageBox('../ctl_library/', strMsg, 'Attenzione', 2, 400, 300);

                        //console.log(ajax.responseText);
                    }


                }

            } // fine if(ajaxLoader)

        }


    }
    catch (err) {
        runTimeError = true;
        loaderInUse = false;
        alert('errore client:' + err.message);
    }
    finally {

        //ShowWorkInProgress(false);

        //Nascondiamo la modale solo se c'� stato un errore di runtime lato client, altrimenti la lasciamo perch� potrebbe esserci un output da mantenere o un messaggio di errore gestito
        if (runTimeError) {
            try {
                if (attivaDebug) alert('finally. runtimeerror');
                getObj('finestra_modale').innerHTML = '';
                $("#finestra_modale").dialog("close");
            }
            catch (e) { }
        }

    }

}

function AF_Loader_html(caption, percentage) {
    //return '<div class="af_loader_div"><span class="af_loader_caption">' + caption + '</span><br/><br/><div class="progress"><div class="progress-bar progress-bar-success active progress-bar-striped" role="progressbar" aria-valuenow="40" aria-valuemin="0" aria-valuemax="100" style="width:' + percentage + '%">' + percentage + '% Completata </div></div></div>';
    return '<div class="af_loader_div"><span class="af_loader_caption">' + caption + '</span><br/><br/>' + HTML_Progress_Bar(percentage) + '</div>';
}




function ShowField(Field, bShow) {
    try {
        if (bShow == true) {
            try {
                obj = getObj('cap_' + Field).parentNode;
                setVisibility(obj, '');
            } catch (e) { }
            try {
                obj = getObj(Field).parentNode;
                setVisibility(obj, '');
            } catch (e) { }
            try {
                obj = getObj(Field + '_V').parentNode;
                setVisibility(obj, '');
            } catch (e) { }
            try {
                obj = getObj('Cell_' + Field).parentNode.parentNode.parentNode;
                setVisibility(obj, '');
            } catch (e) { }
        }
        else {
            try {
                obj = getObj('cap_' + Field).parentNode;
                setVisibility(obj, 'none');
            } catch (e) { }
            try {
                obj = getObj(Field).parentNode;
                setVisibility(obj, 'none');
            } catch (e) { }
            try {
                obj = getObj(Field + '_V').parentNode;
                setVisibility(obj, 'none');
            } catch (e) { }
            try {
                obj = getObj('Cell_' + Field).parentNode.parentNode.parentNode;
                setVisibility(obj, 'none');
            } catch (e) { }


        }
    }
    catch (e) { }

}


//-- ritorna il numero della colonna indicando il nome del campo
//-- -1 = colonna non presente  non presente
function GetPositionCol(grid, idCol, Page) {

    var objInd;
    var nInd;
    var obj;
    var numRow;
    var attr;


    try {

        obj = getObjPage(grid + '_' + idCol, Page);

        attr = GetProperty(obj, 'column');

        return attr;
    }
    catch (e) { return -1; }

}




function Pdf_Quesiti() {

    var PARAM = getObj('PARAM_QUESITINEW').value;
    var ainfo = PARAM.split('@');

    var GUID_DOC = ainfo[0];
    var SUBTYPE_ORIGIN;

    try {
        SUBTYPE_ORIGIN = ainfo[1];
    }
    catch (e) {
        SUBTYPE_ORIGIN = '';
    }




    var Filtro = getObj('FiltroQuesito').value;




    /*
    adesso viene chiamata solo dall'interno quindi sempre backoffice = 'NO';
    try
    {
      backoffice=getObj('backoffice').value;
    }catch(e){}
    */


    var DOCUMENT;

    //� valorizzato solo in caso di nuovo documento
    try {
        DOCUMENT = getObj('DOCUMENT')[0].value;
    }
    catch (e) {

        try {
            DOCUMENT = getObj('DOCUMENT').value;
        } catch (e) {

            DOCUMENT = '';
        }

    }

    var nocache = new Date().getTime();

    var strURL = '/quesiti/grigliaquesiti.asp?FOR_PDF=YES&Filtro=' + escape(Filtro) + '&GUID_DOC=' + GUID_DOC + '&SUBTYPE_ORIGIN=' + SUBTYPE_ORIGIN + '&DOCUMENT=' + DOCUMENT + '&';

    //ExecFunction( pathRoot + 'ctl_library/pdf/pdf.asp?URL=' +  encodeURIComponent ( strURL ) + '&PAGEORIENTATION=landscape&VIEW_FOOTER_HEADER=GARA_QUESITI_HF_Stampe&IDDOC='+ GUID_DOC + '&TYPEDOC='  , 'PrintDocument' , ',menubar=yes,left=0,top=0,width=950,height=900');	

    //tolta la vista per mettere heaader e footer GARA_QUESITI_HF_Stampe da ripristinare
    ExecFunction(pathRoot + 'CTL_Library/accessBarrier.asp?goto=pdf/pdf.asp&URL=' + encodeURIComponent(strURL) + '&PAGEORIENTATION=&VIEW_FOOTER_HEADER=&IDDOC=' + GUID_DOC + '&TYPEDOC=');

}

function validateFieldIPA(obj) {
    var str = obj.value;
    var ret = true;

    /*
      Il codice IPA deve essere esattamente di 6 cifre e non deve contenere - o _
    */

    if (str != '') {
        if (str.length != 6) {
            ret = false;
        }

        if (str.indexOf('-') >= 0) {
            ret = false;
        }

        if (str.indexOf('_') >= 0) {
            ret = false;
        }

        if (ret == false) {
            AF_Alert("Valore non ammesso. Il codice IPA deve essere esattamente di 6 cifre e non deve contenere i caratteri - e _");
            obj.value = '';
        }
        else
            obj.value = str.toUpperCase();
    }

    return ret;
}

//scorre la frase e la prima lettera di ogni parola la mette in maiuscolo.
//separatori tra parole tutti i caratteri che non sono le lettere dell'alfabeto
function Upper_First_Letter(strValue) {

    //return strValue.replace(/(^\w|\s\w)(\S*)/g, (_,m1,m2) => m1.toUpperCase() + m2.toLowerCase())

    return strValue.replace(/\w+/g, function (word) {
        return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase();
    });

}

//restituisce HTML per il disegno della PROGRESS BAR
function HTML_Progress_Bar(percentage) {
    if (percentage != 100)
        return '<div class="progress"><div class="progress-bar progress-bar-success active progress-bar-striped" role="progressbar" aria-valuenow="40" aria-valuemin="0" aria-valuemax="100" style="width:' + percentage + '%">' + percentage + '% Completata </div></div>';
    else
        return '<div class="progress"><div class="progress-bar progress-bar-success" role="progressbar" aria-valuenow="40" aria-valuemin="0" aria-valuemax="100" style="width:' + percentage + '%">' + percentage + '% Completata </div></div>';



}

//controlla se un valore � uno smart CIG 
//smartCIG iniziano sempre con una lettera �X�, �Y� o �Z�.
//Ritorna 0/1 ( no smart cig / si smart cig )
function IsSmartCIg(strValue) {
    var nRet = 0;

    strValue = strValue.toUpperCase();

    if (strValue.substring(0, 1) == 'X' || strValue.substring(0, 1) == 'Y' || strValue.substring(0, 1) == 'Z')
        nRet = 1;

    return nRet;
}

//calcolo i caratteri rimanenti
function Quesito_MaxLen(obj, maxLength) {
    //troncare eventualemente i caratteri sul campo
    TA_MaxLen(obj, maxLength);

    var LenQuesito = obj.value.length;

    //alert(LenQuesito);

    nCharRem = maxLength - LenQuesito;

    //aggiornare etichetta a video 
    getObj('Label_Quesito').innerText = CNV(pathRoot, "Quesito") + ' ( caratteri disponibili ' + nCharRem + ' su ' + maxLength + ')';



}

function trace_in_log_client(param) {
    try {
        //var ajax_trace = GetXMLHttpRequest(); 
        var ajax_trace = new XMLHttpRequest();
        if (ajax_trace && idpfuUtenteCollegato == utente_verifica) {

            var nocache = new Date().getTime();
            ajax_trace.open("GET", pathRoot + 'ctl_library/functions/Trace_in_log_utente.asp?' + param + '&nocache=' + nocache, false);
            ajax_trace.send(null);
        }
    } catch (e) { }
}

//funzione invocata dopo ogni comando suldocumento 
function DOCUMENT_AFTER_COMMAND(Command, Section_Id, TipoSezione) {

    //tolgo il workinprogress sul documento	
    ShowWorkInProgress(false);

    //inizializza il DRAG_AND_DROP sugli allegati
    Init_DRAG_AND_DROP_Allegati();

}

function Init_DRAG_AND_DROP_Allegati() {

    //inizializza il DRAG_AND_DROP sugli allegati
    if (ATTIVA_DRAG_AND_DROP_ATTACH = 'YES') {

        if (typeof (urlPortaleDandD) != "undefined") {

            initgriduploader(urlPortaleDandD, UploadServiceRootUrl, sizeAttach, estensioniUpload);
        }
        else {

            initgriduploader(urlPortale, UploadServiceRootUrl, sizeAttach, estensioniUpload);
        }
    }
}