USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_BANDO_CREATE_FROM_ALBO_FORNITORI]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[OLD_BANDO_CREATE_FROM_ALBO_FORNITORI] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @Errore as nvarchar(2000)
	declare @TipoBando varchar(500)
	
	declare @IdPfu as INT
	
		-- genero il record per il nuovo documento
		INSERT into CTL_DOC ( IdPfu,  TipoDoc, Azienda , titolo,Caption,jumpcheck)
			select 
					idpfu ,
					'BANDO',
					pfuidazi as Azienda ,
					'Senza Titolo',
					'Bando Albo Fornitori',
					'BANDO_ALBO_FORNITORI'
				from profiliutente 
				WHERE idpfu = @IdUser

		set @id = @@identity
		
		-- aggiunge il record sul bando			
		select @TipoBando=DZT_ValueDef from LIB_Dictionary where DZT_Name='SYS_VERSIONE_ISTANZA_BANDO_ALBO_FORNITORI'				
		--insert into Document_Bando ( idHeader , TipoBando, ModalitadiPartecipazione , ProceduraGara, TipoBandoGara)
		insert into Document_Bando ( idHeader , TipoBando)
			select 
					@id 
					, ISNULL(@TipoBando,'AlboFornitori')
				from profiliutente 
				WHERE idpfu = @IdUser
		
		--aggiungo riga vuota nella tabella Document_dati_protocollo
		insert into Document_dati_protocollo
		(idHeader)
		values
		(@id)


		-- aggiunge i modelli personalizzati pr gestire le RDO
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
			values( @id , 'COPERTINA' , 'BANDO_COPERTINA_FORNITORI' )
		
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
			values( @id , 'TESTATA_2' , 'BANDO_TESTATA_2_FORNITORI' )
		
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
			values( @id , 'RIFERIMENTI' , 'BANDO_RIFERIMENTI_FORNITORI' )

		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
			values( @id , 'COMMISSIONE' , 'BANDO_COMMISSIONE_FORNITORI' )

		
		
		
		-- rirorna l'id della nuova procedura appena creata
		select @Id as id
	
	
END



GO
