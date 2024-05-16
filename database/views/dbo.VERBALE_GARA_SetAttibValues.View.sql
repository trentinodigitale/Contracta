USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VERBALE_GARA_SetAttibValues]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[VERBALE_GARA_SetAttibValues] as
	select
		DM.id,
		C.Id as IdPda,
		A.aziRagioneSociale,
		cast(ISNULL(C.Body,'') as nvarchar(MAX)) as Body,
		ISNULL(DB.NumeroIndizione,'') as Atto_Indizione,
		ISNULL(convert( varchar , DB.DataIndizione , 103 ),'' ) as Data_Atto_Indizione,		
		isnull( cast( ML_Description as nvarchar(2000)), cast( DMV_DescML as nvarchar( 2000))) as CriterioAggiudicazioneGara,		
		case 
			when 	DB.CriterioFormulazioneOfferte = '15537' then 'Percentuale'
			when 	DB.CriterioFormulazioneOfferte = '15536' then 'Prezzo'
		end as CriterioFormulazioneOfferte,
		convert( varchar , DB.DataScadenzaOfferta , 103 )  + ' ' +  convert( varchar(5) ,DB.DataScadenzaOfferta , 108 ) as DataScadenzaOfferta,
		DB.Divisione_lotti,
		DB.CIG as CIG_PER_MONOLOTTI ,
		db.ProceduraGara , 
		db.TipoBandoGara
		

	from Document_MicroLotti_Dettagli DM with(nolock) 
		inner join ctl_doc C with(nolock) on  C.TipoDoc='PDA_MICROLOTTI' and DM.IdHeader=C.id and C.Deleted=0
		inner join  CTL_DOC BANDO with(nolock) on BANDO.id=C.LinkedDoc and BANDO.TipoDoc in ('BANDO_GARA' , 'BANDO_SEMPLIFICATO')
		inner join  Document_bando DB with(nolock) on DB.idHeader=BANDO.id
		inner join Aziende A with(nolock) on A.IdAzi=BANDO.Azienda
		inner join LIB_DomainValues LD with(nolock) on LD.DMV_DM_ID='Criterio2' and LD.DMV_Cod=DB.CriterioAggiudicazioneGara
		left outer join dbo.LIB_Multilinguismo on LD.DMV_DescML = ML_KEY and 'I' = ML_LNG
	
GO
