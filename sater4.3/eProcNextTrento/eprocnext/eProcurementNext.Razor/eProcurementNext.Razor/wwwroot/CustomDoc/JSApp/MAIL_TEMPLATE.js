
	function MySec_Dettagli_AddRow( objGrid , Row , c  )
	{
		var cod;
		var nq;
		var strCommand;
		var testo;

		//-- recupero il codice della riga passata
		cod = GetIdRow( objGrid , Row , 'self' );

		try
		{
			getObj('R' + Row + '_FNZ_ADD')[0].style.border = "solid 1px black";
		}
		catch(e)
		{
		}
		
		if((getObj('DOCUMENT').value)=='DETTAGLIOGGETTO.ADDFROM.view_attributi_template')
		{
			//-- invoca sulla pagina chiamante l'aggiunta dell'attributo
			for(i=0;i <= parent.opener.DETTAGLIGrid_NumRow; i++ )
			{
				try
				{
					if(parent.opener.document.getElementById('R'+i+'_Oggetto').contentDocument) 
					{
						parent.opener.document.getElementById('R'+i+'_Oggetto').innerHTML  = cod + '\n' + parent.opener.document.getElementById('R'+i+'_Oggetto').innerHTML;
						parent.opener.document.getElementById('R'+i+'_Oggetto').contentDocument.body.innerHTML  =  cod + '\n' + parent.opener.document.getElementById('FRM_R'+i+'_Oggetto').contentDocument.body.innerHTML;
					}
					else
					{
						parent.opener.document.getElementById('R'+i+'_Oggetto').innerHTML  = cod + '\n' + parent.opener.document.getElementById('R'+i+'_Oggetto').innerHTML;
						parent.opener.document.getElementById('R'+i+'_Oggetto').contentWindow.document.body.innerHTML  =  cod + '\n' + parent.opener.document.getElementById('FRM_R'+i+'_Oggetto').contentWindow.document.body.innerHTML  ;
					}
				}
				catch(e) 
				{
				}
				
				
			}
		}
		if((getObj('DOCUMENT').value)=='DETTAGLI.ADDFROM.view_attributi_template')
		{
			//-- invoca sulla pagina chiamante l'aggiunta dell'attributo
			for(i=0;i <= parent.opener.DETTAGLIGrid_NumRow; i++ )
			{
			try
			{
				if(parent.opener.document.getElementById('FRM_R'+i+'_Template').contentDocument) 
					{
						parent.opener.document.getElementById('R'+i+'_Template').innerHTML  = cod + '\n' + parent.opener.document.getElementById('R'+i+'_Template').innerHTML;
						parent.opener.document.getElementById('FRM_R'+i+'_Template').contentDocument.body.innerHTML  =  cod + '\n' + parent.opener.document.getElementById('FRM_R'+i+'_Template').contentDocument.body.innerHTML;
					}
				else
					{
						parent.opener.document.getElementById('R'+i+'_Template').innerHTML  = cod + '\n' + parent.opener.document.getElementById('R'+i+'_Template').innerHTML;
						parent.opener.document.getElementById('FRM_R'+i+'_Template').contentWindow.document.body.innerHTML  =  cod + '\n' + parent.opener.document.getElementById('FRM_R'+i+'_Template').contentWindow.document.body.innerHTML  ;
					}
			}
				catch(e) 
				{
				}
				
			}
		}
		//parent.opener.SaveDoc();
		parent.close();
	}


	function MODIFICA_TEMPLATE(objGrid , Row , c)
	{
		
		var idRow;
		var parametri;
		var altro;
		var cod;
		var nq;
		var idRow;
		var vet;
		var documento;
		var docfrom;
		var only_doc;
		var nq;
		var w;
		var h;
		var Left;
		var Top;
		
		try 
		{
			idRow = getObj( 'R' + Row + '_id').value;
		}
		catch(e){}
		
		if(idRow == undefined)
			idRow = getObj( 'R' + Row + '_id')[0].value;
		
		parametri='MAIL_TEMPLATE#VIEWER#1024,768###'
				
		vet = parametri.split( '#' );
		documento = vet[0];
		docfrom = vet[1];
		
		if( idRow == '' )
		{
			DMessageBox( '../ctl_library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
			return;
		}

		w = screen.availWidth * 0.9;
		h = screen.availHeight  * 0.9;
		Left= (screen.availWidth - w) / 2;
		Top= (screen.availHeight - h ) / 2;
		
		if( vet.length < 3  )
		{
		}
		else    
		{
			var d;
			d = vet[2].split( ',' );
			w = d[0];
			h = d[1];
			Left = (screen.availWidth-w)/2;
			Top  = (screen.availHeight-h)/2;
			
			if( vet.length > 3 )
			{
				altro = vet[3];
			}
		}

		if ( isSingleWin() == true ) 
			ExecFunctionCenterPath( 'ctl_library/document/document.asp?JScript=' + documento + '&DOCUMENT=' + documento + '&MODE=CREATEFROM&PARAM=' + docfrom + ',' + idRow )
		else
			ExecFunction(  '../ctl_library/document/document.asp?JScript=' + documento + '&DOCUMENT=' + documento + '&MODE=CREATEFROM&PARAM=' + docfrom + ',' + idRow , documento + '_DOC_createfrom' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
		
	}