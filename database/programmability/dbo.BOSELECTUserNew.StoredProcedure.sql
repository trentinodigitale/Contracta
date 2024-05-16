USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOSELECTUserNew]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.BOSELECTUserNew    Script Date: 28/06/2000 17.25.46 ******/
/*
    Nome Stored....................: BOSELECTUserNew
    Data Creazione.................: 14/06/2000
    Descrizione....................: Seleziona un utente a cui inviare una RDO, RIG, .......
    @TipoSELECT....................: Se 1 selezione per Settore merceologico / Area Geografica
                                     Se 2 Area Geografica
    @IdPfuMitt.....................: Utente mittente
    @IdPfuDest.....................: Utente Destinatario
    @TipoUserDest..................: Pu_ valere (B)uyer o (S)upplier
    @PosizioneVincoloDest..........: Abilitazione a ricevere una RDO, RIG ....
    @IdAziDest.....................: Azienda destinataria
                                     
*/
CREATE PROCEDURE [dbo].[BOSELECTUserNew] (@TipoSELECT INT, @IdPfuMitt INT, @IdAziDest INT, @TipoUserDest char(1), 
                                  @PosizioneVincoloDest INT, @IdPfuDest INT OUTPUT)
AS
DECLARE @FuoriSede     INT
DECLARE @TmpCspValue   INT
DECLARE @FiltroProfilo char(3)
DECLARE @IdPfuCur      INT
DECLARE @IdPfuFirst    INT
DECLARE @Count         INT
DECLARE @CountAG       INT
DECLARE @LowerRangeSM  INT
DECLARE @LowerRangeAG  INT
DECLARE @GphMitt       INT
DECLARE @bSuccess      bit
DECLARE @NumeroRdo     INT
set @FuoriSede = 30 
/*
    @TipoSELECT = 1 Selezione per Settore merceologico / Area Geografica
*/
set @FiltroProfilo = '%' + @TipoUserDest + '%'
 IF  @TipoSELECT = 2
           Goto SelAreaGeog
DECLARE tmpcrs cursor static for SELECT TmpCspValue FROM TempSM_SELECTUser
open tmpcrs
fetch next FROM tmpcrs INTo @TmpCspValue 
/* Se non ho il settore merceologico seleziono per Area Geografica */
IF @@fetch_status <> 0
       begin  
              close tmpcrs
              deallocate tmpcrs
              Goto SelAreaGeog
       end 
