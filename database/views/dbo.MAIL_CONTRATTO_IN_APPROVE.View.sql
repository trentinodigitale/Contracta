USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_CONTRATTO_IN_APPROVE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [dbo].[MAIL_CONTRATTO_IN_APPROVE] as

	select	CF.id as iddoc
			, lngSuffisso as LNG
			, convert( varchar , getdate() , 103 ) as DataOperazione
			, isnull( ML_Description , DOC_DescML ) as TipoDoc
			, CF.TipoDoc  as TipoDocumento
			, CF.Protocollo
			, isnull(CF.Body,'') as OggettoGara
			, CF.ProtocolloRiferimento as ProtocolloGara
			, a.aziRagioneSociale as aziragionesocialeforn
			, LBV2.DMV_DescML as StatoFunzionale
			, DB.CIG 
			, cv.value as Body
			, 'Procedure di Gara - Contratto' as cartella
			, p.pfuNome
			, isnull(LBV.DMV_DescML,'') as RuoloApprovatore
		from 
			ctl_doc CF with (nolock)
				inner join LIB_DomainValues LBV2 with(NOLOCK) on LBV2.DMV_DM_ID='Statofunzionale' and LBV2.DMV_Cod=CF.StatoFunzionale

				inner join profiliutente P with (nolock) on P.idpfu = CF.idPfu

				inner join ctl_doc_value CV with (nolock) on CV.IdHeader = CF.id and CV.DSE_ID ='CONTRATTO' and cv.DZT_Name ='BodyContratto'
												
				cross join Lingue with (nolock)
				left join aziende a with (nolock)  on a.idazi = CF.Destinatario_Azi
				inner join LIB_Documents with (nolock) on DOC_ID = CF.TipoDoc
				left outer join LIB_Multilinguismo with (nolock) on DOC_DescML = ML_KEY and ML_Context = 0 and ML_LNG = lngSuffisso
				LEFT join CTL_DOC B with (nolock) on B.Protocollo = CF.ProtocolloRiferimento and B.TipoDoc='BANDO_GARA' and B.Deleted=0
				LEFT join Document_Bando DB 	with (nolock) on DB.idHeader = B.Id 

				left join CTL_ApprovalSteps with (nolock) on aps_doc_type=CF.TipoDoc and aps_state='SENDAPPROVE' 
																and CF.id = APS_ID_DOC  and APS_IsOld = 0 
				
				left join LIB_DomainValues LBV with(NOLOCK) on LBV.DMV_DM_ID='UserRole' and LBV.DMV_Cod =APS_UserProfile

		where 
			CF.TipoDoc='CONTRATTO_GARA'  and CF.StatoFunzionale in ('inapprove' ) and CF.Deleted=0
	
		
GO
