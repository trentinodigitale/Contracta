USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[InsertAziendeProspect]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[InsertAziendeProspect] 
(
  @IdMp             AS INTeger,
  @RagioneSociale   AS NVARCHAR(80),
  @IndirizzoLeg     AS NVARCHAR (80),
  @LocalitaLeg      AS NVARCHAR (80),
  @ProvinciaLeg     AS NVARCHAR (20),
  @StatoLeg         AS NVARCHAR (80),
  @CapLeg           AS NVARCHAR (8),
  @IdFormaSoc       AS INTeger,
  @Telefono         AS NVARCHAR (20),   
  @Fax              AS NVARCHAR (20),
  @EMail            AS NVARCHAR (50),  /* Da cambiare quando cambiamo la lunghezza del campo in tabella aziende !!!!*/
  @SitoWeb          AS NVARCHAR(300),
  @Gph1             AS INTeger,
  @Gph2             AS INTeger,
  @Gph3             AS INTeger,
  @Gph4             AS INTeger,
  @Gph5             AS INTeger,
  @Atv1             AS VARCHAR (20),
  @Atv2             AS VARCHAR (20),
  @Atv3             AS VARCHAR (20),
  @Atv4             AS VARCHAR (20),
  @Atv5             AS VARCHAR (20),
  @AziLog           AS char(7) OUTPUT
) 
AS
DECLARE @IdMetaMp             AS INTeger
DECLARE @bMpVE                AS tinyint
DECLARE @bMpVI                AS tinyint
DECLARE @IdAzi                AS INTeger
DECLARE @IdDscFormaSoc        AS INTeger
DECLARE @nLen                 AS INTeger
DECLARE @Count                AS INTeger
DECLARE @RagioneSocialeNorm   AS NVARCHAR(80)
DECLARE @strClean             AS NVARCHAR(80)
IF @IdMp = 0 or @IdMp IS NULL
begin
       raiserror ('Campo @IdMp non valorizzato (InsertAziendeProspect)', 16, 1) 
       return (99)
end
IF @RagioneSociale = '' or @RagioneSociale IS NULL
begin
       raiserror ('Campo @RagioneSociale non valorizzato (InsertAziendeProspect)', 16, 1) 
       return (99)
end
IF @IndirizzoLeg = '' or @IndirizzoLeg IS NULL
begin
       raiserror ('Campo @IndirizzoLeg non valorizzato (InsertAziendeProspect)', 16, 1) 
       return (99)
end
      
IF @LocalitaLeg = '' or @LocalitaLeg IS NULL
begin
       raiserror ('Campo @LocalitaLeg non valorizzato (InsertAziendeProspect)', 16, 1) 
       return (99)
end
IF @ProvinciaLeg = '' or @ProvinciaLeg IS NULL
begin
       raiserror ('Campo @ProvinciaLeg non valorizzato (InsertAziendeProspect)', 16, 1) 
       return (99)
end
IF @StatoLeg = '' or @StatoLeg IS NULL
begin
       raiserror ('Campo @StatoLeg non valorizzato (InsertAziendeProspect)', 16, 1) 
       return (99)
end
IF @IdFormaSoc = 0 or @IdFormaSoc IS NULL
begin
       raiserror ('Campo @IdFormaSoc non valorizzato (InsertAziendeProspect)', 16, 1) 
       return (99)
end
IF @Gph1 IS NULL
begin
       raiserror ('Campo @Gph1 non valorizzato (InsertAziendeProspect)', 16, 1) 
       return (99)
end
IF @Atv1 IS NULL
begin
       raiserror ('Campo @Atv1 non valorizzato (InsertAziendeProspect)', 16, 1) 
       return (99)
end
/*
   Recupero l'IdDsc della forma giuridica a partire dall'idtdr passato in input
*/
set @IdDscFormaSoc = NULL
SELECT @IdDscFormaSoc = tdrIdDsc FROM TipiDatiRange WHERE idtdr = @IdFormaSoc
IF @IdDscFormaSoc IS NULL
begin
       raiserror ('IdTdr [%d] non trovato in tabella TipiDatiRange (InsertAziendeProspect)', 16, 1, @IdFormaSoc) 
       return (99)
