USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_prot_gen_fascicolo]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD2_prot_gen_fascicolo] as 

	-- Il fascicoloSecondario, composto così : anno.titolario.progressivo    2006.300.30.1
	
	-- Viene associato ai documenti ad esso relativi. 
	-- Nel giro delle convenzioni il fascicoloprimario è generato in automatoco da noi, mentre il secondario
	-- è imputato dall'utente
	
	select	  id
			 , fascicoloSecondario 
			 , dbo.GetColumnValue (fascicoloSecondario, '.', 1) AS ANNO_FASCICOLO
			 , dbo.GetColumnValue (fascicoloSecondario, '.', dbo.contaOccorrenze(fascicoloSecondario,'.') + 1 ) AS PROG_FASCICOLO
			 --, titolarioSecondario as CLASSIFICA_FASCICOLO

			, replace( replace(fascicoloSecondario, dbo.GetColumnValue (fascicoloSecondario, '.', 1) + '.', '') + '###','.' + dbo.GetColumnValue (fascicoloSecondario, '.', dbo.contaOccorrenze(fascicoloSecondario,'.') + 1 )+ '###', '') as CLASSIFICA_FASCICOLO

	from ctl_doc doc
			inner join Document_dati_protocollo prot ON doc.id = prot.idheader 

GO
