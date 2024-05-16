USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_REPORT_EROSIONE_MACROCONVENZIONI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE   view [dbo].[OLD2_DASHBOARD_VIEW_REPORT_EROSIONE_MACROCONVENZIONI] as
select
		C.Id,
		DC.Macro_Convenzione,
		DC.NumOrd,
		DC.CIG_MADRE,
		DC.CIG_MADRE as CIG_MADRE_TEXT,
		c.Titolo,
		c.StatoFunzionale,
		AZ.IdAzi as Mandataria,
		AZ.aziPartitaIVA,
		DC.DataInizio,
		DC.DataFine,
		DCL.NumeroLotto,
		DCL.Descrizione,
		DCL.Importo,
		VDIL.rda_total AS TotaleOrdinativiLotto,
		isnull(DCL.Tot_Altri_Ordinativi_Lotto, 0) + isnull(DCL.Impegnato, 0) as Impegnato,
		case when DCL.Importo = 0 then
			0
			else
				(isnull(DCL.Tot_Altri_Ordinativi_Lotto, 0) + isnull(DCL.Impegnato, 0)) / DCL.Importo
			end as LivelloErosione,
		dcl.Importo - (isnull(DCL.Tot_Altri_Ordinativi_Lotto, 0) + isnull(DCL.Impegnato, 0)) as Residuo

--- L. Importo
--- M. Totale Ordinativi lotto.  rda_total.                               | [VIEW_DOCUMENT_IMPORTI_LOTTI]                                         
--- N.	Totale Ordinato Eroso  Tot_Altri_Ordinativi_Lotto				      | [CONVENZIONE_CAPIENZA_LOTTI_VIEW] 
--- O.	Livello Erosione.  Calcolo % (%  N  /  L).                        
--- P.	Residuo L - N  



	FROM 
		ctl_doc C with(nolock) 
		inner join Document_Convenzione DC with(nolock) on C.id=DC.id	
		inner join Aziende AZ with(nolock) on DC.Mandataria = AZ.IdAzi
		inner join CONVENZIONE_CAPIENZA_LOTTI_VIEW DCL on C.Id = DCL.idheader
		inner join VIEW_DOCUMENT_IMPORTI_LOTTI VDIL ON C.ID = VDIL.idheader and DCL.NumeroLotto = VDIL.NumeroLotto

	WHERE C.tipodoc= 'CONVENZIONE' and C.StatoFunzionale IN ('Pubblicato','Chiuso')


GO
