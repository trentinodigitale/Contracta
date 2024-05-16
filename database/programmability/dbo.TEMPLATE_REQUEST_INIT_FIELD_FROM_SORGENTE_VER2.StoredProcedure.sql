USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TEMPLATE_REQUEST_INIT_FIELD_FROM_SORGENTE_VER2]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[TEMPLATE_REQUEST_INIT_FIELD_FROM_SORGENTE_VER2] ( @idDoc int   , @idDocInUse int  )
AS
--Versione=1&data=2016-10-21&Attivita=126293&Nominativo=Sabato
BEGIN
	SET NOCOUNT ON;


	--declare @Template nvarchar( max )

	--declare @REQUEST_PART varchar(100),   @Descrizione nvarchar( max),   @TEMPLATE_REQUEST_GROUP varchar(200)
	--declare @REQUEST_PART_CUR varchar(100),   @TEMPLATE_REQUEST_GROUP_CUR varchar(200)
	--declare @Parte_aperta int
	--declare @Gruppo_Aperto int
	declare @KeyRiga varchar(500)
	declare @KeyGruppoAperto varchar(500)
	declare @TipoTemplate varchar(500)
	
	declare @idModulo int
	declare @NRow int
	declare @RG_FLD_TYPE varchar(max)
	declare @Value varchar(max)
	declare @ix int

	declare @idTemplate int

	declare @idBando int
	declare @idAziendaOE int
	declare @idAziendaEnte int

	declare @idUser int

	declare @Editabile varchar(5)
	declare @InCaricoA varchar(50)
	declare @SorgenteCampo varchar(500) , @MA_DZT_Name varchar(500)
	declare @sqldinamico  as  nvarchar(max) 

	declare @BANDO_CIG				 nvarchar(4000) 
	declare @BANDO_CUP				 nvarchar(4000) 
	declare @BANDO_Oggetto			 nvarchar(max) 
	declare @BANDO_Titolo			 nvarchar(4000)	
	declare @Ente_CF				 nvarchar(4000) 
	declare @Ente_RagSoc			 nvarchar(4000) 
	declare @Ente_Stato				 nvarchar(4000) 
	declare @OE_aziCAPLeg			 nvarchar(4000) 
	declare @OE_aziE_Mail			 nvarchar(4000) 
	declare @OE_aziIndirizzoLeg		 nvarchar(4000) 
	declare @OE_aziLocalitaLeg		 nvarchar(4000) 
	declare @OE_aziProvinciaLeg		 nvarchar(4000) 
	declare @OE_aziStatoLeg			 nvarchar(4000) 
	declare @OE_IscrCCIAA			 nvarchar(4000) 
	declare @OE_PIVA				 nvarchar(4000) 
	declare @OE_RagSoc				 nvarchar(4000) 
	declare @OE_SedeCCIAA			 nvarchar(4000) 

	declare @Valore					 nvarchar(max)
	declare @Modulo as varchar(500)
	declare @ModuloCurr as varchar(500)
	declare @FieldObbligModulo as nvarchar(max)

	declare @Obblig as varchar(10)

	set @BANDO_CIG				 = '' 
	set @BANDO_CUP				 = '' 
	set @BANDO_Oggetto			 = '' 
	set @BANDO_Titolo			 = ''	
	set @Ente_CF				 = '' 
	set @Ente_RagSoc			 = '' 
	set @Ente_Stato				 = '' 
	set @OE_aziCAPLeg			 = '' 
	set @OE_aziE_Mail			 = '' 
	set @OE_aziIndirizzoLeg		 = '' 
	set @OE_aziLocalitaLeg		 = '' 
	set @OE_aziProvinciaLeg		 = '' 
	set @OE_aziStatoLeg			 = '' 
	set @OE_IscrCCIAA			 = '' 
	set @OE_PIVA				 = '' 
	set @OE_RagSoc				 = '' 
	set @OE_SedeCCIAA			 = '' 
	
	declare @crlf varchar(10)
	set @crlf  = '
