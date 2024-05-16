USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_USER_DOC_ROLE_FROM_UTENTI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------
--[OK] usate come view from nel doc USER_DOC nella sezione ruoli
---------------------------------------------------------------

CREATE view [dbo].[OLD_USER_DOC_ROLE_FROM_UTENTI]
 as
select 
    a.attValue as UserRole
    ,case when b.attValue is null then 0
    else 1 end as Obbligatorio
    ,a.idpfu  AS ID_FROM
	,a.dataultimamod    
    from profiliutenteattrib a
    left outer join profiliutenteattrib b on a.idpfu=b.idpfu and b.dztnome='UserRoleDefault' and
         a.attValue=b.attValue
     where a.dztnome='UserRole'
GO
