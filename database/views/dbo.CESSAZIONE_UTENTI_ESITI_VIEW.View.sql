USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CESSAZIONE_UTENTI_ESITI_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[CESSAZIONE_UTENTI_ESITI_VIEW]  AS
Select
	C.Id as idheader ,
	ISNULL(CV.idrow,0) as idrow,
	ISNULL(pfunomeutente,'') + ' ' + ISNULL(pfuCognome,'')  As cognomeutente,
	P.pfuLastLogin,
	P.pfuE_Mail as EmailUTente,
	A.aziRagioneSociale,
	P.IdPfu,
	ROW_NUMBER() over (Partition By C.id  order by A.aziragionesociale) as NumRiga,
	CM.MailObj,
	CASE ISNULL(pfudeleted,0)
			when 1 then  'deleted'
			else
			CASE ISNULL(pfustato,'')
				WHEN 'block' THEN 'blocked'
				WHEN  '' THEN 'not-blocked'			
			end 
	END AS StatoUtenti,
	C.TipoDoc,
	P.pfuDataCreazione

	from CTL_DOC C with(nolock)
		inner join CTL_DOC_Value CV  with(nolock) on CV.IdHeader=C.Id and CV.DSE_ID='ESITI' and CV.DZT_Name='Idpfu'
		left join CTL_Mail_System CM with(nolock) on CV.IdRow=CM.IdDoc and CM.TypeDoc='CESSAZIONE_UTENTI' and Status='Sent'
		inner join ProfiliUtente P with(nolock) on P.IdPfu=CV.Value
		inner join Aziende A with(nolock) on A.IdAzi=P.pfuIdAzi
	where C.tipodoc='CESSAZIONE_UTENTI' and C.Deleted=0
	
GO
