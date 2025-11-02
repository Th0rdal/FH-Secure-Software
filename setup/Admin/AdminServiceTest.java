import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class AdminServiceTest {

    private AdminService adminService;
    private ApplicationSettings settings;

    private final User adminUser = new User("admin_tester", Role.ADMIN);
    private final User normalUser = new User("normal_tester", Role.USER);

    /**
     * Setzt den Zustand VOR JEDEM einzelnen Test zurück.
     */
    @BeforeEach
    public void setup() {
        adminService = new AdminService();
        
        settings = ApplicationSettings.getInstance();
        
        settings.setCriticalSettingEnabled(false);
        
        SecurityContext.logout();
    }

    /**
     * Räumt NACH JEDEM Test den SecurityContext auf.
     */
    @AfterEach
    public void tearDown() {
        SecurityContext.logout();
    }


    /**
     * Der Test prüft, ob ein normaler Benutzer blockiert wird, wenn er
     * versucht, die Admin-Einstellung zu ändern.
     */
    @Test
    public void test_nonAdminCannotChangeAdminSetting() {
        SecurityContext.login(normalUser);
        
        assertFalse(settings.isCriticalSettingEnabled(), "Einstellung muss initial false sein.");

        try {
            adminService.changeAdminSetting(true);
        } catch (SecurityException e) {

        } catch (Exception e) {
            fail("Es wurde eine unerwartete Exception geworfen: " + e.getMessage());
        }

        assertFalse(settings.isCriticalSettingEnabled(), 
            "FEHLGESCHLAGEN"
        );
    }

    /**
     * Stellt sicher, dass ein Admin die Funktion weiterhin ausführen kann.
     */
    @Test
    public void test_adminMustBeAbleToChangeAdminSetting() {
        SecurityContext.login(adminUser);

        try {
            adminService.changeAdminSetting(true);
        } catch (Exception e) {
            fail("Admin wurde blockiert");
        }

        assertTrue(settings.isCriticalSettingEnabled(), "Ein Admin sollte die Einstellung auf 'true' setzen können.");
    }
}