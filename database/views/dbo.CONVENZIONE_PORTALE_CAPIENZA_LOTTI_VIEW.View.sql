USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONVENZIONE_PORTALE_CAPIENZA_LOTTI_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


	CREATE VIEW [dbo].[CONVENZIONE_PORTALE_CAPIENZA_LOTTI_VIEW]
	as 

	select 
		DCL.*
		, V.CIg 
		
		, dbo.GetAggiudicazioneLotto(DCL.IdHeader, V.CIG) as Data_Aggiudicazione_Lotto

		, case when cast( Importo as decimal(20,5)) = cast( isnull( TotalOrigine , Importo ) as decimal( 20 , 5 ) ) then 'no' else 'si' end as Estensioni

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
