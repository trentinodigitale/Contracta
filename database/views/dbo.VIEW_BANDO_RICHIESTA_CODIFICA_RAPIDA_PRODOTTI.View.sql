USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_BANDO_RICHIESTA_CODIFICA_RAPIDA_PRODOTTI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[VIEW_BANDO_RICHIESTA_CODIFICA_RAPIDA_PRODOTTI] as
select 
Posizione as MacroAreaMerc,
* from 
Document_MicroLotti_Dettagli
where tipodoc in ('BANDO_RICHIESTA_CODIFICA_RAPIDA')
GO
