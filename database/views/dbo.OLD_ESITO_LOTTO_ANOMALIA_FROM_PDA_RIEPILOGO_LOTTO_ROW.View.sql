USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_ESITO_LOTTO_ANOMALIA_FROM_PDA_RIEPILOGO_LOTTO_ROW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create view [dbo].[OLD_ESITO_LOTTO_ANOMALIA_FROM_PDA_RIEPILOGO_LOTTO_ROW] as
select L.id  as ID_FROM , o.idMsg as IdDoc,  idAziPArtecipante as Azienda
					 ,  Fascicolo , L.id as LinkedDoc --, 'InLavorazione' as StatoFunzionale
			from Document_MicroLotti_Dettagli L 
				inner join Document_PDA_OFFERTE o on L.idHeader = o.idrow 
				inner join ctl_doc b on o.idheader = b.id





GO
