namespace Core.Logger.HelkLogEntry.Types
{
    public class EventInfo<T>
    {
        /// <summary>
        /// Message logged by the occurred event.
        /// NOTE => clear text with NO base64 character or documents
        /// or any other content
        /// </summary>
        public T Message { get; set; }

        /// <summary>
        /// Duration of the event in nanoseconds
        /// </summary>
        public long Duration { get; set; }
    }
}
