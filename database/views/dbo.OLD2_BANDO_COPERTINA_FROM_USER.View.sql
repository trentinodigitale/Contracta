USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_BANDO_COPERTINA_FROM_USER]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
create view [dbo].[OLD2_BANDO_COPERTINA_FROM_USER] as 
select idpfu as ID_FROM , pfuidazi as Azienda from profiliutente
GO
