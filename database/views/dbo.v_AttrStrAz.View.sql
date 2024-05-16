USE [AFLink_TND]
GO
/****** Object:  View [dbo].[v_AttrStrAz]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--===============================
--	CODICE STRUTTURA	=
--===============================
CREATE VIEW [dbo].[v_AttrStrAz]
AS
SELECT z.IdAz, z.IdStrutt, z.Descrizione AS Descr, c.Valore AS Ind, d.Valore AS Loc, f.Valore AS Pro, g.Valore AS Sta,g.Valore AS Stato
  FROM AZ_ATTRIBUTI c, AZ_ATTRIBUTI d, AZ_ATTRIBUTI f, AZ_ATTRIBUTI g,
       AZ_STRUTTURA z
WHERE z.IdAz = c.IdAz
  AND z.IdAz = d.IdAz
  AND z.IdAz = f.IdAz
  AND z.IdAz = g.IdAz
  AND z.IdStrutt = c.IdStrutt
  AND z.IdStrutt = d.IdStrutt
  AND z.IdStrutt = f.IdStrutt
  AND z.IdStrutt = g.IdStrutt
  AND c.IdAttr = 3
  AND d.IdAttr = 4
  AND f.IdAttr = 6
  AND g.IdAttr = 7
  AND z.Deleted = 0
GO
