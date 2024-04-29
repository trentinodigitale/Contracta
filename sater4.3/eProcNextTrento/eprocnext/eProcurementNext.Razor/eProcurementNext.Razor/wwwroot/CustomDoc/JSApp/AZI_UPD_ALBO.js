
function QUALIFICA_OnLoad()
{
}
/*    
    //se il documento è modificabile 
    try{
	var v = getObj( 'ClasseIscriz' ).value;
	
	//trasformo la forma tecnica
	getObj( 'ClasseIscriz' ).value= ReplaceExtended(v,'###','#');
	v=getObj( 'ClasseIscriz' ).value;
	

	//trasformo la forma visuale
	var v1 = getObj( 'ClasseIscriz_edit' ).value;
	getObj( 'ClasseIscriz_edit' ).value= ReplaceExtended(v1,';','#');
	v1=getObj( 'ClasseIscriz_edit' ).value;	
	
	

	//costruisco la combo
	sCombo='<select name="ClasseIscriz_edit" id="ClasseIscriz_edit">';
	if (v != '') {

		ArrayIdent = v.split('#');
		ArrayDesc  = v1.split('#');

		for (iLoop=0; iLoop < ArrayDesc.length; iLoop++)
		{	
			
		   sOption= '<option value="' + ArrayIdent[iLoop+1] + '">' + ArrayDesc[iLoop] + '</option>' ;
		   sCombo = sCombo + sOption ;
			
			
		}
	}else{

		//combo vuota con elemento fittizio seleziona classe di iscrizione
		sOption= '<option value="">Seleziona Elenco Classi di Iscrizione</option>' ;
		sCombo = sCombo + sOption ;

	}	
	
	//aggiungo il campo nascosto con le desc
	sCombo=sCombo + '<input type=hidden id=ClasseIscriz_desc name=ClasseIscriz_desc value=' + v1 + '>';

	getObj( 'ClasseIscriz_edit' ).outerHTML=sCombo;

	//imposto chiamata sul bottone ClasseIscriz_button
	getObj( 'ClasseIscriz_button' ).onclick= CallAttributo ;
    }
    catch(e){
	   	
	   
            v1 = getObj( 'Cell_ClasseIscriz' ).innerText; 
	   
	    ArrayDesc  = v1.split(';');
	    sCombo='<select name="ClasseIscriz_edit" id="ClasseIscriz_edit">';	
	    for (iLoop=0; iLoop < ArrayDesc.length; iLoop++)
	    {	
			
		   sOption= '<option value=>' + ArrayDesc[iLoop] + '</option>' ;
		   sCombo = sCombo + sOption ;
			
			
	    }
	
	    getObj( 'Cell_ClasseIscriz' ).innerHTML=sCombo;
    }

}

function CallAttributo(){
	callGerarchia('1','Elenco+Classi+di+Iscrizione','','FORMDOCUMENT','ClasseIscriz_edit','314','../../afladmin/NewArea.asp','FORMDOCUMENT','ClasseIscriz','ClasseIscriz_desc','','','');
}


function callGerarchia(IDMP,StrDescGerarchia,GerarchieDinamiche,NomeFormCampi,nomecombo,idTipoGerarchia,pathGerarchia,RifFormDestHidden,NomeHiddenIdent,NomeHiddenDesc,nMaxElementi,bIsObligatory,strNomeFrameCombo,lIdAzi,OptionalConfirmScript,dztNomeAttrib)
{
                var sChiave
                               
                const_width=600;
                const_height=500;
                sinistra=(screen.width-const_width)/2;
                alto=(screen.height-const_height)/2;
                               
                var sChiave
                if (idTipoGerarchia=='21')
                               sChiave=lIdAzi;
                else
                               sChiave='0';
                NomeFormCampi=escape(NomeFormCampi);
                nomecombo=escape(nomecombo);
                RifFormDestHidden=escape(RifFormDestHidden);
                NomeHiddenIdent=escape(NomeHiddenIdent);
                NomeHiddenDesc=escape(NomeHiddenDesc);
                window.open(pathGerarchia+'?dztNomeAttrib='+dztNomeAttrib+'&RifActionScript='+OptionalConfirmScript+'&strNomeFrameCombo='+strNomeFrameCombo+'&bIsObligatory='+bIsObligatory+'&nMaxElementi='+nMaxElementi+'&NomeHiddenIdent='+NomeHiddenIdent+'&StrDescGerarchia='+StrDescGerarchia+'&NomeHiddenDesc='+NomeHiddenDesc+'&RifFormDestHidden='+RifFormDestHidden+'&GerarchieDinamiche='+GerarchieDinamiche+'&NomeFormCampi='+NomeFormCampi+'&nomecombo='+nomecombo+'&IDMP='+IDMP+'&sChiave='+sChiave+'&idTipoGerarchia='+idTipoGerarchia,'','toolbar=no,location=no,directories=no,status=<%=CONST_STATUS%>,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
                return;
}

function AggiornaComboGerarchie(nomeCombo,nomeIdent,nomeDesc,nomeForm,rifCampiHidden,strDescAtt)
{
                
                var iLoop;
                var ArrayIdent=new Array()
                var ArrayDesc=new Array()
		
		
                ComboGerarchia1=eval("document."+nomeForm+"."+nomeCombo);
                campohiddenIdent=eval("document."+nomeForm+"."+nomeIdent);
                campohiddenDesc=eval("document."+nomeForm+"."+nomeDesc);
                //aggiorno i campi hidden delle descrizioni e dei codici da nascosto
                sopraId=eval(rifCampiHidden+"."+nomeIdent);
                sopraDesc=eval(rifCampiHidden+"."+nomeDesc);
                campohiddenIdent.value=sopraId.value;
                campohiddenDesc.value=sopraDesc.value;
                if (campohiddenIdent!=null)
                {
                               if (campohiddenIdent.value!='')
                               {
                                               ArrayIdent=campohiddenIdent.value.split('#');
                                               ArrayDesc=campohiddenDesc.value.split('#');
                                               ComboGerarchia1.length=0;
                                               for (iLoop=0;iLoop<ArrayIdent.length-1;iLoop++)
                                               {
                                                  var aggiunto=new Option('a');
                                                  aggiunto.text=ArrayDesc[iLoop];
                                                  aggiunto.value=ArrayIdent[iLoop];
                                                  ComboGerarchia1.options[ComboGerarchia1.length]=aggiunto;
                                               }
                                              
                               }else{
                               
                                  ComboGerarchia1.length=0;
                                  var aggiunto=new Option('a');
                                  aggiunto.text = strDescAtt;
                                  aggiunto.value="";
                                  ComboGerarchia1.options[0]=aggiunto;
                               }
                               ComboGerarchia1.focus();
                }
                
                               
}
*/

function MyExecDocProcess(param){
	/*v=getObj( 'ClasseIscriz' ).value;
	v=ReplaceExtended(v,'#',';');
	v1=ReplaceExtended(v,';','###');
	
	if (v1.charAt(0)!= '#') 
		v1='###' + v1;
	getObj( 'ClasseIscriz' ).value=v1;*/
	
	ExecDocProcess(param);
}
