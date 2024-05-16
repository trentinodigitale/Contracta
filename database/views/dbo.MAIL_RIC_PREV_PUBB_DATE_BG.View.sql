USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_RIC_PREV_PUBB_DATE_BG]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MAIL_RIC_PREV_PUBB_DATE_BG]
AS
SELECT     idDOC, LNG, Pratica, DataInvio, Protocol, Importo, TipoDocumento, Tipologia, Oggetto, PEG, DatePubb
FROM         dbo.MAIL_RIC_PREV_PUBB

GO
