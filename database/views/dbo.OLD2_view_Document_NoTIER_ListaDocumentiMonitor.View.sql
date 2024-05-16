USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_view_Document_NoTIER_ListaDocumentiMonitor]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[OLD2_view_Document_NoTIER_ListaDocumentiMonitor] as
	select a.*, c.idpfu as idOwner, 
			--isnull( e.aziRagioneSociale, '' ) as aziRagioneSociale, 
			case when isnull( e.aziRagioneSociale, '' ) <> '' then e.aziRagioneSociale else a.RagioneSocialeMittente end as aziRagioneSociale,
			case when STATOGIACENZA = 'DA_RECAPITARE' then 1 else 0 end as bread
			, a.idazi as Fornitore
		from Document_NoTIER_ListaDocumenti a with(nolock)
				INNER JOIN aziende b with(nolock) ON a.idazi = b.idazi 
				cross join MarketPlace m with(nolock) 
				INNER JOIN profiliutente c with(nolock) ON c.pfuidazi = m.mpIdAziMaster

				LEFT JOIN ( 
						
						select min(lnk) as lnk, 
								vatValore_FT 
							from DM_Attributi with(nolock) 
							where dztNome = 'codicefiscale' 
							group by vatValore_FT 
						
						) as b3 on b3.vatValore_FT = a.CHIAVE_CODICEFISCALEMITTENTE

				LEFT JOIN ( 
						
							select min(a.lnk) as lnk ,
								 a.vatValore_FT 
							from DM_Attributi  a with(nolock) 
									inner join DM_Attributi b with(nolock) on b.lnk = a.lnk and b.dztNome = 'PARTICIPANTID'
							where a.dztNome = 'codicefiscale' 
							group by a.vatValore_FT 
						
						) as b4 on b4.vatValore_FT = a.CHIAVE_CODICEFISCALEMITTENTE

				LEFT JOIN DM_Attributi b5 with(nolock) ON a.IDPEPPOLMITTENTE is not null and B5.vatValore_FT = a.IDPEPPOLMITTENTE and b5.dztNome = 'PARTICIPANTID' 

				-- vado in left join sull'azienda privilegiando prima il match sul partcipantID del mittente, poi quelle con CF e partecipantid, poi vado in match solo sul codice fiscale
				LEFT JOIN aziende e with(nolock) on COALESCE(B5.lnk, B4.lnk, b3.lnk) = e.idazi and e.aziDeleted = 0 

		where a.deleted = 0

GO
