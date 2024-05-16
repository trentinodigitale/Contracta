USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetLnkMsg]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetLnkMsg] (
                                @IdMsg       INTEGER,
                                @vcOper      VARCHAR (20),
                                @vcLngSuffix VARCHAR (5)
                           )
AS
DECLARE @iType                     INTEGER
DECLARE @vcSQLCols1                VARCHAR (8000)
DECLARE @vcbiztoBFieldNameStartF   VARCHAR (0100)
DECLARE @vcbiztoBFieldNameEndF     VARCHAR (0100)
DECLARE @vcIdMsg                   VARCHAR (0100)
SET @vcbiztoBFieldNameStartF = '''%<biztoBFieldName>%'''
SET @vcbiztoBFieldNameEndF   = '''%</biztoBFieldName>%'''
SET @iType = NULL
SELECT @iType = msgIType
  FROM TAB_MESSAGGI
 WHERE IdMsg = @IdMsg
IF @iType IS NULL
   BEGIN
         RAISERROR ('Messaggio [%D] non trovato', 16, 1, @IdMsg)
         RETURN 99
   END
SET @vcIdMsg = NULL
/* RdO  */
IF @iType IN (4, 11) AND @vcOper = 'NEXT'
   BEGIN
        SELECT @vcIdMsg = SUBSTRING (msgText, PATINDEX ('%<biztobFieldIdRdo>%', msgText) + 18, 
                                     PATINDEX ('%</biztobFieldIdRdo>%', msgText) - (PATINDEX ('%<biztobFieldIdRdo>%', msgText) + 18))
          FROM TAB_MESSAGGI
         WHERE IdMsg = @IdMsg
        IF @Idmsg IS NULL
           BEGIN
                RAISERROR ('Field "IdRdo" non trovato per il messaggio [%d]', 16, 1, @IdMsg)
                RETURN 99
           END
        IF @vcIdmsg = ''
           BEGIN
                GOTO L_EMPTY
           END
        SET @vcSQLCols1 = 
        '
        SELECT IdMsg,
               msgIType,
               msgISubType,
               mlngDesc_' + @vcLngSuffix  + '       AS [Tipo Documento],
               SUBSTRING (msgText, PATINDEX (' + @vcbiztoBFieldNameStartF + ', msgtext) + 17, 
                          PATINDEX (' + @vcbiztoBFieldNameEndF + ', msgtext) - (PATINDEX (' + @vcbiztoBFieldNameStartF + ', msgtext) + 17))
                                                     AS [Nome Documento],
               msgDatains                            AS Data,
               aziRagioneSociale + '' / '' + pfuNome AS Utente,
               umInput                               AS Input,
               umStato                               AS Scaricato,
               msgElabWithSuccess                    AS [Elaborato Correttamente],
               msgIdMp,
               IdPfu
          FROM TAB_MESSAGGI, Document, ProfiliUtente, Multilinguismo, Aziende, TAB_UTENTI_MESSAGGI
         WHERE IdMsg = umIdMsg
           AND msgItype = dcmIType
           AND msgISubType = dcmISubType
           AND dcmDescription = IdMultilng
           AND umIdPfu = IdPfu
           AND pfuIdAzi = IdAzi
           AND msgText LIKE ''%<biztobFieldIdRdo>' + @vcIDMsg + '</biztobFieldIdRdo>%''
           AND msgIType IN (9, 10)
         ORDER BY IdMsg
       '    
       EXEC (@vcSQLCols1)
       RETURN 0
   END
