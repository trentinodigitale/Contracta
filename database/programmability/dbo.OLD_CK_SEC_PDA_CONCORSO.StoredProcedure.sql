USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CK_SEC_PDA_CONCORSO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE  proc [dbo].[OLD_CK_SEC_PDA_CONCORSO] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin


	-- verifico se la sezione puo essere aperta.


	declare @idPfu int
	declare @idPDA int
	
	declare @Blocco nvarchar(1000)
	set @Blocco = ''

	declare @StatoFunzionale varchar(50)
	declare @Divisione_lotti varchar(50)

	declare @CriterioAggiudicazioneGara varchar(100)
	declare @Conformita varchar(100)
	declare @ProceduraGara varchar(100)
	declare @TipoBandoGara varchar(100)
	declare @bBandoRistretta as int
	declare @TipoSedutaGara varchar(100)
	--declare @TipoProceduraCaratteristica varchar(100)
	declare @IdGara as int
	declare @FaseConcorso as varchar(20)

	set @idPDA = @IdDoc

	set @bBandoRistretta=0

	select 
		  @ProceduraGara = ProceduraGara 
		, @StatoFunzionale = StatoFunzionale 
		, @Divisione_lotti = Divisione_lotti  
		, @TipoBandoGara = TipoBandoGara
		, @TipoSedutaGara = TipoSedutaGara	
		--, @TipoProceduraCaratteristica = TipoProceduraCaratteristica
		--, @CriterioAggiudicazioneGara = CriterioAggiudicazioneGara 
		--, @Conformita = Conformita
		, @IdGara = LinkedDoc

		from CTL_Doc 
			inner join Document_bando on LinkedDoc = idheader 
		where id = @IdDoc

	-- Salgo sulla gara per recuperare il valore del campo FaseConcorso
	select
		@FaseConcorso = isnull(FaseConcorso,'')
		from 
			Document_Bando with(nolock)
		where idheader = @IdGara
	
	--if @ProceduraGara = '15477' and @TipoBandoGara='2'
	--	set @bBandoRistretta = 1

	---- controlla se per almeno un lotto c'è una valutazione OEV
	--if exists( select   c.Id
	--				from CTL_DOC C -- PDA
	--					inner join ctl_doc b on b.id = C.linkeddoc -- BANDO
	--					inner join document_bando ba on  ba.idheader = b.id
	--					inner join document_microlotti_dettagli lb with (nolock) on b.id = lb.idheader and lb.tipodoc = b.Tipodoc 
			
	--					left outer join Document_Microlotti_DOC_Value v1 on v1.idheader = lb.id and v1.DZT_Name = 'CriterioAggiudicazioneGara'  and v1.DSE_ID = 'CRITERI_AGGIUDICAZIONE' 
			
	--					where C.id = @IdDoc and ( CriterioAggiudicazioneGara = '15532' or isnull( v1.Value , '' ) = '15532' )
	--			)
	--begin
	--	set @CriterioAggiudicazioneGara = '15532' 
	--end

	-- controlla se per almeno un lotto c'è una valutazione COSTO FISSO
	--if exists( select   c.Id
	--				from CTL_DOC C -- PDA
	--					inner join ctl_doc b on b.id = C.linkeddoc -- BANDO
	--					inner join document_bando ba on  ba.idheader = b.id
	--					inner join document_microlotti_dettagli lb with (nolock) on b.id = lb.idheader and lb.tipodoc = b.Tipodoc 
			
	--					left outer join Document_Microlotti_DOC_Value v1 on v1.idheader = lb.id and v1.DZT_Name = 'CriterioAggiudicazioneGara'  and v1.DSE_ID = 'CRITERI_AGGIUDICAZIONE' 
			
	--					where C.id = @IdDoc and ( CriterioAggiudicazioneGara = '25532' or isnull( v1.Value , '' ) = '25532' )
	--			)
	--begin
	--	set @CriterioAggiudicazioneGara = '25532' 
	--end

	-- controlla se per almeno un lotto c'è la conformità 'Ex-Ante'
	--if exists( select  c.Id
	--				from CTL_DOC C -- PDA
	--					inner join ctl_doc b on b.id = C.linkeddoc -- BANDO
	--					inner join document_bando ba on  ba.idheader = b.id
	--					inner join document_microlotti_dettagli lb with (nolock) on b.id = lb.idheader and lb.tipodoc = b.Tipodoc 
			
	--					left outer join Document_Microlotti_DOC_Value v1 on v1.idheader = lb.id and v1.DZT_Name = 'Conformita'  and v1.DSE_ID = 'CRITERI_AGGIUDICAZIONE' 
			
	--					where C.id = @IdDoc and ( Conformita = 'Ex-Ante' or isnull( v1.Value , '' ) = 'Ex-Ante' )
	--			)
	--begin
	--	set @Conformita = 'Ex-Ante'
	--end





	--if @SectionName = 'VAL' and @StatoFunzionale = 'VERIFICA_AMMINISTRATIVA' 
	--begin 
	--	set @Blocco = 'Per la visualizzazione dei lotti è necessario aver avviato la valutazione economica'
	--end 


	--if  @SectionName in (  'VAL_TEC' , 'OFFERTE_TEC' ) 
	--begin
		
	--	if ( @Conformita = 'Ex-Ante' or @CriterioAggiudicazioneGara = '15532' or @CriterioAggiudicazioneGara = '25532' )  and @bBandoRistretta = 0
	--	begin
	--		-- la lista di lotti per aprire le buste tecniche deve avvenire dopo la fase amministrativa
	--		if @StatoFunzionale = 'VERIFICA_AMMINISTRATIVA'
	--			set @Blocco = 'Per aprire le buste tecniche è necessario aver terminato la fase amministrativa'		
	--	end
	--	else
	--		set @Blocco = 'NON_VISIBILE'


	--	if @Divisione_lotti = '0' and  @SectionName in (  'VAL_TEC' )
	--		set @Blocco = 'NON_VISIBILE'

	--	if @Divisione_lotti <> '0' and  @SectionName in (  'OFFERTE_TEC' )
	--		set @Blocco = 'NON_VISIBILE'

	--end 


    
    
    --se si trattat di RDP/IDM nascondo sezione Valutazione amministrativa
  --  if  @SectionName = 'OFF' and @ProceduraGara in ( '15581' , '15479' )
		--set @Blocco = 'NON_VISIBILE'
       




	--if ( @Divisione_lotti = '0' and  @SectionName in (  'RIEP' ) ) or @bBandoRistretta = 1
	--	set @Blocco = 'NON_VISIBILE'

	--if ( @Divisione_lotti <> '0' and  @SectionName in (  'OFFERTE_ECO' ) ) or @bBandoRistretta = 1
	--	set @Blocco = 'NON_VISIBILE'


	--se si tratta di CHAT si controlla il campo TipoSedutaGara = 'virtuale'
    if  @SectionName = 'CHAT'
	begin
		if isnull(@TipoSedutaGara, '') <> 'virtuale'
			set @Blocco = 'NON_VISIBILE'
	end

	--if @TipoProceduraCaratteristica='RFQ' and @Blocco=''
	--	set @Blocco = 'NON_VISIBILE'

	if  @SectionName = 'RISPOSTE'
	begin
		--se i dati non sono in chiaro sulla gara metto messaggio di blocco
		if not exists (
					select idrow from
						CTL_DOC_Value with (nolock) 
							where IdHeader=@IdGara and DSE_ID ='ANONIMATO' and DZT_Name='DATI_IN_CHIARO' and Value='1'
					)
			set @Blocco = 'La Valutazione Amministrativa sara accessibile quando sara effettuato il comando Sblocca buste amministrative'		

		--se sono sulla prima fase del concorso a 2 fasi setto la sezione a non visibile, surclassando il precedente blocco
		IF @FaseConcorso = 'prima'
		begin
			set @Blocco = 'NON_VISIBILE'	
		end

	end


	--if  @SectionName = 'RIEPILOGO'
	--begin
	--	se sono sulla prima fase del concorso a 2 fasi
	--	if @FaseConcorso = 'prima'
	--		set @Blocco = 'NON_VISIBILE'		
	--end	


	select @Blocco as Blocco

end
GO
