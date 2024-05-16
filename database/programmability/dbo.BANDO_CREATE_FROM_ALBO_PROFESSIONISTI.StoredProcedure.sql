USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BANDO_CREATE_FROM_ALBO_PROFESSIONISTI]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[BANDO_CREATE_FROM_ALBO_PROFESSIONISTI] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @Errore as nvarchar(2000)
	declare @TipoBando varchar(500)
	
	declare @IdPfu as INT
	declare @LNG varchar(10)
	
	select @LNG=lngSuffisso from Lingue where idlng=(select pfuIdLng from Profiliutente where idpfu=@IdUser)

	
		-- genero il record per il nuovo documento, cancellato logicamente per evitare che sia visibile se non finalizza le operazioni	
		INSERT into CTL_DOC ( IdPfu,  TipoDoc, Azienda , titolo,Caption,jumpcheck)
			select 
					idpfu ,
					'BANDO',
					pfuidazi as Azienda ,
					'Senza Titolo',
					'Bando Albo ' + dbo.CNV(dv.DMV_DescML,@LNG),
					'BANDO_ALBO_PROFESSIONISTI'
				from profiliutente 
					left join LIB_DomainValues dv with(NOLOCK) on dv.DMV_DM_ID='tipo_albo' and dv.DMV_Deleted=0 and dv.DMV_Cod='BANDO_ALBO_PROFESSIONISTI'
				WHERE idpfu = @IdUser

		set @id = @@identity
		
		-- aggiunge il record sul bando	
		select @TipoBando=DZT_ValueDef from LIB_Dictionary where DZT_Name='SYS_VERSIONE_ISTANZA_BANDO_ALBO_PROFESSIONISTI'			
		--insert into Document_Bando ( idHeader , TipoBando, ModalitadiPartecipazione , ProceduraGara, TipoBandoGara)
		insert into Document_Bando ( idHeader , TipoBando)
			select 
					@id 
					, ISNULL(@TipoBando,'AlboProf')
				from profiliutente 
				WHERE idpfu = @IdUser
		
		--aggiungo riga vuota nella tabella Document_dati_protocollo
		insert into Document_dati_protocollo
		(idHeader)
		values
		(@id)

		
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
			values( @id , 'COPERTINA' , 'BANDO_COPERTINA_PROF' )
		
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
			values( @id , 'TESTATA_2' , 'BANDO_TESTATA_2_PROF' )
		
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
			values( @id , 'RIFERIMENTI' , 'BANDO_RIFERIMENTI_PROF' )

		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
			values( @id , 'COMMISSIONE' , 'BANDO_COMMISSIONE_PROF' )	
		
	
		select @Id as id
	
	
END





GO
