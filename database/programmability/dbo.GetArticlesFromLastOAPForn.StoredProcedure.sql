USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetArticlesFromLastOAPForn]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--===============================
--	CODICE STRUTTURA	=
--===============================
CREATE PROCEDURE [dbo].[GetArticlesFromLastOAPForn]
(
     @iIdPfu                 INT,
     @vArtCode               NVARCHAR(20),      
     @vCodiceForn            NVARCHAR(6),
     @vSediDest              VARCHAR(500),
     @bVariazione            VARCHAR(1),
     @bViewed                VARCHAR(1),
     @vTipoRiga              VARCHAR(20),            
     @vSuffLng               VARCHAR(5),
     @tipologiaoap           INT,       
     @AcceptedProgrammeOrder INT
)
AS
   
            
DECLARE @iVal INT 
DECLARE @vRep VARCHAR(10)
DECLARE @vDesc         VARCHAR(8000)
DECLARE @vDescOut VARCHAR(8000)
DECLARE @vFiltroOut VARCHAR(3000)
SET @iVal = 3       
SET @vFiltroOut = ''
SET @vDesc      = '(SELECT d.dsctesto FROM tipidatirange x inner join (
                          SELECT idtid FROM tipidati WHERE tidnome like ''CARTipoRiga'') y
                                        on (x.tdridtid = y.idtid AND x.tdrcodice = tot.TipoRiga AND x.tdrDeleted = 0)
                          inner join QQQ d on x.tdriddsc = d.iddsc) AS ''DescTipoRiga'''      
IF @AcceptedProgrammeOrder <>  2
        SET @vDescOut = '
        SELECT oapT.*,oapA.IdoapLast,oapA.NumeroOap,oapU.Idpfu,oapD.TipoRiga,oapD.Artcode,
          oapD.DescrArt,oapD.VariatoForn,oapD.Variazione,oapD.Viewed, oapD.AcceptedProgrammeOrder
        FROM oaptestata oapT, 
         oapAziENDe oapA, 
         oapUtenti oapU,
         oapDettaglio oapD      
          WHERE oapT.Idoap = oapU.idoap 
                AND oapA.idoapLast = oapT.Idoap AND 
                @@@
                oapT.idoap = oapD.idoap AND 
                oapU.idpfu = '+CAST(@iIdPfu AS VARCHAR(10)) +
                ' AND oapD.AcceptedProgrammeOrder = ' + CAST(@AcceptedProgrammeOrder AS VARCHAR(10))
ELSE
        SET @vDescOut = '
        SELECT oapT.*,oapA.IdoapLast,oapA.NumeroOap,oapU.Idpfu,oapD.TipoRiga,oapD.Artcode,
          oapD.DescrArt,oapD.VariatoForn,oapD.Variazione,oapD.Viewed, oapD.AcceptedProgrammeOrder
        FROM oaptestata oapT, 
         oapAziENDe oapA, 
         oapUtenti oapU,
         oapDettaglio oapD      
          WHERE oapT.Idoap = oapU.idoap 
                AND oapA.idoapLast = oapT.Idoap AND 
                @@@
                oapT.idoap = oapD.idoap AND 
                oapU.idpfu = '+CAST(@iIdPfu AS VARCHAR(10)) 
IF @vArtCode <> '' 
          BEGIN
              SET @vFiltroOut = @vFiltroOut + ' AND oapD.ArtCode = '''+@vArtCode+''''
          END 
IF @vCodiceForn <> '' 
          BEGIN
              SET @vFiltroOut = @vFiltroOut + ' AND oapT.CodiceFornitore = '''+@vCodiceForn+'''' 
          END        
IF @vSediDest <> ''
		  BEGIN
                        if @vSediDest like '%#%'
					SET @vFiltroOut = @vFiltroOut + ' and oapT.SediDest = '''+@vSediDest+''''
                        else
					SET @vFiltroOut = @vFiltroOut + ' and oapT.CodicePlant = '''+@vSediDest+''''
		  END 
IF @bVariazione <> '' 
          BEGIN
              SET @vFiltroOut = @vFiltroOut + ' AND oapD.Variazione = '''+@bVariazione+''''
          END 
IF @bViewed <> ''
          BEGIN
              SET @vFiltroOut = @vFiltroOut + ' AND oapD.Viewed = '''+@bViewed+''''
          END 
IF @vTipoRiga <> ''
          BEGIN
              SET @vFiltroOut = @vFiltroOut + ' AND oapD.TipoRiga  = '''+@vTipoRiga+''''
          END             
/* controllo */
IF (@tipologiaoap <> 2) 
  BEGIN
	SET @vDescOut = replace (@vDescOut,'@@@','')
  END
IF (@tipologiaoap = 2) 
  BEGIN
	SET @vDescOut = replace (@vDescOut,'@@@','oapA.tipologiaoap <> '+CAST(@tipologiaoap AS VARCHAR(2))+' AND oapT.tipologiaoap <> '+CAST(@tipologiaoap AS VARCHAR(2))+'  AND ')
        SET @vFiltroOut = @vFiltroOut +  ' AND oapD.Tiporiga <> '+''''+CAST(@iVal AS VARCHAR(10))+''''
  END       
/* -----------------------*/             
DECLARE @vRecordSET VARCHAR(3000)
DECLARE @vS VARCHAR(500)
DECLARE @vIdazi VARCHAR(500)
DECLARE @vPath  VARCHAR(500)      
IF @vSediDest <> ''
           BEGIN
              SET @vS = @vSediDest
              SET @vIdazi = SUBSTRING(@vS,1,PATINDEX ('%#%',@vS)-1)
              SET @vPath = SUBSTRING (@vS,PATINDEX ('%#%',@vS)+1,LEN(@vS))
           END                   
IF @vSediDest <> '' 
           BEGIN
              SET @vRecordSET = ' inner join (SELECT az_struttura.Descrizione,convert(varchar(100),idaz)+''#''+path AS sedidest FROM az_struttura WHERE az_struttura.IdAz = '+
                                            ''''+@vIdazi+''''+' AND  az_struttura.Path  = '+''''+@vPath+''''+' AND az_struttura.deleted = 0) AS  xxx
                                      on tot.sedidest = xxx.sedidest'
           END 
IF @vSediDest = ''
           BEGIN
              SET @vRecordSET = ' inner join az_struttura xxx on tot.sedidest = convert(varchar(100),xxx.idaz)+''#''+ Path '
           END       
SET @vRep = case 
                    when @vSuffLng = 'I' then 'Descsi'
                    when @vSuffLng = 'E' then 'Descse'
                    when @vSuffLng = 'UK' then 'Descsuk'
                    when @vSuffLng = 'FRA' then 'Descsfra'
                    when @vSuffLng = 'LNG1' then 'Descslng1'
                    when @vSuffLng = 'LNG2' then 'Descslng2'
                    when @vSuffLng = 'LNG3' then 'Descslng3'
                    when @vSuffLng = 'LNG4' then 'Descslng4'
                END 
SET @vDescOut = @vDescOut + @vFiltroOut
SET @vDesc = replace(@vDesc,'QQQ',@vRep)      
   SET @vDescOut = 'SELECT *,### FROM ( '+@vDescOut+') AS Tot'
                    
SET @vDescOut = replace(@vDescOut,'###',@vDesc)
SET @vDescOut = @vDescOut + @vRecordset
--print @vDescOut 
execute (@vDescOut)
GO
