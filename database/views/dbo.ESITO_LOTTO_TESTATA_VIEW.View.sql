USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ESITO_LOTTO_TESTATA_VIEW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW
	[dbo].[ESITO_LOTTO_TESTATA_VIEW]
	as

	select 

		E.[Id], [IdPfu], [IdDoc], E.[TipoDoc], [StatoDoc], [Data], [Protocollo], [PrevDoc], [Deleted], [Titolo], [Body], 

		--[Azienda],
		case
			when o.TipoDoc ='RISPOSTA_CONCORSO' then 
			
				case 
					when isnull(AN.Value,'0') = '1' then E.Azienda
					else null
				end

			else
				E.Azienda
		
		end as Azienda,

		
		[StrutturaAziendale], [DataInvio], [DataScadenza], [ProtocolloRiferimento], [ProtocolloGenerale], [Fascicolo], [Note], [DataProtocolloGenerale], [LinkedDoc], [SIGN_HASH], [SIGN_ATTACH], [SIGN_LOCK], [JumpCheck], [StatoFunzionale], [Destinatario_User], [Destinatario_Azi], [RichiestaFirma], [NumeroDocumento], [DataDocumento], [Versione], [VersioneLinkedDoc], [GUID], [idPfuInCharge], [CanaleNotifica], [URL_CLIENT], [Caption], [FascicoloGenerale], [CRYPT_VER]
		from 

		ctl_doc E with (nolock)
			--salgo su lotto offerto
			inner join Document_MicroLotti_Dettagli L with (nolock) on l.id = E.LinkedDoc
			
			--salgo sulla pda per controllare se i dati sono in chairo
			inner join Document_PDA_OFFERTE o with (nolock) on L.idHeader = o.idrow 
			--inner join ctl_doc b with (nolock) on o.idheader = b.id
			left join CTL_DOC_VALUE AN with (nolock) on L.idHeader = AN.IdHeader and DSE_ID = 'ANONIMATO' and DZT_NAME = 'DATI_IN_CHIARO'
		
		where E.Tipodoc in ( 'ESITO_LOTTO_ANNULLA','ESITO_LOTTO_ESCLUSA','ESITO_LOTTO_VERIFICA')
GO
