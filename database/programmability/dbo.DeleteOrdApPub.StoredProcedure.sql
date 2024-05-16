USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DeleteOrdApPub]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
	Autore: Alfano Antonio
	Scopo: Cancellazione ordine aperto
	Data:    21/02/2002
*/
CREATE PROCEDURE  [dbo].[DeleteOrdApPub](@IdAz int,@IdOAP int) AS
begin
set nocount on
begin tran
--Cat_BasketBeni
update Cat_BasketBeni
set deleted=1
where IdAz=@IdAz and IdOAP=@IdOAP and (substring(statoItem,12,1)<>'1' or substring(statoItem,20,1)<>'1') and deleted=0 
if @@error <> 0		begin
                  	raiserror ('Errore "Update"  Cat_BasketBeni (DeleteOrdApPub)', 16, 1) 
                  	rollback tran
                  	return 99
             		end
--Cat_Basket
update Cat_Basket
set deleted=1
where Cat_Basket.IdAz=@IdAz and Cat_Basket.deleted=0 and Cat_Basket.IdBsk in (select b.IdBsk from Cat_BasketBeni b where b.IdAz=@IdAz and b.IdOAP=@IdOAP and (substring(b.statoItem,12,1)<>'1' or substring(b.statoItem,20,1)<>'1') and b.deleted=1) 
if @@error <> 0		begin
                  	raiserror ('Errore "Update"  Cat_Basket (DeleteOrdApPub)', 16, 1) 
                  	rollback tran
                  	return 99
             		end
--Cat_Ordini
update Cat_Ordini
set deleted=1
where Cat_Ordini.deleted=0 and Cat_Ordini.IdBsk in (select b.IdBsk from Cat_Basket b Where b.IdAz=@idAz and b.deleted=1)
if @@error <> 0		begin
                  	raiserror ('Errore "Update"  Cat_Ordini (DeleteOrdApPub)', 16, 1) 
                  	rollback tran
                  	return 99
             		end
--CAT_OAP
update CAT_OAP
set deleted=1
where IdAz=@IdAz and IdOAP=@IdOAP and deleted=0
if @@error <> 0		begin
                  	raiserror ('Errore "Update"  CAT_OAP (DeleteOrdApPub)', 16, 1) 
                  	rollback tran
                  	return 99
             		end
--CAT_OAPATTACH
update CAT_OAPATTACH
set deleted=1
where IdAz=@IdAz and IdOAP=@IdOAP and deleted=0
if @@error <> 0		begin
                  	raiserror ('Errore "Update"  CAT_OAPATTACH (DeleteOrdApPub)', 16, 1) 
                  	rollback tran
                  	return 99
             		end
--CAT_BENI
update   CAT_BENI
set deleted=1
where IdAz=@IdAz and IdOAP=@IdOAP and deleted=0
if @@error <> 0		begin
                  	raiserror ('Errore "Update"    CAT_BENI (DeleteOrdApPub)', 16, 1) 
                  	rollback tran
                  	return 99
             		end
--CAT_BENEATTRIBUTI
update CAT_BENEATTRIBUTI
set deleted=1
where IdAz=@IdAz and IdOAP=@IdOAP and deleted=0
if @@error <> 0		begin
                  	raiserror ('Errore "Update"  CAT_BENEATTRIBUTI (DeleteOrdApPub)', 16, 1) 
                  	rollback tran
                  	return 99
             		end
--CAT_BENEIMMAGINI
update CAT_BENEIMMAGINI
set deleted=1
where IdAz=@IdAz and IdOAP=@IdOAP and deleted=0
if @@error <> 0		begin
                  	raiserror ('Errore "Update"  CAT_BENEIMMAGINI (DeleteOrdApPub)', 16, 1) 
                  	rollback tran
                  	return 99
             		end
--CAT_BENISTRUTTURA
update CAT_BENISTRUTTURA
set deleted=1
where IdAz=@IdAz and IdOAP=@IdOAP and deleted=0
if @@error <> 0		begin
                  	raiserror ('Errore "Update"  CAT_BENISTRUTTURA (DeleteOrdApPub)', 16, 1) 
                  	rollback tran
                  	return 99
             		end
commit tran
end
GO
