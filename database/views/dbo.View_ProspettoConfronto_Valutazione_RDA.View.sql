USE [AFLink_TND]
GO
/****** Object:  View [dbo].[View_ProspettoConfronto_Valutazione_RDA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[View_ProspettoConfronto_Valutazione_RDA]
as
		select 
				--a.id,
				c.id,
				isnull(b1.ProductId,x.CodiceProdotto )  as codart,
				isnull(b1.ProductDescription,x.Descrizione ) as DescrizioneArticolo,
				isnull(b1.ProductUnitDescription,x.CampoTesto_1 ) as dscTesto,
				--round(cast(b1.Quantity as float),0) as CARQuantitaDaOrdinare,
				round(cast(x.Quantita as float),0) as CARQuantitaDaOrdinare,
				x.CodiceProdotto as CodiceProdotto
				--,x.*
				
				


			--from Document_MicroLotti_Dettagli  a with (nolock) 
			from ctl_doc c with (nolock)
				--inner join Document_PDA_OFFERTE b with (nolock) on b.IdRow = a.IdHeader 
				--inner join ctl_doc h with (nolock) on h.id = b.IdMsg   and h.TipoDoc = 'offerta' and h.Deleted = 0
				--inner join ctl_doc c with (nolock) on c.id = b.IdHeader  and c.TipoDoc = 'PDA_MICROLOTTI' and c.Deleted = 0
				inner join ctl_doc d with (nolock) on d.id = c.LinkedDoc   and d.TipoDoc = 'bando_gara' and d.Deleted = 0
				left outer join ctl_doc c1 with (nolock) on c1.id = d.LinkedDoc  and c1.TipoDoc = 'PURCHASE_REQUEST' and c1.Deleted = 0

				left outer join document_pr a1 with (nolock) on a1.idheader = c1.id
				left outer join document_pr_product b1 with (nolock) on a1.idheader = b1.idheader 
				inner join Document_MicroLotti_Dettagli x 	with (nolock) on x.IdHeader=d.id and x.TipoDoc = 'BANDO_GARA'									
																			and x.voce <> 0 
																			and (x.CodiceProdotto = b1.ProductId or b1.ProductId is null)
					
					where c.TipoDoc = 'PDA_MICROLOTTI' and c.Deleted = 0									
						--and c.id = 83806


					--select d.LinkedDoc,c.LinkedDoc,* from ctl_doc c 
					--inner join ctl_doc d with (nolock) on d.id = c.LinkedDoc   and d.TipoDoc = 'bando_gara' and d.Deleted = 0
					----inner join ctl_doc c1 with (nolock) on c1.id = d.LinkedDoc  and c1.TipoDoc = 'PURCHASE_REQUEST' and c1.Deleted = 0
					--	where c.TipoDoc = 'PDA_MICROLOTTI' and c.Deleted = 0	 and c.id = 83806
					--select * from document_pr_product
					
GO
