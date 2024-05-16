USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DeleteAzienda]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OLD_DeleteAzienda] (@IdAzi INTeger) AS
set transaction isolation level serializable
/*
data: 20021014
Sono state apportate le modifiche per la cancellazione degli IdVat presenti nella 
Dm_Attributi
*/
begin tran
--not in (SELECT mpIdAziMaster FROM Marketplace)
IF exists(SELECT * FROM marketplace WHERE mpIdAziMaster=@IdAzi)
begin
        raiserror ('Errore si tenta di cancellare un''azienda master', 16, 1)
        rollback tran
        return 99
end
/* AziGph */
delete FROM azigph 
      WHERE gphidazi = @IdAzi
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" AziGph', 16, 1)
        rollback tran
        return 99
   end
   
/* AziAteco */ 
delete FROM aziateco                     
      WHERE idazi    = @IdAzi
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" AziAteco', 16, 1)
        rollback tran
        return 99
   end
/* Aziende_Informazioni */
delete FROM aziende_informazioni         
      WHERE idazi    = @IdAzi
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" Aziende_Informazioni', 16, 1)
        rollback tran
        return 99
   end
/* Aziende_Convenzioni */
delete FROM aziende_convenzioni          
      WHERE idazi    = @IdAzi
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" Aziende_Convenzioni', 16, 1)
        rollback tran
        return 99
   end
/* DfBPfuCsp */ 
delete FROM DfBPfuCsp                    
      WHERE idpfu  in (SELECT idpfu FROM profiliutente WHERE pfuidazi = @IdAzi)
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" DfBPfuCsp', 16, 1)
        rollback tran
        return 99
   end
/* DfSPfuCsp */ 
delete FROM DfSPfuCsp                    
      WHERE idpfu  in (SELECT idpfu FROM profiliutente WHERE pfuidazi = @IdAzi)
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" DfSPfuCsp', 16, 1)
        rollback tran
        return 99
   end
/* DfBPfuGph */ 
delete FROM DfBPfuGph
      WHERE idpfu  in (SELECT idpfu FROM profiliutente WHERE pfuidazi = @IdAzi)
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" DfBPfuGph', 16, 1)
        rollback tran
        return 99
   end
/* DfSPfuGph */ 
delete FROM DfSPfuGph
      WHERE idpfu  in (SELECT idpfu FROM profiliutente WHERE pfuidazi = @IdAzi)
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" DfSPfuGph', 16, 1)
        rollback tran
        return 99
   end
/* TAB_UTENTI_MESSAGGI */ 
delete FROM tab_utenti_messaggi
      WHERE umidpfu  in (SELECT idpfu FROM profiliutente WHERE pfuidazi = @IdAzi)
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" TAB_UTENTI_MESSAGGI', 16, 1)
        rollback tran
        return 99
   end

/* TAB_UTENTI_MESSAGGI */ 

delete FROM msgpermissions
      WHERE mpidpfu  in (SELECT idpfu FROM profiliutente WHERE pfuidazi = @IdAzi)
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" mgpermission', 16, 1)
        rollback tran
        return 99
   end

delete FROM messaggiutenti
      WHERE muIdPfuMitt  in (SELECT idpfu FROM profiliutente WHERE pfuidazi = @IdAzi)
         or muIdPfuDest  in (SELECT idpfu FROM profiliutente WHERE pfuidazi = @IdAzi)
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" mgpermission', 16, 1)
        rollback tran
        return 99
   end


/* TAB_BLACK_LIST */ 
delete FROM tab_black_list
      WHERE blidazi    = @IdAzi
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" TAB_BLACK_LIST', 16, 1)
        rollback tran
        return 99
   end
/* TabPrefissoProtocollo  */
delete FROM tabprefissoprotocollo
      WHERE idazi    = @IdAzi
IF @@error <> 0
   begin
       raiserror ('Errore "Delete" TabPrefissoProtocollo', 16, 1)
       rollback tran
       return 99
   end
