USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_QUESTIONARIO_AMMINISTRATIVO_CREATE_FROM_DOC]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD_QUESTIONARIO_AMMINISTRATIVO_CREATE_FROM_DOC](@idDoc INT, @IdUser INT)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @Id AS INT = 0

  -- Controllo se esiste già un doc QUESTIONARIO_AMMINISTRATIVO legato al doc origine
  SELECT @Id = Id
  FROM CTL_DOC WITH (NOLOCK)
  WHERE LinkedDoc=@idDoc AND TipoDoc='QUESTIONARIO_AMMINISTRATIVO' AND Deleted=0 and StatoFunzionale <> 'Annullato'

  IF (@Id = 0)
  BEGIN

    -- genero il record per il nuovo documento, cancellato logicamente per evitare che sia visibile se non finalizza le operazioni	
    INSERT INTO CTL_DOC (IdPfu, TipoDoc, Azienda, StrutturaAziendale, Titolo, LinkedDoc)
    SELECT IdPfu
           , 'QUESTIONARIO_AMMINISTRATIVO'
           , pfuIdAzi AS Azienda
           , CAST(pfuIdAzi AS VARCHAR) + '#' + '\0000\0000' AS StrutturaAziendale
           , 'Questionario Amministrativo'
           , @idDoc
    FROM ProfiliUtente WITH(NOLOCK)
    WHERE IdPfu = @IdUser

    SET @Id = SCOPE_IDENTITY()
  END

  SELECT @Id AS Id

END
GO
