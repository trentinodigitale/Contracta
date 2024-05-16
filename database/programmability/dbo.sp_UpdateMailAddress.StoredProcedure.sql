USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateMailAddress]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[sp_UpdateMailAddress] (@NewMail NVARCHAR (50) = '') AS
set transaction isolation level serializable
begin tran
update Aziende set aziE_Mail = rtrim(ltrim(@NewMail))
IF @@error <> 0
   begin
        raiserror ('Errore "Update" Aziende', 16, 1)
        rollback tran
        return 99
   end
update ProfiliUtente set pfuE_Mail = rtrim(ltrim(@NewMail))
IF @@error <> 0
   begin
        raiserror ('Errore "Update" ProfiliUtente', 16, 1)
        rollback tran
        return 99
   end
update MPMail set mpmTo = rtrim(ltrim(@NewMail)), mpmCC = rtrim(ltrim(@NewMail)), mpmCCN = rtrim(ltrim(@NewMail))
IF @@error <> 0
   begin
        raiserror ('Errore "Update" MPMail', 16, 1)
        rollback tran
        return 99
   end
commit tran
GO
