USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Bando_Riferimenti_view]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[Document_Bando_Riferimenti_view] as
	select rif.idRow,rif.idHeader, rif.RuoloRiferimenti,pfu.IdPfu,  pfu.pfuE_Mail , pfu.pfuTel, pfu.pfuCell 
		from Document_Bando_Riferimenti rif
			inner join profiliutente pfu ON rif.idpfu = pfu.idpfu


	



	-- select *  from Document_Bando_Riferimenti
GO
