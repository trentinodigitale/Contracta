USE [AFLink_TND]
GO
/****** Object:  View [dbo].[LISTA_OFFERTE_PER_LOTTO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[LISTA_OFFERTE_PER_LOTTO] as

	SELECT o.* 
			, o.tipodoc as OPEN_DOC_NAME
			, o.LinkedDoc as idHeader
			
			
			
			
			
			--, isnull(p1.[Value], az.aziRagioneSociale) as aziRagioneSociale
			,
			 case
				when DETT_GARA.DataScadenzaOfferta < getdate() then isnull(p1.[Value], az.aziRagioneSociale)
				else 
					case 
						when charindex(',aziRagioneSociale,' , ',' + HideCol_Bando_Gara_Lista_Offerte +',' ) > 0 then ''
						else isnull(p1.[Value], az.aziRagioneSociale)
					end 
			  end as aziRagioneSociale

			--, dm1.vatValore_FT as codicefiscale
			,case
				when DETT_GARA.DataScadenzaOfferta < getdate() then dm1.vatValore_FT 
				else 
					case 
						when charindex(',codicefiscale,' , ',' + HideCol_Bando_Gara_Lista_Offerte +',' ) > 0 then ''
						else dm1.vatValore_FT 
					end 
			  end as codicefiscale

			--, az.aziPartitaIVA
			,case
				when DETT_GARA.DataScadenzaOfferta < getdate() then aziPartitaIVA
				else 
					case 
						when charindex(',aziPartitaIVA,' , ',' + HideCol_Bando_Gara_Lista_Offerte +',' ) > 0 then ''
						else aziPartitaIVA 
					end 
			  end as aziPartitaIVA

			--, az.aziLocalitaLeg
			,case
				when DETT_GARA.DataScadenzaOfferta < getdate() then aziLocalitaLeg
				else 
					case 
						when charindex(',aziLocalitaLeg,' , ',' + HideCol_Bando_Gara_Lista_Offerte +',' ) > 0 then ''
						else aziLocalitaLeg 
					end 
			  end as aziLocalitaLeg

			--, az.aziE_Mail

			,case
				when DETT_GARA.DataScadenzaOfferta < getdate() then aziE_Mail
				else 
					case 
						when charindex(',aziE_Mail,' , ',' + HideCol_Bando_Gara_Lista_Offerte +',' ) > 0 then ''
						else aziE_Mail 
					end 
			  end as aziE_Mail

			, d.NumeroLotto
			, d.Descrizione
		FROM ctl_doc o with(nolock)
				inner join document_bando DETT_GARA with (nolock) on DETT_GARA.idHeader = o.LinkedDoc 
				INNER JOIN Document_MicroLotti_Dettagli d with(nolock) on d.IdHeader = o.id and d.TipoDoc = 'OFFERTA' and d.Voce = 0

				LEFT JOIN CTL_DOC p with(nolock) on p.LinkedDoc = o.id and p.TipoDoc = 'OFFERTA_PARTECIPANTI' and p.StatoFunzionale = 'Pubblicato' and p.deleted = 0
--				LEFT JOIN ctl_doc_value p1 with(nolock) on p1.idheader = p.id and p1.DSE_ID = 'TESTATA_RTI' and p1.DZT_Name = 'DenominazioneATI' and isnull(p1.value,'') <> ''
				LEFT JOIN ctl_doc_value p1 with(nolock,index( [ICX_CTL_DOC_VALUE_IdHeader_DSE_id_DZT_name])) on p1.idheader = p.id and p1.DSE_ID = 'TESTATA_RTI' and p1.DZT_Name = 'DenominazioneATI' and isnull(p1.value,'') <> ''

				LEFT JOIN document_offerta_partecipanti p2 with(nolock) ON p2.idheader = p.id and p2.Ruolo_Impresa = 'Mandataria' and p2.tiporiferimento='RTI'

				INNER JOIN aziende az with(nolock) on isnull(p2.IdAzi,o.Azienda) = az.IdAzi --Mandataria o azienda partecipante se non è in RTI
				INNER JOIN DM_Attributi dm1 with(nolock) ON dm1.lnk = az.idazi and dm1.dztNome = 'codicefiscale'
				
				--vado sui parametri a recuperare la lista delle colonne da nascondere su LISTA_OFFERTE
			    cross join ( select dbo.parametri('BANDO_GARA','LISTA_OFFERTE','HIDECOL','',-1) as HideCol_Bando_Gara_Lista_Offerte ) as H


		WHERE o.tipodoc in ('OFFERTA','OFFERTA_ASTA') and o.deleted = 0 and o.StatoFunzionale = 'Inviato' --and o.LinkedDoc=83835 and d.NumeroLotto = 1


GO
