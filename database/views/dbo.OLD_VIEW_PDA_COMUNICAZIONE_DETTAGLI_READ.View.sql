USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_PDA_COMUNICAZIONE_DETTAGLI_READ]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[OLD_VIEW_PDA_COMUNICAZIONE_DETTAGLI_READ] as
select 
		C.Id,
		C.LinkedDoc,
		AziRagioneSociale,
		C.StatoFunzionale,
		C.DataInvio,
		C.ID as GridViewer_ID_DOC,
		C.tipodoc as OPEN_DOC_NAME,
		C.Titolo,
        C.StatoDoc,
		case
			when isnull(G.TipoDoc ,'') not in ( 'BANDO_CONCORSO','PDA_CONCORSO' ) then C.ProtocolloRiferimento  -- com prima
			
			else
				--sul BANDO_CONCORSO/PDA_CONCORSO vedo se sulla risposta i dati sono in chiaro
				case 
					when isnull(ra.value,'')='1' then C.ProtocolloRiferimento
					else ''
				end 
		end as ProtocolloRiferimento,
		--C.ProtocolloRiferimento,
		dbo.StripHTML( C.Note ) as Note, 
		
		--condizionare il ritorno del protocollo al fatto che 
		--se la comunicazion è legata ad un BANDO_CONCORSO allora 
		--devo ritornare l'informazione solo se nella risposta del fornitore 
		--i dati sono in chiaro
		--DSE_ID='ANONIMATO' ,  DZT_NAME='DATI_IN_CHIARO'  e row=0
		
		case
			when isnull(G.TipoDoc ,'') not in ( 'BANDO_CONCORSO','PDA_CONCORSO' ) then C.Protocollo  -- com prima
			
			else
				--sul BANDO_CONCORSO/PDA_CONCORSO vedo se sulla risposta i dati sono in chiaro
				case 
					when isnull(ra.value,'')='1' then C.Protocollo
					else ''
				end 
		end as Protocollo,

		--C.Protocollo,
		cast(C.Deleted as varchar(10)) as Seleziona_Deleted,
		v.value as NumeroDocumento,
		C.versionelinkeddoc as Ruolo_Impresa,
		C.versionelinkeddoc as Descrizione,
		PO.value as Progressivo_Risposta
	from 
		CTL_DOC C with (nolock)

			left outer  join aziende with (nolock) on idazi=C.Destinatario_azi
			
			left outer join ctl_doc P with (nolock) on P.id=C.LinkedDoc and P.TipoDoc in ('PDA_COMUNICAZIONE_GENERICA') 
			
			--salgo sul concorso/pda_concorso
			left outer join ctl_doc G with (nolock) on G.id = P.LinkedDoc --and G.Tipodoc='BANDO_CONCORSO'

			--salgo sulla risposta al concorso del fornitore della comunicazione
			left outer join ctl_doc R with (nolock) on 
			
				( 
					( R.LinkedDoc = G.id  and  G.tipodoc = 'BANDO_CONCORSO')

					or
					( R.LinkedDoc = G.LinkedDoc  and  G.tipodoc = 'PDA_CONCORSO')
					
				) and R.Tipodoc = 'RISPOSTA_CONCORSO' and R.azienda = C.Destinatario_azi and R.StatoDoc ='Sended'

			left outer join ctl_doc_value RA with (nolock) on RA.idheader = R.id and RA.DSE_ID = 'ANONIMATO' and RA.DZT_NAME='DATI_IN_CHIARO' and RA.Row=0

			left outer join ctl_doc_value v with (nolock) on v.idheader = c.id and v.DSE_ID =  'SORTEGGIO' and v.DZT_Name = 'NumeroDocumento'  and v.Row = 0 
			
			left outer join ctl_doc_value PO with (nolock) on PO.idheader = c.id and PO.DSE_ID =  'ANONIMATO' and PO.DZT_Name = 'PROGRESSIVO_RISPOSTA'  and PO.Row = 0 

	where C.tipodoc in ( 'PDA_COMUNICAZIONE_GARA' 
						, 'PDA_COMUNICAZIONE_OFFERTA' 
						, 'PDA_SORTEGGIO_OFFERTA' 
						)   
			and (
					isnull(P.StatoFunzionale,'') = 'InLavorazione' 
					or
					( isnull(P.StatoFunzionale,'') <> 'InLavorazione' and C.deleted <> 1 )
				)

			--escludiamo le comunicazioni figlie senza capogruppo non imperniate sulla ctl_doc
			--comunicazioni sospensione albo (imperniate su idrow della ctl_doc_destinatari)
			and C.JumpCheck not in ('0-SOSPENSIONE_ALBO')


GO
