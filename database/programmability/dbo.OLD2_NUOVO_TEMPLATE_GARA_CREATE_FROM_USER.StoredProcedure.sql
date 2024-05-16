USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_NUOVO_TEMPLATE_GARA_CREATE_FROM_USER]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OLD2_NUOVO_TEMPLATE_GARA_CREATE_FROM_USER] (@idDoc INT, @IdUser INT)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @Id AS INT

    -- genero il record per il nuovo documento, cancellato logicamente per evitare che sia visibile se non finalizza le operazioni	
    INSERT INTO CTL_DOC (IdPfu, TipoDoc, Azienda, deleted, StrutturaAziendale, Caption)
    SELECT idpfu
           , 'TEMPLATE_GARA'
           , pfuidazi AS Azienda
           , 1
           , cast(pfuidazi AS VARCHAR) + '#' + '\0000\0000' AS StrutturaAziendale
           , 'Nuovo Template Gara'
    FROM profiliutente WITH(NOLOCK)
    WHERE idpfu = @IdUser

    SET @id = SCOPE_IDENTITY()

    -- aggiunge il record sul bando				
    INSERT INTO Document_Bando (idHeader, TipoProceduraCaratteristica, DirezioneEspletante, EvidenzaPubblica)
    SELECT @id
           , ''
           , cast(pfuidazi AS VARCHAR) + '#' + '\0000\0000' AS DirezioneEspletante
           , '0'
    FROM profiliutente WITH(NOLOCK)
    WHERE idpfu = @IdUser

    --INSERT INTO Document_Bando_Riferimenti (idHeader, idPfu)
    --VALUES (@id, @IdUser)

    select @Id as id

END
GO
