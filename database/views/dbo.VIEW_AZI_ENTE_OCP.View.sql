USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_AZI_ENTE_OCP]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VIEW_AZI_ENTE_OCP] AS
	select  a.idAzi,
			b.vatValore_FT as Attiva_OCP,
			c.vatValore_FT as DataAttivazioneOCP
		from aziende a with(nolock)
				left join dm_attributi b with(nolock) ON b.lnk = a.IdAzi and b.dztNome = 'Attiva_OCP'
				left join dm_attributi c with(nolock) ON c.lnk = a.IdAzi and c.dztNome = 'DataAttivazioneOCP'

GO
