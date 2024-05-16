USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[FLES_SP_PCP_APPALTO_SCHEDA_INSERT_AGGIORNA_FLES]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE      PROC [dbo].[FLES_SP_PCP_APPALTO_SCHEDA_INSERT_AGGIORNA_FLES] ( 
            @idDoc INT , 
			@uuid  varchar(max),
			@tipoScheda varchar(100), 
			@IdDoc_Scheda int = 0,
			@CIG varchar(max) = null,
			@DatiElaborazione varchar(max) = null,
			@idRowScheda INT = -1 OUTPUT)
AS
BEGIN

	SET NOCOUNT ON
	
	INSERT INTO Document_PCP_Appalto_Schede ( idHeader, bDeleted, dateInsert, tipoScheda, statoScheda, IdDoc_Scheda,  CIG, DatiElaborazione)
									VALUES  ( @idDoc, 0, getDate(), @tipoScheda, 'InvioInCorso', @IdDoc_Scheda, @CIG, @DatiElaborazione ) 
	
	set @idRowScheda = SCOPE_IDENTITY()

	IF @tipoScheda = 'I1'
	       UPDATE FLES_TABLE_SCHEDA_I1 SET IDROW_PCP_SCHEDE = @idRowScheda ,  DATA_ULTIMA_MODIFICA = getDate()
		   where  UUID = @uuid and IDDOC = @IdDoc_Scheda 
	ELSE IF @tipoScheda = 'SA1'
			UPDATE FLES_TABLE_SCHEDA_SA1 SET IDROW_PCP_SCHEDE = @idRowScheda ,  DATA_ULTIMA_MODIFICA = getDate()
		    where  UUID = @uuid and IDDOC = @IdDoc_Scheda
	ELSE IF @tipoScheda = 'M1' OR @tipoScheda = 'M1_40' OR @tipoScheda = 'M2' OR @tipoScheda = 'M2_40'
			UPDATE FLES_TABLE_MODIFICA_CONTRATTUALE SET IDROW_PCP_SCHEDE = @idRowScheda ,  DATA_ULTIMA_MODIFICA = getDate()
		    where  UUID = @uuid and IDDOC = @IdDoc_Scheda
	ELSE IF @tipoScheda = 'CO1'
			UPDATE FLES_TABLE_SCHEDA_CO1 SET IDROW_PCP_SCHEDE = @idRowScheda ,  DATA_ULTIMA_MODIFICA = getDate()
		    where  UUID = @uuid and IDDOC = @IdDoc_Scheda
	
END



GO
