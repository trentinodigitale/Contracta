USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetLinkBotton]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autore : Alfano Antonio
Scopo: Estrazionne MpDocFunk
Data: 20020603
*/
 
CREATE PROCEDURE [dbo].[GetLinkBotton] (@itype INT, @isubtype INT,@IdMp INT, @mpdfObjectType VARCHAR(5),@mpdfHide INT) AS
DECLARE @strSqlExists VARCHAR(8000)
DECLARE @strSql VARCHAR(8000)
DECLARE @strSql0 VARCHAR(8000)
DECLARE @iCount INT
set @iCount =0
            
set @strSql='SELECT MpDocFunc.* FROM Document,MpDocFunc WHERE mpdfDeleted = 0 AND IdDcm=mpdfIdDcm AND dcmIType='+cast(@itype AS VARCHAR(5))+' AND dcmIsubType='+cast(@isubtype AS VARCHAR(5))+ ' AND ('
while @iCount<len(@mpdfObjectType)      
 begin
  set @iCount=@iCount+1
  set @strSql=@strSql+' mpdfObjectType like ''%'+substring(@mpdfObjectType,@iCount,1)+'%'' or'  
 end
set @strSql=substring(@strSql,1,len(@strSql)-2)+' )'
set @strSql=@strSql+case @mpdfHide      when 0      then ' AND mpdfHide=0'
                              when 1      then ' AND mpdfHide=1'
                              ELSE ''
                  END
set @strSql0=@strSql+' AND mpdfIdMp=0'
set @strSql=@strSql+' AND mpdfIdMp='+cast(@IdMp AS VARCHAR(5))
set @strSqlExists='IF not exists('+@strSql+')      BEGIN '+@strSql0+' end ELSE begin '+@strSql+' end '
execute (@strSqlExists)
IF @@error<>0      BEGIN
             return 99
            END
GO
