using System.Text;
using System.Xml;
using System.Xml.Schema;

namespace eProcurementNext.Core.XMLValidation
{
    public enum Errors
    {
        XSDPath,
        XMLPath,
        XSD,
        ValidateXML,
        ReadXML,
        RuntimeException
    }

    public class XMLValidationOutput
    {
        public bool Esit { get; set; }
        public Errors Error { get; set; }
        public string RuntimeException { get; set; }
        public List<string> ValidationErrors { get; set; }
    }


    public class XMLValidation
    {
        //Default path
        private readonly string _basePath = string.Empty;
        private readonly bool _AllowDefaultResolver = false;

        //public string _basePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "wwwroot", "eForms", "XSD", "schemas", "maindoc");

        /// <summary>
        /// Costruttore della classi XMLValidation, utile a settare le variabili di base
        /// </summary>
        /// <param name="basePath">Il percorso assoluto di base al quale si accoderanno directory e file XSD</param>
        /// <param name="AllowDefaultResolver">se passato a true permette al validatore XSD di far navigare l'xsd primario con gli altri linkati. altrimenti XSD che referenziano altri XSD non funzionerebbero</param>
        public XMLValidation(string basePath, bool AllowDefaultResolver)
        {
            _basePath = basePath;
            _AllowDefaultResolver = AllowDefaultResolver;
        }


        /// <summary>
        /// Metodo prende in input 4 parametri: se i 2 bool sono settati a 'true' indicano che le 2 strighe vanno trattate come path 
        /// (relativi, a partire dalla directory del progetto)
        /// oppure se sono settati a false il metodo si aspetta il corpo dell'xml/xsd in input per intero come stringa.
        /// NB: in caso di XSD o XML linkati in più file, si consiglia di mantenere l'approccio a path
        /// </summary>
        /// <param name="Xml">Corpo del documento XML o Path che ne indica il percorso</param>
        /// <param name="Xsd">Corpo del documento XSD o Path che ne indica il percorso</param>
        /// <param name="isXmlPath">Settato a true indica che l'XML fornito è un path, a false invece indica che l'intero corpo è passato come stringa</param>
        /// <param name="isXsdPath">Settato a true indica che l'XSD fornito è un path, a false invece indica che l'intero corpo è passato come stringa<</param>
        /// <returns></returns>
        public XMLValidationOutput ValidateXML(string Xml, string Xsd, bool isXmlPath, bool isXsdPath)
        {
            //Istanzio gli oggetti e variabili
            XmlReaderSettings XSDsettings = new XmlReaderSettings();
            XMLValidationOutput Result = new XMLValidationOutput();
            Result.ValidationErrors = new List<string>();

            //Inizializzo il valore di output a true e RuntimeException come errore di default
            Result.Esit = true;
            Result.Error = Errors.RuntimeException;

            try
            {
                // Se l'XSD è da recuperare con un path e al percorso indicato non esiste il file interrompo il metodo e ritorno un errore
                if (isXsdPath && !File.Exists(Path.Combine(_basePath,Xsd)))
                {
                    Result.Error = Errors.XSDPath;
                    Result.Esit = false;
                    return Result;
                }
                /* Vado a creare gli elementi corretti in base all'input ricevuto per procedere alla validazione */
                else
                {
                    CreateXSD(XSDsettings, Xsd, isXsdPath, Result);
                }

                /* Avendo l'XSD vado ad eseguire la validazione dell'XML */
                if (isXmlPath)
                {
                    if (File.Exists(Path.Combine(_basePath,Xml)))
                    {
                        // Crea un oggetto XmlReader basato sulle impostazioni e sul file XML
                        using (XmlReader reader = XmlReader.Create(Xml, XSDsettings))
                        {
                            try
                            {
                                while (reader.Read()) { }
                            }
                            catch (XmlException ex)
                            {
                                //Se ci sono stati errori durante la lettura del file (file corrotto)
                                Result.Error = Errors.ReadXML;
                                Result.Esit = false;
                                Result.RuntimeException = ex.Message;
                                return Result;
                            }
                        }
                    }
                    else
                    {
                        Result.Error = Errors.XMLPath;
                        Result.Esit = false;
                        return Result;
                    }
                }
                else
                {
                    //Converto la stringa XML in un memorystream
                    byte[] byteArray = Encoding.UTF8.GetBytes(Xml ?? "");

                    using (MemoryStream stream = new MemoryStream(byteArray))
                    {
                        // Carica il documento XML e verifica la validità
                        using (XmlReader reader = XmlReader.Create(stream, XSDsettings))
                        {
                            try
                            {
                                while (reader.Read()) { }
                            }
                            catch (XmlException ex)
                            {
                                //Se ci sono stati errori durante la lettura del file (file corrotto)
                                Result.Error = Errors.ReadXML;
                                Result.Esit = false;
                                Result.RuntimeException = ex.Message;
                                return Result;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            //Se ci sono stati errori rispetto allo schema XSD
            if (Result.ValidationErrors.Count > 0)
            {
                Result.Error = Errors.ValidateXML;
                Result.Esit = false;
            }

            return Result;
        }

        private void CreateXSD(XmlReaderSettings settings, string Xsd, bool isXsdPath, XMLValidationOutput Result)
        {
            try
            {
                if ( _AllowDefaultResolver )
                    AppContext.SetSwitch("Switch.System.Xml.AllowDefaultResolver", true);

                settings.XmlResolver = new XmlUrlResolver();

                if (isXsdPath)
                {
                    // Aggiungo lo schema dell'XSD all'oggetto settings e setto il validationtype
                    string FullPath = Path.Combine(_basePath,Xsd);
                    settings.Schemas.Add(null, FullPath);
                }
                else
                {
                    // Converti la stringa XSD in un flusso
                    byte[] byteArray = System.Text.Encoding.UTF8.GetBytes(Xsd ?? "");
                    MemoryStream xsdStream = new MemoryStream(byteArray);

                    // Configura XmlReaderSettings
                    settings.Schemas.Add(null, XmlReader.Create(xsdStream));
                }

                //Parte di configurazione comune
                settings.ValidationType = ValidationType.Schema;
                settings.ValidationEventHandler += (sender, args) =>
                {
                    if (args.Severity == XmlSeverityType.Error)
                    {
                        // Aggiungo l'errore alla lista
                        Result.ValidationErrors.Add(args.Message);
                    }
                };

            }
            catch (Exception ex)
            {
                Result.Error = Errors.XSD;
                Result.Esit = false;
                Result.RuntimeException = ex.Message;
            }
        }
    }
}
