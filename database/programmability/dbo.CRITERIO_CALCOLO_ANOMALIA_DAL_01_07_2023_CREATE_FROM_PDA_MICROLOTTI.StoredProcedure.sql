USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CRITERIO_CALCOLO_ANOMALIA_DAL_01_07_2023_CREATE_FROM_PDA_MICROLOTTI]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE  PROCEDURE [dbo].[CRITERIO_CALCOLO_ANOMALIA_DAL_01_07_2023_CREATE_FROM_PDA_MICROLOTTI] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Errore as nvarchar(2000)

	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @DataScadenza as datetime
	declare @IdPfu as INT

	set @Errore = ''

	if @Errore = '' 
	begin

		-- cerco una versione precedente del documento 
		set @id = null
		select @id = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'CRITERIO_CALCOLO_ANOMALIA_DAL_01_07_2023' ) and JumpCheck='PDA_MICROLOTTI'

		if @id is null
		begin
			   -- altrimenti lo creo
				INSERT into CTL_DOC (
					IdPfu,  TipoDoc, 
					Titolo,  
					LinkedDoc,
					JumpCheck
					 )
					select 
							@IdUser as idpfu , 'CRITERIO_CALCOLO_ANOMALIA_DAL_01_07_2023' as TipoDoc ,  
							'Criterio Calcolo Anomalia' as Titolo,  
							 d.id as LinkedDoc,d.TipoDoc
									
						from CTL_DOC d
						where d.id = @idDoc

				set @id = SCOPE_IDENTITY()

				INSERT INTO [dbo].[CTL_DOC_Value]
						   ([IdHeader]
						   ,[DSE_ID]
						   ,[Row]
						   ,[DZT_Name]
						   ,[Value])
					 VALUES
						   (@idDoc
						   ,'CRITERI' 
						   ,0
						   ,'check_criterio_a'
						   ,'')

				INSERT INTO [dbo].[CTL_DOC_Value]
						   ([IdHeader]
						   ,[DSE_ID]
						   ,[Row]
						   ,[DZT_Name]
						   ,[Value])
					 VALUES
						   (@idDoc
						   ,'CRITERI' 
						   ,0
						   ,'check_criterio_b'
						   ,'')


		end
	end

	IF NOT EXISTS ( select * from CTL_DOC_SECTION_MODEL md with(nolock) where md.IdHeader = @id and md.DSE_ID = 'CRITERI' )
	BEGIN
		
		--Nella creazione del documento CRITERIO_CALCOLO_ANOMALIA  settiamo il modello da utilizzare sulla sezione 
		--se la gara è stata inviata a partire dal 01-07-2023 con il modello "CRITERIO_CALCOLO_ANOMALIA_CRITERI_DAL_01_07_2023"
		insert into CTL_DOC_SECTION_MODEL( IdHeader, dse_id, MOD_Name )
			select @id, 'CRITERI', 'CRITERIO_CALCOLO_ANOMALIA_CRITERI_DAL_01_07_2023'
				from ctl_doc pda with(nolock)
						inner join ctl_doc gara with(nolock) on gara.id = pda.LinkedDoc
				WHERE pda.id = @idDoc and isnull(pda.JumpCheck,'') <> '' and gara.DataInvio >= '2023-07-01'

	END

			
	if @Errore = ''
	begin
		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
END













GO
