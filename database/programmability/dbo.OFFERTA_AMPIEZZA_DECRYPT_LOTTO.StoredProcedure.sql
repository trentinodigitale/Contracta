USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OFFERTA_AMPIEZZA_DECRYPT_LOTTO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE  procedure [dbo].[OFFERTA_AMPIEZZA_DECRYPT_LOTTO]( @iddoc int , @idPfu int , @Numerolotto varchar(10) )
as 
begin

	declare @TipoDoc as varchar(100)
	declare @modellobando as varchar(500)
	declare @UpdateEsitoForObblig as varchar(8000)
	declare @Divisione_Lotti varchar(20)
	declare @idBando int
	declare @idOfferta int
	declare @idmodAcquisto as int 
	declare @idModAmpGamma as Int


	declare @modello as varchar(500)
	declare @modelloofferta as varchar(500)



	
	select @modelloofferta = Value
		from CTL_DOC 
			inner join CTL_DOC_Value on id = IdHeader and DSE_ID = 'MODELLI' and DZT_Name = 'ModelloAmpiezzaDamma'
		where Id = @idDoc

	exec AFS_DECRYPT_DATI  @idpfu ,  'Document_MicroLotti_Dettagli' , 'PRODOTTI_AMPIEZZA_GAMMA' ,  'idHeader'  ,  @idDoc   ,@modelloofferta  , 'id,idheader,TipoDoc,NumeroLotto,Voce,Variante,CIG,Descrizione,EsitoRiga,NumeroRiga,idHeaderLotto' , ' TipoDoc = ''OFFERTA_AMPIEZZA'' ' , 0 
	


end





GO
