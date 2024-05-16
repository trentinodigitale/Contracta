USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_COPY_RECORD]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[OLD_COPY_RECORD]( @Table as Varchar(200) ,@idSource int , @idDest int , @Escludi varchar(4000))
AS
begin

	declare @sql as varchar(MAX)
	declare @crlf varchar(10)
	set @crlf = '
'

	set @sql = 'update D set '


	select @sql = @sql + 'D.' + a.name + ' = S.' + a.name + '  ,' + @crlf
	  from syscolumns a, sysobjects b
	 where a.id = b.id
	   and b.name = @Table 
		and PATINDEX (  '%,' + a.name + ',%' , ',' + @Escludi + ','   ) = 0 
		and b.xtype='U'

	set @sql = left( @sql , len( @sql ) - 3 )

	set @sql = @sql + ' from ' + @Table + ' as D , ' + @Table + ' as S with(nolock)
			Where D.id = ' + cast( @idDest as varchar ) + ' and S.id = ' + cast( @idSource as varchar ) 


	--print @sql
	exec ( @sql )
end


GO
