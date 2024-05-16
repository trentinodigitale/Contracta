USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Insert_Document_QUESTIONARIO_FORNITORE]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE  PROCEDURE [dbo].[Insert_Document_QUESTIONARIO_FORNITORE] 
	( @idDoc int , @IdUser int,@AreaValutazione as varchar(100),@titolo varchar(100)
	   , @idbando as int, @idazi as int , @istestata int, @idaziForn as int, @cnt as int  )
AS
BEGIN
    
    declare @Id as INT
    declare @aziragionesociale varchar(300)
    declare @myTitolo varchar(600)
    declare @myTitolo1 nvarchar(150)
    declare @cntStr varchar(10)
    declare @pfue_mail nvarchar(500)
    declare @idAzi2 int
    declare @ragsoc nvarchar(80)
    declare @ML_Description nvarchar(300)
    declare @Merceologia varchar(5000)
    
    set @cntStr=cast(@cnt as varchar)
    
    select @aziragionesociale=aziragionesociale
    from aziende
    where idazi=@idaziForn

    set @ML_Description = null
    
    select @ML_Description = case when ML_Description  is null then DMV_DescML else ML_Description end
			from LIB_DomainValues 
		  left outer join LIB_Multilinguismo on DMV_DescML = ml_key and ml_lng='I'
		 where dmv_dm_id = 'AreaValutazione'
				and dmv_cod = @AreaValutazione

    if @ML_Description is null
	   set @ML_Description = @AreaValutazione

    
    --set @myTitolo1 = 'Questionario Fornitore - ' + @aziragionesociale + ' - Area Valutazione ' + @AreaValutazione
    --set @myTitolo = 'Questionario Fornitore - ' + @aziragionesociale + ' - Area Valutazione ' + @AreaValutazione + ' - ' + @titolo

    set @myTitolo1 = 'Questionario Fornitore - ' + @aziragionesociale + ' - Area Valutazione ' + @ML_Description
    set @myTitolo = 'Questionario Fornitore - ' + @aziragionesociale + ' - Area Valutazione ' + @ML_Description + ' - ' + @titolo
    
    -------------------------------------------------------------
    -- genera il documento per l'area di valutazione di input
    -------------------------------------------------------------
    
    -- inserisce nella CTL_DOC
    INSERT into CTL_DOC (
	IdPfu,  TipoDoc, 
	Titolo, Body, Azienda, StrutturaAziendale, 
	ProtocolloRiferimento, Fascicolo, LinkedDoc, Destinatario_User, 
	Destinatario_Azi,protocollo,NumeroDocumento )
	   select 
		   @IdUser  , 'QUESTIONARIO_FORNITORE'   ,  
		   @myTitolo1, @myTitolo , 
		   azienda , StrutturaAziendale, 
		   ProtocolloRiferimento, Fascicolo, @idbando , 
		   null, @IdAzi,protocollo + '-' + @cntStr,@idDoc
		   
	   from CTL_DOC		   
	   where id = @idDoc

	   set @id = @@identity

	-- riporta la stessa merceologia dell'istanza selezionata dal fornitore
	select @Merceologia = Merceologia 
	from DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi
	where idheader = @idDoc

    -- inserisce nella DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi
    -- i dati anagrafici + l'area di valutazione ed il punteggio
    insert into dbo.DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi
    (idHeader, RagSoc, PIVA, INDIRIZZOLEG, LOCALITALEG, PROVINCIALEG, aziStatoLeg, aziCapLeg, QualificazioneAzi, BilancioCertificato, PoliticaAmbientale, CertificazioniAzi, Numerodipendenti, NrFornitori, Ordinato, FatturatoFornitore, Debiti, CapitaleNetto, RedditoOperativo, INDIRIZZOOp, LOCALITAOp, PROVINCIAOp, aziStatoOp, aziCapOp, AreaValutazione, Punteggio,IsTestata,RisultatoNetto,CapitaleInvestito,PatrimonioNetto,FatturatoNettoAnnoN,FatturatoNettoAnnoN_2,FatturatoNettoAnnoN_1,VolumeInvestimentiAnnoN,VolumeInvestimentiAnnoN_1,VolumeInvestimentiAnnoN_2, Merceologia )
    
    select @id, RagSoc, PIVA, INDIRIZZOLEG, LOCALITALEG, PROVINCIALEG, aziStatoLeg, aziCapLeg, QualificazioneAzi, BilancioCertificato, PoliticaAmbientale, CertificazioniAzi, Numerodipendenti, NrFornitori, Ordinato, FatturatoFornitore, Debiti, CapitaleNetto, RedditoOperativo, INDIRIZZOOp, LOCALITAOp, PROVINCIAOp, aziStatoOp, aziCapOp, @AreaValutazione, -1,@istestata,RisultatoNetto,CapitaleInvestito,PatrimonioNetto,FatturatoNettoAnnoN,FatturatoNettoAnnoN_2,FatturatoNettoAnnoN_1,VolumeInvestimentiAnnoN,VolumeInvestimentiAnnoN_1,VolumeInvestimentiAnnoN_2,@Merceologia 
    from DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi
    where idHeader = @idDoc

    -- inserisce nella Document_Bando_DocumentazioneRichiesta i documenti
    -- eventuali aggiunti dal fornitore ovvero quelli senza area valutazione nel caso di testata
    -- altrimenti i documenti di quella area input
    if @istestata = 1
    begin
	   insert into Document_Bando_DocumentazioneRichiesta
	   (idHeader, TipoInterventoDocumentazione, LineaDocumentazione, DescrizioneRichiesta, AllegatoRichiesto, Obbligatorio, TipoFile, AnagDoc, NotEditable, AreaValutazione, Punteggio,datascadenza,peso,tipovalutazione,emas)
        
	   select @id, TipoInterventoDocumentazione, LineaDocumentazione, DescrizioneRichiesta, AllegatoRichiesto, Obbligatorio, TipoFile, AnagDoc, NotEditable, '', -1,datascadenza,1,tipovalutazione,emas
	   from Document_Bando_DocumentazioneRichiesta
	   where idheader=@idDoc and isnull(areavalutazione,'')=''


	   -- inserisce i dati del testo istanza solo per il documento di testata
	   insert into [dbo].[CTL_DOC_Value]
			(IdHeader, DSE_ID, Row, DZT_Name, Value)

		select @id, DSE_ID, Row, DZT_Name, Value
			from [dbo].[CTL_DOC_Value]
			where idheader = @idDoc
	end	   
    else
    
	   insert into Document_Bando_DocumentazioneRichiesta
	   (idHeader, TipoInterventoDocumentazione, LineaDocumentazione, DescrizioneRichiesta, AllegatoRichiesto, Obbligatorio, TipoFile, AnagDoc, NotEditable, AreaValutazione, Punteggio,datascadenza,peso,tipovalutazione,emas)
        
	   select @id, TipoInterventoDocumentazione, LineaDocumentazione, DescrizioneRichiesta, AllegatoRichiesto, Obbligatorio, TipoFile, AnagDoc, NotEditable, @AreaValutazione, -1,datascadenza,peso,tipovalutazione,emas
	   from Document_Bando_DocumentazioneRichiesta
	   where idheader=@idDoc and isnull(areavalutazione,'')= @AreaValutazione
	   	   	 

    -- per ogni utente associato all'area valutazione inserisce la civetta nella CTL_MAIL
    declare @idpfu  int
	declare @conta int

	set @conta = 0
    
    DECLARE crs CURSOR FOR SELECT 
		  a.idpfu,isnull(b.pfue_mail,''),pfuidazi,aziRagioneSociale
		  from profiliutenteattrib a
		  inner join profiliutente b on a.idpfu=b.idpfu		  
		  inner join aziende on idazi=pfuidazi
    where dztnome='AreaValutazione' 
		  and attvalue=@AreaValutazione
		  --and isnull(pfue_mail,'')<>''


	OPEN crs

    FETCH NEXT FROM crs INTO @idpfu,@pfue_mail,@idAzi2,@ragsoc


    -- per ogni riga 
    WHILE @@FETCH_STATUS = 0
    BEGIN

		set @conta = @conta + 1
	
	   if @pfue_mail <> ''
		  insert into ctl_mail
		  (IdDoc, IdUser, TypeDoc, State)
		  values
		  (@id,@idpfu,'QUESTIONARIO_FORNITORE_MAIL','0')
		  
	   
	   -- inserisce nella dbo.CTL_DOC_Destinatari
	   insert dbo.CTL_DOC_Destinatari
	   (idHeader,IdPfu,IdAzi,aziRagioneSociale)
	   values 
	   (@id,@idpfu,@idAzi2,@ragsoc)
	   
    
	   FETCH NEXT FROM crs INTO @idpfu,@pfue_mail,@idAzi2,@ragsoc
    end	

    CLOSE crs
    DEALLOCATE crs


	if @conta > 0
		-- aggiorna sul bando il contatore dei quesiti ricevuti (solo se ci sono utenti associati al questionario)
		update Document_Bando 		
			set  ReceivedQuesiti = isnull( ReceivedQuesiti , 0 ) + 1 
			where idHeader = @idbando
	
	

end

















GO
