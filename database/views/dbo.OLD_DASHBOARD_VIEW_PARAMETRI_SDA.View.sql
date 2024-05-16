USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_PARAMETRI_SDA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE view [dbo].[OLD_DASHBOARD_VIEW_PARAMETRI_SDA] as
  select 
  C.ID,
  C.Titolo,
  C.Protocollo,
  C.DataInvio,
  C.Idpfu,
  DP.NumAnniApertura,
  DP.NumGiorniValutazione,
  DP.NumGiorniPresentazioneDomande,
  DP.PresenzaBustaTecnica,
  C.TipoDoc as OPEN_DOC_NAME ,
	c.StatoFunzionale , 
	dp.Deleted
  
  
  from CTL_DOC C
  inner join dbo.Document_Parametri_SDA  DP on C.ID=DP.IDHEADER
  where C.Statodoc='Sent' and c.tipodoc = 'PARAMETRI_SDA'

GO
