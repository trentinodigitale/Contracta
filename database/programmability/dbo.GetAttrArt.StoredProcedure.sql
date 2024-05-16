USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetAttrArt]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[GetAttrArt] (@IdMp AS INTeger, @IdAzi AS INTeger)
AS
SELECT a.IdArt, b.vatIdDzt, i.dztNome, cast (c.dscTesto AS NVARCHAR(5)) AS UMS, cast(g.vatValore AS NVARCHAR(500)) AS vatValore, d.mpmIdMp, i.dztMultiValue
  FROM dfvatart a, valoriattributi b, descsi c, mpmodelli d, mpmodelliattributi e, unitamisura f, valoriattributi_int g, dizionarioattributi i
 WHERE a.idvat = g.idvat
   AND b.idvat = g.idvat
   AND b.vatiddzt = e.mpmaiddzt
   AND b.vatiddzt = i.iddzt
   AND e.mpmaidmpmod = d.idmpmod
   AND b.vatidums = f.idums
   AND f.umsiddscsimbolo = c.iddsc
   AND b.vatTipoMem = 1
   AND d.mpmdesc = 'Attributi aggiuntivi Tabella prodotti'
union all
SELECT a.IdArt, b.vatIdDzt, i.dztNome, NULL AS UMS, cast(g.vatValore AS NVARCHAR(500)) AS vatValore, d.mpmIdMp, i.dztMultiValue
  FROM dfvatart a, valoriattributi b, mpmodelli d, mpmodelliattributi e, valoriattributi_int g, dizionarioattributi i
 WHERE a.idvat = g.idvat
   AND b.idvat = g.idvat
   AND b.vatiddzt = e.mpmaiddzt
   AND b.vatiddzt = i.iddzt
   AND e.mpmaidmpmod = d.idmpmod
   AND b.vatidums IS NULL
   AND b.vatTipoMem = 1
   AND d.mpmdesc = 'Attributi aggiuntivi Tabella prodotti'
union all
SELECT a.IdArt, b.vatIdDzt, i.dztNome, cast (c.dscTesto AS NVARCHAR(5)) AS UMS, cast(g.vatValore AS NVARCHAR(500)) AS vatValore, d.mpmIdMp, i.dztMultiValue
  FROM dfvatart a, valoriattributi b, descsi c, mpmodelli d, mpmodelliattributi e, unitamisura f, valoriattributi_money g, dizionarioattributi i
 WHERE a.idvat = g.idvat
   AND b.idvat = g.idvat
   AND b.vatiddzt = e.mpmaiddzt
   AND b.vatiddzt = i.iddzt
   AND e.mpmaidmpmod = d.idmpmod
   AND b.vatidums = f.idums
   AND f.umsiddscsimbolo = c.iddsc
   AND b.vatTipoMem = 2
   AND d.mpmdesc = 'Attributi aggiuntivi Tabella prodotti'
union all
SELECT a.IdArt, b.vatIdDzt, i.dztNome, NULL AS UMS, cast(g.vatValore AS NVARCHAR(500)) AS vatValore, d.mpmIdMp, i.dztMultiValue
  FROM dfvatart a, valoriattributi b, mpmodelli d, mpmodelliattributi e, valoriattributi_money g, dizionarioattributi i
 WHERE a.idvat = g.idvat
   AND b.idvat = g.idvat
   AND b.vatiddzt = e.mpmaiddzt
   AND b.vatiddzt = i.iddzt
   AND e.mpmaidmpmod = d.idmpmod
   AND b.vatidums IS NULL
   AND b.vatTipoMem = 2
   AND d.mpmdesc = 'Attributi aggiuntivi Tabella prodotti'
union all
SELECT a.IdArt, b.vatIdDzt, i.dztNome, cast (c.dscTesto AS NVARCHAR(5)) AS UMS, cast(g.vatValore AS NVARCHAR(500))  AS vatValore, d.mpmIdMp, i.dztMultiValue
  FROM dfvatart a, valoriattributi b, descsi c, mpmodelli d, mpmodelliattributi e, unitamisura f, valoriattributi_float g, dizionarioattributi i
 WHERE a.idvat = g.idvat
   AND b.idvat = g.idvat
   AND b.vatiddzt = e.mpmaiddzt
   AND b.vatiddzt = i.iddzt
   AND e.mpmaidmpmod = d.idmpmod
   AND b.vatidums = f.idums
   AND f.umsiddscsimbolo = c.iddsc
   AND b.vatTipoMem = 3
   AND d.mpmdesc = 'Attributi aggiuntivi Tabella prodotti'
