USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_LISTA_ESITO_DEFAULT]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
create view [dbo].[PDA_LISTA_ESITO_DEFAULT] as
select * from CTL_DOC where tipodoc = 'ESITO_DEFAULT' and deleted = 0
GO
