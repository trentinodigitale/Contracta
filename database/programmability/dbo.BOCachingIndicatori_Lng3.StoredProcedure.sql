USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOCachingIndicatori_Lng3]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOCachingIndicatori_Lng3] (@lastDate DATETIME = NULL OUTPUT)
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
                 Indicatori.indUltimaMod,DescsLng3_dscInd.dscTesto  AS indDescrizione, 
                 DescsLng3_dscFormula.dscTesto  AS indForm,Indicatori.indTip,indDeleted AS flagDeleted
            FROM Indicatori, DescsLng3 DescsLng3_dscInd, DescsLng3 DescsLng3_dscFormula
           WHERE DescsLng3_dscInd.IdDsc = Indicatori.indIdDsc
             AND DescsLng3_dscFormula.IdDsc = Indicatori.indIdDscFormula
             AND Indicatori.indTipo = 'D'
    END 
ELSE 
    BEGIN
         IF (@lastDate IS NULL)
            SELECT Indicatori.IdInd, Indicatori.indNatura, Indicatori.indValuta, Indicatori.indFormula, Indicatori.indBestSol, 
                   Indicatori.indPesoDef, Indicatori.indDI, Indicatori.indDF, Indicatori.indUltimaMod,
                   DescsLng3_dscInd.dscTesto  AS indDescrizione,DescsLng3_dscFormula.dscTesto  AS indForm,
                   Indicatori.indTip,indDeleted AS flagDeleted
              FROM Indicatori, DescsLng3 DescsLng3_dscInd, DescsLng3 DescsLng3_dscFormula
             WHERE DescsLng3_dscInd.IdDsc = Indicatori.indIdDsc
               AND DescsLng3_dscFormula.IdDsc = Indicatori.indIdDscFormula
               AND Indicatori.indTipo = 'D'
         ELSE
         IF (@lastDate < @ConfDate)
             SELECT Indicatori.IdInd, Indicatori.indNatura, Indicatori.indValuta, Indicatori.indFormula, Indicatori.indBestSol, 
                    Indicatori.indPesoDef, Indicatori.indDI, Indicatori.indDF, Indicatori.indUltimaMod,
                    DescsLng3_dscInd.dscTesto  AS indDescrizione,DescsLng3_dscFormula.dscTesto  AS indForm,
                    Indicatori.indTip,indDeleted AS flagDeleted
               FROM Indicatori, DescsLng3 DescsLng3_dscInd, DescsLng3 DescsLng3_dscFormula
              WHERE DescsLng3_dscInd.IdDsc = Indicatori.indIdDsc
                AND DescsLng3_dscFormula.IdDsc = Indicatori.indIdDscFormula
                AND Indicatori.indUltimaMod > @lastDate 
                AND Indicatori.indTipo = 'D'
         SELECT @lastDate = @ConfDate
   END
GO
