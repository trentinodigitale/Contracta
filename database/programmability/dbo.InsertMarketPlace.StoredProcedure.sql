USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[InsertMarketPlace]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autore modifiche: Alfano Antonio
Data: 29/11/2001
Scopo modifiche: Flag M in aziProfili e mpProfili
Data: 09/04/2002
Scopo modifiche: Gestione colonne mpcrShadow e mpcrOrder della tabella MpCampiReg
*/
CREATE PROCEDURE [dbo].[InsertMarketPlace] 
(
  @mpRagioneSociale           AS NVARCHAR (80),
  @mpLog                      AS NVARCHAR (12),
  @mpURL                      AS NVARCHAR (300),
  @mpAlias                    AS NVARCHAR (50),
  @mpIdaziMaster              AS INTeger,
  @mpSuffLng                  AS VARCHAR (5),
  @mpCatalogoUnico            AS bit,
  @mpVisibilitaEsterna        AS bit,
  @mpVisibilitaInterna        AS bit,
  @mpOpzioni                  AS char(20),
  @mpTenderggScadenza         AS INT = 0,
  @mpTenderMaxAziende         AS INT = 0
) 
AS
DECLARE @IdMetaMp  AS INTeger
DECLARE @IdLng     AS INTeger
DECLARE @Cnt       AS INTeger
DECLARE @IdMp      AS INTeger
IF @mpRagioneSociale IS NULL or @mpRagioneSociale = ''
begin
       raiserror ('Campo @mpRagioneSociale non valorizzato (InsertMarketPlace)', 16, 1) 
       return (99)
end
IF @mpLog IS NULL or @mpLog = ''
begin
       raiserror ('Campo @mpLog non valorizzato (InsertMarketPlace)', 16, 1) 
       return (99)
end
IF @mpURL IS NULL or @mpURL = ''
begin
       raiserror ('Campo @mpURL non valorizzato (InsertMarketPlace)', 16, 1) 
       return (99)
end
IF @mpAlias IS NULL or @mpAlias = ''
begin
       raiserror ('Campo @mpAlias non valorizzato (InsertMarketPlace)', 16, 1) 
       return (99)
end
IF @mpIdaziMaster IS NULL or @mpIdaziMaster = 0
begin
       raiserror ('Campo @mpIdaziMaster non valorizzato (InsertMarketPlace)', 16, 1) 
       return (99)
end
IF @mpAlias IS NULL or @mpAlias = ''
begin
       raiserror ('Campo @mpAlias non valorizzato (InsertMarketPlace)', 16, 1) 
       return (99)
end
IF @mpSuffLng IS NULL or @mpSuffLng = ''
begin
       raiserror ('Campo @mpSuffLng non valorizzato (InsertMarketPlace)', 16, 1) 
       return (99)
end
IF @mpCatalogoUnico IS NULL
begin
       raiserror ('Campo @mpCatalogoUnico non valorizzato (InsertMarketPlace)', 16, 1) 
       return (99)
end
IF @mpVisibilitaInterna IS NULL
begin
       raiserror ('Campo @mpVisibilitaInterna non valorizzato (InsertMarketPlace)', 16, 1) 
       return (99)
end
IF @mpOpzioni IS NULL or @mpOpzioni = ''
begin
       raiserror ('Campo @mpOpzioni non valorizzato (InsertMarketPlace)', 16, 1) 
       return (99)
end
set @mpOpzioni = ltrim(rtrim(@mpOpzioni)) + substring ('00000000000000000000', 1, 20 - (len(ltrim(rtrim(@mpOpzioni)))))
IF substring(@mpOpzioni, 1, 1) = '1'
   begin
        set @Cnt = 0
        SELECT @Cnt = count (*) FROM MarketPlace
        IF @Cnt <> 0
           begin
                raiserror ('Impossibile inserire il MetaMarketplace [%s] dopo aver definito altri Marketplace', 16, 1, @mpLog) 
                return (99)              
           end
   end
