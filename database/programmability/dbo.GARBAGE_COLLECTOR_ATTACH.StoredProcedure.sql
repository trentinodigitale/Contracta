USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GARBAGE_COLLECTOR_ATTACH]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  PROCEDURE [dbo].[GARBAGE_COLLECTOR_ATTACH]  ( @idDoc int , @IdUser int, @IdRowStart int , @NumDaysBefore int  )	
AS
BEGIN

	set xact_abort ON
	
	SET NOCOUNT ON


	declare @Elab_Key varchar(100)
	declare @Step_Descr varchar(300)
	declare @Step_Type varchar(20)
	declare @DataExec1 datetime
	declare @DataExec2 datetime
	declare @DataExec3 datetime
	declare @DataExec4 datetime
	declare @Duration int
	DECLARE @sTable                 VARCHAR(300)
	DECLARE @sCol                   VARCHAR(300)
	DECLARE @SQLCmd                 VARCHAR(MAX)
	DECLARE @LAST_ATT_IdRow         INT
	declare @Elab_Key_last varchar(100)
	declare @Step_Descr_last varchar(300)
	declare @Step_Type_last varchar(20)

	-- creazione tabelle se non esistono
	IF not EXISTS (SELECT * FROM sysobjects WHERE xtype = 'U' AND name = 'TempDelAtt01')
	begin
		CREATE TABLE TempDelAtt01
		(
				Id INT IDENTITY (1, 1) NOT NULL
				, attKey VARCHAR(max)
		)

	end
	
	IF not EXISTS (SELECT * FROM sysobjects WHERE xtype = 'U' AND name = 'TempDelAtt02')
	begin

		CREATE TABLE TempDelAtt02
		(
				Id INT IDENTITY (1, 1) NOT NULL
			  --, attKey VARCHAR(1000)
			  , ATT_Hash nvarchar(250)
		)

		CREATE unique INDEX IX2 ON TempDelAtt02 (ATT_Hash)

	end
	
	IF not EXISTS (SELECT * FROM sysobjects WHERE xtype = 'U' AND name = 'TempCTLAtt01')
	begin		
		
			CREATE TABLE TempCTLAtt01
			(
					ATT_IdRow INT  NOT NULL
					, attKey VARCHAR(max)
					, ATT_Hash nvarchar(250)
			)
			
			CREATE UNIQUE INDEX IX ON TempCTLAtt01 (ATT_IdRow)
			CREATE INDEX IX2 ON TempCTLAtt01 (ATT_Hash)
	end
	
	
	
	IF not EXISTS (SELECT * FROM sysobjects WHERE xtype = 'U' AND name = 'TempCTLAtt03')
	begin
			CREATE TABLE TempCTLAtt03
			(
					Size BIGINT
			)
	end
	
	IF not EXISTS (SELECT * FROM sysobjects WHERE xtype = 'U' AND name = 'TempCTLAtt04')
	begin
			CREATE TABLE TempCTLAtt04
			(
					Cnt int
			)
	end


	SELECT @LAST_ATT_IdRow = MAX(ATT_IdRow)
	  FROM CTL_Attach
	  where [ATT_DataInsert] < dateadd(d,-@NumDaysBefore,getdate())	  


	

	set @Elab_Key = NEWID ()

	set @Step_Descr_last = null

	-- legge l'ultimo step eseguito da elaborazione precedente
	select top 1 @Elab_Key_last=Elab_Key, @Step_Descr_last=substring(Step_Descr,1,5), @Step_Type_last=Step_Type
	from [GARBAGE_COLLECTOR_LOG]
	order by id desc

	if  ( @Step_Descr_last is null ) OR ( @Step_Descr_last = 'STEP9' AND @Step_Type_last = 'END' )
	begin
		-- in questo caso deve fare l'elaborazione completa
		-- svuota le tabelle
		truncate table GARBAGE_COLLECTOR_LOG
		truncate table GARBAGE_COLLECTOR_QUERY_TO_EXEC
		truncate table TempDelAtt01
		truncate table TempDelAtt02
		truncate table TempCTLAtt01
		truncate table TempCTLAtt03
		truncate table TempCTLAtt04

	end

	else

	begin
		-- deve partire dall'ultimo step eseguito
		set @Elab_Key = @Elab_Key_last

		-- se l'ultimo passo è un END deve partire dallo step successivo
		if @Step_Type_last = 'END'
		begin
			
			declare @nn int

			set @nn = cast(right(@Step_Descr_last,1) as int) + 1

			set @Step_Descr_last = 'STEP' + cast(@nn as varchar(2))

		end

		if @Step_Descr_last = 'STEP1'
			goto step1

		if @Step_Descr_last = 'STEP2'
			goto step2

		if @Step_Descr_last = 'STEP3'
			goto step3

		if @Step_Descr_last = 'STEP4'
			goto step4

		if @Step_Descr_last = 'STEP5'
			goto step5

		if @Step_Descr_last = 'STEP6'
			goto step6

		if @Step_Descr_last = 'STEP7'
			goto step7

		if @Step_Descr_last = 'STEP8'
			goto step8

		if @Step_Descr_last = 'STEP9'
			goto step9

	end
	
	

	
