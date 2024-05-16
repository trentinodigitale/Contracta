USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[sp_MoveMSG]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[sp_MoveMSG] (@SrcAzilog AS char (7), @SrcLogin  AS VARCHAR (12),  @SrcPwd AS VARCHAR (12),  @DstAzilog AS char (7), @DstLogin  AS VARCHAR (12), @DstPwd    AS VARCHAR (12)) AS
DECLARE @SrcIdPfu  AS INT
DECLARE @DstIdPfu  AS INT
SELECT @SrcIdPfu = IdPfu 
  FROM Aziende, ProfiliUtente_Prospect
 WHERE IdAzi = pfuIdAzi
   AND aziLog = @SrcAzilog 
   AND pfuLogin = @SrcLogin
   AND pfuPassword = @SrcPwd
 IF @SrcIdPfu IS NULL
    begin
          raiserror ('Utente [%s] - [%s] - [%s] non  trovato', 16, 1, @SrcAzilog, @SrcLogin, @SrcPwd)
          return -- 99
    end
SELECT @DstIdPfu = IdPfu 
  FROM Aziende, ProfiliUtente
 WHERE IdAzi = pfuIdAzi
   AND aziLog = @DstAzilog 
   AND pfuLogin = @DstLogin
   AND pfuPassword = @DstPwd
 IF @DstIdPfu IS NULL
    begin
          raiserror ('Utente [%s] - [%s] - [%s] non  trovato', 16, 1, @DstAzilog, @DstLogin, @DstPwd)
          return 99
    end
begin tran
    update tab_utenti_messaggi 
       set umIsProspect = 0, umIdPfu = @DstIdPfu
     WHERE umIdPfu = @SrcIdPfu
    IF @@error <> 0
       begin
            raiserror ('Errore "Update" tab_utenti_messaggi', 16, 1)
            rollback tran
            return  99
       end
commit tran
GO
