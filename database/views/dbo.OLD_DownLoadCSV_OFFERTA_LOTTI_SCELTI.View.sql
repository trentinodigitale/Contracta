USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DownLoadCSV_OFFERTA_LOTTI_SCELTI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_DownLoadCSV_OFFERTA_LOTTI_SCELTI] as
select 
	B.*
	
  from Document_MicroLotti_Dettagli B with(nolock)		
	inner join (
					select distinct NumeroLotto,LinkedDoc
						from Document_MicroLotti_Dettagli D  with(nolock)
							inner join CTL_DOC C on C.Id=D.IdHeader
					where D.Tipodoc =  'OFFERTA'
					group by NumeroLotto ,LinkedDoc
				) as A on A.NumeroLotto=b.NumeroLotto	and B.IdHeader=A.LinkedDoc	
  where B.TipoDoc in ('BANDO_GARA','BANDO_SEMPLIFICATO')
GO