end
/*
   Normalizzazione Ragione Sociale 
*/   
set @strClean = Upper(@RagioneSociale)
set @strClean = Replace(@strClean, ' ', '')
set @strClean = Replace(@strClean, '.', '')
set @strClean = Replace(@strClean, '''', '')
set @strClean = Replace(@strClean, ':', '')
set @strClean = Replace(@strClean, ';', '')
set @strClean = Replace(@strClean, '-', '')
set @strClean = Replace(@strClean, '!', '')
set @strClean = Replace(@strClean, '?', '')
set @strClean = Replace(@strClean, '"', '')
set @strClean = Replace(@strClean, ',', '')
set @strClean = Replace(@strClean, '*', '')
set @nLen = len (@strClean)
IF  @nLen > 4
    begin
          IF  right (@strClean, 3) = 'SPA' or right (@strClean, 3) = 'SNC' or right (@strClean, 3) = 'SRL'
              begin
                    set @strClean = left(@strClean, @nLen - 3)                       
              end
     end
set @RagioneSocialeNorm = @strClean
/*
   Controllo se l'azienda _ giO presente. Se giO presente restituisco '-1' nell'azilog senza segnalare errore
*/
set @Count = 0
SELECT @Count = count (*) FROM aziende WHERE aziragionesocialenorm = @RagioneSocialeNorm AND aziLocalitaLeg = @LocalitaLeg
IF @Count <> 0
   begin
        set @Azilog = '-1'
        return (0)
   end
begin tran InsertAz
  insert INTo Aziende (aziRagioneSociale, aziRagioneSocialeNorm, aziIdDscFormaSoc, aziE_Mail, aziProspect, aziIndirizzoLeg,
                       aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziProssimoProtRdo,
                       aziProssimoProtOff, aziGphValueOper, aziAtvAtecord, aziSitoWeb)
    values (@RagioneSociale, @RagioneSocialeNorm, @IdDscFormaSoc, @EMail, 1, @IndirizzoLeg,
            @LocalitaLeg, @ProvinciaLeg, @StatoLeg, @CapLeg, @Telefono, @Fax, 1, 1, @Gph1, @Atv1, @SitoWeb)
  IF @@error <> 0
     begin
           raiserror ('Errore "Insert" tabella Aziende (InsertAziendeProspect)', 16, 1) 
           rollback tran InsertAz 
           return (99)
     end
  set @IdAzi = @@identity
/*
     Inserimento AziGph
*/
  insert INTo AziGph (gphIdAzi, gphValue)
    values (@IdAzi, @gph1)
  IF @@error <> 0
     begin
           raiserror ('Errore "Insert" tabella AziGph (1)(InsertAziendeProspect)', 16, 1) 
           rollback tran InsertAz 
           return (99)
     end
  IF @Gph2  <> -1
     begin
           insert INTo AziGph (gphIdAzi, gphValue)
              values (@IdAzi, @Gph2)
           IF @@error <> 0
              begin
                    raiserror ('Errore "Insert" tabella AziGph (2)(InsertAziendeProspect)', 16, 1) 
                    rollback tran InsertAz 
                    return (99)
              end
     end
  IF @Gph3 <> -1
     begin
           insert INTo AziGph (gphIdAzi, gphValue)
              values (@IdAzi, @Gph3)
           IF @@error <> 0
              begin
                    raiserror ('Errore "Insert" tabella AziGph (3)(InsertAziendeProspect)', 16, 1) 
                    rollback tran InsertAz 
                    return (99)
              end
     end
  IF @Gph4 <> -1
     begin
           insert INTo AziGph (gphIdAzi, gphValue)
              values (@IdAzi, @Gph4)
           IF @@error <> 0
              begin
                    raiserror ('Errore "Insert" tabella AziGph (4)(InsertAziendeProspect)', 16, 1) 
                    rollback tran InsertAz 
                    return (99)
              end
     end
  IF @Gph5 <> -1
     begin
           insert INTo AziGph (gphIdAzi, gphValue)
              values (@IdAzi, @Gph5)
           IF @@error <> 0
              begin
                    raiserror ('Errore "Insert" tabella AziGph (5)(InsertAziendeProspect)', 16, 1) 
                    rollback tran InsertAz 
                    return (99)
              end
     end
/*
     Inserimento AziAteco
*/
  insert INTo AziAteco (IdAzi, AtvAtecord)
    values (@IdAzi, @Atv1)
  IF @@error <> 0
     begin
           raiserror ('Errore "Insert" tabella AziAteco (1)(InsertAziendeProspect)', 16, 1) 
           rollback tran InsertAz 
           return (99)
     end
  IF @Atv2 <> '-1'
     begin
           insert INTo AziAteco (IdAzi, AtvAtecord)
             values (@IdAzi, @Atv2)
           IF @@error <> 0
              begin
                    raiserror ('Errore "Insert" tabella AziAteco (2)(InsertAziendeProspect)', 16, 1) 
                    rollback tran InsertAz 
                    return (99)
              end
     end
  IF @Atv3 <> '-1'
     begin
           insert INTo AziAteco (IdAzi, AtvAtecord)
             values (@IdAzi, @Atv3)
           IF @@error <> 0
              begin
                    raiserror ('Errore "Insert" tabella AziAteco (3)(InsertAziendeProspect)', 16, 1) 
                    rollback tran InsertAz 
                    return (99)
              end
     end
  IF @Atv4 <> '-1'
     begin
           insert INTo AziAteco (IdAzi, AtvAtecord)
             values (@IdAzi, @Atv4)
           IF @@error <> 0
              begin
                    raiserror ('Errore "Insert" tabella AziAteco (4)(InsertAziendeProspect)', 16, 1) 
                    rollback tran InsertAz 
                    return (99)
              end
     end
        
  IF @Atv5 <> '-1'
     begin
           insert INTo AziAteco (IdAzi, AtvAtecord)
             values (@IdAzi, @Atv5)
           IF @@error <> 0
              begin
                    raiserror ('Errore "Insert" tabella AziAteco (5)(InsertAziendeProspect)', 16, 1) 
                    rollback tran InsertAz 
                    return (99)
              end
     end
/*
     Inserimento MPAziende
*/
set @IdMetaMP = NULL
SELECT @IdMetaMp = IdMp FROM MarketPlace WHERE substring(mpOpzioni, 1, 1) = '1'
IF @IdMetaMp IS NULL
     begin
           raiserror ('MetaMarketplace non trovato in tabella MarketPlace (InsertAziendeProspect)', 16, 1) 
           rollback tran InsertAz 
           return (99)
     end
set @bMpVE = NULL
SELECT @bMpVe = mpVisibilitaEsterna, @bMpVi = mpVisibilitaInterna FROM MarketPlace WHERE IdMp = @IdMp
IF @bMpVe IS NULL
     begin
           raiserror ('Marketplace non trovato in tabella MarketPlace (InsertAziendeProspect)', 16, 1) 
           rollback tran InsertAz 
           return (99)
     end
insert INTo MPAziende (mpaIdMp, mpaIdAzi, mpaProspect)
    values (@IdMp,  @IdAzi, 1)
  IF @@error <> 0
     begin
           raiserror ('Errore "Insert" tabella MPAziende (InsertAziendeProspect)', 16, 1) 
           rollback tran InsertAz 
           return (99)
     end
IF @IdMp <> @IdMetaMp AND @bMpVE = 1 AND  @bMpVI = 1
   begin
         insert INTo MPAziende (mpaIdMp, mpaIdAzi, mpaProspect)
               values (@IdMetaMp,  @IdAzi, 1)
         IF @@error <> 0
            begin
                 raiserror ('Errore "Insert" tabella MPAziende (InsertAziendeProspect)', 16, 1) 
                 rollback tran InsertAz 
                 return (99)
            end
end
insert INTo ProfiliUtente_Prospect (pfuIdAzi, pfuLogin, pfuPassword, pfuIdLng)
     values (@IdAzi, upper(left(@RagioneSocialeNorm, 8)), left(@RagioneSocialeNorm, 8), 1)
  IF @@error <> 0
     begin
           raiserror ('Errore "Insert" tabella ProfiliUtente_Prospect (InsertAziendeProspect)', 16, 1) 
           rollback tran InsertAz
           return (99)
     end
SELECT @AziLog = aziLog FROM aziende WHERE IdAzi = @IdAzi
commit tran InsertAz
GO
