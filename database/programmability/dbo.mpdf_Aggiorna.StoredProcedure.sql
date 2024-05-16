USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[mpdf_Aggiorna]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[mpdf_Aggiorna] (@lastDate DATETIME = NULL OUTPUT) AS
 DECLARE @ConfDate DATETIME
 SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'MPDocFunc'
 IF (@ConfDate IS NULL) /* Non accade */
 BEGIN
   SELECT @lastDate = GETDATE()
   SELECT IdMpDF,mpdfIdMp,dcmIType AS IType,dcmIsubType AS ISubType,mpdfFunc,mpdfObjectType,mpdfHide,FnzuPos AS Pos,mpdfDeleted AS flagDeleted
   FROM MPDocFunc m inner join document  d
   on m.mpdfIdDcm = d.iddcm 
            left outer join funzionalitautente f
   on m.mpdfIdFnzu  = f.IdFnzu 
   ORDER BY IdMpDF
 END ELSE BEGIN
  IF (@lastDate IS NULL)
   SELECT IdMpDF,mpdfIdMp,dcmIType AS IType,dcmIsubType AS ISubType,mpdfFunc,mpdfObjectType,mpdfHide,FnzuPos AS Pos,mpdfDeleted AS flagDeleted
   FROM MPDocFunc m inner join document  d
   on m.mpdfIdDcm = d.iddcm 
            left outer join funzionalitautente f
   on m.mpdfIdFnzu  = f.IdFnzu 
   ORDER BY IdMpDF
 ELSE
   IF (@lastDate < @ConfDate)
      SELECT IdMpDF,mpdfIdMp,dcmIType AS IType,dcmIsubType AS ISubType,mpdfFunc,mpdfObjectType,mpdfHide,FnzuPos AS Pos,mpdfDeleted AS flagDeleted
      FROM MPDocFunc m inner join document  d
      on m.mpdfIdDcm = d.iddcm 
            left outer join funzionalitautente f
      on m.mpdfIdFnzu  = f.IdFnzu 
      WHERE mpdfUltimaMod > @lastDate
      ORDER BY IdMpDF
       SELECT @lastDate = @ConfDate
 END
GO
