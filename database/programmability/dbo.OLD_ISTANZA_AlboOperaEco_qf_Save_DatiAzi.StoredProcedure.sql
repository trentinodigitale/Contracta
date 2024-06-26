USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ISTANZA_AlboOperaEco_qf_Save_DatiAzi]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  PROCEDURE [dbo].[OLD_ISTANZA_AlboOperaEco_qf_Save_DatiAzi] 
	( @idDoc int )
AS
BEGIN

    SET NOCOUNT ON;

    declare @Idazi as INT
    
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
    declare @merc varchar(5000)
	declare @value varchar(max)
    set @value=''
    select @Idazi=azienda    
    from  ctl_doc     
    where id=@idDoc
    	
    select
    @RagSoc=RagSoc, 
    @PIVA=PIVA, 
    @INDIRIZZOLEG=INDIRIZZOLEG, 
    @LOCALITALEG=LOCALITALEG, 
    @PROVINCIALEG=PROVINCIALEG, 
    @aziStatoLeg=aziStatoLeg, 
    @aziCapLeg=aziCapLeg, 
    @QualificazioneAzi=QualificazioneAzi, 
    @BilancioCertificato=BilancioCertificato, 
    @PoliticaAmbientale=PoliticaAmbientale, 
    @CertificazioniAzi=CertificazioniAzi, 
    @Numerodipendenti=Numerodipendenti, 
    @NrFornitori=NrFornitori, 
    @Ordinato=Ordinato, 
    @FatturatoFornitore=FatturatoFornitore, 
    @Debiti=Debiti, 
    @CapitaleNetto=CapitaleNetto, 
    @RedditoOperativo=RedditoOperativo, 
    @INDIRIZZOOp=INDIRIZZOOp, 
    @LOCALITAOp=LOCALITAOp, 
    @PROVINCIAOp=PROVINCIAOp, 
    @aziStatoOp=aziStatoOp, 
    @aziCapOp=aziCapOp,
    @RisultatoNetto=RisultatoNetto,
    @CapitaleInvestito=CapitaleInvestito,
    @PatrimonioNetto=PatrimonioNetto,
    @FatturatoNettoAnnoN=FatturatoNettoAnnoN,
    @FatturatoNettoAnnoN_2=FatturatoNettoAnnoN_2,
    @FatturatoNettoAnnoN_1=FatturatoNettoAnnoN_1,
    @VolumeInvestimentiAnnoN=VolumeInvestimentiAnnoN,
    @VolumeInvestimentiAnnoN_1=VolumeInvestimentiAnnoN_1,
    @VolumeInvestimentiAnnoN_2=VolumeInvestimentiAnnoN_2
	   
    
    
    from dbo.DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi
    where idHeader=@idDoc
       
    -- aggiorna i dati della tabella aziende
    update aziende
    set aziRagioneSociale=@RagSoc, 
    aziPartitaIVA=@PIVA, 
    aziIndirizzoLeg=@INDIRIZZOLEG,
    aziLocalitaLeg=@LOCALITALEG,
    aziProvinciaLeg=@PROVINCIALEG,
    aziStatoLeg=@aziStatoLeg,
    aziCAPLeg=@aziCapLeg,    
    
    aziIndirizzoOp=@INDIRIZZOOp, 
    aziLocalitaOp=@LOCALITAOp, 
    aziProvinciaOp=@PROVINCIAOp, 
    aziStatoOp=@aziStatoOp, 
    aziCapOp=@aziCapOp
    where idazi=@idazi
    
    -- salva gli attributi opzionali   
    /*
    exec UpdAttrAzi @idazi,'Qualificazione',@QualificazioneAzi    
    exec UpdAttrAzi @idazi,'BilancioCertificato',@BilancioCertificato
    exec UpdAttrAzi @idazi,'PoliticaAmbientale',@PoliticaAmbientale
    exec UpdAttrAzi @idazi,'Certificazioni',@CertificazioniAzi
    exec UpdAttrAzi @idazi,'Numerodipendenti',@Numerodipendenti
    

    exec UpdAttrAzi @idazi,'NrFornitori',@NrFornitori
    exec UpdAttrAzi @idazi,'Ordinato',@Ordinato
    exec UpdAttrAzi @idazi,'FatturatoFornitore',@FatturatoFornitore
    exec UpdAttrAzi @idazi,'Debiti',@Debiti 
    exec UpdAttrAzi @idazi,'CapitaleNetto',@CapitaleNetto
    exec UpdAttrAzi @idazi,'RedditoOperativo',@RedditoOperativo
    
    exec UpdAttrAzi @idazi,'RisultatoNetto',@RisultatoNetto
    exec UpdAttrAzi @idazi,'CapitaleInvestito',@CapitaleInvestito
    exec UpdAttrAzi @idazi,'PatrimonioNetto',@PatrimonioNetto
    exec UpdAttrAzi @idazi,'FatturatoNettoAnnoN',@FatturatoNettoAnnoN
    exec UpdAttrAzi @idazi,'FatturatoNettoAnnoN-2',@FatturatoNettoAnnoN_2
    exec UpdAttrAzi @idazi,'FatturatoNettoAnnoN-1',@FatturatoNettoAnnoN_1
    exec UpdAttrAzi @idazi,'VolumeInvestimentiAnnoN',@VolumeInvestimentiAnnoN
    exec UpdAttrAzi @idazi,'VolumeInvestimentiAnnoN-1',@VolumeInvestimentiAnnoN_1
    exec UpdAttrAzi @idazi,'VolumeInvestimentiAnnoN-2',@VolumeInvestimentiAnnoN_2 
    
    exec UpdAttrAzi @idazi,'PAIndirizzoOp',@INDIRIZZOOp   
    exec UpdAttrAzi @idazi,'PALocalitaOp',@LOCALITAOp   
    exec UpdAttrAzi @idazi,'PAProvinciaOp',@PROVINCIAOp   
    exec UpdAttrAzi @idazi,'PACapOp',@aziCapOp   
    exec UpdAttrAzi @idazi,'PAStatoOp',@aziStatoOp   
    */


	set @merc = null


	select @merc=value 
	from ctl_doc_value
	where idheader=@idDoc
	and DZT_Name = 'Merceologia'
	and DSE_ID = 'DISPLAY_ABILITAZIONI'
	and row=0

    
    declare @merc_cod varchar(50)
    declare @idvat int
    
    if @merc is not null
    begin

		  declare crs cursor static
		  for 
		  select items from dbo.split(@merc,'###')

		  open crs

		  fetch next from crs into @merc_cod

		  while @@fetch_status=0
		  begin
        
				set @idvat = null

				-- vede se l'attributo esiste già

				select @idvat = idvat from DM_Attributi 
				where idapp=1 and lnk=@idazi and dztnome = 'ArtClasMerceologica' and vatValore_FT = @merc_cod
				
				if @idvat is null
				    exec UpdAttrAzi @idazi,'ArtClasMerceologica',@merc_cod, 2

				fetch next from crs into @merc_cod
        
		  end

		  close crs

		  deallocate crs


    end

	set @value = NULL
	select @value=value 
		from ctl_doc_value
			where idheader=@idDoc
				and DZT_Name = 'AreaGeograficaAlbo'
				and DSE_ID = 'DISPLAY_ABILITAZIONI'
				and row=0
	
	--if @value is not null
		--if @value <> ''
			--exec UpdAttrAzi @idazi,'AreaGeograficaAlbo',@value


          
    
	
END














GO
