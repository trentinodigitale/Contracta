USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[AFS_OFFERTA_CRYPT]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[AFS_OFFERTA_CRYPT]( @iddoc int , @idPfu int )
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
	
	--recupero modello selezionato
	select @modellobando = b.TipoBando , @Divisione_Lotti = Divisione_Lotti 
		from Document_Bando b 
			   inner join CTL_DOC d on b.idHeader = d.LinkedDoc
		where d.id = @iddoc


	if @TipoDoc = 'OFFERTA'
	begin
		set @modelloofferta = 'MODELLI_LOTTI_' + @modellobando + '_MOD_OffertaINPUT'
		
		exec AFS_CRYPT_DATI 'Document_MicroLotti_Dettagli' ,  'idHeader'  ,  @idDoc   ,@modelloofferta  , 'id,idheader,TipoDoc,NumeroLotto,Voce,Variante,CIG,Descrizione,EsitoRiga,NumeroRiga,idHeaderLotto' , ' TipoDoc = ''OFFERTA'' ' 

		exec AFS_CRYPT_DATI 'CTL_DOC_Value' ,  'idHeader'  ,  @idDoc   ,'OFFERTA_TESTATA_TOTALI'  , 'IdRow,IdHeader,DSE_ID,Row,DZT_Name' , ' DSE_ID = ''TOTALI'' ' 

		-- se è attivo il modulo ampiezza di gamma e se l'offerta contiene i dati dell'ampiezza di gamma
		IF  EXISTS (select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI' and ',' + DZT_ValueDef + ',' like '%,AMPIEZZA_DI_GAMMA,%')
		begin
			IF  EXISTS (select top 1 id from Document_MicroLotti_Dettagli with(nolock) where IdHeader =@iddoc and TipoDoc='OFFERTA_AMPIEZZA' )
			begin
				select @modelloofferta = Value
					from CTL_DOC 
						inner join CTL_DOC_Value on id = IdHeader and DSE_ID = 'MODELLI' and DZT_Name = 'ModelloAmpiezzaDamma'
					where Id = @idDoc

				
				exec AFS_CRYPT_DATI 'Document_MicroLotti_Dettagli' ,  'idHeader'  ,  @idDoc   ,@modelloofferta  , 'id,idheader,TipoDoc,NumeroLotto,Voce,Variante,CIG,Descrizione,EsitoRiga,NumeroRiga,idHeaderLotto' , ' TipoDoc = ''OFFERTA_AMPIEZZA'' ' 
			end
		end



	end
--	else
--		set @modelloofferta = 'MODELLI_LOTTI_' + @modellobando + '_MOD_OffertaInd'
	
	if @TipoDoc = 'OFFERTA_AMPIEZZA_DI_GAMMA'
	begin 
		select @modelloofferta = Value
		from CTL_DOC 
			inner join CTL_DOC_Value on id = IdHeader and DSE_ID = 'MODELLI' and DZT_Name = 'ModelloAmpiezzaDamma'
		where Id = @idDoc

		exec AFS_CRYPT_DATI 'Document_MicroLotti_Dettagli' ,  'idHeader'  ,  @idDoc   ,@modelloofferta  , 'id,idheader,TipoDoc,NumeroLotto,Voce,Variante,CIG,Descrizione,EsitoRiga,NumeroRiga' , ' TipoDoc = ''OFFERTA_AMPIEZZA_DI_GAMMA'' ' 
	end


end



GO
