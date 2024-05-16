USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_OE_GARA_APERTA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD_MAIL_OE_GARA_APERTA]
AS
	SELECT    
	CTL_DOC.ID as IdHeader,
	CTL_DOC.Id as IDDOC, 
	'I' as LNG,
	CTL_DOC.IdPfu, 
	convert( varchar , DataInvio , 103 ) as DataInvio, 
	Titolo, 
	Body as oggetto, 
	aziragionesociale as RagioneSociale,
	Protocollo,
	data



	FROM         
		ctl_doc with (nolock)
			inner join Aziende with (nolock) on Azienda=IdAzi
		--inner join ProfiliUtente P on P.idpfu=CTL_DOC.idpfu
		--inner join dbo.Document_Bando DB on DB.idHeader=ctl_doc.ID
		--left join (select A.APS_NOTE,A.APS_ID_DOC from CTL_APPROVALSteps A, (Select MAX(APS_ID_ROW) as APS_ID_ROW,APS_ID_DOC from CTL_APPROVALSteps where APS_State <> 'Sent' group by APS_ID_DOC )B where A.APS_ID_ROW=B.APS_ID_ROW) C on ctl_doc.ID=C.APS_ID_DOC  
			
			where TipoDoc='BANDO_gara' and CTL_DOC.deleted=0 
					and StatoFunzionale <> 'InLavorazione'


GO
