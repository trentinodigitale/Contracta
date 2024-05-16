USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DOCUMENT_CK_TOOLBAR_OFFERTA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- in sostituzione della vista PDA_MICROLOTTI_VIEW_TESTATA [CTL_DOC_SIGN_VIEW]

CREATE PROCEDURE [dbo].[OLD_DOCUMENT_CK_TOOLBAR_OFFERTA](  @DocName nvarchar(500) , @IdDoc as nvarchar(500) , @idUser int )
AS
begin
	
	set nocount on

	declare @IsLettaBustaEco as int = 0
	declare @IsLettaBustaTec as int = 0
	declare @PresidenteEco as int = 0
	declare @PresidenteTec as int = 0
	declare @IdPda as int = 0
	declare @IdBando as int = 0
	declare @ExistsValTec as int = 0

	declare @StatoFunzionale varchar(50)
	declare @Divisione_lotti varchar(50)
	declare @CriterioAggiudicazioneGara varchar(100)
	declare @Conformita varchar(100)
	declare @ProceduraGara varchar(100)
	declare @TipoBandoGara varchar(100)
	declare @bBandoRistretta as int
	declare @TipoSedutaGara varchar(100)
	declare @BC int = 0
	declare @BT int = 0


	-- Risalgo alla PDA e vado a controllare se è stata aperta almeno una busta per inibire 
	-- i comandi di rettifica tecnica o economica
	-- NB quando campo breaddocumentazione è a 1 allora non è stata letta, invece a 0 è letta

	--Recupero l'id della PDA
	select 
		 @IdPda = PDA.id
		,@IdBando = offerta.LinkedDoc
		from 
			CTL_DOC offerta with (nolock)
			left join CTL_DOC PDA with (nolock) on offerta.LinkedDoc = PDA.LinkedDoc and PDA.Deleted = 0 and PDA.TipoDoc = 'PDA_MICROLOTTI'
		where offerta.id = @IdDoc

	--Controllo se c'è almeno una busta Tecnica letta tra tutte le offerte/lotti
	if exists(select top 1
				id
				from 
					PDA_LST_BUSTE_TEC_OFFERTE_VIEW with (nolock)
				where bReadDocumentazione = 0
					and	idheader = @IdPda)
	begin
		select @IsLettaBustaTec = 1
	end

	--Controllo se c'è almeno una busta economica letta tra tutte le offerte/lotti
	if exists(select top 1
		id 
		from 
			PDA_LST_BUSTE_ECO_OFFERTE_VIEW with (nolock)
		where bReadDocumentazione = 0
			and	idheader = @IdPda)
	begin
		select @IsLettaBustaEco = 1
	end


	-- Recupero ID dei presidenti della commissione
	select
		 @PresidenteTec = isnull(CommTec.UtenteCommissione,0)
		,@PresidenteEco = isnull(CommEco.UtenteCommissione,0)
		from 
			CTL_DOC Offerta
		--Accedo al doc della commissione
		left join CTL_DOC Commissione with (nolock) on Offerta.linkedDoc = Commissione.linkedDoc and Commissione.tipodoc = 'COMMISSIONE_PDA' and Commissione.StatoFunzionale = 'Pubblicato'
		--IdPfu Presidente Commissione Tecnica
		left join Document_CommissionePda_Utenti CommTec with(nolock) on Commissione.id = CommTec.IdHeader and CommTec.RuoloCommissione = 15548 and CommTec.TipoCommissione = 'G'
		--IdPfu Presidente Commissione Economica
		left join Document_CommissionePda_Utenti CommEco with(nolock) on Commissione.id = CommEco.IdHeader and CommEco.RuoloCommissione = 15548 and CommEco.TipoCommissione = 'C'
	where Offerta.id = @IdDoc

	--Controllo se è presente almeno un lotto/offerta con busta tecnica

	---- Monolotto
	--select 
	--	  @ProceduraGara = ProceduraGara 
	--	, @StatoFunzionale = StatoFunzionale 
	--	, @Divisione_lotti = Divisione_lotti  
	--	, @TipoBandoGara = TipoBandoGara
	--	, @TipoSedutaGara = TipoSedutaGara
	--	from CTL_Doc with (nolock)
	--		inner join Document_bando with (nolock) on LinkedDoc = idheader 
	--	where id = @IdBando

	--set @bBandoRistretta=0

	--select 
	--	  @ProceduraGara = ProceduraGara 
	--	, @StatoFunzionale = StatoFunzionale 
	--	, @Divisione_lotti = Divisione_lotti  
	--	, @TipoBandoGara = TipoBandoGara
	--	, @TipoSedutaGara = TipoSedutaGara
	--	from CTL_Doc 
	--		inner join Document_bando with(nolock) on LinkedDoc = idheader 
	--	where id = @IdDoc
	
	--if @ProceduraGara = '15477' and @TipoBandoGara='2'
	--	set @bBandoRistretta = 1

	---- controlla se per almeno un lotto c'è una valutazione OEV
	--if exists( select   c.Id
	--				from CTL_DOC C -- OFFERTA
	--					inner join ctl_doc b on b.id = C.linkeddoc -- BANDO
	--					inner join document_bando ba on  ba.idheader = b.id
	--					inner join document_microlotti_dettagli lb with (nolock) on b.id = lb.idheader and lb.tipodoc = b.Tipodoc 
			
	--					left outer join Document_Microlotti_DOC_Value v1 on v1.idheader = lb.id and v1.DZT_Name = 'CriterioAggiudicazioneGara'  and v1.DSE_ID = 'CRITERI_AGGIUDICAZIONE' 
			
	--					where C.id = @IdDoc and ( CriterioAggiudicazioneGara = '15532' or isnull( v1.Value , '' ) = '15532' )
	--			)
	--begin
	--	set @CriterioAggiudicazioneGara = '15532' 
	--end

	---- controlla se per almeno un lotto c'è una valutazione COSTO FISSO
	--if exists( select   c.Id
	--				from CTL_DOC C -- OFFERTA
	--					inner join ctl_doc b on b.id = C.linkeddoc -- BANDO
	--					inner join document_bando ba on  ba.idheader = b.id
	--					inner join document_microlotti_dettagli lb with (nolock) on b.id = lb.idheader and lb.tipodoc = b.Tipodoc 
			
	--					left outer join Document_Microlotti_DOC_Value v1 on v1.idheader = lb.id and v1.DZT_Name = 'CriterioAggiudicazioneGara'  and v1.DSE_ID = 'CRITERI_AGGIUDICAZIONE' 
			
	--					where C.id = @IdDoc and ( CriterioAggiudicazioneGara = '25532' or isnull( v1.Value , '' ) = '25532' )
	--			)
	--begin
	--	set @CriterioAggiudicazioneGara = '25532' 
	--end

	---- controlla se per almeno un lotto c'è la conformità 'Ex-Ante'
	--if exists( select  c.Id
	--				from CTL_DOC C -- OFFERTA
	--					inner join ctl_doc b on b.id = C.linkeddoc -- BANDO
	--					inner join document_bando ba on  ba.idheader = b.id
	--					inner join document_microlotti_dettagli lb with (nolock) on b.id = lb.idheader and lb.tipodoc = b.Tipodoc 
			
	--					left outer join Document_Microlotti_DOC_Value v1 on v1.idheader = lb.id and v1.DZT_Name = 'Conformita'  and v1.DSE_ID = 'CRITERI_AGGIUDICAZIONE' 
			
	--					where C.id = @IdDoc and ( Conformita = 'Ex-Ante' or isnull( v1.Value , '' ) = 'Ex-Ante' )
	--			)
	--begin
	--	set @Conformita = 'Ex-Ante'
	--end

	select	@BT = max( case when criterioaggiudicazionegara in ( '15532' , '25532' ) then 1 else 0 end ) ,
			@BC = max( case when isnull( conformita , 'No' ) <> 'No' then 1 else 0 end ) 
		from BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO where idbando = @IdBando


	--Controllo se è presente almeno un lotto/offerta con busta tecnica
	if (@BC = 1 or @BT = 1)
	begin
		select @ExistsValTec = 1	
	end


	--Multilotto
	if exists (select top 1
					id
					from
						OFFERTA_LISTA_BUSTE_VIEW_EVO with (nolock)
					where Esito_Busta_Tec <> ''
						and idheader = @IdDoc)
	begin
		select @ExistsValTec = 1
	end


	--Compongo la select finale per alimentare il documento
	SELECT 
		 CTL_DOC_SIGN_VIEW.*
		,case 
			--when @IsLettaBustaEcoMonolotto = 1 or @IsLettaBustaEcoLotti = 1
			when @IsLettaBustaEco = 1
			then 
				1
			else
				0
		 end as IsLettaBustaEco
		,case 
			--when @IsLettaBustaTecMonolotto = 1 or @IsLettaBustaTecLotti = 1
			when @IsLettaBustaTec = 1
			then 
				1
			else
				0
		 end as IsLettaBustaTec
		,@ExistsValTec as ExistsValTec
		,@PresidenteTec as PresidenteTec
		,@PresidenteEco as PresidenteEco
		FROM 
			CTL_DOC_SIGN_VIEW with (nolock)
		WHERE id = @IdDoc
end
GO
