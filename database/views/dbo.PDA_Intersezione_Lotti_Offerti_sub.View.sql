USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_Intersezione_Lotti_Offerti_sub]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIew [dbo].[PDA_Intersezione_Lotti_Offerti_sub] as 


				select distinct o.StatoPDA , o.idheader as idPda , o.idrow ,isnull( r.CodiceFiscale , vatValore_FT ) as CodiceFiscale,   isnull( r.IdAzi , idazipartecipante ) as idazi , isnull( l.NumeroLotto  , '1') as NumeroLotto, 
						case 
							when ISNULL(Ruolo_impresa,'')='' then 'Mandataria' 
							when Ruolo_impresa = 'RTI' then 'Mandataria' 
							when Ruolo_impresa='AUSILIARIE' then 'Ausiliaria' 
							when Ruolo_impresa='SUBAPPALTO' then 'Subappaltatore' 
							when Ruolo_impresa  = 'ESECUTRICI' then 'Esecutrice'  
								else Ruolo_impresa 
						 end as Ruolo_impresa,
						 ISNULL(tiporiferimento,'') as tiporiferimento
					--into #Temp
					from Document_PDA_OFFERTE o
						inner join DM_Attributi with(nolock) on lnk=idazipartecipante and dztNome='codicefiscale'
						left outer join CTL_DOC p on p.LinkedDoc = o.IdMsg  and p.TipoDoc = 'OFFERTA_PARTECIPANTI' and p.StatoFunzionale = 'Pubblicato' and deleted = 0
						--left outer join document_offerta_partecipanti r on r.IdHeader = o.IdMsgFornitore
						left outer join (
								select vatValore_FT as CodiceFiscale,azienda as idazi, id as idheader ,NULL as Ruolo_impresa,'' as tiporiferimento  
									from CTL_DOC 
										left join DM_Attributi with(nolock) on lnk=Azienda and dztNome='codicefiscale' 
										left join Aziende A with(nolock) on A.IdAzi=Azienda  
									where tipodoc = 'OFFERTA_PARTECIPANTI' and StatoFunzionale = 'Pubblicato' and deleted = 0
								union 
								select CodiceFiscale,idazi , idheader,
									case 
										when TipoRiferimento='RTI' and Ruolo_Impresa='Mandante' then 'Mandante' 
											else TipoRiferimento 
									end  as Ruolo_impresa
									,tiporiferimento from  document_offerta_partecipanti 
							) as r on r.IdHeader = p.id
						
						--left outer join Document_MicroLotti_Dettagli l on l.IdHeader = o.IdRow and l.TipoDoc = 'PDA_OFFERTE'  and Voce = 0
						left outer join Document_MicroLotti_Dettagli l on l.IdHeader = o.IdMsg and l.TipoDoc = 'OFFERTA'  and Voce = 0

						-- escludo i lotti che sono stati considerati esclusi sull'offerta o per i campioni
						left outer join CTL_DOC ca on  ca.Tipodoc = 'RICEZIONE_CAMPIONI' and ca.deleted = 0 and ca.StatoFunzionale = 'Confermato' and ca.IdDoc = o.idheader and o.IdMsg  = ca.LinkedDoc
						left outer join Document_Pda_Ricezione_Campioni rc on rc.IdHeader = ca.id and rc.NumeroLotto = l.NumeroLotto

						left outer join CTL_DOC es on  es.Tipodoc = 'ESCLUDI_LOTTI' and es.deleted = 0 and es.StatoFunzionale = 'Confermato' and es.IdDoc = o.idheader and o.IdMsg  = es.LinkedDoc
						left outer join Document_Pda_Escludi_Lotti el on el.IdHeader = es.id and el.NumeroLotto = l.NumeroLotto

					where --o.idheader = @idPda and @idAzi =  isnull( r.IdAzi , idazipartecipante ) and 
						
						statopda in  ( '2' , '22' , '8' , '9' , '222' ,'1')

						-- escludo dalla combinatoria i lotti esclusi 
						and  isnull( el.StatoLotto , '' ) <> 'escluso' 
						and isnull( rc.CampioneRicevuto , '1' ) <> '0' 



GO