union all
SELECT a.IdArt, b.vatIdDzt, i.dztNome, NULL AS UMS, cast(g.vatValore AS NVARCHAR(500)) AS vatValore, d.mpmIdMp, i.dztMultiValue
  FROM dfvatart a, valoriattributi b, mpmodelli d, mpmodelliattributi e, valoriattributi_float g, dizionarioattributi i
 WHERE a.idvat = g.idvat
   AND b.idvat = g.idvat
   AND b.vatiddzt = e.mpmaiddzt
   AND b.vatiddzt = i.iddzt
   AND e.mpmaidmpmod = d.idmpmod
   AND b.vatidums IS NULL
   AND b.vatTipoMem = 3
   AND d.mpmdesc = 'Attributi aggiuntivi Tabella prodotti'
union all
SELECT a.IdArt, b.vatIdDzt, i.dztNome, cast (c.dscTesto AS NVARCHAR(5)) AS UMS, cast(g.vatValore AS NVARCHAR(500)) AS vatValore, d.mpmIdMp, i.dztMultiValue
  FROM dfvatart a, valoriattributi b, descsi c, mpmodelli d, mpmodelliattributi e, unitamisura f, valoriattributi_nvarchar g, dizionarioattributi i
 WHERE a.idvat = g.idvat
   AND b.idvat = g.idvat
   AND b.vatiddzt = i.iddzt
   AND b.vatiddzt = e.mpmaiddzt
   AND e.mpmaidmpmod = d.idmpmod
   AND b.vatidums = f.idums
   AND f.umsiddscsimbolo = c.iddsc
   AND b.vatTipoMem = 4
   AND d.mpmdesc = 'Attributi aggiuntivi Tabella prodotti'
union all
SELECT a.IdArt, b.vatIdDzt, i.dztNome, NULL AS UMS, cast(g.vatValore AS NVARCHAR(500)) AS vatValore, d.mpmIdMp, i.dztMultiValue
  FROM dfvatart a, valoriattributi b, mpmodelli d, mpmodelliattributi e, valoriattributi_nvarchar g, dizionarioattributi i
 WHERE a.idvat = g.idvat
   AND b.idvat = g.idvat
   AND b.vatiddzt = e.mpmaiddzt
   AND b.vatiddzt = i.iddzt
   AND e.mpmaidmpmod = d.idmpmod
   AND b.vatidums IS NULL
   AND b.vatTipoMem = 4
   AND d.mpmdesc = 'Attributi aggiuntivi Tabella prodotti'
union all
SELECT a.IdArt, b.vatIdDzt, i.dztNome, cast (c.dscTesto AS NVARCHAR(5)) AS UMS, cast(g.vatValore AS NVARCHAR(500)) AS vatValore, d.mpmIdMp, i.dztMultiValue
  FROM dfvatart a, valoriattributi b, descsi c, mpmodelli d, mpmodelliattributi e, unitamisura f, ValoriAttributi_Datetime g, dizionarioattributi i
 WHERE a.idvat = g.idvat
   AND b.idvat = g.idvat
   AND b.vatiddzt = e.mpmaiddzt
   AND b.vatiddzt = i.iddzt
   AND e.mpmaidmpmod = d.idmpmod
   AND b.vatidums = f.idums
   AND f.umsiddscsimbolo = c.iddsc
   AND b.vatTipoMem = 5
   AND d.mpmdesc = 'Attributi aggiuntivi Tabella prodotti'
