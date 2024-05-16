USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_SEC_MANIFESTAZIONE_INTERESSE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[CK_SEC_MANIFESTAZIONE_INTERESSE] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin
	

	--inserita perchè non restituiva record se faceva una insert
	SET NOCOUNT ON

	DECLARE @tipoDocumento varchar(1000)
	DECLARE @dataScadenza datetime
	declare @Blocco nvarchar(1000)
	declare @Allegato nvarchar(4000)
	declare @idpfu int
	DECLARE @RichiediDocumentazione VARCHAR(10) 
	declare @proceduraGara varchar(50)
	declare @tipoBandoGara varchar(50)
	declare @idGara varchar(50)
	declare @azienda varchar(50)
	declare @aziendadest as int

	set @Blocco = ''

	select @tipoDocumento = o.tipodoc,
		   @datascadenza = b.DataScadenzaOfferta,
		   @idpfu = o.idpfu, 
		   @RichiediDocumentazione = RichiediDocumentazione,
		   @proceduraGara = b.ProceduraGara,
		   @tipoBandoGara = b.TipoBandoGara,
		   @idGara = o.LinkedDoc,
		   @azienda = o.Azienda,
		   @aziendadest = o.Destinatario_Azi
		from ctl_doc o with(nolock)
				inner join Document_Bando b with(nolock) on o.LinkedDoc = b.idheader				
		where id = @IdDoc
	

	-- LA BUSTA DI DOCUMENTAZIONE è VISUALIZZATA SOLAMENTE SE RICHIESTA SUL BANDO
	IF @SectionName in ( 'DOCUMENTAZIONE', 'BUSTA_DOCUMENTAZIONE' ) AND ISNULL( @RichiediDocumentazione , '1' ) <> '1'
	BEGIN

		set @Blocco = 'NON_VISIBILE'

	END
	ELSE
	BEGIN
	
		IF @IdUser  = @idPfu 
			BEGIN

				set @Blocco = ''

			END
		ELSE
			BEGIN

				IF getdate() < @datascadenza and @proceduraGara = '15583' and @tipoBandoGara in ('4','5') --affidamento diretto avviso/destinatari
					BEGIN
						set @Blocco = 'Data presentazione Manifestazioni di interesse non superata'
					END
				ELSE
					BEGIN

						IF @SectionName in ( 'DOCUMENTAZIONE', 'BUSTA_DOCUMENTAZIONE' )
						BEGIN

							exec AFS_DECRYPT_DATI  @IdUser ,  'CTL_DOC_ALLEGATI' , 'DOCUMENTAZIONE' ,  'idHeader'  ,  @IdDoc   ,'OFFERTA_ALLEGATI'  , 'idRow,idHeader,Descrizione' , '' , 1 

							DECLARE curs CURSOR STATIC FOR     
								select Allegato
									from CTL_DOC_ALLEGATI with(nolock)
									where idheader = @IdDoc and isnull(Allegato ,'') <> ''


							OPEN curs
							FETCH NEXT FROM curs INTO @Allegato

							WHILE @@FETCH_STATUS = 0   
							BEGIN  

								exec AFS_DECRYPT_ATTACH  @IdUser ,   @Allegato , @IdDoc
								FETCH NEXT FROM curs INTO @Allegato

							END  

							CLOSE curs   
							DEALLOCATE curs

						END

					END

			END

	END

	--se @Blocco = '' e sono l'utente dell'azienda destinatario e ci troviamo su affidamento diretto avviso/destinatari update su ctl_doc_destinatari e settare la colonna statoiscrizione = valutato
	if @Blocco = '' and  exists ( select idpfu from ProfiliUtente with(nolock) where pfuIdAzi = @aziendadest and IdPfu = @IdUser) and @proceduraGara = '15583' and @tipoBandoGara in ('4','5') 
		BEGIN 
			update ctl_doc_destinatari set StatoIscrizione = 'Valutato' where idHeader = @idGara and IdAzi = @azienda and (StatoIscrizione not in ('Selezionato') or StatoIscrizione is null)
		END	

	select @Blocco as Blocco 

END


GO
