USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_CARICA_MACROPRODOTTI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create VIEW
[dbo].[OLD_VIEW_CARICA_MACROPRODOTTI]
as

select *, jumpcheck as Ambito from ctl_doc where tipodoc='CARICA_MACROPRODOTTI'
GO
