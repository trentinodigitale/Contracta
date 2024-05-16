USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_LISTA_OFFERTE_PER_LOTTI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_LISTA_OFFERTE_PER_LOTTI] AS
	SELECT	d.Id,
			d.IdHeader,
			cast(d.NumeroLotto as int) as NumeroLotto,
			d.Descrizione,
			d.CIG,
			offer.NumeroOfferte
		FROM Document_MicroLotti_Dettagli d WITH(NOLOCK)

				LEFT JOIN (
							SELECT count(*) as NumeroOfferte , doc.LinkedDoc, o.NumeroLotto
								FROM CTL_DOC doc with(nolock) 
										inner join Document_MicroLotti_Dettagli o with(nolock) on o.idheader = doc.id and o.TipoDoc = 'OFFERTA' and o.voce = 0
									WHERE doc.TipoDoc in ( 'OFFERTA' ) and doc.StatoFunzionale = 'Inviato' and doc.Deleted = 0
										and doc.StatoDoc <> 'Invalidate'
								GROUP BY doc.LinkedDoc, o.NumeroLotto

							) offer on offer.LinkedDoc= d.IdHeader and offer.NumeroLotto = d.NumeroLotto

		where d.TipoDoc in ( 'BANDO_GARA', 'BANDO_SEMPLIFICATO' ) and d.Voce = 0 --and d.IdHeader = 63019


GO