/* Offerta  */
IF @iType IN (9, 10) AND @vcOper = 'PREV'
   BEGIN
        SELECT @vcIdMsg = SUBSTRING (msgText, PATINDEX ('%<biztobFieldIdRdo>%', msgText) + 18, 
                                    PATINDEX ('%</biztobFieldIdRdo>%', msgText) - (PATINDEX ('%<biztobFieldIdRdo>%', msgText) + 18))
          FROM TAB_MESSAGGI
         WHERE IdMsg = @IdMsg
        IF @Idmsg IS NULL
           BEGIN
                RAISERROR ('Field "IdRdo" non trovato per il messaggio [%d]', 16, 1, @IdMsg)
                RETURN 99
           END
        IF @vcIdmsg = ''
           BEGIN
                GOTO L_EMPTY
           END
        SET @vcSQLCols1 = 
        '
        SELECT IdMsg,
               msgIType,
               msgISubType,
               mlngDesc_' + @vcLngSuffix  + '       AS [Tipo Documento],
               SUBSTRING (msgText, PATINDEX (' + @vcbiztoBFieldNameStartF + ', msgtext) + 17, 
                          PATINDEX (' + @vcbiztoBFieldNameEndF + ', msgtext) - (PATINDEX (' + @vcbiztoBFieldNameStartF + ', msgtext) + 17))
                                                     AS [Nome Documento],
               msgDatains                            AS Data,
               aziRagioneSociale + '' / '' + pfuNome AS Utente,
               umInput                               AS Input,
               umStato                               AS Scaricato,
               msgElabWithSuccess                    AS [Elaborato Correttamente],
               msgIdMp,
               IdPfu
          FROM TAB_MESSAGGI, Document, ProfiliUtente, Multilinguismo, Aziende, TAB_UTENTI_MESSAGGI
         WHERE IdMsg = umIdMsg
           AND msgItype = dcmIType
           AND msgISubType = dcmISubType
           AND dcmDescription = IdMultilng
           AND umIdPfu = IdPfu
           AND pfuIdAzi = IdAzi
           AND msgText LIKE ''%<biztobFieldIdRdo>' + @vcIDMsg + '</biztobFieldIdRdo>%''
           AND msgIType IN (4, 11)
         ORDER BY IdMsg
       '    
       EXEC (@vcSQLCols1)
       RETURN 0
   END
IF @iType IN (9, 10) AND @vcOper = 'NEXT'
   BEGIN
        SELECT @vcIdMsg = SUBSTRING (msgText, PATINDEX ('%<biztobFieldIdOff>%', msgText) + 18, 
                                    PATINDEX ('%</biztobFieldIdOff>%', msgText) - (PATINDEX ('%<biztobFieldIdOff>%', msgText) + 18))
          FROM TAB_MESSAGGI
         WHERE IdMsg = @IdMsg
        IF @Idmsg IS NULL
           BEGIN
                RAISERROR ('Field "IdOff" non trovato per il messaggio [%d]', 16, 1, @IdMsg)
                RETURN 99
           END
        IF @vcIdmsg = ''
           BEGIN
                GOTO L_EMPTY
           END
        SET @vcSQLCols1 = 
        '
        SELECT IdMsg,
               msgIType,
               msgISubType,
               mlngDesc_' + @vcLngSuffix  + '       AS [Tipo Documento],
               SUBSTRING (msgText, PATINDEX (' + @vcbiztoBFieldNameStartF + ', msgtext) + 17, 
                          PATINDEX (' + @vcbiztoBFieldNameEndF + ', msgtext) - (PATINDEX (' + @vcbiztoBFieldNameStartF + ', msgtext) + 17))
                                                     AS [Nome Documento],
               msgDatains                            AS Data,
               aziRagioneSociale + '' / '' + pfuNome AS Utente,
               umInput                               AS Input,
               umStato                               AS Scaricato,
               msgElabWithSuccess                    AS [Elaborato Correttamente],
               msgIdMp,
               IdPfu
          FROM TAB_MESSAGGI, Document, ProfiliUtente, Multilinguismo, Aziende, TAB_UTENTI_MESSAGGI
         WHERE IdMsg = umIdMsg
           AND msgItype = dcmIType
           AND msgISubType = dcmISubType
           AND dcmDescription = IdMultilng
           AND umIdPfu = IdPfu
           AND pfuIdAzi = IdAzi
           AND msgText LIKE ''%<biztobFieldIdOff>' + @vcIDMsg + '</biztobFieldIdOff>%''
           AND msgIType IN (22, 23)
         ORDER BY IdMsg
       '    
       EXEC (@vcSQLCols1)
       RETURN 0
   END
