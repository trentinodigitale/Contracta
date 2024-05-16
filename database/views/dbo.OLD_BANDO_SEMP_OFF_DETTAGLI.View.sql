USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_BANDO_SEMP_OFF_DETTAGLI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_BANDO_SEMP_OFF_DETTAGLI] as

	select d.* 
		from  Document_MicroLotti_Dettagli d
			inner join CTL_DOC b on b.TipoDoc = d.TipoDoc and d.idheader = b.id
		where b.TipoDoc like 'BANDO%' or b.TipoDoc like 'TEMPLATE%' 

GO
