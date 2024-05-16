USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_IMPOSTA_REG]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_IMPOSTA_REG]
AS
SELECT DISTINCT 
i.ID,i.ID_Repertorio, i.Stato, i.Rep, CAST(i.Oggetto AS nvarchar(200)) AS Oggetto,
i.DataStipula, i.ResponsabileContratto, i.NRDeterminazione, i.DataDetermina,i.ProtocolloGenerale, i.DataProt,
i.NumReversale,i.DataReversale, i.idAggiudicatrice as Fornitore
,	case when isnull( r.StatoRepertorio , '' ) = '' then 'InCorso'
		else r.StatoRepertorio 
	end as StatoRepertorio 
FROM           Document_ImpostaReg i
			left outer join Document_Repertorio r on ID_Repertorio = IdRepertorio
where ID_Repertorio not in (-1,-2,-3,-4) 

GO
