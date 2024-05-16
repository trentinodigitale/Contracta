USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MPGerarchiaAttributi_Lng1]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[MPGerarchiaAttributi_Lng1]
AS
/*
	Modificata Da Albanese Michele
	Data: 20040228
	Ottimizzata 
*/
SELECT IdMpGa           AS IdTab,
       mpgaIdMp         AS tabIdMp,
       mpgaContesto     AS tabContesto,
       dscTesto         AS tabDescr,
       mpgaIdDzt        AS tabValue,
       mpgaPath         AS tabPath,
       mpgaLivello      AS tabLivello,
       mpgaFoglia       AS tabFoglia,
       mpgaLenPathPadre AS tabLenPathPadre,
       mpgaDeleted      AS tabDeleted,
       mpgaUltimaMod    AS tabUltimaMod, 
       mpgaProfili      AS tabProfili,
       mpgaMultiSel     AS tabMultiSel
  FROM MPGerarchiaAttributi, DizionarioAttributi, DescsLng1
 WHERE mpgaIdDzt = iddzt
   AND dztIdDsc = IdDsc 
   AND mpgaFoglia = 1
   AND mpgaUltimaMod >= convert(varchar(23),dscUltimaMod,121) 
UNION ALL
SELECT IdMpGa           AS IdTab,
       mpgaIdMp         AS tabIdMp,
       mpgaContesto     AS tabContesto,
       dscTesto         AS tabDescr,
       mpgaIdDzt        AS tabValue,
       mpgaPath         AS tabPath,
       mpgaLivello      AS tabLivello,
       mpgaFoglia       AS tabFoglia,
       mpgaLenPathPadre AS tabLenPathPadre,
       mpgaDeleted      AS tabDeleted,
       dscUltimaMod     AS tabUltimaMod, 
       mpgaProfili      AS tabProfili,
       mpgaMultiSel     AS tabMultiSel
  FROM MPGerarchiaAttributi, DizionarioAttributi, DescsLng1
 WHERE mpgaIdDzt = iddzt
   AND dztIdDsc = IdDsc 
   AND mpgaFoglia = 1
   AND mpgaUltimaMod < convert(varchar(23),dscUltimaMod,121) 
UNION ALL 
SELECT IdMpGa           AS IdTab,
       mpgaIdMp         AS tabIdMp,
       mpgaContesto     AS tabContesto,
       mpgaDescr        AS tabDescr,
       mpgaIdDzt        AS tabValue,
       mpgaPath         AS tabPath,
       mpgaLivello      AS tabLivello,
       mpgaFoglia       AS tabFoglia,
       mpgaLenPathPadre AS tabLenPathPadre,
       mpgaDeleted      AS tabDeleted,
       mpgaUltimaMod    AS tabUltimaMod,
       mpgaProfili      AS tabProfili,
       mpgaMultiSel     AS tabMultiSel
  FROM MPGerarchiaAttributi
 WHERE mpgaFoglia = 0
GO
