USE [AFLink_TND]
GO
/****** Object:  View [dbo].[V_AttrArt_test]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_AttrArt_test]
AS
SELECT a.IdArt, k.artIdazi, b.vatIdDzt, i.dztNome, 
    cast(c.dscTesto AS varchar(5)) AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue, f.IdUms as IdUms, null as StructDesc
FROM dfvatart a, valoriattributi b, descsi c, 
    unitamisura f, valoriattributi_int g, 
    dizionarioattributi i, articoli k
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    b.vatidums = f.idums AND f.umsiddscsimbolo = c.iddsc AND 
    b.vatTipoMem = 1
    and a.idart = k.idart
    and k.artdeleted = 0
    
UNION ALL
SELECT a.IdArt, k.artIdazi, b.vatIdDzt, i.dztNome, '' AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue, null as IdUms, null as StructDesc
FROM dfvatart a, valoriattributi b, 
    valoriattributi_int g, 
    dizionarioattributi i, articoli k
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    (b.vatidums IS NULL or b.vatidums = 0) AND 
    b.vatTipoMem = 1
    and a.idart = k.idart
    and k.artdeleted = 0
    
UNION ALL
SELECT a.IdArt, k.artIdazi, b.vatIdDzt, i.dztNome, 
    cast(c.dscTesto AS varchar(5)) AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue, f.IdUms as IdUms, null as StructDesc
FROM dfvatart a, valoriattributi b, descsi c, 
    unitamisura f, valoriattributi_money g, 
    dizionarioattributi i, articoli k
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    b.vatidums = f.idums AND f.umsiddscsimbolo = c.iddsc AND 
    b.vatTipoMem = 2
    and a.idart = k.idart
    and k.artdeleted = 0
    
UNION ALL
SELECT a.IdArt, k.artIdazi, b.vatIdDzt, i.dztNome, '' AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue, null as IdUms, null as StructDesc
FROM dfvatart a, valoriattributi b, 
    valoriattributi_money g, 
    dizionarioattributi i, articoli k
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    (b.vatidums IS NULL or b.vatidums = 0) AND 
    b.vatTipoMem = 2
    and a.idart = k.idart
    and k.artdeleted = 0
    
UNION ALL
SELECT a.IdArt, k.artIdazi, b.vatIdDzt, i.dztNome, 
    cast(c.dscTesto AS varchar(5)) AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue, f.IdUms as IdUms, null as StructDesc
FROM dfvatart a, valoriattributi b, descsi c, 
    unitamisura f, valoriattributi_float g, 
    dizionarioattributi i, articoli k
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    b.vatidums = f.idums AND f.umsiddscsimbolo = c.iddsc AND 
    b.vatTipoMem = 3
    and a.idart = k.idart
    and k.artdeleted = 0
    
UNION ALL
SELECT a.IdArt, k.artIdazi, b.vatIdDzt, i.dztNome, '' AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue, null as IdUms, null as StructDesc
FROM dfvatart a, valoriattributi b, 
    valoriattributi_float g, 
    dizionarioattributi i, articoli k
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    (b.vatidums IS NULL or b.vatidums = 0) AND 
    b.vatTipoMem = 3
    and a.idart = k.idart
    and k.artdeleted = 0
/*    
UNION ALL
SELECT a.IdArt, k.artIdazi, b.vatIdDzt, i.dztNome, 
    cast(c.dscTesto AS varchar(5)) AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue, f.IdUms as IdUms, null as StructDesc
FROM dfvatart a, valoriattributi b, descsi c, 
    unitamisura f, valoriattributi_nvarchar g, 
    dizionarioattributi i, articoli k
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    b.vatidums = f.idums AND f.umsiddscsimbolo = c.iddsc AND 
    b.vatTipoMem = 4
    and i.dztIdTid <> 21
    and a.idart = k.idart
    and k.artdeleted = 0
*/    
UNION ALL
SELECT a.IdArt, k.artIdazi, b.vatIdDzt, i.dztNome, '' AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue, null as IdUms, null as StructDesc
FROM dfvatart a, valoriattributi b, 
    valoriattributi_nvarchar g, 
    dizionarioattributi i, articoli k
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    (b.vatidums IS NULL or b.vatidums = 0) AND 
    b.vatTipoMem = 4
    and i.dztIdTid <> 21
    and a.idart = k.idart
    and k.artdeleted = 0
