USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_Rpt_RegIscr_Full]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[DASHBOARD_SP_Rpt_RegIscr_Full] 
(@IdPfu							int,
 @AttrName						varchar(8000),
 @Param							varchar(8000),
 @FilterHide                    varchar(8000)
 )
as
SET NOCOUNT ON

	declare @SQLCmd                 varchar(4000)

	DECLARE @SQLFilterT                                     VARCHAR(8000)

	declare @Periodo   varchar(50)
	declare @SiglaProvincia varchar(50)
	declare @TipoUtente varchar(150)
	declare @ClasseMerce varchar(4000)
	declare @Qta varchar (50)	

	declare @Colonna varchar (50)	
	
	DECLARE @count_loop		INT	
	DECLARE @posOp          INT
	DECLARE @len            INT
	DECLARE @condition	varchar (10)

	if @Param <> ''
	begin 
		set @Periodo		= dbo.GetParam( 'Periodo' , @Param ,1)
		set @SiglaProvincia = dbo.GetParam( 'SiglaProvincia' , @Param ,1)
		set @TipoUtente		= dbo.GetParam( 'TipoUtente' , @Param ,1)
		set @ClasseMerce    = dbo.GetParam( 'ClasseMerce' , @Param ,1)
		set @Qta			= dbo.GetParam( 'Qta' , @Param ,1)
	end

	set @SQLCmd = 'select Periodo, ClasseMerce, SiglaProvincia, TipoUtente, sum( Qta ) as Qta  from DASHBOARD_VIEW_Rpt_RegIscr_Full '


	set @SQLFilterT = ''
	
	if @Periodo <> '' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' Periodo = ''' + @Periodo  + ''' and '
	end

	---------- Lista province selezionate: ....(SiglaProvincia = 'XX' OR SiglaProvincia = 'YY') AND
	set @posOp = 1
	---- recupero nr. di province selezionate
	set @count_loop = dbo.ufn_CountString(@SiglaProvincia, '###') - 1 
	if @count_loop > 0
	begin
		set @SQLFilterT = @SQLFilterT +  '('
	end
	while @count_loop > 0
	begin
		if @count_loop = 1
		begin
			set @condition = ') AND '		---- ultima o unica provincia selezionata
		end			
		else
			set @condition = ' OR '
		set @len = 	charindex('###', @SiglaProvincia, @posOp + 3) - (@posOp + 3)	
		set @SQLFilterT = @SQLFilterT + ' SiglaProvincia = ''' +  SUBSTRING(@SiglaProvincia, @posOp + 3, @len) + '''' + @condition
		set @count_loop = @count_loop - 1
		set @posOp = @posOp + @len + 3
	end
------------------------------------------------------------------------------------

	if @TipoUtente <> '' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' TipoUtente = ''' + @TipoUtente  + ''' and '
	end

	if @ClasseMerce <> '' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' charindex( ''#'' + ClasseMerce + ''#'' , ''#' + @ClasseMerce  + '#'' ) > 0  and '
	end

	if @Qta <> '' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' Qta = ''' + @Qta  + ''' and '
	end

	if @SQLFilterT <> ''
	begin 
		set @SQLCmd = @SQLCmd + ' where ' +  left( @SQLFilterT , len(@SQLFilterT ) - 3)
	end

	if @FilterHide <> ''
	begin 
		if @SQLFilterT <> ''
		begin 
			set @SQLCmd = @SQLCmd + ' and ' +  @FilterHide
		end
		else
		begin 
			set @SQLCmd = @SQLCmd + ' where ' +  @FilterHide
		end
	end

	
	set @SQLCmd = @SQLCmd + ' group by Periodo, ClasseMerce, SiglaProvincia, TipoUtente'

----PRINT @SQLCmd

	EXEC (@SQLCmd)

GO
