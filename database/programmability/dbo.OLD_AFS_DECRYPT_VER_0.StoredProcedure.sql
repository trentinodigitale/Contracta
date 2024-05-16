USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_AFS_DECRYPT_VER_0]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sabato
-- Create date: 07-05-2020
-- =============================================
CREATE PROCEDURE [dbo].[OLD_AFS_DECRYPT_VER_0]( @idPfu int , @Section nvarchar(200) ,  @ValueKeyDoc  as varchar(100) , @Sql as nvarchar(max) , @TableName varchar(200) , @Identity varchar(200)  )
--WITH ENCRYPTION
as
BEGIN

	declare @KeyCrypt varchar(200)
	declare @KeyName varchar(200)
	declare @KeyCryptAPP varchar(200)

	declare @SQLCrypt varchar(max)

	SET NOCOUNT ON;



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
	--print 'insert into #TempValore ( ID_DOC ) select top 1 ' + @ValueKeyDoc +' from ( ' +  @SqlQuery + ' ) as a'  
	exec( 'insert into #TempValore ( ID_DOC ) select top 1 ' + @ValueKeyDoc +' from ( ' +  @SqlQuery + ' ) as a'  )
	select @ID_DOC  = ID_DOC  from #TempValore
	drop table #TempValore

	-- traccia nel log della decifratura dei dati in chiaro sul DB
	declare @pfulogin nvarchar(500)
	select @pfulogin = pfulogin from profiliutente where idpfu = @idPfu
	insert into CTL_LOG_UTENTE ( idpfu , paginaDiArrivo, paginaDiPartenza , querystring )
		values( @idPfu  , 'LETTURA BUSTA [' + @Section + ']' , '' , 'Utente :' + @pfulogin + ' - Riferimento : ' + cast( @ID_DOC as varchar) + ' - Ver : 0' )

	--if @ID_DOC is not null 
	--begin
	--	insert into CTL_LOG_UTENTE ( idpfu , paginaDiArrivo, paginaDiPartenza , querystring )
	--		values( @idPfu  , 'APERTURA BUSTA [' + @Section + ']' , @ID_DOC , @Sql )

	--end

	---- recupero la chiave per critografia
	--select  @KeyCrypt = reverse( substring(  cast( [GUID] as varchar(100)) ,  id % 33  + 2 + 2, 36))  + substring(  cast( [GUID] as varchar(100)) , 2 , id % 33 + 2) ,
	--		@KeyName = 'Key_' + reverse( substring( cast( [GUID] as varchar(100)) ,  id % 6 , 5 ) + cast( id as varchar(10)))  
	--	 from ctl_doc where id = @ID_DOC

	-- recupero la chiave per critografia
	select  @KeyCrypt = reverse( substring(  cast( [GUID] as varchar(100)) ,  id % 33  + 2 + 2, 36))  + substring(  cast( [GUID] as varchar(100)) , 2 , id % 33 + 2) ,
			@KeyName = + reverse( substring( cast( [GUID] as varchar(100)) ,  id % 6 , 5 ) + cast( id as varchar(10)))  
			from ctl_doc where id = @ID_DOC
	
	set @KeyCrypt =  convert(varchar(200) ,  HASHBYTES( 'MD5' , @KeyCrypt ) , 2 ) + '-' + convert( varchar(200) ,  HASHBYTES( 'SHA1' , @KeyCrypt ) ,2)
	set @KeyName ='KEY_' + convert(varchar(200) ,  HASHBYTES( 'SHA1' , @KeyName )  ,2)


	

	if exists( select * from sys.symmetric_keys where name = @KeyName ) and @ID_DOC is not null 
	begin
		
		-- apro la chiave per la cifratura
		set @SQLCrypt = 'OPEN SYMMETRIC KEY ' + @KeyName + ' DECRYPTION BY  PASSWORD = ''' + @KeyCrypt + ''' '
		exec( @SQLCrypt )

		set @Sql = replace( @Sql , 'select ' ,  'select dbo.AFS_DECRYPT_F( ''' + @TableName +''' , ' + @Identity + ' , ''' + @KeyName + ''' )  as AFS_DATI_DECIFRATI , ' )
		exec ( @Sql )



		set @SQLCrypt =  'CLOSE SYMMETRIC KEY  ' + @KeyName  
		exec( @SQLCrypt ) 

	end
	else
	begin

		-- se non esiste la key non decifro
		--set @Sql = replace( @Sql , 'select * ' ,  'select * , ''''  as AFS_DATI_DECIFRATI ' )
		set @Sql = replace( @Sql , 'select ' ,  'select ''''  as AFS_DATI_DECIFRATI , ' )
		exec ( @Sql )
	end

END







GO
