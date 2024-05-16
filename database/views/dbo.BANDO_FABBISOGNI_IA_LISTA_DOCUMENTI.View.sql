USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_FABBISOGNI_IA_LISTA_DOCUMENTI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [dbo].[BANDO_FABBISOGNI_IA_LISTA_DOCUMENTI] as 

	select d.idrow , 
			doc.[Id], doc.IdPfu, [IdDoc], case when DOC.TipoDoc = 'PROROGA_FABB' then 'PROROGA_FABB_IA' else doc.TipoDoc end as TipoDoc , [StatoDoc], [Data], [Protocollo], [PrevDoc], 
			[Deleted], [Titolo], [Body], [Azienda], [StrutturaAziendale], [DataInvio], [DataScadenza], 
			[ProtocolloRiferimento], [ProtocolloGenerale], [Fascicolo], [Note], 
			[DataProtocolloGenerale], [LinkedDoc], [SIGN_HASH], [SIGN_ATTACH], [SIGN_LOCK], 
			[JumpCheck], [StatoFunzionale], [Destinatario_User], [Destinatario_Azi], [RichiestaFirma], 
			[NumeroDocumento], [DataDocumento], [Versione], [VersioneLinkedDoc], [GUID], [idPfuInCharge], [CanaleNotifica], 
			[URL_CLIENT], [Caption], [FascicoloGenerale], 
			case when DOC.OPEN_DOC_NAME = 'PROROGA_FABB' then 'PROROGA_FABB_IA' else doc.OPEN_DOC_NAME end as [OPEN_DOC_NAME], 
			doc.aziRagioneSociale
			, isnull( m.ML_Description, lib.doc_descml) as Tipo

		from CTL_DOC_Destinatari d with(nolock) 
			inner join BANDO_SDA_LISTA_DOCUMENTI doc on doc.LinkedDoc = d.idheader 

			inner join LIB_Documents lib on lib.DOC_ID = doc.TipoDoc
			left  join LIB_Multilinguismo m with(nolock) on m.ML_LNG = 'I' and m.ML_KEY = lib.DOC_DescML

		where tipoDoc = 'PROROGA_FABB'  AND DOC.StatoFunzionale <> 'InLavorazione'
	
	UNION ALL -- aggiungiamo le comunicazioni  generiche

		select d.idrow , 
			c.[Id], c.IdPfu, c.[IdDoc], c.TipoDoc , c.[StatoDoc], c.[Data], c.[Protocollo], c.[PrevDoc], 
				c.[Deleted], c.[Titolo], c.[Body], c.[Azienda], c.[StrutturaAziendale], c.[DataInvio], c.[DataScadenza], 
				c.[ProtocolloRiferimento], c.[ProtocolloGenerale], c.[Fascicolo], c.[Note], 
				c.[DataProtocolloGenerale], c.[LinkedDoc], c.[SIGN_HASH], c.[SIGN_ATTACH], c.[SIGN_LOCK], 
				c.[JumpCheck], c.[StatoFunzionale], c.[Destinatario_User], c.[Destinatario_Azi], c.[RichiestaFirma], 
				c.[NumeroDocumento], c.[DataDocumento], c.[Versione], c.[VersioneLinkedDoc], c.[GUID], c.[idPfuInCharge], c.[CanaleNotifica],
				c.[URL_CLIENT], c.[Caption], c.[FascicoloGenerale], 
				c.tipodoc as OPEN_DOC_NAME,
				az1.aziRagioneSociale

				, dbo.cnv('Comunicazione Fabbisogni','i') as Tipo

		from CTL_DOC_Destinatari d with(nolock ) -- dalla riga che identifica per il destinatario il bando fabbisogni
					inner join ctl_doc Com with(nolock )  on Com.linkeddoc = d.idheader and Com.TipoDoc='PDA_COMUNICAZIONE_GENERICA' -- si prendono le comunicazioni
					inner join ctl_doc C  with(nolock )  on C.linkeddoc = com.id and C.TipoDoc='PDA_COMUNICAZIONE_GARA' and d.IdAzi = C.DEstinatario_azi-- si prendono le comunicazioni dedicate allo specifico ente
					left outer join  aziende az1 with (nolock) on d.IdAzi = az1.idazi

					--inner join LIB_Documents doc on doc.DOC_ID = c.TipoDoc
					--left  join LIB_Multilinguismo m with(nolock) on m.ML_LNG = 'I' and m.ML_KEY = doc.DOC_DescML

			where c.deleted = 0 
			and c.StatoFunzionale not in ( 'Annullato' , 'InLavorazione')
			

	UNION ALL -- aggiungiamo le risposte alle comunicazioni 

		select d.idrow , 
			r.[Id], com.IdPfu, r.[IdDoc], 
				'FABBISOGNI_COMUNICAZIONE_GENERICA' as TipoDoc , 
				r.[StatoDoc], r.[Data], r.[Protocollo], r.[PrevDoc], 
				r.[Deleted], r.[Titolo], r.[Body], r.[Azienda], r.[StrutturaAziendale], r.[DataInvio], r.[DataScadenza], 
				r.[ProtocolloRiferimento], r.[ProtocolloGenerale], r.[Fascicolo], r.[Note], 
				r.[DataProtocolloGenerale], r.[LinkedDoc], r.[SIGN_HASH], r.[SIGN_ATTACH], r.[SIGN_LOCK], 
				r.[JumpCheck], r.[StatoFunzionale], r.[Destinatario_User], r.[Destinatario_Azi], r.[RichiestaFirma], 
				r.[NumeroDocumento], r.[DataDocumento], r.[Versione], r.[VersioneLinkedDoc], r.[GUID], r.[idPfuInCharge], r.[CanaleNotifica],
				r.[URL_CLIENT], r.[Caption], r.[FascicoloGenerale], 
				r.tipodoc as OPEN_DOC_NAME,
				az1.aziRagioneSociale

				, dbo.CNV('FABBISOGNI_COMUNICAZIONE_GENERICA','I') as Tipo

			from CTL_DOC_Destinatari d with(nolock )
					inner join ctl_doc Com with(nolock )  on Com.linkeddoc = d.idheader and Com.TipoDoc='PDA_COMUNICAZIONE_GENERICA' -- si prendono le comunicazioni
					inner join ctl_doc C  with(nolock )  on C.linkeddoc = com.id and C.TipoDoc='PDA_COMUNICAZIONE_GARA' and d.IdAzi = C.DEstinatario_azi-- si prendono le comunicazioni dedicate allo specifico ente
					inner join ctl_doc r with(nolock) on r.LinkedDoc = c.Id and r.TipoDoc = 'PDA_COMUNICAZIONE_RISP' and r.Deleted = 0
					left outer join  aziende az1 with (nolock) on d.IdAzi = az1.idazi
			where c.deleted = 0 
			
			
			--and r.StatoFunzionale <> 'InLavorazione'


GO
