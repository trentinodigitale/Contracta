USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CONVENZIONE_DECURTAZIONE_CREATE_FROM_NEW]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[CONVENZIONE_DECURTAZIONE_CREATE_FROM_NEW] 
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
		select @id = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'CONVENZIONE_DECURTAZIONE' ) and StatoFunzionale= 'InLavorazione'

		if ISNULL(@id,'') = ''
		begin
			   -- altrimenti lo creo
				INSERT into CTL_DOC (
					IdPfu,  TipoDoc, 
					Titolo, Body, ProtocolloRiferimento, LinkedDoc,Destinatario_azi,Destinatario_user
					 )
				select 
					@IdUser as idpfu ,
					 'CONVENZIONE_DECURTAZIONE' as TipoDoc ,  
					'Convenzione Decurtazione' as Titolo,
					 DC.DescrizioneEstesa as Body, 
					protocollo as ProtocolloRiferimento, 
					C.id as LinkedDoc			
					,azi_dest
					,referentefornitore
				from CTL_DOC C
					inner join Document_Convenzione DC on C.id = DC.id
				where C.id = @idDoc and C.tipodoc='CONVENZIONE'

				set @id = @@identity

				Insert into Document_Convenzione_Azioni (IdHeader,Vaue_Originario,Total)
				select @id,Total,Total
				from Document_Convenzione where id=@idDoc

				
				Insert into Document_Convenzione_Lotti ( idHeader, Seleziona, StatoLottoConvenzione, NumeroLotto, Descrizione, Importo, Impegnato, Estensione, Finale, Residuo )
				select   @id, 'escludi', StatoLottoConvenzione, NumeroLotto, Descrizione, Importo, Impegnato, Estensione, Finale, Residuo 
				from Document_Convenzione_Lotti
				where idheader=@idDoc order by idrow

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
