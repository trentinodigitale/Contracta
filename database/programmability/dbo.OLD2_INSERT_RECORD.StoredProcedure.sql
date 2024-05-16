USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_INSERT_RECORD]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[OLD2_INSERT_RECORD]( @Table as Varchar(200) ,@idSource int ,@idDest int , @Key varchar(200) , @Escludi varchar(4000) , @filter nvarchar(max) )
AS
begin

	declare @sql as nvarchar(MAX)
	declare @sqlColonne as nvarchar(MAX)

	declare @crlf varchar(10)
	set @crlf = '
'

	set @sqlColonne = ''

	-- determino le colonne da riportare
	select @sqlColonne = @sqlColonne + a.name + ' , '
		from syscolumns a, sysobjects b
		where a.id = b.id
			and b.name = @Table 
				and PATINDEX (  '%,' + a.name + ',%' , ',' + @Escludi + ',' + @Key + ','   ) = 0 
				and b.xtype='U'

	set @sqlColonne = left ( @sqlColonne , len( @sqlColonne ) -2)


	-- conpongo lo script
	set @sql = 'insert into ' + @Table + ' ( ' + @Key + ' ,' + @sqlColonne + ' ) ' + @crlf
	set @sql = @sql + '  select ' + cast( @idDest as nvarchar(20)) + '  , ' + @sqlColonne + ' from ' + @Table + ' where ' + @Key + ' = ' + cast( @idSource as varchar(20))

	if isnull( @filter , '' ) <> '' 
		set @sql = @sql + ' and ( ' + @filter + ' ) '

	--print @sql
	exec ( @sql )

end

GO
