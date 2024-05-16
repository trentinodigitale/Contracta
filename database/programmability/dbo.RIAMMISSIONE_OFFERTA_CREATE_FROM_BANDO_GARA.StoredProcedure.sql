USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RIAMMISSIONE_OFFERTA_CREATE_FROM_BANDO_GARA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  proc [dbo].[RIAMMISSIONE_OFFERTA_CREATE_FROM_BANDO_GARA] ( @idbando as int, @idPfu as int) 
as
BEGIN
	SET NOCOUNT ON;

	declare @Errore as nvarchar(2000)	
	declare @id as INT

	set @Errore=''

	
	IF NOT EXISTS ( Select * from [Document_Bando_Semplificato_view] where id=@idbando and ( UserRUP=@idPfu or pres_com_A=@idPfu ) )
	BEGIN
		set @Errore='Solo il RUP oppure il presidente del seggio di gara possono creare il documento'
	END

	select @Id=id from ctl_doc where LinkedDoc=@idbando and TipoDoc='RIAMMISSIONE_OFFERTA' and StatoFunzionale = 'InLavorazione' and Deleted=0
	
	if @Errore='' and @id is null
	BEGIN		
			
			insert into ctl_doc(IdPfu,TipoDoc,LinkedDoc,idPfuInCharge,Azienda,Fascicolo)
				select @idPfu,'RIAMMISSIONE_OFFERTA',@idbando,@idPfu,Azienda,Fascicolo
					from ctl_doc with(NOLOCK) 						
					where id=@idbando

			set @id = SCOPE_IDENTITY()

		
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
