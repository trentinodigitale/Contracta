USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_TS_GET_RDA_WINNER_PRODOTTI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD2_TS_GET_RDA_WINNER_PRODOTTI] ( @idDoc int , @IdUser int = 0 )
AS
BEGIN

	SET NOCOUNT ON

--"PurchaseRequestMeasurementId":10,
--"ProductId":"CAEC",
--"Quantity":0.0459223198918264,
--"DeliveryDate":"2021-03-19T08:24:46.2475316+01:00",
--"DescriptionText":"rqrwerwe",
--"UnitCost":0.718692896291005

-- Per capire da quali campi prendere i dati è stato usato come esempio il modello configurato sulla 062 "Modello di acquisto per le RdA di beni e servizi provenienti da CPM"

	select 	isnull(prp.PurchaseRequestMeasurementId,0) as PurchaseRequestMeasurementId,
			isnull(prp.ProductId,'') as ProductId ,
			isnull(m.Quantita,0) as Quantity,
			m.DATA_CONSEGNA as DeliveryDate,
			isnull(prp.DescriptionText,'') as DescriptionText,
			isnull(m.PREZZO_OFFERTO_PER_UM,0) as UnitCost			
		from CTL_DOC a with(nolock) -- documento di offerta
				inner join Document_MicroLotti_Dettagli m with(nolock) on m.IdHeader = a.Id and m.TipoDoc = a.TipoDoc
				inner join CTL_DOC b with(nolock) on b.Id = a.LinkedDoc and b.TipoDoc = 'BANDO_GARA' --RDO
				inner join CTL_DOC c with(nolock) on c.Id = b.LinkedDoc and c.TipoDoc = 'PURCHASE_REQUEST' --RDA
				--inner join document_pr pr with(nolock) on pr.idheader = c.id
				inner join document_pr_product prp with(nolock) on prp.idheader = c.id and prp.ProductId = m.CodiceProdotto
		where a.Id = @idDoc
				
				


END

GO
