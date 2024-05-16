USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_AGGIORNA_OFFERTA_ALLEGATI]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[OLD2_AGGIORNA_OFFERTA_ALLEGATI] ( @idpda as INT, @id_off_all as INT,@idofferta as INT)
AS
BEGIN	

	

	DECLARE @stato_firma as nvarchar(200)

	--SOLO SE ESISTONO ALLEGATI ALTRIMENTI RIMANE VUOTO
	IF EXISTS ( select * from Document_Offerta_Allegati WITH(NOLOCK)  where IdHeader=@id_off_all )
	BEGIN

		IF EXISTS (select IdRow from Document_Offerta_Allegati WITH(NOLOCK) where IdHeader=@id_off_all and statoFirma = 'SIGN_PENDING' )
		BEGIN
			-- warning per file cone verifica in pending
			set @stato_firma = 'PENDING'
		END
		ELSE IF EXISTS (select * from Document_Offerta_Allegati WITH(NOLOCK)  where IdHeader=@id_off_all and ISNULL(Attach_Signers_CF,'')='')
		BEGIN
			-- X rossa KO - è presente un allegato senza firma
			set @stato_firma='KO'
		END
		ELSE
		BEGIN
			--UN SOLO FIRMATARIO PER TUTTI ALLORA METTO OK
			IF EXISTS ( select  count (distinct(Attach_Signers_CF))
							from Document_Offerta_Allegati WITH(NOLOCK) 
							where Idheader=@id_off_all
							having count (distinct(Attach_Signers_CF)) = 1
					   )
			BEGIN
				set @stato_firma='OK'
			END
			ELSE			
			BEGIN
				
				set @stato_firma='WARNING'
				
				--PROVO A RAGIONARE RECUPERANDO I DISTINTI CF DEI FIRMATARI PRESENTI SUI FILE
				--SE PER UNO DI QUESTI CF TROVO LA FIRMA SU TUTTI I FILE "OK", OVVERO FIRMATARIO COMUNE PER TUTTI GLI ALLEGATI, ALTRIMENTI VIENE FUORI IL WARNING
				declare @Attach_Signers_CF as nvarchar(500)
				declare @num_allegati as INT
				declare @tmp_cont as INT
				
				--CONTO IL NUMERO EFFETTIVO DI ALLEGATI TROVATI
				select @num_allegati=count(distinct Attach_hash)
					from Document_Offerta_Allegati 
					where Idheader=@id_off_all
				
				declare CurUpdate2 Cursor FAST_FORWARD for 
					select distinct  Attach_Signers_CF
						from Document_Offerta_Allegati 
						where Idheader=@id_off_all

				open CurUpdate2
				FETCH NEXT FROM CurUpdate2 INTO @Attach_Signers_CF 
				WHILE @@FETCH_STATUS = 0
				BEGIN
						
					select @tmp_cont=count(Attach_hash)
						from Document_Offerta_Allegati 
						where Idheader=@id_off_all and Attach_Signers_CF=@Attach_Signers_CF
						
					--SE ENTRO IN QUESTO IF SIGNIFICA CHE HO TROVATO UN FIRMATARIO COMUNE A TUTTI GLI N FILE
					IF @tmp_cont = @num_allegati
						set @stato_firma='OK'

					FETCH NEXT FROM CurUpdate2  INTO @Attach_Signers_CF 

				END 
				CLOSE CurUpdate2
				DEALLOCATE CurUpdate2
				
			END
		END

		update Document_PDA_OFFERTE 
				set [Stato_Firma_PDA_AMM] = @stato_firma 
			where IdHeader=@idpda and IdMsg=@idofferta

	END
	

END
GO
