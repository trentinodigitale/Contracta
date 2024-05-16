USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_SP_DELTA_TED_Set_Aggiudicatari]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[OLD2_SP_DELTA_TED_Set_Aggiudicatari] ( @newIdLotto int, @IdDoc as int, @idGara int ,  @lotto varchar(max) , @cig varchar(50) , @Contesto varchar(200), @IdContesto int   )
as
BEGIN
	
	declare @Mandataria as int
	declare @IdMsgOfferta as int
	declare @TipoAggiudicazione as varchar(100)
	declare @IdLottoPDA as int
	declare @IdPda as int

	declare  @TempMandatarie table
			( 
			idazi  int
			)

	--recupero tipo gara mon/multi aggiuidcatari
	set @TipoAggiudicazione='monofornitore'
	--select 
	--	@TipoAggiudicazione=isnull(TipoAggiudicazione,'') 
	--	from 
	--		document_bando with (nolock)
	--	where
	--		idheader = @idGara 
	select 
			@TipoAggiudicazione=isnull(TipoAggiudicazione,'') 
		from 
			BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO 
		where 
			idBando = @idGara and n_lotto = @lotto

	if @TipoAggiudicazione = ''
		set @TipoAggiudicazione = 'monofornitore'
	

	--recupero id lotto pda microlotti
	select 	
			@IdLottoPDA = DETT_PDA.id,
			@IdPda = IdHeader
		from
			document_microlotti_dettagli DETT_PDA with (nolock)
				inner join ctl_doc PDA with (nolock) on PDA.id = DETT_PDA.idheader and PDA.tipodoc=DETT_PDA.Tipodoc and PDA.Deleted=0
		where
			DETT_PDA.Tipodoc='PDA_MICROLOTTI' and NumeroLotto = @lotto and CIG = @cig and Voce = 0

	--recupero aggiudicatario
	if @Contesto='CONVENZIONE'
	begin
		
		if @TipoAggiudicazione = 'monofornitore'
		begin
				insert into @TempMandatarie
						(idazi)
					select mandataria from document_convenzione with (nolock) where id=@IdContesto

		end
		else
		begin
			
			--conservo le aggiudicatarie in @TempMandatarie
			insert into @TempMandatarie
						(idazi)
			select 
					Aggiudicata 
				from
					ctl_doc gr with (nolock)	
						left join Document_microlotti_dettagli aggiud with(nolock) ON aggiud.IdHeader = gr.Id and aggiud.TipoDoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE'
				where
					gr.LinkedDoc = @IdLottoPDA and gr.TipoDoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE' and gr.StatoFunzionale = 'Confermato'		
					and aggiud.Posizione in ('','Idoneo provvisorio')
		
			

		end
	end
	else
	begin
		--contratto-gara
		insert into @TempMandatarie
						(idazi)
			select Destinatario_Azi from ctl_doc with (nolock) where id=@IdContesto
	end

	--metto in una tabella temp idmsg delle offerte associate agli aggiudicatari
	select 	
			IdMsgFornitore into #TempIdMsg
		from
			document_pda_offerte O_PDA with (nolock) 
				inner join Document_MicroLotti_Dettagli LO on LO.idheader = O_PDA.idrow and LO.TipoDoc='PDA_OFFERTE' and LO.NumeroLotto = @lotto and LO.Voce = 0
		where
			O_PDA.idheader = @IdPda and O_PDA.idAziPartecipante in ( select idazi from @TempMandatarie )

	
	--metto in una temp l'azienda mandataria + eventuali aziende in caso di rti
	select 
		V.Idazi into #tempAzi
		from 
		(
			select 
				Idazi from @TempMandatarie
			union
				select DO.idazi 
					from 
						ctl_doc OFFERTA with(nolock) 
							inner join CTL_DOC C with(nolock) on C.tipodoc='OFFERTA_PARTECIPANTI' and c.statofunzionale='Pubblicato' and c.linkeddoc=OFFERTA.ID
							inner join Document_Offerta_Partecipanti DO with(nolock) on C.id = DO.IdHeader and TipoRiferimento = 'RTI'
					where 
						OFFERTA.id  in ( select * from #TempIdMsg )
		) V


	INSERT INTO Document_TED_Aggiudicatari 
		( [idHeader], [IdDoc], 
		[TED_AWARDED_IS_SME], [TED_NATIONALID], [TED_NUTS], [TED_E_MAIL], [TED_PHONE], 
		[TED_URL], [TED_FAX], [TED_AZIRAGIONESOCIALE], [TED_AZIINDIRIZZOLEG] )
		select 
			@newIdLotto, @IdDoc , 
			null, dm.vatValore_FT as [TED_NATIONALID] , dbo.GetColumnValue( azilocalitaleg2 , '-', 7) , aziE_Mail, aziTelefono1, 
			aziSitoWeb, aziFAX, a.aziRagioneSociale, aziIndirizzoLeg
			from 
				#tempAzi T
					inner join aziende A with (nolock) on A.idazi = T.Idazi
					inner join dm_attributi DM with (nolock) on Dm.lnk=T.Idazi and DM.dztNome='codicefiscale'

END





GO
