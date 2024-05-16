USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetOap]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetOap] (@IdOap INT,@Lingua VARCHAR(10),@tInput ntext,@sel bit,@Selex char(1))AS
DECLARE @strSql VARCHAR(8000)
DECLARE @strSql0 VARCHAR(8000)
DECLARE @parData VARCHAR(3)
set @parData='103'
IF @Lingua<>'I'  begin
                  set @parData='101'            
            END
set @strSql0 = 'SELECT OapDettaglio.IdDett, DescrArt, ArtCode,UM, dUm.dscTesto AS DescrUM, NumOrd, Descrizione AS DescSediDest, 
                                                            Descs' + @Lingua + '.dscTesto AS DescTipoRiga,
                                                            Descs'+ @Lingua + '_S.dscTesto AS DescSottoTipoRiga, 
                                                            convert(varchar(10), DataScad, '+@parData+') AS DataScad, QO, QOXAb,
                                                            convert(varchar(10),DataXAB,'+@parData+') AS DataXAB, QOCumulataXAB, CodiceArtForn
                                                            FROM (###) AS OapDettaglio 
                                                            inner join oapDettaglioriga on OapDettaglio.iddett = oapDettaglioriga.iddett
                                                            Inner join AZ_STRUTTURA on sedidest = convert(varchar, AZ_STRUTTURA.IdAz) + ''#'' + AZ_STRUTTURA.Path
                                                            Inner join TipiDatiRange on tdrCodice = tipoRiga
                                                            Inner join DizionarioAttributi on dztIdTid = tdrIdTid
                                                            Inner join Descs' + @Lingua + ' on tdrIdDsc = IDdsc
                                                            inner join TipiDatiRange AS TipiDatiRange_S on TipiDatiRange_S.tdrCodice = OapDettaglioRiga.sottotipoRiga
                                                            inner join DizionarioAttributi AS DizionarioAttributi_S on DizionarioAttributi_S.dztIdTid = TipiDatiRange_S.tdrIdTid 
                                                            inner join Descs' + @Lingua + ' AS Descs' + @Lingua + '_S on TipiDatiRange_S.tdrIdDsc = Descs' + @Lingua + '_S.IdDsc
                                                            inner join UnitaMIsura on IdUms = UM
                                                            inner join Descs' + @Lingua + '  AS dUm on dUm.IdDsc = umsIdDscNome
                                                            WHERE DizionarioAttributi.dztNome = ''CarTipoRiga'' 
                                                            AND DizionarioAttributi_S.dztNome = ''CARSottoTipoRiga''
                                                            union 
                                                            SELECT OapDettaglio.IdDett, DescrArt, ArtCode,UM, dUm.dscTesto AS DescrUM, NumOrd, Descrizione AS DescSediDest, 
                                                            Descs' + @Lingua + '.dscTesto AS DescTipoRiga, '''' AS DescSottoTipoRiga, 
                                                            convert(varchar(10), DataScad, '+@parData+') AS DataScad, QO, QOXAb,
                                                            convert(varchar(10),DataXAB,'+@parData+') AS DataXAB, QOCumulataXAB, CodiceArtForn
                                                            FROM (###) AS OapDettaglio
                                                            inner join oapDettaglioriga on OapDettaglio.iddett = oapDettaglioriga.iddett
                                                            Inner join AZ_STRUTTURA on sedidest = convert(varchar, AZ_STRUTTURA.IdAz) + ''#'' + AZ_STRUTTURA.Path
                                                            Inner join TipiDatiRange on tdrCodice = tipoRiga
                                                            Inner join DizionarioAttributi on dztIdTid = tdrIdTid
                                                            Inner join Descs' + @Lingua + ' on tdrIdDsc = IDdsc
                                                            inner join UnitaMIsura on IdUms = UM
                                                            inner join Descs' + @Lingua + '  AS dUm on dUm.IdDsc = umsIdDscNome
                                                            WHERE DizionarioAttributi.dztNome = ''CarTipoRiga'' '
            set @strSql=
                  'SELECT v.DescrArt, v.ArtCode, v.DescrUM, v.NumOrd, v.DescSediDest, 
                  v.DescTipoRiga,
                  v.DescSottoTipoRiga, 
                  v.DataScad, v.QO, v.QOXAb,
                  v.DataXAB, v.QOCumulataXAB, v.CodiceArtForn
                  FROM 
                  (@@@) v
                  ORDER BY v.IdDett'
            IF @sel = 0
                        BEGIN
                              set @strsql = replace(@strSql,'@@@',@strsql0)
                              set @strSql =  replace(@strSql,'###','SELECT * FROM oapdettaglio WHERE IdOap =  cast('+convert(varchar(20),@IdOap)+' AS VARCHAR(20))')
                              --print (@strsql)
                              execute (@strSql)
                        END       
            IF @sel = 1 
                        BEGIN
                              DECLARE @strSQL_uno VARCHAR(8000)
                              DECLARE @strSQL_fine VARCHAR(8000)
                              set @strSQL_uno = 'SELECT v.DescrArt, v.ArtCode, v.DescrUM, v.NumOrd, v.DescSediDest, 
                                                v.DescTipoRiga,
                                                v.DescSottoTipoRiga, 
                                                v.DataScad, v.QO, v.QOXAb,
                                                v.DataXAB, v.QOCumulataXAB, v.CodiceArtForn
                                                FROM 
                                                ('
                              set @strSQL_fine = ') v ORDER BY v.IdDett'
                              DECLARE  @vcSQL1      VARCHAR(8000)
                              DECLARE  @vcSQL2      VARCHAR(8000)
                              DECLARE  @vcSQL3      VARCHAR(8000)
                              DECLARE  @vcSQL4      VARCHAR(8000)
                              DECLARE  @vcSQL5      VARCHAR(8000)
                              DECLARE  @vcSQL6      VARCHAR(8000)
                              DECLARE  @vcSQL7      VARCHAR(8000)
                              DECLARE  @vcSQL8      VARCHAR(8000)
                              DECLARE  @vcSQL9      VARCHAR(8000)
                              DECLARE  @vcSQL10      VARCHAR(8000)
                              set @vcSQL1 = ''
                              set @vcSQL2 = ''
                              set @vcSQL3 = ''
                              set @vcSQL4 = ''
                              set @vcSQL5 = ''
                              set @vcSQL6 = ''
                              set @vcSQL7 = ''
                              set @vcSQL8 = ''
                              set @vcSQL9 = ''
                              set @vcSQL10 = ''
                              DECLARE  @iNext       INT
                              SET @iNext=1
                              SET @vcSQL1=SUBSTRING(@tInput,@iNext,1500)
                              IF SUBSTRING(@tInput,1501,1)='~'
                                                         BEGIN
                                                                    SET @vcSQL1=@vcSQL1+'~'
                                                         END
                              SET @iNext=LEN(@vcSQL1)+1
                              
                              SET @vcSQL1=SUBSTRING(@vcSQL1,3,LEN(@vcSQL1)-2)
                              SET @vcSQL1=REPLACE(@vcSQL1,'#~',')) OR (IdOaP=')
                              SET @vcSQL1=REPLACE(@vcSQL1,'#',' AND ArtCode IN (')
                              
                              IF @iNext>DATALENGTH(@tInput) 
                                                         BEGIN
                                                            SET @vcSQL1=' (IdOaP='+SUBSTRING(@vcSQL1,1,LEN(@vcSQL1)-13)+'))'
                                                            GOTO LAB
                                                         END
                              SET @vcSQL1=' (IdOaP='+@vcSQL1
                              --vcSQL2
                              SET @vcSQL2=SUBSTRING(@tInput,@iNext,1500)
                              IF SUBSTRING(@tInput,@iNext+1500,1)='~'
                                                         BEGIN
                                                              SET @vcSQL2=@vcSQL2+'~'
                                                         END
                              SET @iNext=@iNext+LEN(@vcSQL2)--+1
                              SET @vcSQL2=REPLACE(@vcSQL2,'#~',')) OR (IdOaP=')
                              SET @vcSQL2=REPLACE(@vcSQL2,'#',' AND ArtCode IN (')
                              IF @iNext>DATALENGTH(@tInput) 
                                                   BEGIN
                                                      SET @vcSQL2=SUBSTRING(@vcSQL2,1,LEN(@vcSQL2)-13)+'))'
                                                      GOTO LAB
                                                   END
                              --vcSQL3
                              SET @vcSQL3=SUBSTRING(@tInput,@iNext,1500)
                              IF SUBSTRING(@tInput,@iNext+1500,1)='~'
                                                   BEGIN
                                                        SET @vcSQL3=@vcSQL3+'~'
                                                   END
                              SET @iNext=@iNext+LEN(@vcSQL3)
                              SET @vcSQL3=REPLACE(@vcSQL3,'#~',')) OR (IdOaP=')
                              SET @vcSQL3=REPLACE(@vcSQL3,'#',' AND ArtCode IN (')+'))'
                              IF @iNext>DATALENGTH(@tInput) 
                                                   BEGIN
                                                      SET @vcSQL3=SUBSTRING(@vcSQL3,1,LEN(@vcSQL3)-13)
                                                      GOTO LAB
                                                   END      
                              --vcSQL4
      
                              SET @vcSQL4=SUBSTRING(@tInput,@iNext,1500)
            
                              IF SUBSTRING(@tInput,@iNext+1500,1)='~'
                                                   BEGIN
                                                              SET @vcSQL4=@vcSQL4+'~'
                                                   END
                              SET @iNext=@iNext+LEN(@vcSQL4)
                              SET @vcSQL4=REPLACE(@vcSQL4,'#~',')) OR (IdOaP=')
                              SET @vcSQL4=REPLACE(@vcSQL4,'#',' AND ArtCode IN (')
                              IF @iNext>DATALENGTH(@tInput) 
                                                   BEGIN
                                                      SET @vcSQL4=SUBSTRING(@vcSQL4,1,LEN(@vcSQL4)-13)+'))'
                                                      GOTO LAB
                                                   END
                              --vcSQL5
                              SET @vcSQL5=SUBSTRING(@tInput,@iNext,1500)
                              IF SUBSTRING(@tInput,@iNext+1500,1)='~'
                                                   BEGIN
                                                        SET @vcSQL5=@vcSQL5+'~'
                                                   END
                              SET @iNext=@iNext+LEN(@vcSQL5)
                              SET @vcSQL5=REPLACE(@vcSQL5,'#~',')) OR (IdOaP=')
                              SET @vcSQL5=REPLACE(@vcSQL5,'#',' AND ArtCode IN (')
                              IF @iNext>DATALENGTH(@tInput) 
                                                   BEGIN
                                                      SET @vcSQL5=SUBSTRING(@vcSQL5,1,LEN(@vcSQL5)-13)+'))'
                                                      GOTO LAB
                                                   END
                              --vcSQL6
                              SET @vcSQL6=SUBSTRING(@tInput,@iNext,1500)
      
                              IF SUBSTRING(@tInput,@iNext+1500,1)='~'
                                                   BEGIN
                                                         SET @vcSQL6=@vcSQL6+'~'
                                                   END
                              SET @iNext=@iNext+LEN(@vcSQL6)
                              SET @vcSQL6=REPLACE(@vcSQL6,'#~',')) OR (IdOaP=')
                              SET @vcSQL6=REPLACE(@vcSQL6,'#',' AND ArtCode IN (')
                              IF @iNext>DATALENGTH(@tInput) 
                                                   BEGIN
                                                      SET @vcSQL6=SUBSTRING(@vcSQL6,1,LEN(@vcSQL6)-13)+'))'
                                                      GOTO LAB
                                                   END
                              --vcSQL7
      
                              SET @vcSQL7=SUBSTRING(@tInput,@iNext,1500)
      
                              IF SUBSTRING(@tInput,@iNext+1500,1)='~'
                                                   BEGIN
                                                        SET @vcSQL7=@vcSQL7+'~'
                                                   END
                              SET @iNext=@iNext+LEN(@vcSQL7)
                              SET @vcSQL7=REPLACE(@vcSQL7,'#~',')) OR (IdOaP=')
                              SET @vcSQL7=REPLACE(@vcSQL7,'#',' AND ArtCode IN (')
                              IF @iNext>DATALENGTH(@tInput) 
                                                   BEGIN
                                                      SET @vcSQL7=SUBSTRING(@vcSQL7,1,LEN(@vcSQL7)-13)+'))'
                                                      GOTO LAB
                                                   END
                              --vcSQL8
                              SET @vcSQL8=SUBSTRING(@tInput,@iNext,1500)
                              IF SUBSTRING(@tInput,@iNext+1500,1)='~'
                                                   BEGIN
                                                              SET @vcSQL8=@vcSQL8+'~'
                                                   END
                              SET @iNext=@iNext+LEN(@vcSQL8)
                              SET @vcSQL8=REPLACE(@vcSQL8,'#~',')) OR (IdOaP=')
                              SET @vcSQL8=REPLACE(@vcSQL8,'#',' AND ArtCode IN (')
                              IF @iNext>DATALENGTH(@tInput) 
                                 BEGIN
                                    SET @vcSQL8=SUBSTRING(@vcSQL8,1,LEN(@vcSQL8)-13)+'))'
                                    GOTO LAB
                                END
                              --vcSQL9
                              SET @vcSQL9=SUBSTRING(@tInput,@iNext,1500)
                              IF SUBSTRING(@tInput,@iNext+1500,1)='~'
                                BEGIN
                                      SET @vcSQL9=@vcSQL9+'~'
                                END
                              SET @iNext=@iNext+LEN(@vcSQL9)
                              SET @vcSQL9=REPLACE(@vcSQL9,'#~',')) OR (IdOaP=')
                              SET @vcSQL9=REPLACE(@vcSQL9,'#',' AND ArtCode IN (')
                              IF @iNext>DATALENGTH(@tInput) 
                                       BEGIN
                                          SET @vcSQL9=SUBSTRING(@vcSQL9,1,LEN(@vcSQL9)-13)+'))'
                                          GOTO LAB
                                       END
                              --vcSQL10
                              SET @vcSQL10=SUBSTRING(@tInput,@iNext,1500)
                              IF SUBSTRING(@tInput,@iNext+1500,1)='~'
                                       BEGIN
                                            SET @vcSQL10=@vcSQL10+'~'
                                       END
                              SET @iNext=@iNext+LEN(@vcSQL10)
                              SET @vcSQL10=REPLACE(@vcSQL10,'#~',')) OR (IdOaP=')
                              SET @vcSQL10=REPLACE(@vcSQL10,'#',' AND ArtCode IN (')
                              IF @iNext>DATALENGTH(@tInput) 
                                                   BEGIN
                                                      SET @vcSQL10=SUBSTRING(@vcSQL10,1,LEN(@vcSQL10)-13)+'))'
                                                      GOTO LAB
                                                   END      
                              RAISERROR ('Errore: Filtro troppo lungo - Contattare DBA - (GetPlanningWithPlant) ', 16, 1) 
                              RETURN 99
                        LAB:      
                              DECLARE @strSql1 VARCHAR(8000)
                              DECLARE @strSql2 VARCHAR(8000)
                              DECLARE @strSql3 VARCHAR(8000)
                              IF @selex not in ('S','B')  
                                          BEGIN
                                                      raiserror ('Errore parametro @selex deve essere o S o B',16,1)
                                                      rollback tran
                                                      return 
                                          END 
                                          
                              IF @selex = 'B'
                                          BEGIN
                                                      set @strSql1 = 'SELECT OapDettaglio.IdDett,OapDettaglio.Variazione,OapDettaglio.ViewedBuyer,OapDettaglio.Viewed,DescrArt, ArtCode,UM, dUm.dscTesto AS DescrUM, NumOrd, Descrizione AS DescSediDest, 
                                                      Descs' + @Lingua + '.dscTesto AS DescTipoRiga,
                                                      Descs'+ @Lingua + '_S.dscTesto AS DescSottoTipoRiga, 
                                                      convert(varchar(10), DataScad, '+@parData+') AS DataScad, QO, QOXAb,
                                                      convert(varchar(10),DataXAB,'+@parData+') AS DataXAB, QOCumulataXAB, CodiceArtForn
                                                      FROM (SELECT * FROM oapdettaglio WHERE '                                                
                                          END 
                              ELSE IF @selex = 'S'
                                          BEGIN
                                                      set @strSql1 = 'SELECT OapDettaglio.IdDett,OapDettaglio.Variazione,OapDettaglio.Viewed,DescrArt, ArtCode,UM, dUm.dscTesto AS DescrUM, NumOrd, Descrizione AS DescSediDest, 
                                                      Descs' + @Lingua + '.dscTesto AS DescTipoRiga,
                                                      Descs'+ @Lingua + '_S.dscTesto AS DescSottoTipoRiga, 
                                                      convert(varchar(10), DataScad, '+@parData+') AS DataScad, QO, QOXAb,
                                                      convert(varchar(10),DataXAB,'+@parData+') AS DataXAB, QOCumulataXAB, CodiceArtForn
                                                      FROM (SELECT * FROM oapdettaglio WHERE '                  
                                          END  
                                          
                              set @strSQl2 =       ') AS OapDettaglio 
                                                            inner join oapDettaglioriga on OapDettaglio.iddett = oapDettaglioriga.iddett
                                                            Inner join AZ_STRUTTURA on sedidest = convert(varchar, AZ_STRUTTURA.IdAz) + ''#'' + AZ_STRUTTURA.Path
                                                            Inner join TipiDatiRange on tdrCodice = tipoRiga
                                                            Inner join DizionarioAttributi on dztIdTid = tdrIdTid
                                                            Inner join Descs' + @Lingua + ' on tdrIdDsc = IDdsc
                                                            inner join TipiDatiRange AS TipiDatiRange_S on TipiDatiRange_S.tdrCodice = OapDettaglioRiga.sottotipoRiga
                                                            inner join DizionarioAttributi AS DizionarioAttributi_S on DizionarioAttributi_S.dztIdTid = TipiDatiRange_S.tdrIdTid 
                                                            inner join Descs' + @Lingua + ' AS Descs' + @Lingua + '_S on TipiDatiRange_S.tdrIdDsc = Descs' + @Lingua + '_S.IdDsc
                                                            inner join UnitaMIsura on IdUms = UM
                                                            inner join Descs' + @Lingua + '  AS dUm on dUm.IdDsc = umsIdDscNome
                                                            WHERE DizionarioAttributi.dztNome = ''CarTipoRiga'' 
                                                            AND DizionarioAttributi_S.dztNome = ''CARSottoTipoRiga''
                                                            union 
                                                            SELECT OapDettaglio.IdDett, DescrArt, ArtCode,UM, dUm.dscTesto AS DescrUM, NumOrd, Descrizione AS DescSediDest, 
                                                            Descs' + @Lingua + '.dscTesto AS DescTipoRiga, '''' AS DescSottoTipoRiga, 
                                                            convert(varchar(10), DataScad, '+@parData+') AS DataScad, QO, QOXAb,
                                                            convert(varchar(10),DataXAB,'+@parData+') AS DataXAB, QOCumulataXAB, CodiceArtForn
                                                            FROM (SELECT * FROM oapdettaglio WHERE '
                              set @strSQL3 = ') AS OapDettaglio
                                                            inner join oapDettaglioriga on OapDettaglio.iddett = oapDettaglioriga.iddett
                                                            Inner join AZ_STRUTTURA on sedidest = convert(varchar, AZ_STRUTTURA.IdAz) + ''#'' + AZ_STRUTTURA.Path
                                                            Inner join TipiDatiRange on tdrCodice = tipoRiga
                                                            Inner join DizionarioAttributi on dztIdTid = tdrIdTid
                                                            Inner join Descs' + @Lingua + ' on tdrIdDsc = IDdsc
                                                            inner join UnitaMIsura on IdUms = UM
                                                            inner join Descs' + @Lingua + '  AS dUm on dUm.IdDsc = umsIdDscNome
                                                            WHERE DizionarioAttributi.dztNome = ''CarTipoRiga'' '
                              
                              
                              --set @strsql = replace(@strSql,'@@@',@strsql1)
                              IF (@vcSQL1 <> '' AND @vcSQL2 = '')
                                                      BEGIN
                                                            execute (@strSQL_uno+@strSQL1+@vcSQL1+@strSQL2+@vcSQL1+@strSQL3+@strSQL_fine)
                                                      END 
                              ELSE IF (@vcSQL1 <> '' AND @vcSQL2 <> '' AND @vcSQL3 = '')
                                                      BEGIN
                                                            execute (@strSQL_uno+@strSQL1+@vcSQL1+@vcSQL2+@strSQL2+@vcSQL1+@vcSQL2+@strSQL3+@strSQL_fine)                        
                                                      END       
                              ELSE IF (@vcSQL1 <> '' AND @vcSQL2 <> '' AND @vcSQL3 <> '' AND @vcSQL4 = '')
                                                      BEGIN
                                                            execute (@strSQL_uno+@strSQL1+@vcSQL1+@vcSQL2+@vcSQL3+@strSQL2+@vcSQL1+@vcSQL2+@vcSQL3+@strSQL3+@strSQL_fine)
                                                      END 
                              ELSE IF (@vcSQL1 <> '' AND @vcSQL2 <> '' AND @vcSQL3 <> '' AND @vcSQL4 <> '' AND @vcSQL5 = '')
                                                      BEGIN
                                                            execute (@strSQL_uno+@strSQL1+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@strSQL2+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@strSQL3+@strSQL_fine)
                                                      END 
                              ELSE IF (@vcSQL1 <> '' AND @vcSQL2 <> '' AND @vcSQL3 <> '' AND @vcSQL4 <> '' AND @vcSQL5 <> '' AND @vcSQL6 = '')
                                                      BEGIN
                                                            execute (@strSQL_uno+@strSQL1+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@strSQL2+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@strSQL3+@strSQL_fine)
                                                      END 
                              ELSE IF (@vcSQL1 <> '' AND @vcSQL2 <> '' AND @vcSQL3 <> '' AND @vcSQL4 <> '' AND @vcSQL5 <> '' AND @vcSQL6 <> '' AND @vcsql7 = '')
                                                      BEGIN
                                                            execute (@strSQL_uno+@strSQL1+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@strSQL2+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@strSQL3+@strSQL_fine)
                                                      END 
                              ELSE IF (@vcSQL1 <> '' AND @vcSQL2 <> '' AND @vcSQL3 <> '' AND @vcSQL4 <> '' AND @vcSQL5 <> '' AND @vcSQL6 <> '' AND @vcsql7 <> '' AND @vcsql8 = '')
                                                      BEGIN      
                                                            execute (@strSQL_uno+@strSQL1+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@strSQL2+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@strSQL3+@strSQL_fine)
                                                      END 
                              ELSE IF (@vcSQL1 <> '' AND @vcSQL2 <> '' AND @vcSQL3 <> '' AND @vcSQL4 <> '' AND @vcSQL5 <> '' AND @vcSQL6 <> '' AND @vcsql7 <> '' AND @vcsql8 <> '' AND @vcsql9 = '')
                                                      BEGIN
                                                            execute (@strSQL_uno+@strSQL1+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@vcSQL8+@strSQL2+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@vcSQL8+@strSQL3+@strSQL_fine)
                                                      END 
                              ELSE IF (@vcSQL1 <> '' AND @vcSQL2 <> '' AND @vcSQL3 <> '' AND @vcSQL4 <> '' AND @vcSQL5 <> '' AND @vcSQL6 <> '' AND @vcsql7 <> '' AND @vcsql8 <> '' AND @vcsql9 <> '' AND @vcSQL10 = '')
                                                      BEGIN
                                                            execute (@strSQL_uno+@strSQL1+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@vcSQL8+@vcSQL9+@strSQL2+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@vcSQL8+@vcSQL9+@strSQL3+@strSQL_fine)
                                                      END
                              ELSE IF (@vcSQL1 <> '' AND @vcSQL2 <> '' AND @vcSQL3 <> '' AND @vcSQL4 <> '' AND @vcSQL5 <> '' AND @vcSQL6 <> '' AND @vcsql7 <> '' AND @vcsql8 <> '' AND @vcsql9 <> '' AND @vcSQL10 <> '')
                                                      BEGIN
                                                            execute (@strSQL_uno+@strSQL1+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@vcSQL8+@vcSQL9+@vcSQL10+@strSQL2+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@vcSQL8+@vcSQL9+@vcSQL10+@strSQL3+@strSQL_fine)
                                                      END 
                              /*
                              DECLARE @x VARCHAR(8000)
                              
                              SELECT  case 
                                          when (@vcSQL1 <> '' AND @vcSQL2 = '') then @strSQL_uno+@strSQL1+@vcSQL1+@strSQL2+@vcSQL1+@strSQL3+@strSQL_fine
                                          when (@vcSQL1 <> '' AND @vcSQL2 <> '' AND @vcSQL3 = '') then @strSQL_uno+@strSQL1+@vcSQL1+@vcSQL2+@strSQL2+@vcSQL1+@vcSQL2+@strSQL3+@strSQL_fine
                                          when (@vcSQL1 <> '' AND @vcSQL2 <> '' AND @vcSQL3 <> '' AND @vcSQL4 = '') then @strSQL_uno+@strSQL1+@vcSQL1+@vcSQL2+@vcSQL3+@strSQL2+@vcSQL1+@vcSQL2+@vcSQL3+@strSQL3+@strSQL_fine
                                          when (@vcSQL1 <> '' AND @vcSQL2 <> '' AND @vcSQL3 <> '' AND @vcSQL4 <> '' AND @vcSQL5 = '') then @strSQL_uno+@strSQL1+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@strSQL2+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@strSQL3+@strSQL_fine
                                          when (@vcSQL1 <> '' AND @vcSQL2 <> '' AND @vcSQL3 <> '' AND @vcSQL4 <> '' AND @vcSQL5 <> '' AND @vcSQL6 = '') then @strSQL_uno+@strSQL1+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@strSQL2+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@strSQL3+@strSQL_fine
                                          when (@vcSQL1 <> '' AND @vcSQL2 <> '' AND @vcSQL3 <> '' AND @vcSQL4 <> '' AND @vcSQL5 <> '' AND @vcSQL6 <> '' AND @vcsql7 = '') then @strSQL_uno+@strSQL1+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@strSQL2+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@strSQL3+@strSQL_fine
                                          when (@vcSQL1 <> '' AND @vcSQL2 <> '' AND @vcSQL3 <> '' AND @vcSQL4 <> '' AND @vcSQL5 <> '' AND @vcSQL6 <> '' AND @vcsql7 <> '' AND @vcsql8 = '') then @strSQL_uno+@strSQL1+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@strSQL2+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@strSQL3+@strSQL_fine
                                          when (@vcSQL1 <> '' AND @vcSQL2 <> '' AND @vcSQL3 <> '' AND @vcSQL4 <> '' AND @vcSQL5 <> '' AND @vcSQL6 <> '' AND @vcsql7 <> '' AND @vcsql8 <> '' AND @vcsql9 = '') then @strSQL_uno+@strSQL1+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@vcSQL8+@strSQL2+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@vcSQL8+@strSQL3+@strSQL_fine
                                          when (@vcSQL1 <> '' AND @vcSQL2 <> '' AND @vcSQL3 <> '' AND @vcSQL4 <> '' AND @vcSQL5 <> '' AND @vcSQL6 <> '' AND @vcsql7 <> '' AND @vcsql8 <> '' AND @vcsql9 <> '' AND @vcSQL10 = '') then @strSQL_uno+@strSQL1+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@vcSQL8+@vcSQL9+@strSQL2+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@vcSQL8+@vcSQL9+@strSQL3+@strSQL_fine
                                          when (@vcSQL1 <> '' AND @vcSQL2 <> '' AND @vcSQL3 <> '' AND @vcSQL4 <> '' AND @vcSQL5 <> '' AND @vcSQL6 <> '' AND @vcsql7 <> '' AND @vcsql8 <> '' AND @vcsql9 <> '' AND @vcSQL10 <> '') then @strSQL_uno+@strSQL1+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@vcSQL8+@vcSQL9+@vcSQL10+@strSQL2+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@vcSQL8+@vcSQL9+@vcSQL10+@strSQL3+@strSQL_fine
                                    END 
                              */
                              --print (@x)                                                            
                              --execute (@x)      
                              --print @vcSQL1
                              --print @vcSQL2
                              --print @vcSQL3
                              --print @vcSQL4
                              --print @vcSQL5
                              --print @vcSQL6
                              --print @vcSQL7
                              --print @vcSQL8
                              --print @vcSQL9
                              --print @vcSQL10
                  END             
--exec (@strSql)
GO