/* ModPesiInd */
delete FROM modpesiind
      WHERE mpiidpfu   in (SELECT idpfu FROM profiliutente WHERE pfuidazi = @IdAzi)
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" ModPesiInd', 16, 1)
        rollback tran
         return 99
   end
/* ModPesiRatingForn */
delete FROM ModPesiRatingForn
      WHERE mprfIdPfu  in (SELECT idpfu FROM profiliutente WHERE pfuidazi = @IdAzi)
IF @@error <> 0
   begin
          raiserror ('Errore "Delete" ModPesiRatingForn', 16, 1)
          rollback tran
          return 99
   end
/* Logging */
delete FROM Logging
      WHERE lggIdPfu   in (SELECT idpfu FROM profiliutente WHERE pfuidazi = @IdAzi)
IF @@error <> 0 
   begin
        raiserror ('Errore "Delete" Logging', 16, 1)
        rollback tran
        return 99
   end
/* RdoElaborate */
delete FROM rdoelaborate
      WHERE idpfu      in (SELECT idpfu FROM profiliutente WHERE pfuidazi = @IdAzi)
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" RdoElaborate', 16, 1)
        rollback tran
        return 99
   end
/* ProfiliUtente */
delete FROM profiliutente
      WHERE pfuidazi = @IdAzi
IF @@error <> 0
   begin
         raiserror ('Errore "Delete" ProfiliUtente', 16, 1)
         rollback tran
         return 99
   end
/* ProfiliUtente_Prospect */
delete FROM profiliutente_prospect
      WHERE pfuidazi = @IdAzi
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" ProfiliUtente_Prospect', 16, 1)
        rollback tran
        return 99
   end
/* ValoriAttributi_Int */
delete FROM valoriattributi_int
      WHERE idvat    in (SELECT idvat FROM dfvatazi WHERE idazi = @IdAzi)
IF @@error <> 0
   begin
         raiserror ('Errore "Delete" ValoriAttributi_Int', 16, 1)
         rollback tran
         return 99
   end
/* ValoriAttributi_Money */
delete FROM valoriattributi_money
      WHERE idvat    in (SELECT idvat FROM dfvatazi WHERE idazi = @IdAzi)
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" ValoriAttributi_Money', 16, 1)
        rollback tran
        return 99
   end
/* ValoriAttributi_Descrizioni */
delete FROM valoriattributi_descrizioni
      WHERE idvat    in (SELECT idvat FROM dfvatazi WHERE idazi = @IdAzi)
IF @@error <> 0
   begin
         raiserror ('Errore "Delete" ValoriAttributi_Descrizioni', 16, 1)
         rollback tran
         return 99
   end
/* ValoriAttributi_NVarchar */ 
delete FROM valoriattributi_nvarchar     
      WHERE idvat    in (SELECT idvat FROM dfvatazi WHERE idazi = @IdAzi)
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" ValoriAttributi_NVarchar', 16, 1)
        rollback tran
        return 99
   end
/* ValoriAttribut_DATETIME */
delete FROM ValoriAttributi_Datetime
      WHERE idvat    in (SELECT idvat FROM dfvatazi WHERE idazi = @IdAzi)
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" ValoriAttributi_Datetime', 16, 1)
        rollback tran
        return 99
   end
/* ValoriAttributi_Keys */
delete FROM valoriattributi_keys
      WHERE idvat    in (SELECT idvat FROM dfvatazi WHERE idazi = @IdAzi)
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" ValoriAttributi_Keys', 16, 1)
        rollback tran
        return 99
   end
/* ValoriAttributi_Float */
delete FROM valoriattributi_float
      WHERE idvat    in (SELECT idvat FROM dfvatazi WHERE idazi = @IdAzi)
IF @@error <> 0
   begin
         raiserror ('Errore "Delete" ValoriAttributi_Float', 16, 1)
         rollback tran
         return 99
   end
/* ValoriAttributi_Image */
delete FROM valoriattributi_image
      WHERE idvat    in (SELECT idvat FROM dfvatazi WHERE idazi = @IdAzi)
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" ValoriAttribut_Image', 16, 1)
        rollback tran
        return 99
   end
