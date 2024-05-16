USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TS_GET_RDA_WINNER_PRODOTTI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[TS_GET_RDA_WINNER_PRODOTTI] ( @idDoc int , @IdUser int = 0 )
AS
BEGIN

	SET NOCOUNT ON

--"PurchaseRequestMeasurementId":10,
--"ProductId":"CAEC",
--"Quantity":0.0459223198918264,
--"DeliveryDate":"2021-03-19T08:24:46.2475316+01:00",
--"DescriptionText":"rqrwerwe",
--"UnitCost":0.718692896291005

declare @IdPdaOff int
declare @NumLotto int
declare @IdPda int
declare @IdRdo int
declare @IdRDA int
declare @IdOff int
declare @IdAziForn int
declare @IdAziBuyer int

	-- legge id della Document_PDA_OFFERTE e lotto
	select @IdPdaOff=IdHeader ,@NumLotto=NumeroLotto  from Document_MicroLotti_Dettagli with (nolock) where id = @idDoc

	-- legge id della PDA e offerta
	select @IdPda=IdHeader,@IdOff=idmsg,@IdAziForn=idAziPartecipante   from Document_PDA_OFFERTE with (nolock) where idrow = @IdPdaOff

	-- legge id della RDO
	select @IdRdo=linkeddoc from ctl_doc with (nolock) where id = @IdPda and TipoDoc = 'PDA_MICROLOTTI'

	-- legge id della RDA
	select @IdRDA=linkeddoc,@IdAziBuyer = azienda from ctl_doc with (nolock) where id = @IdRdo and TipoDoc = 'BANDO_GARA' and JumpCheck = 'FROM_RDA'


-- Per capire da quali campi prendere i dati è stato usato come esempio il modello configurato sulla 062 "Modello di acquisto per le RdA di beni e servizi provenienti da CPM"

	select 	isnull(prp.PurchaseRequestMeasurementId,0) as PurchaseRequestMeasurementId,
			isnull(prp.ProductId,'') as ProductId ,
			--isnull(m.Quantita,0) as Quantity,
			--m.DATA_CONSEGNA as DeliveryDate,
			isnull(x.Quantita,0) as Quantity,
			x.DATA_CONSEGNA as DeliveryDate,
			--isnull(prp.DescriptionText,'') as DescriptionText,
			isnull(prp.ProductDescription ,'') as DescriptionText,
			--isnull(m.PREZZO_OFFERTO_PER_UM,0) as UnitCost		
			isnull(x.PREZZO_OFFERTO_PER_UM,0) as UnitCost		
		from CTL_DOC a with(nolock) -- documento di offerta
				inner join Document_MicroLotti_Dettagli m with(nolock) on m.IdHeader = a.Id and m.TipoDoc = a.TipoDoc					
				inner join CTL_DOC b with(nolock) on b.Id = a.LinkedDoc and b.TipoDoc = 'BANDO_GARA' --RDO
				inner join CTL_DOC c with(nolock) on c.Id = b.LinkedDoc and c.TipoDoc = 'PURCHASE_REQUEST' --RDA
				--inner join document_pr pr with(nolock) on pr.idheader = c.id
				inner join document_pr_product prp with(nolock) on prp.idheader = c.id and prp.ProductId = m.CodiceProdotto
				
				inner join Document_MicroLotti_Dettagli x with (nolock) on x.TipoDoc = 'PDA_OFFERTE' and x.IdHeader = @IdPdaOff
																					and x.NumeroLotto = @NumLotto and x.Voce <> 0
																					and prp.ProductId = x.CodiceProdotto
		where a.Id = @IdOff --@idDoc
				
				


END

GO
