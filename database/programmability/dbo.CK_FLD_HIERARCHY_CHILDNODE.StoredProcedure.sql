USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_FLD_HIERARCHY_CHILDNODE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[CK_FLD_HIERARCHY_CHILDNODE]( @Domain varchar(500) , @Codice as varchar(500) )
AS
begin
	declare @Codice_padre as varchar(500)

	--recupero codice padre del nodo
	select 
		@Codice_padre=dmv_father 
		from 
			LIB_DomainValues with (nolock) 
		where DMV_DM_ID =@Domain and DMV_Cod =@Codice
	
	if not exists (
			select 
					top 1 DMV_Cod  
				from 
					LIB_DomainValues with (nolock)
				where 
					dmv_father like @Codice_padre +'%' and DMV_DM_ID=@Domain
					and dmv_father <> @Codice_padre
				)
		select  'YES' as Esito
	else
		select top 0 'NO' as Esito
end

GO
