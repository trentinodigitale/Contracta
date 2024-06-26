USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Spese_Contratto_view]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[Document_Spese_Contratto_view] as
SELECT     Id, 
Conto, 
Descrizione, 
case when Marche = 0 then null else Marche end as Marche, 
case when ValoreMarca = 0 then null else ValoreMarca end as ValoreMarca, 
case when Ruoli = 0 then null else Ruoli end as Ruoli, 
case when Dovute = 0 then null else Dovute end as Dovute, 
case when Versato = 0 then null else Versato end as Versato, 
case when Saldo = 0 then null else Saldo end as Saldo, 
Not_Editable, 
idDoc , IdRepertorio , indrow
FROM         Document_Spese_Contratto
union 
SELECT     Id, Conto, Descrizione, Marche, ValoreMarca, Ruoli, Dovute, Versato, Saldo, Not_Editable, 2 as idDoc , IdRepertorio , indrow
FROM         Document_Spese_Contratto where iddoc = 1

GO
