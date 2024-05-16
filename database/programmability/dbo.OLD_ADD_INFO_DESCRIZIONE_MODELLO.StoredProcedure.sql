USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ADD_INFO_DESCRIZIONE_MODELLO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE     PROCEDURE [dbo].[OLD_ADD_INFO_DESCRIZIONE_MODELLO] ( @idUser int , @param varchar(max)='')
AS
BEGIN
	---@IdDoc corrisponde ad IDAZI
	SET NOCOUNT ON

	If @param <> '' 
	begin
		declare @cv as nvarchar(MAX)

		select  @cv = CV.Value
						from ctl_doc c
								inner join CTL_DOC_Value CV on CV.idHeader=id and CV.DSE_ID='CLASSE' and CV.DZT_Name='ClasseIscriz'
						where TipoDoc='CONFIG_MODELLI_MERC_ADDITIONAL_INFO' 
						--and c.Titolo='45110000_1'
						and c.Titolo=@param
						and Deleted=0 and StatoFunzionale in ('Pubblicato')	

		select  C.DMV_DescML from dbo.split(@cv,'###') inner join ClasseIscriz C on C.DMV_Cod=items
				order by items
	end
	else
	begin
		select '' as DMV_DescML
	end

END
GO
