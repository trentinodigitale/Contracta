USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_VIEW_REPORT_EROSIONE_MACROCONVENZIONI]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[DASHBOARD_SP_VIEW_REPORT_EROSIONE_MACROCONVENZIONI]
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

	declare @Param varchar(8000)
	declare @Profilo as varchar(1500)
	declare @Ambito as varchar(1500)
	declare @Descrizione as varchar(1500)
	
	
	set nocount on

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp
	--set @Descrizione	= dbo.GetParam( 'Descrizione'	, @Param ,1)
	
	--costruisco select da eseguire
	declare @SQLCmd			varchar(8000)
	declare @SQLWhere		varchar(8000)
	
	--ricavo la condizone di where di base basata sulle colonne della vista  da cui tolgo l'ambito per gestirlo separatamente
	set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_REPORT_EROSIONE_MACROCONVENZIONI' , 'V',  @AttrName  ,  @AttrValue ,  @AttrOp )
	
	--METTO IN UNA TEMP LE CONVENZIONI DI COMPETENZA 
	select
		
		C.Id,
		DC.Macro_Convenzione,
		DC.NumOrd,
		DC.CIG_MADRE,
		DC.CIG_MADRE as CIG_MADRE_TEXT,
		c.Titolo,
		c.StatoFunzionale,
		AZ.IdAzi as Mandataria,
		AZ.aziPartitaIVA,
		DC.DataInizio,
		DC.DataFine,
		dc.Total,
		dc.Ambito,
		DC1.value as Acquisto_Sociale,
		DC2.value as Appalto_Verde,
		P2.IdPfu as Owner
		--DCL.NumeroLotto,
		--DCL.Descrizione,
		--DCL.Importo,
		--VDIL.rda_total AS TotaleOrdinativiLotto,
		--isnull(DCL.Tot_Altri_Ordinativi_Lotto, 0) + isnull(DCL.Impegnato, 0) as Impegnato,
		--case when DCL.Importo = 0 then
		--	0
		--	else
		--		(isnull(DCL.Tot_Altri_Ordinativi_Lotto, 0) + isnull(DCL.Impegnato, 0)) / DCL.Importo
		--	end as LivelloErosione,
		--dcl.Importo - (isnull(DCL.Tot_Altri_Ordinativi_Lotto, 0) + isnull(DCL.Impegnato, 0)) as Residuo

	--- L. Importo
	--- M. Totale Ordinativi lotto.  rda_total.                               | [VIEW_DOCUMENT_IMPORTI_LOTTI]                                         
	--- N.	Totale Ordinato Eroso  Tot_Altri_Ordinativi_Lotto				      | [CONVENZIONE_CAPIENZA_LOTTI_VIEW] 
	--- O.	Livello Erosione.  Calcolo % (%  N  /  L).                        
	--- P.	Residuo L - N  

	into 
		#TempConvenzioni

	FROM 
		ctl_doc C with(nolock) 
			inner join Document_Convenzione DC with(nolock) on C.id=DC.id	
			inner join Aziende AZ with(nolock) on DC.Mandataria = AZ.IdAzi
			--inner join CONVENZIONE_CAPIENZA_LOTTI_VIEW DCL on C.Id = DCL.idheader
			--inner join VIEW_DOCUMENT_IMPORTI_LOTTI VDIL ON C.ID = VDIL.idheader and DCL.NumeroLotto = VDIL.NumeroLotto
			left join ctl_doc_value DC1 with(nolock) on C.id=DC1.IdHeader and DC1.dse_id='INFO_AGGIUNTIVE' and DC1.dzt_name='Acquisto_Sociale'
			left join ctl_doc_value DC2 with(nolock) on C.id=DC2.IdHeader and DC2.dse_id='INFO_AGGIUNTIVE' and DC2.dzt_name='Appalto_Verde'
			left join profiliUtente P  with(nolock) on P.idpfu=c.idpfu 
			inner join ProfiliUtente P2 with(nolock) on P2.pfuIdAzi=p.pfuidazi

	WHERE C.tipodoc= 'CONVENZIONE' and C.StatoFunzionale IN ('Pubblicato','Chiuso')
		  and P2.IdPfu = @IdPfu 

	--METTO IN UNA TEMP PER RECUPERARE LE INFPO DELLA VISTA  CONVENZIONE_CAPIENZA_LOTTI_VIEW
	select 
		C.*
		,DCL.NumeroLotto
		,DCL.Descrizione
		,DCL.Importo
		--,VDIL.rda_total AS TotaleOrdinativiLotto
		, isnull(DCL.Tot_Altri_Ordinativi_Lotto, 0) + isnull(DCL.Impegnato, 0) as Impegnato
		, 
		case 
			when DCL.Importo = 0 then 0
			else(isnull(DCL.Tot_Altri_Ordinativi_Lotto, 0) + isnull(DCL.Impegnato, 0)) / DCL.Importo

			end as LivelloErosione

		, dcl.Importo - (isnull(DCL.Tot_Altri_Ordinativi_Lotto, 0) + isnull(DCL.Impegnato, 0)) as Residuo
		, DCL.CodiceAIC
		, DCL.CodiceATC
		, DCL.CODICE_CPV
		, DCL.CODICE_CND
		, DCL.PrincipioAttivo
		--, replace(DCL.Descrizione_Codice_Regionale,CHAR(13)+CHAR(10),'<br>') as Descrizione_Codice_Regionale
		,DCL.Descrizione_Codice_Regionale
			into #Temp2Convenzioni 

		from
			#TempConvenzioni C 
				inner join CONVENZIONE_CAPIENZA_LOTTI_VIEW DCL on C.Id = DCL.idheader
				--inner join VIEW_DOCUMENT_IMPORTI_LOTTI VDIL ON C.ID = VDIL.idheader and DCL.NumeroLotto = VDIL.NumeroLotto
		

	
		--METTO IN UNA TEMP FINALE PER RICAVARE LE INFO DELLA VIEW_DOCUMENT_IMPORTI_LOTTI

		SELECT 
			C.* 
			,VDIL.rda_total AS TotaleOrdinativiLotto

				into #TempFinaleConvenzioni

			from 
				#Temp2Convenzioni C
					inner join VIEW_DOCUMENT_IMPORTI_LOTTI VDIL ON C.ID = VDIL.idheader and C.NumeroLotto = VDIL.NumeroLotto


--EFFETTUO LA SELECT FINALE
	set @SQLCmd =  'select 
						* from 
							#TempFinaleConvenzioni  
								where 1 = 1 '
						
	if 	@SQLWhere <> ''
		set   @SQLCmd = @SQLCmd +  ' and  ' + @SQLWhere
	
	if @Filter <> ''
			set   @SQLCmd = @SQLCmd + ' and ( ' + @Filter + ' ) '	
	
	if @IdPfu <> ''
		set @SQLCmd = @SQLCmd + ' and owner = ' + cast( @IdPfu as varchar(20))
	
	if rtrim( @Sort ) <> ''
		set @SQLCmd=@SQLCmd + ' order by ' + @Sort


	

	--print @SQLCmd
	exec (@SQLCmd)

	--select @cnt = count(*) from #temp
	--set @cnt = @@rowcount
	drop table #TempFinaleConvenzioni
	drop table #Temp2Convenzioni
	drop table #TempConvenzioni

end





GO
