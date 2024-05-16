USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_DOCUMENT_CK_TOOLBAR_PDA_COMUNICAZIONE_GENERICA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD2_DOCUMENT_CK_TOOLBAR_PDA_COMUNICAZIONE_GENERICA](  @DocName nvarchar(500) , @IdDoc nvarchar(500) , @idUser int )
AS
begin
	
	set nocount on
	declare @idPda int
	declare @idGara int
	declare @COM_ID int
	declare @Contesto varchar(500)
	declare @TipoDocSource varchar(200)

	--ricavo il tipodoc sorgente da cui ho creato la comunicazionme

	select 
			@TipoDocSource = S.TipoDoc
		from 
			ctl_doc C with (nolock)
				inner join ctl_doc S with (nolock) on S.id = C.LinkedDoc
		where
			C.id = @IdDoc

	--dalla COMUNICAZIONE ricavo id della pda
	select @idPda = linkeddoc, @Contesto = JumpCheck from ctl_doc with (nolock) where id = @IdDoc 

	--verifico che la comunicazione è legata ad una PDA alla funzione
	if exists ( select id from ctl_doc with (nolock) where id = @idPda and TipoDoc in ( 'PDA_MICROLOTTI','PDA_CONCORSO') ) 
	begin 

		--dalla PDA_MICROLOTTI ricavo l'id della gara 
		select @idGara = linkeddoc from ctl_doc with (nolock) where id = @idPda

		--ricavo id della COMMISSIONE a partire dalla gara
		select @COM_ID = id from ctl_doc with (nolock) where linkeddoc = @idGara and TipoDoc ='COMMISSIONE_PDA' and statofunzionale ='pubblicato' and deleted=0
	
	end
	else
	begin 
		set @COM_ID = -1
	end

	if @Contesto <> '' 
		set @Contesto = right (@Contesto,len(@Contesto)-2)


	select
		C.*,

		case when ISNULL(v.num,0) = 0 and C.JumpCheck='1-VERIFICA_REQUISITI' then '1' else '0' end as CAN_SORT,
		
		case 
			
			when @TipoDocSource in ('BANDO_CONCORSO','PDA_CONCORSO') then 'no'

			when C.JumpCheck IN ('0-REVOCA_BANDO', '0-SOSPENSIONE_GARA' ) then dbo.ATTIVA_ELENCO_DEST_PROCEDURA(C.linkeddoc) 		
			
			else 'si'

		end	as ATTIVO_VIS_DEST

		, dbo.CAN_CREATE_COMUNICAZIONI(@idUser , @COM_ID, @Contesto) as CAN_CREATE_COMUNICAZIONI

	from 
		CTL_DOC C with(nolock)
			left join (  select count(*) as num ,linkeddoc from VIEW_PDA_COMUNICAZIONE_DETTAGLI with(nolock) group by linkeddoc ) V 
					on V.LinkedDoc=C.id and C.TipoDoc='PDA_COMUNICAZIONE_GENERICA'
		
	where C.Id = @IdDoc



end
GO
