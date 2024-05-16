USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[INVIO_CONTRATTO_CONVENZIONE]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[INVIO_CONTRATTO_CONVENZIONE] ( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;
		declare @id int
		declare @azienda_mit int

		select @azienda_mit=pfuidazi from ProfiliUtente where idpfu=@IdUser
		

		--controllo se esiste un documento già per la convenzione in questione
		select @id=id from ctl_doc where linkedDoC=@idDoc and Tipodoc='CONTRATTO_CONVENZIONE' and StatoFunzionale in ('InLavorazione','Inviato','Confermato') and deleted = 0

		--se non esiste un documento già in atto allora crea il nuovo
		if ISNULL(@id,'0') = 0
		BEGIN
			
			Insert into ctl_doc (Titolo,TipoDoc,linkedDoc,Idpfu,Azienda,Destinatario_azi,Destinatario_user,Body,idpfuincharge,JumpCheck)
				select 'Contratto Convenzione','CONTRATTO_CONVENZIONE',@idDoc,@IdUser,@azienda_mit,AZI_Dest,ReferenteFornitore,DOC_Name,ReferenteFornitore,'RICHIESTA-FIRMA:'+ RichiestaFirma
					from Document_Convenzione 
				where id=@idDoc
			
			set @Id = scope_identity()

			--ricopio le info del contratto
			Insert into Document_Convenzione (id,TipoEstensione,NumOrd,DataInizio,DataFine,Valuta,Total,IVA,
											TipoImporto,RicPreventivo,TotaleOrdinato,QtMinTot,
											RichiediFirmaOrdine,DOC_Name,TipoOrdine,Ambito,Merceologia,
											DescrizioneEstesa,GestioneQuote)
				Select @Id,TipoEstensione,NumOrd,DataInizio,
						DataFine,Valuta,Total,IVA,TipoImporto,RicPreventivo,
						TotaleOrdinato,QtMinTot,RichiediFirmaOrdine,Titolo,TipoOrdine,
						Ambito,Merceologia,DescrizioneEstesa,GestioneQuote
					from Document_Convenzione 
						inner join ctl_doc on ctl_doc.id=Document_Convenzione.id and ctl_doc.tipodoc='CONVENZIONE'
					where Document_Convenzione.id=@idDoc
			
			IF EXISTS (Select * from CTL_DOC where id=@Id and JumpCheck='RICHIESTA-FIRMA:no')
			BEGIN
				--inserisci i doc firmati
				insert into CTL_DOC_SIGN ( [idHeader] , [F4_SIGN_HASH] ,[F1_SIGN_HASH] , [F1_SIGN_ATTACH] , [F2_SIGN_HASH]  , [F3_SIGN_HASH] , [F2_SIGN_ATTACH] )
					select @Id, [F1_SIGN_HASH] ,[F1_SIGN_HASH] , [F1_SIGN_ATTACH] , [F2_SIGN_HASH] , [F2_SIGN_HASH] , [F2_SIGN_ATTACH]
						from CTL_DOC_SIGN 
						where [idHeader]=@idDoc
			END
			ELSE
			BEGIN
				--inserisci i doc firmati
				insert into CTL_DOC_SIGN ( [idHeader] , [F4_SIGN_HASH] ,[F1_SIGN_HASH] , [F1_SIGN_ATTACH] , [F2_SIGN_HASH]  , [F3_SIGN_HASH] , [F2_SIGN_ATTACH] )
					select @Id, [F1_SIGN_HASH] ,[F1_SIGN_HASH] , [F1_SIGN_ATTACH] , [F2_SIGN_HASH] , [F2_SIGN_HASH] , [F2_SIGN_ATTACH]
						from CTL_DOC_SIGN 
						where [idHeader]=@idDoc
			END

			--chiamo la stored che gestisce i campi not editable sulla convenzione
			exec CAMPI_NOT_EDITABLE_CONVENZIONE @id , @IdUser
			
			--metto un modello dinamico se non richiedo la firma degli allegati
			IF EXISTS (Select * from CTL_DOC where id=@Id and JumpCheck='RICHIESTA-FIRMA:no')
			BEGIN
				Insert into CTL_DOC_SECTION_MODEL ( IdHeader,DSE_ID,MOD_Name)
					Values (@Id,'FIRMA','CONTRATTO_CONVENZIONE_NO_FIRMA')
			END

	

		END


END

GO
