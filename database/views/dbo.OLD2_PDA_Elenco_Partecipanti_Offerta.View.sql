USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_PDA_Elenco_Partecipanti_Offerta]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  view [dbo].[OLD2_PDA_Elenco_Partecipanti_Offerta] as 
		select distinct   isnull( r.IdAzi , idazipartecipante ) as idazi , o.idrow , a.aziRagioneSociale, 
				case 
					when ISNULL(Ruolo_impresa,'')='' then 'Mandataria' 
					when Ruolo_impresa = 'RTI' then 'Mandataria' 
					when Ruolo_impresa='AUSILIARIE' then 'Ausiliaria' 
					when Ruolo_impresa='SUBAPPALTO' then 'Subappaltatore' 
					when Ruolo_impresa  = 'ESECUTRICI' then 'Esecutrice'  
						else Ruolo_impresa 
				end as Ruolo_impresa
		
			from Document_PDA_OFFERTE o
				left outer join CTL_DOC p on p.LinkedDoc = o.IdMsg  and p.TipoDoc = 'OFFERTA_PARTECIPANTI' and p.StatoFunzionale = 'Pubblicato' and deleted = 0
				--left outer join document_offerta_partecipanti r on r.IdHeader = o.IdMsgFornitore
				left outer join (
						select azienda as idazi, id as idheader,NULL as Ruolo_impresa  from CTL_DOC where tipodoc = 'OFFERTA_PARTECIPANTI' and StatoFunzionale = 'Pubblicato' and deleted = 0
						union 
						select idazi , idheader ,
							case 
								when TipoRiferimento='RTI' and Ruolo_Impresa='Mandante' then 'Mandante' 
									else TipoRiferimento 
							end as Ruolo_impresa 
						from  document_offerta_partecipanti 
					) as r on r.IdHeader = p.id
				inner join aziende a on  isnull( r.IdAzi , idazipartecipante ) = a.idazi
			--where  o.idrow = @idRow




GO
