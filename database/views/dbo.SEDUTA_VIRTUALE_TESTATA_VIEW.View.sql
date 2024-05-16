USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SEDUTA_VIRTUALE_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[SEDUTA_VIRTUALE_TESTATA_VIEW]
as
			select sv.id,sv.ProtocolloRiferimento, sv.Body, p.StatoFunzionale
			   from ctl_doc sv WITH(NOLOCK)
					 inner join ctl_doc b WITH(NOLOCK) on b.id = sv.LinkedDoc
					 inner join ctl_doc p WITH(NOLOCK) on b.id = p.LinkedDoc and p.deleted = 0 and p.tipodoc in ('PDA_MICROLOTTI','PDA_CONCORSO')
					 left join Document_PDA_OFFERTE op WITH(NOLOCK) on op.idheader = p.id and op.idAziPartecipante = sv.Azienda
GO
