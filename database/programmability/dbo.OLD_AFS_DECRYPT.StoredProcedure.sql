USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_AFS_DECRYPT]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OLD_AFS_DECRYPT]( @idPfu int , @Section nvarchar(200) ,  @ValueKeyDoc  as varchar(100) , @Sql as nvarchar(max) , @TableName varchar(200) , @Identity varchar(200)  )
--WITH ENCRYPTION
as
BEGIN

	
	SET NOCOUNT ON;
	declare @Ver varchar(10)
	declare @SqlScript nvarchar(max)

	-- dalla query deve essere recuperato il valore del campo che contienne l'ID del documento
	declare @SqlQuery nvarchar(max)
	declare @IX int
	set @IX = charindex( ' order by ' , @Sql)
	if @IX = 0 
		set @SqlQuery = @Sql
	else
		set @SqlQuery = left( @Sql , @ix )

	create table #TempValore ( ID_DOC int )
	declare @ID_DOC int
	set @ID_DOC = null
	exec( 'insert into #TempValore ( ID_DOC ) select top 1 ' + @ValueKeyDoc +' from ( ' +  @SqlQuery + ' ) as a'  )
	select @ID_DOC  = ID_DOC  from #TempValore
	drop table #TempValore

	-- verifico se il documento ha una versione specifica della cifratura
	--if exists ( select o.name 	from syscolumns c with(nolock) inner join sysobjects o with(nolock) on o.id = c.id where o.name = 'CTL_DOC' and c.name = 'CRYPT_VER' )
	--begin
		select @Ver = CRYPT_VER from  CTL_DOC with(nolock) where Id = @ID_DOC
	--end

	set @Ver = ISNULL( @Ver ,  '0' ) 


	--exec AFS_DECRYPT_VER_0 @idPfu , @Section  ,  @ValueKeyDoc   , @Sql , @TableName  , @Identity 
	--set @SqlScript =  'exec AFS_DECRYPT_VER_' + @Ver  + ' ' +   cast( @idPfu as varchar ) + ', ''' + replace( @Section , '''' , '''''' ) + ''' , ''' + replace( @ValueKeyDoc , '''' , '''''' ) + ''' , ''' + replace (  @Sql , '''' , '''''' ) + ''' , ''' + replace ( @TableName , '''' , '''''' ) + ''' , ''' + replace( @Identity ,'''' , '''''' ) + ''' ' 
	set @SqlScript =  'exec AFS_DECRYPT_VER_' + @Ver  + ' ' +   cast( @idPfu as varchar ) + ', ''' +  @Section  + ''' , ''' + replace( @ValueKeyDoc , '''' , '''''' ) + ''' , ''' + replace (  @Sql , '''' , '''''' ) + ''' , ''' +  @TableName  + ''' , ''' + replace( @Identity ,'''' , '''''' ) + ''' ' 
	exec ( @SqlScript )
end


GO
