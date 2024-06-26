USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_ALLINEAMENTO_UTENTE_LEGACY]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD2_ALLINEAMENTO_UTENTE_LEGACY]  (	 @idPfu int )
AS
BEGIN

	--	QUESTA STORED SERVE PER ALLINEARE UN AZIENDA GIA' PRESENTE, CON CHIAVE IDAZI, NEL DATABASE CONTENUTO NELLA SYS 'SYS_DBNAME_PREV_VER'
	--	NON È PREVISTA L'AGGIUNTA DI NUOVE AZIENDE 

	SET NOCOUNT ON;

	DECLARE @newID INT
	DECLARE @pfuNome nvarchar(1000)
	DECLARE @pfuE_Mail nvarchar(1000)
	DECLARE @pfuTel nvarchar(100)
	DECLARE @pfuCel nvarchar(100)
	DECLARE @pfuCodiceFiscale nvarchar(100)
	DECLARE @pfuTitolo nvarchar(200)
	DECLARE @LOGIN nvarchar(200)
	DECLARE @QUALIFICA nvarchar(200)

	DECLARE @dbLegacy varchar(500)

	DECLARE @strSQL nvarchar(max)

	SET @dbLegacy = ''

	SELECT @dbLegacy = DZT_ValueDef
		from LIB_Dictionary with(nolock)
		where DZT_Name = 'SYS_DBNAME_PREV_VER'

	----------------------------------------------------------- 
	-- SE ESISTE LA SYS 'SYS_DBNAME_PREV_VER' E NON E' VUOTA --
	-----------------------------------------------------------
	IF LTRIM(rtrim(@dbLegacy)) <> '' 
	BEGIN

		CREATE TABLE #T1
		(
			idpfu int
		)

		INSERT INTO #T1 exec('SET NOCOUNT ON; select idpfu from ' + @dbLegacy + '..profiliutente where idpfu = ' + @idPfu )

		SET @strSQL = ''

		------------------------------------------------------------------------
		-- PRENDO I DATI DAL DB MASTER. CIOÈ QUELLO SUL QUALE GIRA LA STORED ---
		------------------------------------------------------------------------
		SELECT	   @pfuNome= isnull(pfuNome,''),
					@pfuE_Mail = isnull(pfuE_Mail,''),
					@pfuTel = isnull(pfuTel,''),
					@pfuCel = isnull(pfuCell,''),
					@pfuCodiceFiscale = isnull(pfuCodiceFiscale,''),
					@pfuTitolo = isnull(pfuTitolo,''),
					@LOGIN = isnull(pfuLogin,''),
					@QUALIFICA = isnull(pfuRuoloAziendale,'')
				from profiliutente with(nolock) 
				where idpfu = @idPfu

		---------------------------------------------
		-- SE L'UTENTE ESISTE NEL DATABASE SLAVE ---
		---------------------------------------------
		IF EXISTS ( select idpfu from #T1 )
		BEGIN

			SET @strSQL = 'SET NOCOUNT ON; 
				UPDATE ' + @dbLegacy + '..profiliutente
					SET pfuNome = ''' + replace(@pfuNome, '''','''''') + '''
						,pfuE_Mail = ''' + @pfuE_Mail + '''
						,pfuTel = ''' + replace(@pfuTel, '''','''''') + '''
						,pfuCell = ''' + replace(@pfuCel, '''','''''') + '''
						,pfuCodiceFiscale = ''' + replace(@pfuCodiceFiscale, '''','''''') + '''
						,pfuTitolo =  ''' + replace(@pfuTitolo, '''','''''') + '''
				WHERE idpfu = ' + cast(@idPfu as varchar(100))

			EXEC(@strSQL)

		END
		ELSE
		BEGIN

			-------------------------------------------------------------------------------------
			-- SE L'UTENTE NON ESISTE MA FA PARTE DELL'AZI MASTER, LA CREO ANCHE SUL DB SLAVE ---
			-------------------------------------------------------------------------------------
			IF EXISTS ( select idpfu from ProfiliUtente with(nolock) where IdPfu = @idPfu and pfuIdAzi = 35152001 )
			BEGIN

				-- ( la transazione viene sempre preservata quando i database chiamati sono sullo stesso server )
				SET @strSQL =  '	SET Identity_insert '  +  @dbLegacy + '..ProfiliUtente on; SET NOCOUNT ON; EXEC ' + @dbLegacy + '..CREA_UTENTE_LEGACY_AZI_MASTER ' + cast(@idPfu as varchar(100)) + ',''' + replace(@LOGIN, '''','''''') + ''',''' + replace(@pfuNome, '''','''''') + ''',''' + replace(@QUALIFICA, '''','''''') + ''''
				
				SET @strSQL = @strSQL + ',''' + replace(@pfuTel, '''','''''') + ''',''' + replace(@pfuCel, '''','''''')  + ''',''' + replace(@pfuE_Mail, '''','''''') + ''',''' + replace(@pfuCodiceFiscale, '''','''''') + ''''
				SET @strSQL = @strSQL + ';SET Identity_insert '  +  @dbLegacy + '..ProfiliUtente OFF;'
				--print @strSQL

				BEGIN TRY  
					EXEC(@strSQL)
				END TRY  
				BEGIN CATCH

					DECLARE @ErrorMessage NVARCHAR(4000)
					DECLARE @ErrorSeverity INT
					DECLARE @ErrorState INT

					SELECT  @ErrorMessage = ERROR_MESSAGE(),  
							@ErrorSeverity = ERROR_SEVERITY(),  
							@ErrorState = ERROR_STATE() 

					RAISERROR (@ErrorMessage,
							   @ErrorSeverity,
							   @ErrorState
							   )

					RETURN 

				END CATCH 
				

				-- AGGIUNGO IL PROFILO DI SSO_LEGACY ALL'UTENTE DELL'ENTE APPENA CREATO, SUL DB MASTER, PER PERMETTERGLI DI COLLEGARSI SULLA PRECEDENTE PIATTAFORMA
				INSERT INTO ProfiliUtenteAttrib( IdPfu, dztNome, attValue)
						select a.IdPfu, 'Profilo', 'SSO_LEGACY_ENTE'
							from ProfiliUtente a with(nolock)	
									left join ProfiliUtenteAttrib b with(nolock) on b.IdPfu = a.IdPfu and b.dztNome = 'Profilo' and b.attValue = 'SSO_LEGACY_ENTE'
							where a.IdPfu = @idPfu and b.IdUsAttr is null

				UPDATE ProfiliUtente
					SET pfufunzionalita = dbo.XOR_FUNZIONALITA_FROM_IDPFU (idpfu),
						pfuprofili = dbo.MERGE_PFUPROFILO_FROM_IDPFU(idpfu)
					WHERE idpfu = @idPfu

			END
			ELSE --NEL CASO NON ESISTE UTENTE E LA CONFIGURAZIONE PREVEDE L'INSERIMENTO INSERT_USER_AZI = 'SI' nella CTL_PARAMETRI
			IF dbo.parametri('PREVIOUS_VERSION','INSERT_USER_AZI','ATTIVO','NO',-1) = 'SI'
			BEGIN	
				SET @strSQL = '	SET Identity_insert '  +  @dbLegacy + '..ProfiliUtente on; 
 								SET NOCOUNT ON; 
								INSERT INTO '  +  @dbLegacy + '..ProfiliUtente ([IdPfu], [pfuIdAzi], [pfuNome], [pfuLogin], [pfuRuoloAziendale], [pfuPassword], [pfuPrefissoProt], [pfuAdmin], [pfuAcquirente], [pfuVenditore], [pfuInvRdO], [pfuRcvOff], [pfuInvOff], [pfuIdPfuBCopiaA], [pfuIdPfuSCopiaA], [pfuCopiaRdo], [pfuCopiaOffRic], [pfuImpMaxRdO], [pfuImpMaxOff], [pfuImpMaxRdoAnn], [pfuImpMaxOffAnn], [pfuIdLng], [pfuParametriBench], [pfuSkillLevel1], [pfuSkillLevel2], [pfuSkillLevel3], [pfuSkillLevel4], [pfuSkillLevel5], [pfuSkillLevel6], [pfuE_Mail], [pfuTestoSollecito], [pfuDeleted], [pfuBizMail], [pfuCatalogo], [pfuProfili], [pfuFunzionalita], [pfuopzioni], [pfuTel], [pfuCell], [pfuSIM], [pfuIdMpMod], [pfuToken], [pfuCodiceFiscale], [pfuLastLogin], [pfuAlgoritmoPassword], [pfuDataCambioPassword], [pfuStato], [pfuTentativiLogin], [pfuSessionID])
									SELECT P.[IdPfu], [pfuIdAzi], [pfuNome], [pfuLogin], [pfuRuoloAziendale], [pfuPassword], [pfuPrefissoProt], [pfuAdmin], [pfuAcquirente], [pfuVenditore], [pfuInvRdO], [pfuRcvOff], [pfuInvOff], [pfuIdPfuBCopiaA], [pfuIdPfuSCopiaA], [pfuCopiaRdo], [pfuCopiaOffRic], [pfuImpMaxRdO], [pfuImpMaxOff], [pfuImpMaxRdoAnn], [pfuImpMaxOffAnn], [pfuIdLng], [pfuParametriBench], [pfuSkillLevel1], [pfuSkillLevel2], [pfuSkillLevel3], [pfuSkillLevel4], [pfuSkillLevel5], [pfuSkillLevel6], [pfuE_Mail], [pfuTestoSollecito], [pfuDeleted], [pfuBizMail], [pfuCatalogo], [pfuProfili], ISNULL(valore,[pfuFunzionalita]), [pfuopzioni], [pfuTel], [pfuCell], [pfuSIM], [pfuIdMpMod], [pfuToken], [pfuCodiceFiscale], [pfuLastLogin], [pfuAlgoritmoPassword], [pfuDataCambioPassword], [pfuStato], [pfuTentativiLogin], [pfuSessionID]
										FROM ProfiliUtente P
											inner join aziende on idazi=pfuidazi
											left join ctl_parametri on Contesto=''PERMESSI_UTENTE_LEGACY_'' + aziProfili and Oggetto=''UTENTE_OE'' and Proprieta=''PERMESSI'' and valore <> ''''
											WHERE P.idpfu = ' + cast(@idPfu as varchar(100)) + '
							SET Identity_insert '  +  @dbLegacy + '..ProfiliUtente OFF; '						
				
					--print @strSQL
					EXEC(@strSQL)

				--INSERISCO I ProfiliUtenteAttrib SUL VECCHIO DB
					SET @strSQL = 'SET NOCOUNT ON; 
						INSERT INTO '  +  @dbLegacy + '..ProfiliUtenteAttrib ([IdPfu], [dztNome], [attValue])
							SELECT PA.[IdPfu], PA.[dztNome], PA.[attValue]
								FROM ProfiliUtenteAttrib PA																	
								WHERE PA.idpfu = ' + cast(@idPfu as varchar(100)) 
					--print @strSQL
					EXEC(@strSQL)
					
				INSERT INTO ProfiliUtenteAttrib( IdPfu, dztNome, attValue)
					select a.IdPfu, 'Profilo', 'SSO_LEGACY_ENTE'
						from ProfiliUtente a with(nolock)	
								left join ProfiliUtenteAttrib b with(nolock) on b.IdPfu = a.IdPfu and b.dztNome = 'Profilo' and b.attValue = 'SSO_LEGACY_ENTE'
						where a.IdPfu = @idPfu and b.IdUsAttr is null

				UPDATE ProfiliUtente
					SET pfufunzionalita = dbo.XOR_FUNZIONALITA_FROM_IDPFU (idpfu),
						pfuprofili = dbo.MERGE_PFUPROFILO_FROM_IDPFU(idpfu)
					WHERE idpfu = @idPfu	
			END

		END

	END

END










GO