union all
SELECT a.IdArt, b.vatIdDzt, i.dztNome, NULL AS UMS, cast(g.vatValore AS NVARCHAR(500)) AS vatValore, d.mpmIdMp, i.dztMultiValue
  FROM dfvatart a, valoriattributi b, mpmodelli d, mpmodelliattributi e, ValoriAttributi_Datetime g, dizionarioattributi i
 WHERE a.idvat = g.idvat
   AND b.idvat = g.idvat
   AND b.vatiddzt = e.mpmaiddzt
   AND b.vatiddzt = i.iddzt
   AND e.mpmaidmpmod = d.idmpmod
   AND b.vatidums IS NULL
   AND b.vatTipoMem = 5
   AND d.mpmdesc = 'Attributi aggiuntivi Tabella prodotti'
union all
SELECT a.IdArt, b.vatIdDzt, i.dztNome, cast (c.dscTesto AS NVARCHAR(5)) AS UMS, cast(h.dsctesto AS NVARCHAR(500)) AS vatValore, d.mpmIdMp, i.dztMultiValue
  FROM dfvatart a, valoriattributi b, descsi c, mpmodelli d, mpmodelliattributi e, unitamisura f, valoriattributi_descrizioni g, descsi h, dizionarioattributi i
 WHERE a.idvat = g.idvat
   AND b.idvat = g.idvat
   AND g.vatiddsc = h.iddsc
   AND b.vatiddzt = e.mpmaiddzt
   AND b.vatiddzt = i.iddzt
   AND e.mpmaidmpmod = d.idmpmod
   AND b.vatidums = f.idums
   AND f.umsiddscsimbolo = c.iddsc
   AND b.vatTipoMem = 6
   AND d.mpmdesc = 'Attributi aggiuntivi Tabella prodotti'
union all
SELECT a.IdArt, b.vatIdDzt, i.dztNome, NULL AS UMS, cast(h.dsctesto AS NVARCHAR(500)) AS vatValore, d.mpmIdMp, i.dztMultiValue
  FROM dfvatart a, valoriattributi b, mpmodelli d, mpmodelliattributi e, valoriattributi_descrizioni g, descsi h, dizionarioattributi i
 WHERE a.idvat = g.idvat
   AND b.idvat = g.idvat
   AND g.vatiddsc = h.iddsc
   AND b.vatiddzt = e.mpmaiddzt
   AND b.vatiddzt = i.iddzt
   AND e.mpmaidmpmod = d.idmpmod
   AND b.vatidums IS NULL
   AND b.vatTipoMem = 6
   AND d.mpmdesc = 'Attributi aggiuntivi Tabella prodotti'
union all
SELECT a.IdArt, b.vatIdDzt, i.dztNome, cast (c.dscTesto AS NVARCHAR(5)) AS UMS, cast(g.vatValore AS NVARCHAR(500)) AS vatValore, d.mpmIdMp, i.dztMultiValue
  FROM dfvatart a, valoriattributi b, descsi c, mpmodelli d, mpmodelliattributi e, unitamisura f, valoriattributi_keys g, dizionarioattributi i
 WHERE a.idvat = g.idvat
   AND b.idvat = g.idvat
   AND b.vatiddzt = e.mpmaiddzt
   AND b.vatiddzt = i.iddzt
   AND e.mpmaidmpmod = d.idmpmod
   AND b.vatidums = f.idums
   AND f.umsiddscsimbolo = c.iddsc
   AND b.vatTipoMem = 7
   AND d.mpmdesc = 'Attributi aggiuntivi Tabella prodotti'
union all
SELECT a.IdArt, b.vatIdDzt, i.dztNome, NULL AS UMS, cast(g.vatValore AS NVARCHAR(500)) AS vatValore, d.mpmIdMp, i.dztMultiValue
  FROM dfvatart a, valoriattributi b, mpmodelli d, mpmodelliattributi e, valoriattributi_keys g, dizionarioattributi i
 WHERE a.idvat = g.idvat
   AND b.idvat = g.idvat
   AND b.vatiddzt = e.mpmaiddzt
   AND b.vatiddzt = i.iddzt
   AND e.mpmaidmpmod = d.idmpmod
   AND b.vatidums IS NULL
   AND b.vatTipoMem = 7
   AND d.mpmdesc = 'Attributi aggiuntivi Tabella prodotti'
GO
