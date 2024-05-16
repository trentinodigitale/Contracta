USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[START_PDA_COMUNICAZIONE_OFFERTA_RISP_CHECK_PRODUCT]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE  procedure [dbo].[START_PDA_COMUNICAZIONE_OFFERTA_RISP_CHECK_PRODUCT] ( @iddoc int , @idPfu int )
as 
begin

	declare @TipoDoc as varchar(100)
	declare @modellobando as varchar(500)
	declare @UpdateEsitoForObblig as varchar(8000)
	declare @Divisione_Lotti varchar(20)
	declare @idBando int


	declare @modello as varchar(500)
	declare @modelloofferta as varchar(500)

	--recupero tipo del documento
	select @TipoDoc= Tipodoc ,@idBando = LinkedDoc from CTL_DOC where id = @iddoc --'ISTANZA_SDA_FARMACI'
	

	
	select @modelloofferta=mod_name
		from ctl_doc_section_model
		where IdHeader=@iddoc and dse_id='OFFERTA'
		
	
	--print @modelloofferta
	exec AFS_DECRYPT_DATI  @idpfu ,  'Document_MicroLotti_Dettagli' , 'PDA_COMUNICAZIONE_OFFERTA_RISP' ,  'idHeader'  ,  @idDoc   ,@modelloofferta  , 'id,idheader,TipoDoc,NumeroLotto,Voce,Variante,CIG,Descrizione,EsitoRiga,idHeaderLotto,NumeroRiga' , ' TipoDoc = ''PDA_COMUNICAZIONE_OFFERTA_RISP'' ' , 1

	

end







GO
