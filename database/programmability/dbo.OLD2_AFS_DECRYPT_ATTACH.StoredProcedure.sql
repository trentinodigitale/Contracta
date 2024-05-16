USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_AFS_DECRYPT_ATTACH]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  PROCEDURE [dbo].[OLD2_AFS_DECRYPT_ATTACH]( @idPfu int ,    @Allegato as nvarchar(max) , @riferimento  as varchar(100) )
as
BEGIN

	DECLARE @KeyCrypt varchar(200)
	DECLARE @KeyName varchar(200)
	DECLARE @KeyCryptAPP varchar(200)

	DECLARE @SQLCrypt varchar(max)
	DECLARE @ix int 

	DECLARE @idRiferimentoOriginale INT

	SET @idRiferimentoOriginale = -1

	SET NOCOUNT ON

	declare @ATT_Hash nvarchar(250)
	declare @AllegatoMulti as nvarchar(max)

	set @AllegatoMulti = @Allegato

	set @Allegato=''

	DECLARE crsAttach CURSOR STATIC FOR 
	
		select * from split(@AllegatoMulti,'***')

	OPEN crsAttach

	FETCH NEXT FROM crsAttach INTO @Allegato
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		set @ATT_Hash =''
		set @ATT_Hash = dbo.GetPos( @Allegato , '*' , 4 )

		--------------------------------------------------------------------------------------------------------
		-- Come riferimento per la richiesta di decifratura dell'allegato utilizzo l'idDoc presente sulla tabella degli allegati
		-- e non più quello passato a questa stored. questo perchè un offerta (ad esempio) può essere invalidata, andandone a generare
		-- una nuova per copia (portandosi i riferimenti degli allegati) cambiando di conseguenza il suo ID. Ma la chiave di decifratura
		-- associata a questo nuovo ID non corrisponde con quella utilizzata al momento della cifratura dell'allegato.. Di conseguenza
		-- è necessario utilizzare sempre l'id 'originale' e non eventuali ID successivi.
		--------------------------------------------------------------------------------------------------------
		select @idRiferimentoOriginale = isnull(ATT_IdDoc,-1)
			 from 
				CTL_Attach with(nolock) 
			 where ATT_Hash = @ATT_Hash and ATT_Cifrato = 1

		-- Verifico se l'allegato è cifrato
		if @idRiferimentoOriginale <> -1
		begin

			-- se si cerca di decifrare un allegato passando un idpfu non coerente si fa scattare un processo di avviso

			insert into CTL_LOG_UTENTE ( idpfu , paginaDiArrivo, paginaDiPartenza , querystring )
				values( @idPfu  , 'APERTURA ALLEGATO [' + @ATT_Hash + ']' , @riferimento , '' )

			-- recupero la chiave per critografia
			select  @KeyCrypt = reverse( substring(  cast( [GUID] as varchar(100)) ,  id % 33  + 2 + 2, 36))  + substring(  cast( [GUID] as varchar(100)) , 2 , id % 33 + 2) ,
					@KeyName = + reverse( substring( cast( [GUID] as varchar(100)) ,  id % 6 , 5 ) + cast( id as varchar(10)))  
				 from ctl_doc with(nolock) where id = @idRiferimentoOriginale
	
			set @KeyCrypt =  convert(varchar(200) ,  HASHBYTES( 'MD5' , @KeyCrypt ) , 2 ) + '-' + convert( varchar(200) ,  HASHBYTES( 'SHA1' , @KeyCrypt ) ,2)
			set @KeyName ='KEY_' + convert(varchar(200) ,  HASHBYTES( 'SHA1' , @KeyName )  ,2)


		
			if not exists( select name from sys.symmetric_keys where name = @KeyName )
			begin
				-- creo una nuova chiave per il documento se non esiste
				set @SQLCrypt = 'CREATE SYMMETRIC KEY ' + @KeyName + '
							WITH ALGORITHM = AES_256
							ENCRYPTION BY PASSWORD = ''' + @KeyCrypt + ''' '
		
				exec( @SQLCrypt )
			end

			-- apro la chiave per la cifratura
			set @SQLCrypt = 'OPEN SYMMETRIC KEY ' + @KeyName + ' DECRYPTION BY  PASSWORD = ''' + @KeyCrypt + ''' '
			exec( @SQLCrypt )

			-- richiedo la decifratura
			insert into CTL_DECRYPT_ATTACH (   [keyFile] , [idX] ) 
				values( EncryptByKey(Key_GUID(  @KeyName ), @Allegato ) , @idRiferimentoOriginale  )

			set @ix = @@identity

			update  CTL_Attach set ATT_Cifrato = 2 where ATT_Hash = @ATT_Hash and ATT_Cifrato = 1 

			insert into CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID )
				values( @ix , @idPfu , 'CIFRATURA' , 'DECIFRA_FILE' )


			set @SQLCrypt =  'CLOSE SYMMETRIC KEY  ' + @KeyName  
		
			exec( @SQLCrypt ) 

		end


		FETCH NEXT FROM crsAttach INTO @Allegato
	END

	CLOSE crsAttach 
	DEALLOCATE crsAttach 

	

	
END



GO
