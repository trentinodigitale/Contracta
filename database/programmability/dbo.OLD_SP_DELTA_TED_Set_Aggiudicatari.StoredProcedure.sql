USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_SP_DELTA_TED_Set_Aggiudicatari]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[OLD_SP_DELTA_TED_Set_Aggiudicatari] ( @newIdLotto int, @IdDoc as int, @idGara int ,  @lotto varchar(max) , @cig varchar(50) , @Contesto varchar(200), @IdContesto int   )
as
BEGIN
	
	declare @Mandataria as int
	declare @IdMsgOfferta as int
	declare @TipoAggiudicazione as varchar(100)
	declare @IdLottoPDA as int
	declare @IdPda as int
	declare @IdTemplate as int
	declare @MA_DZT_NAME as varchar(1000)
	
	declare  @TempMandatarie table
			( 
			idazi  int
			)

	--recupero tipo gara mon/multi aggiuidcatari
	set @TipoAggiudicazione='monofornitore'
	
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

	
	--determino il nome dell'attributo del DGUE che contiene l'informazione per le aziende PMI (S/N)
	--il record sul criterio è quello che ha nella colonna SorgenteCampo il valore 'PMI'
	--recupero il template DGUE PUBBLICATO
	set @IdTemplate =-1
	select @IdTemplate = id from ctl_doc with (nolock) where tipodoc='TEMPLATE_REQUEST' and statofunzionale='Pubblicato'

	if @IdTemplate <> -1
	begin
		--recupero il nome dell'attributo 
		select  top 1  @MA_DZT_NAME = upper( 'MOD_' + replace( k.value , '.' , '_' )  + '_FLD_' +   dbo.GetID_ElementModulo ( ItemPath , ItemLevel  , TypeRequest ) ) 
				from 
					CTL_DOC_Value t with(nolock)
						inner join CTL_DOC_Value k  with(nolock) on t.idheader = k.idheader and t.Row = k.Row and k.DSE_ID = 'VALORI' and k.DZT_Name = 'KeyRiga'
						inner join CTL_DOC_Value M with(nolock) on t.idheader = M.idheader and t.Row = M.Row and M.DSE_ID = 'VALORI' and M.DZT_Name = 'IdModulo'
						inner join DOCUMENT_REQUEST_GROUP G with(nolock) on G.idheader = M.value and G.SorgenteCampo='PMI'
				where 
					t.idHeader=@IdTemplate and t.DSE_ID = 'VALORI' and t.DZT_Name = 'REQUEST_PART' and t.value = 'Modulo' 
					
	end

	

	--metto in una temp l'azienda mandataria + eventuali aziende in caso di rti
	select 
		V.Idazi, PMI into #tempAzi
		from 
		(
			--per l'azienda mandataria il DGUE è sull'offerta direttamente
			select 
				Idazi , isnull(value,'si') as PMI 
					from 
						@TempMandatarie
							inner join ctl_doc OFFERTA with (nolock) on azienda = Idazi and Tipodoc='OFFERTA' and OFFERTA.Deleted=0
							--salgo sul dge
							left join ctl_doc DGUE with(nolock) on DGUE.LinkedDoc = OFFERTA.ID and DGUE.tipodoc='MODULO_TEMPLATE_REQUEST' and DGUE.Deleted=0
							--salgo sul contentuto del dgue
							left join ctl_doc_value DGUE_DETT  with(nolock) on DGUE_DETT.IdHeader = DGUE.id and DGUE_DETT.dse_id = 'MODULO' and DGUE_DETT.DZT_Name = @MA_DZT_NAME
			where
				OFFERTA.id  in ( select * from #TempIdMsg )

			union
				select DO.idazi ,  isnull(value,'si') as PMI
					from 
						ctl_doc OFFERTA with(nolock) 
							inner join CTL_DOC C with(nolock) on C.tipodoc='OFFERTA_PARTECIPANTI' and c.statofunzionale='Pubblicato' and c.linkeddoc=OFFERTA.ID
							inner join Document_Offerta_Partecipanti DO with(nolock) on C.id = DO.IdHeader and TipoRiferimento = 'RTI' and Ruolo_Impresa <> 'mandataria'
							--salgo sulla richiesta compilazione DGUE
							left join ctl_doc RIC_COMP_DGUE with(nolock) on RIC_COMP_DGUE.id = DO.IdDocRicDGUE and RIC_COMP_DGUE.tipodoc='RICHIESTA_COMPILAZIONE_DGUE' and RIC_COMP_DGUE.Deleted=0 and RIC_COMP_DGUE.StatoFunzionale='Inviata Risposta'
							--salgo sulla risposta alla  richiesta compilazione DGUE
							left join ctl_doc RIS_RIC_COMP_DGUE with(nolock) on RIS_RIC_COMP_DGUE.LinkedDoc = RIC_COMP_DGUE.ID and RIS_RIC_COMP_DGUE.tipodoc='RICHIESTA_COMPILAZIONE_DGUE_RISPOSTA' and RIS_RIC_COMP_DGUE.Deleted=0 and RIS_RIC_COMP_DGUE.StatoFunzionale='Inviato'
							--salgo sul DGUE
							left join ctl_doc DGUE with(nolock) on DGUE.LinkedDoc = RIS_RIC_COMP_DGUE.ID and DGUE.tipodoc='MODULO_TEMPLATE_REQUEST' and DGUE.Deleted=0
							--salgo sul contentuto del dgue
							left join ctl_doc_value DGUE_DETT  with(nolock) on DGUE_DETT.IdHeader = DGUE.id and DGUE_DETT.dse_id = 'MODULO' and DGUE_DETT.DZT_Name = @MA_DZT_NAME

					where 
						OFFERTA.id  in ( select * from #TempIdMsg )
		) V


	INSERT INTO Document_TED_Aggiudicatari 
		( [idHeader], [IdDoc], [TED_AWARDED_IS_SME], 
			[TED_NATIONALID], [TED_NUTS], [TED_E_MAIL], [TED_PHONE], [TED_URL], [TED_FAX], [TED_AZIRAGIONESOCIALE], [TED_AZIINDIRIZZOLEG] )
		select 
			@newIdLotto, @IdDoc , 
			
			case when T.PMI='si' then 'S' else 'N' end   as [TED_AWARDED_IS_SME], 
			dm.vatValore_FT as [TED_NATIONALID] , dbo.GetColumnValue( azilocalitaleg2 , '-', 7) as  [TED_NUTS], aziE_Mail, aziTelefono1, 
			aziSitoWeb as [TED_URL] , aziFAX, a.aziRagioneSociale, aziIndirizzoLeg
			from 
				#tempAzi T
					inner join aziende A with (nolock) on A.idazi = T.Idazi
					inner join dm_attributi DM with (nolock) on Dm.lnk=T.Idazi and DM.dztNome='codicefiscale'

END





GO
