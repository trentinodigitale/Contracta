USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_MICROLOTTI_INIZIALIZZA_COLONNE_FISSE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE  proc [dbo].[PDA_MICROLOTTI_INIZIALIZZA_COLONNE_FISSE] ( @IdDoc int , @idPFU int  ) 
as
begin
	


	declare @PunteggioTEC_100 as varchar(50)
	declare @PunteggioTEC_TipoRip as varchar(50)
	declare @IS_EX_POST as varchar(50)
	declare @IS_EX_ANTE as varchar(50)
	declare @IS_OEV as varchar(50)
	declare @IS_PRZ as varchar(50)
	declare @RICHIESTA_CALCOLO_ANOMALIA as varchar(50)
	declare @TipoDocBando as varchar(500)
	declare @EP_Presente as int
	declare @EA_Presente as int
	declare @OEV_Presente as int
	declare @PRZ_Presente as int
	declare @CA_Presente as int
	declare @Criterio_Prezzo_Lotto as int
	declare @PunteggioECO_TipoRip as  varchar(50)
	declare @conformita as varchar(50)

	declare @LottiOmogenei as int

	declare @IdBando as int

	select @IdBando=linkeddoc from CTL_DOC with (nolock) where Id=@IdDoc

	select @TipoDocBando=TipoDoc  from CTL_DOC with (nolock) where Id=@IdBando

	select 
		@PunteggioTEC_100 = isnull(value,'') 
		from  
			CTL_DOC_Value with(nolock) 
		where idheader = @IdBando and DSE_ID = 'CRITERI_ECO' and DZT_Name = 'PunteggioTEC_100'
	
	select 
		@PunteggioTEC_TipoRip = isnull(value,'') 
		from  
			CTL_DOC_Value with(nolock)
		where  idheader = @IdBando and DSE_ID = 'CRITERI_ECO' and DZT_Name = 'PunteggioTEC_TipoRip'


	select 
		@PunteggioECO_TipoRip = isnull(value,'') 
		from  
			CTL_DOC_Value with(nolock)
		where  idheader = @IdBando and DSE_ID = 'CRITERI_ECO_TESTATA' and DZT_Name = 'PunteggioECO_TipoRip'

	
	--travaso in una tabella temporanea le info da controllare
	select c.* 
		into #Temp_Info_lotti 
			from 
				Document_Microlotti_Dettagli d with(nolock)
					inner join Document_Microlotti_DOC_Value c with(nolock) on d.id = c.idheader aND DSE_ID = 'CRITERI_AGGIUDICAZIONE'
			where d.Voce = 0 and d.IdHeader=@IdBando and d.TipoDoc=@TipoDocBando

	
	set @EP_Presente=0
	select  
		@EP_Presente=1
		from 
			#Temp_Info_lotti
		where  DZT_Name = 'Conformita' and Value = 'EX-Post'
	
	set @EA_Presente = 0
	select  
		@EA_Presente = 1
		from 
			#Temp_Info_lotti
		where  DZT_Name = 'Conformita' and Value = 'EX-Ante'
	
	
	set @OEV_Presente = 0
	select  
		@OEV_Presente = 1
		from 
			#Temp_Info_lotti
		where  DZT_Name = 'CriterioAggiudicazioneGara' and Value in (  '15532','25532')

	
	set @PRZ_Presente = 0
	select  
		@PRZ_Presente = 1
		from 
			#Temp_Info_lotti
		where  DZT_Name = 'CriterioAggiudicazioneGara' and Value not in ('15532','25532')
	

	set @Criterio_Prezzo_Lotto = null
	select  
		@Criterio_Prezzo_Lotto = Value
		from 
			#Temp_Info_lotti
		where  DZT_Name = 'CriterioAggiudicazioneGara' and Value = '15531'
	

	set @CA_Presente = null
	select  
		@CA_Presente = 1
		from 
			#Temp_Info_lotti
		where  DZT_Name = 'CalcoloAnomalia' and Value ='1'

	--select  
	--	@CA_Presente=1
	--	from BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO vl with(nolock)
	--	where vl.CriterioAggiudicazioneGara='15531' and CalcoloAnomalia='1'  and vl.idBando=@IdBando
	



	select 
		@IS_EX_POST= case when b.Conformita = 'EX-Post' or isnull( @EP_Presente , 0 ) = 1 then '1' else '0' end,
		@IS_EX_ANTE =case when b.Conformita = 'EX-Ante' or isnull( @EA_Presente , 0 ) = 1 then '1' else '0' end,
		@IS_OEV = case when b.CriterioAggiudicazioneGara = '15532' or b.CriterioAggiudicazioneGara = '25532' or isnull( @OEV_Presente , 0 ) = 1 then '1' else '0' end ,
		@IS_PRZ =case when ( b.CriterioAggiudicazioneGara <> '15532' and b.CriterioAggiudicazioneGara <> '25532' ) or isnull( @PRZ_Presente , 0 ) = 1 then '1' else '0' end ,
		--@RICHIESTA_CALCOLO_ANOMALIA = case when ISNULL(@CA_Presente,0) <> 0 then 'SI' else 'NO' end
		@RICHIESTA_CALCOLO_ANOMALIA = case when  isnull( @CA_Presente , b.CalcoloAnomalia  ) = 1  AND  ISNULL(  @Criterio_Prezzo_Lotto, b.CriterioAggiudicazioneGara ) = '15531'   then 'SI' else 'NO' end,
		@conformita=conformita
		from 
			Document_Bando b with (nolock)
			where b.idHeader =@IdBando
				

	-- verifica che i lotti siaono omegenei nella composizione 
	set @LottiOmogenei  = 0
	if @IS_PRZ = 0 and @IS_OEV = 1
		set @LottiOmogenei  = 1
	
	if @IS_PRZ = 1 and @IS_OEV = 0
	begin
		-- se non c'è una conformità exante allora non ho necessità di aprire prima la busta tecnica
		if @IS_EX_ANTE = '0'
			set @LottiOmogenei  = 1
		else
		begin -- altrimenti devo vedere se tutti i lotti sono exante
			if not exists( select Value from #Temp_Info_lotti where  DZT_Name = 'Conformita' and Value <> 'EX-Ante' )
				set @LottiOmogenei  = 1
		end

	end



	update 
		Document_PDA_TESTATA
		set PunteggioTEC_100 = @PunteggioTEC_100
			, PunteggioTEC_TipoRip = @PunteggioTEC_TipoRip
			, IS_EX_POST = @IS_EX_POST
			, IS_EX_ANTE = @IS_EX_ANTE
			, IS_OEV = @IS_OEV
			, IS_PRZ = @IS_PRZ
			, RICHIESTA_CALCOLO_ANOMALIA = @RICHIESTA_CALCOLO_ANOMALIA
			, PunteggioECO_TipoRip = @PunteggioECO_TipoRip
			, conformita=@conformita
		where IdHeader=@IdDoc

	--select @PunteggioTEC_100 , @PunteggioTEC_TipoRip ,@IS_EX_POST, @IS_EX_ANTE,@IS_OEV,@IS_PRZ,@RICHIESTA_CALCOLO_ANOMALIA
	--	from 
	--	Document_PDA_TESTATA
	--	where IdHeader=@IdDoc

end



















GO
