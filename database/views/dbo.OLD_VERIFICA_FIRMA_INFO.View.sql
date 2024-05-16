USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VERIFICA_FIRMA_INFO]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_VERIFICA_FIRMA_INFO] AS
	select a.*, b.ATT_AlgoritmoHash , b.ATT_FileHash
		from CTL_SIGN_ATTACH_INFO a with(nolock)
				LEFT join CTL_Attach b with(nolock) on b.ATT_Hash = a.ATT_Hash
GO
