USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PDA_UPD_WARNING]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[OLD2_PDA_UPD_WARNING]( @idPda as int )
as
begin

	declare @idrow int
	------------------------------------------------------
	--aggiorno il warning
	------------------------------------------------------
	declare @Warning as nvarchar(max)
	update 
		Document_PDA_OFFERTE 
			set Warning = ''
		where 
			idheader=@idPda

	declare CurProgW Cursor static for 
	
	Select 
		distinct IdRow 
		from  
			Document_PDA_OFFERTE o with (nolock)
		where 
			idheader=@idPda

	open CurProgW

	FETCH NEXT FROM CurProgW INTO @idrow
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		set @Warning = ''

		--recupero tutti i warning della riga offerta corrente
		select @Warning=@Warning + ' - ' + Descrizione from Document_Pda_Offerte_Anomalie where IdRowOfferta=@idrow and IdHeader = @idPda

				
		--print @Warning
		set @Warning = substring(@Warning,4,len(@Warning))

		--se presente aggiorna colonna riepilogativa su offerta
		if @Warning <> ''
		begin
			update Document_PDA_OFFERTE 
				set Warning = '<img src="../images/Domain/State_Warning.png" alt="' + @Warning + '" title="' + @Warning + '">'
				where 
					idRow=@idrow
		end

	             
		FETCH NEXT FROM CurProgW INTO @idrow
	END 
	CLOSE CurProgW
	DEALLOCATE CurProgW

end

GO
