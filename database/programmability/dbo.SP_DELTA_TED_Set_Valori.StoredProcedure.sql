USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SP_DELTA_TED_Set_Valori]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[SP_DELTA_TED_Set_Valori] ( @IdDoc as int, @idGara int ,  @lotto varchar(max) , @cig varchar(50) , @Contesto varchar(200), @IdContesto int   )
as
BEGIN
	
	declare @TipoAggiudicazione varchar(50)
	declare @Not_Editable as varchar (500)
	declare @Valore_Agg as decimal(18,2)
	declare @Valore_Min_Offerta as decimal(18,2)
	declare @Valore_Max_Offerta as decimal(18,2)
	declare @IdLottoPDA as int
	declare @StatoRiga as varchar(200)
	declare @TED_AWARDED_CONTRACT as varchar(1)
	declare @TED_PROCUREMENT_UNSUCCESSFUL as varchar(1)
	declare @TED_DATE_CONCLUSION_CONTRACT as datetime
	declare @Not_Editable_Agg as varchar (500)
	declare @TED_NB_TENDERS_RECEIVED_OTHER_EU as int
	declare @TED_NB_TENDERS_RECEIVED_NON_EU as int
	declare @TED_NB_TENDERS_RECEIVED_EMEANS as int

	declare @IdPda as int

	set @TED_NB_TENDERS_RECEIVED_OTHER_EU = null

	--tutte le colonne non editabili
	set @Not_Editable = ' TED_VAL_TOTAL TED_VAL_RANGE_TOTAL_LOW TED_VAL_RANGE_TOTAL_HIGH TED_INFO_SDA TED_INFO_AVV_PRE TED_INFO_SDA TED_INFO_AVV_PRE '
	set @Not_Editable_Agg = ' TED_DATE_CONCLUSION_CONTRACT TED_NB_TENDERS_RECEIVED_SME TED_LIKELY_SUBCONTRACTED TED_VAL_SUBCONTRACTING TED_PCT_SUBCONTRACTING TED_INFO_ADD_SUBCONTRACTING '

	set @TED_AWARDED_CONTRACT = 'N'
	set @TED_PROCUREMENT_UNSUCCESSFUL = '1'
	set @TED_DATE_CONCLUSION_CONTRACT = null

	--recupero id lotto pda
	select 	
			@IdLottoPDA = DETT_PDA.id,
			@StatoRiga = isnull(StatoRiga,''),
			@IdPda = IdHeader
		from
			document_microlotti_dettagli DETT_PDA with (nolock)
				inner join ctl_doc PDA with (nolock) on PDA.id = DETT_PDA.idheader and PDA.tipodoc=DETT_PDA.Tipodoc and PDA.Deleted=0
		where
			DETT_PDA.Tipodoc='PDA_MICROLOTTI' and NumeroLotto = @lotto and CIG = @cig and Voce = 0
	
	--recupero partecipanti
	if @StatoRiga <> 'Deserta'
	begin

		select 
			OP.idAziPartecipante into #tempAziPart
			from 
				document_pda_offerte OP with (nolock) 
					--inner join document_microlotti_dettagli LO with (nolock) on LO.IdHeader = OP.IdRow and LO.TipoDoc='PDA_OFFERTE' 
						--														and LO.NumeroLotto=@lotto
					inner join document_microlotti_dettagli LO with (nolock) on LO.IdHeader = OP.IdMsgFornitore and LO.TipoDoc='OFFERTA' 
																				and LO.NumeroLotto=@lotto
			where
				OP.idheader = @IdPda and OP.statopda not in ('99' , '999')
		
				

		select 
			@TED_NB_TENDERS_RECEIVED_EMEANS=count(*)
				from 
					#tempAziPart
		
		select 
			@TED_NB_TENDERS_RECEIVED_OTHER_EU=count(*)
				from 
					#tempAziPart
						inner join aziende with (nolock) on idazi = idAziPartecipante and left(aziStatoLeg2,7)='M-1-11-' and isnull(aziStatoLeg2,'M-1-11-ITA') <> 'M-1-11-ITA'

		select 
			@TED_NB_TENDERS_RECEIVED_NON_EU=count(*)
				from 
					#tempAziPart
						inner join aziende with (nolock) on idazi = idAziPartecipante and left(aziStatoLeg2,7) <> 'M-1-11-' 
				
	end


	--controllo se lo stato del lotto sulla PDA non è deserto/non aggiudicabile/ NonGiudicabile / interrotto
	if @StatoRiga not in ('NonAggiudicabile','Deserta','NonGiudicabile','interrotto')
	begin
		
		--set @Not_Editable_Agg = ''

		set @TED_AWARDED_CONTRACT ='S'
		set @TED_PROCUREMENT_UNSUCCESSFUL = ''

		if @Contesto = 'CONVENZIONE'
		begin
			select @TED_DATE_CONCLUSION_CONTRACT = DataStipulaConvenzione from document_convenzione with (nolock) where id = @IdContesto
		end
		
		if @Contesto = 'CONTRATTO_GARA'
		begin
			select  @TED_DATE_CONCLUSION_CONTRACT = value from ctl_doc_value with (nolock) where idheader = @IdContesto and dse_id='CONTRATTO' and dzt_name='DataStipula'
		end

		--per il lotto corrente
		--recupero numero offerte da offerenti membri EU
		--recupero numero offerte da offerenti non membri EU
		--recupero numero offerte per via elettronica

		
		

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

		--GARA MONO FORNITORE - recupero valore aggiudicato per il lotto sul doc OCP_ISTANZIA_AGGIUDICAZIONE
		if @TipoAggiudicazione =  'monofornitore'
		begin
			set @Not_Editable = ' TED_VAL_TOTAL TED_VAL_RANGE_TOTAL_LOW TED_VAL_RANGE_TOTAL_HIGH TED_INFO_AVV_PRE TED_INFO_SDA '

			set @Valore_Agg=null
			select
				@Valore_Agg = W3IMP_AGGI
				from 
					ctl_doc with (nolock)
						inner join view_Document_OCP_LOTTI_AGGIUDICATI with (nolock) on idheader = id 
				where
					LinkedDoc = @idGara	and tipodoc='OCP_ISTANZIA_AGGIUDICAZIONE' and NumeroLotto=@lotto and W3CIG = @cig	
		end
		else
		begin
			--GARA MULTI FORNITORE 
			set @Not_Editable = ' TED_VAL_TOTAL  TED_INFO_AVV_PRE TED_INFO_SDA '

			--caso multiaggiudicazione
			--recupero dal doc PDA_GRADUOTARIA_LOTTO l'offerta più bassa e l'offerta più alta
			--recupero offerta max ed offerta min dal doc di PDA_GRADUOTARIA
			set @Valore_Min_Offerta = null
			set @Valore_Max_Offerta = null

			select 
					@Valore_Min_Offerta = min(ValoreImportoLotto),
					@Valore_Max_Offerta = max(ValoreImportoLotto)

				from
					ctl_doc gr with (nolock)	
						left join Document_microlotti_dettagli aggiud with(nolock) ON aggiud.IdHeader = gr.Id and aggiud.TipoDoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE'
				where
					gr.LinkedDoc = @IdLottoPDA and gr.TipoDoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE' and gr.StatoFunzionale = 'Confermato'		
					and aggiud.Posizione in ('','Idoneo provvisorio')
			
			if @Valore_Min_Offerta is not null and @Valore_Max_Offerta is not null
				set @Not_Editable = ' TED_VAL_TOTAL TED_VAL_RANGE_TOTAL_LOW TED_VAL_RANGE_TOTAL_HIGH  TED_INFO_AVV_PRE TED_INFO_SDA '

		end
	end

	

	--aggiorno le info sulla tabella Document_TED_GARA
	update 
		Document_TED_GARA
		set
			NotEditable = @Not_Editable, 
			TED_VAL_TOTAL = @Valore_Agg,
			TED_VAL_RANGE_TOTAL_LOW = @Valore_Min_Offerta,
			TED_VAL_RANGE_TOTAL_HIGH = @Valore_Max_Offerta
		where 
			idHeader = @IdDoc


	--aggiorno le info sulla tabella Document_TED_Aggiudicazione
	update 
		
		Document_TED_Aggiudicazione
		set
			NotEditable = @Not_Editable_Agg,
			TED_AWARDED_CONTRACT = @TED_AWARDED_CONTRACT,
			TED_PROCUREMENT_UNSUCCESSFUL = @TED_PROCUREMENT_UNSUCCESSFUL,
			TED_DATE_CONCLUSION_CONTRACT = @TED_DATE_CONCLUSION_CONTRACT,
			TED_NB_TENDERS_RECEIVED_OTHER_EU = @TED_NB_TENDERS_RECEIVED_OTHER_EU,
			TED_NB_TENDERS_RECEIVED_NON_EU = @TED_NB_TENDERS_RECEIVED_NON_EU,
			TED_NB_TENDERS_RECEIVED_EMEANS = @TED_NB_TENDERS_RECEIVED_EMEANS
		where
			idHeader = @IdDoc
	
END

GO
