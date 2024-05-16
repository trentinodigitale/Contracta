USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[UpdAttrAzi]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE PROCEDURE [dbo].[UpdAttrAzi] (  @IdAzi INT
                            , @dztNome VARCHAR(50)
                            , @Valore VARCHAR(MAX)
							, @DeleteAttrib int = 0
                           )
AS
begin 
	SET NOCOUNT ON


	DECLARE @TipoMem          INT
	DECLARE @dztMultiValue    INT
	DECLARE @ValTemp          VARCHAR(8000)
	DECLARE @ValTemp1         VARCHAR(8000)
	DECLARE @IdVat            INT
	DECLARE @IdDzt            INT
	DECLARE @IdUms            INT
	DECLARE @IdDscs           INT
	DECLARE @IdDscn           INT
	DECLARE @IdTid            INT
	DECLARE @IdDsc            INT
	DECLARE @TipoDom          CHAR(1)

	SELECT @TipoMem = tidTipoMem
		 , @IdDzt = IdDzt
		 , @IdUms = dztIdUmsDefault
		 , @IdTid = dztIdTid
		 , @TipoDom = tidTipoDom
		 , @dztMultiValue = dztMultiValue
	  FROM tipidati, dizionarioattributi
	 WHERE dztIdTid = IdTid
	   AND dztNome = @dztNome

	IF @IdDzt IS NULL
	BEGIN
			RAISERROR('Attributo %s non trovato', 16, 1, @dztNome)
			RETURN 99
	END


	/* Cancellazione */

	IF @TipoMem = 1
	BEGIN
			DELETE FROM  ValoriAttributi_Int WHERE IdVat IN (SELECT IdVat FROM DM_Attributi WHERE Lnk = @IdAzi AND IdApp = 1 AND dztNome = @dztNome)

			IF @@error <> 0
			BEGIN
					RAISERROR ('Errore "DELETE" ValoriAttributi_Int', 16, 1)
					RETURN 99
			END      
	END
	ELSE
	IF @TipoMem = 2
	BEGIN
			DELETE FROM  ValoriAttributi_Money WHERE IdVat IN (SELECT IdVat FROM DM_Attributi WHERE Lnk = @IdAzi AND IdApp = 1 AND dztNome = @dztNome)

			IF @@error <> 0
			BEGIN
					RAISERROR ('Errore "DELETE" ValoriAttributi_Money', 16, 1)
					RETURN 99
			END      
	END
	IF @TipoMem = 3
	BEGIN
			DELETE FROM  ValoriAttributi_Float WHERE IdVat IN (SELECT IdVat FROM DM_Attributi WHERE Lnk = @IdAzi AND IdApp = 1 AND dztNome = @dztNome)

			IF @@error <> 0
			BEGIN
					RAISERROR ('Errore "DELETE" ValoriAttributi_Float', 16, 1)
					RETURN 99
			END      
	END
	IF @TipoMem = 4
	BEGIN
			DELETE FROM  ValoriAttributi_NVarchar WHERE IdVat IN (SELECT IdVat FROM DM_Attributi WHERE Lnk = @IdAzi AND IdApp = 1 AND dztNome = @dztNome)

			IF @@error <> 0
			BEGIN
					RAISERROR ('Errore "DELETE" ValoriAttributi_NVarchar', 16, 1)
					RETURN 99
			END      
	END
	IF @TipoMem = 5
	BEGIN
			DELETE FROM  ValoriAttributi_Datetime WHERE IdVat IN (SELECT IdVat FROM DM_Attributi WHERE Lnk = @IdAzi AND IdApp = 1 AND dztNome = @dztNome)

			IF @@error <> 0
			BEGIN
					RAISERROR ('Errore "DELETE" ValoriAttributi_Datetime', 16, 1)
					RETURN 99
			END      
	END
	IF @TipoMem = 6
	BEGIN
			DELETE FROM  ValoriAttributi_Descrizioni WHERE IdVat IN (SELECT IdVat FROM DM_Attributi WHERE Lnk = @IdAzi AND IdApp = 1 AND dztNome = @dztNome)

			IF @@error <> 0
			BEGIN
					RAISERROR ('Errore "DELETE" ValoriAttributi_Descrizioni', 16, 1)
					RETURN 99
			END      
	END
	IF @TipoMem = 7
	BEGIN
			DELETE FROM  ValoriAttributi_keys WHERE IdVat IN (SELECT IdVat FROM DM_Attributi WHERE Lnk = @IdAzi AND IdApp = 1 AND dztNome = @dztNome)

			IF @@error <> 0
			BEGIN
					RAISERROR ('Errore "DELETE" ValoriAttributi_keys', 16, 1)
					RETURN 99
			END      
	END

	DELETE FROM  DFVatAzi WHERE IdVat IN (SELECT IdVat FROM DM_Attributi WHERE Lnk = @IdAzi AND IdApp = 1 AND dztNome = @dztNome)

	IF @@error <> 0
	BEGIN
			RAISERROR ('Errore "DELETE" DFVatAzi', 16, 1)
			RETURN 99
	END      

	DELETE FROM  ValoriAttributi WHERE IdVat IN (SELECT IdVat FROM DM_Attributi WHERE Lnk = @IdAzi AND IdApp = 1 AND dztNome = @dztNome)

	IF @@error <> 0
	BEGIN
			RAISERROR ('Errore "DELETE" ValoriAttributi', 16, 1)
			RETURN 99
	END      

	DELETE FROM DM_Attributi WHERE Lnk = @IdAzi AND IdApp = 1 AND dztNome = @dztNome

	IF @@error <> 0
	BEGIN
			RAISERROR ('Errore "DELETE" DFVatAzi', 16, 1)
			RETURN 99
	END      



	if @DeleteAttrib = 1
		return 0

	/* Fine Cancellazione */


	IF @IdUms IS NOT NULL
	BEGIN 
			SET @IdDscs = NULL
			SET @IdDscn = NULL
        
		   SELECT @IdDscs = umsIdDscsimbolo
				, @IdDscn = umsIdDscnome
			 FROM unitamisura
			WHERE IdUms = @IdUms
	END
        

	--IF LEFT(@Valore, 3) = '###'
	--        SET @ValTemp = SUBSTRING(@Valore, 4, 8000)
	--ELSE
	--        SET @ValTemp = @Valore


	DECLARE  curs CURSOR STATIC FOR     
		select distinct items from dbo.split( @Valore , '###' ) 


	OPEN  curs 
	FETCH NEXT FROM  curs INTO @ValTemp1


	WHILE @@FETCH_STATUS = 0   
	--WHILE @ValTemp <> '' AND @ValTemp <> '###'
	BEGIN
			--IF CHARINDEX('###', @ValTemp) <> 0
			--BEGIN
			--        SET @ValTemp1 = SUBSTRING (@ValTemp, 1, CHARINDEX('###', @ValTemp) -1)
			--        SET @ValTemp  = SUBSTRING (@ValTemp, CHARINDEX('###', @ValTemp) + 3, 8000)
			--END
			--ELSE 
			--BEGIN
			--        SET @ValTemp1 = @ValTemp
			--        SET @ValTemp = ''
			--END

			INSERT INTO ValoriAttributi (vatIdDzt, vatTipoMem) VALUES (@IdDzt, @TipoMem)

			IF @@error <> 0
			BEGIN
					RAISERROR ('Errore "INSERT" ValoriAttributi', 16, 1)
					RETURN 99
			END

			SET @IdVat = @@IDENTITY

			INSERT INTO DFVatAzi (IdAzi, IdVat) VALUES (@IdAzi, @IdVat)

			IF @@error <> 0
			BEGIN
					RAISERROR ('Errore "INSERT" ValoriAttributi', 16, 1)
					RETURN 99
			END

			IF @TipoMem = 1
			BEGIN
					INSERT INTO ValoriAttributi_Int (IdVat, vatValore) VALUES (@IdVat, @ValTemp1)

					IF @@error <> 0
					BEGIN
							RAISERROR ('Errore "INSERT" ValoriAttributi_Int', 16, 1)
							RETURN 99
					END      

					INSERT INTO DM_Attributi (IdApp, Lnk, IdVat, vatIdDzt, vatIdUms, vatIdUmsdscnome, vatIdUmsdscsimbolo,
											  dztNome, dztMultiValue, dztIdTid, vatValore_ft, vatValore_fv, isdsccsx, vatTipoMem)
						 VALUES (1, @IdAzi, @IdVat, @IdDzt, @IdUms, ISNULL(@IdDscn,'0'), ISNULL(@IdDscs,'0'),
									   @dztNome, @dztMultiValue, @IdTid, @ValTemp1, @ValTemp1, 0, 1)


					IF @@error <> 0
					BEGIN
							RAISERROR ('Errore "INSERT" DM_Attributi', 16, 1)
							RETURN 99
					END      
			END
			ELSE
			IF @TipoMem = 2
			BEGIN
					INSERT INTO ValoriAttributi_Money (IdVat, vatValore) VALUES (@IdVat, cast(@ValTemp1 as money))

					IF @@error <> 0
					BEGIN
							RAISERROR ('Errore "INSERT" ValoriAttributi_Money', 16, 1)
							RETURN 99
					END      

					INSERT INTO DM_Attributi (IdApp, Lnk, IdVat, vatIdDzt, vatIdUms, vatIdUmsdscnome, vatIdUmsdscsimbolo,
											  dztNome, dztMultiValue, dztIdTid, vatValore_ft, vatValore_fv, isdsccsx, vatTipoMem)
						 VALUES (1, @IdAzi, @IdVat, @IdDzt, @IdUms, ISNULL(@IdDscn,'0'), ISNULL(@IdDscs,'0'),
									   @dztNome, @dztMultiValue, @IdTid, ltrim(str(@ValTemp1, 20, 3)), ltrim(str(@ValTemp1, 20, 3)), 0, 2)


					IF @@error <> 0
					BEGIN
							RAISERROR ('Errore "INSERT" DM_Attributi', 16, 1)
							RETURN 99
					END      
			END
			IF @TipoMem = 3
			BEGIN
					INSERT INTO ValoriAttributi_Float (IdVat, vatValore) VALUES (@IdVat, @ValTemp1)

					IF @@error <> 0
					BEGIN
							RAISERROR ('Errore "INSERT" DM_Attributi', 16, 1)
							RETURN 99
					END      

					INSERT INTO DM_Attributi (IdApp, Lnk, IdVat, vatIdDzt, vatIdUms, vatIdUmsdscnome, vatIdUmsdscsimbolo,
											  dztNome, dztMultiValue, dztIdTid, vatValore_ft, vatValore_fv, isdsccsx, vatTipoMem)
						 VALUES (1, @IdAzi, @IdVat, @IdDzt, @IdUms, ISNULL(@IdDscn,'0'), ISNULL(@IdDscs,'0'),
									   @dztNome, @dztMultiValue, @IdTid, ltrim(str(@ValTemp1, 20, 3)), ltrim(str(@ValTemp1, 20, 3)), 0, 3)


					IF @@error <> 0
					BEGIN
							RAISERROR ('Errore "INSERT" DM_Attributi', 16, 1)
							RETURN 99
					END      
			END
			IF @TipoMem = 4
			BEGIN
					IF @TipoDom = 'A'
					BEGIN
							INSERT INTO ValoriAttributi_NVarchar (IdVat, vatValore) VALUES (@IdVat, @ValTemp1)
        
							IF @@error <> 0
							BEGIN
									RAISERROR ('Errore "INSERT" ValoriAttributi_NVarchar', 16, 1)
									RETURN 99
							END      
        
							INSERT INTO DM_Attributi (IdApp, Lnk, IdVat, vatIdDzt, vatIdUms, vatIdUmsdscnome, vatIdUmsdscsimbolo,
													  dztNome, dztMultiValue, dztIdTid, vatValore_ft, vatValore_fv, isdsccsx, vatTipoMem)
								 VALUES (1, @IdAzi, @IdVat, @IdDzt, @IdUms, ISNULL(@IdDscn,'0'), ISNULL(@IdDscs,'0'),
											   @dztNome, @dztMultiValue, @IdTid, @ValTemp1, @ValTemp1, 0, 4)
        
        
							IF @@error <> 0
							BEGIN
									RAISERROR ('Errore "INSERT" DM_Attributi', 16, 1)
									RETURN 99
							END      
					END
					ELSE
					IF @TipoDom = 'G'
					BEGIN
							
							SELECT @IdDsc = dgIdDsc
								FROM DominiGerarchici 
								WHERE dgTipoGerarchia = @IdTid
								AND dgCodiceInterno = @ValTemp1
								AND dgDeleted = 0
							
							--commentato perchè classifizioneSOA sebbene ancora censito nel vecchio dizionario
							--punta al dominio GERARCHICOSOA definito nelle nuove tabelle LIB_DOMAIN_VALUES
							--e quindi per un determinato codice potrebbe non trovare il corrispondente iddsc
							--IF @IdDsc IS NULL
							--BEGIN
							--		RAISERROR ('Codice %s non trovato per l''attributo %s', 16, 1, @ValTemp1, @dztNome)
							--		RETURN 99
										
							--END
							

							INSERT INTO ValoriAttributi_NVarchar (IdVat, vatValore) VALUES (@IdVat, @ValTemp1)
        
							IF @@error <> 0
							BEGIN
									RAISERROR ('Errore "INSERT" ValoriAttributi_NVarchar', 16, 1)
									RETURN 99
							END      
        
							INSERT INTO DM_Attributi (IdApp, Lnk, IdVat, vatIdDzt, vatIdUms, vatIdUmsdscnome, vatIdUmsdscsimbolo,
													  dztNome, dztMultiValue, dztIdTid, vatValore_ft, vatValore_fv, isdsccsx, vatTipoMem)
								 VALUES (1, @IdAzi, @IdVat, @IdDzt, @IdUms, ISNULL(@IdDscn,'0'), ISNULL(@IdDscs,'0'),
											   @dztNome, @dztMultiValue, @IdTid, @ValTemp1, @IdDsc, 1, 4)
        
        
							IF @@error <> 0
							BEGIN
									RAISERROR ('Errore "INSERT" DM_Attributi', 16, 1)
									RETURN 99
							END      
					END
					ELSE
					IF @TipoDom = 'C'
					BEGIN
							SELECT @IdDsc = tdrIdDsc
							  FROM TipiDatiRange
							 WHERE tdrIdTid = @IdTid
							   AND tdrCodice = @ValTemp1
							   AND tdrDeleted = 0

							IF @IdDsc IS NULL
							BEGIN
									RAISERROR ('Codice %s non trovato per l''attributo %s', 16, 1, @ValTemp1, @dztNome)
									RETURN 99
							END
                
							INSERT INTO ValoriAttributi_NVarchar (IdVat, vatValore) VALUES (@IdVat, @ValTemp1)
        
							IF @@error <> 0
							BEGIN
									RAISERROR ('Errore "INSERT" ValoriAttributi_NVarchar', 16, 1)
									RETURN 99
							END      
        
							INSERT INTO DM_Attributi (IdApp, Lnk, IdVat, vatIdDzt, vatIdUms, vatIdUmsdscnome, vatIdUmsdscsimbolo,
													  dztNome, dztMultiValue, dztIdTid, vatValore_ft, vatValore_fv, isdsccsx, vatTipoMem)
								 VALUES (1, @IdAzi, @IdVat, @IdDzt, @IdUms, ISNULL(@IdDscn,'0'), ISNULL(@IdDscs,'0'),
											   @dztNome, @dztMultiValue, @IdTid, @ValTemp1, @IdDsc, 1, 4)
        
        
							IF @@error <> 0
							BEGIN
									RAISERROR ('Errore "INSERT" DM_Attributi', 16, 1)
									RETURN 99
							END      
					END
			END
			IF @TipoMem = 5
			BEGIN
					if isdate(@ValTemp1) = 1
					BEGIN
						INSERT INTO ValoriAttributi_Datetime (IdVat, vatValore) VALUES (@IdVat, @ValTemp1)
					END					

					IF @@error <> 0
					BEGIN
							RAISERROR ('Errore "INSERT" ValoriAttributi_Datetime', 16, 1)
							RETURN 99
					END      

					INSERT INTO DM_Attributi (IdApp, Lnk, IdVat, vatIdDzt, vatIdUms, vatIdUmsdscnome, vatIdUmsdscsimbolo,
											  dztNome, dztMultiValue, dztIdTid, vatValore_ft, vatValore_fv, isdsccsx, vatTipoMem)
						 VALUES (1, @IdAzi, @IdVat, @IdDzt, @IdUms, ISNULL(@IdDscn,'0'), ISNULL(@IdDscs,'0'),
									   @dztNome, @dztMultiValue, @IdTid, @ValTemp1, @ValTemp1, 0, 5)


					IF @@error <> 0
					BEGIN
							RAISERROR ('Errore "INSERT" DM_Attributi', 16, 1)
							RETURN 99
					END      
			END
			IF @TipoMem = 6
			BEGIN
					SELECT @IdDsc = tdrIdDsc
					  FROM tipidatirange
					 WHERE tdrIdTid = @IdTid
					   AND tdrcodice = @ValTemp1
					   AND tdrDELETEd = 0

					IF @IdDsc IS NULL
					BEGIN
							RAISERROR ('Codice %s non trovato per l''attributo %s', 16, 1, @ValTemp1, @dztNome)
							RETURN 99
					END
                
					INSERT INTO ValoriAttributi_Descrizioni (IdVat, vatIdDsc) VALUES (@IdVat, @ValTemp1)

					IF @@error <> 0
					BEGIN
							RAISERROR ('Errore "INSERT" ValoriAttributi_Descrizioni', 16, 1)
							RETURN 99
					END      

					INSERT INTO DM_Attributi (IdApp, Lnk, IdVat, vatIdDzt, vatIdUms, vatIdUmsdscnome, vatIdUmsdscsimbolo,
											  dztNome, dztMultiValue, dztIdTid, vatValore_ft, vatValore_fv, isdsccsx, vatTipoMem)
						 VALUES (1, @IdAzi, @IdVat, @IdDzt, @IdUms, ISNULL(@IdDscn,'0'), ISNULL(@IdDscs,'0'),
									   @dztNome, @dztMultiValue, @IdTid, @ValTemp1, @IdDsc, 1, 6)


					IF @@error <> 0
					BEGIN
							RAISERROR ('Errore "INSERT" DM_Attributi', 16, 1)
							RETURN 99
					END      
			END
			IF @TipoMem = 7
			BEGIN
					SELECT @IdDsc = dgIdDsc
					  FROM dominigerarchici 
					 WHERE dgtipogerarchia = @IdTid
					   AND dgcodiceinterno = @ValTemp1
					   AND dgDELETEd = 0

					IF @IdDsc IS NULL
					BEGIN
							RAISERROR ('Codice %s non trovato per l''attributo %s', 16, 1, @ValTemp1, @dztNome)
							RETURN 99
					END
                
					INSERT INTO ValoriAttributi_keys (IdVat, vatValore) VALUES (@IdVat, @ValTemp1)

					IF @@error <> 0
					BEGIN
							RAISERROR ('Errore "INSERT" ValoriAttributi_Descrizioni', 16, 1)
							RETURN 99
					END      

					INSERT INTO DM_Attributi (IdApp, Lnk, IdVat, vatIdDzt, vatIdUms, vatIdUmsdscnome, vatIdUmsdscsimbolo,
											  dztNome, dztMultiValue, dztIdTid, vatValore_ft, vatValore_fv, isdsccsx, vatTipoMem)
						 VALUES (1, @IdAzi, @IdVat, @IdDzt, @IdUms, ISNULL(@IdDscn,'0'), ISNULL(@IdDscs,'0'),
									   @dztNome, @dztMultiValue, @IdTid, @ValTemp1, @IdDsc, 1, 7)


					IF @@error <> 0
					BEGIN
							RAISERROR ('Errore "INSERT" DM_Attributi', 16, 1)
							RETURN 99
					END

			END
		
			FETCH NEXT FROM  curs INTO @ValTemp1      
			
       
	END 
	CLOSE curs
	DEALLOCATE curs
	SET NOCOUNT OFF

END







GO