IF substring(@mpOpzioni, 1, 1) = '0'
   begin
        set @Cnt = 0
        SELECT @Cnt = count (*) FROM MarketPlace WHERE substring(mpOpzioni, 1, 1) = '1'
        IF @Cnt = 0
           begin
                raiserror ('Impossibile inserire Marketplace [%s] prima di aver inserito il MetaMarketplace', 16, 1, @mpLog) 
                return (99)              
           end
   end
/*
    Cerco il MetaMP
*/
set @IdMetaMp = NULL
SELECT @IdMetaMp = IdMp FROM MarketPlace WHERE substring(mpOpzioni, 1, 1) = '1'
IF @IdMetaMp IS NULL
begin
       raiserror ('MetaMarketPlace non trovato in tabella MarketPlace (InsertMarketPlace)', 16, 1) 
       return (99)
end
/*
    Controllo che non vi sia ga un altro MarketPlace con lo stesso mpLog
*/
set @Cnt = 0
SELECT @Cnt = count(*) FROM MarketPlace WHERE mpLog = @mpLog
IF @Cnt > 0 
begin
       raiserror ('mpLog [%s] gia presente in tabella MarketPlace (InsertMarketPlace)', 16, 1, @mpLog) 
       return (99)
end
/*
    Cerco l'IdLng
*/
set @IdLng = NULL
SELECT @IdLng = IdLng FROM Lingue WHERE lngSuffisso = @mpSuffLng
IF @IdLng IS NULL
begin
       raiserror ('Suffisso Lingua [%s] non trovato in tabella Lingue (InsertMarketPlace)', 16, 1, @mpSuffLng) 
       return (99)
end
/*
    Controllo la presenza dell'azienda master
*/
set @Cnt = 0
SELECT @Cnt = count(*) FROM Aziende WHERE IdAzi = @mpIdAziMaster
IF @Cnt = 0 
begin
       raiserror ('Azienda Master [%d] non trovata in tabella Aziende (InsertMarketPlace)', 16, 1, @mpIdAziMaster) 
       return (99)
end
begin tran trn001
/*
   Inserimenti in MarketPlace
*/
insert INTo MarketPlace (mpLog, mpRagioneSociale, mpURL, mpAlias, mpIdAziMaster, mpIdLng, mpCatalogoUnico,
                         mpVisibilitaInterna, mpVisibilitaEsterna, mpOpzioni,mpTenderggScadenza, mpTenderMaxAziende)
    values (@mpLog, @mpRagioneSociale, @mpURL, @mpAlias, @mpIdAziMaster, @IdLng, @mpCatalogoUnico,
                         @mpVisibilitaInterna, @mpVisibilitaEsterna, @mpOpzioni, @mpTenderggScadenza, @mpTenderMaxAziende)
IF @@error <> 0
begin
       raiserror ('Errore "Insert" tabella MarketPlace (InsertMarketPlace)', 16, 1) 
       rollback tran trn001
       return (99)
end
set @IdMp = @@identity
--aggiornamento aziProfili con flag M
update aziende
set aziProfili=CASE PATINDEX ('%M%' ,ISNULL( aziProfili, '')) 
         WHEN  0 THEN ISNULL(aziProfili,'')+'M'
         ELSE aziProfili
      END 
WHERE idazi=@mpIdAziMaster
IF @@error <> 0
begin
       raiserror ('Errore "Update" tabella Aziende (InsertMarketPlace)', 16, 1) 
       rollback tran trn001
       return (99)
end
/*
   Inserimento dell'azienda master del MP appena creato in MPAziende
*/
insert INTo MPAziende (mpaIdMp, mpaIdAzi, mpaVenditore, mpaAcquirente, mpaProspect, mpaProfili, mpaDeleted)
SELECT @IdMp, @mpIdAziMaster, aziVenditore, aziAcquirente, aziProspect, aziProfili, aziDeleted
  FROM Aziende
 WHERE IdAzi = @mpIdAziMaster 
IF @@error <> 0
begin
       raiserror ('Errore "Insert" tabella MPAziende (InsertMarketPlace)', 16, 1) 
       rollback tran trn001
       return (99)
