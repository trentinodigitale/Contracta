USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_Ggap_LeggiUOByCfEnte_Auth]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--> DEVE necessariamente esserci o @idSmartCig oppure @idAzi
CREATE PROCEDURE [dbo].[OLD_Ggap_LeggiUOByCfEnte_Auth] ( @idSmartCig int = 0, @idAzi int = 0, @userRup int = 0 )
AS
BEGIN
    
	SET NOCOUNT ON

    --DECLARE @idAzi INT = 35157192 -- 35159461
    --DECLARE @idSmartCig int = 0
    --DECLARE @idDoc int = 0 --475510

    --DECLARE @connectedUserIdUo INT = 17
    DECLARE @vatValore_FT nvarchar(3000)
    DECLARE @pfulogin VARCHAR(MAX)
    DECLARE @azilog VARCHAR(MAX)
    DECLARE @userAlias VARCHAR(MAX)

    
	-- recupero il codice fiscale dell'ente
    IF (@idSmartCig = 0)
    BEGIN
        --DECLARE @idAzi int = 35157192
        --DECLARE @userRup int = 45912

       SELECT @vatValore_FT = vatValore_FT -- => 80014930327
            FROM DM_Attributi WITH (NOLOCK)
            WHERE idApp = 1 AND dztNome = 'codicefiscale' AND lnk = @idAzi -- 00118410323 -- 80014930327
    
        -- Costruisco lo userAlias/connectedUserAlias
        SELECT @pfulogin=PU.pfulogin, @azilog=A.azilog
            FROM ProfiliUtente PU WITH (NOLOCK)
                    INNER JOIN Aziende A WITH (NOLOCK) ON pfuIdAzi = @IdAzi
    END
	ELSE
    BEGIN
        -- Recupero l'id del bando
        DECLARE @idDoc int

            SELECT @idDoc = LinkedDoc
                FROM CTL_DOC
                WHERE Id = @idSmartCig

        --UPDATE CTL_DOC SET Azienda=35157192--35152001
        --WHERE Id=@idDoc

        SELECT @vatValore_FT=vatValore_FT -- => 91252510374
            FROM CTL_DOC WITH (NOLOCK)
                    INNER JOIN DM_Attributi WITH (NOLOCK)
                        ON Azienda = lnk AND idApp = 1 AND dztNome = 'codicefiscale'
            WHERE Id = @idDoc

        -- Costruisco lo userAlias/connectedUserAlias
        SELECT @pfulogin=PU.pfulogin, @azilog=A.azilog
            FROM ProfiliUtente PU WITH (NOLOCK)
                    INNER JOIN Aziende A WITH (NOLOCK) ON pfuIdAzi = IdAzi
            WHERE IdPfu = (SELECT idpfu FROM ctl_doc WHERE Id = @idDoc)
    END


    --select * from ProfiliUtente with(nolock) where idpfu = 45094--@userRup 


    SET @userAlias = CAST(@pfulogin AS NVARCHAR(MAX)) + '_' + CAST(@azilog AS NVARCHAR(MAX)) -- E_SABATO_FERRARO_5_ER000AA
        --SET @userAlias = 'wsApp' -- 'E_CORRADO_VERSOLATO_FV000AA' -- TODO: rimuovere, è solo per test
        --SELECT @userAlias, @idAzi


    SELECT @UserAlias  AS connectedUserAlias
           --,@connectedUserIdUo  AS connectedUserIdUo
           ,@vatValore_FT       AS vatValore_FT

END

GO
