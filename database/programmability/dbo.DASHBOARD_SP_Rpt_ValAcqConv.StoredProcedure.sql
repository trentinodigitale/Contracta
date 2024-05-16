USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_Rpt_ValAcqConv]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[DASHBOARD_SP_Rpt_ValAcqConv] 
(@IdPfu							int,
 @AttrName						varchar(8000),
 @Param							varchar(8000),
 @FilterHide                    varchar(8000)
 )
as
SET NOCOUNT ON

	declare @SQLCmd				varchar(4000)
	DECLARE @SQLFilterT			VARCHAR(8000)
	
	declare @SQLCmd2			varchar(4000)
	declare @SQLCmd3			varchar(4000)
	DECLARE @SQLFilterT2        VARCHAR(8000)
	DECLARE @SQLFilterT3        VARCHAR(100)
	declare @SQLCmd2a			varchar(7)

	declare @Id_Convenzione		varchar(15)
	declare @Data_from			varchar(10)
	declare @Data_to			varchar(10)


	if @Param <> ''
	begin 
		set @Id_Convenzione 	= dbo.GetParam( 'Convenzione' , @Param ,1)
		---- TEST set @Id_Convenzione 	= 15
		set @Data_from 	= dbo.GetParam( 'Data' , @Param ,1)
		set @Data_to		= dbo.GetParam( 'DataF' , @Param ,1)
	end 

	----set @SQLCmd = 'select Convenzione,	DenominazioneEnte, Periodo, Periodo as Periodo_Sort, RDA_Total, Qta, PercQta from DASHBOARD_VIEW_Rpt_ValAcqConv '
	set @SQLCmd = 'select Convenzione,	DenominazioneEnte, Periodo, Periodo as Periodo_Sort, RDA_Total, Qta from DASHBOARD_VIEW_Rpt_ValAcqConv '

	set @SQLFilterT = ''
	
	if @Id_Convenzione <> '' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' Convenzione = ''' + @Id_Convenzione  + ''' and '
	end
	else
	begin
		set @SQLFilterT = @SQLFilterT + ' Convenzione = ''' + '0'  + ''' and '
	end

	if @Data_from <> '' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' Periodo >= ''' + CONVERT(VARCHAR(7), @Data_from, 120)  + ''' and '
	end

	if @Data_to <> '' 
	begin 
		set @SQLFilterT = @SQLFilterT + ' Periodo <= ''' + CONVERT(VARCHAR(7), @Data_to, 120)  + ''' and '
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
	
	set @SQLCmd = @SQLCmd 
	
	--------- aggiungo totale valore acquisti "Fino al AAAA-MM" per ciascun ente se @Data_from > data inizio contratto
	if @Data_from <> '' and 
		@Data_from > (SELECT CONVERT(VARCHAR(7), DataInizio, 120)
						FROM Document_Convenzione where ID = @Id_Convenzione)
	begin 
		set @SQLCmd2a = CONVERT(VARCHAR(7), dateadd(month, -1, @Data_from), 120)
		set @SQLCmd2 = 'select Convenzione, DenominazioneEnte, '+ 
		'''Fino al ' + @SQLCmd2a + '''' + ' AS Periodo,' + 
		'''1900-01''' + ' AS Periodo_Sort,' +
		------'sum(RDA_Total) as RDA_Total, sum(Qta) as Qta, sum(PercQta) as PercQta  from DASHBOARD_VIEW_Rpt_ValAcqConv ' +
		'sum(RDA_Total) as RDA_Total, sum(Qta) as Qta  from DASHBOARD_VIEW_Rpt_ValAcqConv ' +
		' WHERE Convenzione = ''' + @Id_Convenzione  + ''' and  Periodo < ''' + CONVERT(VARCHAR(7), @Data_from, 120)+ 
		''' group by Convenzione, DenominazioneEnte, Periodo'
		set @SQLCmd =  @SQLCmd2 + ' UNION ' + @SQLCmd
	end

	--------- aggiungo colonna "TOTALI" (di riga)
	set @SQLFilterT3 = ' '
	if @Data_to <> '' 
	begin 
		set @SQLFilterT3 = ' and  Periodo <= ' + '''' + CONVERT(VARCHAR(7), @Data_to, 120) + ''''
	end
	set @SQLCmd3 = 'select Convenzione, DenominazioneEnte, '+ 
	'''TOTALI''' + ' AS Periodo,' +
	'''TOTALI''' + ' AS Periodo_Sort,' +
	------'sum(RDA_Total) as RDA_Total, sum(Qta) as Qta, sum(PercQta) as PercQta from DASHBOARD_VIEW_Rpt_ValAcqConv ' +
	'sum(RDA_Total) as RDA_Total, sum(Qta) as Qta from DASHBOARD_VIEW_Rpt_ValAcqConv ' +
	' WHERE Convenzione = ' + '''' + @Id_Convenzione + ''''  + @SQLFilterT3 + ' group by Convenzione, DenominazioneEnte, Periodo'
	set @SQLCmd =  @SQLCmd + ' UNION ' + @SQLCmd3

	--------------- aggiungo colonna "%" (di riga) SOLO TEST!!!!
	------set @SQLFilterT3 = ' '
	------if @Data_to <> '' 
	------begin 
	------	set @SQLFilterT3 = ' and  Periodo <= ' + '''' + CONVERT(VARCHAR(7), @Data_to, 120) + ''''
	------end
	------set @SQLCmd3 = 'select Convenzione, DenominazioneEnte, '+ 
	------'''%''' + ' AS Periodo,' +
	------'''Z''' + ' AS Periodo_Sort,' +
	------'sum(RDA_Total) as RDA_Total, sum(PercQta) as Qta, sum(PercQta) as PercQta from DASHBOARD_VIEW_Rpt_ValAcqConv ' +
	------' WHERE Convenzione = ' + '''' + @Id_Convenzione + ''''  + @SQLFilterT3 + ' group by Convenzione, DenominazioneEnte, Periodo'
	------set @SQLCmd =  @SQLCmd + ' UNION ' + @SQLCmd3

--print @SQLCmd
EXEC (@SQLCmd)








GO
