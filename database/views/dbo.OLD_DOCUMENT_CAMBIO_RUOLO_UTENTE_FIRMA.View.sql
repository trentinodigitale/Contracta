USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DOCUMENT_CAMBIO_RUOLO_UTENTE_FIRMA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_DOCUMENT_CAMBIO_RUOLO_UTENTE_FIRMA] as
select 
	C.*,
	Dm.vatValore_FT as CFRapLeg

from ctl_doc C
inner join ProfiliUtente P on P.IdPfu=C.IdPfu
left join DM_Attributi DM on DM.lnk=P.pfuIdAzi and DM.dztNome='CFRapLeg'
where C.tipodoc='CAMBIO_RUOLO_UTENTE'
GO
