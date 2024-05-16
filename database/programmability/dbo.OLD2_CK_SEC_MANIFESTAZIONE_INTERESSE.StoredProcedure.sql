USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CK_SEC_MANIFESTAZIONE_INTERESSE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[OLD2_CK_SEC_MANIFESTAZIONE_INTERESSE] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin
	

	--inserita perchè non restituiva record se faceva una insert
	SET NOCOUNT ON

	DECLARE @tipoDocumento varchar(1000)
	DECLARE @dataScadenza datetime
	declare @Blocco nvarchar(1000)
	declare @Allegato nvarchar(4000)
	declare @idpfu int

	set @Blocco = ''

	select @tipoDocumento = o.tipodoc,
		   @datascadenza = b.DataScadenzaOfferta,
		   @idpfu = o.idpfu
		from ctl_doc o with(nolock)
				inner join Document_Bando b with(nolock) on o.LinkedDoc = b.idheader
		where id = @IdDoc
	
	IF @IdUser  = @idPfu
	BEGIN

		set @Blocco = ''

	END
	ELSE
	BEGIN

		--IF getdate() < @datascadenza
		--BEGIN
		--	set @Blocco = 'Data presentazione Manifestazioni di interesse non superata'
		--END
		--ELSE
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

	select @Blocco as Blocco 

END





GO
