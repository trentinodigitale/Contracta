USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_Dettaglio_Accessi]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------
--vista per il dettaglio accessi utenti
---------------------------------------------------------------


CREATE VIEW [dbo].[VIEW_Dettaglio_Accessi] as 
select 
 ID,
 CASE DOC_NAME
    when 'RECUPEROCODICI' then id_Doc
    else idPfu
 END AS idPfu,
 Data,
 Proc_Name,
 Parametri as [PARAM] 
from CTL_LOG_PROC
where DOC_NAME in ('LOGIN','UTENTE','RECUPEROCODICI')


GO
