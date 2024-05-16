USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_Rpt_Fornitori_Merceologia]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[DASHBOARD_SP_Rpt_Fornitori_Merceologia] 
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
	declare @Territorio varchar(2)
	declare @TipoUtente varchar(150)
	declare @ClasseMerce2 varchar(4000)
	declare @Qta varchar (50)	

	declare @Colonna varchar (50)	
	
	DECLARE @count_loop		INT	
	DECLARE @posOp          INT
	DECLARE @len            INT
	DECLARE @condition	varchar (10)

	if @Param <> ''
	begin 
		set @Periodo		= dbo.GetParam( 'Periodo' , @Param ,1)
		set @Territorio     = dbo.GetParam( 'Territorio' , @Param ,1)
		set @TipoUtente		= dbo.GetParam( 'TipoUtente' , @Param ,1)
		set @ClasseMerce2    = dbo.GetParam( 'ClasseMerce2' , @Param ,1)
		set @Qta			= dbo.GetParam( 'Qta' , @Param ,1)
	end

	set @SQLCmd = 'select Periodo, TipoUtente, Territorio, ClasseMerce2, ClasseMerceDesc, ClasseMerceDesc_Sort, sum( Qta ) as Qta  from DASHBOARD_VIEW_Rpt_Fornitori_Merceologia '


	set @SQLFilterT = ''
	
	if @Periodo <> '' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' Periodo = ''' + @Periodo  + ''' and '
	end

	---------- Lista classi selezionate: ....(ClasseMerce2 = 'XX' OR ClasseMerce2 = 'YY') AND
	set @posOp = 1
	---- recupero nr. di ClasseMerce2 selezionate
	set @count_loop = dbo.ufn_CountString(@ClasseMerce2, '###') - 1 
	if @count_loop > 0
	begin
		set @SQLFilterT = @SQLFilterT +  '('
	end
	while @count_loop > 0
	begin
		if @count_loop = 1
		begin
			set @condition = ') AND '		---- ultima o unica ClasseMerce2 selezionata
		end			
		else
			set @condition = ' OR '
		set @len = 	charindex('###', @ClasseMerce2, @posOp + 3) - (@posOp + 3)	
		set @SQLFilterT = @SQLFilterT + ' ClasseMerce2 = ''' +  SUBSTRING(@ClasseMerce2, @posOp + 3, @len) + '''' + @condition
		set @count_loop = @count_loop - 1
		set @posOp = @posOp + @len + 3
	end
------------------------------------------------------------------------------------

	if @TipoUtente <> '' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' TipoUtente = ''' + @TipoUtente  + ''' and '
	end

	if @Territorio <> '' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' charindex( ''#'' + Territorio + ''#'' , ''#' + @Territorio  + '#'' ) > 0  and '
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

	
	set @SQLCmd = @SQLCmd + ' group by Periodo,TipoUtente,Territorio,ClasseMerce2,ClasseMerceDesc,ClasseMerceDesc_Sort'

--PRINT @SQLCmd

	EXEC (@SQLCmd)


GO
