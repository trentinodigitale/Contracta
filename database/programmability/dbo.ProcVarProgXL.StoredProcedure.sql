USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ProcVarProgXL]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--===============================
--	CODICE STRUTTURA	=
--===============================
CREATE PROCEDURE [dbo].[ProcVarProgXL]
( 
  @iIdOap INT,
  @vArtCode NVARCHAR(20),
  @istrStato NVARCHAR(4000),
  @vSuffix VARCHAR(5),
  @bValrit bit OUTPUT
)
as  
  begin
       
      DECLARE @vTabDescsX VARCHAR(30)
      DECLARE @vV_OUTPUT  NVARCHAR(4000)
      DECLARE @iIddett INT
      DECLARE @vStr NVARCHAR(4000)
      
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
                  SET @vV_OUTPUT = 'SELECT z.conta,a.iddett,a.DescrArt,a.ArtCode,a.DataForn,a.Variazione,a.Viewed,
                                           a.VariatoForn,a.Protocol, a.IdArt,r.numord,r.modify,r.QTAOrdPrec,
                                           r.PrevisionalDateCrudeDelivery,r.EffectiveDateCrudeDelivery,
                                           r.EffectiveQtyCrudeDelivery,cc.dataoap,cc.codiceplant,cc.protocol,
                                           cc.codicefornitore,de.dsctesto,f.aziragionesociale, a.idOap,a.CodiceArtForn,
                                           de.dsctesto AS dscUM,a.SediDest,a.TipoRiga,a.NumXAB,a.DataXAB,a.QOXAB,
                                           a.QOCumulataXAB, a.ViewedForn,a.CodOperFase,a.Fase,a.ViewedBuyer,
                                           a.PeriodoTipologia,c.DataScad,c.QO,c.QTAProgCons, c.DataScadProp,c.QOProp,
                                           c.QtaProgConsProp,c.Send,c.InsForn,a.IdMsg,c.SottoTipoRiga,c.IdDettRig,
                                           a.ResidualOrderQuantity, c.PlannedDeliveryDate
                                      FROM oapdettaglio a,oapdettaglioriga r,aziende f,oaptestata cc,
                                          (SELECT progdett,IdDettRig,IdDett,DataScadProp,QOProp,
                                                  QtaProgConsProp,Send,InsForn,DataScad,QO,QTAProgCons,SottoTipoRiga, 
                                                  PlannedDeliveryDate
                                             FROM oapultimaprop 
                                            WHERE progdett = '+cast(@ProgDett AS VARCHAR(10))+'
                                                              ) c,UnitaMisura u,### de,
                                        (SELECT count(*) AS ''Conta'',iddett 
                                           FROM oapultimaprop 
                                           group by iddett
                                         ) AS z
                                    WHERE (a.iddett = c.iddett)  AND 
                                        (a.iddett = r.iddett) AND 
                                        (f.idazi = cc.idazi) AND 
                                        (cc.idoap = a.idoap AND cc.sedidest = a.sedidest) 
                                        AND (a.iddett = z.iddett)
                                          AND a.idoap = '+cast(@iIdOap AS VARCHAR(10))+' AND a.artcode = '''+@vArtCode+''' AND a.UM =u.IdUms AND u.umsIdDscNome = de.iddsc
                                        AND c.iddettrig =  r.iddettrig'
            END
      ELSE
            BEGIN
                  SET @bValrit = 1
                  SET @vV_OUTPUT ='SELECT z.conta,a.iddett,a.DescrArt,a.ArtCode,a.DataForn,a.Variazione,a.Viewed,
                                          a.VariatoForn,a.Protocol, a.IdArt,r.numord,r.modify,r.QTAOrdPrec,
                                          r.PrevisionalDateCrudeDelivery,r.EffectiveDateCrudeDelivery,
                                          r.EffectiveQtyCrudeDelivery,cc.dataoap,cc.codiceplant,cc.protocol,
                                          cc.codicefornitore,de.dsctesto,f.aziragionesociale,
                                          a.idOap,a.CodiceArtForn,de.dsctesto AS dscUM,a.SediDest,a.TipoRiga,
                                          a.NumXAB,a.DataXAB,a.QOXAB,a.QOCumulataXAB, a.ViewedForn,a.CodOperFase,
                                          a.Fase,a.ViewedBuyer,a.PeriodoTipologia,r.QO, r.DataScad,r.QO,r.QTAProgCons,
                                          NULL AS ''DataScadProp'',NULL AS ''QOProp'',NULL AS ''QtaProgConsProp'',
                                          NULL AS ''Send'',r.InsForn,r.SottoTipoRiga,r.IdDettRig,
                                          a.ResidualOrderQuantity, r.PlannedDeliveryDate
                                     FROM oapdettaglio a,oapdettaglioriga r,aziende f,oaptestata cc,UnitaMisura u,### de,
                                         (SELECT count(*) AS ''Conta'',iddett 
                                            FROM oapdettaglioriga 
                                           WHERE InsForn = 0      
                                        group by iddett
                                          ) AS z
                                    WHERE (a.iddett = r.iddett) 
                                      AND (f.idazi = cc.idazi) 
                                      AND (cc.idoap = a.idoap AND cc.sedidest = a.sedidest) 
                                      AND (a.iddett = z.iddett)
                                      AND a.idoap = '+cast(@iIdOap AS VARCHAR(10))+
                                    ' AND a.artcode = '''+@vArtCode+
                                  ''' AND a.UM =u.IdUms AND u.umsIdDscNome = de.iddsc AND r.InsForn = 0' 
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
      --print @vV_OUTPUT
      execute (@vV_OUTPUT)
            
  end
GO
