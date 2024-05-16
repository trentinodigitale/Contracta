USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DASHBOARD_SP_MASTER_PLAN]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE proc [dbo].[OLD_DASHBOARD_SP_MASTER_PLAN]
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
begin

	declare @Param varchar(max)

	set nocount on

	--set @Param = Replace(@AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp,' ','')
	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp

	

    declare @DataDa					as varchar(1500)
	declare @DataA					as varchar(1500)
	declare @PrimoLivelloStruttura	as varchar(1500)
	declare @TIPO_AMM_ER			as varchar(1500)
	declare @AZI_Ente				as varchar(1500)
	declare @StatoFunzionale		as varchar(1500)
	declare @Macro_Convenzione		as varchar(1500)
	declare @IdentificativoIniziativa	as varchar(1500)
	declare @DomNumeroConvenzione	as varchar(max)

		
	--recupero i parametri di filtro
    set @DataDa					= dbo.GetParam( 'DataDa' , @Param ,1)
	set @DataA					= dbo.GetParam( 'DataA' , @Param ,1)
	set @PrimoLivelloStruttura	= dbo.GetParam( 'PrimoLivelloStruttura' , @Param ,1)
	set @TIPO_AMM_ER			= dbo.GetParam( 'TIPO_AMM_ER' , @Param ,1)
	set @AZI_Ente				= dbo.GetParam( 'AZI_Ente' , @Param ,1)
	set @StatoFunzionale		= dbo.GetParam( 'StatoFunzionale' , @Param ,1)

	set @Macro_Convenzione		= dbo.GetParam( 'Macro_Convenzione' , @Param ,1)
	
	set @DomNumeroConvenzione	= dbo.GetParam( 'DomNumeroConvenzione' , @Param ,1)
	set @IdentificativoIniziativa		= dbo.GetParam( 'IdentificativoIniziativa' , @Param ,1)
	
	--print @DataDa
	--print @DataA

	declare @SQL_Filter	nvarchar(max)
	set @SQL_Filter = ''

	if @DataDa <> '' 
	begin
		set @DataDa = left( @DataDa , 10 ) 
		set @SQL_Filter = @SQL_Filter + ' and  convert( varchar(10) ,  rda_datascad , 121 )  >= ''' + @DataDa + ''' ' 
	end

	if @DataA <> '' 
	begin
		set @DataA = left( @DataA , 10 ) 
		set @SQL_Filter = @SQL_Filter + ' and  convert( varchar(10) , rda_datacreazione , 121 )<= ''' + @DataA + ''' ' 
	end


	if @AZI_Ente <> ''
	begin
		set @SQL_Filter = @SQL_Filter + ' and  r.Azienda in ( -1 ' + replace( @AZI_Ente , '###' , ',' ) + ' -2 ) '
	end

	--if @PrimoLivelloStruttura <> ''
	--begin
	--	set @SQL_Filter = @SQL_Filter + ' and  SUBSTRING ( dmv_father ,1 , charindex(''-'',dmv_father)-1 ) = ''' + @PrimoLivelloStruttura + ''' '
	--end

	if @PrimoLivelloStruttura <> ''
	begin
		set @SQL_Filter = @SQL_Filter + ' and  SUBSTRING ( dmv_father ,1 , charindex(''-'',dmv_father)-1 )  in  ( ''-1' + replace( @PrimoLivelloStruttura , '###' , ''',''' ) + '-2'' ) '
	end


	--if @TIPO_AMM_ER <> ''
	--begin
	--	set @SQL_Filter = @SQL_Filter + ' and   d1.vatValore_FT = ''' + @TIPO_AMM_ER + ''' '
	--end


	if @TIPO_AMM_ER <> ''
	begin
		set @SQL_Filter = @SQL_Filter + ' and   d1.vatValore_FT in  ( ''-1' + replace( @TIPO_AMM_ER , '###' , ''',''' ) + '-2'' ) '
	end


	if @StatoFunzionale <> ''
	begin
		set @SQL_Filter = @SQL_Filter + ' and   c.StatoFunzionale = ''' + @StatoFunzionale + ''' '
	end

	if @Macro_Convenzione <> ''
	begin
		set @SQL_Filter = @SQL_Filter + ' and  co.Macro_Convenzione in ( ''-1 ' + replace( @Macro_Convenzione , '###' , ''',''' ) + '-2'' ) '
	end

	if @DomNumeroConvenzione <> ''
	begin
		set @SQL_Filter = @SQL_Filter + ' and  co.NumOrd in ( ''-1' + replace( @DomNumeroConvenzione , '###' , ''',''' ) + '-2'' ) '
	end

	if @IdentificativoIniziativa <> ''
	begin
		set @SQL_Filter = @SQL_Filter + ' and  co.IdentificativoIniziativa = ''' + @IdentificativoIniziativa + ''' '
	end


	--print '	exec DASHBOARD_SP_MASTER_PLAN_SUB '' , 0 , ''' + @SQL_Filter + ''' , ''' + @Sort + ''' '
	exec DASHBOARD_SP_MASTER_PLAN_SUB '' , 0 , @SQL_Filter ,@Sort, @IdPfu

end






GO
