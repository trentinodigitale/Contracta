USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TestRap]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[TestRap] (@strIdDzt as varchar(4000)) AS
declare @strSQL as varchar (500)
set @strSQL = '
select a.IdArt, a.artIdAzi, b.vatIdDzt, b.dztNome, b.ums, b.vatValore, b.dztMultiValue, b.IdUms, b.structDesc
  from v_attrArt1 b, 
(
 select a.IdArt, b.artIdAzi, a.IdVat
  from dfvatart a, articoli b, #TempRicercheArticoli c
 where a.idart = b.idart
   and b.artdeleted = 0
   and c.racIdArt = a.IdArt
) a
where a.IDVat = b.IdVat and b.VatIdDzt in (' + @strIdDzt + ')'
exec (@strSQL)
GO