end
/*
   Inserimento in MPMail
*/
set @Cnt = 0
SELECT @Cnt = count (*) FROM MPMail WHERE mpmIdMp = @IdMetaMp
IF @Cnt = 0 
begin
       raiserror ('Nessun record trovato in MPMail per il MetaMP [%d] (InsertMarketPlace)', 16, 1, @IdMetaMp) 
       rollback tran trn001
       return (99)
end
insert INTo MPMail (mpmIdMp, mpmEvento, mpmLng, mpmTo, mpmFrom, mpmCC, mpmCCN)
SELECT @IdMp, mpmEvento, mpmLng, mpmTo, mpmFrom, mpmCC, mpmCCN
  FROM MPMail
 WHERE mpmIdMp = @IdMetaMp
IF @@error <> 0
begin
       raiserror ('Errore "Insert" tabella MPMail (InsertMarketPlace)', 16, 1) 
       rollback tran trn001
       return (99)
end
/*
   Inserimento in MPCampiReg
*/
set @Cnt = 0
SELECT @Cnt = count (*) FROM MPCampiReg WHERE mpcrIdMp = @IdMetaMp
IF @Cnt = 0 
begin
       raiserror ('Nessun record trovato in MPCampiReg per il MetaMP [%d] (InsertMarketPlace)', 16, 1, @IdMetaMp) 
       rollback tran trn001
       return (99)
end
insert INTo MPCampiReg (mpcrIdMp, mpcrCampo, mpcrObbl, mpcrLungh, mpcrTipo, mpcrTipoHtml, mpcrPos, mpcrNomeColonna,mpcrShadow,mpcrOrder)
SELECT @IdMp, mpcrCampo, mpcrObbl, mpcrLungh, mpcrTipo, mpcrTipoHtml, mpcrPos, mpcrNomeColonna,mpcrShadow,mpcrOrder
  FROM MPCampiReg
 WHERE mpcrIdMp = @IdMetaMp
IF @@error <> 0
begin
       raiserror ('Errore "Insert" tabella MPCampiReg (InsertMarketPlace)', 16, 1) 
       rollback tran trn001
       return (99)
end
/*
   Inserimento in MPMultilinguismo
*/
set @Cnt = 0
SELECT @Cnt = count (*) FROM MPMultilinguismo WHERE mpmlngIdMp = @IdMetaMp
IF @Cnt = 0 
begin
       raiserror ('Nessun record trovato in MPMultilinguismo per il MetaMP [%d] (InsertMarketPlace)', 16, 1, @IdMetaMp)        rollback tran trn001
       return (99)
end
insert INTo MPMultilinguismo (mpmlngIdMp, mpmlngMPKey, mpmlngMlngKey)
SELECT @IdMp, mpmlngMPKey, mpmlngMlngKey
  FROM MPMultilinguismo
 WHERE mpmlngIdMp = @IdMetaMp
IF @@error <> 0
begin
       raiserror ('Errore "Insert" tabella MPMultilinguismo (InsertMarketPlace)', 16, 1) 
       rollback tran trn001
       return (99)
end
/*
   Inserimento in MPDominiGerarchici
*/
set @Cnt = 0
SELECT @Cnt = count (*) FROM MPDominiGerarchici WHERE mpdgIdMp = @IdMetaMp
IF @Cnt = 0 
begin
       raiserror ('Nessun record trovato in MPDominiGerarchici per il MetaMP [%d] (InsertMarketPlace)', 16, 1, @IdMetaMp) 
       rollback tran trn001
       return (99)
end
insert INTo MPDominiGerarchici (mpdgIdMp, mpdgIdDg, mpdgTipo, mpdgShowPath)
SELECT @IdMp, mpdgIdDg, mpdgTipo, mpdgShowPath
  FROM MPDominiGerarchici
 WHERE mpdgIdMp = @IdMetaMp
IF @@error <> 0
begin
       raiserror ('Errore "Insert" tabella MPDominiGerarchici (InsertMarketPlace)', 16, 1) 
       rollback tran trn001
       return (99)
end
commit tran trn001
GO
