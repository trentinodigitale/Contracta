USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CONVENZIONE_UPD_ENTI_CREATE_FROM_CONVENZIONE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[CONVENZIONE_UPD_ENTI_CREATE_FROM_CONVENZIONE] 
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

		-- cerco una versione precedente del documento in carico all'utente collegato
		set @id = null
		select @id = id 
			from CTL_DOC with (nolock)
			where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'CONVENZIONE_UPD_ENTI' ) and StatoFunzionale= 'InLavorazione'
					and ( ISNULL(idPfuInCharge,'') = '' or idPfuInCharge=@IdUser )

		if ISNULL(@id,'') = ''
		begin
			   -- altrimenti lo creo
				INSERT into CTL_DOC (
					IdPfu,  TipoDoc, 
					Titolo, Body, ProtocolloRiferimento, LinkedDoc,Destinatario_azi,Destinatario_user,idPfuInCharge
					 )
					select 
						@IdUser as idpfu ,
						 'CONVENZIONE_UPD_ENTI' as TipoDoc ,  
						'Modifica Enti Convenzione' as Titolo,
						 DC.DescrizioneEstesa as Body, 
						protocollo as ProtocolloRiferimento, 
						C.id as LinkedDoc			
						,azi_dest
						,referentefornitore
						,@IdUser
					from CTL_DOC C with (nolock)
							inner join Document_Convenzione DC with (nolock) on C.id = DC.id
					where C.id = @idDoc and C.tipodoc='CONVENZIONE'

				set @id = SCOPE_IDENTITY()

				--riporto gli enti nel nuovo documento
				insert into Document_Convenzione_Plant
					(idHeader, azi_ente, plant )
					select @id as idheader, azi_ente , plant 
						from 
							Document_Convenzione_Plant  with (nolock)
						where idheader = @idDoc order by idRow 
				
				--riporto gli enti nello storico del documento
				insert into ctl_doc_value
					(idHeader,row, dse_id,dzt_name,value)
					select 
						@id as idheader, ROW_NUMBER() OVER(ORDER BY idrow ASC) -1  AS row , 'STORICO_PLANT' as dse_id , 'AZI_ENTE' as dzt_name,  azi_ente as value
						from 
							Document_Convenzione_Plant  with (nolock)
						where idheader = @idDoc  
				
				insert into ctl_doc_value
					(idHeader,row, dse_id,dzt_name,value)
					select 
						@id as idheader, ROW_NUMBER() OVER(ORDER BY idrow ASC) -1  AS row , 'STORICO_PLANT' as dse_id , 'Plant' as dzt_name,  plant as value
						from 
							Document_Convenzione_Plant  with (nolock)
						where idheader = @idDoc  

		end
	end

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
