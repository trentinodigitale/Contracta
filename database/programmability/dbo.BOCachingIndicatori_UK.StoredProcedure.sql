USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOCachingIndicatori_UK]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOCachingIndicatori_UK] (@lastDate DATETIME = NULL OUTPUT)
AS
DECLARE @ConfDate DATETIME
SELECT @ConfDate = umdUltimaMod 
  FROM srv_UltimaMod 
 WHERE umdNome = 'Indicatori'
IF (@ConfDate IS NULL)
    BEGIN
          SELECT @lastDate = GETDATE()
          SELECT Indicatori.IdInd, Indicatori.indNatura, Indicatori.indValuta, Indicatori.indFormula, 
                 Indicatori.indBestSol, Indicatori.indPesoDef, Indicatori.indDI, Indicatori.indDF, 
                 Indicatori.indUltimaMod,DescsUK_dscInd.dscTesto  AS indDescrizione, 
                 DescsUK_dscFormula.dscTesto  AS indForm,Indicatori.indTip,indDeleted AS flagDeleted
            FROM Indicatori, DescsUK DescsUK_dscInd, DescsUK DescsUK_dscFormula
           WHERE DescsUK_dscInd.IdDsc = Indicatori.indIdDsc
             AND DescsUK_dscFormula.IdDsc = Indicatori.indIdDscFormula
             AND Indicatori.indTipo = 'D'
    END 
ELSE 
    BEGIN
         IF (@lastDate IS NULL)
            SELECT Indicatori.IdInd, Indicatori.indNatura, Indicatori.indValuta, Indicatori.indFormula, Indicatori.indBestSol, 
                   Indicatori.indPesoDef, Indicatori.indDI, Indicatori.indDF, Indicatori.indUltimaMod,
                   DescsUK_dscInd.dscTesto  AS indDescrizione,DescsUK_dscFormula.dscTesto  AS indForm,
                   Indicatori.indTip,indDeleted AS flagDeleted
              FROM Indicatori, DescsUK DescsUK_dscInd, DescsUK DescsUK_dscFormula
             WHERE DescsUK_dscInd.IdDsc = Indicatori.indIdDsc
               AND DescsUK_dscFormula.IdDsc = Indicatori.indIdDscFormula
               AND Indicatori.indTipo = 'D'
         ELSE
         IF (@lastDate < @ConfDate)
             SELECT Indicatori.IdInd, Indicatori.indNatura, Indicatori.indValuta, Indicatori.indFormula, Indicatori.indBestSol, 
                    Indicatori.indPesoDef, Indicatori.indDI, Indicatori.indDF, Indicatori.indUltimaMod,
                    DescsUK_dscInd.dscTesto  AS indDescrizione,DescsUK_dscFormula.dscTesto  AS indForm,
                    Indicatori.indTip,indDeleted AS flagDeleted
               FROM Indicatori, DescsUK DescsUK_dscInd, DescsUK DescsUK_dscFormula
              WHERE DescsUK_dscInd.IdDsc = Indicatori.indIdDsc
                AND DescsUK_dscFormula.IdDsc = Indicatori.indIdDscFormula
                AND Indicatori.indUltimaMod > @lastDate 
                AND Indicatori.indTipo = 'D'
         SELECT @lastDate = @ConfDate
   END
GO
