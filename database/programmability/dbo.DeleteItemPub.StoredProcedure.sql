USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DeleteItemPub]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
	Autore: Alfano Antonio
	Scopo: Cancellazione logica bene pubblicato
	Data:    25/03/2002
*/
CREATE PROCEDURE  [dbo].[DeleteItemPub](@IdAz int,@IdOAP int, @IdBene int) AS
begin
begin tran
--Cat_BasketBeni
update Cat_BasketBeni
set deleted=1
where IdAz=@IdAz and IdOAP=@IdOAP and IdBene=@IdBene and (substring(statoItem,12,1)<>'1' or substring(statoItem,20,1)<>'1') and deleted=0 
if @@error <> 0		begin
                  	raiserror ('Errore "Update"  Cat_BasketBeni (DeleteItemPub)', 16, 1) 
                  	rollback tran
                  	return 99
             		end
--CAT_BENI
update CAT_BENI
set deleted=1
where IdAz=@IdAz and IdOAP=@IdOAP and IdBene=@IdBene and deleted=0
if @@error <> 0		begin
                  	raiserror ('Errore "Update"    CAT_BENI (DeleteItemPub)', 16, 1) 
                  	rollback tran
                  	return 99
             		end
--CAT_BENEATTRIBUTI
update CAT_BENEATTRIBUTI
set deleted=1
where IdAz=@IdAz and IdOAP=@IdOAP and IdBene=@IdBene and deleted=0
if @@error <> 0		begin
                  	raiserror ('Errore "Update"  CAT_BENEATTRIBUTI (DeleteItemPub)', 16, 1) 
                  	rollback tran
                  	return 99
             		end
--CAT_BENEIMMAGINI
update CAT_BENEIMMAGINI
set deleted=1
where IdAz=@IdAz and IdOAP=@IdOAP and IdBene=@IdBene and deleted=0
if @@error <> 0		begin
                  	raiserror ('Errore "Update"  CAT_BENEIMMAGINI (DeleteItemPub)', 16, 1) 
                  	rollback tran
                  	return 99
             		end
--CAT_BENISTRUTTURA
update CAT_BENISTRUTTURA
set deleted=1
where IdAz=@IdAz and IdOAP=@IdOAP and IdBene=@IdBene and deleted=0
if @@error <> 0		begin
                  	raiserror ('Errore "Update"  CAT_BENISTRUTTURA (DeleteItemPub)', 16, 1) 
                  	rollback tran
                  	return 99
             		end
commit tran
end
GO
