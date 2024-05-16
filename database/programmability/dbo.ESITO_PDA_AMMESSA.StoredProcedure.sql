USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ESITO_PDA_AMMESSA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROC [dbo].[ESITO_PDA_AMMESSA]( @idRow int , @idUser int )
as
begin
	declare @Protocollo varchar(50)
	set @Protocollo=''
	--exec CTL_GetProtocol @idUser ,@Protocollo output 

	declare @LinkedDoc int
	declare @IdMsg int
	declare @Azienda int
	declare @Fascicolo varchar(50)

	select @LinkedDoc = IdHeader , @IdMsg = IdMsg , @Azienda = idAziPartecipante , @Fascicolo = Fascicolo
		from Document_PDA_OFFERTE o
				inner join CTL_DOC c on c.id = o.idheader
			where o.IdRow = @idRow

	insert into CTL_DOC ( IdPfu , IdDoc , TipoDoc , StatoDoc , Protocollo , Body , Azienda , DataInvio , Fascicolo , LinkedDoc , StatoFunzionale)
		values ( @idUser , @IdMsg , 'ESITO_AMMESSA' , 'Sended' , @Protocollo , '' , @Azienda , getdate() , @Fascicolo , @idRow , 'Confermato')

	update  Document_PDA_OFFERTE set StatoPDA = '2' where idRow = @idRow

end
GO
