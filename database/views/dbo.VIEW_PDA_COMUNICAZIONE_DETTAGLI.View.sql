USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_PDA_COMUNICAZIONE_DETTAGLI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[VIEW_PDA_COMUNICAZIONE_DETTAGLI] as
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
		C.ProtocolloRiferimento,
		dbo.StripHTML( C.Note ) as Note, 
		C.Protocollo,
		C.Deleted as Seleziona_Deleted ,
		C.versionelinkeddoc as Ruolo_Impresa,
		C.versionelinkeddoc as Descrizione,
		RIS.Value as Progressivo_Risposta
	from 
		CTL_DOC C with(nolock)
			left outer  join aziende with(nolock) on idazi=C.Destinatario_azi
			left outer join ctl_doc P with(nolock) on P.id=C.LinkedDoc and P.TipoDoc in ('PDA_COMUNICAZIONE_GENERICA') 
			left outer join CTL_DOC_VALUE RIS on c.id = RIS.IdHeader and DSE_ID = 'ANONIMATO' and Row = 0 and DZT_Name = 'Progressivo_Risposta'

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
