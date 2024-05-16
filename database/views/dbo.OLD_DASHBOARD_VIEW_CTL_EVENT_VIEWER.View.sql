USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_CTL_EVENT_VIEWER]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_CTL_EVENT_VIEWER] AS
	SELECT 
		--RECORDID NON UNIVOCO
		--CHIAVE UNIVOCA SE SERVE RECORDID-MACHINENAME-LogName
		   Recordid as [id]
		  ,TimeCreated as data
		  ,TimeCreated as dataDa
		  ,TimeCreated as dataA
		  
		  --,LevelDisplayName as tipoEvento
		  ,CASE 
			  WHEN LevelDisplayName = 'Critical' then 0
			  when LevelDisplayName = 'Error' then 1
			  when LevelDisplayName = 'Warning' then 2
			  when LevelDisplayName = 'Information' then 4
			  Else LevelDisplayName  end as tipoEvento

		  ,Machinename as source
		  ,Message as descrizione
		  ,0 as [idpfu]
	  FROM [dbo].CTL_EventLog with (nolock)
		inner join LIB_Dictionary L with(nolock) on L.DZT_Name='SYS_AFUPDATE_PRODOTTO' and DZT_ValueDef <> 'eProcNext'
	UNION ALL
		SELECT 
		--RECORDID NON UNIVOCO
		--CHIAVE UNIVOCA SE SERVE RECORDID-MACHINENAME-LogName
		   CTL_EVENT_VIEWER.id
		  ,data
		  ,data as dataDa
		  ,data as dataA
		  
		 , tipoEvento

		  ,source
		  ,descrizione
		  ,0 as [idpfu]
	  FROM [dbo].CTL_EVENT_VIEWER with (nolock)
		inner join LIB_Dictionary L with(nolock) on L.DZT_Name='SYS_AFUPDATE_PRODOTTO' and DZT_ValueDef='eProcNext'
GO
