USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_NOTIER_ISCRIZ_FATTURE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_NOTIER_ISCRIZ_FATTURE] AS
	select c.*
			, TipoDoc as OPEN_DOC_NAME
			, p2.idpfu as owner
			, p.pfunome as nome
	from ctl_doc c with(nolock)
			left join profiliutente p with(nolock) on c.idpfu = p.idpfu
			left join aziende a with(nolock) on a.idazi = p.pfuidazi
			left join profiliutente p2 with(nolock) on p2.pfuidazi = a.idazi
	where tipodoc='NOTIER_ISCRIZ' and deleted=0 and JumpCheck = 'FATTURE'

GO
