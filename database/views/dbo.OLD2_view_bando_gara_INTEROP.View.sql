USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_view_bando_gara_INTEROP]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD2_view_bando_gara_INTEROP] AS
	select a.* ,
			b.test_federico, b.pcp_PrevedeRipetizioniOpzioni, b.pcp_PrevedeRipetizioniCompl, b.pcp_Dl50, b.pcp_CodiceCUI
	from Document_E_FORM_CONTRACT_NOTICE a
			inner join Document_PCP_Appalto b on b.idHeader = a.idHeader
GO
