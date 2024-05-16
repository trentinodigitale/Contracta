USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DeleteUserDeleg]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
	Autore: Alfano Antonio
	Scopo: Cancellazione utente delegato
	Data:    25/02/2002
*/
CREATE PROCEDURE  [dbo].[DeleteUserDeleg](@IdUser int,@IdAz int) AS
begin
set nocount on
begin tran
declare @IdBsk int
declare @IdOrd int
declare @cRow int
--Cancellazioni logica DLG_ATTRIBUTI
update DLG_ATTRIBUTI
set deleted=1
where IdAz=@IdAz and IdUser=@IdUser and deleted=0
if @@error <> 0		begin
                  	raiserror ('Errore "Update"  DLG_ATTRIBUTI (DeleteUserDeleg)', 16, 1) 
                  	rollback tran
                  	return 99
             		end
--Cancellazioni logica DLG_USERDELEGHE
update DLG_USERDELEGHE
set deleted=1
where IdAz=@IdAz and IdUser=@IdUser and deleted=0
if @@error <> 0		begin
                  	raiserror ('Errore "Update"  DLG_USERDELEGHE (DeleteUserDeleg)', 16, 1) 
                  	rollback tran
                  	return 99
             		end
--Cancellazioni logica DLG_USERSTRUTTURA
update DLG_USERSTRUTTURA
set deleted=1
where IdAz=@IdAz and IdUser=@IdUser and deleted=0
if @@error <> 0		begin
                  	raiserror ('Errore "Update"  DLG_USERSTRUTTURA (DeleteUserDeleg)', 16, 1) 
                  	rollback tran
                  	return 99
             		end
--Cat_BasketBeni caso:(substring(Cat_BasketBeni.statoItem,15,1)='1' or substring(Cat_BasketBeni.statoItem,18,1)='1') --- modify=0 (false)
update Cat_BasketBeni
set ModifyItem=0
where Cat_BasketBeni.IdAz=@IdAz and Cat_BasketBeni.IdUser=@IdUser 
and Cat_BasketBeni.IdBsk in (SELECT CAT_ORDINI.IdBsk FROM CAT_ORDINI
WHERE  CAT_ORDINI.IdUser=@idUser AND CAT_ORDINI.IdAz=@idAz AND CAT_ORDINI.Stato<>9 and CAT_ORDINI.deleted=0) 
and (substring(Cat_BasketBeni.statoItem,15,1)='1' or substring(Cat_BasketBeni.statoItem,18,1)='1') and Cat_BasketBeni.deleted=0 
if @@error <> 0		begin
                  	raiserror ('Errore "Update"  Cat_BasketBeni (DeleteUserDeleg)', 16, 1) 
                  	rollback tran
                  	return 99
             		end
--Cat_BasketBeni caso: not(substring(Cat_BasketBeni.statoItem,15,1)='1' or substring(Cat_BasketBeni.statoItem,18,1)='1')
update Cat_BasketBeni
set	Category=2,
	statoItem=substring(statoItem,1,13)+'0'+substring(statoItem,15,2)+'0'+substring(statoItem,18,5)+'1'+substring(statoItem,24,30)
where Cat_BasketBeni.IdAz=@IdAz and Cat_BasketBeni.IdUser=@IdUser 
and Cat_BasketBeni.IdBsk in (SELECT CAT_ORDINI.IdBsk FROM CAT_ORDINI
WHERE  CAT_ORDINI.IdUser=@idUser AND CAT_ORDINI.IdAz=@idAz AND CAT_ORDINI.Stato<>9 and CAT_ORDINI.deleted=0) 
and NOT (substring(Cat_BasketBeni.statoItem,15,1)='1' or substring(Cat_BasketBeni.statoItem,18,1)='1') and Cat_BasketBeni.deleted=0 
if @@error <> 0		begin
                  	raiserror ('Errore "Update"  Cat_BasketBeni (DeleteUserDeleg)', 16, 1) 
                  	rollback tran
                  	return 99
             		end
set @IdBsk=Null
SELECT @cRow=count(*) FROM Cat_Basket 
WHERE  IdUser=@idUser AND IdAz=@idAz AND Stato=0 and deleted=0
If @cRow=0	 		begin
				commit tran
				set nocount off
                  		return 0
				end 
If @cRow>1	 		begin
                  		raiserror ('Errore "Select": valore IdBsk non unico Cat_Basket (DeleteUserDeleg)', 16, 1) 
                  		rollback tran
                  		return 99
				end
--caso basket non inviato... al max un solo record presente
SELECT @IdBsk=IdBsk FROM Cat_Basket 
WHERE  IdUser=@idUser AND IdAz=@idAz AND Stato=0 and deleted=0
--selezione ordine
SELECT @IdOrd=max(IdOrd) FROM Cat_Ordini 
WHERE  IdUser=@idUser AND IdAz=@idAz AND Stato=0 and deleted=0
--inserimento CAT_ORDINI
insert into CAT_ORDINI(IdAz,IdUser,IdBsk,IdOrd,Stato,DataAttivazione) values(@IdAz,@IdUser,@IdBsk,@IdOrd+1,1,getdate())
if @@error <> 0		begin
                  	raiserror ('Errore "insert"  CAT_ORDINI (DeleteUserDeleg)', 16, 1) 
                  	rollback tran
                  	return 99
             		end
--Cat_BasketBeni
update Cat_BasketBeni
set	Category=2,
	statoItem=substring(statoItem,1,13)+'0'+substring(statoItem,15,2)+'0'+substring(statoItem,18,5)+'1'+substring(statoItem,24,30)
where IdAz=@IdAz and IdUser=@IdUser and IdBsk=@IdBsk and deleted=0
if @@error <> 0		begin
                  	raiserror ('Errore "Update"  Cat_BasketBeni (DeleteUserDeleg)', 16, 1) 
                  	rollback tran
                  	return 99
             		end
commit tran
set nocount off
end
GO
