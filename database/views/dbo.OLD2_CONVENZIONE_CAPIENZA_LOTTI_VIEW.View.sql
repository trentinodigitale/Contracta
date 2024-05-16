USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_CONVENZIONE_CAPIENZA_LOTTI_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[OLD2_CONVENZIONE_CAPIENZA_LOTTI_VIEW] AS
select 
	DCL.idRow as indRow,
	DCL.Importo as Importo_Q_Lotto,
	DCL.idRow, 
	DCL.idHeader, 
	DCL.Seleziona, 
	DCL.StatoLottoConvenzione, 
	DCL.NumeroLotto, 
	DCL.Descrizione, 
	DCL.Importo, 
	DCL.Impegnato, 
	DCL.Estensione, 
	DCL.Finale, 	
	DCL.SogliaSuperata, 
	DCL.DataAlertSoglia,

	dbo.AFS_ROUND(case when ISNULL(dc.AZI_Dest,'') <> '' and ISNULL(aggiud.PercAgg,'')=100 
			then ( DCL.Importo - Tot_Altri_Ordinativi_Lotto ) 
			else DCL.Residuo
    end ,10)as Residuo,

	case when ISNULL(dc.AZI_Dest,'') <> '' and ISNULL(aggiud.PercAgg,'')=100 
		      then Tot_Altri_Ordinativi_Lotto - DCL.Impegnato    ---RIMUOVO IMPEGNATO DA ME VISTO CHE Tot_Altri_Ordinativi_Lotto contiene il totale ordinativi per LOTTO
			  else NULL 
	end as Tot_Altri_Ordinativi_Lotto,
	DCL.CodiceAIC,
	DCL.CodiceATC,
	DCL.CODICE_CPV,
	DCL.CODICE_CND,
	DCL.PrincipioAttivo,
	DCL.Descrizione_Codice_Regionale
	--, lg.cig
from 
	Document_Convenzione_Lotti DCL with(NOLOCK)
	
	--left join Document_MicroLotti_Dettagli dettConv with (nolock) on DCL.idHeader=dettConv.IdHeader and dettConv.tipodoc='CONVENZIONE' and DCL.NumeroLotto=dettConv.NumeroLotto and isnull(dettConv.voce,0) = 0
	left join 
		(select distinct cig,numerolotto,idheader from Document_MicroLotti_Dettagli with(NOLOCK) where tipodoc='CONVENZIONE') dettConv on DCL.idHeader=dettConv.IdHeader and DCL.NumeroLotto=dettConv.NumeroLotto 		

	-- Relazione per CIG tra la gara e la conv
	left join ( 
			select  lg.id  , cig , lg.tipodoc , lg.voce , lg.NumeroLotto , LinkedDoc 
				from Document_MicroLotti_Dettagli lg with(nolock)  
					inner join ctl_doc pda with(nolock) ON pda.id = lg.IdHeader and pda.deleted=0 and pda.TipoDoc = 'PDA_MICROLOTTI'
				where isnull( lg.voce , 0 ) = 0 and isnull( CIG ,'' ) <> '' 
					) as lg  on  lg.cig = dettConv.CIG and lg.tipodoc = 'PDA_MICROLOTTI' and dettConv.NumeroLotto=lg.NumeroLotto 
	
	--condiviso con Sabato non serve 
	--left join Document_Bando gara with(nolock) on gara.idHeader = lg.LinkedDoc and gara.TipoAggiudicazione='Multifornitore'
	
	
	left join CTL_DOC gr with(nolock) ON gr.LinkedDoc = lg.Id and gr.TipoDoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE' and gr.StatoFunzionale = 'Confermato'
	left join CTL_DOC_Value gr2 with(nolock) ON gr2.IdHeader = gr.Id and gr2.DSE_ID = 'IMPORTO' and gr2.DZT_Name = 'CIG_LOTTO' and gr2.Value=dettConv.cig
	left join Document_Convenzione dc with(nolock) on dc.ID = DCL.IdHeader
	left join Document_microlotti_dettagli aggiud with(nolock) ON aggiud.IdHeader = gr.Id and aggiud.TipoDoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE' and ISNULL(aggiud.PercAgg,0) = 100 and aggiud.Aggiudicata=dc.AZI_Dest	--prendo solo 100 del destinatario della convenzione
	left join CTL_DOC_Value gr21 with(nolock) ON gr21.IdHeader = gr.Id and gr21.DSE_ID = 'IMPORTO' and gr21.DZT_Name = 'ImportoAggiudicatoInConvenzione'
	left join (
				select dettConv.CIG, sum(ISNULL(Impegnato,0)) as Tot_Altri_Ordinativi_Lotto 
					from Document_Convenzione_Lotti  DCL with(NOLOCK)
						--inner join Document_MicroLotti_Dettagli dettConv with (nolock) on DCL.idHeader=dettConv.IdHeader and dettConv.tipodoc='CONVENZIONE' and DCL.NumeroLotto=dettConv.NumeroLotto and isnull(dettConv.voce,0) = 0 
						inner join (select distinct cig,numerolotto,idheader from Document_MicroLotti_Dettagli with(NOLOCK) where tipodoc='CONVENZIONE'  ) dettConv on DCL.idHeader=dettConv.IdHeader and DCL.NumeroLotto=dettConv.NumeroLotto
					group by dettConv.CIG
				
				) as z on z.CIG=gr2.value




GO
