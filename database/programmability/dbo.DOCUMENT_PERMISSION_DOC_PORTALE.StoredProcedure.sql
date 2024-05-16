USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_PERMISSION_DOC_PORTALE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





---------------------------------------------------------------------------------------------------------------------
-- ***** Stored che controlla l'accesso ai documenti _PORTALE (utilizzati per la generazione degli xml dei bandi ****
-- *****          Applica le seguente regole  *******
-- Permetto l'apertura del documento se : 
--	1) Per poter accedere il documento non deve essere in ('InLavorazione','InApprove','Rifiutato', 'Annullato')
--  2) Il documento richiesto deve far parte del seguente sotto insieme di typeDoc : 'BANDO_GARA', 'BANDO_SDA', 'BANDO_SEMPLIFICATO','CONVENZIONE'
---------------------------------------------------------------------------------------------------------------------
--Versione=1&data=2015-06-25&Attivita=77080&Nominativo=Federico -----------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
CREATE PROC [dbo].[DOCUMENT_PERMISSION_DOC_PORTALE]
( 
	@idPfu   as int  , 
	@idDoc as varchar(50) ,
	@param as varchar(250)  = NULL  
)
AS
BEGIN

	IF upper( substring( @idDoc, 1, 3 ) ) = 'NEW'
	BEGIN
		select top 0 0 as bP_Read , 0 as bP_Write
	END
	ELSE
	BEGIN

		IF isnull(@param,'') <> ''
		BEGIN
			select top 0 0 as bP_Read , 0 as bP_Write
		END
		ELSE
		BEGIN

			declare @tipoDoc nvarchar(1000)
			declare @statoFunzionale nvarchar(1000)

			select @tipoDoc = a.TipoDoc,
				   @statoFunzionale = a.StatoFunzionale
				from ctl_doc a  WITH (NOLOCK)  where a.id = @idDoc

			IF @tipoDoc in ( 'BANDO_GARA', 'BANDO_SDA', 'BANDO_SEMPLIFICATO', 'CONVENZIONE','BANDO','BANDO_CONSULTAZIONE' )
				 and 
			   @statoFunzionale not in ('InLavorazione','InApprove', 'Rifiutato', 'Annullato')
			BEGIN
				select 1 as bP_Read , 0 as bP_Write
			END
			ELSE
			BEGIN
				select top 0 0 as bP_Read , 0 as bP_Write
			END

		END 

	END

END




GO
