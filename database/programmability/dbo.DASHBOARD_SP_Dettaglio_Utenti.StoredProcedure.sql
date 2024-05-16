USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_Dettaglio_Utenti]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   proc [dbo].[DASHBOARD_SP_Dettaglio_Utenti]
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

	declare @SuffLNG varchar(50)

	declare @Profilo varchar(150)


	set nocount on

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp


	declare @SQLCmd			varchar(8000)
	declare @SQLWhere		varchar(8000)
	

	
	set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_Dettaglio_Utenti' , 'V', @AttrName ,  @AttrValue ,  @AttrOp )


	declare @CrLf varchar (10)
	set @CrLf = '
'


	-- criteri di ricerca
	set @Profilo				= replace( dbo.GetParam( 'Profilo' , @Param ,1) ,'''','''''')
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


	set @SQLCmd =  'select * from DASHBOARD_VIEW_Dettaglio_Utenti where IdPfu =  ' + cast( @IdPfu as varchar (10)) + @CrLf

	if rtrim( @SQLWhere ) <> ''
		set @SQLCmd = @SQLCmd + ' and ' + @SQLWhere + @CrLf



	if @Profilo <> ''
		set @SQLCmd = @SQLCmd + ' and ID in ( select idpfu from profiliutenteattrib where dztnome = ''Profilo'' and attvalue =  ''' + @Profilo + ''' )'



	if @Filter <> '' 
		set @SQLCmd = @SQLCmd + ' and ( ' + @Filter + ' ) ' + @CrLf


	if @Sort <> ''
		set @SQLCmd = @SQLCmd + ' ORDER BY ' + @Sort  + @CrLf


	

	exec (@SQLCmd)
	--print @SQLCmd

	--set @cnt = @@rowcount





GO
