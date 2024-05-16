USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_RicPubblic_Direzione]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Document_RicPubblic_Direzione]
AS
SELECT     id, idRicPrevPubblic, StatoRicPubblic, PEG, Bando, Pratica, Fornitore, Fax, Oggetto, Allegato, UserDirigente, Num, Data, Prog, Imp, Bil, Owner, 
                      TipoPubblic, LEFT(PEG, 24) AS Direzione
FROM         dbo.Document_RicPubblic

GO
