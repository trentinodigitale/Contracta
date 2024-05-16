USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_REJECTED]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[OLD_MAIL_REJECTED]
AS
		SELECT		CTL_Mail_System.id AS idDOC, 
					'I' AS LNG, 
					--mailto as eMail, 
					isnull(CTL_CONFIG_MAIL.MailFrom,'') as eMail,

					-- controllo per impedire che la lunghezza totale superi 500
					-- ho disponibili 405 chr.
					replace(replace(case when len(isnull(MailObject,''))<=405 then isnull(MailObject,'')
						else substring(isnull(MailObject,''),1,403) + '...'
					end , 'GUID=[', 'GUID=') , ']','')	as eMailSubject,

					'' as VALUE

		FROM         CTL_Mail_System with (nolock)

			left join LIB_Dictionary l1 with (nolock) on l1.dzt_name = 'SYS_MAILFROM_PEC'
			left join LIB_Dictionary l2 with (nolock) on l2.dzt_name = 'SYS_MAILFROM'
			left join  CTL_CONFIG_MAIL on  Alias = ISNULL(l1.dzt_valuedef,l2.dzt_valuedef)



GO
