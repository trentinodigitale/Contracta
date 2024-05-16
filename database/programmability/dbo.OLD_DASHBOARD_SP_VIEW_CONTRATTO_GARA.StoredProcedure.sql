USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DASHBOARD_SP_VIEW_CONTRATTO_GARA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE proc [dbo].[OLD_DASHBOARD_SP_VIEW_CONTRATTO_GARA]
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
	set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_CONTRATTO_GARA' , 'V',replace(  @AttrName , 'Cig' , '' ) ,  @AttrValue ,  @AttrOp )

--				[Id], [IdPfu], [IdDoc], [TipoDoc], [StatoDoc], [Data], [Protocollo], [PrevDoc], [Deleted], [Titolo], [Body], [Azienda], [StrutturaAziendale], [DataInvio], [ProtocolloRiferimento], [ProtocolloGenerale], [Fascicolo], [Note], [DataProtocolloGenerale], [LinkedDoc], [SIGN_HASH], [SIGN_ATTACH], [SIGN_LOCK], [JumpCheck], [StatoFunzionale], [Destinatario_User], [Destinatario_Azi], [RichiestaFirma], [NumeroDocumento], [DataDocumento], [Versione], [VersioneLinkedDoc], [GUID], [idPfuInCharge], [CanaleNotifica], [URL_CLIENT], [Caption], [FascicoloGenerale], [OPEN_DOC_NAME], [muidazidest], [TipoProceduraCaratteristica], [NewTotal], [BodyContratto], [DataScadenza], [idBando]
	

	--set @SQLCmd =  'select c.*	 from DASHBOARD_VIEW_CONTRATTO_GARA c 

	--inner join (
	--	-- estendo la visualizzazione a tutti gli utenti nei riferimenti della gara come BANDO
	--	select idpfu , id as idBando  from ctl_doc where tipodoc in (  ''BANDO_GARA'' , ''BANDO_SEMPLIFICATO'' )
	--	union 
	--	select idPfu , idheader as idBando from Document_Bando_Riferimenti r with(nolock) where  r.RuoloRiferimenti  = ''Bando'' 
	--) as V on V.idBando = c.idBando
	--'


	set @SQLCmd =  'select c.*	 from DASHBOARD_VIEW_CONTRATTO_GARA c 

	left join (
		-- estendo la visualizzazione a tutti gli utenti nei riferimenti della gara come BANDO
		select distinct idPfu , idheader as idBando from Document_Bando_Riferimenti r with(nolock) where  r.RuoloRiferimenti  = ''Bando'' and idpfu = ' + cast(  @IdPfu aS varchar(10)) + '
	) as V on V.idBando = c.idBando
	'
	
	--if @Descrizione <> '' 
	--begin
	--	set @SQLCmd = @SQLCmd + ' inner join ( select distinct idheader from document_microlotti_dettagli d with(nolock) where d.tipodoc = ''CONVENZIONE'' and d.DESCRIZIONE_CODICE_REGIONALE like ''%' + replace ( @Descrizione  , '''' , '''''' ) + '%'' ) as D on d.idheader = C.id '
	--end
	
	set @SQLCmd = @SQLCmd + ' where (  c.idPfuInCharge = ' + cast( @IdPfu as varchar(10)) + ' or  c.idpfu = ' + cast( @IdPfu as varchar(10)) + ' or c.UserRUP = ' + cast( @IdPfu as varchar(10)) + ' or v.idpfu is not null  )  '




	if 	@SQLWhere <> ''
		set   @SQLCmd = @SQLCmd +  ' and ' + @SQLWhere
	

	
	if @Filter <> ''
		set   @SQLCmd = @SQLCmd + ' and ( ' + @Filter + ' ) '
	
	if rtrim( @Sort ) <> ''
		set @SQLCmd=@SQLCmd + ' order by ' + @Sort




	--print @SQLCmd
	exec (@SQLCmd)

	--select @cnt = count(*) from #temp
	--set @cnt = @@rowcount

end





GO
