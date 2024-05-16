USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOCachingIndicatori_Lng4]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOCachingIndicatori_Lng4] (@lastDate DATETIME = NULL OUTPUT)
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
                 Indicatori.indUltimaMod,DescsLng4_dscInd.dscTesto  AS indDescrizione, 
                 DescsLng4_dscFormula.dscTesto  AS indForm,Indicatori.indTip,indDeleted AS flagDeleted
            FROM Indicatori, DescsLng4 DescsLng4_dscInd, DescsLng4 DescsLng4_dscFormula
           WHERE DescsLng4_dscInd.IdDsc = Indicatori.indIdDsc
             AND DescsLng4_dscFormula.IdDsc = Indicatori.indIdDscFormula
             AND Indicatori.indTipo = 'D'
    END 
ELSE 
    BEGIN
         IF (@lastDate IS NULL)
            SELECT Indicatori.IdInd, Indicatori.indNatura, Indicatori.indValuta, Indicatori.indFormula, Indicatori.indBestSol, 
                   Indicatori.indPesoDef, Indicatori.indDI, Indicatori.indDF, Indicatori.indUltimaMod,
                   DescsLng4_dscInd.dscTesto  AS indDescrizione,DescsLng4_dscFormula.dscTesto  AS indForm,
                   Indicatori.indTip,indDeleted AS flagDeleted
              FROM Indicatori, DescsLng4 DescsLng4_dscInd, DescsLng4 DescsLng4_dscFormula
             WHERE DescsLng4_dscInd.IdDsc = Indicatori.indIdDsc
               AND DescsLng4_dscFormula.IdDsc = Indicatori.indIdDscFormula
               AND Indicatori.indTipo = 'D'
         ELSE
         IF (@lastDate < @ConfDate)
             SELECT Indicatori.IdInd, Indicatori.indNatura, Indicatori.indValuta, Indicatori.indFormula, Indicatori.indBestSol, 
                    Indicatori.indPesoDef, Indicatori.indDI, Indicatori.indDF, Indicatori.indUltimaMod,
                    DescsLng4_dscInd.dscTesto  AS indDescrizione,DescsLng4_dscFormula.dscTesto  AS indForm,
                    Indicatori.indTip,indDeleted AS flagDeleted
               FROM Indicatori, DescsLng4 DescsLng4_dscInd, DescsLng4 DescsLng4_dscFormula
              WHERE DescsLng4_dscInd.IdDsc = Indicatori.indIdDsc
                AND DescsLng4_dscFormula.IdDsc = Indicatori.indIdDscFormula
                AND Indicatori.indUltimaMod > @lastDate 
                AND Indicatori.indTipo = 'D'
         SELECT @lastDate = @ConfDate
   END
GO
