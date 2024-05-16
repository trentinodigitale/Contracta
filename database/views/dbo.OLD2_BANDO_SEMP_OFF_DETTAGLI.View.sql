USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_BANDO_SEMP_OFF_DETTAGLI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[OLD2_BANDO_SEMP_OFF_DETTAGLI] as

	select d.* 
		from  Document_MicroLotti_Dettagli d
			inner join CTL_DOC b on b.TipoDoc = d.TipoDoc and d.idheader = b.id
		where b.TipoDoc like 'BANDO%'


GO
