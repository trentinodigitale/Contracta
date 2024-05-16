USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CESSAZIONE_UTENTI_NUMERI_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[CESSAZIONE_UTENTI_NUMERI_VIEW] AS
select
	CV.idheader,
	CV.idrow,
	CV.value as NumRighe,
	CV2.value as NumRigheCessare,
	 NumRigheCollegati,	
	case when ISNULL( ZZZ.Num_Mail_inviate_per_DOC,0) > 0 then 
				dbo.AFS_ROUND(cast(ISNULL(ZZZ.Num_Mail_inviate_per_DOC,0) as float)/cast(ISNULL(CV2.Value,0) as float) * 100 ,1)
				else 0 
		end as perce_mail_inviate
	from ctl_doc_value CV with(nolock)
		inner join CTL_DOC_Value CV2 with(nolock) on CV2.IdHeader=CV.IdHeader  and CV2.DSE_ID='NUMERI' and CV2.DZT_Name='NumRigheCessare'				
		left join (select CV.IdHeader,count(*) as NumRigheCollegati
				from CTL_DOC_Value CV  with(nolock) 
					inner join CTL_DOC_Value CV3 with(nolock) on CV3.IdHeader=CV.IdHeader  and CV3.DSE_ID='PARAMETRI' and CV3.DZT_Name='DataUltimoCollegamento'		
					inner join ProfiliUtente P with(nolock) on P.IdPfu=CV.value and ISNULL(P.pfuLastLogin,'1900-01-01' ) > cast( CV3.Value as datetime )
				where CV.DSE_ID='ESITI' and CV.DZT_Name='Idpfu'
				group by CV.IdHeader
		) XXX on XXX.idheader=CV.idheader
		--PER CALCOLARE LE MAIL EFFETTIVAMENTE INVIATE SUL DOCUMENTO
		left join (select CV.IdHeader,COUNT(*) as Num_Mail_inviate_per_DOC
					from CTL_Mail_System CM with(nolock) 
						inner join CTL_DOC_Value CV with(nolock) on CV.IdRow=CM.IdDoc
					where CM.TypeDoc='CESSAZIONE_UTENTI' and Status='Sent'
					group by CV.IdHeader
					) ZZZ on ZZZ.IdHeader=CV.IdHeader
		where CV.DSE_ID='NUMERI' and CV.DZT_Name='NumRighe'
GO
