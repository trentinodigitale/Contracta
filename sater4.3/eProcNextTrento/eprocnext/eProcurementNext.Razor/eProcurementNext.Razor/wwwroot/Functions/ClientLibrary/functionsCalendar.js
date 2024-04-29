var DAYS_OF_WEEK = 7;    // numero di giorni della settimana
var DAYS_OF_MONTH = 31;    //numero di giorni del mese

var day_of_week = new Array('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
var month_of_year = new Array('January','February','March','April','May','June','July','August','September','October','November','December');

// variabili per la formattazione ed inizializzazione delle stesse

var const_BORDER
var const_BGCOLOR
var const_CELLPADDING
var const_BORDERCOLOR

const_BORDER=0
const_BGCOLOR='cb1d15'
const_CELLPADDING=0
const_BORDERCOLOR='fff'

var TR_start = '<TR>';
var TR_end = '</TR>';
var highlight_start = '<TD WIDTH="10"><TABLE CELLSPACING='+const_CELLPADDING+' BORDER='+const_BORDER+' BGCOLOR='+const_BGCOLOR+' BORDERCOLOR='+const_BORDERCOLOR+'><TR><TD WIDTH=20><B><CENTER>';
var highlight_end   = '</CENTER></TD></TR></TABLE></B>';
var TD_start = '<TD WIDTH="10"><CENTER>';
var TD_end = '</CENTER></TD>';


function BuildCalendar(DataOdierna) {


	var weekday = DataOdierna.getDay();    // giorno del mese selezionato
	var Calendar = new Date();
	Calendar = DataOdierna
	Calendar.setDate(1);   
	
	var tmpVirtualDir;
	tmpVirtualDir = '..';

	/*
	if ( isSingleWin() )
		tmpVirtualDir = urlPortale;
	*/
	
	/*Costruzione dello stringone dei comandi */

	s_command =  '<TABLE  border="0" CELLSPACING=0 CELLPADDING=0 BORDERCOLOR=#fff><TR><TD>';
	s_command += '<TABLE CELLSPACING=0  border="0" CELLPADDING=2>' + TR_start;
	s_command += '<TD COLSPAN="' + 1 + '" BGCOLOR="#EFEFEF" ALIGN="LEFT" class="FontLegalPub">';
	s_command += '<label onclick="javascript:updateMonth(-12)"><img border=0 src="' + tmpVirtualDir + '/images/General/FirstPage.gif"></label></td>';
	s_command += '<TD COLSPAN="' + 5 + '" BGCOLOR="#EFEFEF" NOWRAP="TRUE"  ALIGN="CENTER" class="FontTitleCover">';
	s_command += ' <select id="IdMonth" name="monthCombo"  class="FontLegalPub" size="1" onChange="Javascript:updateMonth(this.selectedIndex)"></select> <input type="text" size="4" maxlength="4" class="FontLegalPub" name="textYear" value="'+n_year+'"  onBlur="Javascript:checkCorrectYear(\'document.forms[0].textYear\',\'\',\'\');updateYear(this.value);"> </TD>';
	s_command += '<TD COLSPAN="' + 1 + '" BGCOLOR="#EFEFEF" ALIGN="RIGHT" class="FontLegalPub">';
	s_command += '<label onclick="javascript:updateMonth(12)"><img border=0 src="' + tmpVirtualDir + '/images/General/LastPage.gif" ></label> </td>' + TR_end;
	s_command += TR_start;

	cal = s_command;
	// LOOPS per ogni giorno della settimana 


	for(index=0; index < DAYS_OF_WEEK; index++)
	{

		// in bold il giorno della settimana selezionato
		if(weekday == index)
			cal += '<TD WIDTH="30" class="FontTitleCover">' +  day_of_week[index]  + TD_end;

		// PRINTS DAY
		else
			cal += '<TD WIDTH="30" class="FontLegalPub">'  + day_of_week[index] + TD_end;
	}

	cal += TD_end + TR_end;
	cal += TR_start;

	//costruzione del calendario
	for(index=0; index < Calendar.getDay(); index++)
		cal += TD_start + '  ' + TD_end;

		// LOOPS per ogni giorno nel calendario
		for(index=0; index < DAYS_OF_MONTH; index++)
		{
			if( Calendar.getDate() > index )
			{
				// calcolo del prossimo giorno da stampare
				week_day =Calendar.getDay();

				// inizio nuova riga per il primo giorno della settimana
				if(week_day == 0)
					cal += TR_start;

				if(week_day != DAYS_OF_WEEK)
				{

					var day  = Calendar.getDate();

					// HIGHLIGHT il giorno della settimana selezionato
					if( n_day==Calendar.getDate() )
						//cal += highlight_start + day + highlight_end + TD_end;
						cal += highlight_start + '<label class="FontTitleCover">' + day + '</label>' + highlight_end;

					else
						cal += TD_start + '<label class="FontLinkLabelCover" onclick="javascript:updateDay('+day+')">'+ day +'</label>' + TD_end;
			  }

			  // fine della riga per l'ultimo giorno della settimana
			  if(week_day == DAYS_OF_WEEK)
				cal += TR_end;
		  }

		  // incremento fino alla fine del mese
		  Calendar.setDate(Calendar.getDate()+1);

	}

	if (SuffLing.toUpperCase() == 'UK' )
		s_today=addZero(today.getMonth()+1)+'/'+addZero(today.getDate())+'/'+today.getFullYear()
	else
		s_today=addZero(today.getDate())+'/'+addZero(Number(today.getMonth())+1)+'/'+today.getFullYear()
	s_todayValue= today.getFullYear()+'-'+addZero(Number(today.getMonth())+1)+'-'+addZero(today.getDate())
			
	s_tempCoda='<br><center><span class="FontLinkLabelCover"><label onclick="javascript:updateDate(\''+s_todayValue+'\')"  name="dataLNK">'+s_today+'</label></span>	</center>'

	s_button='<br><INPUT type="button" value="'+s_ripulisci+'"  name="closeBTN" onclick="javascript:resetData(\'\');window.close();" title="'+s_ripulisci+'" class="fontCommand">&nbsp;<INPUT type="button" value="'+s_annulla+'"  name="annullaBTN" onclick="javascript:window.close();" title="'+s_annulla+'" class="fontCommand">&nbsp;<INPUT type="button" value="'+s_conferma+'"  name="closeBTN" onclick="javascript:closeCalendar(\'\');" title="'+s_conferma+'" class="fontCommand">';
	cal += '</TD></TR></TABLE></TABLE>'+s_tempCoda+s_button;
	//  visualizzo la stringa ricavata cal
	
	if (document.all != null)
		document.all("DivCalendar").innerHTML =	cal;
	else
		document.getElementById("DivCalendar").innerHTML =	cal;
	
	updateCombo(n_month);


}


//aggiorna il calendario con la data modificata 
function updateDay(iDay)
{
	updatePage(n_year, n_month, iDay)


}


function updateYear(iYear)
{
	if (iYear!="") {
		//controllo che sia numerico
		updatePage(iYear, n_month, n_day)
	}

}


function updateMonth(iMonth)
{
	var DateToDay = new Date();
	switch(iMonth) {
	
		case  12:
					n_year=parseInt(n_year,10)+1
					break;
		case -12:
					n_year=parseInt(n_year,10)-1
					break;
		default :
			n_month=iMonth;
	}

	updatePage(n_year, n_month, n_day)
}

//aggiorno il campo text anno
function updateTextYear(iYear) {
	document.calendario.textYear.value=iYear;
}

//costruzione della combo mese
function updateCombo(n_month) {


	if (document.all != null)
		objCombo=document.all("IdMonth");
	else
		objCombo=document.getElementById("IdMonth");

	for (iLoop=0;iLoop<=month_of_year.length-1;iLoop++)	{
		var aggiunto=new Option('a');
		aggiunto.text=month_of_year[iLoop];
		aggiunto.value=iLoop;
		lengthCombo=objCombo.length
		objCombo.options[lengthCombo]=aggiunto;
	}
	objCombo.options[n_month].selected=true;
}



lastMonth = new Array(31,28,31,30,31,30,31,31,30,31,30,31)

function BuildDataStringVis(iYear, iMonth, iToday, iLingua) {
	var data1 = new Date();
	
	
	if((iYear%4)==0)
		lastMonth[1]=29;
	else
		lastMonth[1]=28;
	if (iToday > lastMonth[iMonth-1])
		iToday=lastMonth[iMonth-1];
	
	if (iLingua.toUpperCase()=='UK')
		return addZero(iMonth)+"/"+addZero(iToday)+"/"+addZero(iYear);
	else
		return addZero(iToday)+"/"+addZero(iMonth)+"/"+addZero(iYear);
}

function BuildDataString(iYear, iMonth_var, iToday) {

	var data1 = new Date();
	
	if((iYear%4)==0)
		lastMonth[1]=29;
	else
		lastMonth[1]=28;
	if (iToday > lastMonth[iMonth_var-1])
		iToday=lastMonth[iMonth_var-1];
	
	return addZero(iYear)+"-"+addZero(iMonth_var)+"-"+addZero(iToday);

}




//aggiorna il calendario con la data modificata 
function updateDate(sDate)
{

	document.calendario.data.value=sDate
	arrayData=sDate.split("-")
	
	//Se ci sono state modifiche, allora setta l'oggetto hiden che rileva le modifiche.
	setModifyField(strModifyObject, eval(campoVis).value, BuildDataStringVis(arrayData[0],arrayData[1],arrayData[2],SuffLing))
	
	eval(campoHidden).value=BuildDataString(arrayData[0],arrayData[1],arrayData[2])
	eval(campoVis).value=BuildDataStringVis(arrayData[0],arrayData[1],arrayData[2],SuffLing)
	
	this.close();
}


//Questa funzione aggiorna la data settata nel calendario
//@bparm |strCalendarType|string|tipo di calendario| tipo di calendario: {"1" o ""-->classico; "2"-->settimanale, "1"-->mensile}
function closeCalendar(strCalendarType) {
	var strNewVisValue; //nuovo valore da visualizzare
	var strNewMemoValue; //valore della nuova data da memorizzare nel campo nascosto
	var vSplitArrayDate;//array di appoggio
	var strAppoggio  = '';
	var objLength;//numero di elementi
	var lElCount; // contataore
	var objRef1;//reference generico 1
	var objRef2;//reference generico 2
	var objDate = new Date();

	switch (strCalendarType)
	  {
			case '': case '1':
					//Caso classico
					//Se ci sono state modifiche, allora setta l'oggetto hidden che rileva le modifiche.
					setModifyField(strModifyObject, eval(campoVis).value, BuildDataStringVis(n_year,n_month+1,n_day,SuffLing));
					strOldValue=eval(campoHidden).value;
					arrayDataTimeOld=strOldValue.split('T');
					if (arrayDataTimeOld.length==2){ 
						strTimeValue=arrayDataTimeOld[1];
						eval(campoHidden).value=BuildDataString(n_year,n_month+1,n_day)+'T'+strTimeValue;
					}else
						eval(campoHidden).value=BuildDataString(n_year,n_month+1,n_day);
						
					eval(campoVis).value=BuildDataStringVis(n_year,n_month+1,n_day,SuffLing);
					
					//eval(campoVis + '.onchange();');
					
					objVis=eval(campoVis);
					objVis.focus();
					objVis.onblur();
					
					break;
			case '2':
					//Settimanale
					objRef1 = document.forms[0].textWeek; //settimana
					objRef2 = document.forms[0].textYear; //year
					strNewVisValue = '';
					strNewMemoValue = '';
					if(typeof(objRef1) == 'undefined' || typeof(objRef2) == 'undefined')
					  {
						return;
					  }
					
					//controlla che l'anno sia corretto
					if (objRef2.value == '')
					  {
						objRef2.value = objDate.getYear();
					  }
					//controlla che il numero di settimana sia corretto
					if (objRef1.value == '')
					  {
						objRef1.value = 1;
					  }
					//nuovo valore da visualizzare
					strNewVisValue  = objRef1.value + 'ª ' + strWeekWordTranslate + ' ' + objRef2.value;
					strNewMemoValue = objRef1.value + '#' + objRef2.value + '#' + strCalendarType;
					
					//Se ci sono state modifiche, allora setta l'oggetto hidden che rileva le modifiche.
					setModifyField(strModifyObject, eval(campoVis).value, strNewVisValue);
					eval(campoHidden).value=strNewMemoValue;
					eval(campoVis).value=strNewVisValue;
					
					break;
			case '3':
					//Mensile
					//Prelevo il mese selezionato
					
					objRef1 = document.forms[0].radMonth; //mese
					objRef2 = document.forms[0].textYear; //year
					strNewVisValue = '';
					strNewMemoValue = '';
					if(typeof(objRef1) == 'undefined' || typeof(objRef2) == 'undefined')
					  {
						return;
					  }
					
					//controlla che l'anno sia corretto
					if (objRef2.value == '')
					  {
						objRef2.value = objDate.getYear();
					  }
					//objLength = objRef1.length;
					
					//prelevo il mese selezionato
					//for (lElCount=0;lElCount<objLength;lElCount++)
					//  {
					//	   if (objRef1[lElCount].checked == true)
					//	     {
							   //trovato
					//		   strNewVisValue = lElCount; //catturo l'inidice
					//		   break;
					//	      }
					//   }
				
					strNewVisValue = objRef1.selectedIndex;
					if (strNewVisValue.toString() != '')
					  {
						
						strNewVisValue = objRef1[strNewVisValue].value;
						vSplitArrayDate = strNewVisValue.split('#');
						strNewVisValue = vSplitArrayDate[1] + ' ' + objRef2.value; //nuovo valore da visualizzare
						strNewMemoValue = vSplitArrayDate[0] + '#' + objRef2.value + '#' + strCalendarType;;
					  }
					
				
					//Se ci sono state modifiche, allora setta l'oggetto hidden che rileva le modifiche.
					setModifyField(strModifyObject, eval(campoVis).value, strNewVisValue);
					eval(campoHidden).value=strNewMemoValue;
					eval(campoVis).value=strNewVisValue;
					break;	  
	  }//end switch
	  
	  //se sul campo sotto è impostato un evento onchange viene richiamato
    if  ( eval(campoVis).onchange != undefined ){ 
	     //alert(eval(campoVis).onchange);
	     opener.setInterval(eval(campoVis).onchange(), 1000 );
	  }
	  //Se arriva fin qui vuol dire che p andata tutto per il meglio
	  window.close();
}


//Questa funzione provvede a settareil campo che rileva le modifiche ove quest'ultimo
//sia presente.
//Il valore sarà pari a "1" --> c'è stata una modifica
//						"0" --> non c'è stata modifica
// refModifyObject | reference | reference al campo hidden che rileva le modifiche
// strOldDate | string | vecchia data
// strNewDate | string | nuova data
function setModifyField(refModifyObject, strOldDate, strNewDate)
  {
	var campoHiddenModify; //reference al campo hidden che rileva le modifiche
	//Se ci sono state modifiche, allora setta l'oggetto hiden che rileva le modifiche.
	if (refModifyObject != '')
	  {
		campoHiddenModify = eval('parent.opener.'+refModifyObject);
		//se il campo realmente esiste, allora continua
		if (typeof(campoHiddenModify)=='object')
		  {
			//controllo che le modifiche siano intervenute realmente.
			if (strOldDate != strNewDate)
				{
					campoHiddenModify.value = '1';
				}
		  }
	  }
  
  }


function updatePage(n_year_var, n_month_var, n_day_var) {
	var DateToDay = new Date();
	n_day=Number(n_day_var)
	n_month=Number(n_month_var)
	n_year=Number(n_year_var)
	DateToDay.setDate(n_day);    // aggiorna il calendario  (per una data facciamo vedere tutti i giorni del mese)
	DateToDay.setMonth(n_month);    // mese del calendario in visualizzazione
	DateToDay.setFullYear(n_year);    // anno del calendario in visualizzazione
	BuildCalendar(DateToDay);
	updateTextYear(n_year);

}



//la fuzione aggiunge uno zero alla stringa : una stringa del tipo 6 diventa 06 
function addZero(intParam) {
	if (Number(intParam) <= 9)
		return '0'+Number(intParam)
	else
		return intParam
}

//@bparm |strCalendarType|string|tipo di calendario| tipo di calendario: {"1" o ""-->classico; "2"-->settimanale, "3"-->mensile}
function resetData(strCalendarType) 
	{
		
		strOldValue=eval(campoHidden).value;
		arrayDataTimeOld=strOldValue.split('T');
		if (arrayDataTimeOld.length==2){ 
			strTimeValue=arrayDataTimeOld[1];
			eval(campoHidden).value="";//'T'+strTimeValue;  COMMENTATO DA FRANCESCO IN QUANTO IL RIPULISCI PER I CAMPI SENZA ORARIO PORTAVA T:00:00:00 e diventava 1900-01-01 al save
		}else
			eval(campoHidden).value="";
			
		eval(campoVis).value="";
		switch (strCalendarType)
			{
				case '': case'1':
						//Caso classico												
						setModifyField(strModifyObject, eval(campoVis).value, BuildDataStringVis(0,0,0,SuffLing));
						break;
				case '2','3':
						//settimanale o mensile
						setModifyField(strModifyObject, eval(campoVis).value, '');
						break;
				
			}//end switch
	}


//Questa funzione provvede ad incrementare il valore in una text effettuando opportuni controlli.
//@bparm |strTypeData|string|tipo di dato {'year','week'} 
//@bparm |strDirection|direzione {'0'-->decremento, '1'-->incremento}
//@bparm |objWeekControlRef| string | reference alla text della settimana
//@bparm |objYearControlRef| string | reference alla text dell'anno
//@bparm |strCalendarType|string|tipo di calendario {'' o '1','2','3'}
function setTextValue(strTypeData,strDirection,objWeekControlRef,objYearControlRef,strCalendarType)
	{
	
		//Creo i reference alle text
		switch (strCalendarType)
				{
					case '2':case '3':case '':case '1': //settimanale o mensile o classico
							//Se l'oggetto non esiste esci
							if (objYearControlRef == '')
							  {
								return;
							  }
							
							objYearControlRef = eval(objYearControlRef);
							//se i reference noin esistono esci
							if (typeof(objYearControlRef) == 'undefined')
							  {
								return;
							  }
							//In particolare se è di tipo settimanale, costruisci il relativo reference
							if (strCalendarType == '2')
							   {
									//Se l'oggetto non esiste esci
									if (objWeekControlRef == '')
									  {
										return;
									  }
									objWeekControlRef = eval(objWeekControlRef);
									if (typeof(objWeekControlRef) == 'undefined')
									  {
										return;
									  }
								}
							break;
							
				}//end switch
				
		
		var objDate = new Date();
		var strTextValue = '';
		
		switch (strTypeData)
			{
				case 'year':
					
					strTextValue = objYearControlRef.value;
					if (strTextValue == '' || IsNumber(strTextValue) == '0')
					  {
						objYearControlRef.value = objDate.getYear();
					  }
				
					//Se non vuoto e non negativo, allora incr. o decr.
					if(parseInt(objYearControlRef.value).toString().length < 4)
					  {
						objYearControlRef.value = objDate.getYear();
					  }
					
					if (strDirection == '0')
					  {
						objYearControlRef.value = (parseInt(objYearControlRef.value,10) - 1).toString();
					  }
					  else
					  {
						objYearControlRef.value = (parseInt(objYearControlRef.value,10) + 1).toString();
					  }
						
					break;
					
				case 'week':
					
					strTextValue = objWeekControlRef.value;
					if (strTextValue == '' || IsNumber(strTextValue) == '0')
					  {
						objWeekControlRef.value = 1;
					  }
					  
					//Se non vuoto, allora incr. o decr.
					if (strDirection == '0')
					  {
						//non potrà mai essere <=0
						if (parseInt(objWeekControlRef.value,10)>1)
						  {
							objWeekControlRef.value = (parseInt(objWeekControlRef.value,10) - 1).toString();
						  }
					  }
					  else
					  {
						objWeekControlRef.value = (parseInt(objWeekControlRef.value,10) + 1).toString();
					  }
					
					break;
		  
			}//end switch
		  
			//A seconda del tipo di calendario, controlliamo la correttezza della settimana in base
			//al fatto che l'anno sia bisestile o meno.
			switch (strCalendarType)
				{
					case '2':
						//se settimanale...
						//massimo numero di week
						lMaxWeekNumberInTheYear = IWeekNumberToYear(objYearControlRef.value);
						//controllo che non sia superato il massimo numero di settimane
						if(parseInt(objWeekControlRef.value,10) > lMaxWeekNumberInTheYear)
						 {
							objWeekControlRef.value = lMaxWeekNumberInTheYear;
						 }
						
						break;
				}//end switch
				
	}


//Questa funzione controlla la correttezza dell'anno
//@bparm |strYearRef| string | reference al texbox dell'anno
//@bparm |strWeekRef| string | reference al texbox della settimana
//@bparm |strCalendarType|string|tipo di calendario
function checkCorrectYear(strYearRef,strWeekRef,strCalendarType)
  {
	var objYear = eval(strYearRef);
	var TodayYear = new Date();
	
	if (typeof(objYear) == 'undefined')
	  {
		return ;
	  }
	
	switch (strCalendarType)
	  {
		case '': case '1': case '2': case'3':
			//Se l'anno non è presente viene settato quello attuale, altrimenti effettua opportuni controlli
			if (objYear.value !='')
			  {
				if (objYear.value.length<4 || IsNumber(objYear.value) == 0)
				  {
					objYear.value = TodayYear.getYear();
				  }
				else
				  {
					//La data potrà essere:0000, o 0002 per cui dev'essere corretta
					if (parseInt(objYear.value,10).toString().length<4)
					  {
						objYear.value = TodayYear.getYear();
					  }
				  }
			  }
			else
			  {
				objYear.value = TodayYear.getYear();
			  }	
			break;
				
	   }//end switch
	   
	  //Se il calendario è di tipo settimanale, correggere la settimana in rifewrimento
	  //alla bisestilità dell'anno appena aggiornato.
	  if (strCalendarType == '2' && strWeekRef != '')
	     {
			strWeekRef = eval(strWeekRef);
			if (typeof(strWeekRef) == 'undefined')
			  {
				return;
			  }
			
			//controllo che non sia superato il massimo numero di settimane
			var lMaxWeekNumberInTheYear = IWeekNumberToYear(objYear.value);
			if(parseInt(strWeekRef.value,10) > lMaxWeekNumberInTheYear)
			 {
				strWeekRef.value = lMaxWeekNumberInTheYear;
			 }
	     
	     }//end if
  }
	
//Questa funzione controlla la correttezza del numero della settimana
//@bparm |strWeekRef| string | reference al texbox della settimana
//@bparm |strYearRef| string | reference al texbox dell'anno
//@bparm |strCalendarType|string|tipo di calendario {'' o '1','3','2',}
function checkCorrectWeekNumber(strWeekRef,strYearRef,strCalendarType)
  {
	var objWeek = eval(strWeekRef);
	var objYear = eval(strYearRef);
	var lWeekDefaultValue = 1;//valore di default della settimana
	var lMaxWeekNumberInTheYear;//numero massimo di settimana per l'anno
	
	if (typeof(objWeek) == 'undefined' || typeof(objYear) == 'undefined')
	  {
		return ;
	  }
	
	//Ci assicuriamo che l'anno sia avvalorato
	checkCorrectYear(strYearRef,strCalendarType);
	//massimo numero di week
	lMaxWeekNumberInTheYear = IWeekNumberToYear(objYear.value);
	
	switch (strCalendarType)
	  {
		case '2':
			//settimanale
			if (objWeek.value !='')
			  {
				//E' numerico?
				if (IsNumber(objWeek.value) == 0)
				  {
					objWeek.value = lWeekDefaultValue;
				  }
				else
				  {
					//E' numerico
					if (parseInt(objWeek.value,10)<=0)
					  {
						objWeek.value = lWeekDefaultValue;
					  }
				  }
			  }
			else
			  {
				objWeek.value = lWeekDefaultValue;
			  }
			
			//controllo che non sia superato il massimo numero di settimane
		    if(parseInt(objWeek.value,10) > lMaxWeekNumberInTheYear)
		     {
				objWeek.value = lMaxWeekNumberInTheYear;
		     }
		  
		    break;
	   }//end switch
  
  }
	

//Questa funzione retistuisce il massimo numero di settimane per un determinato anno
//@bparm | strYear | string | anno in riferimento al quale calcolare la bisestilit
function IWeekNumberToYear(strYear)
  {
		var lResult  = 52;
		//Calcolo anno bisestile
		if ((parseInt(strYear,10)%20==0) || ((parseInt(strYear,10)%4==0) && (parseInt(strYear,10)%10!=0))) 
		{	
			lResult = 53;
		}
		return lResult;
  }
  