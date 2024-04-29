function setVisibility(target, s_value_property)
{
	var cls = target.getAttribute('class');	
	if (cls === null )
	{
		cls=' ';
	}	
	if (s_value_property !== '')
	{
		/*
			if (s_value_property.toLowerCase() == 'none')
			{
				//aggiungo la classe display_none a quelle gia presenti nell'attributo class 
				//a meno che la classe display_none non c'era gia
				if ( cls.indexOf('display_none') == -1)
					target.setAttribute('class',cls + 'display_none');
			}
		*/
		
			target.style.display = s_value_property;
	}
	else
	{
		// tolgo la classe display_none se c'era e poi faccio questo target.style.display = 'inline';
		if ( cls.indexOf('display_none') > -1)
			target.setAttribute('class',cls.replace('display_none','') );
		//target.style.display = 'inline'; // la proprietà inline corrompeva lo stile del folder/bottone, facendolo uscire schiacciato
		target.style.display = ''; //funzionerebbe anche block ma credo sia più conservativo così
	}
}
