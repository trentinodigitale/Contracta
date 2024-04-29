function PRODOTTI_OnLoad()
{
    ShowCol_TipoOrdine();

}


function ShowCol_TipoOrdine()
{

        var TipoOrdine = 'S';
        try{ TipoOrdine = getObjValue( 'TipoOrdine' );   } catch ( e ) {TipoOrdine = 'S';};



        if( TipoOrdine == 'S' )
        {

            //ShowCol( 'PRODOTTI' , 'CodArt' , '' );
            //ShowCol( 'PRODOTTI' , 'QtMin' , '' );
            ShowCol( 'PRODOTTI' , 'CARQuantitaDaOrdinare' , '' );

            ShowCol( 'PRODOTTI' , 'CostoComplessivo' , 'none' );
            ShowCol( 'PRODOTTI' , 'CoefCorr' , 'none' );
            ShowCol( 'PRODOTTI' , 'PercSconto' , 'none' );
            ShowCol( 'PRODOTTI' , 'DataUtilizzo' , 'none' );
            ShowCol( 'PRODOTTI' , 'ImportoCompenso' , 'none' );
        
        }
        
        if( TipoOrdine == 'P' )
        {
        
            //ShowCol( 'PRODOTTI' , 'CodArt' , 'none' );
            ShowCol( 'PRODOTTI' , 'QtMin' , 'none' );
            //ShowCol( 'PRODOTTI' , 'CARQuantitaDaOrdinare' , 'none' );

            ShowCol( 'PRODOTTI' , 'CostoComplessivo' , 'none' );
            ShowCol( 'PRODOTTI' , 'CoefCorr' , 'none' );
            ShowCol( 'PRODOTTI' , 'PercSconto' , '' );
            ShowCol( 'PRODOTTI' , 'DataUtilizzo' , '' );
            ShowCol( 'PRODOTTI' , 'ImportoCompenso' , 'none' );
        
        }

        if( TipoOrdine == 'C' )
        {
        
            //ShowCol( 'PRODOTTI' , 'CodArt' , '' );
            //ShowCol( 'PRODOTTI' , 'QtMin' , '' );
            ShowCol( 'PRODOTTI' , 'CARQuantitaDaOrdinare' , '' );

            ShowCol( 'PRODOTTI' , 'CostoComplessivo' , '' );
            ShowCol( 'PRODOTTI' , 'CoefCorr' , '' );
            ShowCol( 'PRODOTTI' , 'PercSconto' , 'none' );
            ShowCol( 'PRODOTTI' , 'DataUtilizzo' , 'none' );
            ShowCol( 'PRODOTTI' , 'ImportoCompenso' , 'none' );
        
        }


        if( TipoOrdine == 'B' )
        {
        
            //ShowCol( 'PRODOTTI' , 'CodArt' , 'none' );
            ShowCol( 'PRODOTTI' , 'QtMin' , 'none' );
            //ShowCol( 'PRODOTTI' , 'CARQuantitaDaOrdinare' , 'none' );

            ShowCol( 'PRODOTTI' , 'CostoComplessivo' , 'none' );
            ShowCol( 'PRODOTTI' , 'CoefCorr' , 'none' );
            ShowCol( 'PRODOTTI' , 'PercSconto' , '' );
            ShowCol( 'PRODOTTI' , 'DataUtilizzo' , '' );
            ShowCol( 'PRODOTTI' , 'ImportoCompenso' , '' );
        
        }
        
        

}
