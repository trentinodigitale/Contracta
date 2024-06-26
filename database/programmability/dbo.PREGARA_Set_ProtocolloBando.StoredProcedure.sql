USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PREGARA_Set_ProtocolloBando]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[PREGARA_Set_ProtocolloBando] ( @id int )
AS
BEGIN 
 	set nocount on
	IF EXISTS( SELECT id from CTL_DOC with(nolock) where  id =@id and StatoFunzionale = 'VerificaAtti' )
	begin

		if exists ( select idheader from Document_Bando where idHeader  = @id and ISNULL( protocolloBando , '' ) = '' )
		begin
			declare @Protocollo varchar(50) 
			declare @TipoAppaltoGara varchar (50 )
			declare @Sigla varchar (50 )
			select @TipoAppaltoGara  = TipoAppaltoGara from Document_Bando where idHeader  = @id 

			set @Sigla = case  @TipoAppaltoGara 
				when '1' then 'F' -- Forniture
				when '2' then 'L' -- Lavori
				when '3' then 'S' -- Servizi
				when '5' then 'SI' -- Servizi Ingegneria
				else ''
				end


			exec ctl_GetNewProtocol 'PREGARA' , @Sigla ,@Protocollo output 

			update Document_Bando set ProtocolloBando = @Protocollo where idHeader = @id

		end
	end
end
GO
