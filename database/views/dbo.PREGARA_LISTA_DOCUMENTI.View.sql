USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PREGARA_LISTA_DOCUMENTI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [dbo].[PREGARA_LISTA_DOCUMENTI] as

	select  c.Id,c.IdPfu,c.IdDoc,
			
			case when c.TipoDoc in (  'PDA_MICROLOTTI' , 'RICHIESTA_CIG' , 'ANNULLA_RICHIESTA_CIG' ) and isnull( c.Caption , '' ) <> '' 
			THEN c.Caption else c.TipoDoc end as TipoDoc,

			c.StatoDoc,c.Data,c.Protocollo,c.PrevDoc,c.Deleted,c.Titolo,c.Body,c.Azienda,
			c.StrutturaAziendale,c.DataInvio,c.DataScadenza,c.ProtocolloRiferimento,c.ProtocolloGenerale,c.Fascicolo,c.Note,
			c.DataProtocolloGenerale,c.LinkedDoc,c.SIGN_HASH,c.SIGN_ATTACH,c.SIGN_LOCK,c.JumpCheck,
			case when C.tipodoc= 'RICHIESTA_ATTI_GARA' then c.StatoDoc else c.StatoFunzionale end as StatoFunzionale
			,c.Destinatario_User,
			c.Destinatario_Azi,c.RichiestaFirma,c.NumeroDocumento,c.DataDocumento,c.Versione,c.VersioneLinkedDoc,c.GUID,c.idPfuInCharge,
			c.CanaleNotifica,c.URL_CLIENT,c.Caption,c.FascicoloGenerale
			, c.tipodoc as OPEN_DOC_NAME
			, isnull( az1.aziRagionesociale, az2.aziRagioneSociale) as aziRagioneSociale

		from ctl_doc c with (nolock)
				inner join ctl_doc Pre_gara with (nolock) on Pre_gara.id= c.LinkedDoc  and pre_gara.tipodoc='PREGARA'
				left outer join  aziende az1 with (nolock) on c.azienda = az1.idazi
				left outer join  aziende az2 with (nolock) on c.Destinatario_Azi = az2.idazi
				left join document_bando b with(nolock) on b.idHeader = c.id

		where 
			c.tipodoc in ('RICHIESTA_CIG','RICHIESTA_SMART_CIG')
			and c.deleted = 0
					


	


GO
