/*<script language=javascript>*/
// Funzioni Client per abilitare l'help contestuale

	arrayid = new Array()
	strActiveHelp=0;
	//contatore per l'array di document
	CountDoc=0;


	//Descrizione: A partire da un determinato oggetto document,se � un frameset carica in un vettore tutti i documenti figli.

	function LoadArrayDocument(objDocument){
	var nFrame;
	var retrieve
	//fare controllo per evitare di caricare i document dei frame nascosti
	//controllo per evitare di caricare gli IFRAMES 
	objDominiEstesi=getObjDoc(objDocument,"DominiEstesi");
	if (objDominiEstesi != null)
	if (objDominiEstesi.tagName.toLowerCase()=='iframe')
	retrieve=0
	else
	retrieve=1;

	if (retrieve==1){
		nFrame = objDocument.frames.length;
		if (nFrame > 0) {
			for (j = 0; j < nFrame; j++){
		arrayCall[nIndcall] = j;
	nIndcall++;
	LoadArrayDocument(objDocument.frames[j].document);
	nIndcall--;
	j=arrayCall[nIndcall];
				
			}	
		}
	else {
		arrayTemp[CountDoc] = objDocument;
	CountDoc++;
		}
	}
	else
	{
		arrayTemp[CountDoc] = objDocument;
	CountDoc++;
	}
		
	
}



	//Descrizione: imposta su ogni oggetto del document di pagina (o dei document di un frameset) l'evento onclick per aprire la pagina 
	//             di help contestuale associata 



	function EnableHelp (objdocument) {
	//arrayid = new Array()	

	if (strActiveHelp==0){
		if (objdocument != null)
	var strdocument=objdocument;
	else
	var strdocument=document;
	strActiveHelp=1;
	//array dei documenti da trattare
	arrayTemp=new Array();
	//se sto in un frameset allora attivo l'help contestuale su tutte le pagine del frameset
	k=0;
	CountDoc=0;
	nIndcall=0
	arrayCall = new Array();
	//carico in memoria tutti i documenti a partire da strdocument
	LoadArrayDocument(strdocument);
	//per tutti i documenti effettuo la gestione dell'onclick per ogni oggeto del documento

	for (q = 0; q < CountDoc; q++){
		strdocument = arrayTemp[q];
			//valorizzazione propriet� id del body del documento se non � valorizzata

			//if (strdocument.all("id_body.htm") == null) {
			if (getObjDoc(strdocument,"id_body.htm") == null) {
		strdocument.body.id = 'id_body.htm';
			}
			//controlliamo la presenza del campo hiddenWork: per non considerare i frame nascosti
			//if (strdocument.all("hiddenWork")!= null) {				
			if (getObjDoc(strdocument,"hiddenWork")!= null) {
		/*tempClick = strdocument.all("hiddenWork").onclick;
		*/
		tempObjClick = getObjDoc(strdocument, "hiddenWork");
	tempClick = tempObjClick.onclick;
	tempObjBody = getObjDoc(strdocument,"id_body.htm");
	tempObjBody.style.cursor='help';

	//thedocument = strdocument.all;
	thedocument = GetAll(strdocument);



	//thedocument= strdocument;
	nDocumentlegth = thedocument.length;

	for (i = 0; i < nDocumentlegth; i++) {
					
					var tempobj = thedocument[i];
	//alert('vecchio onclick:  '+tempobj.name + ' ' +tempobj.onclick);
	//Controllo se l'oggetto in esame � il bottone dell'help oppure un campo hidden
	if((tempobj.id != 'buttonHelp') && (tempobj.type != 'hidden')) {

		arrayid[k] = new Array(7)
						arrayid[k][0]=tempobj.id
	arrayid[k][1]=tempobj.style.cursor
	arrayid[k][2]=tempobj.onclick
	arrayid[k][3]=strdocument
	arrayid[k][4]=tempobj

	//se si tratta di un link e viene attivato con l'href  mi conservo l'href 
	if (tempobj.tagName.toLowerCase() == "a"){
		arrayid[k][5] = tempobj.href;
	arrayid[k][6]=tempobj.target;
	tempobj.href="javascript:";
	tempobj.target="";
						}
	k+=1;
	tempobj.style.cursor='help';

	//vedo se l'oggetto ha la propriet� ID_HELP e in tal caso attivo l'help
	StrValueID_Help=GetProperty(tempobj, "id_help");

	if ( StrValueID_Help != null && tempobj.id.toLowerCase() != "buttonhelp" && tempobj.tagName.toLowerCase() != "form" && tempobj.tagName.toLowerCase() != "tbody" && tempobj.tagName.toLowerCase() != "link" && tempobj.tagName.toLowerCase() != "html" && tempobj.tagName.toLowerCase() != "head" && tempobj.tagName.toLowerCase() != "title" && tempobj.tagName.toLowerCase() != "body"){
		tempobj.onclick = tempClick;						
						}
	else {
		tempobj.onclick = '';		
						}	
					
					}	
						
				}	
			}//if (strdocument.all("hiddenWork")!= null)			
		}
	}
	else {
		//disattivo l'help se era attivato

		DisableHelp();
	}	
	
}





	/*
	Decrizione: Disabilta l'help contestuale
	*/
	function DisableHelp () {
		strActiveHelp = 0;
	nlength = arrayid.length;
	for (i = 0; i < nlength; i++) {

		objCurDocument = arrayid[i][3];
	if (objCurDocument.all("id_body.htm")!= null)
	objCurDocument.all("id_body.htm").style.cursor='';
	//tempobj = objCurDocument.all(arrayid[i][0]);		
	tempobj=arrayid[i][4];
	tempobj.style.cursor=arrayid[i][1];
	tempobj.onclick=arrayid[i][2];
	if (tempobj.tagName.toLowerCase() == "a")
	tempobj.href=arrayid[i][5];
	tempobj.target=arrayid[i][6];

	objCurDocument = "";
		//arrayid[i] = null;
	}

	//arrayid = null;
}


	/*
	Input:objElement elemento su cui aprire l'help
	Decrizione:apre la pagina di help contestuale riferita all'elemento passato in input (objElement)
	*/
	function openHelp(objElement) {

		const_width = 700;
	const_height=400;

	// una variabile e mi ricavo il valore della posizione della finestra a sinistra dello schermo
	sinistra=(screen.width-const_width)/2;
	alto=(screen.height-const_height)/2;

	//recupero la pagina da agganciare dalla proprieta id_help dell'oggetto
	StrValueID_Help=GetProperty(objElement,"id_help");
	strPath='<%=Application("strVirtualDirectory")%>/Help/<%=Session("strSuffLing")%>';
	window.open(strPath+'/Help_AFSLink.htm#'+StrValueID_Help,'','toolbar=no,location=no,directories=no,status=no,menubar=no,resizable=no,copyhistory=no,scrollbars=no,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
	DisableHelp();
}

	function openMenu(objElement) {

		/*if (document.form1.texthelp.value == "1") {
			document.form1.texthelp.value = "0";
			document.all("id_body").style.cursor='';
			objElement.style.cursor='';
	
			const_width=300;
			const_height=200;
			  
			sinistra=(screen.width-const_width)/2;
			//creo una variabile e mi ricavo il valore della posizione della finestra a sinistra dello schermo
	
			alto=(screen.height-const_height)/2;
	
			window.open('menu.asp?Id='+objElement.name,'menu','toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
		}
		*/
		alert('vecchia azione' + objElement.id + objElement.name)
	}


/*
	FUNZIONE: Open_Help_Page
	INPUT: pagina html da aprire
	DESCRIZIONE: Questa funzione permette di aprire la pagina di help passata come parametro
	AUTORE: Carmine Vella
	*/
	function Open_Help_Page(strPage){
		const_width = 700;
	const_height=400;
	//creo una variabile e mi ricavo il valore della posizione della finestra a sinistra dello schermo
	sinistra=(screen.width-const_width)/2;
	alto=(screen.height-const_height)/2;
	strPath='<%=Application("strVirtualDirectory")%>/Help/<%=Session("strSuffLing")%>'+ '/'+ '<%=Application("HelpIndexPage")%>' + strPage;
	window.open(strPath ,'','toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
 }


/*</script>*/