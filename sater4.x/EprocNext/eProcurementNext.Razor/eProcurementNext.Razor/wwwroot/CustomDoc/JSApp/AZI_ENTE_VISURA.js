function SetProfiliFunzionalita( obj ){
	
	//-- recupera la riga dove si trova l'attributo
	strNameAttrib = obj.name;
	vPartName=strNameAttrib.split('_');
	
	indRow = parseInt(vPartName[0].substr(1,vPartName[0].lenght));
	
	tempvalue=obj.value;
	ainfo=tempvalue.split('###');
	getObjGrid('R' + indRow + '_pfuprofili').value=ainfo[0];
	getObjGrid('R' + indRow + '_pfufunzionalita').value=ainfo[1];
}
