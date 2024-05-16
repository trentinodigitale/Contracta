USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SetStringFunzionalita]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SetStringFunzionalita] AS

DECLARE tmpcrs cursor static for
SELECT IdPfu, pfuAdmin, pfuAcquirente, pfuVenditore, pfuInvRdo, pfuCopiaRdo, pfuInvOff, pfuCopiaOffRic, pfuCatalogo 
FROM  ProfiliUtente
DECLARE @strFunzionalita AS VARCHAR(50)
DECLARE @bAdmin AS bit
DECLARE @bAcquirente AS bit
DECLARE @bVenditore  AS bit
DECLARE @nIdPfu  AS INT
DECLARE @bInvRdo  AS bit
DECLARE @bCopiaRdo  AS bit
DECLARE @bInvOff  AS bit
DECLARE @bCopiaOffRic  AS bit
DECLARE @bCopiaCatalogo  AS bit
DECLARE @strstringavuota AS char(42)
open tmpcrs
fetch next FROM tmpcrs INTo @nIdPfu,@bAdmin, @bAcquirente, @bVenditore, @bInvRdo, @bCopiaRdo, @bInvOff,@bCopiaOffRic, @bCopiaCatalogo
while @@fetch_status = 0
begin
         
      SELECT @strstringavuota = '000000000000000000000000000000000000000000'
         SELECT @strFunzionalita =        cast(@bAdmin AS char(1)) + 
                              cast(@bAcquirente AS char(1)) +
                              cast(@bVenditore AS char(1)) +
                              cast(@bInvRdo AS char(1)) +
                              cast(@bCopiaRdo AS char(1)) +
                              cast(@bInvOff AS char(1)) +
                              cast(@bCopiaOffRic AS char(1)) +
                              cast(@bCopiaCatalogo AS char(1)) + 
                              cast(@strstringavuota AS char(42))
                              
      
update ProfiliUtente set pfuFunzionalita = @strFunzionalita
  WHERE IdPfu = @nIdPfu
  fetch next FROM tmpcrs INTo @nIdPfu,@bAdmin, @bAcquirente, @bVenditore, @bInvRdo, @bCopiaRdo, @bInvOff,@bCopiaOffRic, @bCopiaCatalogo
  
end
 
  
close tmpcrs
deallocate tmpcrs


GO