step1:	 

		-- scrive il log
		set @Step_Descr = 'STEP1 --  copia le chiavi della CTL_ATTACH in una tabella di lavoro'
		set @DataExec1 = getdate()

		insert into [dbo].[GARBAGE_COLLECTOR_LOG]
			( [Elab_Key], [Step_Descr], [Step_Type], [DataExec], [Duration] )
		values
			( @Elab_Key, @Step_Descr, 'BEGIN', @DataExec1, 0 )


		

	 -- la tabella TempCTLAtt01 contiene tutti le chiavi presenti nella CTL_ATTACH

	 truncate table TempCTLAtt01
	
	  insert into TempCTLAtt01
		( ATT_IdRow , attKey, ATT_Hash )

		select ATT_IdRow, ATT_Name + '*' + ATT_Type + '*' + CAST(CAST(ATT_Size AS INT) AS VARCHAR(1000)) + '*' + ATT_Hash , ATT_Hash
	  FROM CTL_ATTACH WITH (NOLOCK)
	 WHERE ISNULL(att_Cifrato, 0) =  0
			and isnull(att_deleted,0)=0
			and ATT_IdRow > @IdRowStart
			and [ATT_DataInsert] < dateadd(d,-@NumDaysBefore,getdate())
	
	
  
	

	set @DataExec2 = getdate()
	  set @Duration = DATEDIFF (ss, @DataExec1, @DataExec2)
	  	  

		insert into [dbo].[GARBAGE_COLLECTOR_LOG]
			( [Elab_Key], [Step_Descr], [Step_Type], [DataExec], [Duration] )
		values
			( @Elab_Key, @Step_Descr, 'END', @DataExec2, @Duration )


