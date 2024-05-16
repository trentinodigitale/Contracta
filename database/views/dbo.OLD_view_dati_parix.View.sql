USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_view_dati_parix]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_view_dati_parix] as 

	select 
		a.sessionId,
		a.codice_fiscale, isnull(a.valore,'') as RagSoc,		
		isnull(b.valore,'') as CodiceFiscale,
	   isnull(c.valore,'') as Piva, isnull(d.valore,'') as Nagi,
	   isnull(e.valore,'') as IscrCCIAA, isnull(f.valore,'') as SedeCCIAA, isnull(g.valore,'') as ANNOCOSTITUZIONE,
	   isnull(h.valore,'') as LocalitaLeg, isnull(i.valore,'') as CapLeg, isnull(l.valore,'') as IndirizzoLeg,
	   isnull(m.valore,'') as EMail, isnull(n.valore,'') as PFUEMAIL, isnull(o.valore,'') as NomeRapLeg,
	   isnull(p.valore,'') as CognomeRapLeg, isnull(q.valore,'') as RuoloRapLeg,
	   isnull(r.valore,'') as CFRapLeg, isnull(s.valore,'') as NUMTEL, isnull(t.valore,'') as NUMFAX,
	   isnull(u.valore,'') as PROVINCIALEG,  isnull(v.valore,'') as aziLocalitaLeg2,  isnull(z.valore,'') as aziProvinciaLeg2
	   

	from parix_dati a with(nolock)
			left join parix_dati b with(nolock) ON b.nome_campo = 'codicefiscale' and b.sessionId = a.sessionId and b.codice_fiscale = a.codice_fiscale
			left join parix_dati c with(nolock) ON c.nome_campo = 'PIVA' and c.sessionId = a.sessionId and c.codice_fiscale = a.codice_fiscale
			left join parix_dati d with(nolock) ON d.nome_campo = 'NAGI' and d.sessionId = a.sessionId and d.codice_fiscale = a.codice_fiscale 
			left join parix_dati e with(nolock) ON e.nome_campo = 'IscrCCIAA' and e.sessionId = a.sessionId and e.codice_fiscale = a.codice_fiscale 
			left join parix_dati f with(nolock) ON f.nome_campo = 'SedeCCIAA' and f.sessionId = a.sessionId and f.codice_fiscale = a.codice_fiscale 
			left join parix_dati g with(nolock) ON g.nome_campo = 'ANNOCOSTITUZIONE' and g.sessionId = a.sessionId and g.codice_fiscale = a.codice_fiscale 
			left join parix_dati h with(nolock) ON h.nome_campo = 'LOCALITALEG' and h.sessionId = a.sessionId and h.codice_fiscale = a.codice_fiscale 
			left join parix_dati i with(nolock) ON i.nome_campo = 'CAPLEG' and i.sessionId = a.sessionId and i.codice_fiscale = a.codice_fiscale 
			left join parix_dati l with(nolock) ON l.nome_campo = 'INDIRIZZOLEG' and l.sessionId = a.sessionId and l.codice_fiscale = a.codice_fiscale 
			left join parix_dati m with(nolock) ON m.nome_campo = 'EMail' and m.sessionId = a.sessionId and m.codice_fiscale = a.codice_fiscale 
			left join parix_dati n with(nolock) ON n.nome_campo = 'PFUEMAIL' and n.sessionId = a.sessionId and n.codice_fiscale = a.codice_fiscale 
			left join parix_dati o with(nolock) ON o.nome_campo = 'NomeRapLeg' and o.sessionId = a.sessionId and o.codice_fiscale = a.codice_fiscale 
			left join parix_dati p with(nolock) ON p.nome_campo = 'CognomeRapLeg' and p.sessionId = a.sessionId and p.codice_fiscale = a.codice_fiscale 
			left join parix_dati q with(nolock) ON q.nome_campo = 'RuoloRapLeg' and q.sessionId = a.sessionId and q.codice_fiscale = a.codice_fiscale 
			
			left join parix_dati r with(nolock) ON r.nome_campo = 'CFRapLeg' and r.sessionId = a.sessionId and r.codice_fiscale = a.codice_fiscale 
			left join parix_dati s with(nolock) ON s.nome_campo = 'NUMTEL' and s.sessionId = s.sessionId and s.codice_fiscale = a.codice_fiscale 
			left join parix_dati t with(nolock) ON t.nome_campo = 'NUMFAX' and t.sessionId = a.sessionId and t.codice_fiscale = a.codice_fiscale 
			
			left join parix_dati u with(nolock) ON u.nome_campo = 'PROVINCIALEG' and u.sessionId = a.sessionId and u.codice_fiscale = a.codice_fiscale 
			
			left join parix_dati v with(nolock) ON v.nome_campo = 'aziLocalitaLeg2' and v.sessionId = a.sessionId and v.codice_fiscale = a.codice_fiscale 
			left join parix_dati z with(nolock) ON z.nome_campo = 'aziProvinciaLeg2' and z.sessionId = a.sessionId and z.codice_fiscale = a.codice_fiscale 
			
			
				
	where a.nome_campo = 'RAGSOC' 

GO
