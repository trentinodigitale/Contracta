using Microsoft.VisualBasic;

namespace eProcurementNext.Session
{
    public partial class Session : ISession
    {
        public DateTime Expires => this.LastUpdate.AddMinutes(this.Timeout);

        public DateTime LastUpdate
        {
            get => (DateTime)this[SessionProperty.LastUpdate]!;
            private set => this[SessionProperty.LastUpdate] = value;
        }

        public string? LastUpdatePath
        {
            get => this[SessionProperty.LastUpdatePage];
            set => this[SessionProperty.LastUpdatePage] = value;
        }

        public int Timeout
        {
            get => (int)(this[SessionProperty.Timeout] ?? throw new InvalidOperationException());
            private set => this[SessionProperty.Timeout] = value;
        }

        public bool SigningOut { get; set; }

        public string SessionID => (string)this[SessionProperty.Id]!;

        public string SessionIDMinimal
        {
            get
            {
                var reducedSessionId = Math.Abs(this.SessionID.GetHashCode()).ToString();

                //'-- normalizzo togliendo gli 0 a sinistra
                while (!string.IsNullOrEmpty(reducedSessionId) && Strings.Left(reducedSessionId, 1) == 0.ToString())
                {
                    reducedSessionId = Strings.Right(reducedSessionId, reducedSessionId.Length - 1);
                }

                return reducedSessionId;
            }
        }

        public string IDAZIENDA
        {
            get
            {
                var bsonElementValue = this[SessionProperty.IDAZIENDA];
                var value = bsonElementValue != null ? bsonElementValue.ToString() : string.Empty;
                return value;
            }
        }

        public string USERNAME
        {
            get
            {
                var bsonElementValue = this[SessionProperty.USERNAME];
                var value = bsonElementValue != null ? bsonElementValue.ToString() : string.Empty;
                return value;
            }
        }
    }
}