USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CK_ARTICOLI_ODC_SUBORDINATI]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE 
[dbo].[OLD2_CK_ARTICOLI_ODC_SUBORDINATI]( @IdDoc int, @Errore as varchar(100) output)
	
AS
BEGIN
	declare @subordinato as varchar(50)
	declare @articoliprimari as nvarchar(1000)
	declare @IdConvenzione as int
	declare @ente as int
	

	SET NOCOUNT ON
	
	--recupero subordinato per tuttigli articoli
	

	DECLARE crsArticoliODC CURSOR STATIC FOR 
		
		select isnull(subordinato,'no'),isnull(articoliprimari,'') from document_microlotti_dettagli where idheader=@IdDoc
		
	OPEN crsArticoliODC

	FETCH NEXT FROM crsArticoliODC INTO @subordinato,@articoliprimari
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		if @subordinato='ordinativo'
		begin
			--controllo che ci sia almeno un primario nell'odc
			if not exists (select * from document_microlotti_dettagli where idheader=@IdDoc and charindex('###' + codice_regionale + '###' ,@articoliprimari)>0	)
			begin
				set @Errore='ci sono articoli subordinati senza primari presenti in odc corrente'
				goto USCITA
			end	
		end
		
		if @subordinato='convenzione'
		begin
			--controllo che ci sia almeno un primario sugli odc della convenzione
			--recupero id convenzione
			select @IdConvenzione=Id_Convenzione from document_odc where rda_id=@IdDoc	
			--recupero ente dell'ODC
			select @ente=azienda from ctl_doc where id=@IdDoc
			
			if not exists (select * from 
							document_microlotti_dettagli d
								inner join ctl_doc c on d.idheader=c.id  and c.tipodoc='ODC' and c.tipodoc=d.tipodoc and azienda=@ente and ( statofunzionale='Accettato' or idheader=@IdDoc )
						   where idheader 
									in (select rda_id from document_odc where id_convenzione=@IdConvenzione) 
							and charindex('###' + codice_regionale + '###' ,@articoliprimari)>0 )	
			begin
				set @Errore='ci sono articoli subordinati senza primari presenti su odc della convenzione'
				goto USCITA
			end	

		end		

		FETCH NEXT FROM crsArticoliODC INTO @subordinato,@articoliprimari
	END

USCITA:

	CLOSE crsArticoliODC 
	DEALLOCATE crsArticoliODC 	

	

SET NOCOUNT OFF
END



GO
