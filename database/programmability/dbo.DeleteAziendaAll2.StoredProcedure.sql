USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DeleteAziendaAll2]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteAziendaAll2] AS
set transaction isolation level serializable
set nocount on
begin tran
/*
Data: 20021014
E' stata aggiunta la cancellazione degli Idvat presenti nella dm_attributi
*/
/* AziGph */
delete from azigph 
      where gphidazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" AziGph', 16, 1)
        rollback tran
        return 99
   end
   
/* AziAteco */ 
delete from aziateco                     
      where idazi    not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" AziAteco', 16, 1)
        rollback tran
        return 99
   end
/* Aziende_Informazioni */
delete from aziende_informazioni         
      where idazi    not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" Aziende_Informazioni', 16, 1)
        rollback tran
        return 99
   end
/* Aziende_Convenzioni */
delete from aziende_convenzioni          
      where idazi    not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" Aziende_Convenzioni', 16, 1)
        rollback tran
        return 99
   end
/* DfBPfuCsp */ 
delete from DfBPfuCsp                    
      where idpfu  in (select idpfu from profiliutente where pfuidazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090)))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" DfBPfuCsp', 16, 1)
        rollback tran
        return 99
   end
/* DfSPfuCsp */ 
delete from DfSPfuCsp                    
      where idpfu  in (select idpfu from profiliutente where pfuidazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090)))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" DfSPfuCsp', 16, 1)
        rollback tran
        return 99
   end
/* DfBPfuGph */ 
delete from DfBPfuGph
      where idpfu  in (select idpfu from profiliutente where pfuidazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090)))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" DfBPfuGph', 16, 1)
        rollback tran
        return 99
   end
/* DfSPfuGph */ 
delete from DfSPfuGph
      where idpfu  in (select idpfu from profiliutente where pfuidazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090)))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" DfSPfuGph', 16, 1)
        rollback tran
        return 99
   end
/* TAB_UTENTI_MESSAGGI */ 
delete from tab_utenti_messaggi
      where umidpfu  in (select idpfu from profiliutente where pfuidazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090)))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" TAB_UTENTI_MESSAGGI', 16, 1)
        rollback tran
        return 99
   end
/* TAB_BLACK_LIST */ 
delete from tab_black_list
      where blidazi    not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" TAB_BLACK_LIST', 16, 1)
        rollback tran
        return 99
   end
/* TabPrefissoProtocollo  */
delete from tabprefissoprotocollo
      where idazi    not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))
if @@error <> 0
   begin
       raiserror ('Errore "Delete" TabPrefissoProtocollo', 16, 1)
       rollback tran
       return 99
   end
/* ModPesiInd */
delete from modpesiind
      where mpiidpfu   in (select idpfu from profiliutente where pfuidazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090)))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" ModPesiInd', 16, 1)
        rollback tran
         return 99
   end
/* ModPesiRatingForn */
delete from ModPesiRatingForn
      where mprfIdPfu  in (select idpfu from profiliutente where pfuidazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090)))
if @@error <> 0
   begin
          raiserror ('Errore "Delete" ModPesiRatingForn', 16, 1)
          rollback tran
          return 99
   end
/* Logging */
delete from Logging
      where lggIdPfu   in (select idpfu from profiliutente where pfuidazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090)))
if @@error <> 0 
   begin
        raiserror ('Errore "Delete" Logging', 16, 1)
        rollback tran
        return 99
   end
/* RdoElaborate */
delete from rdoelaborate
      where idpfu      in (select idpfu from profiliutente where pfuidazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090)))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" RdoElaborate', 16, 1)
        rollback tran
        return 99
   end
/* ProfiliUtente */
delete from profiliutente
      where pfuidazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))
if @@error <> 0
   begin
         raiserror ('Errore "Delete" ProfiliUtente', 16, 1)
         rollback tran
         return 99
   end
/* ProfiliUtente_Prospect */
delete from profiliutente_prospect
      where pfuidazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" ProfiliUtente_Prospect', 16, 1)
        rollback tran
        return 99
   end
/* ValoriAttributi_Int */
delete from valoriattributi_int
      where idvat    in (select idvat from dfvatazi where idazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090)))
if @@error <> 0
   begin
         raiserror ('Errore "Delete" ValoriAttributi_Int', 16, 1)
         rollback tran
         return 99
   end
/* ValoriAttributi_Money */
delete from valoriattributi_money
      where idvat    in (select idvat from dfvatazi where idazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090)))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" ValoriAttributi_Money', 16, 1)
        rollback tran
        return 99
   end
