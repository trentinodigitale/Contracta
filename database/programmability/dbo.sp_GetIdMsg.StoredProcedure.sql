USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[sp_GetIdMsg]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--===============================
--	CODICE STRUTTURA	=
--===============================
CREATE PROCEDURE  [dbo].[sp_GetIdMsg]
                     (
                        @vcContext     VARCHAR(20),
                        @iType         INT,
                        @iSubType      INT,                       
                        @vcFieldName   VARCHAR(50),
                        @vcFieldValue  VARCHAR(1000),
                        @IdPfu         INT,
                        @vcProf        VARCHAR(5)
                     )
AS
IF @iType =  -1 AND @vcFieldName = ''
   BEGIN
        RAISERROR ('Parametri non validi', 16, 1)
        RETURN 99
   END
IF @vcContext = 'Dossier'
   BEGIN
        GOTO l_Dossier
   END
/* Web Client */
IF @iType <> -1
   IF @vcFieldName <> ''
      BEGIN
       IF @IdPfu != -1 
	 BEGIN 	
	        SELECT IdMsg,msgitype,msgisubtype, msgText, SUBSTRING (msgText, PATINDEX ('%<biztoBFieldName>%', msgText) + 17, 
        						PATINDEX ('%</biztoBFieldName>%', msgText) - 
        						(PATINDEX ('%<biztoBFieldName>%', msgText) + 17)) as msgName,
                       dcmUrl
                FROM TAB_MESSAGGI, TAB_UTENTI_MESSAGGI, MessageFields, Document
	        WHERE IdMsg = umIdMsg
        	      AND IdMsg = mfIdMsg
		      AND mfIType = @iType
		      AND mfIType = dcmiType
		      AND mfISubType = @iSubType
		      AND mfISubType = dcmiSubType
	              AND mfFieldName = @vcFieldName
           	      AND mfFieldValue = @vcFieldValue
		      AND umIdPfu = @IdPfu
		      AND umStato = 0
		      AND umInput = 0
	  END 
 	ELSE
          BEGIN
 	        SELECT IdMsg,msgitype,msgisubtype, msgText, SUBSTRING (msgText, PATINDEX ('%<biztoBFieldName>%', msgText) + 17, 
        						PATINDEX ('%</biztoBFieldName>%', msgText) - 
        						(PATINDEX ('%<biztoBFieldName>%', msgText) + 17)) as msgName,
                       dcmUrl
                FROM TAB_MESSAGGI, MessageFields, Document
	        WHERE IdMsg = mfIdMsg
		      AND mfIType = @iType
		      AND mfIType = dcmiType
		      AND mfISubType = @iSubType
		      AND mfISubType = dcmiSubType
	              AND mfFieldName = @vcFieldName
           	      AND mfFieldValue = @vcFieldValue
 	  END
      END 
   ELSE
      BEGIN
	 IF @IdPfu != -1 
	 BEGIN 	
	       SELECT IdMsg,msgitype,msgisubtype, msgText, SUBSTRING (msgText, PATINDEX ('%<biztoBFieldName>%', msgText) + 17, 
        						PATINDEX ('%</biztoBFieldName>%', msgText) - 
        						(PATINDEX ('%<biztoBFieldName>%', msgText) + 17)) as msgName,
                       dcmUrl
               FROM TAB_MESSAGGI, TAB_UTENTI_MESSAGGI, MessageFields, Document
	       WHERE IdMsg = umIdMsg
        	   AND IdMsg = mfIdMsg
	           AND mfIType = @iType
        	   AND mfIType = dcmiType
	           AND mfISubType = @iSubType
	           AND mfISubType = dcmiSubType
	           AND mfFieldValue = @vcFieldValue
	           AND umIdPfu = @IdPfu
	           AND umStato = 0
	           AND umInput = 0
	 END
       ELSE
         BEGIN
	       SELECT IdMsg,msgitype,msgisubtype, msgText, SUBSTRING (msgText, PATINDEX ('%<biztoBFieldName>%', msgText) + 17, 
        						PATINDEX ('%</biztoBFieldName>%', msgText) - 
        						(PATINDEX ('%<biztoBFieldName>%', msgText) + 17)) as msgName,
                       dcmUrl
               FROM TAB_MESSAGGI, MessageFields, Document
	       WHERE IdMsg = mfIdMsg
	           AND mfIType = @iType
        	   AND mfIType = dcmiType
	           AND mfISubType = @iSubType
	           AND mfISubType = dcmiSubType
	           AND mfFieldValue = @vcFieldValue
	 END
      END 
