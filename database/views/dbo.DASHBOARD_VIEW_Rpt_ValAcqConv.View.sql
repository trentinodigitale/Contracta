USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_Rpt_ValAcqConv]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_Rpt_ValAcqConv]
AS

select 				
	t.Id_Convenzione as Convenzione,			
	t.aziRagioneSociale as [DenominazioneEnte],
	t.Periodo as Periodo, 
	sum(t.RDA_Total) as RDA_Total,
	sum(t.Qta) as Qta,
	cast(SUM(t.Qta) as float) / cast((SELECT count(*) FROM Document_ODC 
										INNER JOIN ProfiliUtente ON RDA_Owner = CAST(IdPfu AS VARCHAR)
										INNER JOIN Aziende ON Idazi = [pfuIdAzi]
										WHERE RDA_Deleted = ' '
										AND
										[RDA_Stato] in ('SendOrder', 'Evaso', 'In consegna') or
										([RDA_Stato] in ('SendOrder', 'Evaso', 'In consegna') and [FuoriPiattaforma]='si'))
										as float)
					 as PercQta




from
(
SELECT 
		IdAzi
		,aziRagioneSociale
		,[RDA_ID]
      ,[RDA_Owner]
      ,[RDA_Name]
      ,[RDA_DataCreazione]
      ,cast(year(RDA_DataCreazione) as char(4))  + '-' + right('00'+ltrim(str( month(RDA_DataCreazione))),2) as Periodo
      ,[RDA_Total]
      ,[RDA_Stato]
      ,[RDA_Deleted]
      ,[Utente]
      ,[TotalIva]
      ,[TipoOrdine]
      ,[IdPfu]
      ,[pfuIdAzi]
      ,[pfuNome]
		, TotalIva - RDA_Total                     AS ValoreIva 
     , Id_Convenzione 
     ,1 as Qta
  FROM Document_ODC 
INNER JOIN ProfiliUtente ON RDA_Owner = CAST(IdPfu AS VARCHAR)
INNER JOIN Aziende ON Idazi = [pfuIdAzi]
 WHERE RDA_Deleted = ' '
AND
		[RDA_Stato] in ('SendOrder', 'Evaso', 'In consegna') or
		([RDA_Stato] in ('SendOrder', 'Evaso', 'In consegna') and [FuoriPiattaforma]='si')
) as t
group by t.Id_Convenzione, t.aziRagioneSociale, t.Periodo





GO