step2:	
	
	-- scrive il log
	set @Step_Descr = 'STEP2 --  crea la tabella delle select da eseguire per gli attributi di tipo ATTACH'
	set @DataExec1 = getdate()

	insert into [dbo].[GARBAGE_COLLECTOR_LOG]
		( [Elab_Key], [Step_Descr], [Step_Type], [DataExec], [Duration] )
	values
		( @Elab_Key, @Step_Descr, 'BEGIN', @DataExec1, 0 )

	-- la tabella TempDelAtt01 contiene tutti gli allegati che vengono utilizzati dall'applicazione

	truncate table GARBAGE_COLLECTOR_QUERY_TO_EXEC
	truncate table TempDelAtt01


	insert into GARBAGE_COLLECTOR_QUERY_TO_EXEC
		(query, esito)

		-- Tabelle
		SELECT 
	
						'INSERT INTO TempDelAtt01 (attKey) 
											   SELECT ' + b.name + 						   
											  '  FROM ' + a.name + ' WITH (NOLOCK)
												WHERE ISNULL(' + b.name + ', '''') <> '''''  , 0	
	
				FROM sysobjects a
					, syscolumns b
					, [INFORMATION_SCHEMA].TABLES
				WHERE a.id = b.id			
					AND a.xtype = 'U'			-- Tabelle		
					AND b.name IN (SELECT DZT_NAME 
									FROM LIB_Dictionary
									WHERE DZT_Type = 18)
					AND a.name NOT LIKE 'OLD%'
					and a.name = TABLE_NAME			
					and TABLE_SCHEMA = 'dbo'

		--union all

		---- viste
		--SELECT 
	
		--				'INSERT INTO TempDelAtt01 (attKey) 
		--									   SELECT ' + b.name + 						   
		--									  '  FROM ' + a.name + ' WITH (NOLOCK)
		--										WHERE ISNULL(' + b.name + ', '''') <> '''''  , 0	
	
		--		FROM sysobjects a
		--			, syscolumns b
		--			, [INFORMATION_SCHEMA].VIEWS 
		--		WHERE a.id = b.id			
		--			AND a.xtype = 'V'		-- viste
		--			AND b.name IN (SELECT DZT_NAME 
		--							FROM LIB_Dictionary
		--							WHERE DZT_Type = 18)
		--			AND a.name NOT LIKE 'OLD%'
		--			and a.name = TABLE_NAME			
		--			and TABLE_SCHEMA = 'dbo'


		ORDER BY 1



	set @DataExec2 = getdate()
	set @Duration = DATEDIFF (ss, @DataExec1, @DataExec2)
	  	  

	insert into [dbo].[GARBAGE_COLLECTOR_LOG]
		( [Elab_Key], [Step_Descr], [Step_Type], [DataExec], [Duration] )
	values
		( @Elab_Key, @Step_Descr, 'END', @DataExec2, @Duration )


step3:

	-- scrive il log
	set @Step_Descr = 'STEP3 --  cursore che esegue tutte le query per gli attributi di tipo ATTACH'
	set @DataExec1 = getdate()

	insert into [dbo].[GARBAGE_COLLECTOR_LOG]
		( [Elab_Key], [Step_Descr], [Step_Type], [DataExec], [Duration] )
	values
		( @Elab_Key, @Step_Descr, 'BEGIN', @DataExec1, 0 )

	DECLARE crs CURSOR LOCAL FAST_FORWARD FOR 
								 -- SELECT a.name AS sTable
									--   , b.name AS sCol 
									--FROM sysobjects a
									--   , syscolumns b
								 --  WHERE a.id = b.id
									-- AND a.xtype IN ('U', 'V')
									-- AND b.name IN (SELECT DZT_NAME 
									--				  FROM LIB_Dictionary
									--				 WHERE DZT_Type = 18)
									-- AND a.name NOT LIKE 'OLD%'
								 --  ORDER BY 1
                               select id,query from GARBAGE_COLLECTOR_QUERY_TO_EXEC
									where esito = 0
								order by id

	OPEN crs

	declare @IdRow int

	--FETCH NEXT FROM crs INTO @sTable, @sCol
	FETCH NEXT FROM crs INTO @IdRow, @SQLCmd

	WHILE @@FETCH_STATUS = 0
	BEGIN
			--SET @SQLCmd = 'INSERT INTO TempDelAtt01 (attKey) 
			--			   SELECT ' + @sCol + 						   
			--			  '  FROM ' + @sTable + ' WITH (NOLOCK)
			--				WHERE ISNULL(' + @sCol + ', '''') <> '''''                    
						   
                       
            
			
			set @DataExec3 = getdate()

			--insert into [dbo].[GARBAGE_COLLECTOR_LOG]
			--	( [Elab_Key], [Step_Descr], [Step_Type], [DataExec], [Duration] )
			--values
			--( @Elab_Key, @SQLCmd, 'BEGIN', @DataExec3, 0 )
			  
			EXEC (@SQLCmd) 

			set @DataExec4 = getdate()
			set @Duration = DATEDIFF (ss, @DataExec3, @DataExec4)
	  	  
			update GARBAGE_COLLECTOR_QUERY_TO_EXEC set start= @DataExec3, stop = @DataExec4, 
														duration = @Duration, esito = 1
					where id = @IdRow

			--insert into [dbo].[GARBAGE_COLLECTOR_LOG]
			--	( [Elab_Key], [Step_Descr], [Step_Type], [DataExec], [Duration] )
			--values
			--	( @Elab_Key, @SQLCmd, 'END', @DataExec4, @Duration )

			--FETCH NEXT FROM crs INTO @sTable, @sCol
			FETCH NEXT FROM crs INTO @IdRow, @SQLCmd
	END

	CLOSE crs
	DEALLOCATE crs

	set @DataExec2 = getdate()
	set @Duration = DATEDIFF (ss, @DataExec1, @DataExec2)
	  	  

	insert into [dbo].[GARBAGE_COLLECTOR_LOG]
		( [Elab_Key], [Step_Descr], [Step_Type], [DataExec], [Duration] )
	values
		( @Elab_Key, @Step_Descr, 'END', @DataExec2, @Duration )
	

step4:
	
	-- scrive il log
	set @Step_Descr = 'STEP4 --  estrae chiavi allegati dalla CTL_DOC_VALUE'
	set @DataExec1 = getdate()

	insert into [dbo].[GARBAGE_COLLECTOR_LOG]
		( [Elab_Key], [Step_Descr], [Step_Type], [DataExec], [Duration] )
	values
		( @Elab_Key, @Step_Descr, 'BEGIN', @DataExec1, 0 )


	INSERT INTO TempDelAtt01 (attKey)
	SELECT DISTINCT Value 
	  FROM CTL_DOC_VALUE dv WITH(NOLOCK)
		 , LIB_Dictionary dic WITH(NOLOCK)
	 WHERE dic.DZT_Name = dv.DZT_Name
	   AND dic.DZT_Type = 18
	   AND value IS NOT NULL

	set @DataExec2 = getdate()
	set @Duration = DATEDIFF (ss, @DataExec1, @DataExec2)
	  	  

	insert into [dbo].[GARBAGE_COLLECTOR_LOG]
		( [Elab_Key], [Step_Descr], [Step_Type], [DataExec], [Duration] )
	values
		( @Elab_Key, @Step_Descr, 'END', @DataExec2, @Duration )

step5:

	-- scrive il log
	set @Step_Descr = 'STEP5 --  estrae chiavi allegati dalla Document_Microlotti_DOC_Value'
	set @DataExec1 = getdate()

	insert into [dbo].[GARBAGE_COLLECTOR_LOG]
		( [Elab_Key], [Step_Descr], [Step_Type], [DataExec], [Duration] )
	values
		( @Elab_Key, @Step_Descr, 'BEGIN', @DataExec1, 0 )
	   
 
	INSERT INTO TempDelAtt01 (attKey)
	SELECT DISTINCT Value 
	  FROM Document_Microlotti_DOC_Value dv WITH(NOLOCK)
		 , LIB_Dictionary dic WITH(NOLOCK)
	 WHERE dic.DZT_Name = dv.DZT_Name
	   AND dic.DZT_Type = 18
	   AND value IS NOT NULL
	   
	set @DataExec2 = getdate()
	set @Duration = DATEDIFF (ss, @DataExec1, @DataExec2)
	  	  

	insert into [dbo].[GARBAGE_COLLECTOR_LOG]
		( [Elab_Key], [Step_Descr], [Step_Type], [DataExec], [Duration] )
	values
		( @Elab_Key, @Step_Descr, 'END', @DataExec2, @Duration )
	   

	-- Contiene tutti i puntamenti ad allegati effettivamente utilizzati

step6:

	-- scrive il log
	set @Step_Descr = 'STEP6 --  estrae chiavi allegati distinte nella TempDelAtt02'
	set @DataExec1 = getdate()

	insert into [dbo].[GARBAGE_COLLECTOR_LOG]
		( [Elab_Key], [Step_Descr], [Step_Type], [DataExec], [Duration] )
	values
		( @Elab_Key, @Step_Descr, 'BEGIN', @DataExec1, 0 )
	

	-- la tabella TempDelAtt01 contiene tutti gli allegati che vengono utilizzati dall'applicazione
	-- la tabella TempDelAtt02 contiene tutte le chiavi distinte (ATT_HASH) degli allegati che vengono utilizzati dall'applicazione

	truncate table TempDelAtt02

	--INSERT INTO TempDelAtt02 (attKey,ATT_Hash)
	INSERT INTO TempDelAtt02 (ATT_Hash)
		select distinct dbo.GetPos(attKey,'*',4) 
		    FROM TempDelAtt01
			WHERE attKey IS NOT NULL
			and attKey <> ''
			and attKey like '%*%'

	--CREATE  INDEX IX2 ON TempDelAtt02 (ATT_Hash)

	if not exists ( select * from TempDelAtt02)
	begin
		raiserror ( 'Errore - la tabella TempDelAtt02 è vuota', 16, 1)
		return 99
	end
	

	set @DataExec2 = getdate()
	set @Duration = DATEDIFF (ss, @DataExec1, @DataExec2)
	  	  

	insert into [dbo].[GARBAGE_COLLECTOR_LOG]
		( [Elab_Key], [Step_Descr], [Step_Type], [DataExec], [Duration] )
	values
		( @Elab_Key, @Step_Descr, 'END', @DataExec2, @Duration )

step7:

	--BEGIN TRAN

	--BEGIN TRY

			-------------------------------------------------------------------------------------------------------------------------------------
			-- la tabella TempCTLAtt01 contiene tutti le chiavi presenti nella CTL_ATTACH
			-- la tabella TempDelAtt01 contiene tutti gli allegati che vengono utilizzati dall'applicazione
			-- la tabella TempDelAtt02 contiene tutte le chiavi distinte (ATT_HASH) degli allegati che vengono utilizzati dall'applicazione
			--
			-- Elimino dall TempCTLAtt01 i record presenti nella TempDelAtt02 
			-- quindi alla fine della DELETE la tabella TempCTLAtt01 contiene gli allegati che non sono referenziati dall'applicazione e 
			-- quindi da cancellare!!!
			-------------------------------------------------------------------------------------------------------------------------------------


			-- scrive il log
			set @Step_Descr = 'STEP7 --  cancellazione dalla TempCTLAtt01'
			set @DataExec1 = getdate()

			insert into [dbo].[GARBAGE_COLLECTOR_LOG]
				( [Elab_Key], [Step_Descr], [Step_Type], [DataExec], [Duration] )
			values
				( @Elab_Key, @Step_Descr, 'BEGIN', @DataExec1, 0 )


			DELETE FROM TempCTLAtt01
				  WHERE ATT_Hash IN (SELECT ATT_Hash FROM TempDelAtt02)


			set @DataExec2 = getdate()
			set @Duration = DATEDIFF (ss, @DataExec1, @DataExec2)
	  	  

			insert into [dbo].[GARBAGE_COLLECTOR_LOG]
				( [Elab_Key], [Step_Descr], [Step_Type], [DataExec], [Duration] )
			values
				( @Elab_Key, @Step_Descr, 'END', @DataExec2, @Duration )
              
step8:
			
			-- scrive il log
			set @Step_Descr = 'STEP8 --  calcolo delle dimensioni totali degli allegati non utilizzati'
			set @DataExec1 = getdate()

			insert into [dbo].[GARBAGE_COLLECTOR_LOG]
				( [Elab_Key], [Step_Descr], [Step_Type], [DataExec], [Duration] )
			values
				( @Elab_Key, @Step_Descr, 'BEGIN', @DataExec1, 0 )
			
			-- queste due tabelle contengono la taglia totale e il numero degli allegati non referenziati
			truncate table TempCTLAtt03
			truncate table TempCTLAtt04
			
			  insert into TempCTLAtt03
				(Size)
				SELECT SUM(CAST(ISNULL(DATALENGTH(att_obj), 0) AS BIGINT)) 
			  FROM CTL_ATTACH WITH (NOLOCK)
			 WHERE ATT_IdRow IN (SELECT ATT_IdRow FROM TempCTLAtt01)

			
			  insert into TempCTLAtt04
				(Cnt)
				SELECT COUNT(*) 
			  FROM CTL_ATTACH WITH (NOLOCK)
			 WHERE ATT_IdRow IN (SELECT ATT_IdRow FROM TempCTLAtt01)

			 set @DataExec2 = getdate()
			set @Duration = DATEDIFF (ss, @DataExec1, @DataExec2)
	  	  

			insert into [dbo].[GARBAGE_COLLECTOR_LOG]
				( [Elab_Key], [Step_Descr], [Step_Type], [DataExec], [Duration] )
			values
				( @Elab_Key, @Step_Descr, 'END', @DataExec2, @Duration )
        
			

			--------------------------------------------------------------------------------
			-- aggiorna il documento GARBAGE_COLLECTOR_ATTACH passato in input
			--------------------------------------------------------------------------------

step9:
			
			-- scrive il log
			set @Step_Descr = 'STEP9 --  inserisce le informazioni nel documento GARBAGE_COLLECTOR_ATTACH'
			set @DataExec1 = getdate()

			insert into [dbo].[GARBAGE_COLLECTOR_LOG]
				( [Elab_Key], [Step_Descr], [Step_Type], [DataExec], [Duration] )
			values
				( @Elab_Key, @Step_Descr, 'BEGIN', @DataExec1, 0 )

			if @idDoc = -1
			begin
				
				insert into [dbo].[CTL_DOC]
				( [TipoDoc], [StatoDoc], [Data], [PrevDoc], [Deleted], [Titolo], [Azienda], [DataInvio], [StatoFunzionale], [Destinatario_User], [Destinatario_Azi], [GUID], [CanaleNotifica]) 
				values
				( 'GARBAGE_COLLECTOR_ATTACH', 'Saved', getdate(), 0, 0, 'Schedulazione controllo allegati da cancellare dal sistema', 0 , getdate(), 'InLavorazione', 0, 0, newid(), 'mail' )
			
				set @idDoc = SCOPE_IDENTITY ()

			end

			-- inserisce gli allegati da cancellare (memorizza sia la chiave tecnica sia l'identity tabellare)
			-- memorizza chiave tecnica degli allegati
			insert into [dbo].[CTL_DOC_Value]
				( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] )
			select @idDoc, 'ALLEGATI', ROW_NUMBER()  over (order by att_idrow) - 1, 'Attach', attKey
				from TempCTLAtt01
			-- memorizza ATT_IdRow degli allegati
			insert into [dbo].[CTL_DOC_Value]
				( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] )
			select @idDoc, 'ALLEGATI', ROW_NUMBER()  over (order by att_idrow) - 1, 'IdRow', ATT_IdRow
				from TempCTLAtt01

			-- inserisce la taglia totale
			insert into [dbo].[CTL_DOC_Value]
				( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] )
			select top 1 @idDoc, 'TESTATA', 0, 'Size', size
				from TempCTLAtt03

			-- inserisce il numero di allegati
			insert into [dbo].[CTL_DOC_Value]
				( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] )
			select top 1 @idDoc, 'TESTATA', 0, 'NumAttach', Cnt
				from TempCTLAtt04

			-- inserisce l'id dell'ultima riga elaborata della ctl_attach
			insert into [dbo].[CTL_DOC_Value]
				( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] )
			values ( @idDoc, 'TESTATA', 0, 'LastIdRow', @LAST_ATT_IdRow )
			
			-- aggiorna il documento sulla CTL_DOC
			update [dbo].[CTL_DOC]
				set [StatoFunzionale] = 'Completato', [DataInvio] = getdate()
			where id = @idDoc


			set @DataExec2 = getdate()
			set @Duration = DATEDIFF (ss, @DataExec1, @DataExec2)
	  	  

			insert into [dbo].[GARBAGE_COLLECTOR_LOG]
				( [Elab_Key], [Step_Descr], [Step_Type], [DataExec], [Duration] )
			values
				( @Elab_Key, @Step_Descr, 'END', @DataExec2, @Duration )


		-- cancellazione tabella CTL_Encrypted_Attach		
		--delete from CTL_Encrypted_Attach 
		--	where att_idRow in (select ATT_IdRow from TempCTLAtt01)


	--END TRY
	--BEGIN CATCH
	--		SELECT COALESCE(ERROR_MESSAGE(), '') +  ' - Line: ' + COALESCE(CAST(ERROR_LINE() AS VARCHAR), '')
	--		ROLLBACK TRAN
	--		RETURN        
	--END CATCH

	

	--COMMIT TRAN

                
	
   
	SET NOCOUNT OFF

END



GO
