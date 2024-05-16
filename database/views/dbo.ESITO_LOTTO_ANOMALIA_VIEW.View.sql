USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ESITO_LOTTO_ANOMALIA_VIEW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[ESITO_LOTTO_ANOMALIA_VIEW] as
	select  a.* 
			,o.aziRagioneSociale
			,L.NumeroLotto
			,o.ProtocolloOfferta
		from CTL_DOC a 
				left join Document_MicroLotti_Dettagli L on L.Id = a.LinkedDoc
				left join Document_PDA_OFFERTE o on o.idrow  = L.idHeader
	--	WHERE a.Id = 85981



GO
