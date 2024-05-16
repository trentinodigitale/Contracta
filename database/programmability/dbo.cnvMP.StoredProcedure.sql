USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[cnvMP]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
Autore: Alfano Antonio
Scopo: Estrazione stringhe dal Multilinguismo
Data:  20020509
*/
CREATE PROCEDURE [dbo].[cnvMP] (
            @IdMp INT,
            @suffix VARCHAR(5),
            @key      varchar(101)
)  with recompile  AS
begin

DECLARE @mpmlngMlngKey VARCHAR(101)
SELECT @mpmlngMlngKey=mpmlngMlngKey FROM MpMultilinguismo
WHERE mpmlngMPKey=@key AND mpmlngDeleted=0 AND mpmlngIdMp=@IdMp
IF @mpmlngMlngKey is not NULL      BEGIN
                         set @key=@mpmlngMlngKey
                        END
set @key=REPLACE(@key,'''','''''')
execute('SELECT dbo.CNV_ESTESA(mlngDesc_'+@suffix+','''+@suffix+''') as  mlngDesc_'+@suffix+' FROM Multilinguismo WHERE IdMultiLng like '''+@key+''' AND  mlngCancellato=0')
IF @@ERROR<>0      BEGIN
             return 99
            END
end
GO
