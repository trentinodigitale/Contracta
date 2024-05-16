USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_FASCICOLO_DOCUMENTI_AGGIUNTIVI_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[OLD_FASCICOLO_DOCUMENTI_AGGIUNTIVI_TESTATA_VIEW] AS

select	Id,
		titolo,
		IdPfu,
		Fascicolo,
		DataInvio,
		Note,
		Protocollo,
		StatoFunzionale
	from ctl_doc
	where TipoDoc = 'FASCICOLO_DOCUMENTI_AGGIUNTIVI' and Deleted = 0


GO
