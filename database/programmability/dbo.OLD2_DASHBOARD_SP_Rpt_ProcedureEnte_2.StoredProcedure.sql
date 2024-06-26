USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_DASHBOARD_SP_Rpt_ProcedureEnte_2]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[OLD2_DASHBOARD_SP_Rpt_ProcedureEnte_2] 
(@IdPfu							int,
 @AttrName						varchar(8000),
 @Param							varchar(8000),
 @FilterHide                    varchar(8000)
 )
as
begin
	
	SET NOCOUNT ON

	declare @SQLCmd                 varchar(max)
	declare @SQLWhere		varchar(max)
	
	DECLARE @SQLFilterT                                     VARCHAR(max)

	declare @IdentificativoIniziativa   varchar(50)
	declare @EnteProponente				varchar(50)
	declare @AZI_Ente					varchar(50)

	declare @TIPO_AMM_ER varchar(50)
	declare @Annoda		varchar(50)
	declare @Annoa		varchar(50)
	declare @DescTipoProcedura varchar(max)




	if @Param <> ''
	begin 
		set @TIPO_AMM_ER 			= dbo.GetParam( 'TIPO_AMM_ER' , @Param ,1)
		set @Annoda					= dbo.GetParam( 'Annoda' , @Param ,0)
		set @Annoa					= dbo.GetParam( 'Annoa' , @Param ,0)
		set @IdentificativoIniziativa = dbo.GetParam( 'IdentificativoIniziativa' , @Param ,1)
		set @EnteProponente			= dbo.GetParam( 'EnteProponente' , @Param ,1)
		set @AZI_Ente				= dbo.GetParam( 'AZI_Ente' , @Param ,1)
		set @DescTipoProcedura		= dbo.GetParam( 'DescTipoProcedura' , @Param ,1)
	end 


	
	set @SQLCmd = '
	
	
	select 
			 
			 cast( substring(Periodo,0,5) as int) Annoda ,
			 cast ( substring(Periodo,0,5) as int ) Annoa ,
			 Periodo,
			 TIPO_AMM_ER ,
			 ProceduraGara ,
			 DescTipoProcedura,
			 TipoAppaltoGara ,
			 sum( Qta ) as Qta ,
			 sum( Num ) as Num ,
			 sum( ImportoAggiudicato ) as ImportoAggiudicato ,
			 sum( ValoreImportoLotto ) as ValoreImportoLotto ,
			 1 as NumGarePubb
		from 
		(
			SELECT   CONVERT( VARCHAR(7) , DataInvio , 121) AS Periodo ,
					 TIPO_AMM_ER ,
					 ProceduraGara  ,
					 TipoAppaltoGara ,
					 1 AS Qta ,
					 IsAggiudicato AS Num ,
					 DescTipoProcedura,
					 ValoreImportoLotto ,
					 id ,
					 CASE
						 WHEN IsAggiudicato = 1
						 THEN ImportoAggiudicato
						 ELSE 0
					 END AS ImportoAggiudicato
		 
				FROM DASHBOARD_VIEW_REPORT_LISTA_PROCEDURE
				where 1 = 1 


		'

	if @IdentificativoIniziativa <> ''
	begin
		set @SQLCmd = @SQLCmd + ' and IdentificativoIniziativa  = ''' + replace( @IdentificativoIniziativa , '''' , '''''' ) + '''  '
	end

	if @EnteProponente <> ''
	begin
		set @SQLCmd = @SQLCmd + ' and EnteProponente  = ''' + replace( @EnteProponente , '''' , '''''' ) + '''  '
	end

	if @AZI_Ente <> ''
	begin
		set @SQLCmd = @SQLCmd + ' and AZI_Ente  = ''' + replace( @AZI_Ente , '''' , '''''' ) + '''  '
	end

	if @TIPO_AMM_ER <> ''
	begin
		set @SQLCmd = @SQLCmd + ' and TIPO_AMM_ER  = ''' + replace( @TIPO_AMM_ER , '''' , '''''' ) + '''  '
	end

	if @Annoda <> ''
	begin
		set @SQLCmd = @SQLCmd + ' and year(DataInvio)  >= ' +  @Annoda + '  '
	end

	if @Annoa <> ''
	begin
		set @SQLCmd = @SQLCmd + ' and year(DataInvio)   <= ' +  @Annoa + '  '
	end

	if @DescTipoProcedura <> ''
	begin
		set @SQLCmd = @SQLCmd + ' and ''' + @DescTipoProcedura + ''' like ''%###'' + DescTipoProcedura + ''###%'' '
	end
	


	-- chiusura della query
	set @SQLCmd = @SQLCmd + '
		) as a
		group by
			id ,
			Periodo ,
			TIPO_AMM_ER ,
			ProceduraGara ,
			TipoAppaltoGara,
			DescTipoProcedura
	'



	--print @SQLCmd

	EXEC (@SQLCmd)

end

GO
