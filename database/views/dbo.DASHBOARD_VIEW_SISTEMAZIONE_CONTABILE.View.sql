USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_SISTEMAZIONE_CONTABILE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_SISTEMAZIONE_CONTABILE]
AS
SELECT DISTINCT 
s.ID,s.ID_Repertorio, s.Stato, s.Rep, CAST(s.Oggetto AS nvarchar(200)) AS Oggetto,
s.DataStipula, s.ResponsabileContratto, s.NRDeterminazione, s.DataDetermina,s.ProtocolloGenerale, s.DataProt,
s.NumReversale,s.DataReversale, s.idAggiudicatrice as Fornitore
,	case when isnull( r.StatoRepertorio , '' ) = '' then 'InCorso'
		else r.StatoRepertorio 
	end as StatoRepertorio 
FROM           Document_Sistemazione_Contabile s
			left outer join Document_Repertorio r on ID_Repertorio = IdRepertorio
where ID_Repertorio not in (-1,-2,-3,-4)

GO
