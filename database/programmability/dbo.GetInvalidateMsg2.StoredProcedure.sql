USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetInvalidateMsg2]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetInvalidateMsg2] (
                                    @iType            SMALLINT, 
                                    @iSubType         SMALLINT, 
                                    @iTypeDest        SMALLINT, 
                                    @iSubTypeDest     SMALLINT,
                                    @vcFindFieldName  VARCHAR (50),
                                    @vcFindFieldValue VARCHAR (50),
                                    @iLen             INT
                                   )
AS
DECLARE @vcFindFieldNameDest VARCHAR (60)
DECLARE @iLenFieldName       INT
SET @vcFindFieldNameDest = '%<' + RTRIM (LTRIM (@vcFindFieldName)) + '>%'
SET @iLenFieldName = LEN (@vcFindFieldNameDest) - 2
SELECT IdMsg 
  FROM TAB_MESSAGGI WITH (NOLOCK)
 WHERE (( msgIType = @iType AND msgISubType = @iSubType) OR (msgIType = @iTypeDest AND msgISubType = @iSubTypeDest))
   AND SUBSTRING (msgText, PATINDEX (@vcFindFieldNameDest, msgtext) + @iLenFieldName, @iLen) = @vcFindFieldValue
 ORDER BY IdMsg
GO
