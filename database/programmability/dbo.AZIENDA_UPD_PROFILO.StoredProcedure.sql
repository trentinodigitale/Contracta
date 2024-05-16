USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[AZIENDA_UPD_PROFILO]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AZIENDA_UPD_PROFILO] ( @idAzi INT)
AS

	SET NOCOUNT ON

	declare @disabilita_iscriz_peppol varchar(10) = ''
	declare @sysModuli nvarchar(max) = ''

	select @sysModuli = DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI'
	select items into #moduli_attivi from dbo.Split( @sysModuli ,',' )

	-- Se è attivo il modulo notier/peppol
	if exists ( select * from #moduli_attivi where items = 'GROUP_NOTIER' )
	begin

		select @disabilita_iscriz_peppol = vatvalore_ft from DM_Attributi with(nolock) where lnk = @idAzi and dztNome = 'disabilita_iscriz_peppol' and idApp = 1

		-- se è stato chiesto di disabilitare la possibilità perl'ente di registrarsi peppol, rimuoviamo dai suoi aziProfili la R ( Registrazione notier )
		if @disabilita_iscriz_peppol = 'si'
		begin
			
			update aziende
					set aziProfili = replace(aziProfili, 'R','')
				where idazi = @idAzi and aziProfili like '%R%'

		end
		else
		begin

			-- se non c'era lo aggiungiamo
			update aziende
					set aziProfili = isnull(aziProfili,'') + 'R'
				where idazi = @idAzi and aziProfili not like '%R%'

		end


	end


GO
