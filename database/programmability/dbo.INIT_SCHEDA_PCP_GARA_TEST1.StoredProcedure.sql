USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[INIT_SCHEDA_PCP_GARA_TEST1]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  PROCEDURE [dbo].[INIT_SCHEDA_PCP_GARA_TEST1]  ( @IdGara int , @Idpfu int )
AS
BEGIN
	
	--declare @IdGara int , @Idpfu int

	--set @IdGara = 480150
	--set @Idpfu = -45094

	declare @proceduraGara as varchar(100)
	declare @importoBaseAsta as float
	declare @pcp_TipoScheda as nvarchar(200)
	declare @pcp_VersioneScheda as varchar(50)
	declare @IdModelloGara as int
	declare @Modello_INTEROP_PCP as varchar(100)
	declare @Modello_INTEROP as varchar(100)
	declare @pcp_Categoria as varchar(50)
	declare @TipoAppaltoGara as varchar(50)
	declare @TipoBandoGara as varchar(50)
	declare @TipoSoglia as varchar(50)
	declare @Concessione as varchar(2)
	declare @TipoProceduraCaratteristica as varchar(100)
	declare @TipoDoc as varchar(50)
	declare @LinkedDoc as int
	declare @Prev_TipoScheda as nvarchar(200)
	declare @RegimeAllegerito as varchar(10)
	declare @SocietaInHouse as varchar(10)


	--recupero la versione della PCP da una SYS
	set @pcp_VersioneScheda = '01.00.00'

	select @pcp_VersioneScheda = DZT_ValueDef  from LIB_Dictionary with (nolock) where dzt_name='SYS_VERSIONE_PCP'


	--recupero tipo procedura e importo gara
   	select 			
  		
		@proceduraGara = DB.ProceduraGara,
  		@importoBaseAsta = ImportoBaseAsta,
		@TipoAppaltoGara = DB.TipoAppaltoGara,
		@TipoBandoGara = TipoBandoGara,
		@TipoSoglia = TipoSoglia,
		@Concessione = Concessione,
		@TipoProceduraCaratteristica = TipoProceduraCaratteristica,
		@TipoDoc = TipoDoc,
		@LinkedDoc = isnull(LinkedDoc,0),
		@Prev_TipoScheda = isnull(pcp_TipoScheda,'') ,
		@RegimeAllegerito = RegimeAllegerito--,
		--@SocietaInHouse= SocietaInHouse

		from  
			ctl_doc G with(nolock) 
				inner join document_bando DB with(nolock) on DB.idheader=G.id 
				left join Document_PCP_Appalto PCP with(nolock) on PCP.idheader = DB.idHeader
		where G.id = @IdGara
	
	
	--recupero il tipo scheda
	set @pcp_TipoScheda = dbo.Get_TipoScheda_PCP(@ProceduraGara,@TipoBandoGara,@TipoSoglia,@ImportoBaseAsta,@TipoAppaltoGara,@Concessione,@TipoProceduraCaratteristica,@TipoDoc,@LinkedDoc,@RegimeAllegerito)

	--select @pcp_TipoScheda

	--determino il tipo scheda: default p1_16
	--set @pcp_TipoScheda = 'P1_16'

	
	--per AFFIDAMENTO DIRETTO ('15583') SPOECIALIZZO I MODELLI PER LE SEZIONI  INTEROP e INTEROP_PCP
	--if @proceduraGara = '15583' 
	--aggiungere gli altri tipi scheda che necessitano di modelli personalizzati
	
	delete from  CTL_DOC_SECTION_MODEL where DSE_ID in ('INTEROP', 'INTEROP_PCP') and IdHeader=@IdGara

	if @pcp_TipoScheda in ('AD3','AD5','AD2_25','P7_2', 'P7_1_2','P2_16','P7_1_3', 'P1_19', 'P2_19', 'P2_20', 'A3_6', 'P1_20')
	begin
				
		--setto il modello corretto per la sezione INTEROP_PCP
		set @Modello_INTEROP_PCP = ''
		set @Modello_INTEROP_PCP = case
										when @pcp_TipoScheda = 'AD3' then 'INTEROP_PCP_GARA_AD' 
										--when @pcp_TipoScheda = 'AD5' then 'INTEROP_PCP_GARA_AD5' 
										else 'INTEROP_PCP_GARA_' + @pcp_TipoScheda

									end
		
		if @Modello_INTEROP_PCP <>'' and exists(select mod_id from lib_models with (nolock) where mod_id=@Modello_INTEROP_PCP)
		begin
			insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
  				values( @IdGara , 'INTEROP_PCP' , @Modello_INTEROP_PCP )
		end

		--setto il modello per la sezione INTEROP (la seconda sarebbe)
		set @Modello_INTEROP = ''
		--aggiungere case se necessario per le altre schede
		--set @Modello_INTEROP = --'INTEROP_GARA_CN16_EMPTY'
		--							case
		--								when @pcp_TipoScheda in ('AD3','AD5','AD2_25') then 'INTEROP_GARA_CN16_EMPTY' 
		--								--when @pcp_TipoScheda  ( 'AD5' then 'INTEROP_PCP_GARA_AD5' 
		--								--'P7_2', 'P7_1_2','P2_16','P7_1_3'
		--								else 'INTEROP_GARA_CN16_' + @pcp_TipoScheda
		--								--else ''
		--							end


		if @pcp_TipoScheda in ('AD3','AD5','AD2_25')
		begin
			--per la prima versione delle schede AD utilizzo un modello CN16 senza attributi 
			if @pcp_VersioneScheda < '01.00.01'
			begin
				set @Modello_INTEROP = 'INTEROP_GARA_CN16_EMPTY' 
			end
			else
			begin
				set @Modello_INTEROP = 'INTEROP_GARA_CN16_' + @pcp_TipoScheda
			end
		end
		else
		begin
			--per la scheda A3_6 modello vuoto
			if @pcp_TipoScheda in ('A3_6')

				set @Modello_INTEROP = 'INTEROP_GARA_CN16_EMPTY' 

			else
			BEGIN
			
				--per la prima versione utilizzo come modello CN16 'INTEROP_GARA_CN16_' + LA sigla della scheda
				set @Modello_INTEROP = 'INTEROP_GARA_CN16_' + @pcp_TipoScheda
			
				if @pcp_VersioneScheda >= '01.00.01'
				begin
			
					--per le versioni successive provo ad utilizzare un modello 
					--'INTEROP_GARA_CN16_' + LA sigla della scheda + '_DAL_' + la versione
					set @Modello_INTEROP = 'INTEROP_GARA_CN16_' + @pcp_TipoScheda + '_DAL_' + @pcp_VersioneScheda

					--se non esiste il modello con la versione successiva setto quello della prima versione
					if not exists (select mod_id from lib_models with (nolock) where mod_id=@Modello_INTEROP)
					begin
						set @Modello_INTEROP = 'INTEROP_GARA_CN16_' + @pcp_TipoScheda
					end

				end
			END
		end

		--attenzione al modello sottostante che adesso è quello vuoto
		if @Modello_INTEROP <>'' and exists(select mod_id from lib_models with (nolock) where mod_id=@Modello_INTEROP)
		begin
			
			insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
  				values( @IdGara , 'INTEROP' , @Modello_INTEROP )
		end

		

	end





	--determino il valore per il campo pcp_Categoria in funzione del relazione TipoAppaltoGara_To_Pcp_Categoria
	--3 servizi
	--set @pcp_Categoria = dbo.Get_Transcodifica_Verso('pcp_categoria','','',@TipoAppaltoGara,0)

	set @pcp_Categoria=''
	select 
		@pcp_Categoria=REL_ValueOutput 
		from
			CTL_Relations with (nolock)
		where
			rel_type='TipoAppaltoGara_To_Pcp_Categoria' and REL_ValueInput =@TipoAppaltoGara

	--if @TipoAppaltoGara ='3'
	--begin
	--	set @pcp_Categoria = 'FS'
	--end	

	-- recupero la versione delle schede PCP
	-- CONTESTO = SCHEDA_PCP
	-- OGGETTO= ENTRO PER @pcp_TipoScheda
	-- PROPRIETA= VERSIONE
	-- VALORE = 1.0 (ECC..)
	--select @pcp_VersioneScheda = dbo.PARAMETRI('SCHEDA_PCP',@pcp_TipoScheda,'Versione','1.0',-1)

	

	if not exists (select idrow from Document_PCP_Appalto where idHeader= @IdGara)
	begin
		INSERT INTO Document_PCP_Appalto 
			( idHeader,pcp_TipoScheda, pcp_VersioneScheda,pcp_Categoria   )
			values 
			( @IdGara , @pcp_TipoScheda, @pcp_VersioneScheda, @pcp_Categoria )

	end
	else
	begin
		--aggiorno il tipo e la versione della scheda
		update Document_PCP_Appalto 
			set 
				pcp_TipoScheda =@pcp_TipoScheda , pcp_VersioneScheda=@pcp_VersioneScheda  
			where	
				idHeader = @IdGara 
		
	end
	

	--SE CAMBIATO IL TIPO SCHEDA ED ASSOCIATO ALLA GARA C'è UN MODELLO DI PRODOTTI
	--ALLORA RIGENERO IL MODELLO DEI PRODOTTI PERCHE' E' INFLUENZATO DAL TIPO SCHEDA
	--IF @Prev_TipoScheda <> @pcp_TipoScheda
	--begin
		
		

		--recupero modello legato alla gara se esiste
		set @IdModelloGara=0
		select 
			@IdModelloGara=id 
			from
				ctl_doc with (nolock) 
			where
				linkeddoc = @IdGara and tipodoc='config_modelli_lotti' and deleted=0

		if @IdModelloGara <> 0 
		begin
			--select @IdModelloGara
			exec GENERA_MODELLI_CONTESTO @IdModelloGara , @Idpfu
		end

	--end

	--A SECONDA DEL TIPO SCHEDA SETTO PRESENZA DGUE IN MODO COERENTE
	if @Pcp_TipoScheda  not in ('AD3', 'AD4', 'AD5' , 'P7_2', 'P7_1_2' )
	begin

		delete ctl_doc_value where idheaDer=@IdGara and dse_id='DGUE' and dzt_name='PresenzaDGUE'

		insert into ctl_doc_value
			(idheader, dse_id,dzt_name,row,value)
			values
			(@IdGara, 'DGUE','PresenzaDGUE',0,'si')
	end
	
	


END






GO
