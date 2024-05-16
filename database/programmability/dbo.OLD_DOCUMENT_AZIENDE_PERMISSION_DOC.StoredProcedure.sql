USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DOCUMENT_AZIENDE_PERMISSION_DOC]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[OLD_DOCUMENT_AZIENDE_PERMISSION_DOC]( 
	@idPfu   as int  , 
	@idDoc as varchar(50) ,
	@param as varchar(250)  = NULL     )
as
begin

	declare @idAzi			int
    declare @IdAziMaster as int
	declare @AziFrom		varchar(100)


	select @IdAziMaster=mpidazimaster from marketplace
	select @idAzi = pfuIdAzi  from profiliutente with(nolock)	where idPfu = @idPfu

	--azienda master vede tutto
	if @idAzi=@IdAziMaster and @idPfu>0
	begin
		select  top 1 1 as bP_Read , 1 as bP_Write
	end
	else
	begin
		-- se sto creando un documento devo verificare che la provenienza sia coerente con l'utente
		if upper( substring( @idDoc, 1, 3 ) ) = 'NEW' or @idDoc = '' 
		begin

		    if  isnull( @param , '' ) <> '' 
			begin

				set @AziFrom = dbo.GetPos( @param ,',' ,2 )

				-- SE L'AZIENDA A CUI SI FA LA MODIFICA è DELL'UTENTE COLLEGATO OPPURE L'UTENTE APPARTIENE ALL'AZIENDA MASTER
				IF @AziFrom = @idAzi OR @idAzi=@IdAziMaster or @param = '@@@PROCESS'
					select 1 as bP_Read , 1 as bP_Write
				else
					select top 0 1 as bP_Read , 1 as bP_Write


			end
			else
			begin
					select 1 as bP_Read , 1 as bP_Write
			end

		end
		else
		begin


			----azienda master napoli vede tutto
			--if @idAzi=@IdAziMaster and @idPfu>0
			--begin
			--	select  top 1 1 as bP_Read , 1 as bP_Write
			--end
			--else
			begin
				select  top 1 1 as bP_Read , case when doc.IdPfu = @idPfu then 1 else 0 end as bP_Write
					from document_aziende doc  with(nolock)
						inner join profiliutente p1 with(nolock)  on p1.pfuidazi = doc.IdAzi
					where doc.Id = @idDoc
						and ( p1.idpfu=@idPfu or p1.pfuidAzi = @idAzi )
						and @idPfu>0
					order by bP_Write desc
				
			end
	
		end
	end
end





GO
