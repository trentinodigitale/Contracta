USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_CESSAZIONE_UTENTI_NUMERI_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_CESSAZIONE_UTENTI_NUMERI_VIEW] AS
select
	CV.idheader,
	CV.idrow,
	CV.value as NumRighe,
	CV2.value as NumRigheCessare,
	 NumRigheCollegati
	
	from ctl_doc_value CV with(nolock)
		inner join CTL_DOC_Value CV2 with(nolock) on CV2.IdHeader=CV.IdHeader  and CV2.DSE_ID='NUMERI' and CV2.DZT_Name='NumRigheCessare'				
		left join (select CV.IdHeader,count(*) as NumRigheCollegati
				from CTL_DOC_Value CV  with(nolock) 
					inner join CTL_DOC_Value CV3 with(nolock) on CV3.IdHeader=CV.IdHeader  and CV3.DSE_ID='PARAMETRI' and CV3.DZT_Name='DataUltimoCollegamento'		
					inner join ProfiliUtente P with(nolock) on P.IdPfu=CV.value and ISNULL(P.pfuLastLogin,'1900-01-01' ) > cast( CV3.Value as datetime )
				where CV.DSE_ID='ESITI' and CV.DZT_Name='Idpfu'
				group by CV.IdHeader
		) XXX on XXX.idheader=CV.idheader
		where CV.DSE_ID='NUMERI' and CV.DZT_Name='NumRighe'
GO