/* Ordine  */
IF @iType IN (22, 23) AND @vcOper = 'PREV'
   BEGIN
        SELECT @vcIdMsg = SUBSTRING (msgText, PATINDEX ('%<biztobFieldIdOff>%', msgText) + 18, 
                                    PATINDEX ('%</biztobFieldIdOff>%', msgText) - (PATINDEX ('%<biztobFieldIdOff>%', msgText) + 18))
          FROM TAB_MESSAGGI
         WHERE IdMsg = @IdMsg
        IF @Idmsg IS NULL
           BEGIN
                RAISERROR ('Field "IdOff" non trovato per il messaggio [%d]', 16, 1, @IdMsg)
                RETURN 99
           END
        IF @vcIdmsg = ''
           BEGIN
                GOTO L_EMPTY
           END
        SET @vcSQLCols1 = 
        '
        SELECT IdMsg,
               msgIType,
               msgISubType,
               mlngDesc_' + @vcLngSuffix  + '       AS [Tipo Documento],
               SUBSTRING (msgText, PATINDEX (' + @vcbiztoBFieldNameStartF + ', msgtext) + 17, 
                          PATINDEX (' + @vcbiztoBFieldNameEndF + ', msgtext) - (PATINDEX (' + @vcbiztoBFieldNameStartF + ', msgtext) + 17))
                                                     AS [Nome Documento],
               msgDatains                            AS Data,
               aziRagioneSociale + '' / '' + pfuNome AS Utente,
               umInput                               AS Input,
               umStato                               AS Scaricato,
               msgElabWithSuccess                    AS [Elaborato Correttamente],
               msgIdMp,
               IdPfu
          FROM TAB_MESSAGGI, Document, ProfiliUtente, Multilinguismo, Aziende, TAB_UTENTI_MESSAGGI
         WHERE IdMsg = umIdMsg
           AND msgItype = dcmIType
           AND msgISubType = dcmISubType
           AND dcmDescription = IdMultilng
           AND umIdPfu = IdPfu
           AND pfuIdAzi = IdAzi
           AND msgText LIKE ''%<biztobFieldIdOff>' + @vcIDMsg + '</biztobFieldIdOff>%''
           AND msgIType IN (9, 10)
         ORDER BY IdMsg
       '    
       EXEC (@vcSQLCols1)
       RETURN 0
   END
/* Resituisce il recordset vuoto */
L_EMPTY:
SET @vcIDMsg = ''
SET @vcSQLCols1 = 
'
SELECT IdMsg,
       msgIType,
       msgISubType,
       mlngDesc_' + @vcLngSuffix  + '       AS [Tipo Documento],
       SUBSTRING (msgText, PATINDEX (' + @vcbiztoBFieldNameStartF + ', msgtext) + 17, 
                  PATINDEX (' + @vcbiztoBFieldNameEndF + ', msgtext) - (PATINDEX (' + @vcbiztoBFieldNameStartF + ', msgtext) + 17))
                                             AS [Nome Documento],
       msgDatains                            AS Data,
       aziRagioneSociale + '' / '' + pfuNome AS Utente,
       umInput                               AS Input,
       umStato                               AS Scaricato,
       msgElabWithSuccess                    AS [Elaborato Correttamente],
       msgIdMp,
       IdPfu
  FROM TAB_MESSAGGI, Document, ProfiliUtente, Multilinguismo, Aziende, TAB_UTENTI_MESSAGGI
 WHERE IdMsg = umIdMsg
   AND msgItype = dcmIType
   AND msgISubType = dcmISubType
   AND dcmDescription = IdMultilng
   AND umIdPfu = IdPfu
   AND pfuIdAzi = IdAzi
   AND msgText LIKE ''%<biztobFieldIdRdo>' + @vcIDMsg + '</biztobFieldIdRdo>%''
   AND msgIType IN (9, 10)
   AND IdMsg = -1
'    
EXEC (@vcSQLCols1)
GO
