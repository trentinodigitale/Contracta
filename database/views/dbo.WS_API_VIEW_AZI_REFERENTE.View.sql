USE [AFLink_TND]
GO
/****** Object:  View [dbo].[WS_API_VIEW_AZI_REFERENTE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
		
CREATE VIEW [dbo].[WS_API_VIEW_AZI_REFERENTE] AS

	select IdAzi,
			CognomeRapLeg as CognomeReferente, 
			NomeRapLeg as NomeReferente,
			CFRapLeg as CodiceFiscaleReferente,
			LocalitaRapLeg as LocalitaNascitaReferente,
			DataRapLeg as DataNascitaReferente,
			ResidenzaRapLeg as LocalitaResidenzaReferente,
			IndResidenzaRapLeg as IndirizzoResidenzaReferente
		from 
		(
			select lnk as idazi, vatValore_FT, dztNome
				from dm_attributi dm with(nolock)
				where idapp = 1
		) as P
			pivot
			(
				min(vatValore_FT)
				for dztnome in (CognomeRapLeg, NomeRapLeg,CFRapLeg, LocalitaRapLeg,DataRapLeg,ResidenzaRapLeg,IndResidenzaRapLeg)
			) as PIV
GO
