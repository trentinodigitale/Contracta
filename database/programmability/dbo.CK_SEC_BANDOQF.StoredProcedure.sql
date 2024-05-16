USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_SEC_BANDOQF]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROC [dbo].[CK_SEC_BANDOQF] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
AS
BEGIN


	-- verifico se la sezione puo essere aperta.


	declare @idPfu int
	declare @idPDA int
	set @idPDA = @IdDoc
	declare @Blocco nvarchar(1000)
	set @Blocco = ''

	declare @tipoDoc varchar(500)
	declare @tb varchar(50)
	declare @pg varchar(50)
	declare @Divisione_lotti varchar(50)
	declare @VisualizzaNotifiche as varchar(10)
	declare @DataScadenzaOfferta as datetime
	declare @DataAperturaOfferte as datetime
	declare @Comunicazione_Iniziativa as varchar(2)

	declare @TipoProceduraCaratteristica varchar(20)
	declare @IdAziBando as int

	declare @Conformita varchar(20)
	declare @CriterioAggiudicazioneGara varchar(20)
	declare @TipoSceltaContraente as varchar(100)

	declare @jumpcheck varchar(50)


	--aggiunto per gestire le sezioni da vedere sulle copie dei bandi fatte alla modifica del BANDO
	declare @del varchar(20)

	select @del = deleted , @IdAziBando=azienda , @tipoDoc = tipoDoc , @jumpcheck = isnull(jumpcheck,'')
		from CTL_DOC with(nolock) where id = @IdDoc

	
	
	
	
	--select 	@pg = ProceduraGara 
	--		, @tb = TipoBandoGara 
	--		, @TipoProceduraCaratteristica = TipoProceduraCaratteristica 
	--		, @Divisione_lotti  = Divisione_lotti 
	--		, @VisualizzaNotifiche=VisualizzaNotifiche
	--		, @DataScadenzaOfferta=DataScadenzaOfferta
	--		, @DataAperturaOfferte=DataAperturaOfferte
	--		, @CriterioAggiudicazioneGara = CriterioAggiudicazioneGara
	--		, @Conformita = Conformita
	--		, @TipoSceltaContraente=isnull(TipoSceltaContraente,'')
	--		, @Comunicazione_Iniziativa=ISNULL(Comunicazione_Iniziativa,'no')
	--		, @richiestoSimog = isnull(RichiestaCigSimog,'')
	--	from document_bando with(nolock)
	--	where idheader = @IdDoc

    set @Blocco = ''

	if @SectionName = 'DOC'
	begin 
		if @jumpcheck = 'Variazione_QF'
			set @Blocco = 'NON_VISIBILE'		
	end 

	if @SectionName = 'Gestione_Modifiche'
	begin 
		if @jumpcheck <> 'Variazione_QF'
			set @Blocco = 'NON_VISIBILE'		
	end 
    
    
    --set @Blocco = 'NON_VISIBILE'
    
    

	select @Blocco as Blocco

end























GO
