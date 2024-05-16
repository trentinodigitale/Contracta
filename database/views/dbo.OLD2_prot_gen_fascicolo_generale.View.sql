USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_prot_gen_fascicolo_generale]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_prot_gen_fascicolo_generale] as 

	-- Il fascicoloPrimario,  'crea' il fascicolo imputato dall'utente sul documento
	-- per poi essere usato nel protocollo generale

	-- formato fascicolo : anno.titolario.progressivo    2006.300.30.1

	select	id
			 , doc.FascicoloGenerale 
			 , dbo.GetColumnValue (doc.FascicoloGenerale, '.', 1) AS ANNO_FASCICOLO
			 , dbo.GetColumnValue (doc.FascicoloGenerale, '.', dbo.contaOccorrenze(doc.FascicoloGenerale,'.') + 1 ) AS PROG_FASCICOLO
			 --, titolarioSecondario as CLASSIFICA_FASCICOLO

			 , replace( replace(doc.FascicoloGenerale, dbo.GetColumnValue (doc.FascicoloGenerale, '.', 1) + '.', '') + '###','.' + dbo.GetColumnValue (doc.FascicoloGenerale, '.', dbo.contaOccorrenze(doc.FascicoloGenerale,'.') + 1 )+ '###', '') as CLASSIFICA_FASCICOLO

	from ctl_doc doc
			inner join Document_dati_protocollo prot ON doc.id = prot.idheader 



GO
