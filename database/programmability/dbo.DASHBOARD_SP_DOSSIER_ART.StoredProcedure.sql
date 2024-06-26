USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_DOSSIER_ART]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [dbo].[DASHBOARD_SP_DOSSIER_ART]
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
declare @Param varchar(8000)
	declare @Descrizione varchar(50)
	declare @CodiceFornitore varchar(50)
	declare @CodiceArticolo varchar(50)

	declare @SuffLNG varchar(50)
	declare @AziCatalogo varchar(50)
	declare @Merceologia varchar(50)

	set @AziCatalogo = '35152001'

	set nocount on

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp


	declare @SQLCmd			varchar(8000)
	declare @SQLWhere		varchar(8000)
	set @SQLWhere = dbo.GetWhere( 'articoli' , 'U', @AttrName ,  @AttrValue ,  @AttrOp )

	declare @CrLf varchar (10)
	set @CrLf = '
'


	-- criteri di ricerca
	set @Descrizione				= replace( dbo.GetParam( 'Descrizione' , @Param ,1) ,'''','''''')
	set @CodiceArticolo				= replace( dbo.GetParam( 'CodiceArticolo' , @Param ,1) ,'''','''''')
	set @Merceologia				= replace( dbo.GetParam( 'ArtClasMerceologica' , @Param ,1) ,'''','''''')

-------------------------------------------------------------------
-- recupero la lingua dell'utente 
-------------------------------------------------------------------
	set @SuffLNG = 'I'

	select @SuffLNG = lngSuffisso from ProfiliUtente inner join Lingue on pfuIdLng = IdLng where idpfu = @IdPfu

-------------------------------------------------------------------
-- Verifico la presenza di eventuali restrizioni sull'utente
-------------------------------------------------------------------



-------------------------------------------------------------------
-- creo la query di estrazione
-------------------------------------------------------------------


	set @SQLCmd =  '
	select * from (
		select a.* , 
			
			a.artCode as CodiceArticolo ,
			d1.dscTesto as Descrizione ,
			d2.dsctesto as DescMerceologia , 
			artIdUms as UnitMis , 
			artQMO as QMOArticolo
		from articoli a 
			inner join descs' + @SuffLNG  + ' d1 on a.artIdDscDescrizione = d1.IdDsc  

			inner join dizionarioattributi on dztnome = ''ArtClasMerceologica'' and dztdeleted=0
			inner join dominigerarchici on dztidtid=dgtipogerarchia and dgcodiceinterno = cast(artCspValue as varchar(50))
			inner join descs' + @SuffLNG  + ' d2 on d2.iddsc = dgiddsc


		where artIdAzi = ' + @AziCatalogo + '
			and artDeleted = 0 

	) as a where 1 = 1 ' + @CrLf

	if rtrim( @SQLWhere ) <> ''
		set @SQLCmd = @SQLCmd + ' and ' + @SQLWhere + @CrLf



	if @CodiceArticolo <> ''
		set @SQLCmd = @SQLCmd + ' and artCode like ''' + @CodiceArticolo + ''' '

	if @Descrizione <> ''
		set @SQLCmd = @SQLCmd + ' and Descrizione like ''' + @Descrizione + ''' '

	if @Merceologia	 <> ''
		set @SQLCmd = @SQLCmd + ' and artCspValue = ''' + @Merceologia	+ ''' '


	if @Filter <> '' 
		set @SQLCmd = @SQLCmd + ' and ( ' + @Filter + ' ) ' + @CrLf


	if @Sort <> ''
		set @SQLCmd = @SQLCmd + ' ORDER BY ' + @Sort  + @CrLf


	

	exec (@SQLCmd)
	--print @SQLCmd

	--set @cnt = @@rowcount




GO
