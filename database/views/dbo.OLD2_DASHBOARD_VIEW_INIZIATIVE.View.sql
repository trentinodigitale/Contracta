USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_INIZIATIVE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_DASHBOARD_VIEW_INIZIATIVE] as 
	SELECT  id , StatoFunzionale , cast(NumeroDocumento as BIGINT) as NumeroDocumento , isnull( Body , titolo ) as Titolo 
		FROM ctl_doc C 
		WHERE isnumeric(numerodocumento) = 1 and TipoDoc = 'INIZIATIVA' and deleted = 0



GO
