USE [AFLink_TND]
GO
/****** Object:  View [dbo].[view_test]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[view_test] as
	select 1 as id, 'TEST-RAGIONE-SOC' as RAGIONE_SOCIALE, 'TEST-SEDE LEGALE' as SEDE_LEGALE,'TEST-piva' as CODFIS_PIVA, 'federico' as federico
GO