/* DFVatAzi */
SELECT idvat 
  INTo dbo.TempDelete 
  FROM valoriattributi 
 WHERE idvat in (SELECT idvat FROM dfvatazi WHERE idazi = @IdAzi)
IF @@error <> 0
   begin
        raiserror ('Errore "SELECT INTo" TempDelete', 16, 1)
        rollback tran
        return 99
   end
delete FROM dfvatazi
      WHERE idazi     = @IdAzi
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" DFVatAzi', 16, 1)
        rollback tran
        return 99
   end
/* ValoriAttributi */
delete FROM valoriattributi
      WHERE idvat    in (SELECT idvat FROM dbo.TempDelete)
IF @@error <> 0
   begin
         raiserror ('Errore "Delete" ValoriAttributi', 16, 1)
         rollback tran
         return 99
   end
/*  DM_attributi   */
DELETE FROM DM_attributi
WHERE idvat    in (SELECT idvat FROM dbo.TempDelete)
IF @@ERROR <> 0
   BEGIN
        RAISERROR ('Errore "Delete" DM_attributi', 16, 1)
        ROLLBACK TRAN
        RETURN 99
   END
drop table dbo.TempDelete
/* ValoriIndicatori */
delete FROM valoriindicatori
      WHERE vindIdAzi = @IdAzi
IF @@error <> 0
   begin
         raiserror ('Errore "Delete" ValoriIndicatori', 16, 1)
         rollback tran
         return 99
   end
/* TAB_RICERCHE */
delete FROM tab_ricerche
      WHERE idazi = @IdAzi
IF @@error <>  0
   begin
         raiserror ('Errore "Delete" TAB_RICERCHE', 16, 1)
         rollback tran
         return 99
   end
/* TabContatoriOrdini */
delete FROM tabcontatoriordini
      WHERE idazi = @IdAzi
IF @@error <> 0
   begin
         raiserror ('Errore "Delete" TabContatotiOrdini', 16, 1)
         rollback tran
         return 99
   end
/* Modelli_Attributi */
delete FROM modelli_prodotti             
      WHERE MdlIdArt in (SELECT idart FROM articoli WHERE artidazi  = @IdAzi)
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" Modelli_Attributi', 16, 1)
        rollback tran
        return 99
   end
/* ValoriAttributi_Int */
delete FROM valoriattributi_int
      WHERE idvat in (SELECT idvat FROM dfvatart WHERE idart in (SELECT idart FROM articoli WHERE artidazi  = @IdAzi))
IF @@error <> 0
   begin
          raiserror ('Errore "Delete" ValoriAttributi_Int', 16, 1)
          rollback tran
          return 99
   end
/* ValoriAttributi_Money */
delete FROM valoriattributi_money
      WHERE idvat in (SELECT idvat FROM dfvatart WHERE idart in (SELECT idart FROM articoli WHERE artidazi  = @IdAzi))
IF @@error <> 0
   begin
         raiserror ('Errore "Delete" ValoriAttributi_Money', 16, 1)
         rollback tran
         return 99
   end
/* ValoriAttributi_Descrizioni */
delete FROM valoriattributi_descrizioni
      WHERE idvat in (SELECT idvat FROM dfvatart WHERE idart in (SELECT idart FROM articoli WHERE artidazi  = @IdAzi))
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" ValoriAttributi_Descrizioni', 16, 1)
        rollback tran
        return 99
   end
/* ValoriAttributi_NVArchar */
delete FROM valoriattributi_nvarchar
      WHERE idvat in (SELECT idvat FROM dfvatart WHERE idart in (SELECT idart FROM articoli WHERE artidazi  = @IdAzi))delete FROM ValoriAttributi_Datetime     WHERE idvat in (SELECT idvat FROM dfvatart WHERE idart in (SELECT idart FROM articoli WHERE artidazi  = @IdAzi))
IF @@error <> 0
   begin
         raiserror ('Errore "Delete" ValoriAttributi_NVarchar', 16, 1)
         rollback tran
         return 99
   end
