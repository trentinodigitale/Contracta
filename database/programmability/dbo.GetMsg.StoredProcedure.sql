USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetMsg]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[GetMsg] 
(
@vcLngSuffix    VARCHAR (5),
@vcName         NVARCHAR (100),
@vcProtocol     NVARCHAR (30),
@vcLnkProtocol  NVARCHAR (30),
@vcNumOrd       NVARCHAR (20),
@vcNumOff       NVARCHAR (20),
@vcStartDate    VARCHAR (10),
@vcEndDate      VARCHAR (10),
@vcOperator     VARCHAR (5),
@iType          INT,
@iSubType       INT
)
AS
DECLARE @vcSQLCols1                      NVARCHAR (4000)
DECLARE @vcSQLCols2                      NVARCHAR (4000)
DECLARE @vcSQLWHERE                      NVARCHAR (4000)
DECLARE @vcbiztoBFieldProtocolStart      VARCHAR (0100)
DECLARE @vcbiztoBFieldNameStart          VARCHAR (0100)
DECLARE @vcbiztoBFieldNameStartF         VARCHAR (0100)
DECLARE @vcbiztoBFieldNumOrdStart        VARCHAR (0100)
DECLARE @vcbiztoBFieldNumOffStart        VARCHAR (0100)
DECLARE @vcbiztoBFieldProtLinkMsgStart   VARCHAR (0100)
DECLARE @vcbiztoBFieldProtocolEnd        VARCHAR (0100)
DECLARE @vcbiztoBFieldNameEnd            VARCHAR (0100)
DECLARE @vcbiztoBFieldNameEndF           VARCHAR (0100)
DECLARE @vcbiztoBFieldNumOrdEnd          VARCHAR (0100)
DECLARE @vcbiztoBFieldNumOffEnd          VARCHAR (0100)
DECLARE @vcbiztoBFieldProtLinkMsgend     VARCHAR (0100)
SET @vcbiztoBFieldProtocolStart       = '<biztoBFieldProtocol>'
SET @vcbiztoBFieldNameStart           = '<biztoBFieldName>'
SET @vcbiztoBFieldNameStartF          = '''%<biztoBFieldName>%'''
SET @vcbiztoBFieldNumOrdStart         = '<biztoBFieldNumOrd>'
SET @vcbiztoBFieldNumOffStart         = '<biztoBFieldNumOff>'
SET @vcbiztoBFieldProtLinkMsgStart    = '<biztoBFieldProtLinkMsg>'
SET @vcbiztoBFieldProtocolEnd         = '</biztoBFieldProtocol>'
SET @vcbiztoBFieldNameEnd             = '</biztoBFieldName>'
SET @vcbiztoBFieldNameEndF            = '''%</biztoBFieldName>%'''
SET @vcbiztoBFieldNumOrdEnd           = '</biztoBFieldNumOrd>'
SET @vcbiztoBFieldNumOffEnd           = '</biztoBFieldNumOff>'
SET @vcbiztoBFieldProtLinkMsgEnd      = '</biztoBFieldProtLinkMsg>'
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
'
SET @vcSQLWHERE = ''
IF @iType <> -1
   SET @vcSQLWHERE = ' AND msgIType = ' + CAST(@iType AS VARCHAR(5)) + ' AND msgISubType = ' + CAST(@iSubType AS VARCHAR(5))
IF @vcName <> ''
   BEGIN
        SET @vcName = REPLACE (@vcName, '''', '''''')
        SET @vcSQLWHERE = @vcSQLWHERE + ' AND msgText LIKE + ''%' +  @vcbiztoBFieldNameStart + @vcName + @vcbiztoBFieldNameEnd + '%'''
   END
IF @vcProtocol <> ''
   SET @vcSQLWHERE = @vcSQLWHERE + ' AND msgText LIKE + ''%' +  @vcbiztoBFieldProtocolStart + @vcProtocol + @vcbiztoBFieldProtocolEnd + '%'''
IF @vcLnkProtocol <> ''
   SET @vcSQLWHERE = @vcSQLWHERE + ' AND msgText LIKE + ''%' +  @vcbiztoBFieldProtLinkMsgStart + @vcLnkProtocol + @vcbiztoBFieldProtLinkMsgEnd + '%'''
IF @vcNumOrd <> ''
   SET @vcSQLWHERE = @vcSQLWHERE + ' AND msgText LIKE + ''%' +  @vcbiztoBFieldNumOrdStart + @vcNumOrd + @vcbiztoBFieldNumOrdEnd + '%'''
IF @vcNumOff <> ''
   SET @vcSQLWHERE = @vcSQLWHERE + ' AND msgText LIKE + ''%' +  @vcbiztoBFieldNumOffStart + @vcNumOff + @vcbiztoBFieldNumOffEnd + '%'''
IF @vcStartDate <> '' AND @vcEndDate = ''
   SET @vcSQLWHERE = @vcSQLWHERE + ' AND CONVERT (VARCHAR(10), msgDataIns, 20) ' + @vcOperator + '''' + @vcStartDate + ''''
IF @vcStartDate <> '' AND @vcEndDate <> ''
   SET @vcSQLWHERE = @vcSQLWHERE + ' AND CONVERT (VARCHAR(10), msgDataIns, 20) ' + '>=' + '''' + @vcStartDate + '''' +
                                   ' AND CONVERT (VARCHAR(10), msgDataIns, 20) ' + '<=' + '''' + @vcEndDate + '''' 
SET @vcSQLWHERE = @vcSQLWHERE + ' ORDER BY  msgItype, msgISubType, Data desc '
EXEC (@vcSQLCols1 + @vcSQLWHERE)
GO
