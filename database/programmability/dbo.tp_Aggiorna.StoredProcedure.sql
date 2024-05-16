USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[tp_Aggiorna]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[tp_Aggiorna](@lastDate DATETIME = NULL OUTPUT) 
AS
DECLARE @ConfDate DATETIME
SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'TabProps'
IF (@ConfDate IS NULL) /* Non Accade */
   BEGIN
         SELECT @lastDate = GETDATE()
         SELECT IdTp,
                tpIdCt,
                tpItypeSource,
                tpISubTypeSource,
                tpAttrib,
                tpValue,
                tpUltimaMod,
                tpDeleted AS flagDeleted
           FROM TabProps
         ORDER BY IdTp
   END 
ELSE 
   BEGIN
        IF (@lastDate IS NULL)
         SELECT IdTp,
                tpIdCt,
                tpItypeSource,
                tpISubTypeSource,
                tpAttrib,
                tpValue,
                tpUltimaMod,
                tpDeleted AS flagDeleted
           FROM TabProps
         ORDER BY IdTp
        ELSE
        IF (@lastDate < @ConfDate)
         SELECT IdTp,
                tpIdCt,
                tpItypeSource,
                tpISubTypeSource,
                tpAttrib,
                tpValue,
                tpUltimaMod,
                tpDeleted AS flagDeleted
           FROM TabProps
          WHERE tpUltimaMod > @lastDate
         ORDER BY IdTp
        SELECT @lastDate = @ConfDate
   END
GO
