USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ANAC_FORM_S2]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [dbo].[ANAC_FORM_S2] ( @IdGara int, @operation varchar(100) = '', @guidOperation varchar(500) = '', @extraParam nvarchar(1000) = '' )
AS
BEGIN

	SET NOCOUNT ON

	-- SE @operation = 'INVITATI'
	--		l'output conterrà i dati per popolare la struttura 'invitatiCheNonHannoPresentatoOfferta'
	--		tramite un elaborazione lato codice. la stored tornerà solo gli invitati
	-- SE @operation = 'PARTECIPANTI'
	--		l'output conterrà i dati per popolare la struttura partecipanti
	-- SE @operation = 'LOTTI'
	--		l'output conterrà i dati per popolare il primo livello del payload. cig,dataInvito, dataScadenzaPresentazioneOfferta.
	--		dati che verranno inviati a prescindere dai partecipanti o dagli invitati. che potrebbero anche avere un insieme vuoto in caso di deserta

	-- USATA ANCHE PER LA SCHEDA S1 CON OPERATION 'LOTTI' E 'PARTECIPANTI'

	declare @AziIddsc as varchar(100)
	declare @tipoOE as varchar(1)
	declare @TipoBandoGara varchar(10)
	declare @tipoDoc varchar(100)
	declare @Divisione_lotti varchar(10)
	declare @cigmonolotto varchar(100)
	declare @dataInvito varchar(50)
	declare @dataScadenza varchar(50)

	select  @tipoDoc = g.TipoDoc,
			@TipoBandoGara = b.TipoBandoGara,
			@Divisione_lotti = b.Divisione_lotti,
			@cigmonolotto = b.CIG,
			@dataInvito = dbo.GetStrTecDateUTC(g.datainvio), --data pubblicazione
			@dataScadenza = dbo.GetStrTecDateUTC(b.DataScadenzaOfferta) 
		from ctl_doc g with(nolock)
				inner join document_bando b with(nolock) on b.idHeader = g.id
		where g.id = @IdGara


	CREATE TABLE #invitati
	(
		idAzi INT
	)

	CREATE TABLE #partecipanti
	(
		idOfferta INT,
		idAzi INT,
		numeroLotto varchar(10),
		CIG varchar(100),
		avvalimento INT NULL,
		idPartecipante varchar(1000) NULL,
		paeseOperatoreEconomico nvarchar(1000) null, --aziLocalitaLeg  
		ruoloOE_codice varchar(10) null,
		tipoOE_codice varchar(10) null,
		codiceFiscale varchar(100) null,
		denominazione nvarchar(1000) null,
	)

	CREATE TABLE #lottiGara
	(
		numeroLotto varchar(10),
		CIG varchar(100)
	)

	IF @operation = 'INVITATI'
	BEGIN

		-- Per le gare ad invito tutti gli invitati li troviamo nella Ctl_Doc_Destinatari
		IF @TipoBandoGara = '3' or @tipoDoc = 'BANDO_SEMPLIFICATO'
		BEGIN
			-- INVITATI
			INSERT INTO #invitati( idAzi )
				SELECT azi.idazi
					from Ctl_Doc_Destinatari azi with(nolock) 
					where azi.idHeader = @IdGara and isnull(azi.Seleziona, 'includi') <> 'escludi'
		END

		select cf.vatValore_FT as codiceFiscale, 
				LEFT( azi.aziRagioneSociale, 1000) as denominazione, 
				'3' as ruoloOE_codice, -- fisso a Mandataria
				isnull(ts.ValOut,'1') as tipoOE_codice
			from #invitati i
					inner join Aziende azi with(nolock) on azi.idazi = i.idAzi
					inner join DM_Attributi cf with(nolock) on cf.lnk = azi.idazi and cf.dztNome = 'codicefiscale' and cf.idApp = 1
					left join CTL_Transcodifica ts with(nolock) on ts.dztNome = 'TipoOe'and ts.ValIn = azi.aziIdDscFormaSoc
					

	END

	IF @operation = 'PARTECIPANTI'
	BEGIN

		-- OFFERTE PRESENTATE
		INSERT INTO #partecipanti( idOfferta, idAzi, numeroLotto, 
									CIG, 
									avvalimento,
									idPartecipante, paeseOperatoreEconomico,
									ruoloOE_codice, 
									tipoOE_codice, 
									codiceFiscale,
									denominazione)

			SELECT o.Id, azi.idazi, isnull(lo.NumeroLotto,'1'), 
						case when @Divisione_lotti = '0' then @cigmonolotto else lo.cig end, 
						case when avv.[value] = '1' then 1 else 0 end as avvalimento,
						lower(cast( o.[GUID] as varchar(100) )), ISNULL(azi.aziLocalitaLeg,'N/A'),
						--'1' as ruoloOE_codice, -- fisso a Mandataria
						--presenza RTI-MANDATARIA passiamo 1 altrimenti 3
						case when DO.IdRow is not null  then '1' else '3' end  as ruoloOE_codice,
						isnull(ts.ValOut,'1') as tipoOE_codice,
						cf.vatValore_FT,
						LEFT( azi.aziRagioneSociale, 1000) as denominazione
				FROM Ctl_Doc O with(nolock) 
						left join document_microlotti_dettagli lo with(nolock) on 
								lo.idheader = O.id and lo.TipoDoc =  O.TipoDoc and lo.Voce = 0 --prodotto cartesiano sui lotti per i quali si è partecipato
						inner join Aziende azi with(nolock) on azi.idazi = CAST( o.Azienda AS INT )
						left join Document_Offerta_Partecipanti DO with(nolock) on O.id = DO.IdHeader and TipoRiferimento = 'RTI' and Ruolo_Impresa = 'Mandataria' and DO.IdAzi=CAST( o.Azienda AS INT )
						inner join DM_Attributi cf with(nolock) on cf.lnk = azi.idazi and cf.dztNome = 'codicefiscale' and cf.idApp = 1
						left join CTL_Transcodifica ts with(nolock) on ts.dztNome = 'TipoOe'and ts.ValIn = azi.aziIdDscFormaSoc
						left join ctl_doc_value avv with(nolock) on avv.IdHeader = o.Id and avv.DSE_ID = 'AUSILIARIE' and avv.DZT_Name = 'RicorriAvvalimento'
				WHERE O.TipoDoc in ('OFFERTA','MANIFESTAZIONE_INTERESSE','DOMANDA_PARTECIPAZIONE') and O.linkeddoc = @IdGara and O.StatoDoc = 'Sended' 
						and O.deleted = 0 
						and (
							(O.tipodoc='OFFERTA' and lo.id  is not null)
							or
							O.tipodoc in ('MANIFESTAZIONE_INTERESSE','DOMANDA_PARTECIPAZIONE')
							)


		-----------------------------------------------------
		--- AGGIUNGIAMO EVENTUALI MANDANTI IN CASO DI RTI ---
		-----------------------------------------------------
		INSERT INTO #partecipanti( idOfferta, idAzi, numeroLotto, CIG, avvalimento,
									idPartecipante, paeseOperatoreEconomico,
									ruoloOE_codice, 
									tipoOE_codice, 
									codiceFiscale,
									denominazione )
			SELECT p.idOfferta, azi.idazi, p.numeroLotto, p.cig, 0 as avvalimento, --( per le mandanti avvalimento sempre a 0 ? )
						p.idPartecipante, ISNULL(azi.aziLocalitaLeg,'N/A'),
						'2' as ruoloOE_codice, -- fisso a Mandante
						isnull(ts.ValOut,'1') as tipoOE_codice,
						cf.vatValore_FT,
						LEFT( azi.aziRagioneSociale, 1000) as denominazione
				FROM #partecipanti p --anche per le mandanti creeremo un prodotto cartesiano sui lotti
						inner join CTL_DOC C with(nolock) on c.LinkedDoc = p.idOfferta
						inner join Document_Offerta_Partecipanti DO with(nolock) on C.id = DO.IdHeader and TipoRiferimento = 'RTI' and Ruolo_Impresa = 'Mandante'
						inner join Aziende azi with(nolock) on azi.idazi = DO.idazi
						inner join DM_Attributi cf with(nolock) on cf.lnk = azi.idazi and cf.dztNome = 'codicefiscale' and cf.idApp = 1
						left join CTL_Transcodifica ts with(nolock) on ts.dztNome = 'TipoOe'and ts.ValIn = azi.aziIdDscFormaSoc
				WHERE C.tipodoc='OFFERTA_PARTECIPANTI' and c.statofunzionale='Pubblicato' -- and c.linkeddoc = OFFERTA.ID

		select * 
			from #partecipanti
			order by numeroLotto ASC, idOfferta ASC
			--order su numero lotto o cig. è lo stesso. il chiamante lato codice lavorerà a rottura di chiave sul cig

	END --IF @operation = 'PARTECIPANTI'

	IF @operation = 'LOTTI'
	BEGIN

		-- LOTTI/CIG DELLA GARA
		IF @Divisione_lotti = '0'
		BEGIN
			-- PER LE GARE MONOLOTTO
			INSERT INTO #lottiGara( numeroLotto, cig )
							values ( '1', @cigmonolotto )
		END
		ELSE
		BEGIN
			INSERT INTO #lottiGara( numeroLotto, cig )
				select l.NumeroLotto, l.CIG
					from document_microlotti_dettagli L with(nolock) 
					where l.TipoDoc = @tipoDoc and L.voce = 0 and l.IdHeader = @IdGara
		END
		
		SELECT l.CIG, @dataInvito as dataInvito, @dataScadenza as dataScadenzaPresentazioneOfferta
			FROM #lottiGara l
			order by numeroLotto

	END --IF @operation = 'LOTTI'

	drop table #invitati
	drop table #partecipanti
	drop table #lottiGara

END








GO
