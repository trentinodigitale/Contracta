USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOCachingIndicatori_Lng2]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOCachingIndicatori_Lng2] (@lastDate DATETIME = NULL OUTPUT)
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
                 Indicatori.indUltimaMod,DescsLng2_dscInd.dscTesto  AS indDescrizione, 
                 DescsLng2_dscFormula.dscTesto  AS indForm,Indicatori.indTip,indDeleted AS flagDeleted
            FROM Indicatori, DescsLng2 DescsLng2_dscInd, DescsLng2 DescsLng2_dscFormula
           WHERE DescsLng2_dscInd.IdDsc = Indicatori.indIdDsc
             AND DescsLng2_dscFormula.IdDsc = Indicatori.indIdDscFormula
             AND Indicatori.indTipo = 'D'
    END 
ELSE 
    BEGIN
         IF (@lastDate IS NULL)
            SELECT Indicatori.IdInd, Indicatori.indNatura, Indicatori.indValuta, Indicatori.indFormula, Indicatori.indBestSol, 
                   Indicatori.indPesoDef, Indicatori.indDI, Indicatori.indDF, Indicatori.indUltimaMod,
                   DescsLng2_dscInd.dscTesto  AS indDescrizione,DescsLng2_dscFormula.dscTesto  AS indForm,
                   Indicatori.indTip,indDeleted AS flagDeleted
              FROM Indicatori, DescsLng2 DescsLng2_dscInd, DescsLng2 DescsLng2_dscFormula
             WHERE DescsLng2_dscInd.IdDsc = Indicatori.indIdDsc
               AND DescsLng2_dscFormula.IdDsc = Indicatori.indIdDscFormula
               AND Indicatori.indTipo = 'D'
         ELSE
         IF (@lastDate < @ConfDate)
             SELECT Indicatori.IdInd, Indicatori.indNatura, Indicatori.indValuta, Indicatori.indFormula, Indicatori.indBestSol, 
                    Indicatori.indPesoDef, Indicatori.indDI, Indicatori.indDF, Indicatori.indUltimaMod,
                    DescsLng2_dscInd.dscTesto  AS indDescrizione,DescsLng2_dscFormula.dscTesto  AS indForm,
                    Indicatori.indTip,indDeleted AS flagDeleted
               FROM Indicatori, DescsLng2 DescsLng2_dscInd, DescsLng2 DescsLng2_dscFormula
              WHERE DescsLng2_dscInd.IdDsc = Indicatori.indIdDsc
                AND DescsLng2_dscFormula.IdDsc = Indicatori.indIdDscFormula
                AND Indicatori.indUltimaMod > @lastDate 
                AND Indicatori.indTipo = 'D'
         SELECT @lastDate = @ConfDate
   END
GO
