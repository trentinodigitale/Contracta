USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_QF_COPERTINA_FROM_USER]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




create view [dbo].[BANDO_QF_COPERTINA_FROM_USER] as 
select idpfu as ID_FROM , pfuidazi as Azienda from profiliutente
GO
