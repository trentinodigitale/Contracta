USE [AFLink_TND]
GO
/****** Object:  View [dbo].[USER_DOC_ROLE_FROM_UTENTI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[USER_DOC_ROLE_FROM_UTENTI] AS
	select a.attValue as UserRole
			, case when b.attValue is null then 0 else 1 end as Obbligatorio
			, a.idpfu  AS ID_FROM
			, a.dataultimamod   
			, case when ( b.attValue = 'RESPONSABILE_PEPPOL' or a.attValue = 'RESPONSABILE_PEPPOL' ) then ' FNZ_DEL UserRole ' else '' end as Not_Editable
		from profiliutenteattrib a with(nolock)
				left outer join profiliutenteattrib b with(nolock) on a.idpfu=b.idpfu and b.dztnome='UserRoleDefault' and a.attValue=b.attValue
		where a.dztnome='UserRole'
GO
