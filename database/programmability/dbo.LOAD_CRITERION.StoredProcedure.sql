USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[LOAD_CRITERION]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE proc [dbo].[LOAD_CRITERION] ( @idUser int , @idDocOnly int = 0 ) as
begin


	declare @idDoc int 
	declare @idDoc_SUB int 
	declare @idrow int
	declare @REQUEST_GROUP_Categoria nvarchar(500)
	declare @guid nvarchar(500)

	set @idDoc = @idDocOnly
	set @idDoc_SUB = @idDoc 

	declare @Level int
	declare @Element		nvarchar(500)
	declare @Name			nvarchar(max)
	declare @Description	nvarchar(max)
	declare @Description_UK	nvarchar(max)

	declare @ElementCode	nvarchar(max)
	declare @A				nvarchar(max)
	declare @B				nvarchar(max)
	declare @Z				nvarchar(max)
	declare @Y				nvarchar(max)

	declare @DataType		nvarchar(500)

	declare @Cardinality	nvarchar(500)
	declare @TypeRequest    varchar(100)
	declare @RG_FLD_TYPE    varchar(100)
	declare @Related		varchar(100)
	declare @InCaricoA		varchar(100)
	declare @Iterabile		int 
	declare @Obbligatorio	int
	declare @SubCriterio	varchar(20)
	declare @OnlySubCriterio varchar(20)
	declare @Multivalore	int
	


	declare @PrefissoDoc	varchar (20)
	set @PrefissoDoc = 'EU211'

	set @Level  = 0


	-- cancello il pregresso del documento indicato
	if @idDocOnly > 0 
		delete from DOCUMENT_REQUEST_GROUP where idheader = @idDocOnly

	-- ciclo sulle righe caricate
	declare CurProg Cursor static for 
		select id 
			from CTL_Import
			where  idpfu = @idUser
			order by id

	open CurProg


	FETCH NEXT FROM CurProg 	INTO @idrow
	WHILE @@FETCH_STATUS = 0
	BEGIN

		select @Level = case 
							--when isnull( A , '' ) <> '' then 0
							when isnull( b , '' ) <> '' then 1
							when isnull( c , '' ) <> '' then 2
							when isnull( d , '' ) <> '' then 3
							when isnull( e , '' ) <> '' then 4
							when isnull( f , '' ) <> '' then 5
							when isnull( g , '' ) <> '' then 6
							when isnull( h , '' ) <> '' then 7
							when isnull( i , '' ) <> '' then 8
							when isnull( j , '' ) <> '' then 9
							when isnull( q , '' ) <> '' then 10
						end 
				, @Element =   [dbo].[NormStringExt] (  b+c+d+e+f+g+h+i+j+q   ,'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.:,;{~}' ) 
				, @Name = case when ltrim(isnull( AM , '' ) ) = '' then R else AM end ---- R  sostituita la caption dall'inglese all'italiano CONSERVARE LA SCrITTA IN INGLESE PER GESTIRE ILML
				, @Description = S
				--, @guid = W
				--, @ElementCode = X
				--, @DataType = V
				--, @Cardinality = U

				, @Description_UK = T
				, @guid = [dbo].[NormStringExt] ( X  ,'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.:,;{~}' ) --W
				, @ElementCode = [dbo].[NormStringExt] ( Y  ,'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.:,;{~}' )   ---Y -- X
				, @DataType = W -- V
				, @Cardinality = V -- U
				, @A = ltrim(rtrim(A))
				, @Z = Z
				, @Y = Y
				, @B = B

			from CTL_Import 
			where id = @idrow
	
		if isnull( @Description , '' ) = '' 
			set @Description = @Description_UK

		if @Element <> ''  and @Level > 0 and not (  @a = '1' and @b = '2' )
		begin

			set @Level = @Level - 1

			if @Element = '{CRITERION' 
			begin

				
				-- se il rigo è riferito ad un criterio vedo se esiste nel DB altrimenti lo creo
				if @idDocOnly <= 0 
				begin
					set @IdDoc = null
					select @IdDoc = id from CTL_DOC where Tipodoc = 'TEMPLATE_REQUEST_GROUP' and deleted = 0 and Titolo like @PrefissoDoc + ' -' + right( '00' + @A , 2 )  + '-%' 
					if @IdDoc is null 
					begin 

						insert into ctl_doc ( [TipoDoc] , [Titolo] , [StatoFunzionale] , [LinkedDoc] , JumpCheck , [Versione] ) 
									values ( 'TEMPLATE_REQUEST_GROUP' , @PrefissoDoc + ' -' + right( '00' + @A , 2 )   + '-' + @ElementCode , 'InLavorazione' , @iddoc , 'DGUE' , right( '00' + dbo.getPos( @A ,'_' ,  2 ) ,2 )) 
					
						set @idDoc = scope_identity()
					end
				end 

				set @idDoc_SUB = @idDoc 

				-- elimino le righe precedenti
				delete from DOCUMENT_REQUEST_GROUP where idheader = @idDoc
		
				update d set  body = @Name , Note = @Description , numerodocumento = @guid , Titolo = @PrefissoDoc + ' -' + right( '00' + @A , 2 )  + '- ' + @ElementCode ,  idpfu = abs(@idUser)
					from ctl_doc d
						inner join ctl_import i on i.id = @idrow
						where d.id = @idDoc


				set @REQUEST_GROUP_Categoria = 		 dbo.getPos( @ElementCode, '.' , 1 ) + '.' + dbo.getPos( @ElementCode , '.' , 2 ) 

				update CTL_DOC_Value set value = @REQUEST_GROUP_Categoria  where IdHeader = @idDoc and DZT_Name = 'REQUEST_GROUP_Categoria' and DSE_ID = 'TIPOLOGIA' 

			end
			else
			begin

				-- se l'elemento è la chiusura di un sottocriterio si torna a popolare il criterio principale -- non è possibile avere sottocriteri di sottocriteri
				if @Element = 'SUBCRITERION}' 
				begin 
					exec CRITERIA_CALC_PATH @idDoc_SUB
					set @idDoc_SUB = @idDoc 
				end

				-- se l'elemento è la chiusura di un scriterio si calcola il path
				if @Element = 'CRITERION}' 
				begin 
					exec CRITERIA_CALC_PATH @idDoc 
				end

				-- se l'elemento è quello di aprtura si gestisce, quelli di chiusura non hanno informazioini
				if @Element like '{%'
				begin

		
					-- i sotto criteri vengono caricati completamente in documenti correlati
					if @Element = '{SUBCRITERION' and @A <> ''
					begin

						-- verifico se fra i sottocriteri esistenti è già presente nel caso recupero l'id, altrimenti lo creo
						set @idDoc_SUB = null
						set @SubCriterio = right( '00' + dbo.getPos( @A ,'_' ,  1 ) ,2 ) + '_' + right( '00' + dbo.getPos( @A ,'_' ,  2 ) ,2 ) 
						set @OnlySubCriterio =  right( '00' + dbo.getPos( @A ,'_' ,  2 ) ,2 ) 

						
						declare  @LenS int
						set @LenS = len( @PrefissoDoc + ' -' + @SubCriterio  + '-')

						select @idDoc_SUB = id from ctl_doc with( nolock ) where tipodoc = 'TEMPLATE_REQUEST_GROUP' and linkeddoc = @idDoc and deleted = 0 and  Versione = @OnlySubCriterio --left( Titolo , @LenS ) =  @PrefissoDoc + ' -' + @SubCriterio  + '-' 

						-- se il documento non esiste viene creato
						if @idDoc_SUB is null 
						begin
							insert into ctl_doc ( [TipoDoc] , [Titolo] , [StatoFunzionale] , [LinkedDoc] , JumpCheck , [Versione] ) 
								values ( 'TEMPLATE_REQUEST_GROUP' , @PrefissoDoc + ' -' + @SubCriterio  + '- ' + @Name  , 'InLavorazione' , @iddoc , 'DGUE' , @OnlySubCriterio ) 
							set @idDoc_SUB = scope_identity()
						end

						delete from DOCUMENT_REQUEST_GROUP where idheader = @idDoc_SUB
						update d set  body = @Name , Note = @Description , numerodocumento = @guid , JumpCheck = 'DGUE' , idpfu = abs(@idUser)
							from ctl_doc d
								where d.id = @idDoc_SUB


					end
					else 
					begin

						set @TypeRequest = case 
								--when @Element = '{SUBCRITERION' then 'G'

								when @Element = '{QUESTION_GROUP' then 'K' --'G'
								when @Element = '{QUESTION_SUBGROUP' then 'G'
								when @Element = '{QUESTION}' then 'R'

								when @Element = '{REQUIREMENT_GROUP' then 'T' --'Q'
								when @Element = '{REQUIREMENT_SUBGROUP' then 'Q'
								when @Element = '{REQUIREMENT}' then 'M'

								when @Element = '{CAPTION}' then 'C'
								when @Element = '{LEGISLATION}' then 'L'
								when @Element = '{ADDITIONAL_DESCRIPTION_LINE}' then 'A'
								else ''
							end


						set @RG_FLD_TYPE = case 
								When @DataType = 'DATE' then 'Date'
								When @DataType = 'AMOUNT' then 'AMOUNT' -- 'Currency'
								When @DataType = 'QUANTITY' then 'QUANTITY' -- 'Number_F'
					
								When @DataType = 'PERCENTAGE' then 'PERCENTAGE' --'Number_F'
					
								When @DataType = 'QUANTITY_INTEGER' then 'QUANTITY_INTEGER' -- Number_I'
								When @DataType = 'QUANTITY_YEAR' then 'QUANTITY_YEAR' --'Year'
					
								When @DataType = 'CODE_COUNTRY' then 'CODE_COUNTRY' --'Country'
								When @DataType in (  'INDICATOR' ) then 'INDICATOR' --'SiNo'
								When @DataType in (  'WEIGHT_INDICATOR' ) then 'WEIGHT_INDICATOR' --'SiNo'

								When @DataType in (  'CODE_BOOLEAN' ) and ( @Z = 'BooleanGUIControlType' or @Y = 'BooleanGUIControlType' ) then 'CODE_BOOLEAN_TYPE_REQUIREMENT' 
								When @DataType in (  'CODE_BOOLEAN' ) and not ( @Z = 'BooleanGUIControlType' or @Y = 'BooleanGUIControlType' ) then 'CODE_BOOLEAN'  -- caso non presente nella tassonomia

								--When @DataType = 'Si / No / Non Applicabile' then 'SiNoAltro'
								When @DataType = 'DESCRIPTION' then 'Text' --( trattare nel codice c'è una sovrapposizione
								--When @DataType = 'Text Area' then 'TextArea'


								When @DataType = 'CODE' AND ( @Description LIKE '%cpv%' or @Z = 'CPVCodes' or @y = 'CPVCodes' ) then 'CPVCodes'  -- 'CODE_CPV'        -- CPVCodes
								--When @DataType = 'CODE' AND @Description LIKE '%Business%' then 'CODE_BD'    -- BidType
								--When @DataType = 'CODE' AND @Description LIKE '%insurance%' then 'CODE_TI'   -- CODE_FinancialRatioType
								--When @DataType = 'CODE' AND @Description LIKE '%Tender%' then 'CODE_TS'
								When @DataType = 'CODE' AND ( @Description LIKE '%Tipo Indice%' or @Y = 'FinancialRatioType' or @Z  = 'FinancialRatioType' ) then 'CODE_FinancialRatioType'
								When @DataType = 'CODE' AND ( @Description LIKE '%role of the economic operator%' or @Y = 'EORoleType' or @Z = 'EORoleType' ) then 'CODE_EORoleType'
								When @DataType = 'CODE' AND (  @Description LIKE '%inserire offerta per%' or @Y = 'BidType' or @Z = 'BidType' )  then 'CODE_BidType'

		--64	BidType
		--61	CPVCodes
		--61	CPVCodes
		--59	EORoleType
		--34	FinancialRatioType
		--32	CPVCodes
		--31	CPVCodes
						

								When @DataType = 'PERIOD'  then 'PERIOD'

								When @DataType = 'LOT_IDENTIFIER'  then 'IDENTIFIER_LOT'
								When @DataType = 'IDENTIFIER' AND @Description LIKE '%LOT%' then 'IDENTIFIER_LOT'

								When @DataType = 'ECONOMIC_OPERATOR_IDENTIFIER'  then 'IDENTIFIER_EO'
								When @DataType = 'IDENTIFIER' AND @Description NOT LIKE '%LOT%' then 'IDENTIFIER_EO'


								When @DataType = 'URL'  then 'URL'
								When @DataType = 'MAXIMUM_AMOUNT'  then 'MAXIMUM_AMOUNT'
								When @DataType = 'MINIMUM_AMOUNT'  then 'MINIMUM_AMOUNT'
								When @DataType = 'MAXIMUM_VALUE_NUMERIC'  then 'MAXIMUM_VALUE_NUMERIC' --  NON TROVATO
								When @DataType = 'MINIMUM_VALUE_NUMERIC'  then 'MINIMUM_VALUE_NUMERIC' -- NON TROVATO
								When @DataType = 'TRANSLATION_TYPE_CODE'  then 'TRANSLATION_TYPE_CODE'
								When @DataType = 'CERTIFICATION_LEVEL_DESCRIPTION'  then 'CERTIFICATION_LEVEL_DESCRIPTION'
								When @DataType = 'COPY_QUALITY_TYPE_CODE'  then 'COPY_QUALITY_TYPE_CODE'
								When @DataType = 'TIME'  then 'TIME'
								When @DataType = 'EVIDENCE_IDENTIFIER'  then 'EVIDENCE_IDENTIFIER'

								When @DataType = 'QUAL_IDENTIFIER'  then 'QUAL_IDENTIFIER'

								else '' 
							end

			
						set @Related = case 
								when @ElementCode = 'ONTRUE' then 'GROUP_FULFILLED.ON_TRUE'
								when @ElementCode = 'ONFALSE' then 'GROUP_FULFILLED.ON_FALSE'
								else LTRIM(RTRIM(@Y))
							end

						set @InCaricoA = case 
								when @Element = '{REQUIREMENT}' then 'Ente' 
								when @Element = '{QUESTION}' then 'OE'
								when @Element like '%REQUIREMENT%' then 'Ente' 
								when @Element like '%QUESTION%' then 'OE'
								else ''
							end

						set @Iterabile = case when @Cardinality like '%n' then 1 else 0 end

						set @Obbligatorio = case when @Cardinality like '1%' then 1 else 0 end

						
						-- fanno eccezione agli iterabili i lotti e la CPV
						if @RG_FLD_TYPE in ( 'CPVCodes' , 'IDENTIFIER_LOT' ) and @Iterabile = 1
						begin
							set @Iterabile = 0
							set @Multivalore = 1
						end
						else
						begin
							set @Multivalore = 0
						end


						if @idDoc_SUB <> @idDoc 
							set @Level = @Level -1 -- se stiamo popolando un subcritrio  il livello deve essere decrementato

						insert into DOCUMENT_REQUEST_GROUP ( idheader , [ItemPath] , [TypeRequest] , [UUID] , [DescrizioneEstesa], [DescrizioneEstesaUK] , [RG_FLD_TYPE] , [Related] , ItemLevel , [Iterabile] , Obbligatorio, [InCaricoA] , Multivalore)			
			
							select  @idDoc_SUB,  '' as ItemPath , @TypeRequest , @guid , @Description , @Description_UK , @RG_FLD_TYPE  , @Related , @Level as ItemLevel , @Iterabile , @Obbligatorio , @InCaricoA , @Multivalore

					end
				end
			end
	
		end
			             
		FETCH NEXT FROM CurProg INTO @idrow
	END 

	CLOSE CurProg
	DEALLOCATE CurProg

	-- calcolo il path
	exec CRITERIA_CALC_PATH @idDoc

end
GO
