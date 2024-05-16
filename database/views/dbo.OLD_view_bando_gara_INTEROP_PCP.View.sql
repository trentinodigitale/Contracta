USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_view_bando_gara_INTEROP_PCP]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_view_bando_gara_INTEROP_PCP] AS
	select a.* ,
			b.CN16_CODICE_APPALTO, b.cn16_AuctionConstraintIndicator, b.cn16_ContractingSystemTypeCode_framework,
			c.TipoAppaltoGara
	from Document_PCP_Appalto a
			inner join Document_E_FORM_CONTRACT_NOTICE  b on b.idHeader = a.idHeader
			inner join Document_Bando c on c.idHeader = a.idHeader
GO
