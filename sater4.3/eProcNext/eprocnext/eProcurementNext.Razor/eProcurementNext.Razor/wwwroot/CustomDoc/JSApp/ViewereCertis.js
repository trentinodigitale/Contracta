function RefreshContent(viewer , processo  )
{

	if ( processo == 'GET_CRITERION_BY_ID,ECERTIS' || processo == 'GET_CRITERION_BY_ID_AND_VERSION,ECERTIS' )
	{
		ShowDocument( 'DGUE_DETT_CRITERION' , idpfuUtenteCollegato );
	}
	else
	{
		ShowDocument( 'DGUE_CRITERIA' , idpfuUtenteCollegato );
	}

}