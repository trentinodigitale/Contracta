USE [AFLink_TND]
GO
/****** Object:  View [dbo].[View_ProspettoConfronto_Valutazione]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[View_ProspettoConfronto_Valutazione]
as
		select 
				--a.id,
				c.id,

				case when isnull(x.PREZZO_OFFERTO_PER_UM,0)=0 then isnull(a.PREZZO_OFFERTO_PER_UM,0) else isnull(x.PREZZO_OFFERTO_PER_UM,0) end as PrezzoUnitario,
				case when isnull(x.PREZZO_OFFERTO_PER_UM,0)=0 then isnull(a.PREZZO_OFFERTO_PER_UM,0) else isnull(x.PREZZO_OFFERTO_PER_UM,0) end as PrzUnOfferta,
				case when isnull(x.Quantita,0)=0 then isnull(a.Quantita,0) else isnull(x.Quantita,0) end as Quantita,
				
				isnull(x.PROGRESSIVO_RIGA,x.NumeroRiga ) as KeyRiga ,
				x.CodiceProdotto as CodArt,
				b.idAziPartecipante as IdAziForn,
				b.aziRagioneSociale as aziragionesociale,
				x.CodiceProdotto as CodiceArticolo,
				x.Descrizione as DescrizioneArticolo,
				d.id as IdRdo,
				d.Protocollo as numerordo,
				isnull(x.UnitadiMisura,x.CampoTesto_1) as UM,
				d.Data as DataCreazione,
				d.DataInvio as DataInvio,
				d.StrutturaAziendale as Plant,
				d.Body as Object,
				d.Azienda as idazi,
				d.Protocollo as Protocol,
				d.Protocollo as Protocollo,
				'EUR' as valuta,
				d.deleted,
				h.DataScadenza as DataConsegna,
				isnull(a.Quantita,0) as QtRdo,
				x.NumeroLotto ,
				x.Voce ,
				h.id as IdOfferta,
				d.Titolo as Name,
				aa.aziRagioneSociale as Committente			

			from Document_MicroLotti_Dettagli  a with (nolock) 
				inner join Document_PDA_OFFERTE b with (nolock) on b.IdRow = a.IdHeader 
				inner join ctl_doc h with (nolock) on h.id = b.IdMsg   and h.TipoDoc = 'offerta' and h.Deleted = 0
				inner join ctl_doc c with (nolock) on c.id = b.IdHeader  and c.TipoDoc = 'PDA_MICROLOTTI' and c.Deleted = 0
				inner join ctl_doc d with (nolock) on d.id = c.LinkedDoc   and d.TipoDoc = 'bando_gara' and d.Deleted = 0
				inner join aziende aa with (nolock) on aa.idazi=d.Azienda 
				inner join Document_MicroLotti_Dettagli x with (nolock) on x.TipoDoc = 'PDA_OFFERTE' and x.IdHeader = a.IdHeader 
																					and x.NumeroLotto = a.NumeroLotto 
																					and a.id = x.id
																					and x.Voce <> 0
																					
					where a.voce <> 0 
						--and c.id = 83685

GO
