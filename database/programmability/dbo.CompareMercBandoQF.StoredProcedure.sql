USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CompareMercBandoQF]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[CompareMercBandoQF](@merc varchar(max),@merc_var varchar(max), @esito int output)  
as
begin

declare @str varchar(100)
DECLARE @i INT 
declare @pathMerc varchar(max)
declare @pathMerc_var varchar(max)

declare @sql varchar(max)

-- merceologia per cui il forn si è qualificato
--set @merc = '###26###282###285###'
-- merceologia variata
--set @merc_var = '###283###21###30###'

set @esito = 0

-- elimina i cancelletti in testa ed in coda
if @merc=''
	set @merc='######'

if @merc_var=''
	set @merc_var='######'

set @merc = substring(@merc,4,len(@merc))
set @merc = substring(@merc,1,len(@merc)-3)

set @merc_var = substring(@merc_var,4,len(@merc_var))
set @merc_var = substring(@merc_var,1,len(@merc_var)-3)

--select  @merc

select 0 as conta into #temp

SET @i=1
set @str = dbo.GetPos(@merc,'###',@i)

WHILE ( @str <> '')
BEGIN
    PRINT @str
	-- vede se la merc @str è ancora presente
	--print PATINDEX('###' + @str + '###', '###' + @merc_var + '###')
	if PATINDEX('###' + @str + '###', '###' + @merc_var + '###') > 0
	begin
		set @esito = 1
		break
	end
	else
	begin
		--print 'non trovato'
		--prende il path della merc
		select @pathMerc=DMV_Father  from ClasseIscriz_MLNG where ML_LNG='I' and dmv_cod = @str

		-- vede se tra la merc variate c'è almeno un suo padre
		delete from  #temp
		set @sql = 'insert into #temp (conta) select count(*) as conta  from ClasseIscriz_MLNG where ML_LNG=''I'''
		set @sql = @sql + ' and dmv_cod in (''' + replace(@merc_var,'###',''',''') + ''')'
		--set @sql = @sql + ' and ''' + @pathMerc + ''' like DMV_Father + ''%'''
		set @sql = @sql + ' and DMV_Father like ''' + @pathMerc + ''' + ''%'''

		

		--print @sql
		exec (@sql)

		if exists(select * from #Temp where conta>0)
		begin
			set @esito = 1
			break
		end
		

	end

    SET @i  = @i  + 1
	set @str = dbo.GetPos(@merc,'###',@i)
END


drop table #temp
--print 'esito=' + cast(@esito as varchar(1))



	--return @esito

end
GO
