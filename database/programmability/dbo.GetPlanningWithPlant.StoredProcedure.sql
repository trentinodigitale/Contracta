USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetPlanningWithPlant]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--===============================
--	CODICE STRUTTURA	=
--===============================
CREATE PROCEDURE [dbo].[GetPlanningWithPlant]( @tInput NTEXT, @vcInsForn VARCHAR(5), @vcLng VARCHAR(5))
AS
 
DECLARE  @vcSQLProd       NVARCHAR(4000) --contiene la parte iniziale del sql dinamico generale
DECLARE  @vcSQLProd1      NVARCHAR(4000) --contiene la parte iniziale del sql dinamico per dataScad
DECLARE  @vcSQLProdProp   NVARCHAR(4000) 
DECLARE  @vcSQLProd1Prop  NVARCHAR(4000) 
--Vengono utilizzate per la costruzione dei filtri partendo dal parametro @tInput.
DECLARE  @vcSQL1            NVARCHAR(4000)
DECLARE  @vcSQL2            NVARCHAR(4000)
DECLARE  @vcSQL3            NVARCHAR(4000)
DECLARE  @vcSQL4            NVARCHAR(4000)
DECLARE  @vcSQL5            NVARCHAR(4000)
DECLARE  @vcSQL6            NVARCHAR(4000)
DECLARE  @vcSQL7            NVARCHAR(4000)
DECLARE  @vcSQL8            NVARCHAR(4000)
DECLARE  @vcSQL9            NVARCHAR(4000)
DECLARE  @vcSQL10           NVARCHAR(4000)
DECLARE  @vcSQL1Prop        NVARCHAR(4000)
DECLARE  @vcSQL2Prop        NVARCHAR(4000)
DECLARE  @vcSQL3Prop        NVARCHAR(4000)
DECLARE  @vcSQL4Prop        NVARCHAR(4000)
DECLARE  @vcSQL5Prop        NVARCHAR(4000)
DECLARE  @vcSQL6Prop        NVARCHAR(4000)
DECLARE  @vcSQL7Prop        NVARCHAR(4000)
DECLARE  @vcSQL8Prop        NVARCHAR(4000)
DECLARE  @vcSQL9Prop        NVARCHAR(4000)
DECLARE  @vcSQL10Prop       NVARCHAR(4000)
/* 
PER AMPLIARE I FILTRI:
1) dichiare una nuova stringa 
DECLARE  @vcSQLn       VARCHAR(8000)
SET  @vcSQL5n=''
2)Aggiungere (prima della RaiseError) e correggere oppurtunamente il codice seguente
--vcSQLn
SET @vcSQLn=SUBSTRING(@tInput,@iNext,1500)
IF SUBSTRING(@tInput,@iNext+1500,1)='~'
   BEGIN
                 SET @vcSQLn=@vcSQLn+'~'
   END
SET @iNext=@iNext+LEN(@vcSQLn)
SET @vcSQLn=REPLACE(@vcSQLn,'#~',')) OR (a.IdOaP=')
SET @vcSQLn=REPLACE(@vcSQLn,'#',' AND a.ArtCode IN (')
IF @iNext>DATALENGTH(@tInput) / 2
   BEGIN
      SET @vcSQLn=SUBSTRING(@vcSQLn,1,LEN(@vcSQLn)-13)
      GOTO LAB
   END
3) Aggiungere la nuova stringa @vcSQLn nella esecuzione del SQL dinamico
--@vcSQLProd1
EXECUTE (@vcSQLProd1+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@vcSQL8+@vcSQL9+@vcSQL10+   @vcSQLn  +') ORDER BY  b.DataScad ')
--@vcSQLProd
EXECUTE (@vcSQLProd+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@vcSQL8+@vcSQL9+@vcSQL10+   @vcSQLn  +') ORDER BY a.IdOaP, a.ArtCode, a.SediDest ')
*/
--contatore sul parametro @tInput
DECLARE  @iNext       INT
SET  @vcSQL1=''
SET  @vcSQL2=''
SET  @vcSQL3=''
SET  @vcSQL4=''
SET  @vcSQL5=''
SET  @vcSQL1Prop=''
SET  @vcSQL2Prop=''
SET  @vcSQL3Prop=''
SET  @vcSQL4Prop=''
SET  @vcSQL5Prop=''
--generale
SET @vcSQLProd='SELECT a.IdOaP,a.ArtCode,b.DataScad,d.CodicePlant,d.Protocol,s.Descrizione AS DescPlantTestata, d.DataOAP,
                       a.IdDett,a.IdMsg,a.DescrArt,a.UM,dsc.dscTesto AS dscUM,c.Descrizione,a.TipoRiga,a.QOXAB,
                       a.DataXAB,a.QOCumulataXAB,a.CodiceArtForn,a.DataForn,a.Variazione,a.NumXAB,a.Viewed,
                       a.ViewedBuyer,a.ViewedForn, b.IdDettRig,b.NumOrd,b.SottoTipoRiga,b.QO,b.Modify,b.QTAOrdPrec,
                       b.SottoTipoRigaOrdPrec,b.QtaProgCons,b.DataScadProp,b.QOProp,b.QtaProgConsProp,b.Send,b.InsForn,
                       b.PrevisionalDateCrudeDelivery,b.EffectiveDateCrudeDelivery,b.EffectiveQtyCrudeDelivery,
                       a.SediDest,d.CodiceFornitore,a.VariatoForn, a.CodOperFase, a.Fase,a.PeriodoTipologia,
                       a.ResidualOrderQuantity , b.PlannedDeliveryDate, a.AcceptedProgrammeOrder
                  FROM OAPDettaglio a 
                 RIGHT OUTER JOIN UnitaMisura um ON a.UM=um.IdUms, OAPDettaglioRiga b,
                       AZ_STRUTTURA c,OapTestata d, Descs'+@vcLng+' dsc,
                       AZ_STRUTTURA s 
                 WHERE umsDeleted=0 
                   AND um.umsIdDscNome=dsc.IdDsc 
                   AND a.IdDett=b.IdDett 
                   AND a.SediDest=CAST(c.IdAz AS VARCHAR(20))+''#''+c.Path 
                   AND a.IdOap=d.IdOap AND d.SediDest=CAST(s.IdAz AS VARCHAR(20))+''#''+s.Path ' 