'

	--set @Parte_aperta = 0
	--set @Gruppo_Aperto = 0 

	--set @Template  = ''
	--set @REQUEST_PART_CUR = '' 
	--set @TEMPLATE_REQUEST_GROUP_CUR = ''

	set @idBando = 0 
	set @idAziendaOE = 0 
	set @idAziendaEnte = 0
	
	
	-- recupera l'id del template nel caso in cui è stato passato il template specifico e non base
	select 
			@idTemplate = case when TipoDoc = 'TEMPLATE_REQUEST' then id else idDoc end , 
			@TipoTemplate = TipoDoc 
		from ctl_doc 
		where id = @idDoc
	


	-- recupero se il documento in uso è di un ente o di un oe
	select  
			@InCaricoA = case when aziAcquirente <> 0 then 'Ente' else 'OE' end 
			, @idUser  = d.IdPfu
			, @idAziendaOE = isnull( a.idazi , 0 ) 
		from ctl_doc d with(nolock)
			inner join profiliutente p with(nolock) on p.idpfu = d.IdPfu
			inner join aziende a with(nolock) on p.pfuidazi = a.idazi
		where id = @idDocInUse
	
	set @InCaricoA = isnull( @InCaricoA , 'Ente')


	if @InCaricoA ='Ente'
	begin

	--if @InCaricoA = 'Ente'
	--	set @idAziendaOE = 0
	
	---- recupero l'ente
	--select 
	--		@idAziendaEnte = isnull(  p.pfuidazi , 0 ) 
	--	from ctl_doc d with(nolock)
	--		inner join profiliutente p with(nolock) on p.idpfu = d.IdPfu
	--	where id = @idDoc

	---- recupero l'identificativo del bando partendo dal modulo che si sta compilando
	--declare @tipoDoc nvarchar(500)
	--declare @exit_while nvarchar(500)
	--declare @LinkedDoc int
	--set @LinkedDoc = @idDocInUse
	--set  @tipoDoc = ''
	--set  @exit_while = 'NO'

	--while @tipoDoc not Like 'BANDO%' and @LinkedDoc <> 0 and @exit_while <> 'SI'
	--begin
	--	set @exit_while='SI'
	--	select @exit_while='NO',@idBando = id , @LinkedDoc = isnull( linkeddoc , 0 ) , @tipoDoc = TipoDoc from Ctl_Doc where id = @LinkedDoc
	--end

	
		--metto in una temp i valori di default
		CREATE TABLE #Temp_Default_Value(
								[BANDO_CIG] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[BANDO_CUP] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[BANDO_Oggetto] [nvarchar](max) collate DATABASE_DEFAULT NULL,
								[BANDO_Titolo] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[BANDO_LOTTO_CIG] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[BANDO_NumeroGara] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[BANDO_RUP] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[BANDO_RUP_TEL] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[BANDO_RUP_MAIL] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[Ente_Indirizzo] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[Ente_Localita] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[Ente_CAP] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[Ente_SitoWeb] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[Ente_CUC_CF] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[Ente_CUC_RagSoc] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[Ente_CF] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[Ente_RagSoc] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[Ente_Stato] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[OE_aziCAPLeg] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[OE_aziE_Mail] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[OE_aziIndirizzoLeg] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[OE_aziLocalitaLeg] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[OE_aziProvinciaLeg] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[OE_aziStatoLeg] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[OE_IscrCCIAA] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[OE_PIVA] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[OE_RagSoc] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[OE_SedeCCIAA] [nvarchar](4000) collate DATABASE_DEFAULT NULL,
								[OE_IDENTIFIER_EO] [nvarchar](4000) collate DATABASE_DEFAULT NULL
							)  
				
						--insert into #Temp_Default_Value select top 0 '' as id,'' as errore from aziende 
				
						--chiamo la stored di controllo specifica
		insert into #Temp_Default_Value  
					--([BANDO_CIG] ,[BANDO_CUP] ,[BANDO_Oggetto], [BANDO_Titolo],
					--[BANDO_LOTTO_CIG],[BANDO_NumeroGara],[BANDO_RUP],[BANDO_RUP_TEL]
					--,[BANDO_RUP_MAIL],[Ente_Indirizzo],[Ente_Localita],[Ente_CAP],[Ente_SitoWeb],
					--[Ente_CUC_CF],[Ente_CUC_RagSoc],[Ente_CF],[Ente_RagSoc] ,[Ente_Stato],
					--[OE_aziCAPLeg],[OE_aziE_Mail],[OE_aziIndirizzoLeg],[OE_aziProvinciaLeg],
					--[OE_aziStatoLeg],[OE_IscrCCIAA],[OE_PIVA],[OE_RagSoc],[OE_SedeCCIAA],[OE_IDENTIFIER_EO])
				exec ESPD_FIELD_DEFAULT_VALUE   @idTemplate , @idUser
	

		--select * from #Temp_Default_Value



		-------------------------------------------
		-- recupero tutti gli elementi del template che hanno una sorgente che hanno un acorrispondenza con gli attributi del modello
		-------------------------------------------
		declare CurTemplateRequest Cursor local static for 
		
			select 'MOD_' +  replace(k.value, '.','_') as Modulo ,  G.SorgenteCampo , 
					'MOD_' +  replace(k.value, '.','_') +  '_FLD_'  + dbo.GetID_ElementModulo(itemPath,ItemLevel,TypeRequest) as MA_DZT_Name
					, isnull(Obbligatorio,'') as Obbligatorio
				--, MA_DZT_Name , isnull( [MAP_Value] , '1' )  as Editabile
				from CTL_DOC_Value t with(nolock) 
					--inner join CTL_DOC_Value d  with(nolock) on t.idheader = d.idheader and t.Row = d.Row and d.DSE_ID = 'VALORI' and d.DZT_Name = 'DescrizioneEstesa'
					--inner join CTL_DOC_Value a  with(nolock) on t.idheader = a.idheader and t.Row = a.Row and a.DSE_ID = 'VALORI' and a.DZT_Name = 'TEMPLATE_REQUEST_GROUP'
					inner join CTL_DOC_Value k  with(nolock) on t.idheader = k.idheader and t.Row = k.Row and k.DSE_ID = 'VALORI' and k.DZT_Name = 'KeyRiga'
					inner join CTL_DOC_Value M  with(nolock) on t.idheader = M.idheader and t.Row = M.Row and M.DSE_ID = 'VALORI' and M.DZT_Name = 'IdModulo'

					inner join DOCUMENT_REQUEST_GROUP G  with(nolock) on G.idheader = M.value
						--@idTemplate
			where t.idHeader=@idTemplate and t.DSE_ID = 'VALORI' and t.DZT_Name = 'REQUEST_PART' 
					and isnull( G.SorgenteCampo , '' ) <> ''
					and InCAricoA='Ente'

			--order by t.Row
			order by 'MOD_' +  replace(k.value, '.','_') 

		set @ModuloCurr = ''
		set @FieldObbligModulo = ''
		open CurTemplateRequest

		FETCH NEXT FROM CurTemplateRequest 	INTO @Modulo , @SorgenteCampo , @MA_DZT_Name , @Obblig
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			--se sono al primo giro valorizzo il modulo corrente
			if @ModuloCurr = '' 
				set @ModuloCurr = @Modulo

			-- se il valore esiste <> da vuoto lo lascia
			-- se è vuoto lo inizializza
			-- se non esiste lo crea inizializzato	
			set @Value = null
			set @ix = null

			select @Value = Value , @ix = idrow from CTL_DOC_Value where IdHeader = @idDocInUse and DSE_ID = 'MODULO' and DZT_Name = @MA_DZT_Name

			-- devo inizializzare il campo
			-- se devo svuotare forzo ad entrare perchè li ho lasciati vuoti
			if isnull( @Value , '' ) = '' --or  @Editabile = '0' or @Svuota_Valori = 1
			begin
			
				--preventivamente lo cancello
				--delete from CTL_DOC_Value where IdHeader = @idDocInUse and DSE_ID = 'MODULO' and DZT_Name = @MA_DZT_Name

				-- recupero il valore richiesto
				--exec ' select @Valore=' + @MA_DZT_Name + ' from #Temp_Default_Value ' 

				-- lo inserisco
				if @ix is null
				begin
					BEGIN TRY
						set @sqldinamico =  '
						
									insert into CTL_DOC_Value
											( IdHeader, DSE_ID, Row, DZT_Name, Value )
											select ' + cast(@idDocInUse as varchar(10)) + ' as IdHeader, ''MODULO'' as  DSE_ID, 0 as [Row], 
												''' + 	@MA_DZT_Name + ''' as DZT_Name, ' + @SorgenteCampo + '
											from #Temp_Default_Value 		
											'
						exec (@sqldinamico)
					END TRY
					BEGIN CATCH
					END CATCH
				end
				--else
				--	update CTL_DOC_Value set Value = @Valore where IdRow = @ix

			end

		
			
			--a rottura di modulo inserisco nella ctl_doc_value 
			--il campo OBBLIGATORI per il modulo
			if @ModuloCurr <> @Modulo
			begin
			
				--inserisco entrata OBBLIGATORI per modulo @ModuloCurr
				if @FieldObbligModulo <> ''
				begin
					insert into ctl_doc_Value 
							(IdHeader , dse_id,row,dzt_name,value)
							values
							(@idDocInUse,'OBBLIGATORI',0,@ModuloCurr,'[' + @FieldObbligModulo + ']')	

				end
			
				set @FieldObbligModulo = ''
				set @ModuloCurr = @Modulo

			end
		
			--se il campo obbligatorio lo aggiungo alla lista dei campi obblig del modulo 
			if @Obblig = '1'
			begin
				if @FieldObbligModulo <> ''
					set @FieldObbligModulo = @FieldObbligModulo + ','
				set @FieldObbligModulo = @FieldObbligModulo + '~~~' + @MA_DZT_Name + '~~~'
				--~~~MOD_B_2_1_FLD_G1_R1~~~,~~~MOD_B_2_1_FLD_G1_R2~~~
			end
		
	             

			FETCH NEXT FROM CurTemplateRequest 	INTO @Modulo , @SorgenteCampo , @MA_DZT_Name , @Obblig
		END 
		CLOSE CurTemplateRequest
		DEALLOCATE CurTemplateRequest

		--se ho campi obblig faccio ultimo 
		if @FieldObbligModulo <> ''
		begin
			insert into ctl_doc_Value 
					(IdHeader , dse_id,row,dzt_name,value)
					values
					(@idDocInUse,'OBBLIGATORI',0,@ModuloCurr,'[' + @FieldObbligModulo + ']')	

		end

		drop table #Temp_Default_Value
	
	end



end




























GO
