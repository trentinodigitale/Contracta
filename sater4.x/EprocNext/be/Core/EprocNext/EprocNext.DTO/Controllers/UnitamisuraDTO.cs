using System;

namespace FTM.Cloud.Services.DTO
{
    public partial class UnitamisuraDTO 
    {
        public Int64 Az06Id { get; set; }
        public Int64 Az06Idaziendaaz01 { get; set; }
        public String Az06Um { get; set; }
        public String Az06Descrizione { get; set; }
        public Boolean? Az06Indoperatore { get; set; }
        public Decimal? Az06Fattconv { get; set; }
    }
}

