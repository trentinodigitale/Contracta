USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ChiudiProgetto]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ChiudiProgetto]
AS

SET NOCOUNT ON

DECLARE @IdProgetto                                INT
DECLARE @DataOperazione                            DATETIME
DECLARE @msgISubType                               INT
DECLARE @Protocol                                  VARCHAR(30)
DECLARE @NewProtocol                               VARCHAR(30)
DECLARE @Cnt                                       INT

BEGIN TRAN

DECLARE crs CURSOR STATIC FOR SELECT IdProgetto
                                   , DataOperazione
                                   , msgISubType
                                FROM Document_Progetti 
                                   , TAB_MESSAGGI
                                   , TAB_UTENTI_MESSAGGI
                               WHERE msgIType= 55
                                 AND msgISubType IN (24, 34, 48, 68, 78, 179)
                                 AND umIdMsg = IdMsg
                                 AND umInput = CAST(0 AS BIT)
                                 AND Storico = 0
                                 AND StatoProgetto = 'EsitoPubblicato'
                                 AND dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 20)) = ProtocolloBando

OPEN crs

FETCH NEXT FROM crs INTO @IdProgetto, @DataOperazione, @msgISubType

WHILE @@FETCH_STATUS = 0
BEGIN
        IF @msgISubType = 68 AND DATEDIFF(day, @DataOperazione, GETDATE()) >= 40
        BEGIN
                SET @Protocol = NULL

                SELECT @Protocol = cvLastValue
                  FROM CountersValue 
                 WHERE cvIdCnt = 4
                   AND cvIdAzi = -1

                IF @Protocol IS NULL
                BEGIN
                        RAISERROR ('Contatore Protocollo non trovato', 16, 1)
                        CLOSE crs
                        DEALLOCATE crs
                        ROLLBACK TRAN
                        RETURN 99
                END              

                SET @Cnt = SUBSTRING(@Protocol, 3, 6)

                SET @Cnt = @Cnt + 1

                SET @NewProtocol = LEFT(@Protocol, 2)  + RIGHT('000000' + CAST(@Cnt AS VARCHAR), 6) + RIGHT(@Protocol, 3)

                UPDATE CountersValue
                   SET cvLastValue = @NewProtocol
                 WHERE cvIdCnt = 4
                   AND cvIdAzi = -1

                IF @@ERROR <> 0
                BEGIN
                        RAISERROR ('Errore "UPDATE" CountersValue', 16, 1)
                        CLOSE crs
                        DEALLOCATE crs
                        ROLLBACK TRAN
                        RETURN 99
                END
  

                INSERT INTO Document_Progetti (StatoProgetto, DataInvio, Protocol, UserDirigente, Peg, Importo, Tipologia, TipoProcedura, NumLotti, 
                                               Oggetto, Versione, NumDetermina, DataDetermina, ProtocolloBando, ReferenteUffAppalti, UserProvveditore,
                                               AllegatoDpe, NoteProgetto, DataCompilazione, Storico, DataOperazione, [User], Deleted, LinkModified, Pratica,
                                               CriterioAggiudicazione, EmailComunicazioni, ScadenzaIstanza, ScadenzaOfferta, NumDeterminaAggiudica, DataDeterminaAggiudica)
                SELECT 'GaraConclusa', GETDATE(), @NewProtocol, UserDirigente, Peg, Importo, Tipologia, TipoProcedura, NumLotti, Oggetto, Versione, NumDetermina,
                        DataDetermina, ProtocolloBando, ReferenteUffAppalti, UserProvveditore, AllegatoDpe, NoteProgetto, DataCompilazione, 1, GETDATE(), [User],
                        Deleted, LinkModified, Pratica, CriterioAggiudicazione, EmailComunicazioni, ScadenzaIstanza, ScadenzaOfferta, 
                        NumDeterminaAggiudica, DataDeterminaAggiudica
                  FROM Document_Progetti
                 WHERE IdProgetto = @IdProgetto 

                IF @@ERROR <> 0
                BEGIN
                        RAISERROR ('Errore "INSERT" Document_Progetti', 16, 1)
                        CLOSE crs
                        DEALLOCATE crs
                        ROLLBACK TRAN
                        RETURN 99
                END
                
                UPDATE Document_Progetti
                   SET StatoProgetto = 'GaraConclusa'
                     , Protocol = @NewProtocol
                     , DataOperazione = GETDATE()
                 WHERE IdProgetto = @IdProgetto

                IF @@ERROR <> 0
                BEGIN
                        RAISERROR ('Errore "UPDATE" Document_Progetti', 16, 1)
                        CLOSE crs
                        DEALLOCATE crs
                        ROLLBACK TRAN
                        RETURN 99
                END

        END
        ELSE
        IF @msgISubType IN (24, 34, 48, 78, 179) AND ABS(DATEDIFF(day, @DataOperazione, GETDATE())) >= 40
        BEGIN
                SET @Protocol = NULL

                SELECT @Protocol = cvLastValue
                  FROM CountersValue 
                 WHERE cvIdCnt = 4
                   AND cvIdAzi = -1

                IF @Protocol IS NULL
                BEGIN
                        RAISERROR ('Contatore Protocollo non trovato', 16, 1)
                        CLOSE crs
                        DEALLOCATE crs
                        ROLLBACK TRAN
                        RETURN 99
                END              

                SET @Cnt = SUBSTRING(@Protocol, 3, 6)

                SET @Cnt = @Cnt + 1

                SET @NewProtocol = LEFT(@Protocol, 2)  + RIGHT('000000' + CAST(@Cnt AS VARCHAR), 6) + RIGHT(@Protocol, 3)

                UPDATE CountersValue
                   SET cvLastValue = @NewProtocol
                 WHERE cvIdCnt = 4
                   AND cvIdAzi = -1

                IF @@ERROR <> 0
                BEGIN
                        RAISERROR ('Errore "UPDATE" CountersValue', 16, 1)
                        CLOSE crs
                        DEALLOCATE crs
                        ROLLBACK TRAN
                        RETURN 99
                END
  
                INSERT INTO Document_Progetti (StatoProgetto, DataInvio, Protocol, UserDirigente, Peg, Importo, Tipologia, TipoProcedura, NumLotti, 
                                               Oggetto, Versione, NumDetermina, DataDetermina, ProtocolloBando, ReferenteUffAppalti, UserProvveditore,
                                               AllegatoDpe, NoteProgetto, DataCompilazione, Storico, DataOperazione, [User], Deleted, LinkModified, Pratica,
                                               CriterioAggiudicazione, EmailComunicazioni, ScadenzaIstanza, ScadenzaOfferta, NumDeterminaAggiudica, DataDeterminaAggiudica)
                SELECT 'GaraConclusa', GETDATE(), @NewProtocol, UserDirigente, Peg, Importo, Tipologia, TipoProcedura, NumLotti, Oggetto, Versione, NumDetermina,
                        DataDetermina, ProtocolloBando, ReferenteUffAppalti, UserProvveditore, AllegatoDpe, NoteProgetto, DataCompilazione, 1, GETDATE(), [User],
                        Deleted, LinkModified, Pratica, CriterioAggiudicazione, EmailComunicazioni, ScadenzaIstanza, ScadenzaOfferta, 
                        NumDeterminaAggiudica, DataDeterminaAggiudica
                  FROM Document_Progetti
                 WHERE IdProgetto = @IdProgetto 

                IF @@ERROR <> 0
                BEGIN
                        RAISERROR ('Errore "INSERT" Document_Progetti', 16, 1)
                        CLOSE crs
                        DEALLOCATE crs
                        ROLLBACK TRAN
                        RETURN 99
                END
                
                UPDATE Document_Progetti
                   SET StatoProgetto = 'GaraConclusa'
                     , Protocol = @NewProtocol
                     , DataOperazione = GETDATE()
                 WHERE IdProgetto = @IdProgetto

                IF @@ERROR <> 0
                BEGIN
                        RAISERROR ('Errore "UPDATE" Document_Progetti', 16, 1)
                        CLOSE crs
                        DEALLOCATE crs
                        ROLLBACK TRAN
                        RETURN 99
                END

        END

        FETCH NEXT FROM crs INTO @IdProgetto, @DataOperazione, @msgISubType
END


CLOSE crs
DEALLOCATE crs

COMMIT TRAN
SET NOCOUNT OFF


GO
