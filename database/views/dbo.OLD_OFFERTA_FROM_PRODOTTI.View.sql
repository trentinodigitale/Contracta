USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_OFFERTA_FROM_PRODOTTI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[OLD_OFFERTA_FROM_PRODOTTI] as
select guid , p.id as id  
	from Document_MicroLotti_Dettagli P
		inner join ctl_doc D on d.id = idheader 

GO
