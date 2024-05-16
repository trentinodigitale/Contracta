USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PUBBLICITA_LEGALE_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[PUBBLICITA_LEGALE_TESTATA_VIEW] AS


	select 
			

			c.[Id], c.[IdPfu], [IdDoc], [TipoDoc], [StatoDoc], [Data], [Protocollo], [PrevDoc], c.[Deleted], [Titolo], [Body], [Azienda], [StrutturaAziendale], c.[DataInvio], [DataScadenza], [ProtocolloRiferimento], [ProtocolloGenerale], [Fascicolo], [Note], [DataProtocolloGenerale], [LinkedDoc], [SIGN_HASH], [SIGN_ATTACH], [SIGN_LOCK], [JumpCheck], [StatoFunzionale], [Destinatario_User], [Destinatario_Azi], [RichiestaFirma], [NumeroDocumento], [DataDocumento], [Versione], [VersioneLinkedDoc], [GUID], [idPfuInCharge], [CanaleNotifica], [URL_CLIENT],
			 'Richiesta_Preventivo_' + JumpCheck  as  [Caption], dr.protocol,
			 
			 [FascicoloGenerale], [CRYPT_VER],

			isnull( r.rel_valueoutput , '' ) as AT_Rifiuta,
			cast(c.azienda as varchar(20))+'#\0000\0000' as EnteProponente,
			v2.value as RupProponente,
			CV.Value as Not_Editable
			, v2.Value as UserRUP,
			dr.pratica,
			cds.F1_SIGN_ATTACH,cds.F1_SIGN_HASH,cds.F1_SIGN_LOCK,
			cds.F2_SIGN_ATTACH,cds.F2_SIGN_HASH,cds.F2_SIGN_LOCK,
			--, dbo.GetElenco_PI (v2.Value  ,'RUP,RUP_PDG' ) as IdPfuCreaGara
			

			case when  (
							
							( StatoFunzionale <> 'PreventivoLavorato')
							or
							( StatoFunzionale = 'PreventivoLavorato' and Tipologia = '4' and  idPfuInCharge  =  c.IdPfu ) 
							or 
							( StatoFunzionale = 'PreventivoLavorato' and Tipologia <> '4' and  p.IdPfu is not null ) 
						) 
				then 1 else 0
				end as AT_send
			,Tipologia

		from CTL_DOC C 
			left join CTL_DOC_Value CV on CV.IdHeader=C.Id and CV.DSE_ID='NOT_EDITABLE' and CV.DZT_Name='Not_Editable'
			left join Document_RicPrevPubblic dr with(nolock)  on dr.IdHeader=c.id
			--left join Document_Bando DB   on DB.idHeader=C.id
			left outer join CTL_DOC_Value v2 with(nolock) on c.Id = v2.idheader and v2.dzt_name = 'RupProponente' and v2.DSE_ID = 'CRITERI_ECO' --'InfoTec_comune'
			left join  CTL_Relations r with(nolock) on r.REL_Type='DOCUMENT_PUBB_LEG_ATTIVA_TOOLBAR_For_Stato'  and r.REL_ValueInput = 'RIFIUTA' 
			--verifichiamo se l'utente in carico ha il ruolo membro ufficio appalti
			left join ProfiliUtenteAttrib p  with(nolock) on c.idPfuInCharge = p.IdPfu and attValue='UFFICIO_APPALTI' and p.dztNome ='UserRole'
			
			left join  CTL_DOC_SIGN cds with(nolock) on cds.idHeader=c.id
		where TipoDoc in ('PUBBLICITA_LEGALE','PUBBLICITA_LEGALE_RIFIUTA')

		
GO
