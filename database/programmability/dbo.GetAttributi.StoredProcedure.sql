USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetAttributi]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--===============================
--	CODICE STRUTTURA	=
--===============================
CREATE PROCEDURE [dbo].[GetAttributi]
AS
SELECT IdDzt, LOWER(dztNome) AS dztNome, dztLunghezza, dztCifreDecimali, dztIdTid, 
tidTipoMem,tidTipoDom
  FROM DizionarioAttributi, TipiDati
 WHERE dztDeleted = 0
   AND dztIdTid = IdTid
 ORDER BY 2
GO
