USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GARBAGE_COLLECTOR_ATTACH_DELETE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[GARBAGE_COLLECTOR_ATTACH_DELETE]  ( @idDoc int , @DB_Name varchar(150) , @Delete tinyint  )	
AS
BEGIN

	SET NOCOUNT ON
	

	DECLARE @sTable                 VARCHAR(300)
	DECLARE @sCol                   VARCHAR(300)
	DECLARE @SQLCmd                 VARCHAR(MAX)
	DECLARE @LAST_ATT_IdRow         INT

	-- sposta gli allegati in un altro database tramite SQL dinamico se il parametro lo prevede
	if @DB_Name <> ''
	begin
		
		set @SQLCmd = 'insert into ' + @DB_Name + '.dbo.CTL_Attach '
		set @SQLCmd = @SQLCmd + '( [ATT_Obj], [ATT_Hash], [ATT_Size], [ATT_Name], [ATT_Type], [ATT_DataInsert], [URL_CLIENT], [ATT_IdDoc], [ATT_Cifrato], [ATT_Pubblico], [ATT_FileHash] )	select [ATT_Obj], [ATT_Hash], [ATT_Size], [ATT_Name], [ATT_Type], [ATT_DataInsert], [URL_CLIENT], [ATT_IdDoc], [ATT_Cifrato], [ATT_Pubblico], [ATT_FileHash] from CTL_Attach where [ATT_IdRow] in '
		set @SQLCmd = @SQLCmd + '(select [Value] from [CTL_DOC_Value] where [IdHeader]=' + cast(@idDoc as varchar(10)) +' and [DSE_ID]=''ALLEGATI'' and [DZT_Name]=''IdRow'' )'		

		exec (@SQLCmd)
		--print @SQLCmd

	end

	-- cancella gli allegati se il parametro lo prevede
	if @Delete = 1
	begin

			---- cancellazione logica degli allegati e svuotamento del campo [ATT_Obj]
			update CTL_Attach
				set [ATT_Obj] = '', [ATT_Deleted] = 1
			where [ATT_IdRow] in
								(
									select [Value]
										from [CTL_DOC_Value]
									where [IdHeader] = @idDoc and
											[DSE_ID] = 'ALLEGATI' and
											[DZT_Name] = 'IdRow'
								)

	end
	

	

	

                
	
   
	SET NOCOUNT OFF

END




GO
