USE [AFLink_TND]
GO
/****** Object:  View [dbo].[USER_DOC_ROLE_FROM_AZIENDA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------
--[OK] usate come view from nel doc USER_DOC nella sezione ruoli
---------------------------------------------------------------

CREATE view [dbo].[USER_DOC_ROLE_FROM_AZIENDA]
 as
 select 
    '' as UserRole
    ,'' as Obbligatorio
    ,0  AS ID_FROM
    
GO
