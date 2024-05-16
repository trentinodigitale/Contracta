USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_VIEW_SCRITTURA_PRIVATA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[DASHBOARD_SP_VIEW_SCRITTURA_PRIVATA]
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
	
	--ricavo la condizone di where
	set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_SCRITTURA_PRIVATA' , 'V', @AttrName ,  @AttrValue ,  @AttrOp )
	
	
	-- aggiungo le gare dove l'utente è il rup 
	select RUP.IdHeader as idBando  , RUP.Value as UserRUP into #TempGare
		from CTL_DOC_Value RUP with(nolock) 
			where RUP.DSE_ID='InfoTec_comune' and RUP.DZT_Name='UserRUP' and Rup.Row=0				
				and RUP.Value = @IdPfu

	set @SQLCmd =  'select 
						distinct
						sp.Id, 
						sp.IdPfu, 					
						sp.Protocollo, 					
						sp.DataInvio, 
						sp.StatoFunzionale, 
						sp.idPfuInCharge, 
						sp.tipodoc as OPEN_DOC_NAME,
						sp.destinatario_azi as muidazidest ,
						TipoProceduraCaratteristica,
						CV.Value as NewTotal,
						Cv2.Value as BodyContratto,
						convert( datetime, convert(varchar(10),Cv3.Value, 126 ))  as DataScadenza,				
						UserRUP	
					from ctl_doc sp with(nolock)						
						left outer join CTL_DOC com with(nolock) on com.id = sp.linkedDoc -- PDA_COMUNICAZIONE_GENERICA
						left outer join CTL_DOC pda with(nolock) on pda.id = com.linkedDoc -- PDA_MICROLOTTI
						left outer join CTL_DOC B with(nolock)  on B.id = PDA.linkedDoc -- BANDO_GARA
						left outer join document_bando  with(nolock) on B.id = idHeader
						left outer join CTL_DOC_Value CV with(nolock) on CV.IdHeader=sp.id and cv.DSE_ID=''CONTRATTO'' and cv.Row=0 and cv.DZT_Name=''NewTotal''
						left outer join CTL_DOC_Value CV2 with(nolock) on CV2.IdHeader=sp.id and cv2.DSE_ID=''CONTRATTO'' and cv2.Row=0 and cv2.DZT_Name=''BodyContratto''
						left outer join CTL_DOC_Value CV3 with(nolock) on CV3.IdHeader=sp.id and cv3.DSE_ID=''CONTRATTO'' and cv3.Row=0 and cv3.DZT_Name=''DataScadenza''				
						left outer join #TempGare on idbando=document_bando.idheader
					where sp.tipodoc=''SCRITTURA_PRIVATA'' and sp.deleted = 0 '

	set @SQLCmd = @SQLCmd + ' and (  sp.idpfu = ' + cast( @IdPfu as varchar(10)) + ' or UserRUP = ' + cast( @IdPfu as varchar(10)) + '  )  '
	
	

	if 	@SQLWhere <> ''
	begin
		set @SQLWhere = REPLACE(@SQLWhere ,' protocollo ' , 'sp.protocollo')
		set   @SQLCmd = @SQLCmd +  ' and ' + @SQLWhere
	end

	
	if @Filter <> ''
		set   @SQLCmd = @SQLCmd + ' and ( ' + @Filter + ' ) '
	
	if rtrim( @Sort ) <> ''
		set @SQLCmd=@SQLCmd + ' order by ' + @Sort




	--print @SQLCmd
	exec (@SQLCmd)

	

end





GO
