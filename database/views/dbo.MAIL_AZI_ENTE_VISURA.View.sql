USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_AZI_ENTE_VISURA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE VIEW [dbo].[MAIL_AZI_ENTE_VISURA]
AS
SELECT * ,dbo.GetNaturaGiuridica(aziiddscformasoc) as azinaturagiuridica ,'I' as lng   ,idazi as iddoc
FROM         aziende,profiliutente
where idazi=pfuidazi

GO