/* ValoriAttributi_Keys */
delete FROM valoriattributi_keys
      WHERE idvat in (SELECT idvat FROM dfvatart WHERE idart in (SELECT idart FROM articoli WHERE artidazi  = @IdAzi))
IF @@error <> 0
   begin
         raiserror ('Errore "Delete" ValoriAttributi_Keys', 16, 1)
         rollback tran
         return 99
   end
/* ValoriAttributi_Float */
delete FROM valoriattributi_float
      WHERE idvat in (SELECT idvat FROM dfvatart WHERE idart in (SELECT idart FROM articoli WHERE artidazi  = @IdAzi))
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" ValoriAttributi_Float', 16, 1)
        rollback tran
        return 99
   end
/* ValoriAttributi_Image */
delete FROM valoriattributi_image
      WHERE idvat in (SELECT idvat FROM dfvatart WHERE idart in (SELECT idart FROM articoli WHERE artidazi  = @IdAzi))
IF @@error <> 0
   begin
         raiserror ('Errore "Delete" ValoriAttributi_Image', 16, 1)
         rollback tran
         return 99
   end
/* DFVatArt */
SELECT idvat 
  INTo dbo.TempDelete 
  FROM valoriattributi 
 WHERE idvat in (SELECT idvat FROM dfvatart WHERE idart in (SELECT idart FROM articoli WHERE artidazi  = @IdAzi))
IF @@error <> 0
   begin
        raiserror ('Errore "SELECT INTo" TempDelete', 16, 1)
        rollback tran
        return 99
   end
delete FROM dfvatart
      WHERE idart in (SELECT idart FROM articoli WHERE artidazi  = @IdAzi)
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" DFVAtArt', 16, 1)
        rollback tran
        return 99
   end
/* ValoriAttributi */
delete FROM valoriattributi
      WHERE idvat    in (SELECT idvat FROM dbo.TempDelete)
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" ValoriAttributi', 16, 1)
        rollback tran
        return 99
   end
/*  DM_attributi   */
DELETE FROM DM_attributi
WHERE idvat    in (SELECT idvat FROM dbo.TempDelete)
IF @@ERROR <> 0
   BEGIN
        RAISERROR ('Errore "Delete" DM_attributi', 16, 1)
        ROLLBACK TRAN
        RETURN 99
   END
drop table dbo.TempDelete
/* Articoli */
delete FROM articoli
      WHERE artidazi  = @IdAzi
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" Articoli', 16, 1)
        rollback tran
        return 99
   end
/* MPAziende */
delete FROM mpaziende
      WHERE mpaidazi  = @IdAzi
IF @@error <> 0
   begin
         raiserror ('Errore "Delete" MPAziende', 16, 1)
         rollback tran
         return 99
   end
/* MPMailCensimento */
delete FROM mpmailcensimento
      WHERE mpmcidazi = @IdAzi
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" MPMailCensimento', 16, 1)
        rollback tran
        return 99
   end
--Delete CompanyFolders
delete FROM companyfolders 
      WHERE cfIdAzi = @idazi 
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" CompanyFolders', 16, 1)
        rollback tran
        return 99
   end
--Delete CompanyModels
delete FROM CompanyModels
      WHERE cmIdAzi  = @idazi
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" CompanyModels', 16, 1)
        rollback tran
        return 99
   end
--Delete CountersValue
delete FROM CountersValue 
      WHERE cvIdAzi = @idazi 
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" CountersValue', 16, 1)
        rollback tran
        return 99
   end
--Delete CompanyStruct
delete FROM CompanyStruct
      WHERE csIdAzi = @idazi 
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" CompanyStruct', 16, 1)
        rollback tran
        return 99
   end
--Delete ModelliAziende
delete  FROM modelliAziende       
      WHERE mazIdAzi = @idazi 
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" modelliAziende', 16, 1)
        rollback tran
        return 99
   end
/* Aziende */
delete FROM aziende
      WHERE idazi = @IdAzi
IF @@error <> 0
   begin
        raiserror ('Errore "Delete" Aziende', 16, 1)
        rollback tran
        return 99
   end
commit tran



GO
