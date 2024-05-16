USE [AFLink_TND]
GO
/****** Object:  View [dbo].[v_attrazi3]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_attrazi3]
AS
SELECT idvat, cast(vatValore AS varchar(500)) AS vatValore
FROM valoriattributi_int
UNION ALL
SELECT idvat, cast(vatValore AS varchar(500)) AS vatValore
FROM valoriattributi_money
UNION ALL
SELECT idvat, cast(vatValore AS varchar(500)) AS vatValore
FROM valoriattributi_float
UNION ALL
SELECT idvat, vatValore
FROM valoriattributi_nvarchar
UNION ALL
SELECT idvat, cast(vatValore AS varchar(500)) AS vatValore
FROM valoriattributi_datetime
UNION ALL
SELECT a.idvat, dsctesto AS vatValore
FROM valoriattributi_descrizioni a, tipidatirange, descsi, valoriattributi b, dizionarioattributi, appartenenzaattributi
where a.idvat = b.idvat
 and b.vatiddzt = IdDzt
 and apatIdDzt = IdDzt 
 and dztIdTid = tdrIdTid
 and cast(a.vatIdDsc as varchar(20)) = tdrCodice
 and tdrIdDsc = iddsc
 and apatIdApp = 1
UNION ALL
SELECT idvat, cast(vatValore AS varchar(500)) AS vatValore
FROM valoriattributi_keys
GO
