USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_View_ProspettoConfronto_Valutazione_RDA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_View_ProspettoConfronto_Valutazione_RDA]
as
		select 
				--a.id,
				c.id,
				b1.ProductId as codart,
				b1.ProductDescription as DescrizioneArticolo,
				b1.ProductUnitDescription as dscTesto,
				--round(cast(b1.Quantity as float),0) as CARQuantitaDaOrdinare,
				round(cast(x.Quantita as float),0) as CARQuantitaDaOrdinare
				
				


			--from Document_MicroLotti_Dettagli  a with (nolock) 
			from ctl_doc c with (nolock)
				--inner join Document_PDA_OFFERTE b with (nolock) on b.IdRow = a.IdHeader 
				--inner join ctl_doc h with (nolock) on h.id = b.IdMsg   and h.TipoDoc = 'offerta' and h.Deleted = 0
				--inner join ctl_doc c with (nolock) on c.id = b.IdHeader  and c.TipoDoc = 'PDA_MICROLOTTI' and c.Deleted = 0
				inner join ctl_doc d with (nolock) on d.id = c.LinkedDoc   and d.TipoDoc = 'bando_gara' and d.Deleted = 0
				inner join ctl_doc c1 with (nolock) on c1.id = d.LinkedDoc  and c1.TipoDoc = 'PURCHASE_REQUEST' and c1.Deleted = 0

				inner join document_pr a1 with (nolock) on a1.idheader = c1.id
				inner join document_pr_product b1 with (nolock) on a1.idheader = b1.idheader 
				inner join Document_MicroLotti_Dettagli x 	with (nolock) on x.IdHeader=d.id and x.TipoDoc = 'BANDO_GARA'									
																			and x.voce <> 0 and x.CodiceProdotto = b1.ProductId
					
					where c.TipoDoc = 'PDA_MICROLOTTI' and c.Deleted = 0									
						--and c.id = 83685


					--select voce,* from Document_MicroLotti_Dettagli 
					--where IdHeader = 83673 and TipoDoc = 'BANDO_GARA'
					
GO
