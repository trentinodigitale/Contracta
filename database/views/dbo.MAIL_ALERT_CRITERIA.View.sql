USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_ALERT_CRITERIA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MAIL_ALERT_CRITERIA] AS
	select	id as iddoc,
			'I'  as LNG,
			totInseriti,
			totCancellati,
			totModificati,

			case when totInseriti > 0 then '<li>Nuovi : ' + cast( totInseriti as varchar(10)) + '</li>' else '' end as LI_Inseriti,
			case when totCancellati > 0 then '<li>Cancellati : ' + cast( totCancellati as varchar(10)) + '</li>' else '' end as LI_Cancellati,
			case when totModificati > 0 then '<li>Modificati : ' + cast( totModificati as varchar(10)) + '</li>' else '' end as LI_Modificati

	from Document_eCertis_log with(nolock)

GO
