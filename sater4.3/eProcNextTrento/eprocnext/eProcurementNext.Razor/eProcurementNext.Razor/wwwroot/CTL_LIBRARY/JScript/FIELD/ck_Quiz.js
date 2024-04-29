function Open_Quiz( path , objName , format , Description, TipoGiudizioTecnico, Name_Field_Attributo , PunteggioMax )
{
	
	if ( PunteggioMax == undefined ) 
	{
		PunteggioMax = '1';
		
	}
	
	if ( PunteggioMax == 0 ) 
	{
		alert( CNV ('../../' , 'Inserire un punteggio per il criterio' ));
		return;
	}
	
  
  //recupero valore tecnico
  var strValue = getObj(objName).value;
  
  var TempDescription;
  try{
    TempDescription = GetDescriptionforQuiz(objName);
  }catch(e){
    TempDescription = '';
  }
  
  
  if ( TempDescription != '')
    Description = TempDescription;
  
  
  if ( Description == ''){
    alert( CNV ('../../' , 'Inserire una descrizione univoca per il criterio' ));
    return;
  }
  
  
  //controllo che attributo selezionato
  var strDescAttributo ='';
  try{
	  if ( format == 'C'){
		if ( getObjValue(Name_Field_Attributo) == '' ){
			alert( CNV ('../../' , 'Selezionare attributo per il criterio' ));
			return;
		}
		
		strDescAttributo = getObj(Name_Field_Attributo).options[getObj(Name_Field_Attributo).selectedIndex].text ;	
		
	  }else{
		
		try{	
			strDescAttributo = getObj('val_' + Name_Field_Attributo).innerHTML ;		 
		}catch(e){
			strDescAttributo = getObj(Name_Field_Attributo).value ;
		}
		
		
		
	  }
  }catch(e){}
  
		
  var TipoAttributo;
  TipoAttributo='';
  
	try
	{
		var res = objName.split('_');
		if ( res.length == 2 )
		{
			TipoAttributo=getObj( res[0] + '_AttributoCriterio').value;
		}
		if ( res.length == 3 )
		{
			TipoAttributo=getObj( res[0] +'_' + res[1] + '_AttributoCriterio').value;
		}
		
		
	}catch(e){TipoAttributo = '';}  
  
  

	if (typeof isFaseII !== 'undefined' && isFaseII) {

		closeDrawer();
		openDrawer(`<div class="iframeRightAreaContain">
						<iframe
							class="iframeRightArea"
							name='Open_Quiz'>
						</iframe>
					</div>`,
			false, "", "", false, true, true);
			var QuizForm = getNewSubmitForm();

			createNewFormElement(QuizForm, "Field", objName);
			createNewFormElement(QuizForm, "Format", format);
			createNewFormElement(QuizForm, "Value", strValue);
			createNewFormElement(QuizForm, "Description", Description);
			createNewFormElement(QuizForm, "TempTipoGiudizioTecnico", TipoGiudizioTecnico);
			createNewFormElement(QuizForm, "TipoAttributo", TipoAttributo);
			createNewFormElement(QuizForm, "DescrizioneAttributoCriterio", strDescAttributo);
			createNewFormElement(QuizForm, "PunteggioMax", PunteggioMax);

			QuizForm.action = path + '../ctl_library/Functions/FIELD/Quiz.asp';
			QuizForm.target = 'Open_Quiz';
			QuizForm.submit();
		return;
	}

  param = '#Open_Quiz#600,400#,menubar=yes';
  ExecFunctionCenter( param ) ;
  

  var QuizForm = getNewSubmitForm();
  
  createNewFormElement(QuizForm, "Field", objName );
  createNewFormElement(QuizForm, "Format", format );
  createNewFormElement(QuizForm, "Value", strValue );
  createNewFormElement(QuizForm, "Description", Description );
  createNewFormElement(QuizForm, "TempTipoGiudizioTecnico", TipoGiudizioTecnico );
  createNewFormElement(QuizForm, "TipoAttributo", TipoAttributo );
  createNewFormElement(QuizForm, "DescrizioneAttributoCriterio", strDescAttributo );
  createNewFormElement(QuizForm, "PunteggioMax", PunteggioMax );
  
  QuizForm.action= path + '../ctl_library/Functions/FIELD/Quiz.asp' ;
  QuizForm.target='Open_Quiz';
  QuizForm.submit();
}


function getNewSubmitForm(){
 var submitForm = document.createElement("FORM");
 document.body.appendChild(submitForm);
 submitForm.method = "POST";
 return submitForm;
}

//helper function to add elements to the form
function createNewFormElement(inputForm, elementName, elementValue){
 
 var newElement = document.createElement("input");
 
 newElement.type = 'hidden' ;
 newElement.name = elementName ;
 newElement.name = elementName ;
 newElement.value = elementValue;
 
 //var newElement = document.createElement("<input name='"+elementName+"' type='hidden'>");
 //alert (newElement);
 inputForm.appendChild(newElement);
 
 return newElement;
}

//Aggiunge un criterio di valutazione
function ADD_CriterioQuiz(){

  document.FormQuiz.MODE.value = 'ADD';
	document.FormQuiz.submit();

}


//Elimina un criterio di valutazione
function DEL_CriterioQuiz( Grid , row , col ){

  document.FormQuiz.MODE.value = 'DEL';
  document.FormQuiz.IndRowDelete.value = row;
  document.FormQuiz.submit();


}

function UpdateHiddenQuiz( objNameSource , objNameDest ){
  
  var strValueSource = getObj(objNameSource).value;
  var strValueDest = getObj(objNameDest).value;
  var ainfo = strValueDest.split('#=#');
  
  
  //se criterio range controllo che il valore inserito sia compreso nel range
  if ( ainfo[1] == 'range' ){
	
	var aInfoRange = ainfo[2].split('#~#');
	var len = aInfoRange.length;
	var LimiteInf  = aInfoRange[1];
	var LimiteSup = aInfoRange[len-2];
	var bCheck = true;
	
	if ( LimiteInf != '' && LimiteSup != '' ){
		if ( Number(strValueSource) < Number(LimiteInf) || Number(strValueSource) >= Number(LimiteSup) )
			bCheck = false;
	}
	
	if ( LimiteInf == '' && LimiteSup != '' ){
		if ( Number(strValueSource) >= Number(LimiteSup) )
			bCheck = false;
	}	
	
	if ( LimiteInf != '' && LimiteSup == '' ){
		if ( Number(strValueSource) < Number(LimiteInf) )
			bCheck = false;
	}
		
	
	if ( ! bCheck ){
		strValueSource='';
		getObj(objNameSource).value = ''
		getObj('Vis_' + objNameSource).value='';
		getObj('Vis_' + objNameSource).focus();
		alert( CNV ('../../' , 'valore non compreso nel range del criterio.' ));
	}
		
  }
  
  getObj(objNameDest).value = strValueSource + '#=#' + ainfo[1] + '#=#' + ainfo[2];
  
  
}