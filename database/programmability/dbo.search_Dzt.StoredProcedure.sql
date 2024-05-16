USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[search_Dzt]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--===============================
--	CODICE STRUTTURA	=
--===============================
CREATE PROCEDURE [dbo].[search_Dzt]
      @Str_Iddzt VARCHAR(8000),
      @Str_Lingua VARCHAR(100)
as 
      BEGIN 
             
            --Controllo Lingue 
                  
            DECLARE @str_SELECT VARCHAR(8000)
            set @str_SELECT = 'SELECT x.dsctesto AS ''DescrizioneAttributo'',gg.dsctesto AS ''DescrizioneGruppo'',gg.idgum,x.tidtipomem,x.tidtipodom,x.dztProfili,x.idtid,x.iddzt,x.dztnome
                  FROM (
                              SELECT *  
                              FROM ### d inner join dizionarioattributi z
                              on z.dztiddsc = d.iddsc 
                                          inner join tipidati t
                              on z.dztidtid = t.idtid 
                              WHERE z.iddzt in (@@@) AND z.dztdeleted =0
                       ) x left outer join 
                                    (SELECT * 
                                     FROM gruppiunitamisura g  inner join ### xx
                                     on g.gumiddscNome = xx.iddsc WHERE gumDeleted = 0) AS gg
                                    on x.dztidgum = gg.idgum'
            IF @str_iddzt  = ''
                        BEGIN
                              set @str_iddzt = -1
                        END
                              set @str_SELECT = replace(@str_SELECT,'@@@',@Str_Iddzt)
                              
                              
                        
            set @str_SELECT = case
                              when @Str_Lingua = 'I' then replace(@str_SELECT,'###','DescsI')
                              when @Str_Lingua = 'UK' then replace(@str_SELECT,'###','DescsUK')
                              when @Str_Lingua = 'E' then replace(@str_SELECT,'###','DescsE')
                              when @Str_Lingua = 'FRA' then replace(@str_SELECT,'###','DescsFRA')
                                    when @Str_Lingua = 'Lng1' then replace(@str_SELECT,'###','DescsLng1')
                              when @Str_Lingua = 'Lng2' then replace(@str_SELECT,'###','DescsLng2')
                              when @Str_Lingua = 'Lng3' then replace(@str_SELECT,'###','DescsLng3')
                              when @Str_Lingua = 'Lng4' then replace(@str_SELECT,'###','DescsLng4')
                         end 
            execute (@str_SELECT)
            --print @str_SELECT 
            IF @@error <> 0
                        BEGIN
                              raiserror ('Errore',16,1)
                              return
                        END 
             
      END
GO
