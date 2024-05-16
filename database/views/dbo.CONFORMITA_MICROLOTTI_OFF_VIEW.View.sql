USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONFORMITA_MICROLOTTI_OFF_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[CONFORMITA_MICROLOTTI_OFF_VIEW] as

select C.StatoRiga,CD.* from ctl_doc CD
		inner join document_microlotti_dettagli C on C.id=CD.LinkedDoc and C.TipoDoc='CONFORMITA_MICROLOTTI'
	where CD.tipodoc='CONFORMITA_MICROLOTTI_OFF'
	
GO
