USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SORTEGGIO_PUBBLICO_CREATE_FROM_BANDO_GARA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[SORTEGGIO_PUBBLICO_CREATE_FROM_BANDO_GARA] ( @IdDoc int  , @idUser int )
AS
BEGIN

	SET NOCOUNT ON

	declare @id INT
	declare @Errore as nvarchar(2000)
	declare @TipoBandoGara varchar(100)
	declare @DataScadenzaOfferta datetime
	declare @userRUP varchar(100)
	declare @statoFunzionaleGara varchar(1000)
	declare @IdAvviso as int
	 
	--declare @idDoc int
	--declare @idUser int
	--set @IdDoc = 87026
	--set @idUser = 45094

	set @IdAvviso = 0

	set @Id = 0
	set @Errore=''
	
	-- Provo a cercare il sorteggio pubblico collegato direttamente alla gara sulla quale mi trovo
	select @id = id
		from CTL_DOC with(nolock)
		where LinkedDoc = @IdDoc and TipoDoc = 'SORTEGGIO_PUBBLICO' and Deleted = 0

	IF @id = 0
	BEGIN

		select @id = sort.id
			from CTL_DOC invito with(nolock)
					inner join CTL_DOC avviso with(nolock) ON avviso.Id = invito.LinkedDoc
					inner join CTL_DOC sort with(nolock) ON sort.LinkedDoc = avviso.id and sort.TipoDoc = 'SORTEGGIO_PUBBLICO' and sort.Deleted = 0
			where invito.Id = @IdDoc
		
	END

	-- SE NON ESISTE UNA SORTEGGIO PUBBLICO GIA CREATO
	IF @id = 0
	BEGIN
		
		select  @TipoBandoGara = dGara.TipoBandoGara,
				@DataScadenzaOfferta = dGara.DataScadenzaOfferta,
				@userRUP = isnull(rup.[Value],''),
				@statoFunzionaleGara = gara.StatoFunzionale
			from CTL_DOC gara with(nolock)
					INNER JOIN Document_Bando dGara with(nolock) on dGara.idHeader = gara.Id 
					LEFT JOIN ctl_doc_value rup with (nolock) on gara.id = rup.idHeader and  rup.dzt_name = 'UserRup' and rup.dse_id = 'InfoTec_comune'
			where gara.Id = @IdDoc
		
		IF @TipoBandoGara = '2'	-- BANDO
		BEGIN
			set @Errore = 'Per i Bandi non e'' previsto che ci sia un sorteggio pubblico'
		END

		IF @TipoBandoGara = '1' -- AVVISO
		BEGIN

			-- CONTROLLO CHE : 
			--	1. Siano scaduti i termini per la ricezione delle manifestazioni di interesse
			--	2. Lo stato non sia chiuso
			--	3. L'utente sia il RUP

			IF @errore = '' and GETDATE() < isnull(@DataScadenzaOfferta,GETDATE()) 
			BEGIN
				set @Errore = 'Per effettuare il Sorteggio pubblico e'' necessario che si sia superata la data di termine presentazione risposte'
			END

			IF @errore = '' and @statoFunzionaleGara = 'Chiuso'
			BEGIN
				set @Errore = 'Lo stato del documento non consente di effettuare il sorteggio'
			END

			IF @errore = '' and cast( @idUser as varchar ) <> @userRUP
			BEGIN
				set @Errore = 'Utente non abilitato alla funzione'
			END

		END

		--print @DataScadenzaOfferta
		--print @errore

		IF @TipoBandoGara = '3' -- INVITO
		BEGIN

			--Se esiste un SORTEGGIO_PUBBLICO collegato con l'avviso a cui è collegato l'invito riapriamo quello
			select @id = isnull(sortPub.id,0), @IdAvviso = isnull(avviso.id,0)
				from CTL_DOC invito with(nolock)
						left join CTL_DOC avviso with(Nolock) ON avviso.Id = invito.LinkedDoc and avviso.TipoDoc = 'BANDO_GARA' and avviso.Deleted = 0 
						left join Document_Bando bAvviso with(nolock) on bAvviso.idHeader = avviso.Id and bAvviso.TipoBandoGara = '1'
						left join CTL_DOC sortPub with(nolock) on sortPub.LinkedDoc = avviso.Id and sortPub.TipoDoc = 'SORTEGGIO_PUBBLICO' and sortPub.Deleted = 0
				where invito.Id = @IdDoc

			IF @id = 0
			BEGIN

				-- CONTROLLO CHE : 
				--	1. Lo stato sia in lavorazione
				--	2. L'utente sia il RUP
				--	3. Sia presente una RICERCA_OE confermata con scelta "Sorteggio Pubblico"

				IF @errore = '' and @statoFunzionaleGara <> 'InLavorazione'
				BEGIN
					set @Errore = 'Lo stato del documento non consente di effettuare il sorteggio'
				END

				IF @errore = '' and cast( @idUser as varchar ) <> @userRUP
				BEGIN
					set @Errore = 'Utente non abilitato alla funzione'
				END

				IF @errore = '' and not exists (

					select d.id
						from CTL_DOC d  with(nolock)
								INNER JOIN CTL_DOC_Value v with(nolock) ON v.DSE_ID = 'BOTTONE' and v.DZT_Name = 'TipoSelezioneSoggetti' and v.[Value] = 'sorteggiopubblico'
						where d.LinkedDoc = @IdDoc and d.TipoDoc = 'RICERCA_OE' and d.Deleted = 0 and d.StatoFunzionale = 'Pubblicato'

				)
				BEGIN
					set @Errore = 'Per effettuare il sorteggio pubblico degli invitati e necessario aver effettuato il criterio di scelta fornitori con scelta "Sorteggio Pubblico" e confermato'
				END

			END

		END

		IF @Errore = ''
		BEGIN
			
			INSERT INTO CTL_DOC ( TipoDoc, IdPfu, idPfuInCharge, StatoFunzionale, LinkedDoc )
						 values ( 'SORTEGGIO_PUBBLICO', @idUser, @idUser, 'InLavorazione', @IdDoc )

			SET @id = SCOPE_IDENTITY()
			
			declare @azienda as int
			declare @aziProvinciaLeg3 as varchar(50)

			--recupero azienda della gara
			select @azienda = azienda from ctl_doc with (nolock) where id = @idDoc
			
			--recupero proivincia azienda ente della gara
			select @aziProvinciaLeg3=aziProvinciaLeg2 from aziende where idazi = @azienda

			insert into CTL_DOC_VALUE (IdHeader, DSE_ID, Row, DZT_Name, Value)
			values ( @id, 'NUMERO_OE', 0 , 'aziProvinciaLeg3', @aziProvinciaLeg3)


			IF @TipoBandoGara = '1' -- AVVISO
			BEGIN
				
				--Riportiamo nel documento di sorteggio gli operatori economici con una manifestazione di interesse settata come 'NON ESCLUSA'
				insert into Document_AziSortPub( idHeader, idAzi, ordinamento, idManInt )
					select @id, d.idazi, NULL, o.Id
						from CTL_DOC_Destinatari d with(nolock) 
								inner join aziende a with(nolock) on d.idazi=a.idazi and a.aziDeleted = 0
								inner join CTL_DOC o with(nolock) on o.TipoDoc = 'MANIFESTAZIONE_INTERESSE' and o.StatoDoc = 'Sended' and o.LinkedDoc = @IdDoc and d.IdAzi = o.Azienda and o.Deleted = 0
						where d.idHeader = @IdDoc and isnull(d.StatoIscrizione,'') <> 'Cancellato'
			END
			ELSE
			BEGIN	

				-- riporto tutti gli OE presenti nel documento di ricerca confermato con seleziona "Includi"
				-- SE INVITO COLLEGATO ALL'AVVISO RECUPERO ID MANIFESTAZIONE INTERESSE PER SETTARE POI PROTOCOLLO E DATA INVIO per ogni azienda
				insert into Document_AziSortPub( idHeader, idAzi, ordinamento,idManInt )
					select @id, RD.idazi, NULL, M.Id
						from  ctl_doc R with(nolock)  
							inner join CTL_DOC_Destinatari RD with(nolock) on RD.idheader = R.id and RD.Seleziona = 'includi'
							--left join CTL_DOC_Destinatari DA with(nolock) on DA.idHeader = @IdAvviso and DA.idazi = RD.idazi
							left join CTL_DOC M with(nolock) on  M.LinkedDoc = @IdAvviso and RD.IdAzi = M.Azienda and M.TipoDoc = 'MANIFESTAZIONE_INTERESSE' and M.StatoDoc = 'Sended' and M.Deleted = 0
						where R.LinkedDoc = @IdDoc and R.TipoDoc = 'RICERCA_OE' and R.Deleted = 0 and R.StatoFunzionale = 'Pubblicato'

	
			END

			-- RECUPERO IL PROTOCOLLO DELL'ULTIMO DOCUMENTO UTILE PER GLI IDAZI ESTRATTI
			--Per il protocollo la regola è la seguente:
			--1) se proviene dall'avviso è il protocollo e la data della manifestazione di interesse
			--2) se il criterio di ricerca ha espresso un albo è il protocollo dell'ultima istanza confermata con relativa data
			--3) L'ultima istanza confermata presentata su qualunque albo ( ME,fornitori,....) ,escluso lo SDA.
			--4) In assenza AziLog e data iscrizione

			CREATE TABLE #albi
			(
				albo INT
			)

			CREATE TABLE #istanzaAlbi
			(
				idInst INT,
				idAzi INT
			)

			IF @TipoBandoGara = '3'
			BEGIN

				-- RECUPERO LA LISTA DEGLI ALBI SCELTI SUI CRITERI DI RICERCA_OE. 1 ALBO PER RIGA
				INSERT INTO #albi ( albo )
					select cast( v.[Value] as int ) 
						from CTL_DOC d  with(nolock)
								INNER JOIN CTL_DOC_Value v with(nolock) ON v.DSE_ID = 'CRITERI' and v.DZT_Name = 'ListaAlbi' and ISNULL( v.[Value], '' ) <> ''
						where d.LinkedDoc = @IdDoc and d.TipoDoc = 'RICERCA_OE' and d.Deleted = 0 and d.StatoFunzionale = 'Pubblicato'

			END

			-- SE LA RICERCA NON AVEVA ESPRESSO CONDIZIONI SU UN ALBO O SE LA TIPOLOGIA DI GARA NON E' 3, PRENDO L'INSIEME DELLE ISTANZE DA TUTTI I BANDI
			IF NOT EXISTS ( select * from #albi )
			BEGIN

				INSERT INTO #albi ( albo )
					select id 
						from CTL_DOC with(nolock)
						where TipoDoc = 'BANDO' and StatoFunzionale = 'Pubblicato' and Deleted = 0

			END

			INSERT INTO #istanzaAlbi ( idInst, idAzi )
					select max(inst.id), inst.Azienda
						from #albi a
								inner join CTL_DOC inst with(nolock) ON inst.LinkedDoc = a.albo and inst.tipodoc like 'ISTANZA%' and inst.deleted = 0 and inst.statofunzionale in ( 'Confermato', 'ConfermatoParz' )
								inner join Document_AziSortPub d with(nolock) on inst.Azienda = d.idAzi 
					group by inst.id, inst.Azienda

			UPDATE Document_AziSortPub
						set protocollo = COALESCE( man.protocollo, istanze.protocollo, azi.azilog ),
							datainvio = COALESCE( man.datainvio, istanze.datainvio, azi.aziDataCreazione )
				from Document_AziSortPub sort 
						left join ctl_doc man with(nolock) on man.id = sort.idManInt and man.TipoDoc = 'MANIFESTAZIONE_INTERESSE'
						left join #istanzaAlbi i on i.idAzi = sort.idAzi 
						left join ctl_doc istanze with(nolock) on istanze.id = i.idInst 
						left join Aziende azi with(nolock) on azi.IdAzi = sort.idAzi
				WHERE idHeader = @id

		END

	END



	if @Errore=''
	begin
		select @Id as id , @Errore as Errore
	end
	else
	begin
		select 'Errore' as id , @Errore as Errore
	end


END







GO