IF @vcInsForn = '-2'
SET @vcSQLProdProp = 'SELECT (a.IdOaP * -1 ) as IdOap,a.ArtCode, DataScadProp AS DataScad,d.CodicePlant,d.Protocol,s.Descrizione AS DescPlantTestata, d.DataOAP,
                       a.IdDett,a.IdMsg,a.DescrArt,a.UM,dsc.dscTesto AS dscUM,c.Descrizione, (TipoRiga * -1) AS TipoRiga,a.QOXAB,
                       a.DataXAB,a.QOCumulataXAB,a.CodiceArtForn,a.DataForn,a.Variazione,a.NumXAB,a.Viewed,
                       a.ViewedBuyer,a.ViewedForn, b.IdDettRig,b.NumOrd,b.SottoTipoRiga,b.QOProp AS QO,b.Modify,b.QTAOrdPrec,
                       b.SottoTipoRigaOrdPrec,b.QtaProgCons,b.DataScadProp,b.QOProp,b.QtaProgConsProp,b.Send,b.InsForn,
                       b.PrevisionalDateCrudeDelivery,b.EffectiveDateCrudeDelivery,b.EffectiveQtyCrudeDelivery,
                       a.SediDest,d.CodiceFornitore,a.VariatoForn, a.CodOperFase, a.Fase,a.PeriodoTipologia,
                       a.ResidualOrderQuantity , b.PlannedDeliveryDate, a.AcceptedProgrammeOrder
                  FROM OAPDettaglio a 
                 RIGHT OUTER JOIN UnitaMisura um ON a.UM=um.IdUms, OAPDettaglioRiga b,
                       AZ_STRUTTURA c,OapTestata d, Descs'+@vcLng+' dsc,
                       AZ_STRUTTURA s 
                 WHERE umsDeleted=0 
                   AND a.IdOap IN (SELECT IdOAPLast FROM OAPAziende)
                   AND a.variatoforn in (''11'', ''10'', ''1'')
                   AND um.umsIdDscNome=dsc.IdDsc 
                   AND a.IdDett=b.IdDett 
                   AND a.SediDest=CAST(c.IdAz AS VARCHAR(20))+''#''+c.Path 
                   AND a.IdOap=d.IdOap AND d.SediDest=CAST(s.IdAz AS VARCHAR(20))+''#''+s.Path ' 
