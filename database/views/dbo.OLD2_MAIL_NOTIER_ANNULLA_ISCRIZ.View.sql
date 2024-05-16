USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_MAIL_NOTIER_ANNULLA_ISCRIZ]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD2_MAIL_NOTIER_ANNULLA_ISCRIZ] AS
	SELECT 
		  doc.id as iddoc,
		  'I' as LNG,
		  
		  doc.protocollo as registroDiSistema,
	  	  doc.note as motivazione,
		  doc.DataInvio,

		  pf.pfunome as compilatore
		  ,case 
				when JumpCheck = 'FATTURE' then '"Fatture"'
				when JumpCheck = '' then '"Ordini e DDT"'
				else  ''
			end as TipoDeregistrazione

	from CTL_DOC doc with(nolock)
		left join profiliutente pf with(nolock) ON pf.idpfu = doc.IdPfu
	where doc.TipoDoc='NOTIER_ANNULLA_ISCRIZ'



GO
