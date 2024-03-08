function RefreshContent() {
    var checkReloadPadre = false;
    parent.RefreshContent();

}


window.onload = RefreshDocPadre;

function RefreshDocPadre() {

    var nReload = true
	var tmpVirtualDir;
	
	tmpVirtualDir = '/Application';

	if ( isSingleWin() )
		tmpVirtualDir = urlPortale;

    if (parent.parent.getObj('StatoDoc').value == 'Saved') {

        if (GridViewer_NumRow < 0)
            nReload = false;
        else {

            for (i = 0; i <= GridViewer_NumRow; i++) {

                if (GetProperty(getObjGrid('val_R' + i + '_StatoFunzionale'), 'value') == 'InLavorazione') {
                    nReload = false;
                    break;
                }
            }
        }

    } else {
        nReload = false;
    }

    if (nReload)
        parent.parent.RefreshDocument(tmpVirtualDir + '/ctl_library/document/');

}