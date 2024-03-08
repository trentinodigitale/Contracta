/*
 * Created by Crative Core s.r.l. 
 * www.creativecore.it
 *
 */

var Forms = {
	
	init:function(){
		$$('form').addEvent('submit',function(ev){
			ev = new Event(ev);
			var valid = Forms.validateForm(this.id)
			if(!valid) ev.preventDefault();
			
			if($(this).hasClass('ajax') && valid){
				ev.preventDefault();
				
			} 
		});		
	},

	initForm:function(el){
		$(el).addEvent('submit',function(ev){
			ev = new Event(ev);
			if(!Forms.validateForm(this.id)) ev.preventDefault();
		});		
	},

 	isValidDate:function(dateStr, format){
		if (format == null) { format = "MDY"; }
   		format = format.toUpperCase();
   		if (format.length != 3) { format = "MDY"; }
   		if ( (format.indexOf("M") == -1) || (format.indexOf("D") == -1) || (format.indexOf("Y") == -1) ) { format = "MDY"; }
   		if (format.substring(0, 1) == "Y") { // If the year is first
      		var reg1 = /^\d{2}(\-|\/|\.)\d{1,2}\1\d{1,2}$/
      		var reg2 = /^\d{4}(\-|\/|\.)\d{1,2}\1\d{1,2}$/
   		}else if (format.substring(1, 2) == "Y") { // If the year is second
      		var reg1 = /^\d{1,2}(\-|\/|\.)\d{2}\1\d{1,2}$/
      		var reg2 = /^\d{1,2}(\-|\/|\.)\d{4}\1\d{1,2}$/
   		}else{ // The year must be third
      		var reg1 = /^\d{1,2}(\-|\/|\.)\d{1,2}\1\d{2}$/
      		var reg2 = /^\d{1,2}(\-|\/|\.)\d{1,2}\1\d{4}$/
   		}
   		// If it doesn't conform to the right format (with either a 2 digit year or 4 digit year), fail
   		if ( (reg1.test(dateStr) == false) && (reg2.test(dateStr) == false) ) { return false; }
   		var parts = dateStr.split(RegExp.$1); // Split into 3 parts based on what the divider was
   		// Check to see if the 3 parts end up making a valid date
   		if (format.substring(0, 1) == "M") { var mm = parts[0]; } else 
    	if (format.substring(1, 2) == "M") { var mm = parts[1]; } else { var mm = parts[2]; }
   		if (format.substring(0, 1) == "D") { var dd = parts[0]; } else 
    	if (format.substring(1, 2) == "D") { var dd = parts[1]; } else { var dd = parts[2]; }
   		if (format.substring(0, 1) == "Y") { var yy = parts[0]; } else 
    	if (format.substring(1, 2) == "Y") { var yy = parts[1]; } else { var yy = parts[2]; }
   		if (parseFloat(yy) <= 50) { yy = (parseFloat(yy) + 2000).toString(); }
   		if (parseFloat(yy) <= 99) { yy = (parseFloat(yy) + 1900).toString(); }
   		var dt = new Date(parseFloat(yy), parseFloat(mm)-1, parseFloat(dd), 0, 0, 0, 0);
   		if (parseFloat(dd) != dt.getDate()) { return false; }
   		if (parseFloat(mm)-1 != dt.getMonth()) { return false; }
   		return true;
	},

	isNumeric: function (value){
		objRegExp  =  /(^-?\d\d*\.\d*$)|(^-?\d\d*$)|(^-?\.\d\d*$)/;
		return objRegExp.test(value);
	},

	checkSelect: function(obj){
		if(obj.options[obj.selectedIndex].value == '0' || obj.options[obj.selectedIndex].value == '') return false;
		return true;
	},
	
	checkMail: function(obj){
		var filter  = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
		return filter.test(obj.value);
	},
	
	checkRadio: function(obj){
		var radios = document.getElementsByName(obj.name);
		var checked = false;
		for(var i =0; i<radios.length;i++){			
			var radio = $(radios[i]);
			if(radio.hasClass('req') && !radio.checked) return false;
			if(radio.checked) checked = true;
		}
		return checked;
	},
	
	checkSize: function (obj){
		var checked=false;
		var value='';
		value=obj.value;
		if (value.length == obj.getAttribute('MAXLENGTH'))
			checked=true;
		return checked; 
	},
	
	checkCF: function(cf)
	{
		var codiceStato = document.getElementById("idStato").value;
		var descStato = document.getElementById("stato").value;
	
		// Effettuo il controllo sul codice fiscale tradizionale solo se si è scelto l'italia
		// o ancora non si è scritto lo stato
		if ( descStato == '' || descStato.toUpperCase() == 'ITALIA' || descStato.toUpperCase() == 'ITALY' ) 
		{
			var validi, i, s, set1, set2, setpari, setdisp;
			if( cf == '' )  return '';
			cf = cf.toUpperCase();
			
			if( cf.length != 16 )
				return "La lunghezza del codice fiscale non e'\n"
			    +"corretta: il codice fiscale dovrebbe essere lungo\n"
			    +"esattamente 16 caratteri.\n";
			validi = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
			for( i = 0; i < 16; i++ ){
			    if( validi.indexOf( cf.charAt(i) ) == -1 )
			        return "Il codice fiscale contiene un carattere non valido `" +
			            cf.charAt(i) +
			            "'.\nI caratteri validi sono le lettere e le cifre.\n";
			}
			set1 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
			set2 = "ABCDEFGHIJABCDEFGHIJKLMNOPQRSTUVWXYZ"; 
			setpari = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
			setdisp = "BAKPLCQDREVOSFTGUHMINJWZYX";
			s = 0;
			for( i = 1; i <= 13; i += 2 )
			    s += setpari.indexOf( set2.charAt( set1.indexOf( cf.charAt(i) )));
			for( i = 0; i <= 14; i += 2 )
			    s += setdisp.indexOf( set2.charAt( set1.indexOf( cf.charAt(i) )));
			if( s%26 != cf.charCodeAt(15)-'A'.charCodeAt(0) )
			    return "Il codice fiscale non e' corretto:\n"+
			        "il codice di controllo non corrisponde.\n";
			return "";
		}
		else
		{
		
			// 1o controllo, se lo stato non è Italia è che piva e codFisc devono coincidere
			var txtPiva = document.getElementById("PartitaIva").value;
			
			if (txtPiva.toUpperCase() != cf.toUpperCase())
			{
				return 'Codice fiscale e partita iva differenti';
			}
			
			return "";
		}
	},
	
	checkPIVA_estesa: function(pi)
	{
		var codiceStato;
		var descStato;
		var codicefiscale;
		var errStr;
		
		//codiceStato = document.getElementsByName("idStato")[0].value;
		codiceStato = document.getElementById("idStato").value;
		descStato = document.getElementById("stato").value;
		
		//Se lo stato è italia facciamo il controllo classico
		if ( pi.substring(0,2).toUpperCase() == 'IT' ) 
		{
			/*Controllo che la partita iva inizi per IT
			if ( pi.substring(0,2).toUpperCase() != 'IT' )
			{
				return "La partita iva italiana deve iniziare per IT";
			}
			*/
			
			pi = pi.substring(2); //Ci tolgo la sigla dello stato
			
			return Forms.checkPIVA(pi);
		}
		else
		{
			// 1o controllo, se lo stato non è Italia è che piva e codFisc devono coincidere
			codicefiscale = document.getElementById("codicefiscale").value;
			
			if (codicefiscale.toUpperCase() != pi.toUpperCase())
			{
				return 'Codice fiscale e partita iva differenti';
			}
			
			var url_app = document.getElementById("URL_APP").value;
			var prefisso = pi.substring(0,2).toUpperCase();
						
			resp = checkPIVA_ext(url_app, prefisso , pi);
			
			var arr=resp.split("#");
			
			if ( arr[0] == '1' ) //Se è stato restituito il warning di controllo
			{
				//alert( arr[1] );
				return arr[1];				
			}
			else if ( arr[0] == '2' ) //Errore server
			{
				//alert(arr[1]);
				return '';				
			}
		}
		
		return '';
	},

	checkCF_base: function(cf)
	{
		var descStato = document.getElementById("stato").value;
		
		//Se lo stato è Italia effettuo il vecchio controllo di codicefiscale, altrimenti non faccio niente
		if ( descStato == '' || descStato.toUpperCase() == 'ITALIA' || descStato.toUpperCase() == 'ITALY' ) 
		{
			var validi, i, s, set1, set2, setpari, setdisp;
			if( cf == '' )  return '';
			cf = cf.toUpperCase();
			
			if( cf.length != 16 )
				return "La lunghezza del codice fiscale non e'\n"
			    +"corretta: il codice fiscale dovrebbe essere lungo\n"
			    +"esattamente 16 caratteri.\n";
			validi = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
			for( i = 0; i < 16; i++ ){
			    if( validi.indexOf( cf.charAt(i) ) == -1 )
			        return "Il codice fiscale contiene un carattere non valido `" +
			            cf.charAt(i) +
			            "'.\nI caratteri validi sono le lettere e le cifre.\n";
			}
			set1 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
			set2 = "ABCDEFGHIJABCDEFGHIJKLMNOPQRSTUVWXYZ";
			setpari = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
			setdisp = "BAKPLCQDREVOSFTGUHMINJWZYX";
			s = 0;
			for( i = 1; i <= 13; i += 2 )
			    s += setpari.indexOf( set2.charAt( set1.indexOf( cf.charAt(i) )));
			for( i = 0; i <= 14; i += 2 )
			    s += setdisp.indexOf( set2.charAt( set1.indexOf( cf.charAt(i) )));
			if( s%26 != cf.charCodeAt(15)-'A'.charCodeAt(0) )
			    return "Il codice fiscale non e' corretto:\n"+
			        "il codice di controllo non corrisponde.\n";
			return "";
			
		}
		else
		{
			return "";
		}
	},
	
	checkPIVA: function(pi){
	    
	    if( pi == '' )  return '';
	    if( pi.length != 11 )
	        return "La lunghezza della partita IVA non e'\n" +
	            "corretta: la partita IVA dovrebbe essere lunga\n" +
	            "esattamente 11 caratteri.\n";
	    validi = "0123456789";
	    for( i = 0; i < 11; i++ ){
	        if( validi.indexOf( pi.charAt(i) ) == -1 )
	            return "La partita IVA contiene un carattere non valido `" +
	                pi.charAt(i) + "'.\nI caratteri validi sono le cifre.\n";
	    }
	    s = 0;
	    for( i = 0; i <= 9; i += 2 )
	        s += pi.charCodeAt(i) - '0'.charCodeAt(0);
	    for( i = 1; i <= 9; i += 2 ){
	        c = 2*( pi.charCodeAt(i) - '0'.charCodeAt(0) );
	        if( c > 9 )  c = c - 9;
	        s += c;
	    }
	    if( ( 10 - s%10 )%10 != pi.charCodeAt(10) - '0'.charCodeAt(0) )
	        return "La partita IVA non e' valida:\n" +
	            "il codice di controllo non corrisponde.\n";
	    return '';
	},
	
	checkField:function(obj){
		var tag = obj.tagName.toLowerCase();
		if(obj.disabled) return true;		
		if(tag == 'fieldset') return true;
		else if(tag == 'select' && obj.hasClass('required')) return Forms.checkSelect(obj);
		var value  = obj.value.trim();		
		
		if(/radio|checkbox/.test(obj.type)){
			return Forms.checkRadio(obj);
		}else if(!(/button|reset|submit/.test(obj.type))){
			var empty = (value == '')
			var required = obj.hasClass('required');
			if(required && empty) return false;			
			if(obj.hasClass('date') && !empty) return Forms.isValidDate(obj.value,"DMY");
			if(obj.hasClass('numeric') && !empty) return Forms.isNumeric(obj.value);
			if(obj.hasClass('email') && !empty) return Forms.checkMail(obj);
			if(obj.hasClass('regex') && !empty) return obj.value.test(obj.regex);
			if(obj.hasClass('size')) return Forms.checkSize(obj);
			
			if(obj.hasClass('codicefiscale_base') && !empty) 
			{
				if ( obj.value.length == 11 ) {
					if ( Forms.checkPIVA(obj.value) != '' )
						return false;
				}else
					if ( Forms.checkCF_base(obj.value) != '' ){
						return false;
					}
			}
			
			if(obj.hasClass('codicefiscale') && !empty) {
				
				var codiceStato = document.getElementById("idStato").value;
				var descStato = document.getElementById("stato").value;
				
				if ( codiceStato == '34' || descStato == '' || descStato.toUpperCase() == 'ITALIA' || descStato.toUpperCase() == 'ITALY' ) 				
				{
					if ( obj.value.length == 11 ) 
					{
						if ( Forms.checkPIVA(obj.value) != '' )
							return false;
					}
					else
					{
						if ( Forms.checkCF(obj.value) != '' )
						{
							return false;
						}
					}
				}
				else
				{
					if ( Forms.checkCF(obj.value) != '' )
					{
						return false;
					}
				}
					
			}
			
			if(obj.hasClass('piva') && !empty) {
				if ( Forms.checkPIVA(obj.value) != '' )
					return false;
			}
			
			if(obj.hasClass('pivaext') && !empty)
			{
				var retStr;
				retStr = Forms.checkPIVA_estesa(obj.value);

				if ( retStr != '' )
				{
					//alert(retStr);
					return false;
				}
			}
		}
		return true;
	},

	validateForm:function(el){
		var form = $(el);
		var result = Forms.validate(form.elements);
		form.fireEvent('afterValidation',result);
		return result;
	},
	
	validateFieldset:function(fieldset){
		var fields = fieldset.getElements('input');
		fields.extend(fieldset.getElements('textarea'));
		fields.extend(fieldset.getElements('select'));
		return Forms.validate(fields);
	},
	
	validate:function(fields){
		var error = false;		
		for(var i=0;i<fields.length;i++){
			var field = $(fields[i]);
			if(!Forms.checkField(field) && !(/button|reset|submit/.test(field.type))){
			  error = true;				
				if(!(/radio|checkbox/.test(field.type))){
				  
					field.addClass('error');
					field.addEvent('blur',function(ev){
						ev = new Event(ev);
						if(Forms.checkField(this)){
							this.removeEvent('blur');
							this.removeClass('error');
					}
					});
				}else{
				  
					var label = field.getParent();
					if(label.tagName.toLowerCase() == 'label') label.addClass('error');
				}
			}else{
				if(!(/radio|checkbox/.test(field.type))){
					removeEvent('blur');
					field.removeClass('error');
				}else{
					field.getParent().removeClass('error');
				}
			}
		}
		
		var msgerror = $('errormsg');
		if($chk(msgerror)) msgerror.remove();
		if(error){
			msgerror = new Element('div').setProperty('id','errormsg').injectBefore(fields[fields.length-1].form);
			msgerror.setHTML('<p><strong>Attenzione:</strong> I campi evidenziati non sono stati compilati correttamente!</p>');
		}

		return !error;		
	}	
}
	
window.addEvent('domready',function(){
	Forms.init();
	//alert(document.getElementById('texterrorCaptcha').innerHTML);
	try{
		if (document.getElementById('texterrorCaptcha').innerHTML != ''){
			var valid = Forms.validateForm(document.FormCens);
			accordion.display(2);
		}
	}catch(e){
		
	}	
});

function controllaContryEpiva( obj )
{
	var partitaIva;
	var descStato;
	var resp;
	var codStato;
	
	partitaIva = obj.value;
	descStato = document.getElementById("stato").value;
	
	if (partitaIva == '' || descStato == '')
		return;
	
	codStato = partitaIva.substring(0, 2);
	
	var url_app = document.getElementById("URL_APP").value;
	
	resp = checkCountry(url_app, codStato , descStato);
	
	var arr=resp.split("#");
	
	if ( arr[0] == '1' ) //Se è stato restituito il warning di controllo
	{
		alert( arr[1] );
	}
	else if ( arr[0] == '2' ) //Errore server
	{
		alert(arr[1]);
	}
	
}

