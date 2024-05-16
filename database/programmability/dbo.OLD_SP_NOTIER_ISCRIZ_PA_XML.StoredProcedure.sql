USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_SP_NOTIER_ISCRIZ_PA_XML]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[OLD_SP_NOTIER_ISCRIZ_PA_XML]
		( @idDoc int)
as
BEGIN

	SET NOCOUNT ON


	select 
			id
		 ,isnull(IdAzi,0) as IdAzi
		 ,isnull(ORG_CodiceFiscale,'') as ORG_CodiceFiscale
		 ,isnull(ORG_Denominazione,'') as ORG_Denominazione
		 ,isnull(ORG_EmailReferente,'') as ORG_EmailReferente
		 ,isnull(ORG_Indirizzo,'') as ORG_Indirizzo
		 ,isnull(ORG_PartitaIva,'') as ORG_PartitaIva
		 ,isnull(ORG_PEC,'') as ORG_PEC
		 ,isnull(ORG_Referente,'') as ORG_Referente
		 ,isnull(ORG_Telefono,'') as ORG_Telefono
		 ,isnull(ORG_PrimoLivelloStruttura,'') as ORG_PrimoLivelloStruttura
		 ,isnull(ORG_SecondoLivelloStruttura,'') as ORG_SecondoLivelloStruttura
		 ,isnull(ORG_stato,'') as ORG_stato
		 ,isnull(IDNOTIER_ORGANIZZAZIONE,'') as IDNOTIER_ORGANIZZAZIONE
		 ,isnull(UFF_CodiceIPA,'') as UFF_CodiceIPA
		 ,isnull(UFF_CodiceFiscale,'') as UFF_CodiceFiscale
		 ,isnull(UFF_Denominazione,'') as UFF_Denominazione
		 ,isnull(UFF_EmailReferente,'') as UFF_EmailReferente
		 ,isnull(UFF_Indirizzo,'') as UFF_Indirizzo
		 ,isnull(UFF_PartitaIva,'') as UFF_PartitaIva
		 ,isnull(UFF_PEC,'') as UFF_PEC
		 ,isnull(UFF_Peppol_Invio_DDT,'') as UFF_Peppol_Invio_DDT
		 ,isnull(UFF_Peppol_Invio_Ordine,'') as UFF_Peppol_Invio_Ordine
		 ,isnull(UFF_Peppol_Ricezione_DDT,'') as UFF_Peppol_Ricezione_DDT
		 ,isnull(UFF_Peppol_Ricezione_Ordine,'') as UFF_Peppol_Ricezione_Ordine
		 ,isnull(UFF_Peppol_Invio_Fatture,'') as UFF_Peppol_Invio_Fatture
		 ,isnull(UFF_Peppol_Invio_NoteDiCredito,'') as UFF_Peppol_Invio_NoteDiCredito
		 ,isnull(UFF_Referente,'') as UFF_Referente
		 ,isnull(UFF_Telefono,'') as UFF_Telefono
		 ,isnull(UFF_stato,'') as UFF_stato
		from VIEW_NOTIER_ISCRIZ_PA_XML with(nolock)
		where id = @idDoc
	

END

GO