ELSE
IF @vcInsForn = '-1'
SET @vcSQLProdProp = 'SELECT (a.IdOaP * -1 ) as IdOap,a.ArtCode, DataScadProp AS DataScad,d.CodicePlant,d.Protocol,s.Descrizione AS DescPlantTestata,  d.DataOAP,
                       a.IdDett,a.IdMsg,a.DescrArt,a.UM,dsc.dscTesto AS dscUM,c.Descrizione, (TipoRiga * -1) AS TipoRiga,a.QOXAB,
                       a.DataXAB,a.QOCumulataXAB,a.CodiceArtForn,a.DataForn,a.Variazione,a.NumXAB,a.Viewed,
                       a.ViewedBuyer,a.ViewedForn, b.IdDettRig,b.NumOrd,b.SottoTipoRiga,b.QOProp AS QO,b.Modify,b.QTAOrdPrec,
                       b.SottoTipoRigaOrdPrec,b.QtaProgCons,b.DataScadProp,b.QOProp,b.QtaProgConsProp,b.Send,b.InsForn,
                       b.PrevisionalDateCrudeDelivery,b.EffectiveDateCrudeDelivery,b.EffectiveQtyCrudeDelivery,
                       a.SediDest,d.CodiceFornitore,a.VariatoForn, a.CodOperFase, a.Fase,a.PeriodoTipologia,
                       a.ResidualOrderQuantity , b.PlannedDeliveryDate, a.AcceptedProgrammeOrder
                  FROM OAPDettaglio a 
                 RIGHT OUTER JOIN UnitaMisura um ON a.UM=um.IdUms, OAPDettaglioRiga b,
                       AZ_STRUTTURA c,OapTestata d, Descs'+@vcLng+' dsc,
                       AZ_STRUTTURA s 
                 WHERE umsDeleted=0 
                   AND a.IdOap IN (SELECT IdOAPLast FROM OAPAziende)
                   AND a.variatoforn in (''10'', ''1'')
                   AND um.umsIdDscNome=dsc.IdDsc 
                   AND a.IdDett=b.IdDett 
                   AND a.SediDest=CAST(c.IdAz AS VARCHAR(20))+''#''+c.Path 
                   AND a.IdOap=d.IdOap AND d.SediDest=CAST(s.IdAz AS VARCHAR(20))+''#''+s.Path ' 
SET @vcSQLProd=@vcSQLProd+CASE @vcInsForn   
                               WHEN '0' THEN ' AND b.InsForn = 0 '
                               WHEN '1' THEN ' AND b.InsForn = 1 '
                               ELSE ' '      
                         END
