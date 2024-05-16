USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ProcVarProg]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--===============================
--	CODICE STRUTTURA	=
--===============================
CREATE PROCEDURE [dbo].[ProcVarProg]
( 
  @iIdOap INT,
  @vArtCode NVARCHAR(20),
  @istrStato VARCHAR(8000),
  @vSuffix VARCHAR(5),
  @bValrit bit OUTPUT
)
AS  
  BEGIN
       
      DECLARE @vTabDescsX VARCHAR(30)
      DECLARE @vV_OUTPUT  NVARCHAR(4000)
      DECLARE @iIddett INT
      DECLARE @vStr VARCHAR(4000)
      
      SELECT  @iIddett = IdDett 
        FROM oapdettaglio 
       WHERE idoap = @iIdOap AND artcode=@vArtCode
      DECLARE @iddett1 INT
      DECLARE @SQLString NVARCHAR(4000)
      DECLARE @ParmDefinition NVARCHAR(4000)
      DECLARE @Val INT
      DECLARE @ProgDett tinyint
      SET @SQLString = N'SELECT @val = count(*)
                         FROM oapultimaprop 
                         WHERE send in ('''+@istrstato+''') AND iddett = '+cast(@iIddett AS VARCHAR(10))
      SET @ParmDefinition = N'@val INT out,@istrstato VARCHAR(100),@iIddett INT'
      EXECUTE sp_executesql @SQLString, @ParmDefinition,@val out,@istrstato = @istrstato,@iIddett = @iddett1
      IF @val > 0 
            BEGIN
                  
                  SET @bValrit = 0 
                  SELECT @ProgDett = progdett 
                  FROM oapultimaprop 
                  WHERE send in (''+@istrstato+'') AND iddett = @iIddett
                  SET @vV_OUTPUT = 'SELECT a.idOap,a.CodiceArtForn,de.dsctesto AS dscUM,a.SediDest,a.TipoRiga,a.NumXAB,
                                           a.DataXAB,a.QOXAB,a.QOCumulataXAB, a.ViewedForn,a.CodOperFase,a.Fase,
                                           a.ViewedBuyer,a.PeriodoTipologia,a.VariatoForn,c.DataScad,c.QO,c.QTAProgCons,
                                           c.DataScadProp,c.QOProp,c.QtaProgConsProp,c.Send,c.InsForn,a.IdMsg,
                                           c.SottoTipoRiga,c.IdDettRig,c.PrevisionalDateCrudeDelivery,
                                           c.EffectiveDateCrudeDelivery,c.EffectiveQtyCrudeDelivery,
                                           a.ResidualOrderQuantity, c.PlannedDeliveryDate
                                      FROM oapdettaglio a,(SELECT progdett,IdDettRig,IdDett,DataScadProp,QOProp,
                                                                  QtaProgConsProp,Send,InsForn,DataScad,QO,QTAProgCons,
                                                                  SottoTipoRiga, PrevisionalDateCrudeDelivery,
                                                                  EffectiveDateCrudeDelivery,EffectiveQtyCrudeDelivery, PlannedDeliveryDate            
                                                             FROM oapultimaprop 
                                                            WHERE progdett = '+cast(@ProgDett AS VARCHAR(10))+'
                                                 ) c,UnitaMisura u,### de
                                     WHERE (a.iddett = c.iddett)
                                        AND a.idoap = '+cast(@iIdOap AS VARCHAR(10))+
                                      ' AND a.artcode = '''+@vArtCode+''' AND a.UM =u.IdUms AND u.umsIdDscNome = de.iddsc'
            END
      ELSE
            BEGIN
                  SET @bValrit = 1
                  SET @vV_OUTPUT ='SELECT a.idOap,a.CodiceArtForn,de.dsctesto AS dscUM,a.SediDest,a.TipoRiga,a.NumXAB,
                                          a.DataXAB,a.QOXAB,a.QOCumulataXAB, a.ViewedForn,a.CodOperFase,a.Fase,
                                          a.ViewedBuyer,a.PeriodoTipologia,a.VariatoForn,b.DataScad,b.QO,
                                          b.QTAProgCons,NULL AS ''DataScadProp'',NULL AS ''QOProp'',
                                          NULL AS ''QtaProgConsProp'',NULL AS ''Send'',b.InsForn,a.IdMsg,
                                          b.SottoTipoRiga,b.IdDettRig, b.PrevisionalDateCrudeDelivery,
                                          b.EffectiveDateCrudeDelivery,b.EffectiveQtyCrudeDelivery,
                                          a.ResidualOrderQuantity, b.PlannedDeliveryDate            
                                     FROM oapdettaglio a,oapdettaglioriga  b, UnitaMisura u,### de      
                                    WHERE a.iddett = b.iddett 
                                      AND a.idoap = '+cast(@iIdOap AS VARCHAR(10))+' AND a.artcode = '''+@vArtCode+''' AND a.UM =u.IdUms AND u.umsIdDscNome = de.iddsc AND b.InsForn = 0'
            END             
      SET @vTabDescsX  = case
                        when @vSuffix = 'I'       then 'DescsI'
                        when @vSuffix = 'E'       then 'DescsE'
                        when @vSuffix = 'UK'       then 'DescsUK'
                        when @vSuffix = 'FRA'       then 'DescsFRA'
                        when @vSuffix = 'Lng1'       then 'descsLng1'
                        when @vSuffix = 'Lng2'      then 'descsLng2'
                        when @vSuffix = 'Lng3'       then 'descsLng3'
                        when @vSuffix = 'Lng4'       then 'descsLng4'
                   end 
      SET @vV_OUTPUT = replace(@vV_OUTPUT,'###',@vTabDescsX)
      EXECUTE (@vV_OUTPUT)
            
  end
GO
