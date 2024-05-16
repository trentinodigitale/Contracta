USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_Rpt_ProcNeg]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[DASHBOARD_SP_Rpt_ProcNeg] 
(@IdPfu							int,
 @AttrName						varchar(8000),
 @AttrValue						varchar(8000),
 @AttrOp 						varchar(8000),
 @Filter                        varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output
)
as
SET NOCOUNT ON

	declare @SQLCmd                 varchar(4000)

	DECLARE @SQLFilterT                                     VARCHAR(8000)

	declare @Name   varchar(150)
	declare @Oggetto varchar(150)
	declare @AZI_Ente2 varchar(4000)
	declare @ProtocolloBando varchar(20)
	declare @CIG varchar (15)	
	declare @TipoProcedura_KPI varchar(20)
	declare @Tipologia_KPI varchar (20)	

	declare @Colonna varchar (50)	
	
	DECLARE @Expirydate               VARCHAR(20)
	DECLARE @ExpirydateAl             VARCHAR(20)
	DECLARE @DataAperturaOfferte      VARCHAR(20)
	DECLARE @DataAperturaOfferteAl    VARCHAR(20)
	DECLARE @DivisioneInLotti		VARCHAR(20)
	
	DECLARE @count_loop		INT	
	DECLARE @posOp          INT
	DECLARE @len            INT
	DECLARE @condition	varchar (10)
	declare @Param varchar(8000)

        SET @Expirydate = ''
        SET @ExpirydateAl = ''
        
	if @AttrValue <> ''
	 
	begin 
		set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp
		set @AttrValue = @Param

		set @Name				= dbo.GetParam( 'Name' , @AttrValue ,1)
		set @Oggetto			= dbo.GetParam( 'Oggetto' , @AttrValue ,1)
		set @AZI_Ente2			= dbo.GetParam( 'AZI_Ente2' , @AttrValue ,1)
		set @ProtocolloBando	= dbo.GetParam( 'ProtocolloBando' , @AttrValue ,1)
		set @CIG				= dbo.GetParam( 'CIG' , @AttrValue ,1)
		set @TipoProcedura_KPI	= dbo.GetParam( 'TipoProcedura_KPI' , @AttrValue ,1)
		set @Tipologia_KPI		= dbo.GetParam( 'Tipologia_KPI' , @AttrValue ,1)
		set @Expirydate		        = dbo.GetParam( 'Expirydate' , @AttrValue ,1)
		set @ExpirydateAl		= dbo.GetParam( 'ExpirydateAl' , @AttrValue ,1)
		set @DataAperturaOfferte	= dbo.GetParam( 'DataAperturaOfferte' , @AttrValue ,1)
		set @DataAperturaOfferteAl	= dbo.GetParam( 'DataAperturaOfferteAl' , @AttrValue ,1)
		set @DivisioneInLotti	= dbo.GetParam( 'Qualita' , @AttrValue ,1)
	end

	set @SQLCmd = 
			'SELECT
			ID,
			TipoProcedura_KPI,
			DivisioneInLotti,
			NumLotti, 
			Tipologia_KPI, 
			Name, 
			Oggetto, 
			CIG, 
			ProtocolloBando, 
			AZI_Ente2 as AZI_Ente, 
			pfuE_Mail, 
			pfuNome, 
			DataPubblicazioneBando, 
			ExpiryDate, 
			ExpiryDateAl, 
			DataAperturaOfferte, 
			DataAperturaOfferteAl, 
			importoBaseAsta,
			QtaAziInvitate,     
			QtaOffRicevute,
			Num	
			from DASHBOARD_VIEW_Rpt_ProcNeg '	

	set @SQLFilterT = ''
	
-- INIZIO SETTING FILTRI -----------------------------------------------------
	if @Name <> '' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' Name LIKE ''' + @Name  + ''' AND '
	end

	if @Oggetto <> '' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' Oggetto LIKE ''' + @Oggetto  + ''' AND '
	end

	---------- inizio setting lista enti selezionati: ....(AZI_Ente2 = 'XX' OR AZI_Ente2 = 'YY') AND
	set @posOp = 1
	---- recupero nr. di enti selezionati
	set @count_loop = dbo.ufn_CountString(@AZI_Ente2, '###') - 1 
	if @count_loop > 0
	begin
		set @SQLFilterT = @SQLFilterT +  '('
	end
	while @count_loop > 0
	begin
		if @count_loop = 1
		begin
			set @condition = ') AND '		---- ultimo o unico ente selezionato
		end			
		else
			set @condition = ' OR '
		set @len = 	charindex('###', @AZI_Ente2, @posOp + 3) - (@posOp + 3)	
		set @SQLFilterT = @SQLFilterT + ' AZI_Ente2 = ''' +  SUBSTRING(@AZI_Ente2, @posOp + 3, @len) + '''' + @condition
		set @count_loop = @count_loop - 1
		set @posOp = @posOp + @len + 3
	end
	---------- fine setting lista enti selezionati
	if @ProtocolloBando <> '' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' ProtocolloBando LIKE ''' + @ProtocolloBando  + ''' AND '
	end

	if @CIG <> '' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' CIG LIKE ''' + @CIG  + ''' AND '
	end

	if @TipoProcedura_KPI <> '' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' TipoProcedura_KPI = ''' + @TipoProcedura_KPI  + ''' AND '
	end

	if @Tipologia_KPI <> '' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' Tipologia_KPI = ''' + @Tipologia_KPI  + ''' AND '
	end

	if @Expirydate <> '' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' LEFT(ExpiryDate, 10)  >= ''' + LEFT(@Expirydate, 10)  + ''' AND '
	end

	if @ExpirydateAl <> '' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' LEFT(ExpiryDateAl, 10)  <= ''' + LEFT(@ExpirydateAl, 10)  + ''' AND '
	end

	if @DataAperturaOfferte <> '' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' LEFT(DataAperturaOfferte, 10)  >= ''' + LEFT(@DataAperturaOfferte, 10)  + ''' AND '
	end

	if @DataAperturaOfferteAl <> '' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' LEFT(DataAperturaOfferteAl, 10)  <= ''' + LEFT(@DataAperturaOfferteAl, 10)  + ''' AND '
	end

	if @DivisioneInLotti = 'si' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' DivisioneInLotti = ''si'' AND '
	end

	if @DivisioneInLotti = 'no' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' DivisioneInLotti = '''' AND '
	end

-- FINE SETTING FILTRI -----------------------------------------------------
	
	if @SQLFilterT <> ''	-- @SQLFilterT contiene la stringa relativa alla where condition
	begin 
		set @SQLCmd = @SQLCmd + ' WHERE ' +  left( @SQLFilterT , len(@SQLFilterT ) - 3)
	end

	if @Filter <> ''
	begin 
		if @SQLFilterT <> ''
		begin 
			set @SQLCmd = @SQLCmd + ' AND ' +  @Filter
		end
		else
		begin 
			set @SQLCmd = @SQLCmd + ' WHERE ' +  @Filter
		end
	end

	IF @Sort <> ''
        SET @SQLCmd = @SQLCmd + ' ORDER BY ' + @Sort

	
--PRINT @SQLCmd


	EXEC (@SQLCmd)










GO
