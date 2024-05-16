USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BANDO_CREATE_FROM_ALBO_ME]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[BANDO_CREATE_FROM_ALBO_ME] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @Errore as nvarchar(2000)
	declare @TipoBando varchar(500)

	
	declare @IdPfu as INT
	
		-- genero il record per il nuovo documento
		INSERT into CTL_DOC ( IdPfu,  TipoDoc, Azienda , titolo)
			select 
					idpfu ,
					'BANDO',
					pfuidazi as Azienda ,
					'Senza Titolo'
				from profiliutente 
				WHERE idpfu = @IdUser

		set @id = @@identity
		
		-- aggiunge il record sul bando				
		select @TipoBando=DZT_ValueDef from LIB_Dictionary where DZT_Name='SYS_VERSIONE_ISTANZA_BANDO_ME'

		insert into Document_Bando ( idHeader , TipoBando)
			select 
					@id 
					, ISNULL(@TipoBando,'AlboOperaEco')
				
		
		--aggiungo riga vuota nella tabella Document_dati_protocollo
		insert into Document_dati_protocollo
		(idHeader)
		values
		(@id)
		
		-- rirorna l'id della nuova procedura appena creata
		select @Id as id
	
	
END




GO
