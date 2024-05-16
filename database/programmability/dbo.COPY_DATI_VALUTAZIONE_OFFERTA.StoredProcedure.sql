USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[COPY_DATI_VALUTAZIONE_OFFERTA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[COPY_DATI_VALUTAZIONE_OFFERTA] ( @idDoc int ,  @ModelName varchar(200) , @Lotto varchar(100) )
as
begin

	--dal documento recupera la pda e le righe da riportare
	declare @idDocVal int
	select @idDocVal  = o.IdRow
			from 
				CTL_DOC m with (nolock)
				inner join CTL_DOC D with (nolock) on d.deleted = 0 and  m.LinkedDoc = d.linkedDoc and d.TipoDoc = 'PDA_MICROLOTTI'
				inner join Document_PDA_OFFERTE o with (nolock) on o.IdMsgFornitore = m.id and d.id = o.idheader
				--inner join Document_MicroLotti_Dettagli LP on o.idheader = LP.IdHeader and LP.TipoDoc = 'PDA_MICROLOTTI' and LP.NumeroLotto = '1'  and LP.Voce = 0 
				--inner join Document_MicroLotti_Dettagli LO on LO.IdHeader = o.idRow and LO.TipoDoc = 'PDA_OFFERTE' and LO.NumeroLotto = '1'  and LO.Voce = 0 
			where   m.id = @IdDoc 

	

	SET NOCOUNT ON;
	
	DECLARE @Sql as varchar(max)
	DECLARE @Column as varchar(max)
	DECLARE @AttrEccezzioni as varchar(max)


	set @AttrEccezzioni = 'id,idheader,TipoDoc,NumeroLotto,Voce,Variante,CIG,Descrizione,EsitoRiga,NumeroRiga,idHeaderLotto'

	set @Sql = ''
	set @Column = ''


	-- recupero dal sistema le colonne sulle quali basare il recupero dei dati
	if exists ( select MOD_ID from LIB_Models with (nolock) where MOD_ID = @ModelName )
	begin

		-- conpongo la query il cui risultato è XML + lo stament per cancellare dal record gli stessi valori
		SELECT @Column = @Column  + ' a.' + MA_DZT_Name + ' = b.' + MA_DZT_Name + ' ,'
			FROM LIB_ModelAttributes with (nolock)
				inner join syscolumns c on c.name = MA_DZT_Name
				inner join sysobjects o on o.id = c.id and o.name = 'Document_MicroLotti_Dettagli'
			WHERE MA_MOD_ID =  @ModelName  
					and charindex( ',' + MA_DZT_Name +',' , ',' +  @AttrEccezzioni + ',' ) = 0 

			ORDER BY MA_Order

	end
	else 
	begin
		-- recupero dal sistema le colonne sulle quali basare il recupero dei dati
		if exists ( select MOD_ID from CTL_Models with (nolock) where MOD_ID = @ModelName )
		begin


			-- conpongo la query il cui risultato è XML + lo stament per cancellare dal record gli stessi valori
			SELECT @Column = @Column  + ' a.'+  MA_DZT_Name + ' = b.' + MA_DZT_Name + ' ,'
				FROM CTL_ModelAttributes with (nolock)
					inner join syscolumns c on c.name = MA_DZT_Name
					inner join sysobjects o on o.id = c.id and o.name = 'Document_MicroLotti_Dettagli'
				WHERE MA_MOD_ID = @ModelName  
					and charindex( ',' + MA_DZT_Name +',' , ',' +  @AttrEccezzioni + ',' ) = 0 
				ORDER BY MA_Order

		end
	end


	if @Column <> '' 
	begin
		set @Column = left ( @Column , len(@Column ) - 1 ) 


		if @Lotto <> ''
		begin
			set @sql  = 'update   a set ' + @Column + ' 
				from  Document_MicroLotti_Dettagli as a inner join Document_MicroLotti_Dettagli as b on isnull( a.NumeroLotto , '''' )  = isnull( b.NumeroLotto , '''' ) and isnull( a.Voce , 0 )  = isnull( b.Voce , 0 ) and isnull( a.NumeroRiga , 0 ) = isnull( b.NumeroRiga , 0 ) 
				where b.idheader = ' + cast( @idDoc as varchar(20)) + ' and a.idheader = ' + cast( @idDocVal  as varchar(20)) + ' and b.TipoDoc = ''OFFERTA'' and a.TipoDoc = ''PDA_OFFERTE'' '


			set @sql = @sql + ' and b.NumeroLotto = ''' + @Lotto + ''' '
		end
		else
		begin
			set @sql  = 'update   a set ' + @Column + ' 
				from  Document_MicroLotti_Dettagli as a inner join Document_MicroLotti_Dettagli as b on isnull( a.NumeroRiga , 0 ) = isnull( b.NumeroRiga , 0 ) 
				where b.idheader = ' + cast( @idDoc as varchar(20)) + ' and a.idheader = ' + cast( @idDocVal  as varchar(20)) + ' and b.TipoDoc = ''OFFERTA'' and a.TipoDoc = ''PDA_OFFERTE'' '

		end

		exec( @sql )
		--print @sql

	end 
end



GO