UNION ALL
SELECT a.IdArt, k.artIdazi, b.vatIdDzt, i.dztNome, '' AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue, null as IdUms, l.descrizione as StructDesc
FROM dfvatart a, valoriattributi b, 
    valoriattributi_nvarchar g, 
    dizionarioattributi i, articoli k, az_struttura l
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    (b.vatidums IS NULL or b.vatidums = 0) AND 
    b.vatTipoMem = 4
    and a.idart = k.idart
    and i.dztIdTid = 21
    and k.artdeleted = 0
    and cast(l.IdAz  as varchar(20)) + '#' + l.Path like g.vatValore
    
    
UNION ALL
SELECT a.IdArt, k.artIdazi, b.vatIdDzt, i.dztNome, '' AS UMS, 
    convert (varchar(10), g.vatValore, 20),
    i.dztMultiValue, null as IdUms, null as StructDesc
FROM dfvatart a, valoriattributi b, 
    valoriattributi_datetime g, 
    dizionarioattributi i, articoli k
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
--   (b.vatidums IS NULL or b.vatidums = 0) AND 
    b.vatTipoMem = 5
    and a.idart = k.idart
    and k.artdeleted = 0
/*    
UNION ALL
SELECT a.IdArt, k.artIdazi, b.vatIdDzt, i.dztNome, 
    cast(c.dscTesto AS varchar(5)) AS UMS, 
    cast(h.dsctesto AS varchar(500)) AS vatValore, 
    i.dztMultiValue, f.IdUms as IdUms, null as StructDesc
FROM dfvatart a, valoriattributi b, descsi c, 
    unitamisura f, 
    valoriattributi_descrizioni g, descsi h, 
    dizionarioattributi i, articoli k, tipidatirange j
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    cast(g.vatiddsc as varchar(20)) = j.tdrCodice AND 
    j.tdrIdDsc = h.iddsc AND 
    b.vatiddzt = i.iddzt AND 
    j.tdridtid = i.dztidtid and
    b.vatidums = f.idums AND f.umsiddscsimbolo = c.iddsc AND 
    b.vatTipoMem = 6
    and a.idart = k.idart
    and k.artdeleted = 0
*/    
UNION ALL
SELECT a.IdArt, k.artIdazi, b.vatIdDzt, i.dztNome, '' AS UMS, 
    cast(h.dsctesto AS varchar(500)) AS vatValore, 
    i.dztMultiValue, null  as IdUms, null as StructDesc
FROM dfvatart a, valoriattributi b, 
    valoriattributi_descrizioni g, descsi h, 
    dizionarioattributi i, articoli k, tipidatirange j
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    cast(g.vatiddsc as varchar(20)) = j.tdrCodice AND 
    j.tdrIdDsc = h.iddsc AND 
    b.vatiddzt = i.iddzt AND 
    j.tdridtid = i.dztidtid and
    (b.vatidums IS NULL or b.vatidums = 0) AND b.vatTipoMem = 6
    and a.idart = k.idart
    and k.artdeleted = 0
/*    
UNION ALL
SELECT a.IdArt, k.artIdazi, b.vatIdDzt, i.dztNome, 
    cast(c.dscTesto AS varchar(5)) AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue, f.IdUms as IdUms, null as StructDesc
FROM dfvatart a, valoriattributi b, descsi c, 
    unitamisura f, valoriattributi_keys g, 
    dizionarioattributi i, articoli k
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    b.vatidums = f.idums AND f.umsiddscsimbolo = c.iddsc AND 
    b.vatTipoMem = 7
    and a.idart = k.idart
    and k.artdeleted = 0
*/    
UNION ALL
SELECT a.IdArt, k.artIdazi, b.vatIdDzt, i.dztNome, '' AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue, null as IdUms, null as StructDesc
FROM dfvatart a, valoriattributi b, 
    valoriattributi_keys g, 
    dizionarioattributi i, articoli k
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    (b.vatidums IS NULL or b.vatidums = 0) AND 
    b.vatTipoMem = 7
    and a.idart = k.idart
    and k.artdeleted = 0
    
GO
