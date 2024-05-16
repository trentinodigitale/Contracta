USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_ESITO_QUALIFICAZIONE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD_MAIL_ESITO_QUALIFICAZIONE]
as
	select	idcom as iddoc,
			idcom as id,
			[Name],
			Protocollo,
			datacreazione as DataInvio,
			note as object,
			aziRagionesociale,
			'I' as LNG
	
		from Document_Esito_Qualificazione
			inner join aziende on idazi = idazienda

GO
