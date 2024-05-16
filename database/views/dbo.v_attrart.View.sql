USE [AFLink_TND]
GO
/****** Object:  View [dbo].[v_attrart]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[v_attrart]
as
select a.IdArt, a.artIdAzi, b.vatIdDzt, b.dztNome, b.ums, b.vatValore, b.dztMultiValue, b.IdUms, b.structDesc
  from v_attrArt1 b, v_attrArt2 a
 where a.idvat = b.idvat
GO
