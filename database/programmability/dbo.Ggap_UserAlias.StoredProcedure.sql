USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_UserAlias]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Ggap_UserAlias] ( @idAzi int, @idPfu int )
AS
BEGIN
    
	SET NOCOUNT ON
    
    --DECLARE @idAzi INT = 35152001
    --DECLARE @idPfu INT = 45094

    DECLARE @userAlias VARCHAR(MAX)
    DECLARE @pfulogin VARCHAR(MAX)
    DECLARE @azilog VARCHAR(MAX)

    SELECT 
           @pfulogin=pfulogin
           , @azilog=azilog
           --pfulogin
           --, azilog
        FROM ProfiliUtente WITH (NOLOCK)
                INNER JOIN Aziende WITH (NOLOCK) ON pfuidazi = idazi
        WHERE IdPfu = @idPfu


    SET @userAlias = CAST(@pfulogin AS NVARCHAR(MAX)) + '_' + CAST(@azilog AS NVARCHAR(MAX)) -- E_SABATO_FERRARO_5_ER000AA -- E_CORRADO_VERSOLATO_FV000AA

    --SELECT 'E_CORRADO_VERSOLATO_FV000AA'
    SELECT @userAlias

END

GO
