USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_BANDO_RICHIESTA_CODIFICA_PRODOTTI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VIEW_BANDO_RICHIESTA_CODIFICA_PRODOTTI] as
select 
Posizione as MacroAreaMerc,
* from 
Document_MicroLotti_Dettagli
where tipodoc='BANDO_RICHIESTA_CODIFICA'
GO
