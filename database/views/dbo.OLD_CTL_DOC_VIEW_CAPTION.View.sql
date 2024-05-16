USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_CTL_DOC_VIEW_CAPTION]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[OLD_CTL_DOC_VIEW_CAPTION] as
select
	d.*, 	
	--case 
		--when d.TipoDoc ='BANDO_CONCORSO' then 'Bando Concorso'
		--else
			case 
				when Proceduragara='15586' then 'Concorso di Idee'
				when Proceduragara='15587' and isnull(TipoProceduraCaratteristica,'') ='ConcorsoInSingolaFase'  then 'Concorso di Progettazione'
				when Proceduragara='15587' and isnull(TipoProceduraCaratteristica,'') ='ConcorsoInDueFasi' and ISNULL(faseconcorso,'')='prima' then 'Concorso di Progettazione I fase'
				when Proceduragara='15587' and isnull(TipoProceduraCaratteristica,'') ='ConcorsoInDueFasi'  and ISNULL(faseconcorso,'')='seconda' then 'Concorso di Progettazione II fase'
				when b.TipoProceduraCaratteristica = 'RDO' then 'Richiesta di Offerta'
				when b.ProceduraGara = '15477' and b.TipoBandoGara = '2' then 'BandoRistretta' -- Ristretta / Bando
				else
					case when b.TipoSceltaContraente = 'ACCORDOQUADRO' 
						then 'Accordo Quadro'
					else
						case b.TipoBandoGara 
							when '1' then 'Avviso'
							when '3' then 'Invito'
							else 'Bando'	
						end 
					end
			end as CaptionDoc	
		
	--end as CaptionDoc	

	from ctl_doc d with (nolock)
		left join document_bando b with (nolock) on d.id = b.idheader
GO
