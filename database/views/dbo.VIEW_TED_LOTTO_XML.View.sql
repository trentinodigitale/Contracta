USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_TED_LOTTO_XML]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VIEW_TED_LOTTO_XML] AS
	select l.idRow,  --chiave di ingresso
			l.idHeader,
			l.CIG,
			cast(l.TED_LOT_NO as varchar) as TED_LOT_NO,			
			l.TED_TITOLO_APPALTO,
			l.TED_LUOGO_ESECUZIONE_PRINCIPALE,
			cast(l.TED_CRITERIO_AGG_LOTTO as varchar) as TED_CRITERIO_AGG_LOTTO,
			l.TED_ACCETTATE_VARIANTI,
			l.TED_DESCRIZIONE_OPZIONI,
			l.TED_PRES_OFFERTE_CATALOGO_ELETTRONICO,
			l.TED_APPALTO_PROGETTO_UE,
			l.TED_FLAG_APPALTO_PROGETTO_UE

		from Document_TED_LOTTI l with(nolock)
				

GO
