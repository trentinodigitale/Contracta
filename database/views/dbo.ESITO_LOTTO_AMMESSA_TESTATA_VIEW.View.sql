USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ESITO_LOTTO_AMMESSA_TESTATA_VIEW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ESITO_LOTTO_AMMESSA_TESTATA_VIEW] as
	select 
		C.*,
		L.NumeroLotto
		from ctl_doc C with(nolock)
			inner join Document_MicroLotti_Dettagli L with (nolock) on L.id=C.LinkedDoc
		where C.TipoDoc='ESITO_LOTTO_AMMESSA'
GO
