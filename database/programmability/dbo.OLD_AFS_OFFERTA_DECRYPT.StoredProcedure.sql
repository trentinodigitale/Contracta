USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_AFS_OFFERTA_DECRYPT]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE  procedure [dbo].[OLD_AFS_OFFERTA_DECRYPT]( @iddoc int , @idPfu int )
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

	--recupero tipo del documento
	select @TipoDoc= Tipodoc ,@idBando = LinkedDoc from CTL_DOC where id = @iddoc --'ISTANZA_SDA_FARMACI'
	
	--recupero modello selezionato
	select @modellobando = b.TipoBando , @Divisione_Lotti = Divisione_Lotti 
		from Document_Bando b 
			   inner join CTL_DOC d on b.idHeader = d.LinkedDoc
		where d.id = @iddoc


	if @TipoDoc = 'OFFERTA'
	begin
		set @modelloofferta = 'MODELLI_LOTTI_' + @modellobando + '_MOD_OffertaINPUT'
		--print @modelloofferta
		exec AFS_DECRYPT_DATI  @idpfu ,  'Document_MicroLotti_Dettagli' , 'BUSTA_ECONOMICA' ,  'idHeader'  ,  @idDoc   ,@modelloofferta  , 'id,idheader,TipoDoc,NumeroLotto,Voce,Variante,CIG,Descrizione,EsitoRiga,NumeroRiga' , ' TipoDoc = ''OFFERTA'' ' , 0 

		exec AFS_DECRYPT_DATI  @idpfu ,  'CTL_DOC_Value' , 'BUSTA_ECONOMICA' ,  'idHeader'  ,  @idDoc   ,'OFFERTA_TESTATA_TOTALI'  ,  'IdRow,IdHeader,DSE_ID,Row,DZT_Name' ,  ' DSE_ID = ''TOTALI'' '  , 0 
		--exec AFS_CRYPT_DATI 'CTL_DOC_Value' ,  'idHeader'  ,  @idDoc   ,'OFFERTA_TESTATA_TOTALI'  , 'IdRow,IdHeader,DSE_ID,Row,DZT_Name' , ' DSE_ID = ''TOTALI'' ' 
	end
--	else
--		set @modelloofferta = 'MODELLI_LOTTI_' + @modellobando + '_MOD_OffertaInd'

	if @TipoDoc = 'OFFERTA_AMPIEZZA_DI_GAMMA'
	begin 
		select @modelloofferta = Value
		from CTL_DOC 
			inner join CTL_DOC_Value on id = IdHeader and DSE_ID = 'MODELLI' and DZT_Name = 'ModelloAmpiezzaDamma'
		where Id = @idDoc

		exec AFS_DECRYPT_DATI  @idpfu ,  'Document_MicroLotti_Dettagli' , 'PRODOTTI' ,  'idHeader'  ,  @idDoc   ,@modelloofferta  , 'id,idheader,TipoDoc,NumeroLotto,Voce,Variante,CIG,Descrizione,EsitoRiga,NumeroRiga' , '' , 0 
	end


end





GO