while @@fetch_status = 0    /* 1 */
begin
     set @bSuccess = 0
     exec LowerRange @TmpCspValue, @LowerRangeSM OUTPUT
     set @Count = 0
     IF  @TipoUserDest = 'S'
            begin
                 SELECT @Count = count(a.IdPfu)
                   FROM  ProfiliUtente a, DfsPfuCsp b
                  WHERE a.pfuProfili like @FiltroProfilo 
                    AND a.IdPfu = b.IdPfu
                    AND a.pfuIdAzi = @IdAziDest
                    AND substring(a.pfuFunzionalita, @PosizioneVincoloDest, 1) = '1'
                    AND substring(a.pfuFunzionalita, @FuoriSede, 1) = '0'
                    AND b.cspValue between @LowerRangeSM AND @TmpCspValue 
                    AND a.pfuDeleted = 0
            end
     ELSE
            begin
                 SELECT @Count = count(a.IdPfu)
                   FROM  ProfiliUtente a, DfbPfuCsp b
                  WHERE a.pfuProfili like @FiltroProfilo 
                    AND a.IdPfu = b.IdPfu
                    AND a.pfuIdAzi = @IdAziDest
                    AND substring(a.pfuFunzionalita, @PosizioneVincoloDest, 1) = '1'
                    AND substring(a.pfuFunzionalita, @FuoriSede, 1) = '0'
                    AND b.cspValue between @LowerRangeSM AND @TmpCspValue 
                    AND a.pfuDeleted = 0
            end
     IF @Count = 0
         begin
                fetch next FROM tmpcrs INTo @TmpCspValue   
                continue /* Torna al while 1  */
         end
   
     /* 
        Conteggio dei records che soddisfano la SELECT
        Ordinamento sul "carico" dell' utente
        Consideriamo il primo record in assoluto se nessuno soddisfa il filtro sull'area geografica oppure
        consideriamo il primo record che soddisfa il filtro sull'area geografica
     */
     IF  @TipoUserDest = 'S'
          begin
                  DECLARE PfuCursor cursor static for SELECT a.IdPfu
                                                 FROM  ProfiliUtente a
                                                 inner join DfsPfuCsp b on a.IdPfu = b.IdPfu
                                                 left outer join RdoElaborate c on a.IdPfu = c.IdPfu
                                                WHERE a.pfuProfili like @FiltroProfilo 
                                                  AND a.pfuIdAzi = @IdAziDest
                                                  AND substring(a.pfuFunzionalita, @PosizioneVincoloDest, 1) = '1'
                                                  AND substring(a.pfuFunzionalita, @FuoriSede, 1) = '0'
                                                  AND b.cspValue between @LowerRangeSM AND @TmpCspValue 
                                                  AND a.pfuDeleted = 0
                                                ORDER BY c.NumeroRdo
                                                 
          end
     ELSE
          begin
                  DECLARE PfuCursor cursor static for SELECT a.IdPfu
                                                 FROM  ProfiliUtente a
                                                 inner join DfbPfuCsp b on a.IdPfu = b.IdPfu
                                                 left outer join RdoElaborate c on a.IdPfu = c.IdPfu
                                                WHERE a.pfuProfili like @FiltroProfilo 
                                                  AND a.pfuIdAzi = @IdAziDest
                                                  AND substring(a.pfuFunzionalita, @PosizioneVincoloDest, 1) = '1'
                                                  AND substring(a.pfuFunzionalita, @FuoriSede, 1) = '0'
                                                  AND b.cspValue between @LowerRangeSM AND @TmpCspValue 
                                                  AND a.pfuDeleted = 0
                                                ORDER BY c.NumeroRdo
          end
     open PfuCursor
     fetch next FROM PfuCursor INTo @IdPfuCur
     set @IdPfuFirst = @IdPfuCur
     IF @Count = 1
          begin
                set @bSuccess = 1
                close PfuCursor
                deallocate PfuCursor
                break
          end
     /* Controllo le aree geografiche */
     while @@fetch_status = 0   /* 2 */
     begin
         /* Se l'utente destinatario _ un seller faccio il confronto con le aree geografiche del buyer e viceversa */
          IF  @TipoUserDest = 'S'
               begin
                     DECLARE PfuGphMittCursor cursor static for SELECT b.gphvalue
                                                 FROM  ProfiliUtente a, DfbPfuGph b 
                                                WHERE a.IdPfu = @IdPfuMitt
                                                  AND a.IdPfu = b.IdPfu
                                                  AND a.pfuDeleted = 0
               end
          ELSE
               begin
                     DECLARE PfuGphMittCursor cursor static for SELECT b.gphvalue
                                                 FROM  ProfiliUtente a, DfsPfuGph b 
                                                WHERE a.IdPfu = @IdPfuMitt
                                                  AND a.IdPfu = b.IdPfu                                               
                                                  AND a.pfuDeleted = 0
               end
          open PfuGphMittCursor
          fetch next FROM PfuGphMittCursor INTo @GphMitt
          while @@fetch_status = 0   /*  3  */
          begin
               exec LowerRange @GphMitt, @LowerRangeAG OUTPUT
               set @CountAG = 0
               IF  @TipoUserDest = 'S'
                    begin
                          SELECT @CountAG = count(b.gphvalue)
                            FROM  DfsPfuGph b 
                           WHERE  b.IdPfu = @IdPfuCur
                             AND  ((b.gphValue between @LowerRangeAG AND @GphMitt) or  b.gphValue = 0)
                    end
               ELSE
                    begin
                          SELECT @CountAG = count(b.gphvalue)
                            FROM  DfbPfuGph b 
                           WHERE  b.IdPfu = @IdPfuCur
                             AND  ((b.gphValue between @LowerRangeAG AND @GphMitt) or  b.gphValue = 0)
                    end
               IF @CountAG <> 0
                   begin
                         set @bSuccess = 1
                         close PfuGphMittCursor
                         deallocate PfuGphMittCursor
                         break
                   end
               fetch next FROM PfuGphMittCursor INTo @GphMitt
          end  /* 3  */
          IF @bSuccess = 1
              begin
                   close PfuCursor
                   deallocate PfuCursor
                   break
              end
          close PfuGphMittCursor
          deallocate PfuGphMittCursor
  
          fetch next FROM PfuCursor INTo @IdPfuCur
     end  /* 2 */
     close PfuCursor
     deallocate PfuCursor
     IF @bSuccess = 0 AND @Count > 1
         begin
              set @bSuccess = 1
              set @IdPfuCur = @IdPfuFirst
         end
     IF @bSuccess = 1
           begin
                break
           end
     fetch next FROM tmpcrs INTo @TmpCspValue 
