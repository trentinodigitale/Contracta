USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GESTIONE_DOMINIO_CREATE_FROM_NEW]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [dbo].[GESTIONE_DOMINIO_CREATE_FROM_NEW] 
	( @idDoc int  , @idUser int )
AS
BEGIN

	--@iddoc=1 = ClasseIscriz
	--@iddoc=2 = GerarchicoSOA
	--@iddoc=3 = Quotidiani
	BEGIN TRAN

	SET NOCOUNT ON	-- set nocount ON è importantissimo

	DECLARE @newId INT
	DECLARE @jumpcheck as varchar(100)
	DECLARE @Caption as varchar(255)
	set @newId = -1
	
	IF @iddoc = 1
	BEGIN
		SET @jumpcheck='ClasseIscriz'
		set @Caption='Gestione Dominio - Classe di iscrizione'
	END

	IF @iddoc = 2
	BEGIN
		SET @jumpcheck='GerarchicoSOA'
		set @Caption='Gestione Dominio - Gerarchico SOA'
	END

	
	IF @iddoc = 3
	BEGIN
		SET @jumpcheck='Quotidiani'
		set @Caption='Gestione Dominio - Quotidiani'
	END

	IF @iddoc = 4
	BEGIN
		SET @jumpcheck='TipologiaIncarico'
		set @Caption='Gestione Dominio - Attivita Professionale'
	END

	IF @iddoc = 5
	BEGIN
		SET @jumpcheck='A_ATC'
		set @Caption='Gestione Dominio - ATC'
	END

	IF @iddoc = 6
	BEGIN
		SET @jumpcheck='A_PRINCIPIO_ATTIVO'
		set @Caption='Gestione Dominio - Principio Attivo'
	END

	IF @iddoc = 7
	BEGIN
		SET @jumpcheck='A_VIA_DI_SOMMINISTRAZIONE'
		set @Caption='Gestione Dominio - Via di Somministrazione'
	END

	IF @iddoc = 8
	BEGIN
		SET @jumpcheck='A_FORMA_FARMACEUTICA'
		set @Caption='Gestione Dominio - Forma Farmaceutica'
	END

	IF @iddoc = 9
	BEGIN
		SET @jumpcheck='A_CND'
		set @Caption='Gestione Dominio - CND'
	END

	IF @iddoc = 10
	BEGIN
		SET @jumpcheck='MOD_CONSERVAZ_DOM'
		set @Caption='Gestione Dominio - MOD_CONSERVAZ'
	END
	
	--CERCO il documento precedente in lavorazione creato dall'utente.
	select @newId=id from ctl_doc with(nolock) where idpfu=@idUser and  TipoDoc='GESTIONE_DOMINIO' and JumpCheck=@jumpcheck and StatoFunzionale='InLavorazione' and Deleted=0

	if @newId = -1
	BEGIN
		insert into CTL_DOC ( idpfu, TipoDoc, StatoDoc, Data,Caption ,JumpCheck,Titolo,PrevDoc)
			select @idUser,'GESTIONE_DOMINIO','Saved',GETDATE(),@Caption,@jumpcheck,@Caption,0
		
		set @newId=SCOPE_IDENTITY()


		--POPOLIAMO Elenco Valori del Dominio con quello in essere, sfruttando la select del dominio
		IF @iddoc = 1
		BEGIN
			insert into CTL_DomainValues ( [idHeader], [DMV_DM_ID], [DMV_LNG], [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Deleted])
				select 
						@newId,'DOMINIO', 'I',  [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Deleted]
					from 
						ClasseIscriz
					where 1 = 1 
					order by [DMV_Father]
		END

		IF @iddoc = 2
		BEGIN
			insert into CTL_DomainValues ( [idHeader], [DMV_DM_ID], [DMV_LNG], [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Deleted])
				select 
						@newId,'DOMINIO', 'I',  [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Deleted]
					from 
						GerarchicoSOA 
					where 1 = 1 
					order by [DMV_Father] 
		END

		IF @iddoc = 3
		BEGIN
			insert into CTL_DomainValues ( [idHeader], [DMV_DM_ID], [DMV_LNG], [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Deleted])
				select 
						@newId,'DOMINIO', 'I',  [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Deleted]
					from 
						Quotidiani 
					where 1 = 1 
					order by [DMV_Father] 
		END

		IF @iddoc = 4
		BEGIN
			insert into CTL_DomainValues ( [idHeader], [DMV_DM_ID], [DMV_LNG], [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Deleted])
				select 
						@newId,'DOMINIO', 'I',  [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Deleted]
					from 
						GESTIONE_DOMINIO_TipologiaIncarico 
					where 1 = 1 
					order by [DMV_Father] 
		END


		IF @iddoc = 5
		BEGIN
			insert into CTL_DomainValues ( [idHeader], [DMV_DM_ID], [DMV_LNG], [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Deleted])
				select 
						@newId,'DOMINIO', 'I',  [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Deleted]
					from 
						GESTIONE_DOMINIO_A_ATC
					where 1 = 1 
					order by [DMV_Father] 
		END

		IF @iddoc = 6
		BEGIN
			insert into CTL_DomainValues ( [idHeader], [DMV_DM_ID], [DMV_LNG], [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Deleted])
				select 
						@newId,'DOMINIO', 'I',  [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Deleted]
					from 
						GESTIONE_DOMINIO_A_PRINCIPIO_ATTIVO
					where 1 = 1 
					order by [DMV_Father] 
		END

		IF @iddoc = 7
		BEGIN
			insert into CTL_DomainValues ( [idHeader], [DMV_DM_ID], [DMV_LNG], [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Deleted])
				select 
						@newId,'DOMINIO', 'I',  [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Deleted]
					from 
						GESTIONE_DOMINIO_A_VIA_DI_SOMMINISTRAZIONE
					where 1 = 1 
					order by [DMV_Father] 
		END

		IF @iddoc = 8
		BEGIN
			insert into CTL_DomainValues ( [idHeader], [DMV_DM_ID], [DMV_LNG], [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Deleted])
				select 
						@newId,'DOMINIO', 'I',  [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Deleted]
					from 
						GESTIONE_DOMINIO_A_FORMA_FARMACEUTICA
					where 1 = 1 
					order by [DMV_Father] 
		END

		IF @iddoc = 9
		BEGIN
			insert into CTL_DomainValues ( [idHeader], [DMV_DM_ID], [DMV_LNG], [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Deleted])
				select 
						@newId,'DOMINIO', 'I',  [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Deleted]
					from 
						GESTIONE_DOMINIO_A_CND
					where 1 = 1 
					order by [DMV_Father] 
		END




	END


	IF @@ERROR <> 0 
	BEGIN
		raiserror ('Errore creazione record in ctl_doc.  ', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
		rollback tran
		return 99
	END

	COMMIT TRAN

	-- rirorna l'id del documento appena creato
	select @newId as id

	return 

END




GO
