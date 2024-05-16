USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DownLoadCSV_OFFERTA_LOTTI_SCELTI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD2_DownLoadCSV_OFFERTA_LOTTI_SCELTI] as
select 
	B.*,idoff
	from Document_MicroLotti_Dettagli B with(nolock)		
		--MI PRENDO SOLO I LOTTI PRESENTI NELLE OFFERTE
		inner join (
						select distinct NumeroLotto,LinkedDoc,IdHeader as idoff
							from Document_MicroLotti_Dettagli D  with(nolock)
								inner join CTL_DOC C on C.Id=D.IdHeader
							where D.Tipodoc =  'OFFERTA'
							group by NumeroLotto ,LinkedDoc,IdHeader
					) as A on A.NumeroLotto=b.NumeroLotto	and B.IdHeader=A.LinkedDoc	
  where B.TipoDoc in ('BANDO_GARA','BANDO_SEMPLIFICATO')

GO
