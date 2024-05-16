USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DASHBOARD_SP_AGGIUDICAZIONI_OE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[OLD_DASHBOARD_SP_AGGIUDICAZIONI_OE]
(@IdPfu							int,
 @AttrName						varchar(8000),
 @AttrValue						varchar(8000),
 @AttrOp 						varchar(8000),
 @Filter                        varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output,
 @nIsExcel						int = 0
)
as
	declare @Param varchar(8000)
	declare @DataInizio as varchar(10)
	declare @DataFine as varchar(10)
	declare @Fornitore as varchar(255)
	declare @StazioneAppaltante  as varchar(255)
	declare @DescTipoProcedura as varchar(255)
	
	SET NOCOUNT ON

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp

	--recupero i parametri DataInizio, DataFine, Fornitore e Tipo Procedura
    set @DataInizio = dbo.GetParam( 'DataInizio' , @Param ,1)
	set @DataFine = dbo.GetParam( 'DataFine' , @Param ,1)
	set @Fornitore = dbo.GetParam( 'Fornitore' , @Param ,1)
	set @StazioneAppaltante = dbo.GetParam( 'StazioneAppaltante' , @Param ,1)
	set	@DescTipoProcedura = dbo.GetParam( 'DescTipoProcedura' , @Param ,1)
	
	--costruisco select da eseguire
	declare @SQLCmd			varchar(8000)
	declare @SQLWhere		varchar(8000)
	
	set @SQLCmd = ''
	set @SQLWhere =''
	
	--set @SQLCmd =  @SQLCmd + '
	--	SELECT
	--		E.Azienda as StazioneAppaltante 
	--		, SA.aziRagioneSociale as enteappaltante
	--		, S.IdAziAggiudicataria as Fornitore
	--		, FO.aziRagioneSociale as RAGIONE_SOCIALE_FORNITORE
	--		, dbo.GetDescTipoProcedura ( B.Tipodoc , TipoProceduraCaratteristica , ProceduraGara )  as DescTipoProcedura
	--		, sum(S.Importo) as Total
	--		, count(E.Id) as numerorighe

	--		into #LST_AGGIUDICAZIONI_OE
	--		FROM ctl_doc E with(nolock) 
	--				INNER JOIN Document_comunicazione_StatoLotti S with(nolock) ON S.IDHEADER = E.ID and  S.Deleted = 0 
	--				INNER JOIN CTL_DOC P WITH (NOLOCK) on  P.Id = E.LinkedDoc 
	--				INNER JOIN Document_Bando db WITH (NOLOCK) on p.linkedDoc = db.idheader
	--				INNER JOIN CTL_DOC B WITH (NOLOCK) on  B.Id = P.LinkedDoc 
	--				INNER JOIN AZIENDE SA WITH (NOLOCK) on  SA.IdAzi = E.Azienda 
	--				INNER JOIN AZIENDE FO WITH (NOLOCK) on  FO.IdAzi = S.IdAziAggiudicataria
					
	--		WHERE
	--			e.tipodoc = ''PDA_COMUNICAZIONE_GENERICA''
	--			and E.JumpCheck like ''%-ESITO_DEFINITIVO_MICROLOTTI'' 
	--			and e.Deleted = 0 
	--			and e.StatoFunzionale  = ''Inviato'' 
	--	'

	set @SQLCmd = '
			select 	
				gara.azienda as StazioneAppaltante 
				, SA.aziRagioneSociale as enteappaltante
				, d.idAziPartecipante as Fornitore
				, FO.aziRagioneSociale as RAGIONE_SOCIALE_FORNITORE
				, dbo.GetDescTipoProcedura ( gara.Tipodoc , db.TipoProceduraCaratteristica , db.ProceduraGara )  as DescTipoProcedura
				, count( * ) as numerorighe
				, sum( case when m.StatoRiga in ( ''AggiudicazioneDef'', ''AggiudicazioneCond'' ) then 1 else 0 end ) as TotAggiudicazioniDef
				
					INTO 
						#LST_AGGIUDICAZIONI_OE
			from 
				ctl_doc pda with(nolocK)
					inner join ctl_doc gara with(nolock) on gara.id = pda.LinkedDoc and gara.Deleted = 0 and gara.StatoFunzionale not in ( ''Revocato'' )
					INNER JOIN Document_Bando db WITH (NOLOCK) on db.idheader = gara.Id
					inner join Document_MicroLotti_Dettagli m with(nolock) on m.IdHeader = pda.Id 
																			and m.StatoRiga in ( ''AggiudicazioneCond'', 
																								''AggiudicazioneDef'', 
																								''AggiudicazioneProvv'' ) 
																			and m.Voce = 0
																			and m.TipoDoc = pda.TipoDoc
					inner join Document_PDA_OFFERTE d with(nolock) on d.idHeader = m.IdHeader
					inner join Document_MicroLotti_Dettagli o with(nolock) on o.idheader = d.idRow
																			and o.TipoDoc = ''PDA_OFFERTE''
																			and o.Voce = 0 and o.NumeroLotto = m.NumeroLotto and ( o.Posizione like ''%Aggiudicatario%'' or o.Posizione like ''%idoneo%'' )
					inner join AZIENDE FO WITH (NOLOCK) on  FO.IdAzi = d.idAziPartecipante
					INNER JOIN AZIENDE SA WITH (NOLOCK) on  SA.IdAzi = gara.Azienda 

					left join ctl_doc E with(nolock) on e.tipodoc = ''PDA_COMUNICAZIONE_GENERICA''
													and E.JumpCheck like ''%-ESITO_DEFINITIVO_MICROLOTTI''
													and e.Deleted = 0 
													and e.StatoFunzionale  = ''Inviato''
													and e.LinkedDoc = pda.Id

					left join Document_comunicazione_StatoLotti S with(nolock) ON S.IDHEADER = E.ID and S.Deleted = 0 and s.NumeroLotto = m.NumeroLotto

			where 
				pda.Deleted = 0 and pda.TipoDoc = ''PDA_MICROLOTTI''
			
