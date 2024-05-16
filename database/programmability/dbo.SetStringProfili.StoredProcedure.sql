USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SetStringProfili]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SetStringProfili] AS

DECLARE tmpcrs cursor static for
SELECT IdPfu, pfuAdmin, pfuAcquirente, pfuVenditore FROM  ProfiliUtente
DECLARE @strProfilo AS VARCHAR(20)
DECLARE @bAdmin AS bit
DECLARE @bAcquirente AS bit
DECLARE @bVenditore  AS bit
DECLARE @nIdPfu  AS INT
open tmpcrs
fetch next FROM tmpcrs INTo @nIdPfu,@bAdmin, @bAcquirente, @bVenditore
while @@fetch_status = 0
begin
   SELECT @strprofilo = NULL
 
   IF @bAdmin = 1 AND @bAcquirente = 0 AND @bVenditore = 0
       begin 
          SELECT @strProfilo =  'A'
           
       end
 
   IF @bAdmin = 0 AND @bAcquirente = 1 AND @bVenditore = 0
       begin 
          SELECT @strProfilo =  'B'
           
       end
   IF @bAdmin = 0 AND @bAcquirente = 0 AND @bVenditore = 1
       begin 
          SELECT @strProfilo =  'S'
           
       end
 
   IF @bAdmin = 1 AND @bAcquirente = 1 AND @bVenditore = 0
       begin 
          SELECT @strProfilo =  'AB'
           
       end
   IF @bAdmin = 1 AND @bAcquirente = 0 AND @bVenditore = 1
       begin 
          SELECT @strProfilo =  'AS'
           
       end
   IF @bAdmin = 0 AND @bAcquirente = 1 AND @bVenditore = 1
       begin 
          SELECT @strProfilo =  'BS'
           
       end
   IF @bAdmin = 1 AND @bAcquirente = 1 AND @bVenditore = 1
       begin 
          SELECT @strProfilo =  'ABS'
           
       end
 
  update ProfiliUtente set pfuProfili = @strProfilo
  WHERE IdPfu = @nIdPfu
  fetch next FROM tmpcrs INTo @nIdPfu,@bAdmin, @bAcquirente, @bVenditore
end
close tmpcrs
deallocate tmpcrs


GO
