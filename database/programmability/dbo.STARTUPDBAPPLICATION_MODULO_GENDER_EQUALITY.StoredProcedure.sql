USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[STARTUPDBAPPLICATION_MODULO_GENDER_EQUALITY]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[STARTUPDBAPPLICATION_MODULO_GENDER_EQUALITY]
AS
BEGIN
		
	-----------------------------------------------------------------------
	-- attivazione e disattivazione del modulo GENDER_EQUALITY
	-----------------------------------------------------------------------
	--
	declare @listaModelli varchar(4000)
	set @listaModelli = 'BANDO_GARA_TESTATA@BANDO_GARA_TESTATA_AVVISO@BANDO_GARA_TESTATA_GAREINFORMALI@BANDO_GARA_TESTATA_ACCORDOQUADRO@BANDO_SEMPLIFICATO_TESTATA@BANDO_SEMPLIFICATO_TESTATA2@BANDO_CONSULTAZIONE_TESTATA'


	IF EXISTS (	select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI' and ',' + DZT_ValueDef + ',' like '%,GENDER_EQUALITY,%'	)
	BEGIN
		
		update CTL_Parametri
			set Valore = '0'
		from CTL_Parametri
				inner join dbo.Split(@listamodelli,'@' ) on items = Contesto 
		where Oggetto='GenderEquality' and Proprieta='Hide'


		update CTL_Parametri
			set Valore = '0'
		from CTL_Parametri
				inner join dbo.Split(@listamodelli,'@' ) on items = Contesto 
		where Oggetto='GenderEqualityMotivazione' and Proprieta='Hide'


		update CTL_Parametri
			set Valore = '0'
		where Oggetto='GenderEquality' 
		and Proprieta='Hide' 
		and Contesto = 'CONVENZIONE_TESTATA'

	END
	ELSE
	BEGIN

		update CTL_Parametri
			set Valore = '1'
		from CTL_Parametri
				inner join dbo.Split(@listamodelli,'@' ) on items = Contesto 
		where Oggetto='GenderEquality' and Proprieta='Hide'


		update CTL_Parametri
			set Valore = '1'
		from CTL_Parametri
				inner join dbo.Split(@listamodelli,'@' ) on items = Contesto 
		where Oggetto='GenderEqualityMotivazione' and Proprieta='Hide'


		update CTL_Parametri
			set Valore = '1'
		where Oggetto='GenderEquality' 
		and Proprieta='Hide' 
		and Contesto = 'CONVENZIONE_TESTATA'

	END

END
GO