end   /* 1 */
close tmpcrs
deallocate tmpcrs
  IF  @bSuccess = 1 
       begin
             goto FineStored
       end
  ELSE
       begin
             set @IdPfuCur = NULL
               /* Selezioniamo il primo utente acquirente o venditore dell'azienda destinataria */
             SELECT top 1 @IdPfuCur = a.IdPfu
                    FROM  ProfiliUtente a
              left outer join RdoElaborate c on a.IdPfu = c.IdPfu
                        WHERE a.pfuProfili like @FiltroProfilo 
                          AND a.pfuIdAzi = @IdAziDest
                          AND substring(a.pfuFunzionalita, @PosizioneVincoloDest, 1) = '1'
                          AND substring(a.pfuFunzionalita, @FuoriSede, 1) = '0'
                          AND a.pfuDeleted = 0
                     ORDER BY c.NumeroRdo
                                                 
               /* Viene selezionato l'amministratore dell'azienda destinataria */
             IF @IdPfuCur IS NULL
                 begin
                      SELECT top 1 @IdPfuCur = IdPfu 
                              FROM ProfiliUtente 
                             WHERE pfuIdAzi = @IdAziDest 
                               AND pfuAdmin = 1 
                               AND pfuDeleted = 0
                 end
             goto FineStored
       end
 /*
                              S E L E Z I O N E   P E R   A R E A   G E O G R A F I C A
 */
