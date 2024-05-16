USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_VIEW_Seleziona_Ente]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[DASHBOARD_SP_VIEW_Seleziona_Ente] 
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
	declare @azienda					varchar(250)
	declare @numEntiContratto			int;

	set nocount on

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp
	
	--tolgo gli attributi che gestisco in modo personalizzato
	set @AttrName =REPLACE( @AttrName , 'Ambito' , '')

	declare @SQLCmd			varchar(max)
	declare @SQLWhere		varchar(8000)
	set @SQLWhere = dbo.GetWhere( 'Seleziona_Ente' , 'V', @AttrName ,  @AttrValue ,  @AttrOp )

	declare @CrLf varchar (10)
	set @CrLf = '
'

	--acquisisco pfuIdAzi dell'utente collegato
	select @azienda = pfuIdAzi from ProfiliUtente with(nolock) where IdPfu = @IdPfu

	select @numEntiContratto = COUNT(*) from ACCORDO_CREA_CONVENZIONI_VIEW where Azienda = @azienda

	if @numEntiContratto > 0
		begin 
			set @SQLCmd =  '
				select * 
					from Seleziona_Ente 
					where idAziPartecipante in (select idazi from ACCORDO_CREA_CONVENZIONI_VIEW where StatoFunzionale = ''Inviato'' and Azienda = ' + @azienda + ')  '  + @CrLf
		end 
	else
	begin 
			set @SQLCmd =  '
				select * 
					from Seleziona_Ente where 1=1 '  + @CrLf
	end

	
	
	if rtrim( @SQLWhere ) <> ''
		set @SQLCmd = @SQLCmd + ' and ' + @SQLWhere + @CrLf

	if @Filter <> '' 
		set @SQLCmd = @SQLCmd + ' and ( ' + @Filter + ' ) ' + @CrLf


	if @Sort <> ''
		set @SQLCmd = @SQLCmd + ' ORDER BY ' + @Sort  + @CrLf

	exec (@SQLCmd)
	--print @SQLCmd






GO
