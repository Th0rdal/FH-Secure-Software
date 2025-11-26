/**
 * Speichert globale Anwendungseinstellungen als Singleton.
 */
public class ApplicationSettings {

    private static final ApplicationSettings instance = new ApplicationSettings();

    private volatile boolean criticalSettingEnabled = false;

    private ApplicationSettings() {}

    public static ApplicationSettings getInstance() {
        return instance;
    }

    public boolean isCriticalSettingEnabled() {
        return this.criticalSettingEnabled;
    }

    void setCriticalSettingEnabled(boolean status) {
        this.criticalSettingEnabled = status;
    }
}