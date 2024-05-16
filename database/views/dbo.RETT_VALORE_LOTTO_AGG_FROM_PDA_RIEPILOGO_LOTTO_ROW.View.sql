USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RETT_VALORE_LOTTO_AGG_FROM_PDA_RIEPILOGO_LOTTO_ROW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[RETT_VALORE_LOTTO_AGG_FROM_PDA_RIEPILOGO_LOTTO_ROW] as
			
	select DMDO.id  as ID_FROM , DMDO.id as LinkedDoc,  Fascicolo ,ValoreImportoLotto  
			from 
				CTL_DOC PDA
					inner join DOCUMENT_PDA_OFFERTE DPO on PDA.id=DPO.idheader and PDA.tipodoc='PDA_MICROLOTTI'
						inner join	DOCUMENT_MICROLOTTI_DETTAGLI DMDO on DPO.idrow=DMDO.idheader and DMDO.TipoDoc='PDA_OFFERTE' and DMDO.voce=0 

			

GO
