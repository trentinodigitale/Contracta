USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RICERCA_OE_ESITI_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[RICERCA_OE_ESITI_VIEW] as 

select 
	d.* , 
	
	v.Value as Certificazioni,

	case 
		when ISNULL(CV.Value,'') in ( 'rotazione','rotazione2' ) 
		then ' Seleziona '
		else ''
	end	
		 as NonEditabili,
	  --recupero id se esiste ALBO PROF
		CASE
			WHEN ISNULL(BANDI_PROF.Id_Doc , '') <> '' THEN BANDI_PROF.Id_Doc
			ELSE '0'
		END AS ID_ALBO_PROF,
		CASE
			WHEN ISNULL(BANDI_PROF.Id_Doc , '') <> '' THEN '../Domain/Lente.gif'
			ELSE '&nbsp;'
		END AS FNZ_QUOT
		
		


	from CTL_DOC_Destinatari d 

		left outer join CTL_DOC_Value v on d.idHeader = v.IdHeader and d.idrow = v.Row and v.DSE_ID = 'CERTIFICAZIONI' and DZT_Name = 'Certificazioni' 

		left join ctl_doc_Value CV on CV.IdHeader=D.idHeader and CV.DSE_ID='BOTTONE' and CV.DZT_Name='TipoSelezioneSoggetti' 
		--left join ctl_doc_Value CV1 on CV1.IdHeader=D.idHeader and CV1.DSE_ID='BOTTONE' and CV1.DZT_Name='NumeroInvitiRotazione' 
		--left join ctl_doc_Value CV2 on CV2.IdHeader=D.idHeader and CV2.DSE_ID='BOTTONE' and CV2.DZT_Name='SogliaImportoAggiudicato' 
		LEFT JOIN
				(
					SELECT    
						'ISTANZA_AlboProf_3' AS tipodoc ,
						 CD.IdAzi ,
						  MAX(CD.Id_Doc) AS     Id_Doc
						FROM  ctl_doc C with(nolock) 
							INNER JOIN Document_Bando d  with(nolock) ON C.id = d.idHeader  AND d.TipoBando IN('AlboProf_3')
							INNER JOIN CTL_DOC_Destinatari CD  with(nolock) ON CD.idHeader = C.id AND CD.StatoIscrizione = 'Iscritto'
						WHERE C.tipodoc = 'BANDO' AND C.Deleted = 0 AND C.StatoFunzionale = 'Pubblicato'
						GROUP BY CD.IdAzi
				) AS BANDI_PROF ON BANDI_PROF.IdAzi = d.IdAzi

GO
