USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOLogon_Check]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOLogon_Check] (@CurAziLog char(7), 
                               @CurLoginName NVARCHAR(12), 
                               @CurPassword NVARCHAR(12),
                               @CurIdAzi INT OUTPUT,
                               @CurIdPfu INT OUTPUT,
                               @CurIdLng INT OUTPUT,
                               @CurUserName NVARCHAR(30) OUTPUT)
AS
SELECT @CurIdAzi = IdAzi 
  FROM Aziende 
 WHERE aziLog = @CurAziLog 
   AND aziVenditore <> 2 
   AND aziAcquirente <> 2 
   AND azideleted = 0
 SELECT @CurIdAzi = ISNULL(@CurIdAzi, 0)
 SELECT @CurIdPfu = IdPfu, @CurIdLng = pfuIdLng, @CurUserName = pfuNome 
   FROM ProfiliUtente 
  WHERE pfuLogin = @CurLoginName 
    AND pfuPassword = @CurPassword 
    AND pfuIdAzi = @CurIdAzi 
    AND pfuDeleted = 0
SELECT @CurIdPfu = ISNULL(@CurIdPfu, 0)
SELECT @CurIdLng = ISNULL(@CurIdLng, 0)
SELECT @CurUserName = ISNULL(@CurUserName, '')
IF @CurIdPfu = 0 
   SELECT @CurIdAzi = 0, @CurIdPfu = 0
GO
