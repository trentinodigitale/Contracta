USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SP_drop_table_index]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[SP_drop_table_index] ( @tab_name varchar(500))
as 
set nocount on 
declare @name varchar(2000)
,@errorsave int

if (rtrim(@tab_name) = '') 
RAISERROR ('A non-zero length table name parameter is expected', 16, 1)


	if exists (select name from sysindexes where id = object_id(@tab_name) and indid > 0 and indid < 255 and (status & 64)=0)
	begin 
		declare ind_cursor cursor for 
			select name from sysindexes
				where id = object_id(@tab_name) and indid > 0 and indid < 255 and (status & 64)=0

	open ind_cursor
	fetch next from ind_cursor into @name
	while (@@fetch_status = 0)
	begin 
		exec ('drop index ' + @tab_name + '.' + @name)
		set @errorsave = @@error

	fetch next from ind_cursor into @name
	end

close ind_cursor
deallocate ind_cursor

end 

GO