SET @vcSQLProd=@vcSQLProd        +' AND ( '
SET @vcSQLProdProp=@vcSQLProdProp+' AND ( '
--solo data
SET @vcSQLProd1='SELECT DISTINCT b.DataScad   FROM OAPDettaglio a RIGHT OUTER JOIN UnitaMisura um ON a.UM=um.IdUms, OAPDettaglioRiga b,AZ_STRUTTURA c,OapTestata d, Descs'+@vcLng+' dsc,AZ_STRUTTURA s WHERE umsDeleted=0 AND um.umsIdDscNome=dsc.IdDsc AND a.IdDett=b.IdDett AND a.SediDest=CAST(c.IdAz AS VARCHAR(20))+''#''+c.Path AND a.IdOap=d.IdOap AND d.SediDest=CAST(s.IdAz AS VARCHAR(20))+''#''+s.Path ' 
IF @vcInsForn = '-2'
SET @vcSQLProd1Prop= 'SELECT DISTINCT b.DataScadProp   
                        FROM OAPDettaglio a 
                      RIGHT OUTER JOIN UnitaMisura um ON a.UM=um.IdUms, OAPDettaglioRiga b,AZ_STRUTTURA c,OapTestata d, 
                                       Descs'+@vcLng+' dsc,AZ_STRUTTURA s 
                       WHERE umsDeleted=0 
                         AND um.umsIdDscNome=dsc.IdDsc 
                         AND a.variatoforn in (''11'', ''10'', ''1'')
                         AND a.IdOap IN (SELECT IdOAPLast FROM OAPAziende)
                         AND a.IdDett=b.IdDett 
                         AND a.SediDest=CAST(c.IdAz AS VARCHAR(20))+''#''+c.Path 
                         AND a.IdOap=d.IdOap AND d.SediDest=CAST(s.IdAz AS VARCHAR(20))+''#''+s.Path ' 
ELSE
IF @vcInsForn = '-1'
SET @vcSQLProd1Prop= 'SELECT DISTINCT b.DataScadProp   
                        FROM OAPDettaglio a 
                      RIGHT OUTER JOIN UnitaMisura um ON a.UM=um.IdUms, OAPDettaglioRiga b,AZ_STRUTTURA c,OapTestata d, 
                                       Descs'+@vcLng+' dsc,AZ_STRUTTURA s 
                       WHERE umsDeleted=0 
                         AND um.umsIdDscNome=dsc.IdDsc 
                         AND a.variatoforn in (''10'', ''1'')
                         AND a.IdOap IN (SELECT IdOAPLast FROM OAPAziende)
                         AND a.IdDett=b.IdDett 
                         AND a.SediDest=CAST(c.IdAz AS VARCHAR(20))+''#''+c.Path 
                         AND a.IdOap=d.IdOap AND d.SediDest=CAST(s.IdAz AS VARCHAR(20))+''#''+s.Path ' 
SET @vcSQLProd1=@vcSQLProd1+CASE @vcInsForn   WHEN '0' THEN ' AND b.InsForn = 0 '
                                      WHEN '1' THEN ' AND b.InsForn = 1 '
                                    ELSE ' '      
                      END
SET @vcSQLProd1    = @vcSQLProd1     + ' AND ( '
SET @vcSQLProd1Prop= @vcSQLProd1Prop + ' AND ( '
                                           
--vcSQL1
SET @iNext=1
SET @vcSQL1=SUBSTRING(@tInput,@iNext,1500)
IF SUBSTRING(@tInput,1501,1)='~'
   BEGIN
        SET @vcSQL1=@vcSQL1+'~'
   END
SET @iNext=LEN(@vcSQL1)+1
SET @vcSQL1=SUBSTRING(@vcSQL1,3,LEN(@vcSQL1)-2)
SET @vcSQL1=REPLACE(@vcSQL1,'#~',')) OR (a.IdOaP=')
SET @vcSQL1=REPLACE(@vcSQL1,'#',' AND a.ArtCode IN (')
IF @iNext>DATALENGTH(@tInput)  / 2
   BEGIN
      SET @vcSQL1=' (a.IdOaP='+SUBSTRING(@vcSQL1,1,LEN(@vcSQL1)-13)
      --SET @vcSQL1Prop = REPLACE (@vcSQL1, 'a.IdOaP', '(a.IdOaP * -1)')
      GOTO LAB
   END
