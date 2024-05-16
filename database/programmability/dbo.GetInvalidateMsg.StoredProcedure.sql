USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetInvalidateMsg]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetInvalidateMsg] (
                                    @iType            SMALLINT, 
                                    @iSubType         SMALLINT, 
                                    @iTypeDest        SMALLINT, 
                                    @iSubTypeDest     SMALLINT,
                                    @vcFindFieldName  VARCHAR (80),
                                    @vcFindFieldValue VARCHAR (100),
                                    @iLen             INT
                                   )
AS
SELECT mfIdMsg AS IdMsg 
  FROM MessageFields WITH (NOLOCK)
 WHERE ((mfIType = @iType AND mfISubType = @iSubType) OR (mfIType = @iTypeDest AND mfISubType = @iSubTypeDest))
   AND mfFieldName = @vcFindFieldName
   AND mfFieldValue = @vcFindFieldValue
GO
