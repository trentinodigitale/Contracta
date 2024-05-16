USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_CONVENZIONE_PORTALE_CAPIENZA_LOTTI_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE VIEW [dbo].[OLD_CONVENZIONE_PORTALE_CAPIENZA_LOTTI_VIEW]
	as 

	select 
		DCL.*
		, V.CIg 
		
		, dbo.GetAggiudicazioneLotto(DCL.IdHeader, V.CIG) as Data_Aggiudicazione_Lotto

		from Document_Convenzione_Lotti DCL

			inner join (
						select 
							IdHeader,NumeroLotto ,max (cig) as CIG
						from 
							Document_MicroLotti_Dettagli
						where 
							TipoDoc = 'CONVENZIONE' 
							group by IdHeader,NumeroLotto ) V on V.IdHeader = DCL.idHeader and V.NumeroLotto=DCL.NumeroLotto

		


GO
