function MySec_Dettagli_AddRow( objGrid , Row , c  )
{
	var cod;
	var nq;
	var strCommand;
	var testo;
	

	
	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );

	try{		
		getObj('R' + Row + '_FNZ_ADD')[0].style.border = "solid 1px black"
  	}catch(e){
	}
	
	var strDoc;
	strDoc = getObj('DOCUMENT').value;
	v = strDoc.split('.');
	
	//-- compone il comando per aggiungere la riga
	strCommand = v[0] + '#' + v[1] + '#' + 'Template=' + cod + '&TABLEFROMADD=' + v[2];
	
	//alert( strCommand );
	
	//-- invoca sulla pagina chiamante l'aggiunta dell'attributo
	
				parent.opener.document.getElementById('URL').innerHTML  += cod 
				
				
	
	//parent.opener.SaveDoc();
	parent.close();
}

function Prepara_Bottone() 
{
    	
	getObj('FNZ_ADD').outerHTML='<input type="button"  class="button" onclick="Inserisci_Link()" value="Ok">';
	   	
}

window.onload=Prepara_Bottone;

function Inserisci_Link ()
{
	var link
	link='<a href="' + getObj('URL').value + '">' + getObj('Titolo').value + '</a>';

		//-- invoca sulla pagina chiamante l'aggiunta dell'attributo
		for(i=0;i <= parent.opener.DETTAGLIGrid_NumRow; i++ )
		{
			if(parent.opener.document.getElementById('FRM_R'+i+'_Template').contentDocument) 
				{
					
					parent.opener.document.getElementById('R'+i+'_Template').innerHTML  =  parent.opener.document.getElementById('R'+i+'_Template').innerHTML + '\n' + link;
					parent.opener.document.getElementById('FRM_R'+i+'_Template').contentDocument.body.innerHTML  =  parent.opener.document.getElementById('FRM_R'+i+'_Template').contentDocument.body.innerHTML +'\n'+ link;
				}
			else
				{
					
					//parent.opener.document.getElementById('R'+i+'_Template').innerHTML  =parent.opener.document.getElementById('R'+i+'_Template').innerHTML +'\n'+ link;
					parent.opener.document.getElementById('FRM_R'+i+'_Template').contentWindow.document.body.innerHTML  = parent.opener.document.getElementById('FRM_R'+i+'_Template').contentWindow.document.body.innerHTML +'\n'+ link ;
				}
			
			
		}
	//parent.opener.SaveDoc();
	parent.close();}
