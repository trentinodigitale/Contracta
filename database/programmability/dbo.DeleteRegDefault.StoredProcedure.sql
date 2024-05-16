USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DeleteRegDefault]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autore: Alfano Antoni
Scopo: Delete logico elemento RegDefault
data: 4/7/2001
*/
CREATE PROCEDURE [dbo].[DeleteRegDefault] (@Idrd INT) AS
Begin
begin tran
update RegDefault
set rdDeleted=1
WHERE Idrd=@Idrd
IF @@error <> 0
                                           begin
                                                raiserror ('Errore "Update"  RegDefault  (DeleteRegDefault) ', 16, 1) 
                                                rollback tran
                                                return 99
                                           END
commit tran
end
GO
