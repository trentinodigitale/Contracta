USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetSingleOAP]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetSingleOAP] (@IdOap INT)
AS
SELECT a.IdDett, a.IdOaP, a.IdMsg, a.DescrArt, a.ArtCode, a.UM, c.Descrizione AS SediDest, a.SediDest AS CodSediDest, a.TipoRiga, a.QOXAB, a.DataXAB,
       a.QOCumulataXAB, a.CodiceArtForn, a.DataForn, a.Variazione, a.NumXAB, a.Viewed,
       a.ViewedBuyer, a.ViewedForn, a.VariatoForn, a.CodOperFase, a.Fase, a.Protocol, a.PeriodoTipologia,
       b.NumOrd, b.SottoTipoRiga, b.DataScad, b.QO, b.Modify, b.QTAOrdPrec, b.SottoTipoRigaOrdPrec,
       b.QtaProgCons, b.DataScadProp, b.QOProp, b.QtaProgConsProp, b.Send, b.InsForn, b.ChiaveRigaDett, a.IdArt
  FROM OAPDettaglio a, OAPDettaglioRiga b, AZ_STRUTTURA c
 WHERE a.IdDett = b.IdDett
   AND a.IdOap = @IdOap
   AND b.InsForn = 0
   AND CAST (c.IdAz AS VARCHAR(20)) + '#' + c.Path = a.SediDest
ORDER BY a.IdDett
GO
