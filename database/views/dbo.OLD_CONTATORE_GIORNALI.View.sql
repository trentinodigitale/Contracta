USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_CONTATORE_GIORNALI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_CONTATORE_GIORNALI]
AS
SELECT     TOP 100 PERCENT CAST(Id AS varchar) AS DMV_Cod, Diffusione, b.aziRagioneSociale as aziRagioneSociale,Quotidiano, isnull(NV,0) AS Num_Preventivi 
FROM         dbo.Document_Quotidiani AS a INNER JOIN
                      Aziende AS b ON a.IdAzi = b.IdAzi
left outer join (
		select Giornale , count(*) as NV 
		from Document_RicPrevPubblic_Quotidiani 
					inner join dbo.Document_RicPrevPubblic on idHeader = id
		where StatoRicPrevPubblic <> 'Annulled' and dbo.Document_RicPrevPubblic.Storico=0 and   year( dbo.Document_RicPrevPubblic.DataInvio ) = year ( getdate())
		group by Giornale 
		) as c on CAST(Id AS varchar) = Giornale
where a.diffusione in ('Nazionale','Regionale')
ORDER BY Diffusione,NV
GO