SET @vcSQL1=' (a.IdOaP='+@vcSQL1
SET @vcSQL1Prop = REPLACE (@vcSQL1, 'a.IdOaP', '(a.IdOaP * -1)')
--vcSQL2
SET @vcSQL2=SUBSTRING(@tInput,@iNext,1500)
IF SUBSTRING(@tInput,@iNext+1500,1)='~'
   BEGIN
        SET @vcSQL2=@vcSQL2+'~'
   END
SET @iNext=@iNext+LEN(@vcSQL2)--+1
SET @vcSQL2=REPLACE(@vcSQL2,'#~',')) OR (a.IdOaP=')
SET @vcSQL2=REPLACE(@vcSQL2,'#',' AND a.ArtCode IN (')
IF @iNext>DATALENGTH(@tInput) / 2
   BEGIN
      SET @vcSQL2=SUBSTRING(@vcSQL2,1,LEN(@vcSQL2)-13)
      --SET @vcSQL2Prop = REPLACE (@vcSQL2, 'a.IdOaP', '(a.IdOaP * -1)')
      GOTO LAB
   END
SET @vcSQL2Prop = REPLACE (@vcSQL2, 'a.IdOaP', '(a.IdOaP * -1)')
--vcSQL3
SET @vcSQL3=SUBSTRING(@tInput,@iNext,1500)
IF SUBSTRING(@tInput,@iNext+1500,1)='~'
   BEGIN
        SET @vcSQL3=@vcSQL3+'~'
   END
SET @iNext=@iNext+LEN(@vcSQL3)
SET @vcSQL3=REPLACE(@vcSQL3,'#~',')) OR (a.IdOaP=')
SET @vcSQL3=REPLACE(@vcSQL3,'#',' AND a.ArtCode IN (')
IF @iNext>DATALENGTH(@tInput) / 2
   BEGIN
      SET @vcSQL3=SUBSTRING(@vcSQL3,1,LEN(@vcSQL3)-13)
      --SET @vcSQL3Prop = REPLACE (@vcSQL3, 'a.IdOaP', '(a.IdOaP * -1)')
      GOTO LAB
   END
SET @vcSQL3Prop = REPLACE (@vcSQL3, 'a.IdOaP', '(a.IdOaP * -1)')
--vcSQL4
SET @vcSQL4=SUBSTRING(@tInput,@iNext,1500)
IF SUBSTRING(@tInput,@iNext+1500,1)='~'
   BEGIN
        SET @vcSQL4=@vcSQL4+'~'
   END
SET @iNext=@iNext+LEN(@vcSQL4)
SET @vcSQL4=REPLACE(@vcSQL4,'#~',')) OR (a.IdOaP=')
SET @vcSQL4=REPLACE(@vcSQL4,'#',' AND a.ArtCode IN (')
IF @iNext>DATALENGTH(@tInput) / 2
   BEGIN
      SET @vcSQL4=SUBSTRING(@vcSQL4,1,LEN(@vcSQL4)-13)
      --SET @vcSQL4Prop = REPLACE (@vcSQL4, 'a.IdOaP', '(a.IdOaP * -1)')
      GOTO LAB
   END
SET @vcSQL4Prop = REPLACE (@vcSQL4, 'a.IdOaP', '(a.IdOaP * -1)')
--vcSQL5
SET @vcSQL5=SUBSTRING(@tInput,@iNext,1500)
IF SUBSTRING(@tInput,@iNext+1500,1)='~'
   BEGIN
        SET @vcSQL5=@vcSQL5+'~'
   END
