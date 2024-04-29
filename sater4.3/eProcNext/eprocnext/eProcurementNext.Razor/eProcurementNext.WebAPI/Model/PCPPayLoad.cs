using eProcurementNext.PDND;

namespace eProcurementNext.WebAPI.Model
{
    public class PCPPayLoad
    {
        public string iss { get; set; }
        public string sub { get; set; }
        public string aud { get; set; }
        public string purposeId { get; set; }
        public string jti { get; set; }
        public long iat { get; set; } // => DateTimeOffset.UtcNow.ToUnixTimeSeconds();
        public long exp { get; set; } // da appsettings recuperare la scadenza in secondi nel caso venisse modificata nel tempo
        public long nbf { get; set; }
    }

    public class PCPPayloadWithData : PCPPayload
    {
        //public long nbf { get; set; } // not before
        public string userLocation { get; set; } = "postazione di test";
        public string userCodiceFiscale { get; set; }
        public string userRole { get; set; } = "RP";
        public string userLoa { get; set; } = "3";
        public string userIdpType { get; set; }   /*    description: tipo di identity provider utilizzato per stabilire l'identità dell'utente.
                                                        type: string
                                                        example: "SPID"
                                                        enum:
                                                        - "SPID"
                                                        - "CIE"
                                                        - "CNS"
                                                        - "EIDAS"
                                                        - "CUSTOM" # sistema interno al gestore della piattaforma certificata */
        public string SAcodiceAUSA { get; set; }        /*# blocco SA, Stazione Appaltante. Dati identificativi della stazione appaltante alla quale afferisce l'utente connesso        
                                                        SACodiceFiscale:
                                                        description: codice Fiscale della stazione appaltante. Può essere nullo in caso di soggetti non dotati di personalità giuridica
                                                        type: string
                                                        example: "11111111115"
                                                        SAcodiceAUSA:  
                                                        description: codice ausa della stazione appaltante alla quale appartiene l'utente
                                                        type: string
                                                        example: "0000000000" 
                                                         */
        public string regCodicePiattaforma { get; set; }
        public string regCodiceComponente { get; set; }
        public string businessFlowID { get; set; } = new Guid().ToString(); // sarà uguale a "00000000-0000-0000-0000-000000000000"
        /* businessFlowID:
           description: coincide con idAppalto. Assume valore "00000000-0000-0000-0000-000000000000" 
           nella prima transazione (che è necessariamente comunicaAppalto.crea-appalto) In tutte le operazioni 
           successive riconduce la transazione all’appalto
           type: string
           example: "8cc2d6ca-690d-4031-b75d-b0139b7ace39"
        */
        public string traceID { get; set; } = Guid.NewGuid().ToString();
        public string spanID { get; set; } = Guid.NewGuid().ToString();     /* description: identificativo univoco assegnato dalla piattaforma (?) all'operazione iniziale richiesta dall'utente 
                                                                               type: string
                                                                               example: "8cc2d6ca-690d-4031-b75d-b0139b7ace39"
                                                                            */

    }

    public class ComplementaryPayload
    {
        public PCPHeader header { get; set; }
        public PCPPayload payload { get; set; }
    }

    public class PCPPayloadWithHash : PCPPayload
    {
        public Digest digest { get; set; }

    }

    public class PCPHeader
    {
        public string kid { get; set; }
        public string alg { get; set; } = "RS256";
        public string typ { get; set; } = "JWT";
    }

    public class PCPEservice
    {
        public string id { get; set; }
        public string endpoint { get; set; }
        public string purposeId { get; set; }
        public string clientId { get; set; }
        public string kid { get; set; }
    }

}