'

	--aggiungo la condizione su DataInizio
	if @DataInizio <> '' 
	begin
		--set @SQLWhere = @SQLWhere + ' AND E.DataInvio >= ''' + @DataInizio + '''';
		set @SQLWhere = @SQLWhere + ' AND isnull(E.DataInvio, pda.Data) >= ''' + @DataInizio + '''';
	end

	--aggiungo la condizione sul ruolo
	if 	@DataFine <> '' 
	begin
		--set @SQLWhere = @SQLWhere + ' AND E.DataInvio <= ''' + @DataFine + ''''
		set @SQLWhere = @SQLWhere + ' AND isnull(E.DataInvio, pda.Data) <= ''' + @DataFine + ''''
	end
	
	--aggiungo la condizione su Fornitore
	if @Fornitore <> '' 
	begin
		--set @SQLWhere = @SQLWhere + ' AND S.IdAziAggiudicataria = ' + @Fornitore + ''
		set @SQLWhere = @SQLWhere + ' AND d.idAziPartecipante = ' + @Fornitore + ''
		
	end
		
	--aggiungo la condizione su Ente
	if @StazioneAppaltante <> '' 
	begin
		--set @SQLWhere = @SQLWhere + ' AND E.azienda = ' + @StazioneAppaltante + ''
		set @SQLWhere = @SQLWhere + ' AND gara.azienda = ' + @StazioneAppaltante + ''
	end


	set @SQLCmd=@SQLCmd + @SQLWhere
	
	-- Group By
 	--set @SQLCmd=@SQLCmd + '
		--group by dbo.GetDescTipoProcedura ( B.Tipodoc , TipoProceduraCaratteristica , ProceduraGara ), 
		--		E.Azienda,
		--		S.IdAziAggiudicataria,
		--		SA.aziRagioneSociale, 
		--		FO.aziRagioneSociale
		--'

	set @SQLCmd = @SQLCmd + '	
		group by gara.azienda 
			, SA.aziRagioneSociale
			, d.idAziPartecipante
			, FO.aziRagioneSociale
			, dbo.GetDescTipoProcedura ( gara.Tipodoc , db.TipoProceduraCaratteristica , db.ProceduraGara )	
		'
	
	set @SQLCmd=@SQLCmd + ' 
		SELECT 
			row_number() OVER(ORDER BY StazioneAppaltante ASC) as id, * 
			from 
				#LST_AGGIUDICAZIONI_OE '
		
	--aggiungo la condizione su Tipo Procedura
	--alla tabella temporanea che già lo contiene
	if @DescTipoProcedura <> '' 
	begin
		
		set @SQLCmd = @SQLCmd  + ' 
								where DescTipoProcedura = ''' + @DescTipoProcedura + ''' '
		
	end

	if @Sort <> ''
	begin
		set @SQLCmd=@SQLCmd + ' order by ' + @Sort
	end


	--print @SQLCmd

	exec (@SQLCmd)
	

GO
