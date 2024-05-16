USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_Rpt_ProcedureEnte]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[DASHBOARD_SP_Rpt_ProcedureEnte] 
(@IdPfu							int,
 @AttrName						varchar(8000),
 @Param							varchar(8000),
 @FilterHide                    varchar(8000)
 )
as
SET NOCOUNT ON

	declare @SQLCmd                 varchar(4000)

	DECLARE @SQLFilterT                                     VARCHAR(8000)

	declare @TipoProcedura   varchar(50)
	declare @Tipologia varchar(50)


	if @Param <> ''
	begin 
		set @TipoProcedura 	= dbo.GetParam( 'TipoProcedura_KPI' , @Param ,1)
		set @Tipologia		= dbo.GetParam( 'Tipologia_KPI' , @Param ,1)
	end 
	
	set @SQLCmd = 'select Periodo, sum(Importo) as Importo, TipoProcedura_KPI, Tipologia_KPI, sum( Qta ) as Qta, PercN_Bandi from DASHBOARD_VIEW_Rpt_ProcedureEnte '

	set @SQLFilterT = ''
	
	if @TipoProcedura <> '' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' TipoProcedura_KPI = ''' + @TipoProcedura  + ''' and '
	end

	if @Tipologia <> '' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' Tipologia_KPI = ''' + @Tipologia  + ''' and '
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
	
	set @SQLCmd = @SQLCmd + ' GROUP BY Periodo, TipoProcedura_KPI, Tipologia_KPI, PercN_Bandi'

--- print @SQLCmd

EXEC (@SQLCmd)



GO
