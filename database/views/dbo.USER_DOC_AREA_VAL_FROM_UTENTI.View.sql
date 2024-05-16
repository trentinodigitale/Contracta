USE [AFLink_TND]
GO
/****** Object:  View [dbo].[USER_DOC_AREA_VAL_FROM_UTENTI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


---------------------------------------------------------------
--[OK] usate come view from nel doc USER_DOC nella sezione ruoli
---------------------------------------------------------------

CREATE view [dbo].[USER_DOC_AREA_VAL_FROM_UTENTI]
 as
select 
    a.attValue as AreaValutazione
    ,0 as Obbligatorio
    ,a.idpfu  AS ID_FROM
	,a.dataultimamod    
    from profiliutenteattrib a with (nolock)
    --left outer join profiliutenteattrib b on a.idpfu=b.idpfu and b.dztnome='UserRoleDefault' and
    --     a.attValue=b.attValue
		inner join LIB_DomainValues b with (nolock) on b.DMV_DM_ID = 'AreaValutazione' and b.DMV_Deleted = 0 and b.DMV_Cod = a.attValue 
     where a.dztnome='AreaValutazione'


GO
