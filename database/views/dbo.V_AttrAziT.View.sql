USE [AFLink_TND]
GO
/****** Object:  View [dbo].[V_AttrAziT]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_AttrAziT]
AS
SELECT b.IdAzi, a.vatIdDzt, a.dztNome, 
       a.UMS, 
       a.vatValore , 
       a.dztMultiValue
from DFVatAzi b, v_AttrAziT1 a
where b.IdVat = a.IdVat
     
GO
