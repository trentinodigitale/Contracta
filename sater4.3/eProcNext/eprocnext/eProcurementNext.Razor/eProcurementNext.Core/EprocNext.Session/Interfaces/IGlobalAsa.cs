namespace eProcurementNext.Razor
{
    public interface IGlobalAsa
    {
        public void MY_Application_OnStart();
        public void Application_OnEnd();

        public void RefreshApplicationBase();

    }
}
