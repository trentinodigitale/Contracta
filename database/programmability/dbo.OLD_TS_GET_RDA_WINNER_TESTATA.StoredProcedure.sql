USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_TS_GET_RDA_WINNER_TESTATA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD_TS_GET_RDA_WINNER_TESTATA] ( @idDoc int , @IdUser int = 0 )
AS
BEGIN

	SET NOCOUNT ON

--"CompanyId":"AZ1",	-- CODICE FISCALE DELLA COMPANY, PRESO DALL'RDA IN PARTENZA.
--"ProjectId":"LAV1",	-- DI DI PROGETTO, PRESO DALL'RDA
--"PurchaseRequestId":"EFFBBCFDAEACFD0",	--PRESO DALL'RDA
--"DeliveryDate":"2021-03-19T08:24:46.2475316+01:00",	-- PRESO DALL'RDA
--"DeliveryNotes":"dsafd",	-- PRESO DALL'RDA
--"NominativeId":"1128",	--CODICE FISCALE FORNITORE VINCITORE
--"NominativeDescription":"fsdf",	--RAGIONE SOCIALE VINCITORE
--"PurchaseRequestNotes":"fwefwe w"	-- PRESO DALL'RDA

	select  'it-IT' as LanguageId,
			isnull(pr.CompanyCF,'') as CompanyId,
			isnull(pr.ProjectId,'') as ProjectId,
			isnull(c.NumeroDocumento,'') as PurchaseRequestId,
			c.DataScadenza as DeliveryDate,
			isnull(c.Note,'') as DeliveryNotes,
			isnull(dm1.vatValore_FT,'') as NominativeId,
			isnull(az.aziRagioneSociale,'') as NominativeDescription,
			isnull(pr.PurchaseRequestNotes,'') as PurchaseRequestNotes
		from CTL_DOC a with(nolock) -- documento di offerta
				inner join Aziende az with(nolock) on az.IdAzi = a.Azienda
				inner join DM_Attributi dm1 with(nolock) on dm1.lnk = az.IdAzi and dm1.dztNome = 'codicefiscale' and dm1.idApp = 1
				inner join CTL_DOC b with(nolock) on b.Id = a.LinkedDoc and b.TipoDoc = 'BANDO_GARA' --RDO
				inner join CTL_DOC c with(nolock) on c.Id = b.LinkedDoc and c.TipoDoc = 'PURCHASE_REQUEST' --RDA
				inner join document_pr pr with(nolock) on pr.idheader = c.id
		where a.Id = @idDoc
				
				


END





GO
