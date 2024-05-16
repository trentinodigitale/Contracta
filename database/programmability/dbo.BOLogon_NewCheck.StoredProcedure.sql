USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOLogon_NewCheck]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOLogon_NewCheck] (@CurAziLog char(7), 
                                  @CurLoginName NVARCHAR(12), 
                                  @CurPassword NVARCHAR(12),
                                  @CurMpLog  NVARCHAR (12),
                                  @CurIdAzi INT OUTPUT,
                                  @CurIdPfu INT OUTPUT,
                                  @CurSuffLingua VARCHAR(3) OUTPUT,
                                  @CurUserName NVARCHAR(30) OUTPUT,
                                  @CurProfili VARCHAR(20) OUTPUT)
AS
SELECT @CurIdAzi = IdAzi 
  FROM Aziende, MPAziende, MarketPlace
 WHERE IdAzi = mpaIdazi
   AND mpaIdMp = IdMp
   AND mpLog = @CurMpLog
   AND aziLog = @CurAziLog
   AND mpaVenditore <> 2 
   AND mpaAcquirente <> 2 
   AND mpaProspect = 0
   AND mpaDeleted = 0
   AND aziDeleted = 0
SELECT @CurIdAzi = ISNULL(@CurIdAzi, 0)
 
SELECT @CurIdPfu = IdPfu, @CurSuffLingua = lngSuffisso, @CurUserName = pfuNome, @CurProfili = pfuProfili 
  FROM ProfiliUtente, Lingue
 WHERE IdLng = pfuIdLng 
   AND pfuLogin = @CurLoginName 
   AND pfuPassword = @CurPassword 
   AND pfuIdAzi = @CurIdAzi 
   AND pfuDeleted = 0
 
SELECT @CurIdPfu = ISNULL(@CurIdPfu, 0)
SELECT @CurSuffLingua = ISNULL(@CurSuffLingua, '')
SELECT @CurUserName = ISNULL(@CurUserName, '')
SELECT @CurProfili = ISNULL(@CurProfili, '')
IF @CurIdPfu = 0 
   SELECT @CurIdAzi = 0, @CurIdPfu = 0
GO
