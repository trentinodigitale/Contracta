USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DASHBOARD_SP_VIEW_CATALOGHI_MEA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE proc [dbo].[OLD_DASHBOARD_SP_VIEW_CATALOGHI_MEA] 
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

	declare @Param						varchar(8000)
	declare @IdentificativoIniziativa	varchar(250)
	declare @Convenzione				varchar(250)
	declare @Codice						varchar(250)
	declare @Descrizione				varchar(250)
	declare @Macro_Convenzione			varchar(250)
	declare @Convenzione_Lotto			varchar(8000)
	declare @ambito						varchar(250)
	declare @ClasseIscriz				varchar(max)
	declare @debug						int
	declare @Fornitore					int
	set nocount on

	set @debug  =0

	
	if @debug = 1
	begin
		print GETDATE() 
		print 'inizio'
	end 

	if @debug = 1
		select GETDATE() as dataoperazione

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp
	
	set @ClasseIscriz = ''

	select @Fornitore = pfuidazi from ProfiliUtente with(nolock) where IdPfu = @IdPfu

	-----------------------------------------------------------
	-- recupero le classi di iscrizione dell'azienda utente
	-- concateno tutte le classi di iscrizione per i vari albi del ME
	-----------------------------------------------------------
	select @ClasseIscriz = @ClasseIscriz + Cl.Value 
		from ProfiliUtente p with (nolock)

			--prendo tutti gli albi ME dove il fornitore è iscritto
			inner join (

						select idAzi , AL.id , I.Id_Doc -- ultima istanza apparovata

							from CTL_DOC AL with (nolock)
							
								inner join CTL_DOC_Destinatari I with (nolock) on I. idHeader = AL. Id and I.StatoIscrizione = 'Iscritto'

							where

								AL.TipoDoc = 'BANDO' and
								AL.deleted = 0 and
								isnull( AL.jumpcheck,'') = '' and --  Mercato Elettronico
								AL. StatoFunzionale = 'Pubblicato' and
								isnull(AL.DataScadenza, '3000-01-01') > GETDATE()

						) as I on I.IdAzi = p.pfuIdAzi -- or C.LinkedDoc = I.Id

			-- approvazione dell'istanza dove sono presenti le classi di iscrizione valide
			inner join CTL_DOC Ap with(nolock) on Ap.LinkedDoc = I.Id_Doc and Ap.TipoDoc = 'CONFERMA_ISCRIZIONE' and Ap.Deleted = 0  

			-- recupero le classi confermate
			inner join ctl_doc_value Cl with(nolock ) on Cl.IdHeader = Ap.Id and   Cl.DZT_Name = 'ClasseIscriz' 

		where p.IdPfu = @IdPfu

	if @debug = 1
		select @ClasseIscriz as ClasseIscriz , GETDATE() as dataoperazione

	-----------------------------------------------------------
	-- esplode la selezione sulle foglie nel caso in cui sia stato consentito selezionare un ramo 
	-----------------------------------------------------------
	set @ClasseIscriz =  dbo.ExplodeClasseIscriz( @ClasseIscriz )

	if @debug = 1
		select @ClasseIscriz as ClasseIscriz , GETDATE() as dataoperazione

	-----------------------------------------------------------
	-- recupero i modelli pertinenti con le classi di iscrizione del fornitore
	-----------------------------------------------------------
				--select m.id 
				--	into #ModelliPertinenti
				--	from CTL_DOC m with(nolock)
				--		inner join CTL_DOC_Value v with(nolock) on v.IdHeader = m.Id 
				--													and DSE_ID = 'CLASSE' 
				--													and DZT_Name = 'ClasseIscriz' 
				--													and dbo.Intersezione_Insiemi( dbo.ExplodeClasseIscriz(v.Value) , @ClasseIscriz , '###' ) = 'OK'
				--	where  
				--		m.TipoDoc = 'CONFIG_MODELLI_MEA'
				--		and m.Deleted = 0 
				--		and m.statofunzionale = 'Pubblicato'


	select m.id , dbo.ExplodeClasseIscriz(v.Value) as ClasseIscriz
		into #ModelliPubblicati
		from CTL_DOC m with(nolock)
			inner join CTL_DOC_Value v with(nolock) on v.IdHeader = m.Id 
														and DSE_ID = 'CLASSE' 
														and DZT_Name = 'ClasseIscriz' 
														--and dbo.Intersezione_Insiemi( dbo.ExplodeClasseIscriz(v.Value) , @ClasseIscriz , '###' ) = 'OK'
		where  
			m.TipoDoc = 'CONFIG_MODELLI_MEA'
			and m.Deleted = 0 
			and m.statofunzionale = 'Pubblicato'


	select id 
		into #ModelliPertinenti
		from #ModelliPubblicati
		where dbo.Intersezione_Insiemi( ClasseIscriz , @ClasseIscriz , '###' ) <> '' --= 'OK'



	if @debug = 1
		select Id , GETDATE() as dataoperazione from #ModelliPertinenti

	-----------------------------------------------------------
	-- Aggiungo tutti i modelli che sono legati ai cataloghi del fornitore, 
	-- potrebbero mancare dall'elenco precedente perchè non più pubblicati
	-----------------------------------------------------------
	insert into #ModelliPertinenti ( Id ) -- , Titolo , Descrizione , ClasseIscriz ) 
		select distinct IdDoc
			from CTL_DOC C with(nolock)

			where  
				c.TipoDoc = 'CATALOGO_MEA'
				and C.StatoFunzionale = 'Pubblicato'
				and C.Azienda = @Fornitore
				and c.Deleted = 0 




	-----------------------------------------------------------
	-- elenco degli albi ME pubblicati con le classi valide al momento
	-----------------------------------------------------------
	select 
			a.Id as idAlbo , 
			a.Titolo ,   
			dbo.Insiemi_NOT( dbo.Insiemi_NOT( dbo.ExplodeClasseIscriz(B.ClasseIscriz) , dbo.ExplodeClasseIscriz(v.Value) , '###' ) , dbo.ExplodeClasseIscriz(v1.Value) , '###' )  as ClasseIscriz ,
			i.StatoIscrizione


		into #Albi
		from CTL_DOC a with(nolock)
			inner join CTL_DOC_Destinatari i with(nolock) on I.idheader = a.Id and i.IdAzi = @Fornitore
			inner join Document_Bando B with(nolock) on b.idheader = a.id
			left join CTL_DOC_Value v with(nolock) on v.IdHeader = a.Id 
														and v.DSE_ID = 'CLASSE' 
														and v.DZT_Name = 'ClasseIscriz_Sospese' 
			left join CTL_DOC_Value v1 with(nolock) on v1.IdHeader = a.Id 
														and v1.DSE_ID = 'CLASSE' 
														and v1.DZT_Name = 'ClasseIscriz_Revocate' 
		where  
			a.TipoDoc = 'BANDO'
			and a.Deleted = 0 
			and a.statofunzionale <> 'InLavorazione' -- 'Pubblicato'
			and ISNULL( a.jumpcheck , '' ) = ''  -- Mercato Elettronico dove il fornitore risulta presente , escludiamo altri albi


	-----------------------------------------------------------
	-- elenco dei modelli / cataloghi per la selezione a video
	-----------------------------------------------------------
	select distinct
		M.Id as idModello , cast( M.Body as nvarchar(max)) as Descrizione , A.idAlbo , A.Titolo

		, CP.Protocollo
		, CP.DataInvio
		, case 
				
				when isnull( A.StatoIscrizione, '' ) =  'Sospeso'  then 'Sospeso'
				when A.idAlbo is null then 'Annullato' -- se l'albo non è pubblicato vuol dire che il catalogo non è più valido
				when CL.Id IS not null and CP.Id IS not null then 'In Modifica'
				when CL.Id IS not null and CP.Id is null  and isnull( A.StatoIscrizione, '' ) = 'Iscritto' then 'InLavorazione'
				when CL.Id IS null and CP.Id is not null and isnull( A.StatoIscrizione, '' ) = 'Iscritto'  then 'Pubblicato'
				when CL.Id IS null and CP.Id is not null and isnull( A.StatoIscrizione, '' ) =  'Sospeso'  then 'Sospeso'
				else  ''
			end
			as StatoFunzionale
		
		,cast( M.Id as varchar) + '_' + CAST( a.idAlbo as varchar ) as Id

		into #ElencoModelli

		from CTL_DOC M with(nolock) -- modelli estratti
			inner join CTL_DOC_Value C with(nolock) on C.IdHeader = M.Id and C.DZT_Name = 'ClasseIscrizFoglie' --'ClasseIscriz' 
			
			-- albo compatibile con il modello dove il fornitore risulta presente
			--inner join #Albi A on dbo.Intersezione_Insiemi( dbo.ExplodeClasseIscriz(c.Value ), A.ClasseIscriz , '###' ) <> '' --= 'OK'
			left join #Albi A on dbo.Intersezione_Insiemi( c.Value , A.ClasseIscriz , '###' ) <> '' --= 'OK'


			--eventuale catalogo relativo al modello in lavorazione se esiste
			left join CTL_DOC CL with(nolock) on CL.IdDoc = M.id and CL.StatoFunzionale = 'InLavorazione' and CL.Deleted = 0 and CL.Azienda = @Fornitore AND A.idAlbo = CL.LinkedDoc

			--eventuale catalogo relativo al modello Pubblicato se esiste
			left join CTL_DOC CP with(nolock) on CP.IdDoc = M.id and CP.StatoFunzionale = 'Pubblicato' and CP.Deleted = 0 and CP.Azienda = @Fornitore AND A.idAlbo = Cp.LinkedDoc

			-- albo del catalogo collegato
			--inner join CTL_DOC AL with(nolock) on AL.Id = A.idAlbo

			-- stato di iscrizione relativo all'albo
			--left join CTL_DOC_Destinatari I with(nolock) on I.idHeader = AL.Id and I.IdAzi = @Fornitore

			
		where M.Id in ( select id from #ModelliPertinenti ) 
			AND 
			--LA RIGA DEVE USCIRE O SE LE MIE ISCRIZIONI SONO COMPATIBILI oppure ho un catalogo per quell'albo
			(	
				CL.Id is not null 
				or 
				CP.id is not null  
				or
				( dbo.Intersezione_Insiemi(  dbo.Intersezione_Insiemi( c.Value , isnull( A.ClasseIscriz ,'') , '###' )  , @ClasseIscriz , '###' ) <> '' and A.StatoIscrizione = 'Iscritto' )
				
			) 

		

	if @Sort = '' 
		set @Sort = ' Titolo , Descrizione '



	declare @SQLCmd			varchar(max)
	declare @SQLWhere		varchar(8000)
	--set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_CONVENZIONI' , 'V', @AttrName ,  @AttrValue ,  @AttrOp )

	declare @CrLf varchar (10)
	set @CrLf = '
'

	set @SQLCmd =  '
	select * from #ElencoModelli  '  + @CrLf

	if @Sort <> ''
		set @SQLCmd = @SQLCmd + ' ORDER BY ' + @Sort  + @CrLf

	exec (@SQLCmd)
	--print @SQLCmd






GO
