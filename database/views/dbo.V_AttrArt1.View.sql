USE [AFLink_TND]
GO
/****** Object:  View [dbo].[V_AttrArt1]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[V_AttrArt1] 
AS
SELECT b.IdVat, i.IdDzt as vatIdDzt, i.dztNome, 
       c.dscTesto AS UMS, 
       cast(g.vatValore AS varchar(500)) AS vatValore, 
       i.dztMultiValue, f.IdUms as IdUms, null as StructDesc
FROM dbo.valoriattributi b, dbo.descsi c, 
    dbo.unitamisura f, dbo.valoriattributi_int g, 
    dbo.dizionarioattributi i
WHERE b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    b.vatidums = f.idums AND f.umsiddscsimbolo = c.iddsc 
    AND b.vatTipoMem= 1
    
UNION ALL
SELECT b.IdVat, i.IdDzt as vatIdDzt,    i.dztNome, '' AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue, null as IdUms, null as StructDesc
FROM dbo.valoriattributi b, 
    dbo.valoriattributi_int g, 
    dbo.dizionarioattributi i
WHERE b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt 
    AND (b.vatidums IS NULL or b.vatidums = 0)
    AND b.vatTipoMem= 1
UNION ALL
SELECT b.IdVat, i.IdDzt as vatIdDzt,    i.dztNome, 
     c.dscTesto AS UMS, 
    convert(varchar(50), g.vatValore, 2) AS vatValore, 
    i.dztMultiValue, f.IdUms as IdUms, null as StructDesc
FROM dbo.valoriattributi b, dbo.descsi c, 
    dbo.unitamisura f, dbo.valoriattributi_money g, 
    dbo.dizionarioattributi i
WHERE b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    b.vatidums = f.idums AND f.umsiddscsimbolo = c.iddsc 
    AND b.vatTipoMem= 2
UNION ALL
SELECT b.IdVat, i.IdDzt as vatIdDzt,    i.dztNome, 
     c.dscTesto AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue, f.IdUms as IdUms, null as StructDesc
FROM dbo.valoriattributi b, dbo.descsi c, 
    dbo.unitamisura f, dbo.valoriattributi_float g, 
    dbo.dizionarioattributi i
WHERE b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    b.vatidums = f.idums AND f.umsiddscsimbolo = c.iddsc 
    AND b.vatTipoMem= 3
UNION ALL
SELECT b.IdVat, i.IdDzt as vatIdDzt,    i.dztNome, '' AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue, null as IdUms, null as StructDesc
FROM dbo.valoriattributi b, 
    dbo.valoriattributi_float g, 
    dbo.dizionarioattributi i
WHERE b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt  
    AND  (b.vatidums IS NULL or b.vatidums = 0) 
    AND b.vatTipoMem= 3
UNION ALL
SELECT b.IdVat, i.IdDzt as vatIdDzt,    i.dztNome, '' AS UMS, 
     g.vatValore AS vatValore, 
    i.dztMultiValue, null as IdUms, null as StructDesc
FROM dbo.valoriattributi b, 
    dbo.valoriattributi_nvarchar g, 
    dbo.dizionarioattributi i
WHERE b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt 
    AND b.vatTipoMem= 4
    and i.dztIdTid <> 21
UNION ALL
SELECT b.IdVat, i.IdDzt as vatIdDzt,    i.dztNome, '' AS UMS, 
     g.vatValore AS vatValore, 
    i.dztMultiValue, null as IdUms, l.descrizione as StructDesc
FROM dbo.valoriattributi b, 
    dbo.valoriattributi_nvarchar g, 
    dbo.dizionarioattributi i,dbo.az_struttura l
WHERE b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt 
    AND  b.vatTipoMem= 4
    and i.dztIdTid = 21
    and cast(l.IdAz  as varchar(20)) + '#' + l.Path like g.vatValore
UNION ALL
SELECT b.IdVat, i.IdDzt as vatIdDzt,    i.dztNome, '' AS UMS, 
    convert (varchar(10), g.vatValore, 20),
    i.dztMultiValue, null as IdUms, null as StructDesc
FROM dbo.valoriattributi b, 
    dbo.valoriattributi_datetime g, 
    dbo.dizionarioattributi i
WHERE b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt 
    AND b.vatTipoMem= 5
UNION ALL
SELECT b.IdVat, i.IdDzt as vatIdDzt,    i.dztNome, '' AS UMS, 
     h.dsctesto as vatValore, 
    i.dztMultiValue, null  as IdUms, null as StructDesc
FROM dbo.valoriattributi b, 
    dbo.valoriattributi_descrizioni g, dbo.descsi h, 
    dbo.dizionarioattributi i, dbo.tipidatirange j
WHERE b.idvat = g.idvat AND 
    cast(g.vatiddsc as varchar(20)) = j.tdrCodice AND 
--    g.vatiddsc = j.tdrCodice AND 
    j.tdrIdDsc = h.iddsc AND 
    b.vatiddzt = i.iddzt AND 
    j.tdridtid = i.dztidtid
    AND b.vatTipoMem= 6
UNION ALL
SELECT b.IdVat, i.IdDzt as vatIdDzt,    i.dztNome, '' AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue, null as IdUms, null as StructDesc
FROM dbo.valoriattributi b, 
    dbo.valoriattributi_keys g, 
    dbo.dizionarioattributi i
WHERE b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt 
    AND b.vatTipoMem= 7
GO
