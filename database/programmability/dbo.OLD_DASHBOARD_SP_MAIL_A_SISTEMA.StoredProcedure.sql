USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DASHBOARD_SP_MAIL_A_SISTEMA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE proc [dbo].[OLD_DASHBOARD_SP_MAIL_A_SISTEMA]
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
	
	declare @Name as varchar(1500)
	declare @MailGuid as varchar(1500)
	declare @MailData as varchar(50)
	declare @UtenteCommissione nvarchar(200)
	declare @consenti_accesso_per_ruolo as nvarchar(200)
	
	
	
	set nocount on

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp
	set @Name	= dbo.GetParam( 'Name'	, @Param ,1)
	set @MailGuid	= dbo.GetParam( 'MailGuid'	, @Param ,2)
	set @MailData	= dbo.GetParam( 'DataDa'	, @Param ,2) + dbo.GetParam( 'DataA'	, @Param ,2)


	set @UtenteCommissione = cast( @IdPfu as varchar) 

	--costruisco select da eseguire
	declare @SQLCmd			varchar(max)
	declare @SQL			varchar(max)
	declare @SQLWhere		varchar(max)
	

	-- tolgo mail guid per ottimizzare la ricerca
	set @AttrName = replace( @AttrName , 'MailGuid' , 'MailGuid_XX' )

	--set @AttrName = replace( @AttrName , 'MailGuid' , 'MailGuid_XX' )
	--set @AttrName = replace( @AttrName , 'MailGuid' , 'MailGuid_XX' )


	--ricavo la condizone di where di base basata sulle colonne della vista 
	set @SQLWhere = dbo.GetWhere( 'VIEW_DOCUMENT_MAIL_A_SISTEMA' , 'V',@AttrName ,  @AttrValue ,  @AttrOp )


	if @Filter = ''
	 set   @Filter = ' 1 = 1 '
	
	-- effettuo la query finale

	set @SQLCmd = '
		
		select 
				ID, TypeDoc, IdDoc, MailGuid, MailFrom, MailTo, MailObject, 
				[dbo].[StripHTML]( MailBody ) as MailBody, MailCC, MailCCn, MailData,
				MailObj , 
		 
				IdPfuMitt, IdPfuDest, Status, IsFromPec, IsToPec, InOut, deleted, DescrError, DataUpdate, NumRetry, idAziDest, DataSent,
		
				MailData as DataDA ,
				MailData as DataA ,
				TypeDoc as DocType,
				IdDoc as IdProgetto

		'
		
		-- se ho un filtro per guid faccio una ricerca applicando l'indice
		if 	 @MailGuid <> '' 
			set   @SQLCmd = @SQLCmd +  ' from CTL_MAIL_SYSTEM with(nolock,index([IX_CTL_Mail_System_MailGuid_MailTo_InOut_deleted]))  where mailguid = '''  + replace( @MailGuid , '''' , '''''' ) + ''' '
		else
		if 	 @MailData <> '' 
			set   @SQLCmd = @SQLCmd +  ' from CTL_MAIL_SYSTEM with(nolock,index([IX_CTL_Mail_System_Data]))  where  1 = 1 '
		else 
		
			set   @SQLCmd = @SQLCmd +  ' from CTL_MAIL_SYSTEM with(nolock) where 1 = 1  '
		


	set @SQLWhere = replace( @SQLWhere , ' DataDa ' , ' MailData ' )
	set @SQLWhere = replace( @SQLWhere , ' DataA ' , ' MailData ' )
	set @SQLWhere = replace( @SQLWhere , ' DocType ' , ' TypeDoc ' )
	set @SQLWhere = replace( @SQLWhere , ' IdProgetto ' , ' IdDoc ' )

	if 	@SQLWhere <> ''
		set   @SQLCmd = @SQLCmd +  ' and ' + @SQLWhere
	

	
	if @Filter <> ''
		set   @SQLCmd = @SQLCmd + ' and ( ' +   @Filter   + ' ) '
	
	
	set @SQLCmd = @SQLCmd +  ' order by maildata'
	--if rtrim( @Sort ) <> ''
	--begin

	--	set @SQLCmd = @SQLCmd +  ' order by ' + @Sort

	--end


	--print @SQLCmd
	--select @SQLCmd
	exec (@SQLCmd)



end









GO
