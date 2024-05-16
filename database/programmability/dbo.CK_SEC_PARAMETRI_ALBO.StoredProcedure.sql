USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_SEC_PARAMETRI_ALBO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[CK_SEC_PARAMETRI_ALBO] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
AS
BEGIN
	declare @Blocco nvarchar(1000)
	set @Blocco = ''

	-- verifico se la sezione puo essere VISIBILE in base al parametro settato sul cliente

	IF upper(@SectionName) = 'CONTROLLI' 
	BEGIN
		set @Blocco = 'NON_VISIBILE'
		IF EXISTS ( select id from CTL_Parametri with(nolock) 
						where Contesto='ATTIVA_MODULO' and Oggetto='CONTROLLI_OE' 
								and Proprieta='ATTIVA' and Valore='YES'
				  )
		BEGIN
			set @Blocco = ''
		END		
	END





	select @Blocco as Blocco

END
GO
