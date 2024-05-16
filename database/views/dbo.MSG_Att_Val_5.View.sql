USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MSG_Att_Val_5]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  view [dbo].[MSG_Att_Val_5] as 

	select m1.IdMsg , v1.vatIdDzt , va1.vatValore  
		from MSGVatMsg  m1 WITH (NOLOCK)
		inner join MSGValoriAttributi  v1 WITH (NOLOCK)  on m1.idvat = v1.idvat 
		inner join dbo.MSGValoriAttributi_Datetime   va1  WITH (NOLOCK) on m1.idvat = va1.idvat


GO
