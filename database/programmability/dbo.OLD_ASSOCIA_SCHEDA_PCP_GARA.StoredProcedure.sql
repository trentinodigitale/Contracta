USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ASSOCIA_SCHEDA_PCP_GARA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE PROCEDURE [dbo].[OLD_ASSOCIA_SCHEDA_PCP_GARA]  ( @IdGara int , @Idpfu int )
AS
BEGIN

	exec INIT_SCHEDA_PCP_GARA   @IdGara , @Idpfu 
	
	--declare @IdGara int , @Idpfu int

	--set @IdGara = 480150
	--set @Idpfu = -45094

	--declare @proceduraGara as varchar(100)
	--declare @importoBaseAsta as float
	--declare @pcp_TipoScheda as nvarchar(200)
	--declare @pcp_VersioneScheda as varchar(50)
	--declare @Prev_TipoScheda as nvarchar(200)
	--declare @IdModelloGara as int
	--declare @Modello_INTEROP_PCP as varchar(100)
	--declare @Modello_INTEROP as varchar(100)
	--declare @TipoAppaltoGara as varchar(50)
	--declare @TipoBandoGara as varchar(50)
	--declare @TipoSoglia as varchar(50)
	--declare @Concessione as varchar(2)
	--declare @TipoProceduraCaratteristica as varchar(100)
	--declare @TipoDoc as varchar(50)

	----recupero tipo procedura e importo gara
 --  	select 			
 -- 		@proceduraGara = DB.ProceduraGara,
 -- 		@importoBaseAsta = ImportoBaseAsta,
	--	@Prev_TipoScheda = pcp_TipoScheda,
	--	@TipoAppaltoGara = DB.TipoAppaltoGara,
	--	@TipoBandoGara = TipoBandoGara,
	--	@TipoSoglia = TipoSoglia,
	--	@Concessione = Concessione,
	--	@TipoProceduraCaratteristica = TipoProceduraCaratteristica,
	--	@TipoDoc = TipoDoc 

	--	from  
	--		ctl_doc G with (nolock)
	--			inner join document_bando DB with(nolock) on DB.idheader = G.id
	--			inner join Document_PCP_Appalto PCP with(nolock) on PCP.idheader = DB.idHeader
	--	where G.id = @IdGara
	
	----se non settata considero quella di default P1_16
	--if @Prev_TipoScheda = ''
	--begin
	--	set @Prev_TipoScheda = 'P1_16'
	--end

 -- 	--recupero il tipo scheda
	--set @pcp_TipoScheda = dbo.Get_TipoScheda_PCP(@ProceduraGara,@TipoBandoGara,@TipoSoglia,@ImportoBaseAsta,@TipoAppaltoGara,@Concessione,@TipoProceduraCaratteristica,@TipoDoc)

	----select @pcp_TipoScheda +'- ' + @Prev_TipoScheda

	----se il tipo scheda è cambiato rispetto al precedente 
	----allora lo aggiorno compreso e rigenero modelli dei prodotti
	--if @Prev_TipoScheda <> @pcp_TipoScheda
	--begin

	--	-- recupero la versione delle schede PCP
	--	-- CONTESTO = SCHEDA_PCP
	--	-- OGGETTO= ENTRO PER @pcp_TipoScheda
	--	-- PROPRIETA= VERSIONE
	--	-- VALORE = 1.0 (ECC..)
	--	select @pcp_VersioneScheda = dbo.PARAMETRI('SCHEDA_PCP',@pcp_TipoScheda,'Versione','1.0',-1)

	--	--aggiorno il tipo e la versione della scheda
	--	update Document_PCP_Appalto 
	--		set 
	--			pcp_TipoScheda =@pcp_TipoScheda , pcp_VersioneScheda=@pcp_VersioneScheda  
	--		where	
	--			idHeader = @IdGara 
		
		
	--	--CAMBIO MODELLO DI SEZIONE A SECONDA DELLA SCHEDA 
	--	if @pcp_TipoScheda in ('AD3','AD5','P7_2','P7_1_2')
	--	begin
	--		--setto il modello corretto per la sezione INTEROP
	--		set @Modello_INTEROP_PCP = ''
	--		set @Modello_INTEROP_PCP = case
	--										when @pcp_TipoScheda = 'AD3' then 'INTEROP_PCP_GARA_AD' 
	--										--when @pcp_TipoScheda = 'AD5' then 'INTEROP_PCP_GARA_AD5' 
	--										else 'INTEROP_PCP_GARA_' + @pcp_TipoScheda

	--									end
	--		--return
	--		--se richiesto lo setto sulla sezione
	--		if @Modello_INTEROP_PCP <>''
	--		begin
			
			
			
	--			delete CTL_DOC_SECTION_MODEL where idheader=@IdGara and dse_id='INTEROP_PCP'

	--			insert into CTL_DOC_SECTION_MODEL
	--				( [IdHeader], [DSE_ID], [MOD_Name] )
	--				values
	--				( @IdGara, 'INTEROP_PCP', @Modello_INTEROP_PCP )
			
	--			--select @Modello_INTEROP_PCP

	--		end


	--		--setto il modello per la sezioneINTEROP
	--		set @Modello_INTEROP = ''
	--		--aggiungere case se necessario per le altre schede
	--		set @Modello_INTEROP = --'INTEROP_GARA_CN16_EMPTY'
	--									case
	--										when @pcp_TipoScheda in ('AD3','AD5','P7_2','P7_1_2') then 'INTEROP_GARA_CN16_EMPTY' 
	--										--when @pcp_TipoScheda = 'AD5' then 'INTEROP_PCP_GARA_AD5' 
	--										--else 'INTEROP_PCP_GARA_' + @pcp_TipoScheda

	--									end

	--		--attenzione al modello sottostante che adesso è quello vuoto
	--		if @Modello_INTEROP <>''
	--		begin
	--			delete CTL_DOC_SECTION_MODEL where idheader=@IdGara and dse_id='INTEROP'
 -- 				insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
 -- 					values( @IdGara , 'INTEROP' , @Modello_INTEROP )
	--		end
	--	end

	--	--per adesso non serve perchè
	--	--la SP è innescata solo per AFFIDAMENTO DIRETTO
	--	--se cambia importo appalto 
	--	--le colonne aggiuntive sono le stesse per le due schede AD3 e AD5
	--	----genero i modelli 
	--	----recupero modello legato alla gara se esiste
	--	--set @IdModelloGara=0
	--	--select 
	--	--	@IdModelloGara=id 
	--	--	from
	--	--		ctl_doc with (nolock) 
	--	--	where
	--	--		linkeddoc = @IdGara and tipodoc='config_modelli_lotti' and deleted=0

	--	--if @IdModelloGara <> 0 
	--	--begin
	--	--	exec GENERA_MODELLI_CONTESTO @IdModelloGara , @Idpfu
	--	--end

	--end

END






GO
