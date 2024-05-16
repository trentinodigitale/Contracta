USE [AFLink_TND]
GO
/****** Object:  View [dbo].[v_attrart4]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[v_attrart4]
as
select IdVat, cast(dsctesto AS varchar(500)) as dscTesto, tdridtid
  from valoriattributi_descrizioni, descsi, tipiDatiRange
 where cast(vatiddsc as varchar(20)) = tdrCodice 
   and tdriddsc = iddsc
GO
