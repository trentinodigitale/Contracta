USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PDA_COMUNICAZIONE_CREATE_FROM_RICHIESTA_STIPULA_CONTRATTO]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD_PDA_COMUNICAZIONE_CREATE_FROM_RICHIESTA_STIPULA_CONTRATTO] 
	( @idDoc int , @IdUser int  )
AS
--Versione=2&data=2013-01-29&Attivita=40053&Nominativo=Sabato
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	set @id=0
	declare @c as INT
	declare @n as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Body as nvarchar(2000)
	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @IdPfu as INT
	declare @NumeroLotto as varchar(50)
	declare @MotivoEsclusione as nvarchar(4000)
	declare @idRow int	
	declare @idRiga int
    declare @idaziPartecipante INT
    declare @idCom INT
    declare @Descrizione as nvarchar(4000)
	declare @CriterioAggiudicazioneGara as varchar(100)
	declare @Errore as nvarchar(2000)
	declare @divisione_lotti as varchar(1)
	declare @Ruolo_Partecipante nvarchar(200)

	set @Errore=''
	
	--CREATE TABLE #TempLotti(
	--					[NumeroLotto] [varchar](200) collate DATABASE_DEFAULT NULL,
	--					[idaziPartecipante] [INT] ,
	--					Ruolo_Partecipante [nvarchar](200) 
						
	--				)  

	--metto in una tabella temporanea i destinatari della comunicazione
	CREATE TABLE #TempLotti(
			[NumeroLotto] [varchar](200) collate DATABASE_DEFAULT NULL,
			[ProtocolloRiferimento] [varchar] (200) collate DATABASE_DEFAULT ,
			[idaziPartecipante] int,
			[Ruolo_Partecipante] [varchar] (200) collate DATABASE_DEFAULT,
			[idaziRiferimento] int,
			[CodiceFiscale] [varchar] (200) collate DATABASE_DEFAULT,
			[RagSocRiferimento] [varchar] (1000) collate DATABASE_DEFAULT,
		)  
	
	--------------------------------------------------------------------------------------------------------	
	-- recupero i dati necessari alla creazione della comuniczione
	--------------------------------------------------------------------------------------------------------	
	Select 
		@IdPfu=IdPfu,
		@Fascicolo=Fascicolo,
		@ProtocolloGenerale=ProtocolloGenerale,
		@DataProtocolloGenerale=DataProtocolloGenerale,
		@ProtocolloRiferimento=ProtocolloRiferimento,
		@Body=Body,
		@azienda=azienda,
		@StrutturaAziendale=StrutturaAziendale,
		@CriterioAggiudicazioneGara=Document_PDA_TESTATA.CriterioAggiudicazioneGara,
		@divisione_lotti=divisione_lotti
	from CTL_DOC with (nolock) 
		inner join Document_PDA_TESTATA with (nolock)  on idHeader=id
		inner join document_bando on document_bando.idHeader=LinkedDoc
	where id=@idDoc



	--------------------------------------------------------------------------------------------------------	
	-- recupero gli identificativi dei lotti per i quali risulta già inviata una comunicazione RICHIESTA_STIPULA_CONTRATTO
	--------------------------------------------------------------------------------------------------------	
	select l.Value as ID_LOTTO
		into  #IdLottiRichiestaContratto
		from CTL_DOC c with (nolock) -- Comunicazione cappello
			inner join CTL_DOC d with (nolock) on d.LinkedDoc = c.id and d.TipoDoc = 'PDA_COMUNICAZIONE_GARA' and substring( d.JumpCheck , 3 , 27 ) = 'RICHIESTA_STIPULA_CONTRATTO' and d.StatoFunzionale <> 'Invalidato' 
			inner join  CTL_DOC_Value l with (nolock)  on l.idheader = d.id and l.DZT_Name = 'NumeroLotto' and l.DSE_ID = 'LOTTI'
		where c.LinkedDoc = @idDoc 
			and c.StatoFunzionale <> 'Invalidato' 
			and c.TipoDoc = 'PDA_COMUNICAZIONE' and c.Deleted=0

	--------------------------------------------------------------------------------------------------------	
	-- Recupero le info per capire se posso fare la comunicazione a meno dei lotti che gia hanno avuto RICHIESTA_STIPULA_CONTRATTO
	--------------------------------------------------------------------------------------------------------	
	--insert into #TempLotti (NumeroLotto,idaziPartecipante,Ruolo_Partecipante) 
	insert into #TempLotti
				(NumeroLotto,ProtocolloRiferimento,idaziPartecipante,Ruolo_Partecipante,idaziRiferimento,CodiceFiscale,
				RagSocRiferimento)
	
		select b.NumeroLotto,OFFERTA.protocollo,idaziPartecipante , 
					case when do.idrow is null or H.Hide <> '0' then '' else 'Mandataria' end as Ruolo_Partecipante,
					idaziPartecipante,do.codicefiscale,DO.RagSocRiferimento
			from Document_PDA_OFFERTE o with (nolock) 
					inner join ctl_doc OFFERTA with(nolock)  on OFFERTA.id=idmsg
					inner join 	Document_MicroLotti_Dettagli b with (nolock) on o.IdHeader = b.idheader and b.tipodoc = 'PDA_MICROLOTTI' and b.Voce = 0
					inner join 	Document_MicroLotti_Dettagli l with (nolock)  on o.IdRow = l.idheader and l.tipodoc = 'PDA_OFFERTE' and b.NumeroLotto = l.NumeroLotto and l.Voce = 0
					left join 	#IdLottiRichiestaContratto on ID_LOTTO=b.NumeroLotto		

					left join CTL_DOC C with(nolock) on C.tipodoc='OFFERTA_PARTECIPANTI' and c.statofunzionale='Pubblicato' and c.linkeddoc=idmsg
					left join Document_Offerta_Partecipanti DO with(nolock) on C.id = DO.IdHeader and  DO.Ruolo_Impresa in ('Mandataria') 
					cross join ( select  dbo.PARAMETRI('PDA_COMUNICAZIONE_DETTAGLI','Ruolo_Impresa','Hide','0',-1) as Hide ) as H

					where b.StatoRiga in ( 'AggiudicazioneDef', 'AggiudicazioneCond' ) and l.Posizione in ('Aggiudicatario definitivo condizionato', 'Aggiudicatario definitivo' , 'Idoneo definitivo')
						and o.idHEader=@idDoc and ID_LOTTO IS NULL
		UNION 
		--AGGIUNGO LA UNION CHE RECUPERA EVENTUALI MANDANTI O ESECUTRICI DA AGGIUNGERE ALLA COMUNICAZIONE
		select b.NumeroLotto,o.ProtocolloRiferimento, PARTECIPANTE as idaziPartecipante ,o.Ruolo_Partecipante,
					o.idaziriferimento,
					o.codicefiscale,
					o.RagSocRiferimento
			from dbo.GET_IDAZI_COMUNICAZIONE_PARTECIPANTI_RTI(@idDoc) o
					inner join 	Document_MicroLotti_Dettagli b with (nolock) on o.IdHeader = b.idheader and b.tipodoc = 'PDA_MICROLOTTI' and b.Voce = 0
					inner join 	Document_MicroLotti_Dettagli l with (nolock) on o.IdRow = l.idheader and l.tipodoc = 'PDA_OFFERTE' and b.NumeroLotto = l.NumeroLotto and l.Voce = 0
					left join 	#IdLottiRichiestaContratto on ID_LOTTO=b.NumeroLotto		
					where b.StatoRiga in ( 'AggiudicazioneDef', 'AggiudicazioneCond' ) and l.Posizione in ('Aggiudicatario definitivo condizionato', 'Aggiudicatario definitivo' , 'Idoneo definitivo')
						 and ID_LOTTO IS NULL
					

	if not exists( select NumeroLotto from #TempLotti ) 
	begin 
		
		--controllo se esiste una comunicazione in lavorazione e se esiste riapro la più vecchia
		select top 1  @id=id from ctl_doc with (nolock) where TipoDoc='PDA_COMUNICAZIONE' and substring( JumpCheck , 3 , 27 ) = 'RICHIESTA_STIPULA_CONTRATTO' and Deleted=0 and LinkedDoc=@idDoc and StatoFunzionale ='InLavorazione' order by id
	
		if @id = 0
			-- rirorna l'errore
			set @Errore = 'Non ci sono lotti nello stato AggiudicazioneDef' 

	end

	if @divisione_lotti='0'
	begin
		select @id=id from ctl_doc with (nolock) where TipoDoc='PDA_COMUNICAZIONE' and substring( JumpCheck , 3 , 27 ) = 'RICHIESTA_STIPULA_CONTRATTO' and Deleted=0 and LinkedDoc=@idDoc
		set @Errore=''
	end
	
	
	if @Errore='' and @id=0
	begin
		--------------------------------------------------------------------------------------------------------	
		---Insert nella CTL_DOC per creare la comunicazione 
		--------------------------------------------------------------------------------------------------------	
		insert into CTL_DOC 
			(IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,LinkedDoc,Azienda,StrutturaAziendale,JumpCheck)
			VALUES
			(@IdUser,'PDA_COMUNICAZIONE','Comunicazione di Richiesta Stipula Contratto',@Fascicolo,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@idDoc,@azienda,@StrutturaAziendale,'1-RICHIESTA_STIPULA_CONTRATTO' )

		set @Id = SCOPE_IDENTITY()	

		declare @RuoloNascosto as int
		declare @ModelloGriglia as varchar(200)
		set @RuoloNascosto=1
		set @ModelloGriglia='PDA_COMUNICAZIONE_DETTAGLI_Ruolo'
		select @RuoloNascosto= dbo.PARAMETRI('PDA_COMUNICAZIONE_DETTAGLI','Ruolo_Impresa','Hide','0',-1)
	
		if   @RuoloNascosto = 1
			set @ModelloGriglia='PDA_COMUNICAZIONE_DETTAGLI_SenzaRuolo'

		-- aggiungo nella ctl_doc_section_model il modello di griglia con il ruolo
		insert into CTL_DOC_SECTION_MODEL			
			( [IdHeader], [DSE_ID], [MOD_Name]	)
			values
			( @Id,'DETTAGLI',@ModelloGriglia)	

		--------------------------------------------------------------------------------------------------------	
		-- invalido precedenti comunicazioni non inviate
		--------------------------------------------------------------------------------------------------------	
		update CTL_DOC 
			set StatoFunzionale='Invalidato',StatoDoc='Invalidate' 
			where JumpCheck='1-RICHIESTA_STIPULA_CONTRATTO' and TipoDoc='PDA_COMUNICAZIONE_GARA' 
					and StatoFunzionale='InLavorazione' 
					and LinkedDoc in (Select id from CTL_DOC where LinkedDoc=@idDoc )



		declare @PrecComunicazioneEsclusione int
		set @PrecComunicazioneEsclusione = null

		--------------------------------------------------------------------------------------------------------	
		-- se esiste una comuniacazione precedente viene cambiata di stato
		--------------------------------------------------------------------------------------------------------	
		Select @PrecComunicazioneEsclusione = id 
				from CTL_DOC 
				where TipoDoc = 'PDA_COMUNICAZIONE' and 
						substring( JumpCheck , 3 , 27 ) = 'RICHIESTA_STIPULA_CONTRATTO' and 
						LinkedDoc=@idDoc and 
						StatoFunzionale='InLavorazione' and
						@Id <> id

		if @PrecComunicazioneEsclusione is not null 
		begin

			select @c = count(*) , @n = sum(case when StatoFunzionale='Invalidato' then 1 else 0 end )
				from CTL_DOC 
					where LinkedDoc = @PrecComunicazioneEsclusione
		
			if @c > @n 
				update ctl_doc set StatoFunzionale='Inviato', StatoDoc='Sended' where id=@PrecComunicazioneEsclusione
			else
				update ctl_doc set StatoFunzionale='Invalidato', StatoDoc='Invalidate' where id=@PrecComunicazioneEsclusione
	
		end 



		--------------------------------------------------------------------------------------------------------	
		---inserisco la riga per tracciare la cronologia nella PDA
		--------------------------------------------------------------------------------------------------------	
		declare @userRole as varchar(100)
		select    @userRole= isnull( attvalue,'')
			from ctl_doc d 
				left outer join profiliutenteattrib p on d.idpfu = p.idpfu and dztnome = 'UserRoleDefault'  
			where id = @id

		
		insert into CTL_ApprovalSteps 
			( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
			values ('PDA_MICROLOTTI' , @idDoc , 'PDA_COMUNICAZIONE_GARA' , 'Comunicazione di Richiesta Stipula Contratto' , @IdUser , @userRole   , 1  , getdate() )
		
		
				
	


		--------------------------------------------------------------------------------------------------------	
		-- recupero il testo della comunicazione
		--------------------------------------------------------------------------------------------------------	
		declare @Note as nvarchar(max)
		set @Note=dbo.RisolvoTemplatePDAMicrolotti(@idDoc,'1-RICHIESTA_STIPULA_CONTRATTO','AggiudicazioneDef',@CriterioAggiudicazioneGara)



		--------------------------------------------------------------------------------------------------------	
		-- creo le singole comunicazione per ogni fornitore con tutti i lotti per i quali è stato aggiudicato
		--------------------------------------------------------------------------------------------------------	
		declare @RagSocRiferimento as nvarchar(1000)
		declare @RagSocRiferimento_Rif as nvarchar(1000)
		declare @idaziRiferimento as int
		declare @NumeroDocumento as varchar(1000)
		declare @CodiceFiscale as varchar(100)
		declare @CodiceFiscaleRif as varchar(100)

		declare CurProg Cursor static for 
			-- lista dei fornitori - creiamo le singole comunicazioni
			select distinct  idaziPartecipante , Ruolo_Partecipante, ProtocolloRiferimento 
				from  #TempLotti 
					
		open CurProg

		FETCH NEXT FROM CurProg 	INTO @idaziPartecipante , @Ruolo_Partecipante, @ProtocolloRiferimento
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			set @NumeroDocumento='0'
			set @RagSocRiferimento=''
			set @CodiceFiscale=''
			set @RagSocRiferimento_Rif=''
			set @CodiceFiscaleRif=''
			--compongo in modo articolato ruolo 
			if @Ruolo_Partecipante <> ''
			begin
				
				select @RagSocRiferimento = RagSocRiferimento , @CodiceFiscale=CodiceFiscale 
						 from 
							#TempLotti 
						 where 
							idaziPartecipante = @idaziPartecipante and Ruolo_Partecipante = @Ruolo_Partecipante
							and ProtocolloRiferimento = @ProtocolloRiferimento

				if @Ruolo_Partecipante in ('Mandataria','Mandante')
				begin
					set @Ruolo_Partecipante = @RagSocRiferimento + ' - ' + @Ruolo_Partecipante
					
					if @Ruolo_Partecipante='Mandataria'
						set @NumeroDocumento = '1 - ' + @CodiceFiscale
					else
						set @NumeroDocumento = '1 - ' + @CodiceFiscale
				end
				 
				if @Ruolo_Partecipante= 'Esecutrice'
				begin
					
					select @idaziRiferimento = idaziRiferimento  
						 from 
							#TempLotti 
						 where 
							idaziPartecipante = @idaziPartecipante and Ruolo_Partecipante = @Ruolo_Partecipante
							and ProtocolloRiferimento = @ProtocolloRiferimento

					select @RagSocRiferimento_Rif = RagSocRiferimento   , @CodiceFiscaleRif = CodiceFiscale 
						 from 
							#TempLotti 
						 where 
							idaziPartecipante = @idaziRiferimento and Ruolo_Partecipante = @Ruolo_Partecipante
							and ProtocolloRiferimento = @ProtocolloRiferimento

					set @Ruolo_Partecipante = @RagSocRiferimento_Rif + ' Esecutrice di ' + @RagSocRiferimento

					set @NumeroDocumento = '3 - ' + @CodiceFiscaleRif + ' - ' + @CodiceFiscale

				end	
			end

			-- inserisco il documento per il fornitore
			insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,LinkedDoc,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,Azienda,Destinatario_Azi,Data,Note,JumpCheck , VersioneLinkedDoc) 
				select @IdUser,'PDA_COMUNICAZIONE_GARA','Comunicazione di Richiesta Stipula Contratto',@Fascicolo,@Id,
						@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,
							@idaziPartecipante,getDate()
							,@Note, '1-RICHIESTA_STIPULA_CONTRATTO'		, @Ruolo_Partecipante
			
			set @idCom = SCOPE_IDENTITY()

			--inserisco i lotti relativi al fornitore
			insert into CTL_DOC_Value 
				( IdHeader, DSE_ID, Row, DZT_Name, Value )
				select @idCom , 'LOTTI' , ROW_NUMBER() over (order by NumeroLotto) -1  , 'NumeroLotto' , NumeroLotto
					from 
						#TempLotti 
					where idaziPartecipante=@idaziPartecipante and Ruolo_Partecipante = @Ruolo_Partecipante
			
			
			--inserisco il campo per ordinamento
			insert into ctl_Doc_value
				( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] )

				values
				 
				(@idCom,'SORTEGGIO'  ,0  ,'NumeroDocumento' ,@NumeroDocumento)

	             
			FETCH NEXT FROM CurProg INTO @idaziPartecipante,@Ruolo_Partecipante,@ProtocolloRiferimento
		END 

		CLOSE CurProg
	DEALLOCATE CurProg
END


-- rirorna l'id della nuova comunicazione appena creata se non ci sono stati errori
if @Errore = ''
	begin
		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id		
	end
else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end	

END

















GO
