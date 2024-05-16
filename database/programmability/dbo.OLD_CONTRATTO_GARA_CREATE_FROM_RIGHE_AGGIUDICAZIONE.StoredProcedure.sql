USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CONTRATTO_GARA_CREATE_FROM_RIGHE_AGGIUDICAZIONE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[OLD_CONTRATTO_GARA_CREATE_FROM_RIGHE_AGGIUDICAZIONE] ( @idDoc int , @IdUser int  )
AS
BEGIN

	SET NOCOUNT ON

	declare @Id as int
	declare @IdCom as int
	declare @IdAggiudicatario as int
	declare @EnteAggiudicatrice as int
	declare @IdPda as int
	declare @IdBando as int
	declare @ProtocolloBando as varchar(50)
	declare @DataBando as datetime
	declare @Fascicolo as varchar(50)
	declare @DataRiferimentoInizio as datetime
	declare @DataScadenzaOfferta as datetime
	declare @ProtocolloOfferta as varchar(50)
	declare @DataOfferta as datetime
	declare @TotaleAggiudicato as float
	declare @OggettoBando as nvarchar(max)
	declare @ModelloBando as varchar(500)
	declare @ModelloContratto as varchar(4000)
	declare @IdOfferta as int
	declare @Testo as nvarchar(max)
	declare @idpfuOfferta as int
	declare @cig as varchar(100)
	declare @NumRow as int
	declare @TipoDocBando as varchar(500)
	declare @DivisioneLotti as varchar(10)

	declare @errore varchar(1000)
	declare @righeSelezionate varchar(1000)
	declare @totRipetizioni INT
	declare @Oneri as float

	SET @NumRow=1
	SET @errore = ''

	-- QUESTA MAKE DOC FROM VIENE INVOCATA CON IL PARAMETRO BUFFER, MI TROVERO' QUINDI LE RIGHE SELEZIONATE NELLA COLONNA 'A' DELLA CTL_IMPORT
	select @righeSelezionate = A from CTL_Import with(nolock) where idPfu = @IdUser

	select * into #righe_selezionate from dbo.Split( @righeSelezionate, ',')

	-----------------------------------------------------------------------------------------------------------------------------------
	-- CONTROLLO BLOCCANTE PER CONSENTIRE LA SELEZIONE DELLE SOLE RIGHE CHE FANNO PARTE DELLA STESSA GARA E DELLO STESSO FORNITORE.  --
	-----------------------------------------------------------------------------------------------------------------------------------
	SELECT @totRipetizioni = COUNT(*) FROM
		(
			select  IdAziAggiudicataria
				from Document_comunicazione_StatoLotti with(nolock)
						inner join #righe_selezionate on Id = items
				group by IdAziAggiudicataria
		) A

	IF @totRipetizioni > 1
	BEGIN
		set @errore = 'Selezionare solo righe dello stesso operatore economico'
	END

	IF @errore = ''
	BEGIN

		SELECT @totRipetizioni = COUNT(*) FROM
		(
			select b.LinkedDoc
				from Document_comunicazione_StatoLotti a with(nolock) 
						inner join ctl_doc b with(nolock) on b.Id = a.IdHeader 
						inner join #righe_selezionate on a.Id = items
				group by b.LinkedDoc
		) A

		IF @totRipetizioni > 1
		BEGIN
			set @errore = 'Selezionare solo righe della stessa procedura'
		END

	END

	IF @errore = ''
	BEGIN

		-- PARTENDO DAL PRESUPPOSTO CHE ANCHE SELEZIONANDO N RIGHE DAL VIEWER, SARANNO COMUNQUE RIGHE DELLO STESSO O.E. E DELLA STESSA PROCEDURA, PER RECUPERARMI LE INFORMAZIONI CHE MI SERVONO
		--	PRENDO QUINDI LA PRIMA TRA QUESTE ( VA BENE UNA QUALSIASI )

		select top 1 @idDoc = cast(items as int) from #righe_selezionate 

		--recupero info dal dettaglio del lotto aggiudicato
		select @IdCom=idheader,@IdAggiudicatario=IdAziAggiudicataria from Document_comunicazione_StatoLotti with(nolock) where id = @idDoc
	
	
		select @IdPda = com.linkeddoc,			--recupero IDPDA dalla comunicazione
			   @IdBando = gara.id,				--recupero IDBANDO dalla PDA
			   @TipoDocBando = gara.Tipodoc		--recupero tipodoc del bando
			from ctl_doc com with(Nolock)
					inner join ctl_doc pda with(nolock) on pda.Id = com.LinkedDoc
					inner join ctl_doc gara with(nolock) on gara.Id = pda.LinkedDoc
			where com.id=@IdCom

		-- Recupero ente che ha emesso il bando e info del bando
		select  @DataBando=DataInvio,@ProtocolloBando=Protocollo,@Fascicolo=Fascicolo,@EnteAggiudicatrice=azienda, 
				@DataRiferimentoInizio=DataRiferimentoInizio,@DataScadenzaOfferta=DataScadenzaOfferta,@DivisioneLotti =  Divisione_Lotti,
				@OggettoBando=Body,@ModelloBando=TipoBando,@cig=cig
		from ctl_doc with(nolock)
				inner join document_bando with(nolock) on id=idheader
		where id=@IdBando


		--recupero idofferta dalla tabella document_pda_offerte 
		--perchè potrebbe essere cambiata una rti e qui è aggiornato il campo idAziPartecipante
		--mentre sull'offerta è rimasta quella iniziale
		select 
			@IdOfferta = idmsg , 
			@idpfuOfferta=IdMittente ,
			@ProtocolloOfferta=ProtocolloOfferta , 
			@DataOfferta=ReceivedDataMsg			
			from 
				Document_PDA_OFFERTE with(nolock) 
			where 
				IdHeader = @IdPda and idAziPartecipante = @IdAggiudicatario
								and StatoPDA not in (99,999,1)
								 
		--recupero protocolloofferta dataofferta
		--select  @IdOfferta=Id,
		--		@idpfuOfferta=idpfu,
		--		@ProtocolloOfferta=Protocollo, 
		--		@DataOfferta = DataInvio
		--	from ctl_doc with(nolock)
		--	where TIPODOC='OFFERTA' and linkeddoc = @IdBando and Azienda = @IdAggiudicatario and statofunzionale='Inviato'
	
		--recupero totale dei lotti aggiudicati
		select	@TotaleAggiudicato=sum(Importo) 
			from (
					select distinct Importo , IdAziAggiudicataria , NumeroLotto
						from Document_comunicazione_StatoLotti with(nolock)
								inner join #righe_selezionate on Id = items
				) as a

		-- Recupero ultimo doc CONTRATTO_GARA pubblicato legato all'offerta
		set @Id = -1

		--ENRPAN
		--se devo creare il contratto vuol dire che non esiste e quindi è inutile controllare
		--esistenza; questo a patto che le righe nella vista di partenza siano quelle per cui non esiste il contratto
		--select @Id=id 
		--	from ctl_doc with(nolock) 
		--	where deleted = 0 
		--			and tipodoc='CONTRATTO_GARA' 
		--			and statofunzionale not in ('Confermato','InLavorazione','Inviata','Rifiutato') 
		--			and linkeddoc=@IdCom and Destinatario_azi=@IdAggiudicatario
	
		if @Id = -1 
		begin

			insert into CTL_DOC ( IdPfu,Titolo, TipoDoc, Azienda, Body,	ProtocolloRiferimento, Fascicolo, LinkedDoc, Destinatario_Azi ,idPfuInCharge ) 
				values ( @IdUser,'Contratto', 'CONTRATTO_GARA', @EnteAggiudicatrice ,  @OggettoBando,@ProtocolloBando, @Fascicolo, @IdCom , @IdAggiudicatario , @IdUser )   

			set @Id = SCOPE_IDENTITY()

			--inserisco una riga su ctl_doc_value con utente che ha presentato l'offerta
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value)
				values ( @Id, 'DOCUMENT', '0', 'UtenteOfferta', @idpfuOfferta)

			--inserisco la riga nella ctl_approvalStep
			insert into ctl_approvalsteps (APS_Doc_Type,APS_ID_DOC,APS_State,APS_Note,APS_Allegato,APS_UserProfile,APS_Idpfu,APS_IsOld)
				select top 1 'CONTRATTO_GARA',@Id,'Compiled','','',isnull( attvalue,''),@IdUser,0 
				from profiliutenteattrib p  with(nolock)
				where  p.idpfu = @IdUser and dztnome = 'UserRoleDefault'

			--inserisco nella CTL_DOC_VALUE i campi aggiuntivi
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value)
				values ( @Id, 'DOCUMENT', '0', 'DataBando', convert(varchar(19),@DataBando,126))

			--inserisco nella CTL_DOC_VALUE i campi aggiuntivi
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value)
				values ( @Id, 'DOCUMENT', '0', 'DataRiferimentoInizio', convert(varchar(19),@DataRiferimentoInizio ,126))

			--inserisco nella CTL_DOC_VALUE i campi aggiuntivi
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value)
				values( @Id, 'DOCUMENT', '0', 'DataScadenzaOfferta', convert(varchar(19),@DataScadenzaOfferta  ,126))

			--inserisco nella CTL_DOC_VALUE i campi aggiuntivi
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value)
				values ( @Id, 'DOCUMENT', '0', 'ProtocolloOfferta', @ProtocolloOfferta )

			--inserisco nella CTL_DOC_VALUE i campi aggiuntivi
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value)
				values ( @Id, 'DOCUMENT', '0', 'DataRisposta', convert(varchar(19),@DataOfferta  ,126)  )

			--inserisco nella CTL_DOC_VALUE i campi aggiuntivi
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value)
				values ( @Id, 'CONTRATTO', '0', 'NewTotal', str(@TotaleAggiudicato,20,5) )
			
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value)
				select @Id, 'CONTRATTO', '0', 'FascicoloSecondario', FascicoloSecondario 
					from Document_dati_protocollo where idHeader=@IdBando
			
			--recuperiamo NRDeterminazione e DataDetermina dalla PDA (Document_PDA_TESTATA) e li riportiamo sul contratto
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value)
				select @Id, 'CONTRATTO', '0', 'NRDeterminazione', NRDeterminazione 
					from Document_PDA_TESTATA where idHeader=@IdPda
			
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value)
				select @Id, 'CONTRATTO', '0', 'DataDetermina', convert( varchar(19),DataDetermina,126 )   
					from Document_PDA_TESTATA where idHeader=@IdPda and isnull(DataDetermina,'') <>''
			
			

			--EP:att. 457961 commentato perchè gestito tramite la relazione DEFAULT_CONTRATTO_GARA_DOCUMENTAZIONE
			--insert into CTL_DOC_ALLEGATI (idHeader,Descrizione,NotEditable,Obbligatorio,FirmeRichieste)
			--	select @Id,'Contratto',' Descrizione , FirmeRichieste ','1','ente_oe'
			
			--INSERISCO LE RIGHE DI DFAULT NELLA SEZIONE DOCUMENTAZIONE TRAMITE UNA RELAZIONE
			exec INIT_DOCUMENTI_CONTRATTO  @Id, @IdUser 
			
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value)
				values ( @Id, 'TESTATA_PRODOTTI', '0', 'ModelloBando', @ModelloBando )

			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value)
				values ( @Id, 'RIGHE_AGGIUDICAZIONE_VIEWER', '0', 'RigheSelezionate', @righeSelezionate )

			set @ModelloContratto = 'MODELLI_LOTTI_' + @ModelloBando + '_MOD_SCRITTURA_PRIVATA'

			--inserisco il modello da utilizzarte
			insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name)
				values	( @Id , 'BENI' , 	@ModelloContratto )	

			--determino nel caso non a lotti se ho righe multiple (voce 0,1,ecc...) oppure no (solo voce 0)
			if @DivisioneLotti='0'
			begin
			  select @NumRow = count(*) from document_microlotti_dettagli with (nolock) where idheader=@IdBando and tipodoc=@TipoDocBando 
			end
			

			declare @idRow INT
			declare @NewIdRow INT

			declare CurProg Cursor Static for 
					select DMDO.id as idrow 
						from document_pda_offerte DPO with(nolock)
								inner join DOCUMENT_MICROLOTTI_DETTAGLI DMDO with(nolock) on DPO.idrow=DMDO.idheader and DMDO.TipoDoc='PDA_OFFERTE'  
						where 
							DPO.idheader=@IdPda and DPO.idazipartecipante=@IdAggiudicatario
								and
									( NumeroLotto in ( 
														select distinct NumeroLotto
															from Document_comunicazione_StatoLotti with(nolock)
																	inner join #righe_selezionate on Id = items 
													  )

										or @DivisioneLotti = '0'
									)
			
								and  
									( ( @DivisioneLotti = '0' and ( ( voce <> 0 and @NumRow <> 1) or ( voce = 0 and @NumRow=1) ) ) or @DivisioneLotti <> '0' )
			

			open CurProg

			FETCH NEXT FROM CurProg INTO @idrow

			WHILE @@FETCH_STATUS = 0
			BEGIN

				INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc )
					select @id , 'CONTRATTO_GARA' as TipoDoc

				set @NewIdRow = scope_identity()

				-- ricopio tutti i valori
				exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@idrow  , @NewIdRow, ',Id,IdHeader,TipoDoc,CODICE_REGIONALE'

				--se divisione_lotti =0 aggiorno il cig
				if @DivisioneLotti = '0' 
				BEGIN
					update Document_MicroLotti_Dettagli set cig = @cig where id=@NewIdRow
				END

				FETCH NEXT FROM CurProg INTO @idrow

			END 

			CLOSE CurProg
			DEALLOCATE CurProg

			---- SE NON HO IL NUMERORIGA SU TUTTE LE RIGHE, LO RICALCOLO
			--IF EXISTS ( select id from Document_MicroLotti_Dettagli with(nolock) where idheader = @Id and tipodoc = 'CONTRATTO_GARA' and numeroriga is null )
			--BEGIN

			--	SELECT	D1.id as id_microlotti,
			--			ROW_NUMBER() OVER(ORDER BY D1.id ASC) AS Row# INTO #temp
			--		from Document_MicroLotti_Dettagli D1 with(nolock)
			--		where D1.IdHeader = @Id and tipodoc = 'CONTRATTO_GARA'
			--		order by D1.id
		
			--	update Document_MicroLotti_Dettagli 
			--			set NumeroRiga=Row#
			--		from Document_MicroLotti_Dettagli with(nolock)
			--				inner join #temp  on id=id_microlotti
			--		where IdHeader=@Id

			--	drop table #temp

			--END
			--select @DivisioneLotti
			IF @DivisioneLotti = '1'
			BEGIN

				insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value)
							select 	@Id, 'LOTTO_VOCI_INIZIALI', isnull(voce,0), 'lotto_voce', isnull(NumeroLotto,'')
							from Document_MicroLotti_Dettagli with(nolock)
							where IdHeader = @id and TipoDoc = 'CONTRATTO_GARA'

			END
			ELSE
			BEGIN

				insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value)
							select 	@Id, 'NUMERORIGA_INIZIALE', 0, 'NumeroRiga', NumeroRiga
							from Document_MicroLotti_Dettagli with(nolock)
							where IdHeader = @id and TipoDoc = 'CONTRATTO_GARA'

			END

			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value)
								values ( @Id, 'CONTRATTO', 0, 'Divisione_Lotti', @DivisioneLotti )
			
			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value)
								values ( @Id, 'CONTRATTO', 0, 'Modello', @ModelloContratto )

			
			--setto a 1 presenzalistino di default
			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value)
								values ( @Id, 'CONTRATTO', 0, 'PresenzaListino', 1 )

			

			--recupero oneri sommando il campo IMPORTO_ATTUAZIONE_SICUREZZA sulle voci 0
			select @Oneri=SUM (ISNULL(IMPORTO_ATTUAZIONE_SICUREZZA,0))
				from Document_MicroLotti_Dettagli 
				where IdHeader = @Id and TipoDoc='CONTRATTO_GARA'
				
			--inserisco nella CTL_DOC_VALUE il campo oneri
			insert into CTL_DOC_Value
				( IdHeader, DSE_ID, Row, DZT_Name, Value)
				values
				( @Id, 'CONTRATTO', '0', 'Oneri', str(@Oneri,20,5) )

			
			
			
				
		end
	
	END

	
	IF @Errore = ''
	BEGIN
		select @Id as id
	END
	ELSE
	BEGIN
		select 'Errore' as id , @Errore as Errore
	END

END












GO
