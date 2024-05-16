USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[AQ_ABILITAZIONE_RILANCIO_CREATE_FROM_AQ]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[AQ_ABILITAZIONE_RILANCIO_CREATE_FROM_AQ] 
	( @idAQ int  , @idUser int )
AS
BEGIN
	declare @id int		
	declare @Errore as nvarchar(4000)
	set @Errore = ''

	SET NOCOUNT ON

	--La make doc from riapre il documento se lo trova altrimenti lo crea nuovo se è rifiutato o non esiste
	select @id=id from CTL_DOC with(nolock) where  idpfu=@idUser and  LinkedDoc=@idAQ and TipoDoc='AQ_ABILITAZIONE_RILANCIO' and deleted=0 and StatoFunzionale  not in ('Rifiutato') 


	--CREA IL DOC
	if ISNULL(@id,0)=0 and @Errore = ''
	begin		
		--CREA IL DOCUMENTO
		INSERT into CTL_DOC ( IdPfu,  TipoDoc , deleted  ,LinkedDoc,Body,Fascicolo ,Azienda)
			select @idUser, 'AQ_ABILITAZIONE_RILANCIO'  , 0 , id , body ,C.Fascicolo,P.pfuidazi
				from CTL_DOC C with(NOLOCK) 
					inner join ProfiliUtente P with(nolock) on P.IdPfu=@idUser				
				WHERE C.Id=@idAQ 		
					
			set @id=SCOPE_IDENTITY()

		--inserisco la riga nella ctl_approvalStep
		insert into ctl_approvalsteps 
			(APS_Doc_Type,APS_ID_DOC,APS_State,APS_Note,APS_Allegato,APS_UserProfile,APS_Idpfu,APS_IsOld)
				select top 1 'AQ_ABILITAZIONE_RILANCIO',@Id,'Compiled','','',isnull( attvalue,''),@IdUser,0 
					from profiliutenteattrib p  
					where  p.idpfu = @IdUser and dztnome = 'UserRoleDefault'
	end



		
		if @Errore = '' and ISNULL(@id,0) <> 0
		begin
			-- rirorna l'id del doc da aprire
			select @Id as id
				
		end
		else
		begin

			select 'Errore' as id , @Errore as Errore

		end



END

	
GO