SET @iNext=@iNext+LEN(@vcSQL5)
SET @vcSQL5=REPLACE(@vcSQL5,'#~',')) OR (a.IdOaP=')
SET @vcSQL5=REPLACE(@vcSQL5,'#',' AND a.ArtCode IN (')
IF @iNext>DATALENGTH(@tInput) / 2
   BEGIN
      SET @vcSQL5=SUBSTRING(@vcSQL5,1,LEN(@vcSQL5)-13)
      --SET @vcSQL5Prop = REPLACE (@vcSQL5, 'a.IdOaP', '(a.IdOaP * -1)')
      GOTO LAB
   END
SET @vcSQL5Prop = REPLACE (@vcSQL5, 'a.IdOaP', '(a.IdOaP * -1)')
--vcSQL6
SET @vcSQL6=SUBSTRING(@tInput,@iNext,1500)
IF SUBSTRING(@tInput,@iNext+1500,1)='~'
   BEGIN
         SET @vcSQL6=@vcSQL6+'~'
   END
SET @iNext=@iNext+LEN(@vcSQL6)
SET @vcSQL6=REPLACE(@vcSQL6,'#~',')) OR (a.IdOaP=')
SET @vcSQL6=REPLACE(@vcSQL6,'#',' AND a.ArtCode IN (')
IF @iNext>DATALENGTH(@tInput) / 2
   BEGIN
      SET @vcSQL6=SUBSTRING(@vcSQL6,1,LEN(@vcSQL6)-13)
      --SET @vcSQL6Prop = REPLACE (@vcSQL6, 'a.IdOaP', '(a.IdOaP * -1)')
     GOTO LAB
   END
SET @vcSQL6Prop = REPLACE (@vcSQL6, 'a.IdOaP', '(a.IdOaP * -1)')
--vcSQL7
SET @vcSQL7=SUBSTRING(@tInput,@iNext,1500)
IF SUBSTRING(@tInput,@iNext+1500,1)='~'
   BEGIN
        SET @vcSQL7=@vcSQL7+'~'
   END
SET @iNext=@iNext+LEN(@vcSQL7)
SET @vcSQL7=REPLACE(@vcSQL7,'#~',')) OR (a.IdOaP=')
SET @vcSQL7=REPLACE(@vcSQL7,'#',' AND a.ArtCode IN (')
IF @iNext>DATALENGTH(@tInput) / 2
   BEGIN
      SET @vcSQL7=SUBSTRING(@vcSQL7,1,LEN(@vcSQL7)-13)
      --SET @vcSQL7Prop = REPLACE (@vcSQL7, 'a.IdOaP', '(a.IdOaP * -1)')
      GOTO LAB
   END
SET @vcSQL7Prop = REPLACE (@vcSQL7, 'a.IdOaP', '(a.IdOaP * -1)')
--vcSQL8
SET @vcSQL8=SUBSTRING(@tInput,@iNext,1500)
IF SUBSTRING(@tInput,@iNext+1500,1)='~'
   BEGIN
        SET @vcSQL8=@vcSQL8+'~'
   END
SET @iNext=@iNext+LEN(@vcSQL8)
SET @vcSQL8=REPLACE(@vcSQL8,'#~',')) OR (a.IdOaP=')
SET @vcSQL8=REPLACE(@vcSQL8,'#',' AND a.ArtCode IN (')
IF @iNext>DATALENGTH(@tInput) / 2
   BEGIN
      SET @vcSQL8=SUBSTRING(@vcSQL8,1,LEN(@vcSQL8)-13)
      --SET @vcSQL8Prop = REPLACE (@vcSQL8, 'a.IdOaP', '(a.IdOaP * -1)')
      GOTO LAB
   END
SET @vcSQL8Prop = REPLACE (@vcSQL8, 'a.IdOaP', '(a.IdOaP * -1)')
--vcSQL9
SET @vcSQL9=SUBSTRING(@tInput,@iNext,1500)
IF SUBSTRING(@tInput,@iNext+1500,1)='~'
   BEGIN
        SET @vcSQL9=@vcSQL9+'~'
   END
