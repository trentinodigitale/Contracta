USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_GESTIONE_DOMINIO_DIREZIONE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_GESTIONE_DOMINIO_DIREZIONE] AS
	SELECT    *
		FROM
		(
			SELECT DISTINCT   
				   19 AS DMV_DM_ID , CAST(idaz AS VARCHAR) + '#' + path AS DMV_Cod , 
				   CAST(idaz AS VARCHAR) + '#' + path AS DMV_Father , (LEN(path) / 5) AS DMV_Level ,
				   descrizione AS DMV_DescML ,
					CASE
						WHEN LEN(path) < 15
						THEN 'folder.gif'
						ELSE 'node.gif'
					END AS DMV_Image , 
					0 AS DMV_Sort , '' AS DMV_CodExt , idaz,
					case 
						when isnull(aziDeleted,0)=1 OR isnull(deleted,0)=1 then 1
						else 0
					end as dmv_deleted

				FROM az_struttura with (nolock)
					inner join Aziende with (nolock) on IdAzi = Idaz and aziAcquirente<>0
		) AS a
GO
