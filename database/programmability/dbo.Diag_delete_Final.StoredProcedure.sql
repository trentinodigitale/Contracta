USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Diag_delete_Final]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Diag_delete_Final]
as 
 begin tran 
 
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[CreateCheckOrders]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
      drop procedure [dbo].[CreateCheckOrders]
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[MIk_CheckOrders1Cod222]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
      drop table [dbo].[MIk_CheckOrders1Cod222]
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[MIk_CheckOrders2Cod222]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
      drop table [dbo].[MIk_CheckOrders2Cod222]
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[MIk_CheckOrders1Cod223]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
      drop table [dbo].[MIk_CheckOrders1Cod223]
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[MIk_CheckOrders2Cod223]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
      drop table [dbo].[MIk_CheckOrders2Cod223]
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[MIk_CheckOrders1Cod322]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
      drop table [dbo].[MIk_CheckOrders1Cod322]
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[MIk_CheckOrders2Cod322]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
      drop table [dbo].[MIk_CheckOrders2Cod322]
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[MIk_CheckOrders1Cod323]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
      drop table [dbo].[MIk_CheckOrders1Cod323]
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[MIk_CheckOrders2Cod323]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
      drop table [dbo].[MIk_CheckOrders2Cod323]
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[MIk_CheckOrders1Cod422]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
      drop table [dbo].[MIk_CheckOrders1Cod422]
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[MIk_CheckOrders2Cod422]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
      drop table [dbo].[MIk_CheckOrders2Cod422]
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[MIk_CheckOrders1Cod423]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
      drop table [dbo].[MIk_CheckOrders1Cod423]
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[MIk_CheckOrders2Cod423]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
      drop table [dbo].[MIk_CheckOrders2Cod423]
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[DiagnosticaOrdCod1Itype22]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DiagnosticaOrdCod1Itype22]
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[DiagnosticaOrdCod1Itype23]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DiagnosticaOrdCod1Itype23]
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[DiagnosticaOrdCod2Itype22]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DiagnosticaOrdCod2Itype22]
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[DiagnosticaOrdCod2Itype23]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DiagnosticaOrdCod2Itype23]
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[DiagnosticaOrdCod3Itype22]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DiagnosticaOrdCod3Itype22]
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[DiagnosticaOrdCod3Itype23]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DiagnosticaOrdCod3Itype23]
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[DiagnosticaOrdCod4Itype22]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DiagnosticaOrdCod4Itype22]
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[DiagnosticaOrdCod4Itype23]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DiagnosticaOrdCod4Itype23]
commit tran
GO