SET @iNext=@iNext+LEN(@vcSQL9)
SET @vcSQL9=REPLACE(@vcSQL9,'#~',')) OR (a.IdOaP=')
SET @vcSQL9=REPLACE(@vcSQL9,'#',' AND a.ArtCode IN (')
IF @iNext>DATALENGTH(@tInput) / 2
   BEGIN
      SET @vcSQL9=SUBSTRING(@vcSQL9,1,LEN(@vcSQL9)-13)
      --SET @vcSQL9Prop = REPLACE (@vcSQL9, 'a.IdOaP', '(a.IdOaP * -1)')
      GOTO LAB
   END
SET @vcSQL9Prop = REPLACE (@vcSQL9, 'a.IdOaP', '(a.IdOaP * -1)')
--vcSQL10
SET @vcSQL10=SUBSTRING(@tInput,@iNext,1500)
IF SUBSTRING(@tInput,@iNext+1500,1)='~'
   BEGIN
        SET @vcSQL10=@vcSQL10+'~'
   END
SET @iNext=@iNext+LEN(@vcSQL10)
SET @vcSQL10=REPLACE(@vcSQL10,'#~',')) OR (a.IdOaP=')
SET @vcSQL10=REPLACE(@vcSQL10,'#',' AND a.ArtCode IN (')
IF @iNext>DATALENGTH(@tInput) / 2
   BEGIN
      SET @vcSQL10=SUBSTRING(@vcSQL10,1,LEN(@vcSQL10)-13)
      --SET @vcSQL10Prop = REPLACE (@vcSQL10, 'a.IdOaP', '(a.IdOaP * -1)')
      GOTO LAB
   END
RAISERROR ('Errore: Filtro troppo lungo - Contattare DBA - (GetPlanningWithPlant) ', 16, 1) 
RETURN 99
LAB:
IF @vcInsForn IN ('-1', '-2')
BEGIN
 
        EXECUTE (@vcSQLProd1+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@vcSQL8+@vcSQL9+@vcSQL10+ ')'+
                 '  UNION ALL ' + @vcSQLProd1Prop+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@vcSQL8+@vcSQL9+@vcSQL10 + ') ORDER BY  b.DataScad ')
        IF @@ERROR<>0
           BEGIN
                RAISERROR ('Errore: Sintassi SQL DINAMICO - vcSQLProd1 - (GetPlanningWithPlant) ', 16, 1) 
                RETURN 99
           END
        EXECUTE ('SELECT * FROM (' +@vcSQLProd+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@vcSQL8+@vcSQL9+@vcSQL10+ ')' +
                 '  UNION all  ' + @vcSQLProdProp+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@vcSQL8+@vcSQL9+@vcSQL10 +')) v ORDER BY ABS(v.IDOap), v.IdOap, v.ArtCode, v.DataScad ')
  IF @@ERROR<>0
           BEGIN
                RAISERROR ('Errore: Sintassi SQL DINAMICO - vcSQLProd - (GetPlanningWithPlant) ', 16, 1) 
                RETURN 99
           END
END 
ELSE
BEGIN
        EXECUTE (@vcSQLProd1+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@vcSQL8+@vcSQL9+@vcSQL10+') ORDER BY  b.DataScad ')
        IF @@ERROR<>0
           BEGIN
                RAISERROR ('Errore: Sintassi SQL DINAMICO - vcSQLProd1 - (GetPlanningWithPlant) ', 16, 1) 
                RETURN 99
           END
        EXECUTE (@vcSQLProd+@vcSQL1+@vcSQL2+@vcSQL3+@vcSQL4+@vcSQL5+@vcSQL6+@vcSQL7+@vcSQL8+@vcSQL9+@vcSQL10+') ORDER BY a.IDOap,  a.ArtCode, b.DataScad ')
        IF @@ERROR<>0
           BEGIN
                RAISERROR ('Errore: Sintassi SQL DINAMICO - vcSQLProd - (GetPlanningWithPlant) ', 16, 1) 
                RETURN 99
           END
END
GO