SelAreaGeog:
    set @bSuccess = 0
    IF  @TipoUserDest = 'S'
          begin
                 DECLARE PfuGphMittCursor cursor static for SELECT b.gphvalue
                                                       FROM  ProfiliUtente a, DfbPfuGph b 
                                                      WHERE a.IdPfu = @IdPfuMitt
                                                        AND a.IdPfu = b.IdPfu
                                                        AND a.pfuDeleted = 0
          end
    ELSE
          begin
                 DECLARE PfuGphMittCursor cursor  static for SELECT b.gphvalue
                                                       FROM  ProfiliUtente a, DfsPfuGph b 
                                                      WHERE a.IdPfu = @IdPfuMitt
                                                        AND a.IdPfu = b.IdPfu                                               
                                                        AND a.pfuDeleted = 0
          end
     open PfuGphMittCursor
     fetch next FROM PfuGphMittCursor INTo @GphMitt
     while @@fetch_status = 0   /*  4  */
     begin
           exec LowerRange @GphMitt, @LowerRangeAG OUTPUT
           set @CountAG = 0
           IF  @TipoUserDest = 'S'
                begin
                      SELECT @CountAG = count(a.IdPfu)
                        FROM  ProfiliUtente a, DfsPfuGph b
                       WHERE a.pfuProfili like @FiltroProfilo 
                         AND a.IdPfu = b.IdPfu
                         AND a.pfuIdAzi = @IdAziDest
                         AND substring(a.pfuFunzionalita, @PosizioneVincoloDest, 1) = '1'
                         AND substring(a.pfuFunzionalita, @FuoriSede, 1) = '0'
                         AND ((b.gphValue between @LowerRangeAG AND @GphMitt) or  b.gphValue = 0)
                         AND a.pfuDeleted = 0
                end
           ELSE
                begin
                      SELECT @CountAG = count(a.IdPfu)
                        FROM  ProfiliUtente a, DfbPfuGph b
                       WHERE a.pfuProfili like @FiltroProfilo 
                         AND a.IdPfu = b.IdPfu
                         AND a.pfuIdAzi = @IdAziDest
                         AND substring(a.pfuFunzionalita, @PosizioneVincoloDest, 1) = '1'
                         AND substring(a.pfuFunzionalita, @FuoriSede, 1) = '0'
                         AND ((b.gphValue between @LowerRangeAG AND @GphMitt) or  b.gphValue = 0)
                         AND a.pfuDeleted = 0
                end
           IF @CountAG = 0
                  begin
                         fetch next FROM PfuGphMittCursor INTo @GphMitt
                         continue
                  end
          IF  @TipoUserDest = 'S'
                begin
                      DECLARE PfuCursor cursor  static  for SELECT a.IdPfu 
                                                     FROM  ProfiliUtente a
                                                     inner join DfsPfuGph b on a.IdPfu = b.IdPfu                                                     
                                                     left outer join RdoElaborate c on a.IdPfu = c.IdPfu
                                                    WHERE a.pfuProfili like @FiltroProfilo 
                                                      AND a.pfuIdAzi = @IdAziDest
                                                      AND substring(a.pfuFunzionalita, @PosizioneVincoloDest, 1) = '1'
                                                      AND substring(a.pfuFunzionalita, @FuoriSede, 1) = '0'
                                                      AND ((b.gphValue between @LowerRangeAG AND @GphMitt) or  b.gphValue = 0)
                                                      AND a.pfuDeleted = 0
                                                 ORDER BY c.NumeroRdo
                                                 
                end
          ELSE
                begin
                      DECLARE PfuCursor cursor  static  for SELECT a.IdPfu 
                                                     FROM  ProfiliUtente a
                                                     inner join DfbPfuGph b on a.IdPfu = b.IdPfu
                                                     left outer join RdoElaborate c on a.IdPfu = c.IdPfu
                                                    WHERE a.pfuProfili like @FiltroProfilo 
                                                      AND a.pfuIdAzi = @IdAziDest
                                                      AND substring(a.pfuFunzionalita, @PosizioneVincoloDest, 1) = '1'
                                                      AND substring(a.pfuFunzionalita, @FuoriSede, 1) = '0'
                                                      AND ((b.gphValue between @LowerRangeAG AND @GphMitt) or  b.gphValue = 0)
                                                      AND a.pfuDeleted = 0
                                                 ORDER BY c.NumeroRdo
                end
          open PfuCursor
          fetch next FROM PfuCursor INTo @IdPfuCur
          set @bSuccess = 1
          close PfuCursor
          deallocate PfuCursor
          break
          fetch next FROM PfuGphMittCursor INTo @GphMitt
     end  /* 4  */
     close PfuGphMittCursor
     deallocate PfuGphMittCursor
     IF @bSuccess = 0
          begin
             set @IdPfuCur = NULL
               /* Selezioniamo il primo utente acquirente o venditore dell'azienda destinataria */
             SELECT top 1 @IdPfuCur = a.IdPfu
                    FROM  ProfiliUtente a
              left outer join RdoElaborate c on a.IdPfu = c.IdPfu
                        WHERE a.pfuProfili like @FiltroProfilo 
                          AND a.pfuIdAzi = @IdAziDest
                          AND substring(a.pfuFunzionalita, @PosizioneVincoloDest, 1) = '1'
                          AND substring(a.pfuFunzionalita, @FuoriSede, 1) = '0'
                          AND a.pfuDeleted = 0
                     ORDER BY c.NumeroRdo
                                                 
               /* Viene selezionato l'amministratore dell'azienda destinataria */
             IF @IdPfuCur IS NULL
                 begin
                      SELECT top 1 @IdPfuCur = IdPfu 
                              FROM ProfiliUtente 
                             WHERE pfuIdAzi = @IdAziDest 
                               AND pfuAdmin = 1 
                               AND pfuDeleted = 0
                 end
           end
FineStored:
  /* Cancello tutti i record dalla tabella temporanea */
    delete FROM TempSM_SELECTUser
    IF  @IdPfuCur IS NULL
         begin
                 Set @IdPfuDest = -1
                 goto ExitStored
         end
  /* incrementa di uno il numero di messaggi elaborati per l'utente selezionato */
    SELECT @NumeroRdo = NULL
    SELECT @NumeroRdo = RdoElaborate.NumeroRdo
      FROM RdoElaborate WHERE RdoElaborate.IdPfu = @IdPfuCur
    IF @NumeroRdo IS NULL
         begin
               insert RdoElaborate(IdPfu,NumeroRdo) values (@IdPfuCur,1)
         end
    ELSE
         begin
               update RdoElaborate SET NumeroRdo = NumeroRdo + 1 
                WHERE IdPfu = @IdPfuCur
         end
  Set @IdPfuDest = @IdPfuCur
ExitStored:



GO
