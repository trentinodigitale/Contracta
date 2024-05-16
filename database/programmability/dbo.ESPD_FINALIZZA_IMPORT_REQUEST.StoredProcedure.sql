USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ESPD_FINALIZZA_IMPORT_REQUEST]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  PROCEDURE [dbo].[ESPD_FINALIZZA_IMPORT_REQUEST](  @idDoc INT, @idPfu INT )
AS
BEGIN

--	 string strSql = "INSERT INTO [CTL_IMPORT]   ([idPfu],[A],[B],[C],[D],[E],[F])" +
--                                    " VALUES(@idpfu,@responseQuestionID, @requestQuestionID, @tipoDomanda, @respValue, @ApplicablePeriodStart, @ApplicablePeriodEnd) ";

	-- l'idDoc sarà di un 'MODULO_TEMPLATE_REQUEST'


	DECLARE @responseQuestionID varchar(1000)
	DECLARE @requestQuestionID varchar(1000)
	DECLARE @tipoDomanda varchar(1000)
	DECLARE @respValue nvarchar(max)
	DECLARE @ApplicablePeriodStart varchar(100)
	DECLARE @ApplicablePeriodEnd varchar(100)
	DECLARE @evidenceReference VARCHAR(4000)
	DECLARE @evidenceUrl VARCHAR(4000)
	DECLARE @evidenceIssuer VARCHAR(4000)
	DECLARE @EOIDType VARCHAR(1000)

	declare @dztName varchar(4000)

	DECLARE curs CURSOR STATIC FOR     
		select A,B,C,D,E,F,G,H,I,L from CTL_IMPORT with(nolock) where idPfu = @idPfu

	OPEN curs 
	FETCH NEXT FROM curs INTO @responseQuestionID, @requestQuestionID, @tipoDomanda, @respValue, @ApplicablePeriodStart, @ApplicablePeriodEnd, @evidenceReference, @evidenceUrl, @evidenceIssuer,@EOIDType


	WHILE @@FETCH_STATUS = 0   
	BEGIN  

		-- per il momento il period è l'unico che fa eccezione, dobbiamo recuperare i dzt_name in modo diverso
		IF @tipoDomanda = 'PERIOD'
		BEGIN

			-- Nell'UUID della domanda ho il campo di data inizio, poi devo andare su quello di data fine
			select @dztName = DZT_Name from CTL_DOC_VALUE with(nolock) WHERE IdHeader = @idDoc and dse_id = 'UUID' and [value] = @requestQuestionID and [row] = 0

			UPDATE modulo
					SET [value] = @ApplicablePeriodStart
				FROM ctl_doc_value modulo 
				where modulo.IdHeader = @idDoc and modulo.DSE_ID = 'MODULO' and modulo.DZT_Name = @dztName 

			UPDATE modulo
					SET [value] = @ApplicablePeriodEnd
				FROM ctl_doc_value modulo 
				where modulo.IdHeader = @idDoc and modulo.DSE_ID = 'MODULO' and modulo.DZT_Name = replace(@dztName, '_FLD_I_', '_FLD_F_')

			--Data_I = cstr(g_col("MOD_" &  KeyModulo &  "_FLD_I_"  &  CurField))
			--Data_F = cstr(g_col("MOD_" &  KeyModulo &  "_FLD_F_"  &  CurField))

		END
		ELSE IF @tipoDomanda = 'EVIDENCE_IDENTIFIER'
		BEGIN

			SET @tipoDomanda = @tipoDomanda

			-- Nell'UUID della domanda ho il campo URL, poi devo andare su reference e issuer
			select @dztName = DZT_Name from CTL_DOC_VALUE with(nolock) WHERE IdHeader = @idDoc and dse_id = 'UUID' and [value] = @requestQuestionID  and [row] = 0

			UPDATE modulo
					SET [value] = @evidenceUrl
				FROM ctl_doc_value modulo 
				where modulo.IdHeader = @idDoc and modulo.DSE_ID = 'MODULO' and modulo.DZT_Name = @dztName 

			UPDATE modulo
					SET [value] = @evidenceReference
				FROM ctl_doc_value modulo 
				where modulo.IdHeader = @idDoc and modulo.DSE_ID = 'MODULO' and modulo.DZT_Name = replace(@dztName, '_FLD_URL_', '_FLD_REF_')

			UPDATE modulo
					SET [value] = @evidenceIssuer
				FROM ctl_doc_value modulo 
				where modulo.IdHeader = @idDoc and modulo.DSE_ID = 'MODULO' and modulo.DZT_Name = replace(@dztName, '_FLD_URL_', '_FLD_ISS_')

				--  '-- URL
				--	'"MOD_" &  KeyModulo &  "_FLD_URL_"  &  CurField 
				--	'-- REFERENCE
				--	'"MOD_" &  KeyModulo &  "_FLD_REF_"  &  CurField
				--	'-- ISSUER
				--	'"MOD_" &  KeyModulo &  "_FLD_ISS_"  &  CurField 

		END
		ELSE IF @tipoDomanda = 'ECONOMIC_OPERATOR_IDENTIFIER'
		BEGIN

			-- call MakeAttrib( "MOD_" &  KeyModulo &  "_FLD_ID_"  &  CurField  , RG_FLD_TYPE & "_TYPE" , Obbligatorio , DZT_Type ,"EOIDType" , DZT_DM_ID_Um , DZT_Dec , DZT_Len , DZT_Format , DZT_Help , DZT_InCaricoA  , SorgenteCampo , iif( UUID = "" , "" , UUID & "_ID") )
			-- call MakeAttrib( "MOD_" &  KeyModulo &  "_FLD_"  &  CurField  , RG_FLD_TYPE , Obbligatorio , DZT_Type ,DZT_DM_ID , DZT_DM_ID_Um , DZT_Dec , DZT_Len , DZT_Format , DZT_Help , DZT_InCaricoA , SorgenteCampo ,   UUID   )

			-- Nell'UUID della domanda ho il campo del valore dell'eo identifier. vado poi a prendermi quello per il tipo identificatore
			select @dztName = DZT_Name from CTL_DOC_VALUE with(nolock) WHERE IdHeader = @idDoc and dse_id = 'UUID' and [value] = @requestQuestionID and [row] = 0

			UPDATE modulo
					SET [value] = @respValue
				FROM ctl_doc_value modulo 
				where modulo.IdHeader = @idDoc and modulo.DSE_ID = 'MODULO' and modulo.DZT_Name = @dztName 

			UPDATE modulo
					SET [value] = @EOIDType
				FROM ctl_doc_value modulo 
				where modulo.IdHeader = @idDoc and modulo.DSE_ID = 'MODULO' and modulo.DZT_Name = replace(@dztName, '_FLD_', '_FLD_ID_')


		END
		ELSE
		BEGIN

			UPDATE modulo
					SET [value] = @respValue
				FROM ctl_doc_value uuid with(nolock) 
						inner join ctl_doc_value modulo with(nolock) on modulo.IdHeader = uuid.IdHeader and modulo.DSE_ID = 'MODULO' and modulo.DZT_Name = uuid.DZT_Name
				WHERE uuid.IdHeader = @idDoc and uuid.DSE_ID = 'UUID' and uuid.[Value] = @requestQuestionID and uuid.[row] = 0

		END

		-- AREA DATI UUID : 
		--SELECT * from ctl_doc_value with(nolock) where idheader = " & g_idDoc & " and DSE_ID = 'UUID' and row = 0  order by idrow 

		-- AREA DATI VALORI :
		--SELECT * from ctl_doc_value with(nolock) where idheader = " & g_idDoc & " and DSE_ID = 'MODULO'  order by idrow

		FETCH NEXT FROM curs INTO @responseQuestionID, @requestQuestionID, @tipoDomanda, @respValue, @ApplicablePeriodStart, @ApplicablePeriodEnd, @evidenceReference, @evidenceUrl, @evidenceIssuer,@EOIDType

	END  

	CLOSE curs   
	DEALLOCATE curs

END



GO
