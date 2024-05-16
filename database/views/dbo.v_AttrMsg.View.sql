USE [AFLink_TND]
GO
/****** Object:  View [dbo].[v_AttrMsg]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[v_AttrMsg] as
SELECT a.IdMsg,b.vatIdDzt, i.dztNome, 
    cast(c.dscTesto AS varchar(5)) AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue,f.IdUms as IdUms
FROM MSGVatMSG a, MSGValoriAttributi b, descsi c, 
    unitamisura f, MSGValoriAttributi_int g, 
    dizionarioattributi i
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    b.vatidums = f.idums AND f.umsiddscsimbolo = c.iddsc AND 
    b.vatTipoMem = 1
    
   
UNION ALL
SELECT a.IdMsg,  b.vatIdDzt, i.dztNome, '' AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue,null as IdUms
FROM MSGVatMSG a, MSGValoriAttributi b, 
    MSGValoriAttributi_int g, 
    dizionarioattributi i
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    (b.vatidums IS NULL or b.vatIdUms = 0) AND 
    b.vatTipoMem = 1
    
    
UNION ALL
SELECT a.IdMsg,  b.vatIdDzt, i.dztNome, 
    cast(c.dscTesto AS varchar(5)) AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue,f.IdUms as IdUms
FROM MSGVatMSG a, MSGValoriAttributi b, descsi c, 
    unitamisura f, MSGValoriAttributi_money g, 
    dizionarioattributi i
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    b.vatidums = f.idums AND f.umsiddscsimbolo = c.iddsc AND 
    b.vatTipoMem = 2
    
    
    
UNION ALL
SELECT a.IdMsg,  b.vatIdDzt, i.dztNome, '' AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue,null as IdUms
FROM MSGVatMSG a, MSGValoriAttributi b, 
    MSGValoriAttributi_money g, 
    dizionarioattributi i
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    (b.vatidums IS NULL or b.vatIdUms = 0) AND 
    b.vatTipoMem = 2
    
    
    
UNION ALL
SELECT a.IdMsg,  b.vatIdDzt, i.dztNome, 
    cast(c.dscTesto AS varchar(5)) AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue,f.IdUms as IdUms
FROM MSGVatMSG a, MSGValoriAttributi b, descsi c, 
    unitamisura f, MSGValoriAttributi_float g, 
    dizionarioattributi i
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    b.vatidums = f.idums AND f.umsiddscsimbolo = c.iddsc AND 
    b.vatTipoMem = 3
    
    
    
UNION ALL
SELECT a.IdMsg,  b.vatIdDzt, i.dztNome, '' AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue,null as IdUms
FROM MSGVatMSG a, MSGValoriAttributi b, 
    MSGValoriAttributi_float g, 
    dizionarioattributi i
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    (b.vatidums IS NULL or b.vatIdUms = 0) AND 
    b.vatTipoMem = 3
    
    
    
UNION ALL
SELECT a.IdMsg,  b.vatIdDzt, i.dztNome, 
    cast(c.dscTesto AS varchar(5)) AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue,f.IdUms as IdUms
FROM MSGVatMSG a, MSGValoriAttributi b, descsi c, 
    unitamisura f, MSGValoriAttributi_nvarchar g, 
    dizionarioattributi i
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    b.vatidums = f.idums AND f.umsiddscsimbolo = c.iddsc AND 
    b.vatTipoMem = 4
    
    
    
UNION ALL
SELECT a.IdMsg,  b.vatIdDzt, i.dztNome, '' AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue,null as IdUms
FROM MSGVatMSG a, MSGValoriAttributi b, 
    MSGValoriAttributi_nvarchar g, 
    dizionarioattributi i
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    (b.vatidums IS NULL or b.vatIdUms = 0) AND 
    b.vatTipoMem = 4
    
    
    
UNION ALL
SELECT a.IdMsg,  b.vatIdDzt, i.dztNome, 
    cast(c.dscTesto AS varchar(5)) AS UMS,
    convert (varchar(10), g.vatValore, 20),
    --cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue,f.IdUms as IdUms
FROM MSGVatMSG a, MSGValoriAttributi b, descsi c, 
    unitamisura f, MSGValoriAttributi_datetime g, 
    dizionarioattributi i
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    b.vatidums = f.idums AND f.umsiddscsimbolo = c.iddsc AND 
    b.vatTipoMem = 5
    
    
    
UNION ALL
SELECT a.IdMsg,  b.vatIdDzt, i.dztNome, '' AS UMS, 
     convert (varchar(10), g.vatValore, 20),
    --cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue,null as IdUms
FROM MSGVatMSG a, MSGValoriAttributi b, 
    MSGValoriAttributi_datetime g, 
    dizionarioattributi i
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    (b.vatidums IS NULL or b.vatIdUms = 0) AND 
    b.vatTipoMem = 5
    
    
    
UNION ALL
SELECT a.IdMsg,  b.vatIdDzt, i.dztNome, 
    cast(c.dscTesto AS varchar(5)) AS UMS, 
    cast(h.dsctesto AS varchar(500)) AS vatValore, 
    i.dztMultiValue,f.IdUms as IdUms
FROM MSGVatMSG a, MSGValoriAttributi b, descsi c, 
    unitamisura f, 
    MSGValoriAttributi_descrizioni g, descsi h, tipidatirange j,
    dizionarioattributi i
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    cast(g.vatiddsc as varchar(20)) = j.tdrCodice and
    h.iddsc = j.tdrIdDsc AND  
    i.dztIdTid =j.tdrIdTid and
    b.vatiddzt = i.iddzt AND 
    b.vatidums = f.idums AND f.umsiddscsimbolo = c.iddsc AND 
    b.vatTipoMem = 6
    
    
    
UNION ALL
SELECT a.IdMsg,  b.vatIdDzt, i.dztNome, '' AS UMS, 
    cast(h.dsctesto AS varchar(500)) AS vatValore, 
    i.dztMultiValue,null as IdUms
FROM MSGVatMSG a, MSGValoriAttributi b, 
    MSGValoriAttributi_descrizioni g, descsi h, tipidatirange j,
    dizionarioattributi i
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    cast(g.vatiddsc as varchar(20)) = j.tdrCodice and
    h.iddsc = j.tdrIdDsc AND  
    i.dztIdTid =j.tdrIdTid and
    b.vatiddzt = i.iddzt AND 
    (b.vatidums IS NULL or b.vatIdUms = 0) AND b.vatTipoMem = 6
    
    
    
UNION ALL
SELECT a.IdMsg,  b.vatIdDzt, i.dztNome, 
    cast(c.dscTesto AS varchar(5)) AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue,f.IdUms as IdUms
FROM MSGVatMSG a, MSGValoriAttributi b, descsi c, 
    unitamisura f, MSGValoriAttributi_keys g, 
    dizionarioattributi i
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    b.vatidums = f.idums AND f.umsiddscsimbolo = c.iddsc AND 
    b.vatTipoMem = 7
    
    
    
UNION ALL
SELECT a.IdMsg,  b.vatIdDzt, i.dztNome, '' AS UMS, 
    cast(g.vatValore AS varchar(500)) AS vatValore, 
    i.dztMultiValue,null as IdUms
FROM MSGVatMSG a, MSGValoriAttributi b, 
    MSGValoriAttributi_keys g, 
    dizionarioattributi i
WHERE a.idvat = g.idvat AND b.idvat = g.idvat AND 
    b.vatiddzt = i.iddzt AND 
    (b.vatidums IS NULL or b.vatIdUms = 0) AND 
    b.vatTipoMem = 7
    
    
    
GO
