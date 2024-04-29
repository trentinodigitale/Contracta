
<script language="javascript">

//nel caso di non cifratura svuoto le date DataInizioPwd e DataFinePwd
if (getObj('Stato').value == '0' && getObj('Rilancio').value != '15534'){
	getObj('DataInizioPwd_vis').value='';
	getObj('DataFinePwd_vis').value='';
	getObj('DataInizioPwd').value='';
	getObj('DataFinePwd').value='';
	
	getObj('DataInizioPwd_hh').value='';
	getObj('DataFinePwd_hh').value='';
	
	getObj('DataInizioPwd_mm').value='';
	getObj('DataFinePwd_mm').value='';
	
	getObj('DataInizioPwd_ss').value='';
	getObj('DataFinePwd_ss').value='';
	

}

//nel caso di non cifratura disabilito le date
if (getObj('Rilancio').value != '15534'){
	
	getObj('DataInizioPwd_vis').value='';
	getObj('DataFinePwd_vis').value='';
	getObj('DataInizioPwd').value='';
	getObj('DataFinePwd').value='';
		
	getObj('DataInizioPwd_vis').disabled=true;
	getObj('DataFinePwd_vis').disabled=true;
	getObj('DataInizioPwd_BTN').disabled=true;
	getObj('DataFinePwd_BTN').disabled=true;
	
	getObj('DataInizioPwd_hh').value='';
	getObj('DataFinePwd_hh').value='';
	getObj('DataInizioPwd_hh').disabled=true;
	getObj('DataFinePwd_hh').disabled=true;
	
	getObj('DataInizioPwd_mm').value='';
	getObj('DataFinePwd_mm').value='';
	getObj('DataInizioPwd_mm').disabled=true;
	getObj('DataFinePwd_mm').disabled=true;
	
	getObj('DataInizioPwd_ss').value='';
	getObj('DataFinePwd_ss').value='';
	getObj('DataInizioPwd_ss').disabled=true;
	getObj('DataFinePwd_ss').disabled=true;
	
}

</script>
