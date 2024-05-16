USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_RICERCA_OE_ESITI_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_RICERCA_OE_ESITI_VIEW] as 

select 
	d.* , 
	
	v.Value as Certificazioni,

	case 
		when ISNULL(CV.Value,'') in ( 'rotazione','rotazione2' ) 
		then ' Seleziona '
		else ''
	end	
		 as NonEditabili

	from CTL_DOC_Destinatari d 

		left outer join CTL_DOC_Value v on d.idHeader = v.IdHeader and d.idrow = v.Row and v.DSE_ID = 'CERTIFICAZIONI' and DZT_Name = 'Certificazioni' 

		left join ctl_doc_Value CV on CV.IdHeader=D.idHeader and CV.DSE_ID='BOTTONE' and CV.DZT_Name='TipoSelezioneSoggetti' 
		--left join ctl_doc_Value CV1 on CV1.IdHeader=D.idHeader and CV1.DSE_ID='BOTTONE' and CV1.DZT_Name='NumeroInvitiRotazione' 
		--left join ctl_doc_Value CV2 on CV2.IdHeader=D.idHeader and CV2.DSE_ID='BOTTONE' and CV2.DZT_Name='SogliaImportoAggiudicato' 


GO
