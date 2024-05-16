USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_COMUNICAZIONE_CREATE_FROM_ESCLUSIONE_LOTTI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[PDA_COMUNICAZIONE_CREATE_FROM_ESCLUSIONE_LOTTI] 
	( @idDoc int , @IdUser int  )
AS
--Versione=2&data=2013-01-29&Attivita=40053&Nominativo=Sabato
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
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
	declare @Ruolo_Partecipante nvarchar(100)


	--------------------------------------------------------------------------------------------------------	
	-- recupero i dati necessari alla creazione della comuniczione
	--------------------------------------------------------------------------------------------------------	
	Select @IdPfu=IdPfu,@Fascicolo=Fascicolo,@ProtocolloGenerale=ProtocolloGenerale,
		@DataProtocolloGenerale=DataProtocolloGenerale,@ProtocolloRiferimento=ProtocolloRiferimento,@Body=Body,
		@azienda=azienda,@StrutturaAziendale=StrutturaAziendale 
		from 
			CTL_DOC with (nolock)
		where id=@idDoc
	
	--------------------------------------------------------------------------------------------------------	
	---Insert nella CTL_DOC per creare la comunicazione 
	--------------------------------------------------------------------------------------------------------	
	insert into CTL_DOC 
		(IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,LinkedDoc,Azienda,StrutturaAziendale,JumpCheck)
		VALUES
		(@IdUser,'PDA_COMUNICAZIONE','Comunicazione di Esclusione Lotti',@Fascicolo,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@idDoc,@azienda,@StrutturaAziendale,'0-LOTTI_ESCLUSIONE' /*'0-ESCLUSIONE'*/ )

	set @Id = @@identity	


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
	update CTL_DOC set StatoFunzionale='Invalidato',StatoDoc='Invalidate' 
			where JumpCheck='0-LOTTI_ESCLUSIONE' and TipoDoc='PDA_COMUNICAZIONE_GARA' and 
					StatoFunzionale='InLavorazione' 
			and LinkedDoc in (Select id from CTL_DOC where LinkedDoc=@idDoc )



	declare @PrecComunicazioneEsclusione int
	set @PrecComunicazioneEsclusione = null

	--------------------------------------------------------------------------------------------------------	
	-- se esiste una comuniacazione di esclusione precedente viene cambiata di stato
	--------------------------------------------------------------------------------------------------------	
	Select @PrecComunicazioneEsclusione = id 
			from CTL_DOC with (nolock)
			where TipoDoc = 'PDA_COMUNICAZIONE' and 
					substring( JumpCheck , 3 , 16 ) = 'LOTTI_ESCLUSIONE' and 
					LinkedDoc=@idDoc and 
					StatoFunzionale='InLavorazione' and
					@Id <> id

	if @PrecComunicazioneEsclusione is not null 
	begin

		select @c = count(*) , @n = sum(case when StatoFunzionale='Invalidato' then 1 else 0 end )
			from CTL_DOC with (nolock)
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
		from ctl_doc d with (nolock)
			left outer join profiliutenteattrib p on d.idpfu = p.idpfu and dztnome = 'UserRoleDefault'  
		where id = @id

		
	insert into CTL_ApprovalSteps 
		( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
		values ('PDA_MICROLOTTI' , @idDoc , 'PDA_COMUNICAZIONE_GARA' , 'Comunicazione di Esclusione Lotti' , @IdUser , @userRole   , 1  , getdate() )
		
		
				
	--------------------------------------------------------------------------------------------------------	
	-- recupero gli identificativi dei lotti per i quali risulta già inviata una comunicazione di esclusione
	--------------------------------------------------------------------------------------------------------	
	select l.Value as ID_LOTTO
		into  #IdLottiEsclusi
		from CTL_DOC c with (nolock)-- Comunicazione cappello
			inner join CTL_DOC d with (nolock) on d.LinkedDoc = c.id and d.TipoDoc = 'PDA_COMUNICAZIONE_GARA' and d.JumpCheck = '0-LOTTI_ESCLUSIONE' and d.StatoFunzionale <> 'Invalidato' -- comunicazione per i fornitori
			inner join  CTL_DOC_Value l with (nolock) on l.idheader = d.id and l.DZT_Name = 'idRow' and l.DSE_ID = 'LOTTI'
		where c.LinkedDoc = @idDoc 
			and c.StatoFunzionale <> 'Invalidato' 
			and c.TipoDoc = 'PDA_COMUNICAZIONE'

	--metto in una tabella temporanea i destinatari della comunicazione
	CREATE TABLE #TempDestinatari_Comunicazioni(
			[ProtocolloRiferimento] [varchar] (200) collate DATABASE_DEFAULT ,
			[idaziPartecipante] int,
			[Ruolo_Partecipante] [varchar] (200) collate DATABASE_DEFAULT,
			[idaziRiferimento] int,
			[CodiceFiscale] [varchar] (200) collate DATABASE_DEFAULT,
			[RagSocRiferimento] [varchar] (1000) collate DATABASE_DEFAULT
		)  

	insert into #TempDestinatari_Comunicazioni
		(ProtocolloRiferimento,idaziPartecipante,Ruolo_Partecipante,idaziRiferimento,CodiceFiscale,RagSocRiferimento)
		
		select distinct 
					OFFERTA.protocollo,idaziPartecipante 
					, case when do.idrow is null or H.Hide <> '0' then '' else 'Mandataria' end as Ruolo_Partecipante,
					DO.IdAziRiferimento , do.CodiceFiscale, do.RagSocRiferimento
			from Document_PDA_OFFERTE o with (nolock)
				inner join ctl_doc OFFERTA with(nolock)  on OFFERTA.id=idmsg
				inner join 	Document_MicroLotti_Dettagli b with (nolock) on o.IdHeader = b.idheader and b.tipodoc = 'PDA_MICROLOTTI' and b.Voce = 0
				inner join 	Document_MicroLotti_Dettagli l with (nolock) on o.IdRow = l.idheader and l.tipodoc = 'PDA_OFFERTE' and b.NumeroLotto = l.NumeroLotto and l.Voce = 0
				left join CTL_DOC C with(nolock) on C.tipodoc='OFFERTA_PARTECIPANTI' and c.statofunzionale='Pubblicato' and c.linkeddoc=idmsg
				left join Document_Offerta_Partecipanti DO with(nolock) on C.id = DO.IdHeader and  DO.Ruolo_Impresa in ('Mandataria') 
				cross join ( select  dbo.PARAMETRI('PDA_COMUNICAZIONE_DETTAGLI','Ruolo_Impresa','Hide','0',-1) as Hide ) as H
			--where b.StatoRiga in ( 'Valutato' , 'NonGiudicabile' ) and l.StatoRiga in ( 'escluso' , 'esclusoEco' ) 
			where b.StatoRiga not in ( 'daValutare' , 'inValutazione' ) and l.StatoRiga in ( 'escluso' , 'esclusoEco', 'anomalo') 
					and o.idHEader=@idDoc 
					and l.id not in ( --- escludo dalla lista i lotti per cui già risulta una comunicazione di esclusione inviata
							select ID_LOTTO from #IdLottiEsclusi
						)
		UNION 
		
		--AGGIUNGO LA UNION CHE RECUPERA EVENTUALI MANDANTI O ESECUTRICI DA AGGIUNGERE ALLA COMUNICAZIONE
		select  
			distinct
					o.ProtocolloRiferimento, 
					PARTECIPANTE , 
					Ruolo_Partecipante ,
					o.idaziriferimento,
					o.codicefiscale,
					o.RagSocRiferimento

			from dbo.GET_IDAZI_COMUNICAZIONE_PARTECIPANTI_RTI(@idDoc) o
				inner join 	Document_MicroLotti_Dettagli b with (nolock) on o.IdHeader = b.idheader and b.tipodoc = 'PDA_MICROLOTTI' and b.Voce = 0
				inner join 	Document_MicroLotti_Dettagli l with (nolock) on o.IdRow = l.idheader and l.tipodoc = 'PDA_OFFERTE' and b.NumeroLotto = l.NumeroLotto and l.Voce = 0
			--where b.StatoRiga in ( 'Valutato' , 'NonGiudicabile' ) and l.StatoRiga in ( 'escluso' , 'esclusoEco' ) 
			where b.StatoRiga not in ( 'daValutare' , 'inValutazione' ) and l.StatoRiga in ( 'escluso' , 'esclusoEco', 'anomalo' ) 					
					and l.id not in ( --- escludo dalla lista i lotti per cui già risulta una comunicazione di esclusione inviata
							select ID_LOTTO from #IdLottiEsclusi
						)	

	declare @RagSocRiferimento as nvarchar(1000)
	declare @RagSocRiferimento_Rif as nvarchar(1000)
	declare @idaziRiferimento as int
	declare @NumeroDocumento as varchar(1000)
	declare @CodiceFiscale as varchar(100)
	declare @CodiceFiscaleRif as varchar(100)
	--------------------------------------------------------------------------------------------------------	
	-- creo le singole comunicazione per ogni fornitore con tutti i lotti per i quali è stato escluso
	--------------------------------------------------------------------------------------------------------	
	declare CurProg Cursor static for 
		-- lista dei fornitori - creiamo le singole comunicazioni
		
		--select distinct idaziPartecipante 
		--				, case when do.idrow is null or H.Hide <> '0' then '' else 'Mandataria' end as Ruolo_Partecipante
		--	from Document_PDA_OFFERTE o with (nolock)
		--		inner join 	Document_MicroLotti_Dettagli b with (nolock) on o.IdHeader = b.idheader and b.tipodoc = 'PDA_MICROLOTTI' and b.Voce = 0
		--		inner join 	Document_MicroLotti_Dettagli l with (nolock) on o.IdRow = l.idheader and l.tipodoc = 'PDA_OFFERTE' and b.NumeroLotto = l.NumeroLotto and l.Voce = 0
		--		left join CTL_DOC C with(nolock) on C.tipodoc='OFFERTA_PARTECIPANTI' and statofunzionale='Pubblicato' and linkeddoc=idmsg
		--		left join Document_Offerta_Partecipanti DO with(nolock) on C.id = DO.IdHeader and  DO.Ruolo_Impresa in ('Mandataria') 
		--		cross join ( select  dbo.PARAMETRI('PDA_COMUNICAZIONE_DETTAGLI','Ruolo_Impresa','Hide','0',-1) as Hide ) as H
		--	--where b.StatoRiga in ( 'Valutato' , 'NonGiudicabile' ) and l.StatoRiga in ( 'escluso' , 'esclusoEco' ) 
		--	where b.StatoRiga not in ( 'daValutare' , 'inValutazione' ) and l.StatoRiga in ( 'escluso' , 'esclusoEco' ) 
		--			and o.idHEader=@idDoc 
		--			and l.id not in ( --- escludo dalla lista i lotti per cui già risulta una comunicazione di esclusione inviata
		--					select ID_LOTTO from #IdLottiEsclusi
		--				)
		--UNION 
		
		----AGGIUNGO LA UNION CHE RECUPERA EVENTUALI MANDANTI O ESECUTRICI DA AGGIUNGERE ALLA COMUNICAZIONE
		--select distinct PARTECIPANTE ,Ruolo_Partecipante

		--	from dbo.GET_IDAZI_COMUNICAZIONE_PARTECIPANTI_RTI(@idDoc) o
		--		inner join 	Document_MicroLotti_Dettagli b with (nolock) on o.IdHeader = b.idheader and b.tipodoc = 'PDA_MICROLOTTI' and b.Voce = 0
		--		inner join 	Document_MicroLotti_Dettagli l with (nolock) on o.IdRow = l.idheader and l.tipodoc = 'PDA_OFFERTE' and b.NumeroLotto = l.NumeroLotto and l.Voce = 0
		--	--where b.StatoRiga in ( 'Valutato' , 'NonGiudicabile' ) and l.StatoRiga in ( 'escluso' , 'esclusoEco' ) 
		--	where b.StatoRiga not in ( 'daValutare' , 'inValutazione' ) and l.StatoRiga in ( 'escluso' , 'esclusoEco' ) 					
		--			and l.id not in ( --- escludo dalla lista i lotti per cui già risulta una comunicazione di esclusione inviata
		--					select ID_LOTTO from #IdLottiEsclusi
		--				)
		select idaziPartecipante , Ruolo_Partecipante,ProtocolloRiferimento 
			from  #TempDestinatari_Comunicazioni

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
						#TempDestinatari_Comunicazioni
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
						#TempDestinatari_Comunicazioni 
						where 
						idaziPartecipante = @idaziPartecipante and Ruolo_Partecipante = @Ruolo_Partecipante
						and ProtocolloRiferimento = @ProtocolloRiferimento

				select @RagSocRiferimento_Rif = RagSocRiferimento   , @CodiceFiscaleRif = CodiceFiscale 
						from 
						#TempDestinatari_Comunicazioni 
						where 
						idaziPartecipante = @idaziRiferimento and Ruolo_Partecipante = @Ruolo_Partecipante
						and ProtocolloRiferimento = @ProtocolloRiferimento

				set @Ruolo_Partecipante = @RagSocRiferimento_Rif + ' - Esecutrice di ' + @RagSocRiferimento

				set @NumeroDocumento = '3 - ' + @CodiceFiscaleRif + ' - ' + @CodiceFiscale

			end	
		end

		-- inserisco il documento per il fornitore
		insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,LinkedDoc,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,Azienda,Destinatario_Azi,Data,Note,JumpCheck ,VersioneLinkedDoc) 
			select @IdUser,'PDA_COMUNICAZIONE_GARA','Comunicazione di Esclusione Lotti',@Fascicolo,@Id,@Body,
					@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,@idaziPartecipante,getDate()

						,dbo.CNV('I lotti di seguito riportati risultano esclusi dalla gara per i motivi esposti','I'),
						'0-LOTTI_ESCLUSIONE' , @Ruolo_Partecipante
		
		set @idCom = @@identity
		
		--inserisco il campo per ordinamento
		insert into ctl_Doc_value
			( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] )
			values
			(@idCom,'SORTEGGIO'  ,0  ,'NumeroDocumento' ,@NumeroDocumento)

		set @idRiga = 0


		-- inserisco le note per ogni lotto escluso del fornitore
		declare CurProgLotto Cursor static for 
			
			select  l.NumeroLotto , c.Body , l.id , b.Descrizione
				from Document_PDA_OFFERTE o
					inner join 	Document_MicroLotti_Dettagli b on o.IdHeader = b.idheader and b.tipodoc = 'PDA_MICROLOTTI' and b.Voce = 0
					inner join 	Document_MicroLotti_Dettagli l on o.IdRow = l.idheader and l.tipodoc = 'PDA_OFFERTE' and b.NumeroLotto = l.NumeroLotto and l.Voce = 0
					inner join	ctl_doc c on c.tipodoc in (  'ESITO_LOTTO_ESCLUSA','ESITO_ECO_LOTTO_ESCLUSA' )  and c.StatoDoc = 'Sended' and c.StatoFunzionale = 'Confermato' and c.LinkedDoc = l.id
				--where b.StatoRiga in ( 'Valutato' , 'NonGiudicabile' ) and l.StatoRiga = 'escluso'
				where b.StatoRiga not in ( 'daValutare' , 'inValutazione' ) and l.StatoRiga in ( 'escluso' , 'esclusoEco', 'anomalo' ) 
						and o.idHEader=@idDoc 
						and o.idaziPartecipante = @idaziPartecipante
						and l.id not in ( --- escludo dalla lista i lotti per cui già risulta una comunicazione di esclusione inviata
							select ID_LOTTO from #IdLottiEsclusi
							)
				order by l.id

			-- devo escludere tutti i lotti che risultano già comunicati
		open CurProgLotto

		FETCH NEXT FROM CurProgLotto 	INTO @NumeroLotto , @MotivoEsclusione , @idRow , @Descrizione
		WHILE @@FETCH_STATUS = 0
		BEGIN

			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values ( @idCom , 'LOTTI' , @idRiga , 'NumeroLotto' , @NumeroLotto )

			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values ( @idCom , 'LOTTI' , @idRiga , 'Motivazione' , @MotivoEsclusione )

			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values ( @idCom , 'LOTTI' , @idRiga , 'Descrizione' , @Descrizione )

			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values ( @idCom , 'LOTTI' , @idRiga , 'idRow' , @idRow )

	        set @idRiga = @idRiga +1
			
			FETCH NEXT FROM CurProgLotto 	INTO @NumeroLotto , @MotivoEsclusione , @idRow , @Descrizione
		END 

		CLOSE CurProgLotto
		DEALLOCATE CurProgLotto


	             
		FETCH NEXT FROM CurProg INTO @idaziPartecipante  , @Ruolo_Partecipante, @ProtocolloRiferimento
	END 

	CLOSE CurProg
	DEALLOCATE CurProg



	--------------------------------------------------------------------------------------------------------	
	-- rirorna l'id della nuova comunicazione appena creata
	--------------------------------------------------------------------------------------------------------	
	select @Id as id

END











GO
