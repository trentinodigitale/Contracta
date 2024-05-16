USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetArticlesFromLastOAP2]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetArticlesFromLastOAP2]
(
     @IdAzi INT, 
     @ArtCode NVARCHAR(20),
     @CodiceArtForn NVARCHAR(20),
     @SediDest VARCHAR(500),
     @Variazione  VARCHAR(1),
     @Viewed VARCHAR(1),
     @iIdPfu INT,
     @cContext CHAR(1),
     @vTiporiga VARCHAR(20)
)
AS
DECLARE @vRecordset VARCHAR(8000)
DECLARE @vS VARCHAR(500)
DECLARE @vIdazi VARCHAR(500)
DECLARE @vPath  VARCHAR(500)
DECLARE @vFiltro VARCHAR(4000)
DECLARE @vDesc VARCHAR(8000)
set @vDesc = '(SELECT d.dsctesto FROM tipidatirange x inner join (
                                    SELECT idtid FROM tipidati WHERE tidnome like ''CARTipoRiga'') y
                         on (x.tdridtid = y.idtid AND x.tdrcodice = tot.TipoRiga)
                  inner join descsi d on x.tdriddsc = d.iddsc) AS ''DescTipoRiga'''
            
SET @vFiltro = ''
SET @variazione = CONVERT(VARCHAR(2),@variazione)
SET @Viewed = CONVERT(VARCHAR(2),@Viewed)
IF @Idazi IS NULL
   BEGIN
      RAISERROR ('Errore Parametro @Idazi mancante',16,1)
      RETURN 99
   END 
IF @SediDest <> ''
   BEGIN
      SET @vS = @SediDest
      SET @vIdazi = SUBSTRING(@vS,1,PATINDEX ('%#%',@vS)-1)
      SET @vPath = SUBSTRING (@vS,PATINDEX ('%#%',@vS)+1,LEN(@vS))
   END       
            
/*
       SET @vRecordset = 'SELECT oapD.IdOaP,oapD.ArtCode,oapD.DescrArt,oapD.CodiceArtForn,
                    oapD.DataForn,oapD.Variazione,oapD.Viewed,oapT.DataOap,oapT.CodicePlant,oapT.sedidest,oapD.ViewedForn,oapD.IdMsg
                   FROM oapdettaglio AS oapD inner join oapaziende opaA on oapD.IdOaP = opaA.IdOaPLast inner join oaptestata oapT
                    on oapd.idoap = oapT.idoap
                 WHERE opaA.idazi = '+convert(VARCHAR(30),@idazi)
*/
IF @cContext NOT IN ('','S','B')
   BEGIN
      RAISERROR ('Errore Parametro @cContext ERRATO',16,1)
      RETURN 99
   END
     
IF @cContext='' OR @cContext='S'
   BEGIN
        SET @vRecordset = 'SELECT oapD.TipoRiga,oapD.IdOaP,oapD.ArtCode,oapD.DescrArt,oapD.CodiceArtForn,
                            oapD.DataForn,oapD.Variazione,oapD.Viewed,oapT.DataOap,oapT.CodicePlant,oapT.sedidest,oapD.ViewedForn,oapD.IdMsg,oapd.VariatoForn
                           FROM oapdettaglio AS oapD inner join oapaziende opaA on oapD.IdOaP = opaA.IdOaPLast inner join oaptestata oapT
                            on oapd.idoap = oapT.idoap
                         WHERE opaA.idazi = '+convert(VARCHAR(30),@idazi)+' AND oapT.IdPfuDest = '+convert(VARCHAR(30),@iIdPfu)
   END 
ELSE
   BEGIN
       SET @vRecordset = 'SELECT oapD.TipoRiga,oapD.IdOaP,oapD.ArtCode,oapD.DescrArt,oapD.CodiceArtForn,
                           oapD.DataForn,oapD.Variazione,oapD.Viewed,oapT.DataOap,oapT.CodicePlant,oapT.sedidest,oapD.ViewedForn,oapD.IdMsg
                          FROM OapUtenti AS OapU,oapdettaglio AS oapD inner join oapaziende opaA on oapD.IdOaP = opaA.IdOaPLast inner join oaptestata oapT
                           on oapd.idoap = oapT.idoap
                        WHERE OapU.IdOaP=oapT.IdOaP AND opaA.idazi = '+convert(VARCHAR(30),@idazi)+' AND OapU.IdPfu='+convert(VARCHAR(30),@iIdPfu)
   END 
                  
IF @artcode <> '' 
   BEGIN
      SET @vFiltro = @vFiltro + ' AND oapD.ArtCode like '+''''+replace(replace(@ArtCode,'*','%'),'_','[_]')+'''' 
    END 
            
IF @CodiceArtForn <> '' 
   BEGIN
      SET @vFiltro = @vFiltro + ' AND oapD.CodiceArtForn like '+''''+replace(replace(@CodiceArtForn,'*','%'),'_','[_]')+''''
   END 
IF @Variazione <> '' 
   BEGIN
      SET @vFiltro = @vFiltro + ' AND oapD.Variazione = '+''''+@Variazione+''''
   END
IF @Viewed  <> '' 
   BEGIN
      SET @vFiltro = @vFiltro + 
                              case when @cContext = 'S' then ' AND oapD.ViewedForn = '+''''+@Viewed+'''' 
                                          ELSE ' AND oapD.Viewed = '+''''+@Viewed+''''
                              END       
   END 
IF @vTiporiga <> ''
      BEGIN
            set @vFiltro = @vFiltro +  ' AND oapD.Tiporiga = '+''''+@vTiporiga+''''
      END             
IF @sediDest <> '' 
   BEGIN
      SET @vRecordset = 'SELECT tot.*,xxx.descrizione,#@# FROM ('+@vRecordset+ @vFiltro+') AS tot inner join (SELECT az_struttura.Descrizione,convert(varchar(100),idaz)+''#''+path AS sedidest FROM az_struttura WHERE az_struttura.IdAz = '+
                                                      ''''+@vIdazi+''''+' AND  az_struttura.Path  = '+''''+@vPath+''''+' AND az_struttura.deleted = 0) AS  xxx
                                          on tot.sedidest = xxx.sedidest'
   END 
            
IF @SediDest = ''
   BEGIN
      SET @vRecordset = 'SELECT tot.*,xxx.descrizione,#@# FROM ('+@vRecordset+ @vFiltro+') AS tot inner join az_struttura xxx
                            on tot.sedidest = convert(varchar(100),xxx.idaz)+''#''+ Path '
   END 
      /* 
      Ordinamento risultato su recordset 
      richiesto da Zumpano in data 20020905
      */
      set @vRecordset = @vRecordset + ' ORDER BY tot.artcode,xxx.descrizione'
      /*
      Sostituzione della stringa #@# nel recordset con la variabile @vdesc
      */
      set @vRecordset = replace(@vRecordset,'#@#',@vdesc)
print @vRecordset
--EXECUTE (@vRecordset)
GO
