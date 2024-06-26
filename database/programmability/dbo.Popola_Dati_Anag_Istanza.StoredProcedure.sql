USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Popola_Dati_Anag_Istanza]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  PROCEDURE [dbo].[Popola_Dati_Anag_Istanza] 
	( @idDoc int , @IdAzi int , @AreaVal varchar(100)  )
AS
BEGIN

SET NOCOUNT ON

declare @RagSoc varchar(300)
declare @PIVA varchar(300)
declare @INDIRIZZOLEG varchar(300)
declare @LOCALITALEG varchar(300)
declare @PROVINCIALEG varchar(300)
declare @aziStatoLeg varchar(300)
declare @aziCapLeg varchar(300)

declare @QualificazioneAzi varchar(300)
declare @BilancioCertificato  varchar(300)
declare @PoliticaAmbientale  varchar(300)
declare @CertificazioniAzi  varchar(300)
declare @Numerodipendenti  varchar(300)
declare @NrFornitori float
declare @Ordinato  float
declare @FatturatoFornitore  float
declare @Debiti  float
declare @CapitaleNetto  float
declare @RedditoOperativo float

declare @INDIRIZZOOp varchar(300)
declare @LOCALITAOp varchar(300)
declare @PROVINCIAOp varchar(300)
declare @aziStatoOp varchar(300)
declare @aziCapOp varchar(300)

declare @RisultatoNetto  float
declare @CapitaleInvestito  float
declare @PatrimonioNetto  float
declare @FatturatoNettoAnnoN  float
declare @FatturatoNettoAnnoN_2  float
declare @FatturatoNettoAnnoN_1  float
declare @VolumeInvestimentiAnnoN  float
declare @VolumeInvestimentiAnnoN_1  float
declare @VolumeInvestimentiAnnoN_2  float



select @RagSoc=aziRagioneSociale,@PIVA=aziPartitaIVA,@INDIRIZZOLEG=aziIndirizzoLeg,
@LOCALITALEG=aziLocalitaLeg,@PROVINCIALEG=aziProvinciaLeg,@aziStatoLeg=aziStatoLeg,
@aziCapLeg=aziCAPLeg,@INDIRIZZOOp=aziIndirizzoOp,@LOCALITAOp=aziLocalitaOp,
@PROVINCIAOp=aziProvinciaOp,@aziStatoOp=aziStatoOp,@aziCapOp=aziCapOp
from aziende
where idazi=@IdAzi


--select @QualificazioneAzi =dsctesto from descsi
--inner join dm_attributi on idapp=1 and lnk=@idazi 
--				and dztnome='Qualificazione' and vatvalore_fv=iddsc

--select @BilancioCertificato =tdrcodiceraccordo from tipidatirange
--inner join dm_attributi on idapp=1 and lnk=@idazi 
--				and dztnome='BilancioCertificato' and vatvalore_fv=tdrcodice
--				and tdridtid=dztidtid

--select @PoliticaAmbientale =dsctesto from descsi
--inner join dm_attributi on idapp=1 and lnk=@idazi 
--				and dztnome='PoliticaAmbientale' and vatvalore_fv=iddsc
				
--select @CertificazioniAzi =dsctesto from descsi
--inner join dm_attributi on idapp=1 and lnk=@idazi 
--				and dztnome='Certificazioni' and vatvalore_fv=iddsc				


--select @Numerodipendenti =dsctesto from descsi
--inner join dm_attributi on idapp=1 and lnk=@idazi 
--				and dztnome='Numerodipendenti' and vatvalore_fv=iddsc


select @INDIRIZZOOp =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='PAIndirizzoOp' 

select @LOCALITAOp =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='PALocalitaOp' 

select @PROVINCIAOp =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='PAProvinciaOp' 

select @aziStatoOp =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='PAStatoOp' 

select @aziCapOp =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='PACapOp' 





select @QualificazioneAzi =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='Qualificazione' 

select @BilancioCertificato =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='BilancioCertificato' 

select @PoliticaAmbientale =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='PoliticaAmbientale' 

select @CertificazioniAzi =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='Certificazioni' 

select @Numerodipendenti =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='Numerodipendenti' 





select @NrFornitori =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='NrFornitori' 

select @Ordinato =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='Ordinato' 

select @FatturatoFornitore =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='FatturatoFornitore' 

select @Debiti =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='Debiti' 

select @CapitaleNetto =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='CapitaleNetto' 

select @RedditoOperativo =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='RedditoOperativo' 


select @RisultatoNetto =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='RisultatoNetto' 

select @CapitaleInvestito =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='CapitaleInvestito' 

select @PatrimonioNetto =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='PatrimonioNetto' 

select @FatturatoNettoAnnoN =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='FatturatoNettoAnnoN' 

select @FatturatoNettoAnnoN_2 =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='FatturatoNettoAnnoN-2' 

select @FatturatoNettoAnnoN_1 =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='FatturatoNettoAnnoN-1' 

select @VolumeInvestimentiAnnoN =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='VolumeInvestimentiAnnoN' 

select @VolumeInvestimentiAnnoN_1 =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='VolumeInvestimentiAnnoN-1' 

select @VolumeInvestimentiAnnoN_2 =vatvalore_ft from dm_attributi 
where idapp=1 and lnk=@idazi and dztnome='VolumeInvestimentiAnnoN-2' 







insert into dbo.DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi
(idHeader, RagSoc, PIVA, INDIRIZZOLEG, LOCALITALEG, PROVINCIALEG, aziStatoLeg, aziCapLeg, QualificazioneAzi, BilancioCertificato, PoliticaAmbientale, CertificazioniAzi, Numerodipendenti, NrFornitori, Ordinato, FatturatoFornitore, Debiti, CapitaleNetto, RedditoOperativo, INDIRIZZOOp, LOCALITAOp, PROVINCIAOp, aziStatoOp, aziCapOp,RisultatoNetto,CapitaleInvestito,PatrimonioNetto,FatturatoNettoAnnoN,FatturatoNettoAnnoN_2,FatturatoNettoAnnoN_1,VolumeInvestimentiAnnoN,VolumeInvestimentiAnnoN_1,VolumeInvestimentiAnnoN_2,areavalutazione )
values
(@idDoc,@RagSoc, @PIVA, @INDIRIZZOLEG, @LOCALITALEG, @PROVINCIALEG, @aziStatoLeg, @aziCapLeg, @QualificazioneAzi, @BilancioCertificato, @PoliticaAmbientale, @CertificazioniAzi, @Numerodipendenti, @NrFornitori, @Ordinato, @FatturatoFornitore, @Debiti, @CapitaleNetto, @RedditoOperativo, @INDIRIZZOOp, @LOCALITAOp, @PROVINCIAOp, @aziStatoOp, @aziCapOp,@RisultatoNetto,@CapitaleInvestito,@PatrimonioNetto,@FatturatoNettoAnnoN,@FatturatoNettoAnnoN_2,@FatturatoNettoAnnoN_1,@VolumeInvestimentiAnnoN,@VolumeInvestimentiAnnoN_1,@VolumeInvestimentiAnnoN_2,@AreaVal)





END








GO
