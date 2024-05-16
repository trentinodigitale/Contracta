USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_dashboard_sp_view_export_listini_lotti]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[OLD2_dashboard_sp_view_export_listini_lotti]
(@IdPfu							int,
 @AttrName						varchar(8000),
 @AttrValue						varchar(8000),
 @AttrOp 						varchar(8000),
 @Filter                        varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output
)
as
begin
	
	set nocount on
	
	--costruisco select da eseguire
	declare @SQLCmd			varchar(8000)
	declare @SQLWhere		varchar(8000)
	declare @Param varchar(8000)

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp
	
	declare @TuttiOperatoriEconomici varchar(10)
	set @TuttiOperatoriEconomici			= dbo.GetParam( 'TuttiOperatoriEconomici' , @Param ,1) 

	
	set @AttrName = replace( @AttrName , 'TuttiOperatoriEconomici' , 'X_TuttiOperatoriEconomici' )

	set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_Export_Listini_Prodotti' , 'V',  @AttrName  ,  @AttrValue ,  @AttrOp )




	select distinct
		--filtro
		 d.Id as id
		, db.cig as NumeroGara
		, case	
				when db.Divisione_lotti = '0' then db.cig
				else lb.CIG 
		  end as cig
		, REPLACE(REPLACE(d.Titolo , ';', ' '), CHAR(13) + CHAR(10) , '')  AS NomeProcedura
		, dbo.GetDescTipoProcedura ( d.Tipodoc , TipoProceduraCaratteristica , ProceduraGara, TipoBandoGara )  as DescTipoProcedura
		, aziPda.aziPartitaIVA as PIvaOperatoreEconomico

		, case
			--when ro.StatoRiga IN ('AggiudicazioneDef') then 'si'
			when left( ro.posizione , 6 ) in ( 'Idoneo' , ' Aggiud' ) then 'si'
			else 'no'
		end as Aggiudicatario
--		end as TuttiOperatoriEconomici
		
		--griglia
		, REPLACE(REPLACE(CAST(d.Body AS VARCHAR(150)), ';', ' '), CHAR(13) + CHAR(10), '')	 AS Oggetto
		, case when db.Divisione_lotti = '0' then '1' else lb.NumeroLotto end as NumeroLotto
		, lv.Descrizione as DescrizioneLotto
	
		, pda.aziRagioneSociale

	into #TemplistaLotti		
	from CTL_DOC d WITH (NOLOCK) --bando_gara
		--info bando_gara
		INNER JOIN Document_Bando db WITH (NOLOCK) on d.id = db.idheader
		--lotti bando_gara 
		inner join Document_MicroLotti_Dettagli lb WITH (NOLOCK) on d.Id = lb.IdHeader and d.TipoDoc = lb.TipoDoc and (lb.Voce = 0 or lb.NumeroRiga = 0)
		--sublotti bando_gara 
		left join Document_MicroLotti_Dettagli lv WITH (NOLOCK) on d.Id = lv.IdHeader and d.TipoDoc = lv.TipoDoc and isnull(lb.NumeroLotto, '1') = isnull(lv.NumeroLotto, '1')  
																	--and lv.Voce = lb.Voce and lv.AmpiezzaGamma = '1'	
																	and lv.AmpiezzaGamma = '1'
		--documento pda
		inner join CTL_DOC as dpda WITH (NOLOCK) on dpda.LinkedDoc = d.id and dpda.Deleted = 0 and dpda.TipoDoc = 'PDA_MICROLOTTI'
		--offerte pda
		inner join Document_PDA_OFFERTE as pda WITH (NOLOCK) on pda.IdHeader = dpda.Id

		-- lotti della PDA
		inner join Document_MicroLotti_Dettagli rl WITH (NOLOCK) on rl.idHeader = dpda.Id and rl.TipoDoc = 'PDA_MICROLOTTI' and isnull(lv.NumeroLotto, '1') = isnull(rl.NumeroLotto, '1') 
																	and ( lv.Voce = rl.Voce or lv.numeroriga=rl.numeroriga )

		--lotti offerte
		inner join Document_MicroLotti_Dettagli ro WITH (NOLOCK) on ro.idHeader = pda.IdRow and ro.TipoDoc = 'PDA_OFFERTE' and isnull(lv.NumeroLotto, '1') = isnull(ro.NumeroLotto, '1') 
																	and ( lv.Voce = ro.Voce or lv.numeroriga=ro.numeroriga )

		--azienda che ha fatto l'offerta
		INNER JOIN aziende aziPda WITH (NOLOCK) on aziPda.idazi = pda.idAziPartecipante
		
		--offerta ampiezza di gamma
		--inner join ctl_doc as ag WITH (NOLOCK) on pda.IdMsg = ag.LinkedDoc and ag.TipoDoc = 'OFFERTA_AMPIEZZA_DI_GAMMA' and ag.VersioneLinkedDoc = lv.NumeroLotto + '-' + cast(lv.Voce as varchar)
		----prodotti offerta ampiezza di gamma
		--inner join Document_MicroLotti_Dettagli as pag WITH (NOLOCK) on pag.IdHeader = ag.Id and pag.TipoDoc = ag.TipoDoc and pag.Voce = 0
	where
		d.TipoDoc in ('BANDO_GARA','BANDO_SEMPLIFICATO','BANDO_CONCORSO') and
		d.Deleted = 0 and
		d.StatoFunzionale not in  ('InLavorazione','Rifiutato','InApprove') and 
		(getdate() >= db.DataScadenzaOfferta)
		and db.tipobandogara not in ('4','5') -- per escludere gli avvisi dell''AFFIDAMENTO DIRETTO A DUE FASI

		-- solo i lotti aggiudicati
		and rl.statoriga in ( 'AggiudicazioneCond','AggiudicazioneDef','AggiudicazioneProvv','Valutato')



	
	set @SQLCmd =  'select * from 
						#TemplistaLotti where 1 = 1 '
	
	if 	@SQLWhere <> ''
		set   @SQLCmd = @SQLCmd +  ' and  ' + @SQLWhere

	if @TuttiOperatoriEconomici <> 'si' -- in questo caso dobbiamo prendere solo l'aggiudicatario
	begin
		set   @SQLCmd = @SQLCmd +  ' and Aggiudicatario = ''si''  '
	end

	if 	@Filter <> ''
		set   @SQLCmd = @SQLCmd +  ' and  ' + @Filter 
	
	if rtrim( @Sort ) <> ''
		set @SQLCmd=@SQLCmd + ' order by ' + @Sort

	--print @SQLCmd

	exec (@SQLCmd)

end 






GO
