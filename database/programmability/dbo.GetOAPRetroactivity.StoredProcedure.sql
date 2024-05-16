USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetOAPRetroactivity]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[GetOAPRetroactivity] (@idazi INT,@CodicePlant VARCHAR(20),@Retroactivity INT,@dDataOaP DATETIME=NULL) 
AS 
 
DECLARE @string VARCHAR(8000)
DECLARE @vcDataOaP VARCHAR(40)
SET @vcDataOaP=''
IF @dDataOaP IS NOT NULL
   BEGIN
        SET @vcDataOaP=' AND DataOaP <= '''+CAST(@dDataOaP AS VARCHAR(20))+''''
   END
SET @Retroactivity = @Retroactivity + 1
SET @string = 'SELECT TOP '+CONVERT(VARCHAR(20),@Retroactivity)+' IdOaP,SediDest,CONVERT(VARCHAR(10),DataOaP,20) AS DataOaP   
             FROM oaptestata 
            WHERE idazi =  '+CONVERT(VARCHAR(20),@idazi)+' AND CodicePlant  = '+''''+@CodicePlant+''''+@vcDataOaP+' ORDER BY DataOap DESC '
EXECUTE (@string)
GO
