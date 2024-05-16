USE [AFLink_TND]
GO
/****** Object:  View [dbo].[view_bando_gara_INTEROP]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[view_bando_gara_INTEROP] AS
	select a.* ,
			--b.test_federico,
			b.pcp_PrevedeRipetizioniOpzioni, 
			b.pcp_PrevedeRipetizioniCompl, 
			b.pcp_Dl50, b.pcp_CodiceCUI,
			b.pcp_lavoroOAcquistoPrevistoInProgrammazione
		
	from Document_E_FORM_CONTRACT_NOTICE a
			inner join Document_PCP_Appalto b on b.idHeader = a.idHeader
GO
