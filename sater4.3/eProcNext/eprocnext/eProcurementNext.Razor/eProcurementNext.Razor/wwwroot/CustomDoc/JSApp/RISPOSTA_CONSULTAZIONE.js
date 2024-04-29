window.onload = DisplaySection;


//funzione per inserire nella sezione documentazione i tipi allegati consentiti scelti in creazione del BANDO
function FormatAllegato() {

    var numDocu = GetProperty(getObj('DOCUMENTAZIONEGrid'), 'numrow');
    var tipofile;
    var richiestaFirma;
    var onclick;
    var obj;

    for (i = 0; i <= numDocu; i++) {
        try {

            tipofile = getObj('RDOCUMENTAZIONEGrid_' + i + '_TipoFile').value;

            try {
                richiestaFirma = getObj('RDOCUMENTAZIONEGrid_' + i + '_RichiediFirma').value;
            } catch (e) {
                richiestaFirma = '';
            }

			if( tipofile != '' )
			{
				tipofile = ReplaceExtended(tipofile, '###', ',');
				tipofile = 'EXT:' + tipofile.substring(1, tipofile.length);
				tipofile = tipofile.substring(0, tipofile.length - 1) + '-';
			}


            obj = getObj('RDOCUMENTAZIONEGrid_' + i + '_Allegato_V_BTN').parentElement;
            onclick = obj.innerHTML;
			
            //RECUPERO DINAMICAMENTE LA Format			
			nPosStartFormat = onclick.indexOf('&amp;FORMAT=');
			strTailOnclick = onclick.substring(nPosStartFormat+12, nPosStartFormat+100);
			nPosEndParametri = strTailOnclick.indexOf('\' ');
			
			nPosEndFormat = strTailOnclick.indexOf('&amp;');
			if (nPosEndFormat == -1)
				nPosEndFormat = nPosEndParametri;
			
			strHeadFormat =  strTailOnclick.substring(0 , nPosEndFormat);
			strPatternFormat = 'FORMAT=' + strHeadFormat;
			if (richiestaFirma == '1') 
			{
				strHeadFormat = strHeadFormat + 'B'; //format per forzare la verifica di firma bloccante in caso di mancata firma o file corrotto
			}

			tipofile =  strHeadFormat + tipofile;			
			strExt = 'FORMAT=' + tipofile;

			onclick=onclick.replace(new RegExp(strPatternFormat, 'g'), strExt);
			
			
            obj.innerHTML = onclick;

        } catch (e) {}
    }

}



function Doc_DettagliDel(grid, r, c) {
    var v = '0';
    try {
        v = getObj('RDOCUMENTAZIONEGrid_' + r + '_Obbligatorio').value;
    } catch (e) {};

    if (v == '1') {
        //DMessageBox( '../' , 'La documentazione è obbligatoria' , 'Attenzione' , 1 , 400 , 300 );
    } else {
        DettagliDel(grid, r, c);
    }
}

function DOCUMENTAZIONE_AFTER_COMMAND() {
    HideCestinodoc();
    FormatAllegato();
	

}



function HideCestinodoc() 
{
    try {
        var i = 0;

        if (getObj('StatoDoc').value == 'Saved' || getObj('StatoDoc').value == '') {
            for (i = 0; i < DOCUMENTAZIONEGrid_EndRow + 1; i++) {
                if (getObj('RDOCUMENTAZIONEGrid_' + i + '_Obbligatorio').value == '1') {
                    getObj('DOCUMENTAZIONEGrid_r' + i + '_c0').innerHTML = '&nbsp;';
                }
            }
        }
    } catch (e) {}

}


function RefreshContent() 
{
    RefreshDocument('');
}


function DisplaySection(obj) 
{
	try
	{
		HideCestinodoc();
		FormatAllegato();
	}
	catch(e)
	{
	}
}