/* ValoriAttributi_Descrizioni */
delete from valoriattributi_descrizioni
      where idvat    in (select idvat from dfvatazi where idazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090)))
if @@error <> 0
   begin
         raiserror ('Errore "Delete" ValoriAttributi_Descrizioni', 16, 1)
         rollback tran
         return 99
   end
/* ValoriAttributi_NVarchar */ 
delete from valoriattributi_nvarchar     
      where idvat    in (select idvat from dfvatazi where idazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090)))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" ValoriAttributi_NVarchar', 16, 1)
        rollback tran
        return 99
   end
/* ValoriAttribut_DateTime */
delete from valoriattributi_datetime
      where idvat    in (select idvat from dfvatazi where idazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090)))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" ValoriAttributi_DateTime', 16, 1)
        rollback tran
        return 99
   end
/* ValoriAttributi_Keys */
delete from valoriattributi_keys
      where idvat    in (select idvat from dfvatazi where idazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090)))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" ValoriAttributi_Keys', 16, 1)
        rollback tran
        return 99
   end
/* ValoriAttributi_Float */
delete from valoriattributi_float
      where idvat    in (select idvat from dfvatazi where idazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090)))
if @@error <> 0
   begin
         raiserror ('Errore "Delete" ValoriAttributi_Float', 16, 1)
         rollback tran
         return 99
   end
/* ValoriAttributi_Image */
delete from valoriattributi_image
      where idvat    in (select idvat from dfvatazi where idazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090)))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" ValoriAttribut_Image', 16, 1)
        rollback tran
        return 99
   end
/* DFVatAzi */
select idvat 
  into dbo.TempDelete 
  from valoriattributi 
 where idvat in (select idvat from dfvatazi where idazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090)))
if @@error <> 0
   begin
        raiserror ('Errore "Select into" TempDelete', 16, 1)
        rollback tran
        return 99
   end
delete from dfvatazi
      where idazi     not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" DFVatAzi', 16, 1)
        rollback tran
        return 99
   end
/* ValoriAttributi */
delete from valoriattributi
      where idvat    in (select idvat from dbo.TempDelete)
if @@error <> 0
   begin
         raiserror ('Errore "Delete" ValoriAttributi', 16, 1)
         rollback tran
         return 99
   end
delete from DM_attributi
      where idvat    in (select idvat from dbo.TempDelete)
if @@error <> 0
   begin
         raiserror ('Errore "Delete" DM_attributi', 16, 1)
         rollback tran
         return 99
   end
drop table dbo.TempDelete
/* ValoriIndicatori */
delete from valoriindicatori
      where vindIdAzi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))
if @@error <> 0
   begin
         raiserror ('Errore "Delete" ValoriIndicatori', 16, 1)
         rollback tran
         return 99
   end
/* TAB_RICERCHE */
delete from tab_ricerche
      where idazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))
if @@error <>  0
   begin
         raiserror ('Errore "Delete" TAB_RICERCHE', 16, 1)
         rollback tran
         return 99
   end
/* TabContatoriOrdini */
delete from tabcontatoriordini
      where idazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))
if @@error <> 0
   begin
         raiserror ('Errore "Delete" TabContatotiOrdini', 16, 1)
         rollback tran
         return 99
   end
/* Modelli_Attributi */
delete from modelli_prodotti             
      where MdlIdArt in (select idart from articoli where artidazi  not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090)))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" Modelli_Attributi', 16, 1)
        rollback tran
        return 99
   end
/* ValoriAttributi_Int */
delete from valoriattributi_int
      where idvat in (select idvat from dfvatart where idart in (select idart from articoli where artidazi  not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))))
if @@error <> 0
   begin
          raiserror ('Errore "Delete" ValoriAttributi_Int', 16, 1)
          rollback tran
          return 99
   end
/* ValoriAttributi_Money */
delete from valoriattributi_money
      where idvat in (select idvat from dfvatart where idart in (select idart from articoli where artidazi  not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))))
if @@error <> 0
   begin
         raiserror ('Errore "Delete" ValoriAttributi_Money', 16, 1)
         rollback tran
         return 99
   end
/* ValoriAttributi_Descrizioni */
delete from valoriattributi_descrizioni
      where idvat in (select idvat from dfvatart where idart in (select idart from articoli where artidazi  not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" ValoriAttributi_Descrizioni', 16, 1)
        rollback tran
        return 99
   end
/* ValoriAttributi_NVArchar */
delete from valoriattributi_nvarchar
      where idvat in (select idvat from dfvatart where idart in (select idart from articoli where artidazi  not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))))
