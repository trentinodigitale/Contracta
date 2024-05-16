USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[sp_DOCUMENT_CARRELLO_ME]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select * from carrello_me

--select * from aziende where idazi = 35159186




CREATE PROCEDURE [dbo].[sp_DOCUMENT_CARRELLO_ME] 
(@IdPfu							int,
 @AttrName						varchar(8000),
 @AttrValue						varchar(8000),
 @AttrOp 						varchar(8000),
 @Filter                        varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output
)
AS


	SET NOCOUNT ON
	declare @SQLCmd	varchar(max)
	declare @CrLf varchar (10)
	set @CrLf = '
'

	exec CHECK_ODA_TOTALE_EROSO @IdPfu

	set @SQLCmd = 'select	C.[id], [Marca], [Linea], [Modello], [Codice], [Categoria], c.Descrizione, [Nota], [QtMin], [QTDisp], [Composizione], [Fascia], c.PrezzoUnitario, [Foto], [Colore], c.deleted, c.idPfu, [QtaXconf], [NumConf], [Plant], [Id_Catalogo], [Id_Product], [TipoOrdine], [ImportoCompenso], [UnitMis], [Immagine], [Brochure], [TipoProdotto], [ToDelete], [RicPreventivo],[Importo_Residuo_Quote], [Iva], c.Titolo,  [Not_Editable] 
							, D.UnitadiMisura
							, ca.azienda as Mandataria 
							, ca.azienda as Fornitore
							, C.EsitoRiga
						from carrello_ME C with(nolock ) 		
							inner join document_microlotti_dettagli D with(nolock )  on C.Id_Product=D.id		
							inner join CTL_DOC ca with(nolock )  on D.idheader= ca.id		
						where c.idPfu = ' + CAST(@IdPfu as varchar(10)) + ''
		
	exec (@SQLCmd)



						
						
						
					
GO
