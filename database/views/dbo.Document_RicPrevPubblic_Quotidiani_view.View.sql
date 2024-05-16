USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_RicPrevPubblic_Quotidiani_view]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Document_RicPrevPubblic_Quotidiani_view]
AS
SELECT     idRow, idHeader, idRicPubblic, Giornale, NumMod, Importo, StatoQuotidiano, RDP_VDS, PEG, Fornitore, Disponibilita, Ticket, Added, 
                      DataPubblicazione, Storico, Tipo, CASE Disponibilita WHEN 'No - Mandato' THEN '' ELSE ' Importo ' END AS NonEditabili
FROM         dbo.Document_RicPrevPubblic_Quotidiani



GO
