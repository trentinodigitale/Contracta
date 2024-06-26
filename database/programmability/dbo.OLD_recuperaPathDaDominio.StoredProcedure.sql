USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_recuperaPathDaDominio]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		Federico Leone
-- Create date: 16 aprile 2012
-- Description:	stored per inserire in una tabella temporanea i path associati
--				a N valori di un dominio (nel caso di multivalore) rispetto
--				a una dm_query o alla domain values
-- =============================================
CREATE PROCEDURE [dbo].[OLD_recuperaPathDaDominio]
	@nomeDominio VARCHAR(200), 
	@values NVARCHAR(4000),
	@nomeTempTable NVARCHAR(200) = '',
	@Lng as varchar(10)='I'
AS
BEGIN

	SET NOCOUNT ON;

	-- ******** NOTE **********
	
	-- mi aspetto di avere una tabella temporanea gia generata dal chiamante di questa funzione
	-- con nome temp_nomeDominio

	-- la query contenuta in dm_query per essere utilizzata in una from, se possiede un order by alla sua fine, deve
	-- avere anche un TOP 100 PERCENT all'inizio


	declare @dm_query as nvarchar(4000)
	--declare @nomeTempTable as nvarchar(200)
	if @nomeTempTable = ''
	BEGIN
		set @nomeTempTable = '#temp_' + @nomeDominio
	END
	-- verifico se recuperare i valori dalla domainValues o dalla query del dominio
	select @dm_query = cast( DM_Query as nvarchar(4000)) from lib_domain where dm_id = @nomeDominio
	
	if isnull(@dm_query,'') <>	''
	begin
		set @dm_query=replace(@dm_query,'#LNG#',@Lng)
	end


	if charindex( 'order by ' , @dm_query ) > 0 
	begin 
		set @dm_query = left( @dm_query , charindex( 'order by ' , @dm_query )-1 )
	end
	
	-- Se non è un multivalue
	if charindex('###', @values) = 0
	begin
	
		if isnull(@dm_query,'') =	''
		begin
			
			exec ('insert into ' + @nomeTempTable + ' select DMV_Father as ColPath from lib_domainvalues where dmv_cod = ''' + @values + ''' and dmv_dm_id = ''' + @nomeDominio + ''' ')
			
		end
		else
		begin

			exec('insert into ' + @nomeTempTable + ' select DMV_Father as ColPath from (' + @dm_query + ')b where b.dmv_cod = ''' + @values + '''')
	
		end
		
	end

	else
	begin
		
		
		if isnull(@dm_query,'') =	''
		begin			
			
			exec('insert into ' + @nomeTempTable + ' select b.DMV_Father as ColPath from dbo.split(''' + @values + ''',''###'') a, lib_domainvalues b where a.items = b.dmv_cod  and b.dmv_dm_id = ''' + @nomeDominio + '''')			

		end
		else
		begin
		
			exec('insert into ' + @nomeTempTable + ' select b.DMV_Father as ColPath from dbo.split(''' + @values + ''',''###'') a,(' + @dm_query + ')b where a.items = b.dmv_cod')
			
		end
	
	end
END





GO
