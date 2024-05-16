USE [AFLink_TND]
GO
/****** Object:  View [dbo].[v_attrazi2]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_attrazi2]
AS
--select a.idvat, a.Idazi, cast(b.vatValore AS varchar(500)) as vatValore 
select a.idvat, a.Idazi, b.vatValore 
 from dfvatazi a, v_attrazi3 b 
where a.idvat = b.idvat
GO