if @@error <> 0
   begin
         raiserror ('Errore "Delete" ValoriAttributi_NVarchar', 16, 1)
         rollback tran
         return 99
   end
delete from valoriattributi_datetime     where idvat in (select idvat from dfvatart where idart in (select idart from articoli where artidazi  not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))))
if @@error <> 0
   begin
         raiserror ('Errore "Delete" ValoriAttributi_NVarchar', 16, 1)
         rollback tran
         return 99
   end
/* ValoriAttributi_Keys */
delete from valoriattributi_keys
      where idvat in (select idvat from dfvatart where idart in (select idart from articoli where artidazi  not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))))
if @@error <> 0
   begin
         raiserror ('Errore "Delete" ValoriAttributi_Keys', 16, 1)
         rollback tran
         return 99
   end
/* ValoriAttributi_Float */
delete from valoriattributi_float
      where idvat in (select idvat from dfvatart where idart in (select idart from articoli where artidazi  not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" ValoriAttributi_Float', 16, 1)
        rollback tran
        return 99
   end
/* ValoriAttributi_Image */
delete from valoriattributi_image
      where idvat in (select idvat from dfvatart where idart in (select idart from articoli where artidazi  not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))))
if @@error <> 0
   begin
         raiserror ('Errore "Delete" ValoriAttributi_Image', 16, 1)
         rollback tran
         return 99
   end
/* DFVatArt */
select idvat 
  into dbo.TempDelete 
  from valoriattributi 
 where idvat in (select idvat from dfvatart where idart in (select idart from articoli where artidazi  not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))))
if @@error <> 0
   begin
        raiserror ('Errore "Select into" TempDelete', 16, 1)
        rollback tran
        return 99
   end
delete from dfvatart
      where idart in (select idart from articoli where artidazi  not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090)))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" DFVAtArt', 16, 1)
        rollback tran
        return 99
   end
/* ValoriAttributi */
delete from valoriattributi
      where idvat    in (select idvat from dbo.TempDelete)
if @@error <> 0
   begin
        raiserror ('Errore "Delete" ValoriAttributi', 16, 1)
        rollback tran
        return 99
   end
delete from DM_attributi
      where idvat    in (select idvat from dbo.TempDelete)
if @@error <> 0
   begin
         raiserror ('Errore "Delete" DM_attributi', 16, 1)
         rollback tran
         return 99
   end
drop table dbo.TempDelete
/* Articoli */
delete from articoli
      where artidazi  not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" Articoli', 16, 1)
        rollback tran
        return 99
   end
/* MPAziende */
delete from mpaziende
      where mpaidazi  not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))
if @@error <> 0
   begin
         raiserror ('Errore "Delete" MPAziende', 16, 1)
         rollback tran
         return 99
   end
/* MPMailCensimento */
delete from mpmailcensimento
      where mpmcidazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" MPMailCensimento', 16, 1)
        rollback tran
        return 99
   end
/**aggiunto in data 2002-04-05***************************/
--Delete CompanyFolders
delete from companyfolders 
	where cfIdAzi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090)) 
if @@error <> 0
   begin
        raiserror ('Errore "Delete" CompanyFolders', 16, 1)
        rollback tran
        return 99
   end
--Delete CompanyModels
delete from CompanyModels
	where cmIdAzi  not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" CompanyModels', 16, 1)
        rollback tran
        return 99
   end
--Delete CountersValue
delete from CountersValue 
	where cvIdAzi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" CountersValue', 16, 1)
        rollback tran
        return 99
   end
--Delete CompanyStruct
delete from CompanyStruct
	where csIdAzi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" CompanyStruct', 16, 1)
        rollback tran
        return 99
   end
--Delete ModelliAziende
delete  from modelliAziende 	
	where mazIdAzi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" modelliAziende', 16, 1)
        rollback tran
        return 99
   end
/********************************/
/* Aziende */
delete from aziende
      where idazi not in (select mpIdAziMaster from Marketplace union select idazi from aziende where idAzi in (35152001,35152002,35152003,35152005,35152009,35152086,35152087,35152088,35152089,35152090))
if @@error <> 0
   begin
        raiserror ('Errore "Delete" Aziende', 16, 1)
        rollback tran
        return 99
   end
commit tran
set nocount off
GO
