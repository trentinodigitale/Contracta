USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DeleteContestoMPGerAttr]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autore:  Alfano Antonio
Scopo: Delete  logico di un contesto personalizzato in MpGerarchiaAttributi
Data: 11/10/2001
*/
CREATE PROCEDURE [dbo].[DeleteContestoMPGerAttr] (@mpgaIdMp INT,@mpgaContesto VARCHAR(50)) AS
begin
--E' possibile cancellare solo contesti con IdMp<>0
IF @mpgaIdMp=0            BEGIN
                        raiserror ('Errore: Non F possibile cancellare un contesto di default (DeleteContestoMPGerAttr) ', 16, 1) 
                        rollback tran
                        return 99
                  END
--Esistenza del contesto
IF Not exists(SELECT * FROM MPGerarchiaAttributi WHERE mpgaIdMp=@mpgaIdMp AND mpgaContesto=@mpgaContesto AND mpgaDeleted=0 )            
                  BEGIN
                        raiserror ('Errore: Contesto personalizzato inesistente o gia cancellato (DeleteContestoMPGerAttr) ', 16, 1) 
                        rollback tran
                        return 99
                  END
--Cancellazione logica di un INTero contesto personalizzato
update MPGerarchiaAttributi
set mpgaDeleted=1
WHERE mpgaIdMp=@mpgaIdMp AND mpgaContesto=@mpgaContesto
IF @@error <> 0            BEGIN
                        raiserror ('Errore "update" MPGerarchiaAttributi  (DeleteContestoMPGerAttr) ', 16, 1) 
                        rollback tran
                        return 99
                         END
end
GO
