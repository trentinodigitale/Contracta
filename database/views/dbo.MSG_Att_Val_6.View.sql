USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MSG_Att_Val_6]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[MSG_Att_Val_6] as
select m1.IdMsg , v1.vatIdDzt , va1.vatIdDsc , va1.vatIdDsc as vatValore
		from MSGVatMsg m1 WITH (NOLOCK)
		inner join MSGValoriAttributi v1 WITH (NOLOCK) on m1.idvat = v1.idvat 
		inner join MSGValoriAttributi_Descrizioni va1 WITH (NOLOCK) on m1.idvat = va1.idvat


GO
