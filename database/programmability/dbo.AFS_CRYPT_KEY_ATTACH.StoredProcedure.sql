USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[AFS_CRYPT_KEY_ATTACH]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  PROCEDURE [dbo].[AFS_CRYPT_KEY_ATTACH]( @idPfu int ,   @ValueKeyDoc  as varchar(100) , @TableName varchar(200) )
--WITH ENCRYPTION
as
BEGIN

	
	SET NOCOUNT ON;
	declare @Ver varchar(10)
	declare @SqlScript nvarchar(max)
	declare @ID_DOC  varchar(100)

	declare @SqlQuery nvarchar(max)
	declare @IX int



	set @ID_DOC  = @ValueKeyDoc 

	-- se la tabella non sulla CTL_DOC devo prima recuperare l'ID della CTLDOC e poi passo alla funzione che recupera il guid
	if @TableName <> 'ctl_doc'
	begin

		set @SqlQuery = ' insert into #TempValore ( ID_DOC ) select top 1 idDoc from  ' + REPLACE(  @TableName , '''' , '''''' ) + ' where id = ' + REPLACE(  @ValueKeyDoc , '''' , '''''' )

		create table #TempValore ( ID_DOC int )
		set @ID_DOC = null
		exec( @SqlQuery)
		select @ID_DOC  = ID_DOC  from #TempValore
		drop table #TempValore

	end
	


	-- verifico se il documento ha una versione specifica della cifratura
	select @Ver = CRYPT_VER from  CTL_DOC with(nolock) where Id = @ID_DOC

	set @Ver = ISNULL( @Ver ,  '0' ) 


	set @SqlScript =  'exec AFS_CRYPT_KEY_ATTACH_VER_' + @Ver  + ' ' +   cast( @idPfu as varchar ) + ', ''' + replace( @ID_DOC , '''' , '''''' ) + '''  ' 
	exec ( @SqlScript )
end
GO
