USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_ControlliGara_DIR_RAPLEG]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view  [dbo].[Document_ControlliGara_DIR_RAPLEG] as
select distinct LocalitaDirTec , ProvinciaDirTec , CFDirTec ,DataDirTec,
	 idAziDirTec as idAziPartecipante,idAziDirTec as idAziPartecipanteHide, NomeDirTec , CognomeDirTec , TelefonoDirTec , EmailDirTec, RuoloDirTec, ResidenzaDirTec
	from  dbo.Document_Aziende_DirTec
	where not idAziDirTec is null and isold = 0 and CFDirTec + cast(idAziDirTec as varchar)  not in (select CFRapLeg + cast(idAziRapLeg as varchar) from  dbo.Document_Aziende_RapLeg
	where not idAziRapLeg is null and isold = 0)
union all
select distinct LocalitaRapLeg as  LocalitaDirTec , ProvinciaRapLeg as ProvinciaDirTec ,CFRapLeg as CFDirTec ,DataRapLeg as DataDirTec,
	 idAziRapLeg as idAziPartecipante,idAziRapLeg as idAziPartecipanteHide, NomeRapLeg as NomeDirTec , CognomeRapLeg as CognomeDirTec, TelefonoRapLeg as TelefonoDirTec, EmailRapLeg as EmailDirTec , RuoloRapLeg as RuoloDirTec, ResidenzaRapLeg as ResidenzaDirTec
	from  dbo.Document_Aziende_RapLeg
	where not idAziRapLeg is null and isold = 0


GO
