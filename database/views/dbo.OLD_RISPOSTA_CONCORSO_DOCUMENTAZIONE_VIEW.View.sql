USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_RISPOSTA_CONCORSO_DOCUMENTAZIONE_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--../../CTL_Library/images/Domain/


CREATE VIEW [dbo].[OLD_RISPOSTA_CONCORSO_DOCUMENTAZIONE_VIEW]
as
	select 
		*
		,
		case
			when isnull(NotEditable,'') <> ' descrizione allegato obbligatorio ' then 'OK'
			else 'KO'
		end as Esito
		from 
		CTL_DOC_ALLEGATI
GO
