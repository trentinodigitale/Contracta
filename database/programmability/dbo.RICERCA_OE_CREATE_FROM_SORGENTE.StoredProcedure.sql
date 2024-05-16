USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RICERCA_OE_CREATE_FROM_SORGENTE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE  PROCEDURE [dbo].[RICERCA_OE_CREATE_FROM_SORGENTE] 
	( @idDoc int , @IdUser int , @Provenienza varchar(100)  )
AS
BEGIN
	SET NOCOUNT ON;



	declare @Id as INT
	declare @Iddoccopy as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Errore as nvarchar(2000)

	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @DataScadenza as datetime
	declare @IdPfu as INT
	declare @Jumpcheck as varchar(100)	
	declare @TipoBandoGara_Sorgente as varchar(100)	
	declare @REL_ValueInput_RicercaModello as varchar(100)	
	declare @TipoAppaltoGara as varchar(100)	
	declare @aziProvinciaLeg3 as varchar(100)
--	declare @Provenienza as varchar(100)
--	set @Provenienza='DOCUMENTOGENERICO'
--	declare @idDoc as int
--	set @idDoc=102455

	set @Errore = ''
	set @Jumpcheck=''

	if 	@Provenienza='DOCUMENTOGENERICO'
		set @Jumpcheck='DOCUMENTOGENERICO'

	if 	@Provenienza='DOCUMENTOGENERICO' and @idDoc=-1
		set @Errore = 'Effettuare salvataggio per proseguire'

	--Se proveniamo da un invito che a sua volta proviene da un avviso sul quale è già stato effettuato un sorteggio, non facciamo creare la ricerca OE ed usciamo il messaggio "Non è possibile aggiungere invitati, è già stato effettuato il sorteggio sulle manifestazioni di interesse"
	if @Errore = '' and
		exists ( 

				select invito.id
					from ctl_doc invito with(nolock)
							 inner join Document_Bando bInvito with(nolock) on bInvito.idHeader = invito.id and bInvito.TipoBandoGara = '1'
							 inner join CTL_DOC avviso with(nolock) on avviso.Id = invito.LinkedDoc and avviso.TipoDoc = 'BANDO_GARA' and avviso.Deleted = 0
							 inner join Document_Bando bAvviso with(nolock) on bAvviso.idHeader = avviso.id and bAvviso.TipoBandoGara = '3'
							 inner join CTL_DOC sort with(nolock) on sort.LinkedDoc = avviso.Id and sort.TipoDoc = 'SORTEGGIO_PUBBLICO' and sort.Deleted = 0
					where invito.Id = @idDoc and invito.TipoDoc = 'BANDO_GARA' 

			)
	begin
		set @Errore = 'Non è possibile aggiungere invitati, è già stato effettuato il sorteggio sulle manifestazioni di interesse'
	end	


	IF @Errore = '' 
	BEGIN
		
		-- se lo stato del bando è diverso da inlavorazione allora apro il documento di ricerca pubblicato
		IF ( 
				EXISTS ( 

						select id from ctl_doc where id=@idDoc and tipodoc=@Provenienza and StatoFunzionale <> 'InLavorazione'

							union

						select idmsg from tab_messaggi_fields where idmsg=@idDoc and stato<>'1' and 'DOCUMENTOGENERICO' = @Provenienza

					)
					and
					not exists( 

						select * from CTL_relations where rel_type =  'GARE_IN_MODIFICA_O_RETTIFICA' AND rel_valueoutput = 'OPEN' and REL_ValueInput = cast( @idDoc as varchar)

					)
			)

			OR

			EXISTS ( 

				--Impediamo la creazione di una nuova ricerca in presenza di una confermata se su quest'ultima il Tipo scelta soggetti è "Sorteggio pubblico" ed esiste il documento "SORTEGGIO_PUBBLICO" non cancellato.
				-- in questo caso riapriamo l'ultima confermata

				select a.id
					from CTL_DOC a with(nolock)	
							inner join CTL_DOC_Value b with(nolock) ON b.IdHeader = a.id and b.DSE_ID = 'BOTTONE' and b.DZT_Name = 'TipoSelezioneSoggetti' and b.Value = 'sorteggiopubblico'
							inner join CTL_DOC sort with(nolock) on sort.LinkedDoc = @idDoc and sort.Deleted = 0 and sort.TipoDoc = 'SORTEGGIO_PUBBLICO' 
					where a.LinkedDoc = @idDoc and a.TipoDoc = 'RICERCA_OE' and a.Deleted = 0 and a.StatoFunzionale = 'Pubblicato'

			)
		BEGIN

			--recupero id della ricerca associata al bando
			select @id=id from ctl_doc with(nolock) where linkedDoc=@idDoc and deleted=0 and TipoDoc in ( 'RICERCA_OE' ) and statoFunzionale in ( 'Pubblicato' ) 

		END
		ELSE	
		BEGIN

			-- cerco una versione precedente del documento se esiste
			set @id = null
			select @id = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'RICERCA_OE' ) and statoFunzionale in ( 'InLavorazione' )  and isnull(Jumpcheck,'')=@Jumpcheck
			select @Iddoccopy = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'RICERCA_OE' ) and statoFunzionale in ( 'Pubblicato' ) and isnull(Jumpcheck,'')=@Jumpcheck

			if @id is null and @Iddoccopy is null
			begin

				   -- altrimenti lo creo
					INSERT into CTL_DOC (IdPfu,  TipoDoc, LinkedDoc ,jumpcheck )
						VALUES (@IdUser  , 'RICERCA_OE'  ,  @idDoc , @Jumpcheck )

					set @id = SCOPE_IDENTITY()
					  
					 insert into CTL_DOC_VALUE (IdHeader, DSE_ID, Row, DZT_Name, Value)
						values ( @id, 'CRITERI', 0 , 'CARBelongTo', '1')
					
					--setto nel campo aziprovincialeg3 la proivncia dell'ente
					--recupero azienda della gara
					select @azienda = azienda from ctl_doc with (nolock) where id = @idDoc
					--recupero proivincia azienda ente della gara
					select @aziProvinciaLeg3=aziProvinciaLeg2 from aziende where idazi = @azienda

					 insert into CTL_DOC_VALUE (IdHeader, DSE_ID, Row, DZT_Name, Value)
						values ( @id, 'BOTTONE', 0 , 'aziProvinciaLeg3', @aziProvinciaLeg3)
			end

			--se esiste un documento pubblicato faccio una copia di quest'ultimo
			if @Iddoccopy > 0 and  @id is null
			begin

				   -- altrimenti lo creo
					INSERT into CTL_DOC (IdPfu,  TipoDoc, LinkedDoc,PrevDoc,Jumpcheck )
						select	@IdUser as idpfu , 'RICERCA_OE' as TipoDoc ,  LinkedDoc, @Iddoccopy ,@Jumpcheck
							from CTL_DOC
							where id = @Iddoccopy

					set @id = SCOPE_IDENTITY()


					--copio sezione TESTATA_PRODOTTI ,ATTI, InfoTec_comune  
					 insert into CTL_DOC_VALUE (IdHeader, DSE_ID, Row, DZT_Name, Value)
							select @id, DSE_ID, Row, DZT_Name, Value
								from CTL_DOC_VALUE
								where idheader=@Iddoccopy and DSE_ID='CRITERI'

			END

		END

		---VERIFICO SE DEVO AGGIUNGERE UN MODELLO SPECIFICO PER I CRITERI
		IF EXISTS ( select * from CTL_Relations with(nolock) where [REL_Type] = 'DOCUMENT_RICERCA_OE' and REL_ValueInput= 'SEZIONE_CRITERI' )
		BEGIN

			--SOLO PER DOCUMENTI IN LAVORAZIONE CHE NON HANNO IL MODELLO GIà ASSOCIATO
			IF EXISTS ( select * from ctl_doc left join CTL_DOC_SECTION_MODEL on IdHeader=id and DSE_ID = 'CRITERI' where @id=id and StatoFunzionale='InLavorazione' and MOD_Name IS NULL )
			BEGIN

				insert into CTL_DOC_SECTION_MODEL ( IdHeader,DSE_ID,MOD_Name)
					select top 1 @id,'CRITERI',REL_ValueOutput 
					from CTL_Relations with(nolock)	
					where [REL_Type] = 'DOCUMENT_RICERCA_OE' and REL_ValueInput= 'SEZIONE_CRITERI'

			END

		END

		set @TipoBandoGara_Sorgente='0'
		set @REL_ValueInput_RicercaModello = 'SEZIONE_DOCUMENT_INVITO'
		set @TipoAppaltoGara = ''
		select @TipoBandoGara_Sorgente= isnull(bAvviso.TipoBandoGara,0), @TipoAppaltoGara=bInvito.TipoAppaltoGara
					from ctl_doc invito with(nolock)
							 inner join Document_Bando bInvito with(nolock) on bInvito.idHeader = invito.id and bInvito.TipoBandoGara = '3'
							 left join CTL_DOC avviso with(nolock) on avviso.Id = invito.LinkedDoc and avviso.TipoDoc = 'BANDO_GARA' and avviso.Deleted = 0
							 left join Document_Bando bAvviso with(nolock) on bAvviso.idHeader = avviso.id --and bAvviso.TipoBandoGara = '1'
					WHERE invito.id=@idDoc
		
		--nel caso di INVITO DIRETTO APRO LA SPECIALIZZAZIONE AL TIPO APPALTO DELLA GARA
		if @TipoBandoGara_Sorgente='0'
		BEGIN
			
			--se FORNITURE
			if @TipoAppaltoGara = '1'
				set @REL_ValueInput_RicercaModello = 'SEZIONE_DOCUMENT_INVITO_FORNITURE'

			--se LAVORI
			if @TipoAppaltoGara = '2'
				set @REL_ValueInput_RicercaModello = 'SEZIONE_DOCUMENT_INVITO_LAVORI'
			
			--se SERVIZI
			if @TipoAppaltoGara = '3'
				set @REL_ValueInput_RicercaModello = 'SEZIONE_DOCUMENT_INVITO_SERVIZI'

		END

		if @TipoBandoGara_Sorgente = '1'
			set @REL_ValueInput_RicercaModello = 'SEZIONE_DOCUMENT_AVVISO_INVITO'
		
		if @TipoBandoGara_Sorgente = '2'
			set @REL_ValueInput_RicercaModello = 'SEZIONE_DOCUMENT_BANDO_INVITO'
			
		--VERIFICO SE DEVO AGGIUNGERE UN MODELLO SPECIFICO PER LA SEZIONE "DOCUMENT"
		IF EXISTS ( select * from CTL_Relations with(nolock) where [REL_Type] = 'DOCUMENT_RICERCA_OE' and REL_ValueInput= @REL_ValueInput_RicercaModello )
		BEGIN

			--SOLO PER DOCUMENTI IN LAVORAZIONE CHE NON HANNO IL MODELLO GIà ASSOCIATO
			IF EXISTS ( select * from ctl_doc left join CTL_DOC_SECTION_MODEL on IdHeader=id and DSE_ID = 'DOCUMENT' where @id=id and StatoFunzionale='InLavorazione' and MOD_Name IS NULL )
			BEGIN

				insert into CTL_DOC_SECTION_MODEL ( IdHeader,DSE_ID,MOD_Name)
					select top 1 @id,'DOCUMENT',REL_ValueOutput 
					from CTL_Relations with(nolock)	
					where [REL_Type] = 'DOCUMENT_RICERCA_OE' and REL_ValueInput= @REL_ValueInput_RicercaModello

			END

		END


	END

	if @Errore = '' and ISNULL(@id,'') <> ''
	begin

		-- rirorna l'id del doc da aprire
		select @Id as id
	
	end
	else
	begin

		-- rirorna l'errore
		if  ISNULL(@id,'') = '' and @Errore = ''
		BEGIN
			set @Errore='Non e'' stato trovato un documento di Ricerca Fornitori nel sistema.'
		END

		select 'Errore' as id , @Errore as Errore

	end
END

GO
