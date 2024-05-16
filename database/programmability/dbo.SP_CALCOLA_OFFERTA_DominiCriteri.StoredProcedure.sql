USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SP_CALCOLA_OFFERTA_DominiCriteri]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[SP_CALCOLA_OFFERTA_DominiCriteri] ( @idDoc int  ) 
AS
BEGIN

	SET NOCOUNT ON
	declare @value as nvarchar(max)
	declare @tipodoc as nvarchar(max)
	declare @DZT_NAME as nvarchar(max)
	declare @NL as nvarchar(max)
	declare @Valori as nvarchar(max)
	set @value=''
	set @NL=''
	set @DZT_NAME=''
	set @Valori=''

	select @tipodoc=TipoDoc from CTL_DOC whith(nolock) where Id=@idDoc
	set @value='{"ATTRIBUTI":['

	
	select 
			@value=@value + '{ "Contesto" : "' + NL + '" , "Attributo" : "' + Attributo + '" , "Valori" : "' +   dbo.EscapeJson(Formula) + '" },'			
			
		from 
		(
			select 
					'B' as NL,
					dbo.GetPos(DV.AttributoCriterio,'.', 2) as Attributo,
					dbo.Spacchetta_Formule( Formula , DIZ.DZT_Name , DIZ.DZT_Type) as Formula

					from Document_Microlotto_Valutazione DV with(nolock)
						inner join LIB_Dictionary DIZ  with(nolock) on DIZ.DZT_Name=dbo.GetPos(DV.AttributoCriterio,'.', 2)
						where  DV.idheader=@idDoc and DV.TipoDoc=@tipodoc 
							and DV.CriterioValutazione='quiz' and dbo.GetPos(DV.Formula,'#'+'='+'#', 2) in ( 'dominio') 

			union all
			
			select 
					o.NumeroLotto as NL,
					dbo.GetPos(DV.AttributoCriterio,'.', 2) as Attributo,
					dbo.Spacchetta_Formule( Formula , DIZ.DZT_Name ,  DIZ.DZT_Type) as Formula

					from Document_MicroLotti_Dettagli o with(nolock)						
						inner join Document_Microlotto_Valutazione DV with(nolock) on DV.TipoDoc='LOTTO' and DV.idHeader=o.Id and DV.CriterioValutazione='quiz' 		
						inner join LIB_Dictionary DIZ  with(nolock) on DIZ.DZT_Name=dbo.GetPos(DV.AttributoCriterio,'.', 2)
				where	o.IdHeader = @idDoc 
						and O.TipoDoc = @tipodoc 
						and O.voce = 0
						and dbo.GetPos(DV.Formula,'#'+'='+'#', 2) in ( 'dominio') 
		) W
	
	
	
	if @value <> '{"ATTRIBUTI":[' 
	BEGIN
		--RIMUOVE LA , finale
		 set @value = SUBSTRING (@value,1,Len(@value)-1) 			 
				
	END
	
	set @value=@value  + '] }'	
	
	
	--POPOLO IL VALORE CALCOLATO NELLA CTL_DOC_VALUE SUL BANDO
	DELETE FROM CTL_DOC_Value where IdHeader=@idDoc and DSE_ID='CRITERI_TEC' and DZT_Name='JSON_DOMINI_CRITERI'
	
	INSERT INTO CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Row,Value)
		select @idDoc, 'CRITERI_TEC' ,'JSON_DOMINI_CRITERI',0,@value
	
END	
	
	
	
	
GO
