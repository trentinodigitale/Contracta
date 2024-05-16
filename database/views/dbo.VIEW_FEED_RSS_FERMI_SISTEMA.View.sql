USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_FEED_RSS_FERMI_SISTEMA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VIEW_FEED_RSS_FERMI_SISTEMA] AS
	select Id, IdPfu, convert( VARCHAR(50) , a.Data, 126) as DataCreazione,convert( VARCHAR(50) , a.DataInvio, 126) as DataInvio,cast(Body as nvarchar(max)) as Descrizione,StatoDoc, StatoFunzionale, convert( VARCHAR(50) ,  b.DataInizio, 126) as DataInizio , convert( VARCHAR(50) , b.DataFine, 126) as DataFine 
		from CTL_DOC a with(nolock) 
				inner join Document_FermoSistema b with(nolock) on b.idHeader = a.Id
		where a.TipoDoc = 'FERMOSISTEMA' and a.Deleted = 0 and a.StatoFunzionale = 'Confermato'
GO
