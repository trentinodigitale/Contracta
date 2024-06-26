USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOIndicatori_Indicatori_Lng4]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOIndicatori_Indicatori_Lng4] (@indTip INT)
AS
SELECT Indicatori.IdInd, Indicatori.indNatura, Indicatori.indValuta, Indicatori.indFormula, Indicatori.indBestSol, 
       Indicatori.indPesoDef, Indicatori.indDI, Indicatori.indDF, Indicatori.indUltimaMod,
       DescsLng4_dscInd.dscTesto  AS indDescrizione, DescsLng4_dscFormula.dscTesto  AS indForm,
       Indicatori.indTipo , Indicatori.indFuncParms, Indicatori.indCalcolo, Indicatori.IndNome, Indicatori.indFunc,
       Indicatori.indMin,Indicatori.indMax       
  FROM Indicatori, DescsLng4 DescsLng4_dscInd, DescsLng4 DescsLng4_dscFormula
 WHERE DescsLng4_dscInd.IdDsc = Indicatori.indIdDsc
   AND DescsLng4_dscFormula.IdDsc = Indicatori.indIdDscFormula
   AND Indicatori.IndTip = @indTip 
   AND Indicatori.IndDeleted=0
GO
