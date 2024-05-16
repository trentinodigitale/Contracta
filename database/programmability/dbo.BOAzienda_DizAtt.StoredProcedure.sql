USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOAzienda_DizAtt]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOAzienda_DizAtt](@nomeAttr VARCHAR(50))
AS
SELECT DizionarioAttributi.idDzt, DizionarioAttributi.dztFAziende,DizionarioAttributi.dztFArticoli,
       DizionarioAttributi.dztFRegObblig,DizionarioAttributi.dztCampoSpeciale
  FROM DizionarioAttributi
 WHERE dztNome = @nomeAttr
GO