ELSE
 IF @IdPfu != -1 
	 BEGIN 	
		SELECT IdMsg, msgitype,msgisubtype, msgText, SUBSTRING (msgText, PATINDEX ('%<biztoBFieldName>%', msgText) + 17, 
						PATINDEX ('%</biztoBFieldName>%', msgText) - 
						(PATINDEX ('%<biztoBFieldName>%', msgText) + 17)) as msgName,
	        dcmUrl
	        FROM TAB_MESSAGGI, TAB_UTENTI_MESSAGGI, MessageFields, Document
		WHERE IdMsg = umIdMsg
		AND IdMsg = mfIdMsg
		AND mfIType = dcmiType
		AND mfISubType = dcmiSubType
		AND mfFieldName = @vcFieldName
		AND mfFieldValue = @vcFieldValue
		AND umIdPfu = @IdPfu
		AND umStato = 0
		AND umInput = 0
	END
ELSE
	BEGIN
		SELECT IdMsg, msgitype,msgisubtype, msgText, SUBSTRING (msgText, PATINDEX ('%<biztoBFieldName>%', msgText) + 17, 
						PATINDEX ('%</biztoBFieldName>%', msgText) - 
						(PATINDEX ('%<biztoBFieldName>%', msgText) + 17)) as msgName,
	        dcmUrl
	        FROM TAB_MESSAGGI,MessageFields, Document
		WHERE IdMsg = mfIdMsg
		AND mfIType = dcmiType
		AND mfISubType = dcmiSubType
		AND mfFieldName = @vcFieldName
		AND mfFieldValue = @vcFieldValue
	END 
GOTO l_ExitSP
l_Dossier:
IF @iType <> -1
   IF @vcFieldName <> ''
      BEGIN
        SELECT DISTINCT a.IdMsg, e.dcmIType as msgitype, e.dcmISUbtype as msgitype, a.msgName, e.dcmURL
          FROM Messaggi a, Document e, MessageFields d
         WHERE a.msgIdDcm = e.IdDcm
           AND a.IdMsg = d.mfIdMsg
           AND d.mfFieldName = @vcFieldName
           AND d.mfFieldValue = @vcFieldValue
           AND e.dcmDetail LIKE '%' + @vcProf + '%'
           AND e.dcmIType = @iType
           AND e.dcmISubType = @iSubType
      END
   ELSE
     BEGIN
        SELECT DISTINCT a.IdMsg, e.dcmIType as msgitype, e.dcmISUbtype as msgitype, a.msgName, e.dcmURL
          FROM Messaggi a, Document e, MessageFields d
         WHERE a.msgIdDcm = e.IdDcm
           AND a.IdMsg = d.mfIdMsg
           AND d.mfFieldValue = @vcFieldValue
           AND e.dcmDetail LIKE '%' + @vcProf + '%'
           AND e.dcmIType = @iType
           AND e.dcmISubType = @iSubType
     END
ELSE
SELECT DISTINCT a.IdMsg, a.msgName, e.dcmURL
  FROM Messaggi a, Document e, MessageFields d
 WHERE a.msgIdDcm = e.IdDcm
   AND a.IdMsg = d.mfIdMsg
   AND d.mfFieldName = @vcFieldName
   AND d.mfFieldValue = @vcFieldValue
   AND e.dcmDetail LIKE '%' + @vcProf + '%'
l_ExitSP:
GO
