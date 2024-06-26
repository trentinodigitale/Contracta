USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_PDA_MICROLOTTI_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[CK_PDA_MICROLOTTI_CREATE_FROM_BANDO] 
	( @idDoc int , @IdUser int  )
AS
BEGIN

	SET NOCOUNT ON
	
	declare @Errore as nvarchar(2000)
	declare @IdCommissione as int
	declare @Fascicolo as nvarchar(50)
	declare @statofunzionale_bando as nvarchar(500)
	declare @IdDocBando as varchar(50)
	declare @DataAperturaOfferte as datetime
	declare @TipoDoc  varchar(250)		

	declare @TipoBandoGara varchar(500)
	declare @ProceduraGara varchar(500)
	declare @consenti_accesso_per_ruolo as nvarchar(200)
	declare @TipoProceduraCaratteristica as varchar(50)

	set @Errore = ''
	set @IdCommissione = -1
	
	BEGIN TRY  

		-- SFRUTTO QUESTA STORED PER CREARE IL MODELLO DA UTILIZZARE PER LA LISTA OFFERTA (CON RELATIVI DATI) ALL'INTERNO DELLA PDA
		-- INSERISCO LA GENERAZIONE QUI PERCHE' QUESTA E' UNA STORED CHE VIENE INVOCATA PRIMA DELL'APERTURA DELLA PDA
		EXEC GENERA_MODELLO_PDA_OFFERTE @idDoc

	END TRY  
	BEGIN CATCH  
	END CATCH

	--recupero le info dal bando
	SELECT    @DataAperturaOfferte = CAST(DataAperturaOfferte AS DATETIME) , 
			  @TipoDoc = TipoDoc,
			  @TipoBandoGara = TipoBandoGara,
			  @ProceduraGara = ProceduraGara,
			  @statofunzionale_bando=StatoFunzionale ,
			  @TipoProceduraCaratteristica = TipoProceduraCaratteristica				
		FROM  ctl_doc with(nolock)
				INNER JOIN document_bando with(nolock) ON id = idheader
		WHERE idheader = @idDoc

	if @DataAperturaOfferte = '1900-01-01 00:00:00.000' 
		set @DataAperturaOfferte = getdate()

	select @consenti_accesso_per_ruolo=dbo.PARAMETRI('CONSENTI_ACCESSO_PDA','RUOLO_COMMISSIONE','VALORE','','-1')
	--1 Controllo che data apertura buste sia superata
	IF datediff(s,@DataAperturaOfferte,getdate()) < 0 and @TipoProceduraCaratteristica <> 'RFQ'
	BEGIN
		
		IF @TipoBandoGara = '2' AND @ProceduraGara = '15477'
			set @Errore = 'Creazione Prequalifica non possibile. La data di apertura delle buste non è stata superata.'
		ELSE
			set @Errore = 'Creazione PDA non possibile. Data apertura buste non superata.'

	END
	
	if @Errore='' and ( @statofunzionale_bando='Sospeso' or @statofunzionale_bando='InSospensione')
	BEGIN
		if @TipoProceduraCaratteristica = 'RFQ' 
			set @Errore = 'Creazione VdO non possibile. Terminare la Sospensione Procedura in corso.'		
		else IF @TipoBandoGara = '2' AND @ProceduraGara = '15477'
			set @Errore = 'Creazione Prequalifica non possibile. Terminare la Sospensione Procedura in corso.'
		ELSE
			set @Errore = 'Creazione PDA non possibile. Terminare la Sospensione Procedura in corso.'		
	END


	if @Errore=''
	begin
		
		if  @TipoProceduraCaratteristica = 'RFQ'
				select @IdCommissione = -1
		else
		if @proceduragara in ('15583','15479')   --AFFIDAMENTO E RDP
		begin
			select @IdCommissione = -100
		end
		else
		begin		
			--recupero documento commissione se esiste
			select @IdCommissione=ID from ctl_doc with (nolock) where linkedDoc=@idDoc and tipodoc='commissione_pda' and statofunzionale='pubblicato'  and substring( JumpCheck , 1 , len( @TipoDoc )  ) = @TipoDoc 
		end

		if @IdCommissione <> -1
		begin
			
			declare @PI_approvazione_diretta varchar(10)
			select @PI_approvazione_diretta =  dbo.PARAMETRI('BANDO_GARA','APPROVE','PI_DIRECT_APPROVE','',-1)
			
			--2 Controllo se l'utente collegato è il presidente commissione A 
			IF @TipoBandoGara = '2' AND @ProceduraGara = '15477'
				set @Errore = 'Creazione Prequalifica non possibile. Utente non abilitato'
			ELSE
			begin
				if @PI_approvazione_diretta = 'YES' and (@ProceduraGara = '15583' or @ProceduraGara = '15479' or @ProceduraGara = '15585')
					set @Errore = ''
				else
					set @Errore = 'Creazione PDA non possibile. Utente non abilitato'
			end
			
			--Controllo se l'utente collegato è il presidente commissione A oppure RUP per le gare informali											   
			if @proceduragara in ('15583','15479')
			begin

				if exists (select * from ctl_doc_value with (nolock) where IdHeader=@idDoc  and DSE_ID='InfoTec_comune' and DZT_Name='UserRUP' and value=@IdUser)
					set @Errore =''
			end
			else 
			if exists(select UtenteCommissione from	Document_CommissionePda_Utenti with (nolock) where idheader=@IdCommissione and ruolocommissione='15548' and TipoCommissione='A' and UtenteCommissione=@IdUser)
			begin

				set @Errore =''

			end
			


			if @Errore <> ''
			begin

				-- se esiste la PDA
				if exists (select id from ctl_doc with (nolock) where linkeddoc=@idDoc and tipodoc='PDA_MICROLOTTI' and deleted=0 and substring( JumpCheck , 1 , len( @TipoDoc )  ) = @TipoDoc )
				begin


						--3. Controllo se l'utente collegato è il presidente commissione B 	
						if exists(select UtenteCommissione from	Document_CommissionePda_Utenti with (nolock) where idheader=@IdCommissione and ruolocommissione='15548' and TipoCommissione in('G','C') and UtenteCommissione=@IdUser)			
						begin

							
							--4 Se esiste la PDA per il presid B controllo se è stata superata la fase amministrativa
							IF @TipoBandoGara = '2' AND @ProceduraGara = '15477'
								set @Errore = 'Creazione Prequalifica non possibile. Utente non abilitato'
							ELSE
								set @Errore ='Apertura PDA non possibile. La fase amministrativa non superata'
							
							-- se la fase della PDA diversa da Verfica Amministrativa ok
							if exists (select id from ctl_doc with (nolock) where linkeddoc=@idDoc and tipodoc='PDA_MICROLOTTI' and deleted=0 and substring( JumpCheck , 1 , len( @TipoDoc )  ) = @TipoDoc and statofunzionale<>'VERIFICA_AMMINISTRATIVA')
								set @Errore =''


						end


						-- se sei un utente che è presente nei riferimenti del bando con ruolo Bando/Inviti 
						-- oppure sei il rup del procedimento
						-- oppure un utente della commissione 
						-- puoi accedere						
						if @Errore <> ''						
							if	exists(  select idheader from document_bando_riferimenti with (nolock) where idheader = @idDoc and  ruoloriferimenti = 'Bando' and idPfu = @IdUser )
									or 
								exists (select idrow from ctl_doc_value with (nolock) where IdHeader=@idDoc  and DSE_ID='InfoTec_comune' and DZT_Name='UserRUP' and value=@IdUser)
									or 
								exists ( select idrow from Document_CommissionePda_Utenti with (nolock) where IdHeader=@IdCommissione  and UtenteCommissione=@IdUser  )
							begin
								set @Errore =''
							end

						--SE RICHIESTO dal parametro E NON HO ERRORI PRECEDENTI faccio la verifica del ruolo della commissione
						if @Errore = ''	and @consenti_accesso_per_ruolo <> ''
						BEGIN
							if	not exists(  select idheader from document_bando_riferimenti with (nolock) where idheader = @idDoc and  ruoloriferimenti = 'Bando' and idPfu = @IdUser )
									and  
								not exists (select idrow from ctl_doc_value with (nolock) where IdHeader=@idDoc  and DSE_ID='InfoTec_comune' and DZT_Name='UserRUP' and value=@IdUser)
									and  
								not exists ( select idrow from Document_CommissionePda_Utenti with (nolock) where IdHeader=@IdCommissione  and UtenteCommissione=@IdUser and RuoloCommissione  in ( @consenti_accesso_per_ruolo ) )
							begin
								set @Errore ='Apertura PDA non possibile. Il Ruolo della Commissione non consente l''apertura'
							end
						END
						
					
						
						
				end
			end
		end
	end	
	

	if @Errore = ''
	begin
		-- rirorna OK
		select 'OK' as id , '' as Errore

	end
	else
	begin
		-- rirorna l'errore
		select 'ERRORE' as id , @Errore as Errore
	end
SET NOCOUNT OFF
END






GO
