USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CONVENZIONE_PROROGA_CREATE_FROM_NEW]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[CONVENZIONE_PROROGA_CREATE_FROM_NEW] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @Errore as nvarchar(2000)
	declare @DataScadenza as varchar(19)
	declare @DataScadenzaOrdinativo  as varchar(19)
	declare @TipoScadenzaOrdinativo as varchar(50)
	
	
	--controllo che esista almeno un lotto con residuo maggiore di 0
	set @Errore = 'non ci sono lotti con residuo maggiore di 0'
	if exists( select * from Document_Convenzione_Lotti where idheader=@idDoc and isnull(residuo,0) > 0 )
	begin

		set @Errore = ''

		-- cerco una versione precedente del documento 
		set @id = null
		select @id = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'CONVENZIONE_PROROGA' ) and StatoFunzionale= 'InLavorazione'

		if ISNULL(@id,'') = ''
		begin
			   -- altrimenti lo creo
				INSERT into CTL_DOC (
					IdPfu,  TipoDoc, 
					Titolo, Body, ProtocolloRiferimento, LinkedDoc,Destinatario_azi,Destinatario_user,VersioneLinkedDoc
					 )
				select 
					@IdUser as idpfu ,
					 'CONVENZIONE_PROROGA' as TipoDoc ,  
					'Convenzione Proroga' as Titolo,
					 DC.DescrizioneEstesa as Body, 
					protocollo as ProtocolloRiferimento, 
					C.id as LinkedDoc			
					,azi_dest
					,referentefornitore
					,TipoScadenzaOrdinativo
				from CTL_DOC C
					inner join Document_Convenzione DC on C.id = DC.id
				where C.id = @idDoc and C.tipodoc='CONVENZIONE'

				set @id = SCOPE_IDENTITY()

				select	@DataScadenza=convert(varchar(19),Datafine,126),@DataScadenzaOrdinativo=convert(varchar(19),DataScadenzaOrdinativo,126),@TipoScadenzaOrdinativo=TipoScadenzaOrdinativo from document_convenzione where id=	@idDoc	

				--salvo datafine precedente sulla ctl_doc_value
				insert into ctl_doc_value
				(IdHeader, DSE_ID, Row, DZT_Name, Value)
				values
				(@id, 'TESTATA', 0, 'DataFine', @DataScadenza)	
				insert into ctl_doc_value
				(IdHeader, DSE_ID, Row, DZT_Name, Value)
				values
				(@id, 'TESTATA', 0, 'DataFineOrdinativo', @DataScadenzaOrdinativo)	

				insert into ctl_doc_value
				(IdHeader, DSE_ID, Row, DZT_Name, Value)
				values
				(@id, 'TESTATA', 0, 'TipoScadenzaOrdinativo', @TipoScadenzaOrdinativo)	

			
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
