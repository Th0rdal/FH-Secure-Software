import java.util.logging.Logger;

/**
 * Service-Klasse zur Verwaltung von Anwendungseinstellungen.
 */
public class AdminService {

    private final ApplicationSettings settings = ApplicationSettings.getInstance();
    private static final Logger logger = Logger.getLogger(AdminService.class.getName());

    public boolean getCriticalSettingStatus() {
        User user = SecurityContext.getCurrentUser();
        boolean status = settings.isCriticalSettingEnabled();
        logger.info("Benutzer '" + user.getUsername() + "' fragt 'criticalSettingEnabled' ab. Status: " + status);
        return status;
    }

    public void changeAdminSetting(boolean newStatus) {
                
        User user = SecurityContext.getCurrentUser();
        
        logger.info(
            "Benutzer '" + user.getUsername() + "' ändert 'criticalSettingEnabled' auf: " + newStatus
        );
        
        settings.setCriticalSettingEnabled(newStatus);
        
    }
}